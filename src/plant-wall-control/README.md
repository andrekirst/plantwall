# Plant Wall Control

This project is designed to manage a plant wall using a Raspberry Pi Zero 2W or higher. It automates the control of lighting, watering, nutrient delivery, and monitoring of environmental conditions to create an optimal growth environment for plants.

## Features

- **Lighting Control**: Simulates day and night cycles with adjustable brightness levels.
- **Automated Watering**: Manages watering schedules and checks water levels.
- **Nutrient Management**: Delivers nutrients to plants and monitors nutrient levels.
- **Environmental Monitoring**: Measures soil moisture, external light, and water tank levels.
- **User Interface**: Provides a small GPIO-connected display for real-time information and a web application for settings management.

## Project Structure

```
plant-wall-control
├── src
│   ├── main.py               # Entry point of the application
│   ├── hardware
│   │   ├── lighting.py       # Controls lighting
│   │   ├── watering.py       # Manages watering system
│   │   ├── nutrients.py      # Handles nutrient delivery
│   │   ├── sensors.py        # Interfaces with sensors
│   │   └── display.py        # Manages the display
│   ├── web
│   │   ├── app.py            # Initializes the web application
│   │   ├── routes.py         # Defines web application routes
│   │   └── templates
│   │       └── index.html    # Main HTML template
│   ├── config
│   │   └── settings.py       # Configuration settings
│   └── utils
│       └── helpers.py        # Utility functions
├── requirements.txt           # Project dependencies
├── README.md                  # Project documentation
└── .gitignore                 # Files to ignore in version control
```

## Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/plant-wall-control.git
   cd plant-wall-control
   ```

2. Install the required dependencies:
   ```
   pip install -r requirements.txt
   ```

3. Configure the settings in `src/config/settings.py` according to your hardware setup.

## Usage

To start the application, run the following command:
```
python src/main.py
```

Access the web application by navigating to `http://<your_pi_ip>:<port>` in your web browser.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.