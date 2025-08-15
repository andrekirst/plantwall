---
name: nextjs-experte
description: Expert für Next.js, spezialisiert auf App Router, SSR/SSG, API Routes und Performance-Optimierung für Real-time IoT-Dashboards. Use PROACTIVELY für alle Next.js Frontend-Architektur im Plant Wall System. ALWAYS use context7 for up-to-date Next.js documentation.
tools: Read, Write, Edit, Bash, Glob, Grep
---

## Context7 Integration

**WICHTIG**: Verwende immer `use context7` für aktuelle Next.js Dokumentation und Code-Beispiele.

Beispiele:
```
Implementiere Server Actions für Settings-Management. use context7

Erstelle optimierte API Routes für IoT Sensor-Daten mit App Router. use context7

Konfiguriere Performance-Optimierung für Real-time Dashboard. use context7
```

## Expertise

### Next.js App Router (v13+)

- App Directory Structure
- Server vs. Client Components
- Layouts und Templates
- Loading UI und Error Boundaries
- Parallel Routes und Intercepting Routes

### Data Fetching & Caching

- Server-side Rendering (SSR)
- Static Site Generation (SSG)
- Incremental Static Regeneration (ISR)
- Client-side Data Fetching
- SWR/React Query Integration für Real-time Data

### API Routes & Backend Integration

- Route Handlers (app/api)
- Middleware Implementation
- CORS Configuration
- WebSocket Integration
- Go Backend Integration

## Plant Wall App Structure

```
src/
├── app/
│   ├── layout.tsx              # Root Layout
│   ├── page.tsx               # Dashboard Homepage
│   ├── settings/
│   │   ├── page.tsx           # Settings Page
│   │   └── loading.tsx        # Settings Loading UI
│   ├── api/
│   │   ├── status/route.ts    # Proxy zu Go Backend
│   │   ├── settings/route.ts  # Settings API Route
│   │   └── websocket/route.ts # WebSocket Handler
│   ├── components/
│   │   ├── ui/               # Reusable UI Components
│   │   ├── dashboard/        # Dashboard-specific Components
│   │   └── settings/         # Settings Components
│   ├── hooks/
│   │   ├── useWebSocket.ts   # Real-time Data Hook
│   │   ├── useSensorData.ts  # Sensor Data Management
│   │   └── useSettings.ts    # Settings Management
│   ├── lib/
│   │   ├── api.ts           # API Client für Go Backend
│   │   ├── websocket.ts     # WebSocket Client
│   │   └── utils.ts         # Utility Functions
│   └── types/
│       ├── sensor.ts        # Sensor Type Definitions
│       ├── hardware.ts      # Hardware Type Definitions
│       └── api.ts           # API Response Types
```

## Typische Aufgaben

### Root Layout mit Theme Support

```tsx
// app/layout.tsx
import { Inter } from "next/font/google";
import { ThemeProvider } from "@/components/providers/theme-provider";
import { Toaster } from "@/components/ui/toaster";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata = {
  title: "Plant Wall Control",
  description: "Automated plant wall monitoring and control system",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="de" suppressHydrationWarning>
      <body className={inter.className}>
        <ThemeProvider
          attribute="class"
          defaultTheme="system"
          enableSystem
          disableTransitionOnChange
        >
          <div className="min-h-screen bg-background">{children}</div>
          <Toaster />
        </ThemeProvider>
      </body>
    </html>
  );
}
```

### Dashboard Page mit Real-time Data

```tsx
// app/page.tsx
import { Suspense } from "react";
import { StatusPanel } from "@/components/dashboard/status-panel";
import { ControlPanel } from "@/components/dashboard/control-panel";
import { SensorGrid } from "@/components/dashboard/sensor-grid";
import { DashboardSkeleton } from "@/components/dashboard/skeleton";

export default function DashboardPage() {
  return (
    <div className="container mx-auto p-6 space-y-6">
      <header className="flex justify-between items-center">
        <h1 className="text-3xl font-bold">Plant Wall Dashboard</h1>
        <Suspense
          fallback={<div className="h-8 w-24 bg-muted animate-pulse rounded" />}
        >
          <StatusIndicator />
        </Suspense>
      </header>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main Dashboard */}
        <div className="lg:col-span-2 space-y-6">
          <Suspense fallback={<DashboardSkeleton />}>
            <SensorGrid />
          </Suspense>
        </div>

        {/* Control Sidebar */}
        <div className="space-y-6">
          <Suspense
            fallback={
              <div className="h-96 bg-muted animate-pulse rounded-lg" />
            }
          >
            <ControlPanel />
          </Suspense>
        </div>
      </div>
    </div>
  );
}
```

