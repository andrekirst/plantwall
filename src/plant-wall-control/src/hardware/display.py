class Display:
    def __init__(self, gpio_pin):
        import RPi.GPIO as GPIO
        self.gpio_pin = gpio_pin
        GPIO.setmode(GPIO.BCM)
        GPIO.setup(self.gpio_pin, GPIO.OUT)
        self.display_data = ""

    def update_display(self, data):
        self.display_data = data
        # Code to update the actual display would go here

    def clear_display(self):
        self.display_data = ""
        # Code to clear the actual display would go here