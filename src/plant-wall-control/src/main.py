import time
from hardware.lighting import Lighting
from hardware.watering import Watering
from hardware.nutrients import Nutrients
from hardware.sensors import Sensors
from hardware.display import Display
from web.app import start_web_app

def main():
    # Initialize hardware components
    lighting = Lighting()
    watering = Watering()
    nutrients = Nutrients()
    sensors = Sensors()
    display = Display()

    # Start the web application
    start_web_app()

    try:
        while True:
            # Read sensor data
            soil_moisture = sensors.read_soil_moisture()
            external_light = sensors.read_external_light()
            water_tank_level = sensors.read_water_tank_level()

            # Update display with sensor data
            display.update_display({
                'soil_moisture': soil_moisture,
                'external_light': external_light,
                'water_tank_level': water_tank_level
            })

            # Control lighting based on external light
            if external_light < 100:  # Example threshold
                lighting.turn_on()
            else:
                lighting.turn_off()

            # Watering logic based on soil moisture
            if soil_moisture < 30:  # Example threshold
                watering.start_watering()
            else:
                watering.stop_watering()

            # Nutrient management logic can be added here

            time.sleep(60)  # Delay for a minute before the next loop

    except KeyboardInterrupt:
        # Clean up on exit
        lighting.turn_off()
        watering.stop_watering()
        display.clear_display()
        print("Exiting plant wall control system.")

if __name__ == "__main__":
    main()