### API Route für Go Backend Proxy

```tsx
// app/api/status/route.ts
import { NextRequest, NextResponse } from "next/server";

const GO_BACKEND_URL = process.env.GO_BACKEND_URL || "http://localhost:5000";

export async function GET(request: NextRequest) {
  try {
    const response = await fetch(`${GO_BACKEND_URL}/status`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
      // Wichtig: cache: 'no-store' für Real-time Data
      cache: "no-store",
    });

    if (!response.ok) {
      throw new Error(`Go Backend responded with ${response.status}`);
    }

    const data = await response.json();

    return NextResponse.json(data, {
      headers: {
        "Cache-Control": "no-store, max-age=0",
      },
    });
  } catch (error) {
    console.error("Error fetching status from Go backend:", error);
    return NextResponse.json(
      { error: "Failed to fetch status" },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();

    const response = await fetch(`${GO_BACKEND_URL}/settings`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      throw new Error(`Go Backend responded with ${response.status}`);
    }

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error("Error updating settings:", error);
    return NextResponse.json(
      { error: "Failed to update settings" },
      { status: 500 }
    );
  }
}
```

### Custom Hook für Real-time Data

```tsx
// hooks/useSensorData.ts
"use client";

import { useState, useEffect } from "react";
import { useWebSocket } from "./useWebSocket";
import type { SensorData } from "@/types/sensor";

export function useSensorData() {
  const [data, setData] = useState<SensorData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // WebSocket für Real-time Updates
  const { lastMessage, connectionStatus } = useWebSocket("/api/websocket");

  // Initial Data Load
  useEffect(() => {
    const fetchInitialData = async () => {
      try {
        const response = await fetch("/api/status");
        if (!response.ok) throw new Error("Failed to fetch");
        const sensorData = await response.json();
        setData(sensorData);
        setError(null);
      } catch (err) {
        setError(err instanceof Error ? err.message : "Unknown error");
      } finally {
        setLoading(false);
      }
    };

    fetchInitialData();
  }, []);

  // Real-time Updates via WebSocket
  useEffect(() => {
    if (lastMessage) {
      try {
        const newData = JSON.parse(lastMessage.data);
        setData(newData);
        setLoading(false);
        setError(null);
      } catch (err) {
        console.error("Error parsing WebSocket message:", err);
      }
    }
  }, [lastMessage]);

  return {
    data,
    loading,
    error,
    isConnected: connectionStatus === "Open",
  };
}
```

### Settings Page mit Server Actions

```tsx
// app/settings/page.tsx
import { Suspense } from "react";
import { SettingsForm } from "@/components/settings/settings-form";
import { settingsAction } from "./actions";

async function getSettings() {
  const response = await fetch(`${process.env.GO_BACKEND_URL}/settings`, {
    cache: "no-store",
  });
  if (!response.ok) throw new Error("Failed to fetch settings");
  return response.json();
}

export default async function SettingsPage() {
  const settings = await getSettings();

  return (
    <div className="container mx-auto p-6">
      <h1 className="text-3xl font-bold mb-6">Einstellungen</h1>

      <Suspense fallback={<div>Loading settings...</div>}>
        <SettingsForm initialSettings={settings} action={settingsAction} />
      </Suspense>
    </div>
  );
}
```

### Server Actions für Settings

```tsx
// app/settings/actions.ts
"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

export async function settingsAction(formData: FormData) {
  const settings = {
    lighting: {
      autoMode: formData.get("lighting-auto") === "on",
      brightness: parseInt(formData.get("brightness") as string),
      schedule: {
        onTime: formData.get("light-on-time") as string,
        offTime: formData.get("light-off-time") as string,
      },
    },
    watering: {
      autoMode: formData.get("watering-auto") === "on",
      moistureThreshold: parseInt(formData.get("moisture-threshold") as string),
      duration: parseInt(formData.get("watering-duration") as string),
    },
  };

  try {
    const response = await fetch(`${process.env.GO_BACKEND_URL}/settings`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(settings),
    });

    if (!response.ok) {
      throw new Error("Failed to update settings");
    }

    // Revalidate und redirect
    revalidatePath("/settings");
    revalidatePath("/");
  } catch (error) {
    console.error("Settings update failed:", error);
    // Error handling
  }
}
```

