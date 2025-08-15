# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Plant wall control system with dual architecture:

- **Backend** (`src/plant-wall-control/`): Go-based REST API for Raspberry Pi hardware control
- **Frontend** (`src/plant-wall-control-web/`): Next.js/TypeScript web application

## Backend Technology Choice

**Go is used for the backend** for the following reasons:
- Better resource efficiency for Raspberry Pi Zero 2W
- Smaller binary size and lower memory footprint compared to Python
- Excellent GPIO library support for hardware control
- Fast compilation and cross-compilation capabilities

## Common Development Commands

### Frontend (Next.js)

```bash
cd src/plant-wall-control-web
npm install                 # Install dependencies
npm run dev                 # Start development server (port 3000)
npm run build              # Build for production
npm run start              # Start production server
npm run lint               # Run ESLint
```

### Backend (Go)

```bash
cd src/plant-wall-control
go mod init plant-wall-control     # Initialize Go module (first time)
go mod tidy                        # Update dependencies
go run main.go                     # Start development server
go build -o plant-wall-control     # Build binary
./plant-wall-control               # Run compiled binary
```

### Docker Deployment

```bash
docker-compose up          # Start both services (backend:12600, frontend:12500)
docker-compose up --build  # Rebuild and start services
```

## Architecture & Key Integration Points

### Hardware Abstraction Layer

- Each hardware function isolated in `src/plant-wall-control/hardware/` packages
- Modules: `lighting.go`, `watering.go`, `nutrients.go`, `sensors.go`, `display.go`
- All GPIO interactions abstracted for easier testing/mocking

### API Communication

- Backend exposes REST endpoints via Go HTTP server
- Frontend API calls centralized in `src/plant-wall-control-web/src/utils/api.ts`
- Key endpoints: `/status` (GET), `/settings` (POST)
- Data exchange uses JSON with types defined in `src/plant-wall-control-web/src/types/index.ts`

### Component Structure

- **StatusPanel**: Real-time system monitoring (`src/plant-wall-control-web/src/components/StatusPanel.tsx`)
- **LightingControl**: Hardware control interface (`src/plant-wall-control-web/src/components/LightingControl.tsx`)
- **Pages**: `index.tsx` (status view), `settings.tsx` (configuration)

## Development Patterns

### Adding New Hardware Features

1. Create new Go package in `src/plant-wall-control/hardware/`
2. Add corresponding HTTP handler and route in main Go server
3. Update frontend API calls in `utils/api.ts`
4. Add TypeScript types in `types/index.ts`
5. Create/update React components as needed

### Backend Configuration

- Configuration managed via Go structs and config files
- HTTP server setup in `main.go`
- Hardware initialization and management in respective packages

### Frontend State Management

- API communication via axios (configured in `utils/api.ts`)
- Component-level state management (no global state library currently used)
- Real-time updates via polling of `/status` endpoint

## Port Configuration

- Frontend development: `localhost:3000`
- Backend API: `localhost:5000`
- Docker frontend: `localhost:12500`
- Docker backend: `localhost:12600`

## Hardware Target

- Optimized for Raspberry Pi Zero 2W and higher
- GPIO libraries and hardware modules designed for Pi compatibility
- Cross-compilation from development machine to ARM architecture supported
