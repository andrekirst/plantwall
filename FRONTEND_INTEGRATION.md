# Frontend Integration with Go Backend

This document describes the updated Next.js frontend integration with the new Go backend API.

## Overview

The Next.js frontend has been updated to communicate with the Go backend running on port 5000. The integration includes:

- **Real-time system monitoring** with automatic refresh
- **Lighting control** with brightness and scheduling
- **Watering control** with manual and automatic modes
- **Comprehensive error handling** and loading states
- **CORS support** between frontend (port 3000) and backend (port 5000)

## Updated Files

### API Client (`src/utils/api.ts`)
- Updated base URL configuration for development/production
- Added all new API endpoints
- Enhanced error handling and response interceptors
- Backward compatibility for existing code

### TypeScript Types (`src/types/index.ts`)
- Complete type definitions matching Go backend structures
- Lighting, watering, and sensor data interfaces
- Error handling and API response types

### Components

#### StatusPanel (`src/components/StatusPanel.tsx`)
- Real-time data fetching with configurable refresh intervals
- Color-coded status indicators for optimal plant conditions
- System health monitoring
- Proper loading states and error handling

#### LightingControl (`src/components/LightingControl.tsx`)
- Complete lighting system control
- Brightness control with real-time feedback
- Scheduling functionality
- Status monitoring and power usage display

#### WateringControl (`src/components/WateringControl.tsx`)
- Manual and automatic watering control
- Duration and interval configuration
- Emergency stop detection
- Water level monitoring with color coding

#### Navigation (`src/components/Navigation.tsx`)
- Clean navigation between dashboard and settings
- Responsive design with mobile-friendly icons

### Pages

#### Dashboard (`src/pages/index.tsx`)
- Grid layout with status panel and controls
- Responsive design for desktop and mobile
- Real-time updates without manual refresh

#### Settings (`src/pages/settings.tsx`)
- Comprehensive configuration interface
- Lighting and watering system settings
- System health monitoring
- Real-time status display

### Styling (`src/styles/main.css`)
- Modern, responsive CSS design
- Plant-themed color scheme
- Mobile-first responsive design
- Loading states and animations
- Print-friendly styles

## API Integration

### Endpoints Used

```typescript
// Health and Status
GET /api/health          - System health check
GET /api/status          - Complete system status
GET /api/sensors         - All sensor readings

// Lighting Control
GET /api/lighting        - Current lighting status
POST /api/lighting       - Update lighting settings

// Watering Control
GET /api/watering        - Current watering status
POST /api/watering       - Control watering system
```

### Data Flow

1. **Initial Load**: Components fetch current status from backend
2. **Real-time Updates**: Status panel refreshes every 30 seconds
3. **User Actions**: Control components send updates and refresh status
4. **Error Handling**: Graceful fallbacks with retry mechanisms

## Environment Configuration

### Development
- Frontend: `http://localhost:3000`
- Backend: `http://localhost:5000`
- CORS enabled for cross-origin requests

### Production (Docker)
- Frontend: `http://localhost:12500`
- Backend: `http://backend:5000` (Docker Compose service name)

## Key Features

### Real-time Monitoring
- Automatic status updates every 30 seconds
- Color-coded indicators for plant health
- Connection status monitoring
- Last update timestamps

### Comprehensive Control
- **Lighting**: Brightness, on/off toggle, scheduling
- **Watering**: Manual trigger, automatic scheduling, emergency stop
- **System**: Health checks, error reporting

### User Experience
- Loading states for all operations
- Success/error message feedback
- Mobile-responsive design
- Keyboard and screen reader accessible

### Error Handling
- Network error recovery
- Graceful degradation when backend unavailable
- Retry mechanisms for failed operations
- Clear error messages for users

## Development Commands

```bash
# Frontend development
cd src/plant-wall-control-web
npm install
npm run dev

# Backend development (separate terminal)
cd src/plant-wall-control
go run main.go

# Production build
npm run build
npm run start
```

## Testing Integration

1. Start the Go backend:
   ```bash
   cd src/plant-wall-control
   go run main.go
   ```

2. Start the frontend:
   ```bash
   cd src/plant-wall-control-web
   npm run dev
   ```

3. Access the application at `http://localhost:3000`

## API Communication Examples

### Fetch System Status
```typescript
const status = await fetchStatus();
console.log(status); // SystemStatus object
```

### Control Lighting
```typescript
const result = await updateLighting({
    brightness: 75,
    enabled: true
});
```

### Start Manual Watering
```typescript
const result = await triggerWatering({
    duration: 30,
    auto_mode: false
});
```

## Troubleshooting

### Common Issues

1. **CORS Errors**: Ensure Go backend CORS middleware is properly configured
2. **Connection Refused**: Check that Go backend is running on port 5000
3. **Type Errors**: Verify TypeScript interfaces match Go struct definitions
4. **Loading States**: Components handle loading gracefully when backend is unavailable

### Debug Steps

1. Check browser network tab for API calls
2. Verify Go backend logs for request handling
3. Test API endpoints directly with curl or Postman
4. Check console for JavaScript errors

## Production Deployment

The frontend is optimized for production deployment with:
- Environment-based API URL configuration
- Docker Compose service name resolution
- Optimized bundle size and caching
- Mobile-responsive design for tablet monitoring

## Future Enhancements

- WebSocket integration for real-time updates
- Historical data charting
- Mobile push notifications
- Advanced scheduling features
- Multi-plant module support