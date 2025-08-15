# Plant Wall Control System

Ein automatisiertes Steuerungssystem für Pflanzenwände, optimiert für Raspberry Pi und entwickelt für optimale Wachstumsbedingungen.

## Überblick

Das Plant Wall Control System automatisiert die Pflege einer Pflanzenwand durch intelligente Steuerung von:

- **🌱 Beleuchtung**: Simuliert Tag-/Nacht-Zyklen mit anpassbarer Helligkeit
- **💧 Bewässerung**: Automatische Bewässerung basierend auf Bodenfeuchtigkeit
- **🧪 Nährstoffe**: Kontrollierte Nährstoffzufuhr für optimales Pflanzenwachstum
- **📊 Überwachung**: Kontinuierliche Messung von Umweltbedingungen
- **🖥️ Benutzeroberfläche**: Physisches Display + professionelle Web-Anwendung

## System-Architektur

```
┌─────────────────────┐    HTTP API    ┌─────────────────────┐
│   Next.js Frontend  │ ◄────────────► │   Go Backend        │
│   (Web Interface)   │                │   (Hardware Control)│
└─────────────────────┘                └─────────┬───────────┘
                                                 │
                                                 ▼
                                       ┌─────────────────────┐
                                       │  Raspberry Pi GPIO  │
                                       │  Hardware Interface │
                                       └─────────────────────┘
                                                 │
                    ┌────────────────────────────┼────────────────────────────┐
                    ▼                            ▼                            ▼
            ┌───────────────┐           ┌───────────────┐           ┌───────────────┐
            │   Sensoren    │           │   Aktoren     │           │   Display     │
            │               │           │               │           │               │
            │ • Bodenfeuchte│           │ • LED-Leuchten│           │ • Status-Info │
            │ • Lichtsensor │           │ • Wasserpumpe │           │ • Messwerte   │
            │ • Wassertank  │           │ • Nährstoffp. │           │ • Einstellungen│
            └───────────────┘           └───────────────┘           └───────────────┘
```

## Hardware-Anforderungen

### Mindestanforderungen
- **Raspberry Pi Zero 2W** oder höher
- **MicroSD-Karte** (16GB+)
- **Stromversorgung** (5V, min. 2.5A)

### Sensoren
- Bodenfeuchtesensor (analog/digital)
- Lichtsensor (LDR oder digitaler Sensor)
- Wasserstandssensor
- Optional: Temperatur-/Luftfeuchtesensor

### Aktoren
- LED-Beleuchtung (PWM-steuerbar)
- Wasserpumpe (12V mit Relais)
- Nährstoffpumpe (12V mit Relais)
- Optional: Lüfter für Luftzirkulation

### Display & Bedienung
- Small OLED/LCD Display (I2C/SPI)
- Optional: Buttons für lokale Bedienung

## Software-Stack

### Backend (Go)
- **Hochperformant**: Minimaler Speicherverbrauch auf Raspberry Pi
- **GPIO-Steuerung**: Direkte Hardware-Anbindung
- **REST API**: JSON-basierte Kommunikation mit Frontend
- **Cross-Compilation**: Entwicklung auf Desktop, Deployment auf Pi

### Frontend (Next.js/TypeScript)
- **Responsive Design**: Desktop, Tablet, Mobile
- **Real-time Updates**: Live-Monitoring der Systemdaten
- **Benutzerfreundlich**: Intuitive Bedienung und Konfiguration
- **Progressive Web App**: Installierbar auf mobilen Geräten

## Installation

### Voraussetzungen
```bash
# Go 1.21+ installieren
# Node.js 18+ und npm installieren
# Git installieren
```

### Repository klonen
```bash
git clone https://github.com/andrekirst/plantwall.git
cd plantwall
```

### Frontend Setup
```bash
cd src/plant-wall-control-web
npm install
npm run dev          # Entwicklungsserver (localhost:3000)
npm run build        # Produktions-Build
```

### Backend Setup
```bash
cd src/plant-wall-control
go mod init plant-wall-control
go mod tidy
go run main.go       # Entwicklungsserver (localhost:5000)
go build -o plant-wall-control  # Binary erstellen
```

## Verwendung

### Web-Interface
1. Frontend starten: `npm run dev` (Port 3000)
2. Backend starten: `go run main.go` (Port 5000)
3. Browser öffnen: `http://localhost:3000`

### Produktionsdeployment auf Raspberry Pi
```bash
# Cross-Compilation für ARM
GOOS=linux GOARCH=arm64 go build -o plant-wall-control

# Auf Pi kopieren und ausführen
scp plant-wall-control pi@raspberry-pi:/home/pi/
ssh pi@raspberry-pi './plant-wall-control'
```

## Konfiguration

### Hardware-Konfiguration
- GPIO-Pin-Zuordnung in `config/hardware.go`
- Sensor-Schwellenwerte in `config/sensors.go`
- Timing-Einstellungen über Web-Interface

### Automatisierung
- **Beleuchtung**: Automatische Tag/Nacht-Zyklen
- **Bewässerung**: Basierend auf Bodenfeuchte-Schwellenwerten
- **Nährstoffe**: Zeitgesteuerte oder bedarfsbasierte Zugabe
- **Monitoring**: Kontinuierliche Datenerfassung und -speicherung

## API-Endpunkte

```
GET  /status          # Aktuelle Systemdaten
POST /settings        # Einstellungen aktualisieren
GET  /history         # Historische Daten
POST /manual/water    # Manuelle Bewässerung
POST /manual/light    # Manuelle Lichtsteuerung
POST /manual/nutrients # Manuelle Nährstoffzugabe
```

## Entwicklung

Siehe [CLAUDE.md](./CLAUDE.md) für detaillierte Entwicklungsrichtlinien und Architektur-Informationen.

## Roadmap

- [ ] **Phase 1**: Grundlegende Hardware-Steuerung (Go Backend)
- [ ] **Phase 2**: Web-Interface Integration
- [ ] **Phase 3**: Datenlogging und Historische Auswertung
- [ ] **Phase 4**: Machine Learning für optimierte Pflanzenpflege
- [ ] **Phase 5**: Multi-Plant-Wall Management

## Beitragen

1. Fork das Repository
2. Feature-Branch erstellen (`git checkout -b feature/amazing-feature`)
3. Änderungen committen (`git commit -m 'Add amazing feature'`)
4. Branch pushen (`git push origin feature/amazing-feature`)
5. Pull Request öffnen

## Lizenz

Dieses Projekt steht unter der MIT-Lizenz. Siehe [LICENSE](LICENSE) für Details.

## Support

- **Issues**: [GitHub Issues](https://github.com/andrekirst/plantwall/issues)
- **Diskussionen**: [GitHub Discussions](https://github.com/andrekirst/plantwall/discussions)
- **Wiki**: [Projektdokumentation](https://github.com/andrekirst/plantwall/wiki)