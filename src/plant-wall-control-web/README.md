# Plant Wall Control Web Application

This project is a web application built with Next.js and TypeScript for controlling a plant wall system. It provides an interface for monitoring and adjusting various settings related to the plant wall.

## Features

- **Homepage**: Displays the current status of the plant wall system.
- **Settings Page**: Allows users to adjust settings such as lighting and watering.
- **Real-time Status Updates**: Monitors soil moisture, external light, and water tank levels.

## Project Structure

```
plant-wall-control-web
├── src
│   ├── pages
│   │   ├── index.tsx
│   │   └── settings.tsx
│   ├── components
│   │   ├── StatusPanel.tsx
│   │   └── LightingControl.tsx
│   ├── types
│   │   └── index.ts
│   └── utils
│       └── api.ts
├── public
│   └── favicon.ico
├── package.json
├── tsconfig.json
├── next.config.js
└── README.md
```

## Getting Started

To get started with the project, follow these steps:

1. **Clone the repository**:
   ```
   git clone <repository-url>
   cd plant-wall-control-web
   ```

2. **Install dependencies**:
   ```
   npm install
   ```

3. **Run the development server**:
   ```
   npm run dev
   ```

4. **Open your browser** and navigate to `http://localhost:3000` to view the application.

## Usage

- Use the homepage to view the current status of the plant wall.
- Navigate to the settings page to adjust the lighting and watering settings.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.