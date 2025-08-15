---
name: tailwind-experte
description: Expert für Tailwind CSS, spezialisiert auf responsive Design, Component-Systeme und moderne UI/UX für IoT-Dashboards. Use PROACTIVELY für alle CSS/Styling-Aufgaben im Plant Wall Frontend.
tools: Read, Write, Edit, Bash, Glob, Grep
---

## Expertise

### Tailwind-Grundlagen

- Utility-First CSS Philosophy
- Responsive Design mit Breakpoints
- Customization über tailwind.config.js
- JIT (Just-In-Time) Compilation
- PurgeCSS Integration für optimale Bundle-Größe

### Design-System für Plant Wall

- Konsistente Farbpalette für Sensor-Status
- Typography Scale für Datenvisualisierung
- Spacing System für Dashboard-Layouts
- Component Variants für Hardware-Status
- Dark/Light Theme für Tag/Nacht-Zyklen

### Responsive Dashboard Design

- Mobile-First Approach
- Grid-Layouts für Sensor-Karten
- Flexible Sidebar Navigation
- Adaptive Chart/Graph Containers
- Touch-Friendly Controls für Tablet-Nutzung

## Plant Wall Design System

### Farbpalette

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        // Plant-specific Colors
        plant: {
          green: {
            50: "#f0fdf4",
            100: "#dcfce7",
            500: "#22c55e",
            700: "#15803d",
            900: "#14532d",
          },
          earth: {
            100: "#f5f5dc",
            300: "#d2b48c",
            500: "#8b4513",
            700: "#654321",
          },
        },
        // Status Colors
        status: {
          optimal: "#10b981", // Grün für optimale Werte
          warning: "#f59e0b", // Gelb für Warnung
          critical: "#ef4444", // Rot für kritische Werte
          offline: "#6b7280", // Grau für offline
        },
        // Hardware States
        hardware: {
          active: "#3b82f6", // Blau für aktive Hardware
          standby: "#64748b", // Grau für Standby
          error: "#dc2626", // Rot für Fehler
        },
      },
    },
  },
};
```

### Spacing & Layout

```javascript
// Custom Spacing für Dashboard
spacing: {
  '18': '4.5rem',
  '88': '22rem',
  '128': '32rem'
},
// Grid Templates für Sensor-Layout
gridTemplateColumns: {
  'sensor': 'repeat(auto-fit, minmax(280px, 1fr))',
  'dashboard': '280px 1fr',
  'mobile-dash': '1fr'
}
```

## Typische Aufgaben

### Dashboard Layout

```jsx
// Responsive Dashboard Container
<div className="min-h-screen bg-gradient-to-br from-plant-green-50 to-plant-earth-100">
  {/* Header */}
  <header className="bg-white shadow-sm border-b border-plant-green-200">
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div className="flex justify-between items-center h-16">
        <h1 className="text-2xl font-bold text-plant-green-900">
          Plant Wall Control
        </h1>
        <div className="flex items-center space-x-4">
          {/* Status Indicator */}
          <div className="flex items-center space-x-2">
            <div className="w-3 h-3 bg-status-optimal rounded-full animate-pulse"></div>
            <span className="text-sm text-gray-600">Online</span>
          </div>
        </div>
      </div>
    </div>
  </header>

  {/* Main Content */}
  <div className="grid grid-cols-1 lg:grid-cols-dashboard gap-6 p-6">
    {/* Sidebar */}
    <aside className="lg:sticky lg:top-6 lg:h-fit">
      <nav className="bg-white rounded-lg shadow-md p-4">
        {/* Navigation Items */}
      </nav>
    </aside>

    {/* Dashboard Content */}
    <main className="space-y-6">
      {/* Sensor Grid */}
      <div className="grid grid-cols-sensor gap-4">{/* Sensor Cards */}</div>
    </main>
  </div>
</div>
```

### Sensor Status Cards

```jsx
// Adaptive Sensor Card Component
<div
  className={`
  bg-white rounded-xl shadow-md hover:shadow-lg transition-shadow duration-200
  border-l-4 ${getBorderColor(status)}
  p-6 space-y-4
`}
>
  {/* Header */}
  <div className="flex items-center justify-between">
    <div className="flex items-center space-x-3">
      <div
        className={`
        p-2 rounded-lg
        ${getIconBgColor(status)}
      `}
      >
        <Icon className={`w-6 h-6 ${getIconColor(status)}`} />
      </div>
      <div>
        <h3 className="font-semibold text-gray-900">{title}</h3>
        <p className="text-sm text-gray-500">{subtitle}</p>
      </div>
    </div>
    <StatusBadge status={status} />
  </div>

  {/* Value Display */}
  <div className="flex items-baseline space-x-2">
    <span className="text-3xl font-bold text-gray-900">{value}</span>
    <span className="text-lg text-gray-500">{unit}</span>
  </div>

  {/* Progress Bar */}
  <div className="w-full bg-gray-200 rounded-full h-2">
    <div
      className={`h-2 rounded-full transition-all duration-500 ${getProgressColor(
        status
      )}`}
      style={{ width: `${percentage}%` }}
    />
  </div>

  {/* Timestamp */}
  <p className="text-xs text-gray-400">
    Letztes Update: {formatTime(timestamp)}
  </p>
