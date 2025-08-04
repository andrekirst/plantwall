from flask import Blueprint, render_template, request, jsonify
from hardware.lighting import Lighting
from hardware.watering import Watering
from hardware.nutrients import Nutrients
from hardware.sensors import Sensors

routes = Blueprint('routes', __name__)

lighting = Lighting()
watering = Watering()
nutrients = Nutrients()
sensors = Sensors()

@routes.route('/')
def index():
    return render_template('index.html')

@routes.route('/settings', methods=['POST'])
def update_settings():
    data = request.json
    # Update settings based on the received data
    # Example: lighting.set_brightness(data['brightness'])
    return jsonify({"status": "success"})

@routes.route('/status', methods=['GET'])
def get_status():
    soil_moisture = sensors.read_soil_moisture()
    external_light = sensors.read_external_light()
    water_tank_level = sensors.read_water_tank_level()
    return jsonify({
        "soil_moisture": soil_moisture,
        "external_light": external_light,
        "water_tank_level": water_tank_level
    })