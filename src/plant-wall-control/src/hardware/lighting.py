class Lighting:
    def __init__(self, pin):
        self.pin = pin
        self.brightness = 0
        self.setup()

    def setup(self):
        # Initialize the GPIO pin for the lighting
        import RPi.GPIO as GPIO
        GPIO.setmode(GPIO.BCM)
        GPIO.setup(self.pin, GPIO.OUT)

    def turn_on(self):
        # Turn on the light
        import RPi.GPIO as GPIO
        GPIO.output(self.pin, GPIO.HIGH)

    def turn_off(self):
        # Turn off the light
        import RPi.GPIO as GPIO
        GPIO.output(self.pin, GPIO.LOW)

    def set_brightness(self, level):
        # Set the brightness of the light (0-100)
        import RPi.GPIO as GPIO
        from time import sleep

        if 0 <= level <= 100:
            self.brightness = level
            pwm = GPIO.PWM(self.pin, 100)  # 100 Hz
            pwm.start(self.brightness)
        else:
            raise ValueError("Brightness level must be between 0 and 100")