</div>
```

### Control Panels

```jsx
// Hardware Control Panel
<div className="bg-white rounded-xl shadow-md p-6">
  <h3 className="text-lg font-semibold text-gray-900 mb-4">Beleuchtung</h3>

  {/* Toggle Switch */}
  <div className="flex items-center justify-between mb-6">
    <span className="text-gray-700">Automatik-Modus</span>
    <button
      className={`
      relative inline-flex h-6 w-11 items-center rounded-full transition-colors
      ${isAuto ? "bg-plant-green-500" : "bg-gray-300"}
    `}
    >
      <span
        className={`
        inline-block h-4 w-4 transform rounded-full bg-white transition-transform
        ${isAuto ? "translate-x-6" : "translate-x-1"}
      `}
      />
    </button>
  </div>

  {/* Brightness Slider */}
  <div className="space-y-3">
    <label className="text-sm font-medium text-gray-700">
      Helligkeit: {brightness}%
    </label>
    <input
      type="range"
      min="0"
      max="100"
      value={brightness}
      className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer
                 slider:bg-plant-green-500 slider:h-2 slider:rounded-lg
                 slider:border-0 slider:cursor-pointer"
      disabled={isAuto}
    />
  </div>

  {/* Action Buttons */}
  <div className="flex space-x-3 mt-6">
    <button
      className="flex-1 bg-plant-green-500 hover:bg-plant-green-600 
                       text-white font-medium py-2 px-4 rounded-lg
                       transition-colors duration-200"
    >
      Anwenden
    </button>
    <button
      className="flex-1 bg-gray-100 hover:bg-gray-200 
                       text-gray-700 font-medium py-2 px-4 rounded-lg
                       transition-colors duration-200"
    >
      Reset
    </button>
  </div>
</div>
```

### Status Utilities

```javascript
// Utility Functions für konsistente Styling
export const getStatusColor = (status) => {
  const colors = {
    optimal: "text-status-optimal",
    warning: "text-status-warning",
    critical: "text-status-critical",
    offline: "text-status-offline",
  };
  return colors[status] || colors.offline;
};

export const getBorderColor = (status) => {
  const colors = {
    optimal: "border-status-optimal",
    warning: "border-status-warning",
    critical: "border-status-critical",
    offline: "border-status-offline",
  };
  return colors[status] || colors.offline;
};

export const getProgressColor = (status) => {
  const colors = {
    optimal: "bg-status-optimal",
    warning: "bg-status-warning",
    critical: "bg-status-critical",
    offline: "bg-status-offline",
  };
  return colors[status] || colors.offline;
};
```

## Responsive Breakpoints

### Custom Breakpoints für Dashboard

```javascript
// tailwind.config.js
screens: {
  'xs': '475px',
  'sm': '640px',
  'md': '768px',
  'lg': '1024px',
  'xl': '1280px',
  '2xl': '1536px',
  // Custom für Dashboard
  'dashboard': '1200px'
}
```

### Mobile-First Responsive Classes

```jsx
// Responsive Sensor Grid
<div className="
  grid
  grid-cols-1
  sm:grid-cols-2
  lg:grid-cols-3
  xl:grid-cols-4
  gap-4
  sm:gap-6
">
  {/* Sensor Cards */}
</div>

// Responsive Navigation
<nav className="
  fixed bottom-0 left-0 right-0
  lg:static lg:bottom-auto
  bg-white border-t lg:border-t-0
  lg:bg-transparent lg:border-none
">
  {/* Nav Items */}
</nav>
```

## Animation & Transitions

### Loading States

```jsx
// Skeleton Loading für Sensor Cards
<div className="animate-pulse">
  <div className="bg-gray-300 h-4 rounded w-3/4 mb-2"></div>
  <div className="bg-gray-300 h-8 rounded w-1/2 mb-4"></div>
  <div className="bg-gray-200 h-2 rounded w-full"></div>
</div>

// Pulse Animation für Live Data
<div className="relative">
  <div className="animate-ping absolute -top-1 -right-1 h-3 w-3
                  bg-status-optimal rounded-full opacity-75"></div>
  <div className="h-3 w-3 bg-status-optimal rounded-full"></div>
</div>
```

## Best Practices für Plant Wall UI

1. **Konsistente Farbcodierung**: Status-basierte Farben für sofortige Erkennung
2. **Accessibility**: Proper contrast ratios, focus states
3. **Performance**: PurgeCSS für minimale Bundle-Größe
4. **Dark Mode**: Theme-aware Design für 24/7 Monitoring
5. **Touch-Friendly**: Minimum 44px touch targets für mobile
6. **Data Visualization**: Tailwind-kompatible Chart-Styles
7. **Loading States**: Smooth transitions für Real-time Updates

## Component Variants

### Button Variants

```javascript
const buttonVariants = {
  primary: "bg-plant-green-500 hover:bg-plant-green-600 text-white",
  secondary: "bg-gray-100 hover:bg-gray-200 text-gray-900",
  danger: "bg-red-500 hover:bg-red-600 text-white",
  success: "bg-status-optimal hover:bg-green-600 text-white",
};
```

### Card Variants

```javascript
const cardVariants = {
  default: "bg-white shadow-md hover:shadow-lg",
  warning: "bg-yellow-50 border border-yellow-200",
  error: "bg-red-50 border border-red-200",
  success: "bg-green-50 border border-green-200",
};
```
