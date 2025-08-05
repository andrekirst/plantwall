# Copilot Instructions for Plant Wall Control Repository

## Overview

This repository contains two main components:

- **plant-wall-control**: Python backend for Raspberry Pi, managing hardware (lighting, watering, nutrients, sensors, display) and providing a Flask-based API.
- **plant-wall-control-web**: Next.js/TypeScript frontend for professional web-based control and monitoring of the plant wall.

## Architecture & Data Flow

- The Python backend (`src/plant-wall-control/`) interfaces directly with hardware via GPIO and exposes REST endpoints (see `web/routes.py`).
- The Next.js frontend (`src/plant-wall-control-web/`) communicates with the backend via HTTP (fetch/axios in `utils/api.ts`).
- Status and settings are exchanged as JSON objects (see `/status` and `/settings` routes in Flask).
- Real-time updates are polled or fetched via API endpoints.

## Key Patterns & Conventions

- **Hardware Abstraction**: Each hardware function (lighting, watering, nutrients, sensors, display) is encapsulated in its own Python module under `hardware/`.
- **Web API**: All hardware control and status endpoints are defined in `web/routes.py`. Example:
  ```python
  @routes.route('/status', methods=['GET'])
  def get_status():
      # Returns JSON with soil_moisture, external_light, water_tank_level
  ```
- **Frontend API Calls**: Use `utils/api.ts` for all HTTP requests to the backend. Types for API responses are defined in `types/index.ts`.
- **Settings Management**: Settings are updated via POST to `/settings` (see Flask and Next.js `settings.tsx`).
- **Status Display**: StatusPanel component in React displays live data from `/status` endpoint.

## Developer Workflows

- **Backend**: Run Flask app via `python src/web/app.py` (ensure dependencies from `requirements.txt` are installed).
- **Frontend**: Start Next.js app with `npm install && npm run dev` in `plant-wall-control-web`.
- **Testing**: No custom test runners detected; use standard Python/JS testing tools if needed.
- **Debugging**: Hardware modules are separated for easier mocking and testing. Web API can be tested with curl/Postman.

## Integration Points

- **GPIO Hardware**: All hardware access is abstracted in Python modules; update these for new hardware support.
- **Web API**: All frontend/backend communication is via REST endpoints; keep API contracts in sync.
- **Display**: Real-time info is shown both on a physical display (`hardware/display.py`) and in the web UI.

## Project-Specific Notes

- **Raspberry Pi**: Backend is optimized for Pi Zero 2W and up; ensure GPIO libraries are compatible.
- **Professional Web UI**: Use Next.js/TypeScript for all new web features; avoid Flask templates for user-facing UI.
- **Extensibility**: Add new hardware features by creating new modules and exposing endpoints in `routes.py`.

## Key Files

- `src/plant-wall-control/hardware/`: Hardware abstraction modules
- `src/plant-wall-control/web/routes.py`: API endpoints
- `src/plant-wall-control-web/src/utils/api.ts`: Frontend API calls
- `src/plant-wall-control-web/src/components/StatusPanel.tsx`: Status display
- `src/plant-wall-control-web/src/pages/settings.tsx`: Settings management

---

For questions or unclear patterns, review the respective README files or ask for clarification.