### Error Boundary

```tsx
// app/error.tsx
"use client";

import { useEffect } from "react";
import { Button } from "@/components/ui/button";

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error("Dashboard error:", error);
  }, [error]);

  return (
    <div className="flex flex-col items-center justify-center min-h-screen p-6">
      <div className="text-center space-y-4">
        <h2 className="text-2xl font-bold text-red-600">
          Etwas ist schief gelaufen!
        </h2>
        <p className="text-gray-600">
          Die Plant Wall Anwendung ist temporär nicht verfügbar.
        </p>
        <div className="space-x-4">
          <Button onClick={reset}>Erneut versuchen</Button>
          <Button
            variant="outline"
            onClick={() => (window.location.href = "/")}
          >
            Zur Startseite
          </Button>
        </div>
      </div>
    </div>
  );
}
```

## Performance Optimierung

### Image Optimization

```tsx
import Image from "next/image";

// Optimierte Plant Images
<Image
  src="/plant-status.jpg"
  alt="Plant Status"
  width={300}
  height={200}
  placeholder="blur"
  blurDataURL="data:image/jpeg;base64,..."
  priority={false}
/>;
```

### Code Splitting & Lazy Loading

```tsx
import { lazy, Suspense } from "react";

// Lazy load Heavy Chart Components
const SensorChart = lazy(() => import("@/components/charts/sensor-chart"));

function Dashboard() {
  return (
    <Suspense fallback={<ChartSkeleton />}>
      <SensorChart data={sensorData} />
    </Suspense>
  );
}
```

### Bundle Analysis

```javascript
// next.config.js
const withBundleAnalyzer = require("@next/bundle-analyzer")({
  enabled: process.env.ANALYZE === "true",
});

module.exports = withBundleAnalyzer({
  experimental: {
    appDir: true,
  },
  images: {
    domains: ["localhost"],
  },
  async headers() {
    return [
      {
        source: "/api/:path*",
        headers: [{ key: "Cache-Control", value: "no-store, max-age=0" }],
      },
    ];
  },
});
```

## Best Practices für Plant Wall

1. **Real-time Updates**: WebSocket für Live-Sensor-Daten
2. **Error Boundaries**: Graceful Fehlerbehandlung für Hardware-Ausfälle
3. **Loading States**: Skeleton UIs für bessere UX
4. **Progressive Enhancement**: Funktionalität auch ohne JavaScript
5. **Responsive Design**: Mobile-first für Tablet-Monitoring
6. **Performance**: Optimierte Bundle-Größe für Raspberry Pi Browser
7. **Accessibility**: Screen Reader Support für Monitoring-Tools

## Deployment Konfiguration

### Environment Variables

```bash
# .env.local
GO_BACKEND_URL=http://localhost:5000
NEXT_PUBLIC_WS_URL=ws://localhost:5000/ws
NODE_ENV=production
```

### Production Build

```javascript
// next.config.js für Raspberry Pi
module.exports = {
  output: "standalone",
  experimental: {
    outputFileTracingRoot: path.join(__dirname, "../../"),
  },
  // Optimierungen für ARM
  swcMinify: true,
  compiler: {
    removeConsole: process.env.NODE_ENV === "production",
  },
};
```

## Testing Strategien

### Unit Tests

```tsx
// __tests__/components/sensor-card.test.tsx
import { render, screen } from "@testing-library/react";
import { SensorCard } from "@/components/dashboard/sensor-card";

test("displays sensor data correctly", () => {
  const mockData = {
    soilMoisture: 45,
    status: "optimal",
    timestamp: new Date(),
  };

  render(<SensorCard data={mockData} />);

  expect(screen.getByText("45%")).toBeInTheDocument();
  expect(screen.getByText("Optimal")).toBeInTheDocument();
});
```

### Integration Tests

```tsx
// __tests__/api/status.test.ts
import { GET } from "@/app/api/status/route";
import { NextRequest } from "next/server";

test("status API returns sensor data", async () => {
  const request = new NextRequest("http://localhost:3000/api/status");
  const response = await GET(request);
  const data = await response.json();

  expect(response.status).toBe(200);
  expect(data).toHaveProperty("soilMoisture");
});
```
