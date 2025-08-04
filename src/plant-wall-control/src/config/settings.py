# Configuration settings for the plant wall control application

# GPIO pin assignments
GPIO_PINS = {
    'light': 18,
    'water_pump': 23,
    'nutrient_pump': 24,
    'moisture_sensor': 17,
    'light_sensor': 27,
    'water_level_sensor': 22,
    'display': 25
}

# Sensor thresholds
SENSOR_THRESHOLDS = {
    'moisture_low': 300,
    'moisture_high': 700,
    'light_threshold': 500,
    'water_level_low': 10  # in percentage
}

# Timing settings
TIMING_SETTINGS = {
    'day_duration': 12,  # hours
    'night_duration': 12  # hours
}

# Nutrient settings
NUTRIENT_SETTINGS = {
    'default_nutrient_amount': 50  # in ml
}

# Watering settings
WATERING_SETTINGS = {
    'watering_duration': 5,  # in seconds
    'watering_interval': 3600  # in seconds
}