import json
from abc import ABC, abstractmethod
from typing import Any, Dict, List, Optional

import _snowflake
import pandas as pd
import streamlit as st

# constants --------------------------------------------------------------
SEMANTIC_VIEW = "DEMONSTRATION.WEATHER.GLOBAL_WEATHER_SV"

# streamlit initialization ---------------------------------------------
st.set_page_config(page_title="Weather Chatbot", layout="wide")
st.title("Weather Data Chatbot")
st.caption(f"Powered by Cortex Analyst · Semantic View: `{SEMANTIC_VIEW}`")


# session state helpers -------------------------------------------------
def ensure_session_state():
    """Ensures that required keys are present in the Streamlit session state.

    Initializes 'messages' as an empty list and 'active_suggestion' as None if they do not already exist.
    This function is called at the module level to set up the session state before the app runs.
    """
    if "messages" not in st.session_state:
        st.session_state.messages = []
    if "active_suggestion" not in st.session_state:
        st.session_state.active_suggestion = None


ensure_session_state()


class ISnowflakeClient(ABC):
    """Abstract interface for sending messages to Snowflake Cortex Analyst."""

    @abstractmethod
    def send_message(self, messages: List[Dict[str, Any]]) -> Dict[str, Any]:
        pass


class SnowflakeClient(ISnowflakeClient):
    """Concrete implementation of ISnowflakeClient using the private _snowflake wrapper."""

    def send_message(self, messages: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Sends a list of messages to the Snowflake Cortex Analyst API and returns the parsed response.

        Constructs a request body with the provided messages and the predefined semantic view,
        sends a POST request to the Cortex Analyst endpoint, and parses the JSON response.

        Args:
            messages (List[Dict[str, Any]]): A list of dictionaries representing the conversation messages.
                Each dictionary should contain 'role' (e.g., 'user' or 'analyst') and 'content' fields,
                where 'content' is a list of dictionaries with 'type' and 'text' for text content.

        Returns:
            Dict[str, Any]: The parsed JSON response from the API, containing the analyst's reply
                and any additional metadata such as request_id or message content.
        """
        request_body = {"messages": messages, "semantic_view": SEMANTIC_VIEW}
        resp = _snowflake.send_snow_api_request(
            "POST",
            "/api/v2/cortex/analyst/message",
            {},
            {},
            request_body,
            {},
            30000,
        )
        parsed = json.loads(resp["content"])
        if isinstance(parsed, str):
            parsed = json.loads(parsed)
        return parsed


class ContentRenderer:
    """Encapsulates logic for rendering various content types to the Streamlit UI."""

    def __init__(self):
        """Initializes the ContentRenderer by setting up the Snowflake Snowpark session getter."""
        from snowflake.snowpark.context import get_active_session

        self._get_session = get_active_session

    def render(self, content: List[Dict[str, Any]], msg_idx: int) -> None:
        """Renders a list of content items to the Streamlit UI based on their type.

        Iterates through the provided content list and delegates rendering to specific
        handler methods based on the 'type' key in each item (e.g., 'text', 'suggestions', 'sql').
        Falls back to a default handler for unknown types.

        Args:
            content (List[Dict[str, Any]]): A list of dictionaries representing content items.
                Each dictionary must have a 'type' key indicating the content type, along with
                type-specific data (e.g., 'text' for text content, 'suggestions' for a list of strings).
            msg_idx (int): An integer index for the message, used to generate unique keys for
                interactive UI elements like buttons to avoid conflicts in the Streamlit app.
        """
        for item in content:
            handler = getattr(self, f"_handle_{item['type']}", self._handle_unknown)
            handler(item, msg_idx)

    def _handle_text(self, item: Dict[str, Any], msg_idx: int) -> None:
        """Renders text content as markdown in the Streamlit UI.

        Displays the text from the provided item dictionary using Streamlit's markdown function.

        Args:
            item (Dict[str, Any]): A dictionary containing the text content, with a 'text' key
                holding the string to be rendered as markdown.
            msg_idx (int): An integer index for the message, included for consistency with other
                handler methods but not used in this implementation.
        """
        st.markdown(item["text"])

    def _handle_suggestions(self, item: Dict[str, Any], msg_idx: int) -> None:
        """Renders a list of suggestions as interactive buttons in an expandable section.

        Displays the suggestions from the provided item dictionary as buttons within a Streamlit expander.
        Clicking a button sets the active suggestion in the session state.

        Args:
            item (Dict[str, Any]): A dictionary containing the suggestions, with a 'suggestions' key
                holding a list of strings to be rendered as buttons.
            msg_idx (int): An integer index for the message, used to generate unique keys for the buttons
                to avoid conflicts in the Streamlit app.
        """
        with st.expander("Suggestions", expanded=True):
            for i, s in enumerate(item["suggestions"]):
                if st.button(s, key=f"sug_{msg_idx}_{i}"):
                    st.session_state.active_suggestion = s

    def _handle_sql(self, item: Dict[str, Any], msg_idx: int) -> None:
        """Renders SQL query and its results in expandable sections with visualizations.

        Displays the SQL statement in a code block and executes it to show results as a dataframe,
        line chart, and bar chart in tabs if the data has multiple columns.

        Args:
            item (Dict[str, Any]): A dictionary containing the SQL query, with a 'statement' key
                holding the SQL string to be executed and displayed.
            msg_idx (int): An integer index for the message, included for consistency with other
                handler methods but not used in this implementation.
        """
        with st.expander("SQL Query", expanded=False):
            st.code(item["statement"], language="sql")
        with st.expander("Results", expanded=True):
            with st.spinner("Running SQL..."):
                session = self._get_session()
                df = session.sql(item["statement"]).to_pandas()
                if len(df) > 1:
                    data_tab, line_tab, bar_tab = st.tabs(
                        ["Data", "Line Chart", "Bar Chart"]
                    )
                    data_tab.dataframe(df, use_container_width=True)
                    display_df = (
                        df.set_index(df.columns[0]) if len(df.columns) > 1 else df
                    )
                    with line_tab:
                        st.line_chart(display_df)
                    with bar_tab:
                        st.bar_chart(display_df)
                else:
                    st.dataframe(df, use_container_width=True)

    def _handle_unknown(self, item: Dict[str, Any], msg_idx: int) -> None:
        """Handles unknown content types by displaying a warning message.

        Shows a Streamlit warning for content items with unrecognized 'type' values,
        helping developers identify unsupported content during development.

        Args:
            item (Dict[str, Any]): A dictionary representing the unknown content item,
                with a 'type' key holding the unrecognized content type string.
            msg_idx (int): An integer index for the message, included for consistency with other
                handler methods but not used in this implementation.
        """
        st.warning(f"Unknown content type: {item.get('type')}")


class MessageProcessor:
    """Orchestrates sending user prompts, receiving responses, and updating session state."""

    def __init__(
        self,
        client: ISnowflakeClient,
        renderer: ContentRenderer,
        session_state: Any = st.session_state,
    ):
        self._client = client
        self._renderer = renderer
        self._session_state = session_state

    def add_user_message(self, prompt: str) -> None:
        """Adds a user message to the session state.

        Appends a new message dictionary with role 'user' and the provided prompt to the messages list.

        Args:
            prompt (str): The text content of the user's message to be added.
        """
        self._session_state.messages.append({"role": "user", "content": prompt})

    def add_assistant_message(self, content: Any) -> None:
        """Adds an assistant message to the session state.

        Appends a new message dictionary with role 'analyst' and the provided content to the messages list.

        Args:
            content (Any): The content of the assistant's message, which can be a string or a list of content items.
        """
        self._session_state.messages.append({"role": "analyst", "content": content})

    def process(self, prompt: str) -> None:
        """Processes a user prompt by sending it to the API and rendering the response.

        Adds the prompt as a user message, sends the conversation to the Snowflake client,
        handles the response, renders the content, and adds the assistant's reply to the session.

        Args:
            prompt (str): The user's input prompt to be processed and sent to the analyst.
        """
        self.add_user_message(prompt)
        with st.chat_message("user"):
            st.markdown(prompt)

        with st.chat_message("assistant"):
            with st.spinner("Thinking..."):
                try:
                    response = self._client.send_message(
                        [
                            {
                                "role": m["role"],
                                "content": (
                                    [{"type": "text", "text": m["content"]}]
                                    if isinstance(m["content"], str)
                                    else m["content"]
                                ),
                            }
                            for m in self._session_state.messages
                        ]
                    )
                except Exception as e:
                    st.error(f"Error: {e}")
                    self._session_state.messages.pop()
                    return

            request_id = response.get("request_id")
            message = response.get("message", response)
            if isinstance(message, str):
                message = json.loads(message)
            content = message.get("content", message)
            if isinstance(content, str):
                content = [{"type": "text", "text": content}]

            self._renderer.render(content, len(self._session_state.messages))
            self.add_assistant_message(content)


# ----- application entrypoint -------------------------------------------------


def render_history(renderer: ContentRenderer):
    """Renders the chat history by displaying each message in the session state.

    Iterates through the stored messages and displays them as chat messages,
    using the provided renderer for complex content types.

    Args:
        renderer (ContentRenderer): An instance of ContentRenderer responsible for
            rendering various content types such as text, suggestions, and SQL results
            in the chat interface.
    """
    for idx, message in enumerate(st.session_state.messages):
        role = "assistant" if message["role"] == "analyst" else "user"
        with st.chat_message(role):
            if isinstance(message["content"], str):
                st.markdown(message["content"])
            else:
                renderer.render(message["content"], idx)


class ChatApp:
    def __init__(self):
        """Initializes the ChatApp by creating instances of ContentRenderer and MessageProcessor."""
        self.renderer = ContentRenderer()
        self.processor = MessageProcessor(SnowflakeClient(), self.renderer)

    def run(self):
        """Runs the main application loop, handling user input, rendering chat history, and managing the sidebar.

        This method orchestrates the Streamlit app's execution by displaying the chat history,
        processing new user inputs and suggestions, and providing a sidebar for app information and reset functionality.
        """
        render_history(self.renderer)

        if user_input := st.chat_input("Ask about weather data..."):
            self.processor.process(user_input)

        if st.session_state.active_suggestion:
            self.processor.process(st.session_state.active_suggestion)
            st.session_state.active_suggestion = None

        with st.sidebar:
            st.markdown("### About")
            st.markdown(
                "Ask natural language questions about global weather data including temperature, precipitation, wind, air quality, and more."
            )
            if st.button("Reset conversation"):
                st.session_state.messages = []
                st.session_state.active_suggestion = None
                st.rerun()


if __name__ == "__main__":
    app = ChatApp()
    app.run()
