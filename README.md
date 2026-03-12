# SEMANTIC_VIEW_STREAMLIT
# Weather Chatbot with Snowflake Cortex

This Streamlit application creates a chatbot that uses Snowflake's Cortex models to answer questions about global weather data stored in the `DEMONSTRATION.WEATHER.GLOBAL_WEATHER_REPOSITORY` table using its semantic view `DEMONSTRATION.WEATHER.GLOBAL_WEATHER_SV`.

# Architecture & Design Patterns

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Streamlit UI Layer                       │
│              (render_history, ChatApp.run)                  │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                  ChatApp Controller                         │
│  ┌───────────────────────────────────────────────────────── ┤
│  │ • Initializes components                                 │
│  │ • Manages UI loop                                        │
│  │ • Routes user input                                      │
└──┼───────────────────────────────────────────────────────── ┘
   │
   ├──────────────────────┬──────────────────────┐
   │                      │                      │
   ▼                      ▼                      ▼
┌─────────────┐   ┌──────────────────┐   ┌─────────────────┐
│  Message    │   │  Content         │   │  API Client     │
│  Processor  │   │  Renderer        │   │  Interface      │
│             │   │                  │   │                 │
│ • process() │   │ • render()       │   │ ┌─────────────┐ │
│ • add_msg() │   │ • _handle_text() │   │ │ Snowflake   │ │
│             │   │ • _handle_sql()  │   │ │ Client      │ │
└─────┬───────┘   │ • _handle_*()    │   │ │             │ │
      │           └──────────────────┘   │ │ • send_msg()│ │
      │                                  │ └─────────────┘ │
      │                                  └─────────────────┘
      │                                        │
      └─────────────────┬──────────────────────┘
                        │
          ┌─────────────▼─────────────┐
          │   Session State Storage   │
          │  • messages[]             │
          │  • active_suggestion      │
          └───────────────────────────┘
```

## Class Diagram - SOLID Principles

### Dependency Inversion Pattern

```
┌──────────────────────┐
│ ISnowflakeClient     │ (Abstract Interface)
│ (Abstraction Layer)  │
└──────────┬───────────┘
           △
           │ implements
           │
    ┌──────┴─────┐
    │            │
┌───┴────┐   ┌───┴────────────────┐
│ Snow-  │   │ MockSnowflake      │
│ flake  │   │ Client (for tests) │
│ Client │   │                    │
└────────┘   └────────────────────┘
```

### Handler Pattern

```
ContentRenderer
├── render(content, msg_idx)     [Main dispatch method]
│
├── _handle_text()               [Text content]
├── _handle_suggestions()        [Suggestion buttons]
├── _handle_sql()                [SQL queries + charts]
├── _handle_unknown()            [Fallback handler]
└── [Extensible for new types]   [Add _handle_custom()]
```

## Data Flow

### Chat Message Processing

```
1. User Input
   └─> st.chat_input() captures text
       │
2. Message Processing
   └─> MessageProcessor.process()
       ├─> add_user_message()     [Store in state]
       ├─> Display user message UI
       │
3. API Call
   └─> client.send_message()
       ├─> SnowflakeClient encapsulates request
       ├─> Parses JSON response
       │
4. Response Rendering
   └─> renderer.render()
       ├─> Inspects content type
       ├─> Routes to appropriate handler
       ├─> Renders UI elements
       │
5. Store Response
   └─> add_assistant_message()    [Persist in state]
