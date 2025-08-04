class Watering:
    def __init__(self, pump_pin, water_level_sensor_pin):
        self.pump_pin = pump_pin
        self.water_level_sensor_pin = water_level_sensor_pin
        self.is_watering = False

    def start_watering(self):
        if not self.is_watering:
            # Code to activate the pump
            self.is_watering = True
            print("Watering started.")

    def stop_watering(self):
        if self.is_watering:
            # Code to deactivate the pump
            self.is_watering = False
            print("Watering stopped.")

    def check_water_level(self):
        # Code to read from the water level sensor
        water_level = 0  # Replace with actual sensor reading
        print(f"Current water level: {water_level}")
        return water_level