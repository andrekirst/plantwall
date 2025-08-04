def log_message(message):
    with open("plant_wall_control.log", "a") as log_file:
        log_file.write(f"{message}\n")

def format_data(data):
    return f"{data:.2f}"

def read_config(file_path):
    import json
    with open(file_path, "r") as config_file:
        return json.load(config_file)