```

## Design Patterns Used

### 1. **Dependency Injection**
- `MessageProcessor` receives `ISnowflakeClient` and `ContentRenderer`
- Enables testing with mock objects
- Loose coupling between components

```python
processor = MessageProcessor(SnowflakeClient(), renderer)
```

### 2. **Strategy Pattern**
- Content handlers (`_handle_text`, `_handle_sql`, etc.)
- Dynamically select rendering strategy based on type
- Easy to add new strategies

```python
handler = getattr(self, f"_handle_{item['type']}", self._handle_unknown)
handler(item, msg_idx)
```

### 3. **Template Method Pattern**
- `render()` provides overall structure
- Subclasses (handlers) implement specific behavior
- Consistent interface for all handlers

### 4. **Facade Pattern**
- `ChatApp` simplifies complex component interactions
- Single entry point for application logic
- Hides internal complexity

### 5. **Observer Pattern** (Implicit)
- Streamlit session state acts as observable
- UI components react to state changes
- Automatic re-renders on updates

## SOLID Principles Breakdown

### Single Responsibility Principle (SRP)
```
✓ SnowflakeClient: Only API communication
✓ ContentRenderer: Only UI rendering
✓ MessageProcessor: Only chat orchestration
✓ ChatApp: Only application control
```

### Open/Closed Principle (OCP)
```
✓ Open for extension: Add _handle_newtype() methods
✓ Closed for modification: No changes to base render()
✓ Interface-based: Use ISnowflakeClient for alternatives
```

### Liskov Substitution Principle (LSP)
```
✓ Any ISnowflakeClient implementation works identically
✓ Mock, Real, or Alternative clients are interchangeable
✓ Contract is maintained across implementations
```

### Interface Segregation Principle (ISP)
```
✓ ISnowflakeClient only defines necessary methods
✓ ContentRenderer doesn't expose internal handlers
✓ MessageProcessor only exposes process(), add_* methods
```

### Dependency Inversion Principle (DIP)
```
✓ Depend on ISnowflakeClient (abstraction)
✓ Not on SnowflakeClient (concrete implementation)
✓ High-level modules (MessageProcessor) depend on abstractions
✓ Low-level modules (SnowflakeClient) implement abstractions
```

## Extension Points

### Adding New Content Type Handler

```python
# In ContentRenderer class
def _handle_custom_type(self, item: Dict[str, Any], msg_idx: int) -> None:
    """Handle custom content type.
    
    Args:
        item: Content item with custom fields
        msg_idx: Message index for unique keys
    """
    # Your implementation
    st.custom_widget(item['data'])
```

### Replacing API Client

```python
class CustomClient(ISnowflakeClient):
    def send_message(self, messages: List[Dict[str, Any]]) -> Dict[str, Any]:
        # Alternative implementation
        return custom_api_call(messages)

# Use in ChatApp
processor = MessageProcessor(CustomClient(), renderer)
```

## Testing Strategy

### Unit Testing
```python
# Mock the API client
mock_client = Mock(spec=ISnowflakeClient)
mock_client.send_message.return_value = {"message": {"content": [...]}}

processor = MessageProcessor(mock_client, renderer)
processor.process("test prompt")
```

### Integration Testing
```python
# Test components together
processor = MessageProcessor(SnowflakeClient(), ContentRenderer())
# Run through complete flow
```

## Performance Considerations

1. **Session State**: Messages stored in memory
   - Optimize for moderate conversation lengths
   - Consider pagination for long histories

2. **API Calls**: Synchronous blocking calls
   - Consider async implementation for scaling
   - Implement caching for repeated queries

3. **Data Rendering**: Renders all content sequentially
   - Optimize for typical data sizes
   - Consider lazy loading for large result sets

## Security Notes

- ✓ Credentials managed via environment variables
- ⚠️ SQL queries executed directly (if using Snowpark)
- ⚠️ User input passed to API without sanitization
- Recommendations:
  - Validate user input length
  - Rate limit API calls
  - Use least-privilege Snowflake roles
  - Enable query logging for auditing

## Component Responsibilities

| Component | Responsibility | Key Methods |
|-----------|-----------------|------------|
| **ChatApp** | Application lifecycle & UI orchestration | `run()`, `__init__()` |
| **MessageProcessor** | Chat logic & session management | `process()`, `add_user_message()`, `add_assistant_message()` |
| **ContentRenderer** | UI rendering for all content types | `render()`, `_handle_*()` |
| **ISnowflakeClient** | API abstraction | `send_message()` |
| **SnowflakeClient** | Snowflake API implementation | `send_message()` |

## Module Dependencies

```
User Input
    ↓
ChatApp.run()
    ↓
├── render_history()  → ContentRenderer.render()
    ↓
└── MessageProcessor.process()
    ├── ISnowflakeClient.send_message()
    └── ContentRenderer.render()
        └── Session State (st.session_state)
```

---
