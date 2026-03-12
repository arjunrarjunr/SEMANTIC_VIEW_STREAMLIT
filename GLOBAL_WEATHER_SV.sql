CREATE OR REPLACE SEMANTIC VIEW DEMONSTRATION.WEATHER.GLOBAL_WEATHER_SV

  TABLES (
    weather AS DEMONSTRATION.WEATHER.GLOBAL_WEATHER_REPOSITORY
  )

  FACTS (
    weather.temperature_celsius AS TEMPERATURE_CELSIUS
      COMMENT = 'Temperature in degrees Celsius',
    weather.temperature_fahrenheit AS TEMPERATURE_FAHRENHEIT
      COMMENT = 'Temperature in degrees Fahrenheit',
    weather.wind_mph AS WIND_MPH
      COMMENT = 'Wind speed in miles per hour',
    weather.wind_kph AS WIND_KPH
      COMMENT = 'Wind speed in kilometers per hour',
    weather.wind_degree AS WIND_DEGREE
      COMMENT = 'Wind direction in degrees',
    weather.pressure_mb AS PRESSURE_MB
      COMMENT = 'Atmospheric pressure in millibars',
    weather.pressure_in AS PRESSURE_IN
      COMMENT = 'Atmospheric pressure in inches',
    weather.precip_mm AS PRECIP_MM
      COMMENT = 'Precipitation amount in millimeters',
    weather.precip_in AS PRECIP_IN
      COMMENT = 'Precipitation amount in inches',
    weather.humidity AS HUMIDITY
      COMMENT = 'Humidity as a percentage',
    weather.cloud AS CLOUD
      COMMENT = 'Cloud cover as a percentage',
    weather.feels_like_celsius AS FEELS_LIKE_CELSIUS
      COMMENT = 'Feels-like temperature in Celsius',
    weather.feels_like_fahrenheit AS FEELS_LIKE_FAHRENHEIT
      COMMENT = 'Feels-like temperature in Fahrenheit',
    weather.visibility_km AS VISIBILITY_KM
      COMMENT = 'Visibility in kilometers',
    weather.visibility_miles AS VISIBILITY_MILES
      COMMENT = 'Visibility in miles',
    weather.uv_index AS UV_INDEX
      COMMENT = 'UV Index',
    weather.gust_mph AS GUST_MPH
      COMMENT = 'Wind gust in miles per hour',
    weather.gust_kph AS GUST_KPH
      COMMENT = 'Wind gust in kilometers per hour',
    weather.air_quality_carbon_monoxide AS AIR_QUALITY_CARBON_MONOXIDE
      COMMENT = 'Carbon monoxide level',
    weather.air_quality_ozone AS AIR_QUALITY_OZONE
      COMMENT = 'Ozone level',
    weather.air_quality_nitrogen_dioxide AS AIR_QUALITY_NITROGEN_DIOXIDE
      COMMENT = 'Nitrogen dioxide level',
    weather.air_quality_sulphur_dioxide AS AIR_QUALITY_SULPHUR_DIOXIDE
      COMMENT = 'Sulphur dioxide level',
    weather.air_quality_pm2_5 AS AIR_QUALITY_PM2_5
      COMMENT = 'PM2.5 particulate matter level',
    weather.air_quality_pm10 AS AIR_QUALITY_PM10
      COMMENT = 'PM10 particulate matter level',
    weather.air_quality_us_epa_index AS AIR_QUALITY_US_EPA_INDEX
      COMMENT = 'US EPA air quality index',
    weather.air_quality_gb_defra_index AS AIR_QUALITY_GB_DEFRA_INDEX
      COMMENT = 'GB DEFRA air quality index',
    weather.moon_illumination AS MOON_ILLUMINATION
      COMMENT = 'Moon illumination percentage'
  )

  DIMENSIONS (
    weather.country AS COUNTRY
      WITH SYNONYMS = ('nation', 'region')
      COMMENT = 'Country of the weather observation',
    weather.location_name AS LOCATION_NAME
      WITH SYNONYMS = ('city', 'place', 'station')
      COMMENT = 'Name of the location or city',
    weather.latitude AS LATITUDE
      COMMENT = 'Latitude coordinate of the location',
    weather.longitude AS LONGITUDE
      COMMENT = 'Longitude coordinate of the location',
    weather.timezone AS TIMEZONE
      COMMENT = 'Timezone of the location',
    weather.last_updated AS LAST_UPDATED
      COMMENT = 'Local time of the last data update',
    weather.condition_text AS CONDITION_TEXT
      WITH SYNONYMS = ('weather condition', 'weather type', 'sky condition')
      COMMENT = 'Weather condition description (e.g. Sunny, Rainy, Cloudy)',
    weather.wind_direction AS WIND_DIRECTION
      COMMENT = 'Wind direction as a 16-point compass (e.g. N, NE, SW)',
    weather.moon_phase AS MOON_PHASE
      COMMENT = 'Current moon phase'
  )

  

    METRICS (
    weather.avg_temperature_celsius AS AVG(TEMPERATURE_CELSIUS)
      WITH SYNONYMS = ('average temperature', 'mean temperature')
      COMMENT = 'Average temperature in Celsius',
    weather.min_temperature_celsius AS MIN(TEMPERATURE_CELSIUS)
      WITH SYNONYMS = ('lowest temperature', 'coldest temperature')
      COMMENT = 'Minimum temperature in Celsius',
    weather.max_temperature_celsius AS MAX(TEMPERATURE_CELSIUS)
      WITH SYNONYMS = ('highest temperature', 'peak temperature')
      COMMENT = 'Maximum temperature in Celsius',

    weather.avg_temperature_fahrenheit AS AVG(TEMPERATURE_FAHRENHEIT)
      COMMENT = 'Average temperature in Fahrenheit',
    weather.min_temperature_fahrenheit AS MIN(TEMPERATURE_FAHRENHEIT)
      COMMENT = 'Minimum temperature in Fahrenheit',
    weather.max_temperature_fahrenheit AS MAX(TEMPERATURE_FAHRENHEIT)
      COMMENT = 'Maximum temperature in Fahrenheit',

    weather.avg_wind_mph AS AVG(WIND_MPH)
      COMMENT = 'Average wind speed in mph',
    weather.min_wind_mph AS MIN(WIND_MPH)
      COMMENT = 'Minimum wind speed in mph',
    weather.max_wind_mph AS MAX(WIND_MPH)
      COMMENT = 'Maximum wind speed in mph',

    weather.avg_wind_speed_kph AS AVG(WIND_KPH)
      WITH SYNONYMS = ('average wind speed')
      COMMENT = 'Average wind speed in kph',
    weather.min_wind_speed_kph AS MIN(WIND_KPH)
      COMMENT = 'Minimum wind speed in kph',
    weather.max_wind_speed_kph AS MAX(WIND_KPH)
      COMMENT = 'Maximum wind speed in kph',

    weather.avg_wind_degree AS AVG(WIND_DEGREE)
      COMMENT = 'Average wind direction in degrees',
    weather.min_wind_degree AS MIN(WIND_DEGREE)
      COMMENT = 'Minimum wind direction in degrees',
    weather.max_wind_degree AS MAX(WIND_DEGREE)
      COMMENT = 'Maximum wind direction in degrees',

    weather.avg_pressure_mb AS AVG(PRESSURE_MB)
      COMMENT = 'Average atmospheric pressure in millibars',
    weather.min_pressure_mb AS MIN(PRESSURE_MB)
      COMMENT = 'Minimum atmospheric pressure in millibars',
    weather.max_pressure_mb AS MAX(PRESSURE_MB)
      COMMENT = 'Maximum atmospheric pressure in millibars',

    weather.avg_pressure_in AS AVG(PRESSURE_IN)
      COMMENT = 'Average atmospheric pressure in inches',
    weather.min_pressure_in AS MIN(PRESSURE_IN)
      COMMENT = 'Minimum atmospheric pressure in inches',
    weather.max_pressure_in AS MAX(PRESSURE_IN)
      COMMENT = 'Maximum atmospheric pressure in inches',

    weather.avg_precip_mm AS AVG(PRECIP_MM)
      COMMENT = 'Average precipitation in millimeters',
    weather.min_precip_mm AS MIN(PRECIP_MM)
      COMMENT = 'Minimum precipitation in millimeters',
    weather.max_precip_mm AS MAX(PRECIP_MM)
      COMMENT = 'Maximum precipitation in millimeters',
    weather.total_precip_mm AS SUM(PRECIP_MM)
      WITH SYNONYMS = ('total precipitation', 'total rainfall')
      COMMENT = 'Total precipitation in millimeters',

    weather.avg_precip_in AS AVG(PRECIP_IN)
      COMMENT = 'Average precipitation in inches',
    weather.min_precip_in AS MIN(PRECIP_IN)
      COMMENT = 'Minimum precipitation in inches',
    weather.max_precip_in AS MAX(PRECIP_IN)
      COMMENT = 'Maximum precipitation in inches',

    weather.avg_humidity AS AVG(HUMIDITY)
      WITH SYNONYMS = ('average humidity', 'mean humidity')
      COMMENT = 'Average humidity percentage',
    weather.min_humidity AS MIN(HUMIDITY)
      COMMENT = 'Minimum humidity percentage',
    weather.max_humidity AS MAX(HUMIDITY)
      COMMENT = 'Maximum humidity percentage',

    weather.avg_cloud_cover AS AVG(CLOUD)
      WITH SYNONYMS = ('average cloud cover', 'mean cloudiness')
      COMMENT = 'Average cloud cover percentage',
    weather.min_cloud_cover AS MIN(CLOUD)
      COMMENT = 'Minimum cloud cover percentage',
    weather.max_cloud_cover AS MAX(CLOUD)
      COMMENT = 'Maximum cloud cover percentage',

    weather.avg_feels_like_celsius AS AVG(FEELS_LIKE_CELSIUS)
      COMMENT = 'Average feels-like temperature in Celsius',
    weather.min_feels_like_celsius AS MIN(FEELS_LIKE_CELSIUS)
      COMMENT = 'Minimum feels-like temperature in Celsius',
    weather.max_feels_like_celsius AS MAX(FEELS_LIKE_CELSIUS)
      COMMENT = 'Maximum feels-like temperature in Celsius',

    weather.avg_feels_like_fahrenheit AS AVG(FEELS_LIKE_FAHRENHEIT)
      COMMENT = 'Average feels-like temperature in Fahrenheit',
    weather.min_feels_like_fahrenheit AS MIN(FEELS_LIKE_FAHRENHEIT)
      COMMENT = 'Minimum feels-like temperature in Fahrenheit',
    weather.max_feels_like_fahrenheit AS MAX(FEELS_LIKE_FAHRENHEIT)
      COMMENT = 'Maximum feels-like temperature in Fahrenheit',

    weather.avg_visibility_km AS AVG(VISIBILITY_KM)
      COMMENT = 'Average visibility in kilometers',
    weather.min_visibility_km AS MIN(VISIBILITY_KM)
      COMMENT = 'Minimum visibility in kilometers',
    weather.max_visibility_km AS MAX(VISIBILITY_KM)
      COMMENT = 'Maximum visibility in kilometers',

    weather.avg_visibility_miles AS AVG(VISIBILITY_MILES)
      COMMENT = 'Average visibility in miles',
    weather.min_visibility_miles AS MIN(VISIBILITY_MILES)
      COMMENT = 'Minimum visibility in miles',
    weather.max_visibility_miles AS MAX(VISIBILITY_MILES)
      COMMENT = 'Maximum visibility in miles',

    weather.avg_uv_index AS AVG(UV_INDEX)
      COMMENT = 'Average UV index',
    weather.min_uv_index AS MIN(UV_INDEX)
      COMMENT = 'Minimum UV index',
    weather.max_uv_index AS MAX(UV_INDEX)
      COMMENT = 'Maximum UV index',

    weather.avg_gust_mph AS AVG(GUST_MPH)
      COMMENT = 'Average wind gust in mph',
    weather.min_gust_mph AS MIN(GUST_MPH)
      COMMENT = 'Minimum wind gust in mph',
    weather.max_gust_mph AS MAX(GUST_MPH)
      COMMENT = 'Maximum wind gust in mph',

    weather.avg_gust_kph AS AVG(GUST_KPH)
      COMMENT = 'Average wind gust in kph',
    weather.min_gust_kph AS MIN(GUST_KPH)
      COMMENT = 'Minimum wind gust in kph',
    weather.max_gust_kph AS MAX(GUST_KPH)
      COMMENT = 'Maximum wind gust in kph',

    weather.avg_air_quality_carbon_monoxide AS AVG(AIR_QUALITY_CARBON_MONOXIDE)
      COMMENT = 'Average carbon monoxide level',
    weather.min_air_quality_carbon_monoxide AS MIN(AIR_QUALITY_CARBON_MONOXIDE)
      COMMENT = 'Minimum carbon monoxide level',
    weather.max_air_quality_carbon_monoxide AS MAX(AIR_QUALITY_CARBON_MONOXIDE)
      COMMENT = 'Maximum carbon monoxide level',

    weather.avg_air_quality_ozone AS AVG(AIR_QUALITY_OZONE)
      COMMENT = 'Average ozone level',
    weather.min_air_quality_ozone AS MIN(AIR_QUALITY_OZONE)
      COMMENT = 'Minimum ozone level',
    weather.max_air_quality_ozone AS MAX(AIR_QUALITY_OZONE)
      COMMENT = 'Maximum ozone level',

    weather.avg_air_quality_nitrogen_dioxide AS AVG(AIR_QUALITY_NITROGEN_DIOXIDE)
      COMMENT = 'Average nitrogen dioxide level',
    weather.min_air_quality_nitrogen_dioxide AS MIN(AIR_QUALITY_NITROGEN_DIOXIDE)
      COMMENT = 'Minimum nitrogen dioxide level',
    weather.max_air_quality_nitrogen_dioxide AS MAX(AIR_QUALITY_NITROGEN_DIOXIDE)
      COMMENT = 'Maximum nitrogen dioxide level',

    weather.avg_air_quality_sulphur_dioxide AS AVG(AIR_QUALITY_SULPHUR_DIOXIDE)
      COMMENT = 'Average sulphur dioxide level',
    weather.min_air_quality_sulphur_dioxide AS MIN(AIR_QUALITY_SULPHUR_DIOXIDE)
      COMMENT = 'Minimum sulphur dioxide level',
    weather.max_air_quality_sulphur_dioxide AS MAX(AIR_QUALITY_SULPHUR_DIOXIDE)
      COMMENT = 'Maximum sulphur dioxide level',

    weather.avg_air_quality_pm2_5 AS AVG(AIR_QUALITY_PM2_5)
      COMMENT = 'Average PM2.5 air quality level',
    weather.min_air_quality_pm2_5 AS MIN(AIR_QUALITY_PM2_5)
      COMMENT = 'Minimum PM2.5 air quality level',
    weather.max_air_quality_pm2_5 AS MAX(AIR_QUALITY_PM2_5)
      COMMENT = 'Maximum PM2.5 air quality level',

    weather.avg_air_quality_pm10 AS AVG(AIR_QUALITY_PM10)
      COMMENT = 'Average PM10 air quality level',
    weather.min_air_quality_pm10 AS MIN(AIR_QUALITY_PM10)
      COMMENT = 'Minimum PM10 air quality level',
    weather.max_air_quality_pm10 AS MAX(AIR_QUALITY_PM10)
      COMMENT = 'Maximum PM10 air quality level',

    weather.avg_air_quality_us_epa AS AVG(AIR_QUALITY_US_EPA_INDEX)
      COMMENT = 'Average US EPA air quality index',
    weather.min_air_quality_us_epa AS MIN(AIR_QUALITY_US_EPA_INDEX)
      COMMENT = 'Minimum US EPA air quality index',
    weather.max_air_quality_us_epa AS MAX(AIR_QUALITY_US_EPA_INDEX)
      COMMENT = 'Maximum US EPA air quality index',

    weather.avg_air_quality_gb_defra AS AVG(AIR_QUALITY_GB_DEFRA_INDEX)
      COMMENT = 'Average GB DEFRA air quality index',
    weather.min_air_quality_gb_defra AS MIN(AIR_QUALITY_GB_DEFRA_INDEX)
      COMMENT = 'Minimum GB DEFRA air quality index',
    weather.max_air_quality_gb_defra AS MAX(AIR_QUALITY_GB_DEFRA_INDEX)
      COMMENT = 'Maximum GB DEFRA air quality index',

    weather.avg_moon_illumination AS AVG(MOON_ILLUMINATION)
      COMMENT = 'Average moon illumination percentage',
    weather.min_moon_illumination AS MIN(MOON_ILLUMINATION)
      COMMENT = 'Minimum moon illumination percentage',
    weather.max_moon_illumination AS MAX(MOON_ILLUMINATION)
      COMMENT = 'Maximum moon illumination percentage',

    weather.observation_count AS COUNT(*)
      WITH SYNONYMS = ('number of observations', 'record count')
      COMMENT = 'Total number of weather observations',

    weather.country_count AS COUNT(DISTINCT COUNTRY)
      WITH SYNONYMS = ('number of countries', 'country count')
      COMMENT = 'Count of distinct countries',
    weather.city_count AS COUNT(DISTINCT LOCATION_NAME)
      WITH SYNONYMS = ('number of cities', 'city count')
      COMMENT = 'Count of distinct cities or locations',
    weather.earliest_update AS MIN(LAST_UPDATED)
      WITH SYNONYMS = ('earliest observation', 'first update')
      COMMENT = 'Earliest last-updated timestamp',
    weather.latest_update AS MAX(LAST_UPDATED)
      WITH SYNONYMS = ('latest observation', 'most recent update')
      COMMENT = 'Latest last-updated timestamp'
  )

  COMMENT = 'Semantic view for global weather data analysis covering temperature, precipitation, wind, air quality, and astronomical observations'