# Konstruktionskonzept: Automatisierte Pflanzenwand

**Projektspezifikationen:**

- Abmessungen: 2,8m (Breite) × 2,3m (Höhe)
- Steuerung: Raspberry Pi Zero 2W
- **Zielsetzung: Raumklima-Verbesserung und Luftreinigung**
- Automatische Bewässerung und Überwachung
- Freistehende Konstruktion mit Wandsicherung

---

## 1. Struktureller Aufbau

### 1.1 Freistehende Konstruktion mit Wandsicherung

**Grundprinzip: Bodenständer-System**

- Material: Aluminium-Profile 40x40mm (Serie 8)
- **Haupttraglast:** Komplett auf stabilem Bodenrahmen (wie ein Regal)
- **Wandkontakt:** Nur zur Kipp-Sicherung - minimale Wandbelastung
- Wandabstand: 5-10cm (nur für Sicherungsbefestigung)

**Konstruktionskonzept:**

- **Schwere Bodenplatte:** Stahlrahmen 60x40mm als stabile Basis
- **Vertikale Träger:** 4x Aluminium-Profile, fest mit Bodenrahmen verbunden
- **Wandsicherung:** 2-4 leichte Sicherungspunkte gegen Umkippen
- **Höhenverstellung:** Verstellbare Füße für unebene Böden

**Konstruktionsschema:**

```
Draufsicht Bodenständer-System:
┌─────────────────────────────────────────────────┐ 2,8m
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │ ← Schwere Bodenplatte (Stahlrahmen)
│ │                                           │ │
│ │  ● Pflanzmodule (luftreinigende Pflanzen) │ │ 
│ │                                           │ │
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
└─────────────────────────────────────────────────┘
                         │    │ ← Nur 2 leichte Wandsicherungen
                        Wand
```

**Seitenansicht Bodenständer:**

```
Wand    ┌─────────────────────────┐ ← Pflanzenwand (2,3m hoch)
 █████ ╱│  🌿   🌿   🌿   🌿   🌿  │ ← Luftreinigende Pflanzen  
 █████╱ │  🌿   🌿   🌿   🌿   🌿  │   ┌─ Leichte Wandsicherung
 ████│  │  🌿   🌿   🌿   🌿   🌿  │ ──┤   (nur gegen Umkippen)
 ████│  │  🌿   🌿   🌿   🌿   🌿  │   └─ Minimale Wandlast
 ████│  │                         │
 ████│  └─────────────────────────┘
 ████│  ▌█████████████████████████▐ ← Schwere Bodenplatte (Haupttragkraft)
      │  ▌ Wasserreservoir + Pumpe ▐
      │  ▌       Elektronik       ▐
      └──▌███████████████████████▌─┘
         ▲                       ▲
    Höhenverstellbarer Fuß  Höhenverstellbarer Fuß
```

### 1.2 Materialauswahl mit Begründung

**Tragstruktur:**

- Aluminium-Profile: Gewicht 3,2 kg/m, Tragkraft 2000N/m
- Edelstahl-Verbinder: V4A für Feuchtigkeitsresistenz
- EPDM-Dichtungen: UV-beständig, 15 Jahre Haltbarkeit

**Pflanzfächer:**

- HDPE-Kunststoff: Lebensmittelecht, UV-stabil
- Wandstärke: 3mm für Stabilität bei Vollfüllung

### 1.3 Lastverteilung Bodenständer-System

**Gewichtsanalyse:**

- Bodenplatte (Stahl): ~60 kg
- Tragkonstruktion: ~40 kg
- Pflanzmodule mit Substrat: ~80 kg
- Wasserreservoir (gefüllt): ~50 kg
- **Gesamtgewicht: ~230 kg**

**Lastverteilung:**
- **Bodenbelastung:** 230 kg (verteilt auf 4 Füße = 57,5 kg/Fuß)
- **Wandbelastung:** Nur Kipp-Sicherung (~10-20 kg seitlich)
- **Vorteil:** Geeignet für alle Wandtypen, auch Gipskarton oder Altbau

## 2. Modulares Pflanzensystem

### 2.1 Anzahl und Dimensionen der Pflanzmodule

**Luftreinigungs-optimiertes Layout:**

- 5 Module horizontal × 4 Module vertikal = **20 Pflanzmodule**
- Einzelmodul: 50cm (B) × 50cm (H) × 30cm (T)  
- Nutzvolumen: 7,5 Liter pro Modul (größere Pflanzen für bessere Luftreinigung)

```
Seitenansicht Pflanzfächer:
┌────┬────┬────┬────┬────┬────┬────┐ ← Obere Reihe
│ 01 │ 02 │ 03 │ 04 │ 05 │ 06 │ 07 │ 35cm
├────┼────┼────┼────┼────┼────┼────┤
│ 08 │ 09 │ 10 │ 11 │ 12 │ 13 │ 14 │ 35cm
├────┼────┼────┼────┼────┼────┼────┤
│ 15 │ 16 │ 17 │ 18 │ 19 │ 20 │ 21 │ 35cm
├────┼────┼────┼────┼────┼────┼────┤
│ 22 │ 23 │ 24 │ 25 │ 26 │ 27 │ 28 │ 35cm
├────┼────┼────┼────┼────┼────┼────┤
│ 29 │ 30 │ 31 │ 32 │ 33 │ 34 │ 35 │ 35cm
├────┼────┼────┼────┼────┼────┼────┤
│ 36 │ 37 │ 38 │ 39 │ 40 │ 41 │ 42 │ 35cm ← Untere Reihe
└────┴────┴────┴────┴────┴────┴────┘
```

### 2.2 Substrat für Luftreinigungs-Pflanzen

**Gewähltes System: Hochwertige Zimmerpflanzen-Erde mit Drainage**

- Substrat: Premium-Zimmerpflanzenerde mit Perlite und Kokosfasern
- Drainage: Blähton-Schicht am Boden jedes Moduls
- Wurzelraum: Optimiert für gesunde Zimmerpflanzen und Langzeit-Stabilität

**Vorteile für Raumklima:**

- Natürliche Luftfeuchtigkeit-Regulierung durch Erdsubstrat
- Bessere Nährstoffspeicherung für robuste Pflanzengesundheit
- Pflegeleicht und wartungsfreundlich
- Geeignet für alle luftreinigenden Zimmerpflanzen
- Längere Standzeiten ohne Pflanzenwechsel

### 2.3 Drainage-System

**Aufbau (von oben nach unten):**

1. Überlauf-Schutz: 5mm über maximaler Füllhöhe
2. Hauptdrainagerohr: DN32 PVC mit 2% Gefälle
3. Sammelrinne: Edelstahl V2A, 50mm breit
4. Rücklauf zum Reservoir: Schwerkraft-gesteuert

### 2.4 Pflanzenauswahl für optimale Luftreinigung

**NASA Clean Air Study - Top Luftreiniger:**

**Hauptpflanzen (10 Module):**
- **Bogenhanf (Sansevieria):** Entfernt Formaldehyd, Benzol, produziert nachts O₂
- **Efeutute (Epipremnum):** Filtert Formaldehyd, Xylol, schnelles Wachstum
- **Friedenslilie (Spathiphyllum):** Ammoniak, Benzol, Trichloretylen-Filter
- **Gummibaum (Ficus elastica):** Formaldehyd-Spezialist, große Blattoberfläche

**Ergänzungspflanzen (10 Module):**
- **Grünlilie (Chlorophytum):** Formaldehyd, Xylol, sehr pflegeleicht
- **Drachenbaum (Dracaena):** Trichloretylen, Formaldehyd, optisch ansprechend
- **Aloe Vera:** Benzol, Formaldehyd, zusätzlicher Nutzen als Heilpflanze
- **Bambus-Palme (Chamaedorea):** Formaldehyd, Xylol, erhöht Luftfeuchtigkeit

**Auswahlkriterien:**
- Nachgewiesene Luftreinigungsleistung (NASA-Studie)
- Robustheit und pflegeleichte Eigenschaften
- Verschiedene Blattformen für maximale Oberfläche
- Kompatibilität mit automatischer Bewässerung
- Ästhetische Vielfalt (verschiedene Höhen und Texturen)

## 3. Bewässerungsinfrastruktur

### 3.1 Wasserleitungsverlegung

**Hauptverteilung:**

- Material: PE-Rohr 20mm für Hauptleitung
- Tropfleitungen: 6mm Mikro-Schläuche
- Verlegung: Hinter Aluminium-Profilen für Wartungszugang

**Verteilsystem:**

```
Wasserleitungs-Schema:
    Reservoir (100L)
         │
    Hauptpumpe (12V)
         │
┌────────┼────────┐
│   Zuleitung     │ 20mm PE-Rohr
│                 │
├─┬─┬─┬─┬─┬─┬─────┤ Verteilermanifold (7-fach)
│ │ │ │ │ │ │     │
▼ ▼ ▼ ▼ ▼ ▼ ▼     ▼ 6mm Mikro-Schläuche
█ █ █ █ █ █ █  Reihe 1 (Fächer 1-7)
█ █ █ █ █ █ █  Reihe 2 (Fächer 8-14)
█ █ █ █ █ █ █  Reihe 3 (Fächer 15-21)
█ █ █ █ █ █ █  Reihe 4 (Fächer 22-28)
█ █ █ █ █ █ █  Reihe 5 (Fächer 29-35)
█ █ █ █ █ █ █  Reihe 6 (Fächer 36-42)
```

### 3.2 Pumpen- und Ventilpositionen

**Hauptpumpe:**

- Typ: 12V Tauchpumpe, 800 L/h, 3m Förderhöhe
- Position: Im Reservoir (schallgedämpft)
- Redundanz: Backup-Pumpe (manuell schaltbar)

**Elektroventile:**

- 7x 12V Magnetventile (einer pro Spalte)
- Position: Unter Pflanzenwand in Servicekasten
- Durchfluss: 100 L/h pro Ventil

### 3.3 Wasserreservoir-Dimensionierung

**Hauptreservoir:**

- Volumen: 100 Liter (Polyethylen-Tank)
- Abmessungen: 80cm × 40cm × 35cm
- Position: Unter der Pflanzenwand (verdeckt)
- Füllstandsensor: Ultraschall-Sensor (JSN-SR04T)

**Berechnung Wasserbedarf:**

- Pro Pflanze/Tag: 0,5 Liter
- 42 Pflanzen × 0,5L = 21 Liter/Tag
- Reservoir-Kapazität: 5 Tage Autonomie

### 3.4 Nährstoffdosierung-System

**Dosier-Setup:**

- 2x Dosier-Pumpen (A+B Lösung)
- Konzentrat-Behälter: 2x 5 Liter
- Dosierung: 0,5-2ml pro Liter (EC-gesteuert)
- pH-Regulierung: Automatische Säure-Dosierung

## 4. Elektronik-Integration

### 4.1 Kabelführung wasserdicht

**Hauptkabelkanal:**

- Aluminium-Kabelkanal 60×40mm
- Schutzart: IP65 durch EPDM-Dichtungen
- Zugentlastung: PG-Verschraubungen für alle Durchführungen

**Verkabelungsschema:**

```
Elektronik-Verteilung:
┌─ Raspberry Pi Zero 2W (IP65-Gehäuse)
├─ 12V Netzteil (Mean Well, 5A)
├─ GPIO-Expander (MCP23017) ×2
├─ ADC-Wandler (ADS1115) für Analogsensoren
└─ Relais-Platine (8-Kanal, 12V)
```

### 4.2 Sensorpositionierung

**Sensoren pro Zone (3 Zonen):**

- Bodenfeuchtigkeit: Kapazitive Sensoren (korrosionsfrei)
- pH-Wert: Digitale pH-Elektrode (±0.1 pH Genauigkeit)
- EC-Wert: Leitfähigkeitssensor (±2% Genauigkeit)
- Luftfeuchtigkeit/Temperatur: SHT30 (±2% rel. Feuchte)
- Lichtstärke: BH1750 (Lux-Meter, I²C)

**Positionierung:**

- Zone 1: Obere Reihen (1-14)
- Zone 2: Mittlere Reihen (15-28)
- Zone 3: Untere Reihen (29-42)

### 4.3 LED-Beleuchtungssystem

**LED-Strips:**

- Typ: Vollspektrum LED (380-780nm)
- Leistung: 20W/m, 24V DC
- Anzahl: 6 Strips à 1,2m = 144W Gesamtleistung
- Dimmung: PWM-gesteuert (0-100%)

**Beleuchtungszeit:**

- Wachstumsphase: 14h/Tag (6:00-20:00 Uhr)
- Intensität: 70% tagsüber, 30% morgens/abends
- Spektrum: Blau-reich morgens, Rot-reich abends

### 4.4 Zentrale Steuereinheit (Raspberry Pi) Gehäuse

**Gehäuse-Spezifikation:**

- Material: Polycarbonat, transparent
- Schutzart: IP65
- Abmessungen: 160×110×70mm
- Belüftung: Lüftergitter mit Filter
- Montage: DIN-Schiene kompatibel

**Interne Ausstattung:**

- Raspberry Pi Zero 2W + 32GB SD-Karte
- HAT: GPIO-Expander für 32 zusätzliche I/O
- Mini-Display: 2,8" TFT für Status-Anzeige
- Backup-Batterie: 18650 Li-Ion für 4h Autonomie

## 5. Technische Zeichnungen/Skizzen

### 5.1 Struktur-Übersicht

```
Seitenansicht (Schnitt A-A):
                    Wand
                     │
    ┌───15cm───┐    │
    │           │    │ ← Wandabstand für Wartung
2,3m│    ┌──────┼────┤
    │    │ LED  │ ○○ │ ← LED-Beleuchtung
    │    │      │ ██ │ ← Pflanzfächer (6 Reihen)
    │    │      │ ██ │
    │    │      │ ██ │
    │    │      │ ██ │
    │    │      │ ██ │
    │    │      │ ██ │
    │    └──────┼────┤
    │           │  ◊ │ ← Reservoir (100L)
    └───────────┼────┘
                │
            2,8m Breite
```

### 5.2 Detailansichten kritischer Bereiche

**Bewässerungs-Detail pro Fach:**

```
Einzelfach-Schnitt:
┌─────────────────────────────────┐ ← Überlauf (5mm)
│ ◊◊◊ ░░░░░░░░░░░░░░░░░░░░░░░ ◊◊◊ │ ← Blähton (2cm)
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │ ← Steinwolle (8cm)
│ ≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈ │ ← Nährlösung (5mm Film)
└─────────────┬───────────────────┘
              ▼ Drainage DN32
```

**Sensor-Integration:**

```
Sensor-Anordnung pro Zone:
    pH-Sensor ◄─────────┐
         ▲              │
    ┌────┼────┐         │ Zum Pi Zero 2W
    │ Fach XX │◄────────┤ (I²C/GPIO)
    │ ░░░░░░░ │         │
    └────┼────┘         │
    EC-Sensor ◄─────────┘
```

### 5.3 Installations-Schematik

**Elektrische Verteilung:**

```
Hauptverteilung:
230V AC ──► Netzteil (24V, 6A) ──┬─► LED-Strips (144W)
                                 │
         ┌─► Netzteil (12V, 5A) ──┼─► Pumpen + Ventile
         │                       │
         │                       └─► Raspberry Pi (5V, 2A)
         │                           │
         └───────────────────────────┼─► Sensoren (3.3V)
                                     │
                                     └─► GPIO-Expander
```

## 6. Materialliste

### 6.1 Strukturelle Komponenten

| Komponente                    | Menge  | Beschreibung |
| ----------------------------- | ------ | ------------ |
| Alu-Profile 40x40mm (6m)      | 8 Stk  | Haupttragstruktur |
| Alu-Verbinder                 | 24 Stk | Rahmenverbindungen |
| Schwerlastdübel M12           | 8 Stk  | Wandsicherung |
| HDPE-Pflanzmodule (50x50x30cm)| 20 Stk | Luftreinigungs-Module |
| Stahlrahmen Bodenplatte       | 1 Set  | Stabile Basis |
| Höhenverstellbare Füße        | 4 Stk  | Bodenausgleich |
| Montage-Material              | 1 Set  | Schrauben, Dichtungen |

### 6.2 Bewässerungssystem

| Komponente                | Menge   | Beschreibung |
| ------------------------- | ------- | ------------ |
| Tauchpumpe 12V, 500L/h    | 1 Stk   | Hauptpumpe für Bewässerung |
| Magnetventile 12V         | 4 Stk   | Zonensteuerung |
| Tropfschläuche 6mm        | 50m     | Direkte Pflanzenversorgung |
| Wasserreservoir 50L       | 1 Stk   | Wasserspeicher im Bodenbereich |
| Druckminderer             | 2 Stk   | Gleichmäßiger Wasserdruck |
| Schlauchverbinder         | 20 Stk  | Systemverbindungen |

### 6.3 Elektronik und Sensoren

| Komponente                   | Menge | Beschreibung |
| ---------------------------- | ----- | ------------ |
| Raspberry Pi Zero 2W         | 1 Stk | Zentrale Steuereinheit |
| SD-Karte 32GB (Industrial)   | 1 Stk | Betriebssystem und Daten |
| GPIO-Expander MCP23017       | 2 Stk | Hardware-Interface Erweiterung |
| ADC-Wandler ADS1115          | 1 Stk | Analog-Digital-Konvertierung |
| Relais-Platine 8-Kanal       | 1 Stk | Pumpen-/Ventil-Steuerung |
| Feuchtigkeitssensoren        | 10 Stk| Bodenfeuchte-Überwachung |
| Temperatur-/Luftfeuchte SHT30| 2 Stk | Raumklima-Sensoren |
| Lichtsensoren BH1750         | 3 Stk | Beleuchtungs-Überwachung |
| Gehäuse IP65                 | 1 Stk | Elektronik-Schutz |
| Verkabelung                  | 1 Set | Systemverkabelung |

### 6.4 LED-Beleuchtung

| Komponente                    | Menge    | Beschreibung |
| ----------------------------- | -------- | ------------ |
| LED-Strips Vollspektrum 15W/m| 4 × 1,4m | Pflanzenwachstum-Beleuchtung |
| LED-Netzteil 24V, 150W       | 1 Stk    | Stromversorgung LED-System |
| PWM-Controller                | 1 Stk    | Dimm-/Zeitsteuerung |
| Alu-Profile für LEDs          | 4 Stk    | LED-Montage und Kühlung |

### 6.5 Substrat und Pflanzen

| Komponente                          | Menge   | Beschreibung |
| ----------------------------------- | ------- | ------------ |
| Premium-Zimmerpflanzenerde 40L      | 15 Säcke| Nährstoffreiche Basis |
| Blähton-Drainage 25L                | 3 Säcke | Drainage-Schicht |
| Kokos-Perlite-Mix 50L               | 2 Säcke | Substrat-Verbesserung |
| Flüssigdünger für Zimmerpflanzen    | 4 × 1L  | Langzeit-Nährstoffversorgung |
| Luftreinigende Starter-Pflanzen     | 20 Stk  | NASA Clean Air Study Pflanzen |

### 6.6 Kostenschätzung

**Detaillierte Kostenschätzung siehe separates Dokument:**
📄 [Kostenschätzung Pflanzenwand](kostenschaetzung-pflanzenwand.md)

**Grobe Orientierung:**
- **Gesamtprojektkosten:** ca. 2.500 - 3.500 €
- **Laufende Kosten:** ca. 130 €/Jahr (Strom, Substrat, Pflanzen)

Die genaue Kostenschätzung mit detaillierten Einzelpreisen, Kostenverteilung und verschiedenen Ausstattungsvarianten finden Sie im separaten Kostendokument.

## 7. Installation und Wartung

### 7.1 Schritt-für-Schritt Installationsanleitung

**Phase 1: Vorbereitung (Tag 1)**

1. Wandstatik prüfen (min. 1000 kg Traglast)
2. Stromversorgung 230V verlegen (FI-Schutzschalter!)
3. Wasseranschluss in Nähe planen
4. Werkzeug bereitstellen: Bohrmaschine, Wasserwaage, Multimeter

**Phase 2: Mechanischer Aufbau (Tag 2-3)**

1. Bohrlöcher anzeichnen und bohren (12mm, 120mm tief)
2. **Optional:** Bodenstützen-Positionen markieren und Bodenanker setzen
3. Dübel setzen und Grundrahmen montieren
4. **Optional:** Bodenstützen montieren und höhenjustieren
5. Pflanzfächer einsetzen und ausrichten
6. Drainage-System installieren
7. Reservoir positionieren und anschließen

**🔧 Hinweis bei Bodenstützen:**
- Bodenstützen zuerst grob positionieren
- Wandbefestigung reduziert ausführen (nur 4 statt 8 Dübel bei sicherer Bodenverankerung)
- Höhenverstellung für perfekte Ausrichtung nutzen

**Phase 3: Elektronik (Tag 4)**

1. Kabelkanäle verlegen und Kabel ziehen
2. Raspberry Pi in Gehäuse installieren
3. Sensoren kalibrieren und testen
4. Grundfunktionen der Software testen
5. LED-Beleuchtung installieren und ausrichten

**Phase 4: Bewässerung (Tag 5)**

1. Wasserleitungen verlegen und abdichten
2. Pumpen und Ventile anschließen
3. Dichtigkeitsprüfung (24h Testlauf)
4. Nährstoff-Dosierung kalibrieren
5. Automatik-Zyklen programmieren

**Phase 5: Inbetriebnahme (Tag 6)**

1. Substrat einfüllen
2. System mit Nährlösung füllen
3. pH-Wert einstellen (5.5-6.5)
4. EC-Wert kalibrieren (1.2-1.8 mS/cm)
5. Pflanzen einsetzen
6. 72h Monitoring der Grundfunktionen

### 7.2 Wartungskonzept und -intervalle

**Tägliche Checks (automatisiert):**

- Wasserstand im Reservoir
- pH- und EC-Werte
- Pumpenfunktion
- Sensorwerte-Plausibilität

**Wöchentliche Wartung (5 Min):**

- Sichtkontrolle Pflanzen
- Reservoir nachfüllen
- Nährstoff-Konzentrate prüfen
- System-Logs auswerten

**Monatliche Wartung (30 Min):**

- pH-Sensoren kalibrieren
- Reservoir komplett wechseln
- Filter reinigen
- Düsen und Leitungen spülen
- Software-Updates prüfen

**Vierteljährliche Wartung (2h):**

- Pumpen entkälken
- Vollständige Systemspülung
- Elektronik-Verbindungen prüfen
- LED-Performance testen
- Backup der Konfiguration

**Jährliche Wartung (4h):**

- Substrat teilweise erneuern
- Sensoren-Neukalibrierung
- Mechanical wear inspection
- Dichtungen austauschen
- Komplett-Reinigung System

### 7.3 Troubleshooting-Guide

**Problem: Pflanzen welken trotz Bewässerung**

- Prüfung: pH-Wert (Soll: 5.5-6.5)
- Prüfung: EC-Wert (Soll: 1.2-1.8 mS/cm)
- Prüfung: Wurzelbereich auf Verstopfung
- Lösung: Nährlösung erneuern, Leitungen spülen

**Problem: Ungleichmäßige Bewässerung**

- Prüfung: Alle Ventile funktionsfähig?
- Prüfung: Düsen verstopft?
- Prüfung: Druck in Hauptleitung (min. 0.5 bar)
- Lösung: Düsen reinigen, Ventile austauschen

**Problem: pH-Wert driftet**

- Prüfung: Sensor-Kalibrierung (monatlich)
- Prüfung: Elektroden-Zustand
- Prüfung: Temperatur-Kompensation aktiv?
- Lösung: Sensoren neu kalibrieren oder ersetzen

**Problem: Algenwachstum im System**

- Prüfung: Lichteinfall in Reservoir?
- Prüfung: Nährstoff-Überdosierung?
- Lösung: Reservoir abdecken, UV-Sterilizer nachrüsten

**Problem: Elektronik-Ausfall**

- Prüfung: Stromversorgung stabil?
- Prüfung: Feuchtigkeit in Gehäusen?
- Prüfung: SD-Karte lesbar?
- Lösung: Backup-Image auf neue SD-Karte

## 8. Software-Integration

### 8.1 Software-Architektur und Design Patterns

**Clean Architecture mit Domain-Driven Design:**

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                   │ ← Next.js Frontend
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐
│  │   Dashboard     │  │   API Routes    │  │ Components  │
│  │   (React)       │  │   (Next.js)     │  │  (React)    │
│  └─────────────────┘  └─────────────────┘  └─────────────┘
└─────────────────────────────────────────────────────────┘
              │ HTTP REST API + WebSocket
┌─────────────────────────────────────────────────────────┐
│                 Application Layer (Go)                  │ ← Go Backend
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐
│  │ HTTP Handlers   │  │ WebSocket Hub   │  │   Services  │
│  │ (Gin/Fiber)     │  │ (Gorilla WS)    │  │ (Use Cases) │
│  └─────────────────┘  └─────────────────┘  └─────────────┘
└─────────────────────────────────────────────────────────┘
              │ Interface Adapters
┌─────────────────────────────────────────────────────────┐
│                   Domain Layer (Go)                     │ ← Business Logic
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐
│  │   Entities      │  │  Repositories   │  │ Domain      │
│  │ (PlantModule)   │  │ (Interfaces)    │  │ Services    │
│  └─────────────────┘  └─────────────────┘  └─────────────┘
└─────────────────────────────────────────────────────────┘
              │ Dependency Inversion
┌─────────────────────────────────────────────────────────┐
│              Infrastructure Layer (Go)                  │ ← Hardware/Data
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐
│  │ GPIO Hardware   │  │ SQLite/JSON     │  │   Config    │
│  │ (periph.io)     │  │ (Persistence)   │  │ Management  │
│  └─────────────────┘  └─────────────────┘  └─────────────┘
└─────────────────────────────────────────────────────────┘
```

**Angewendete Design Patterns:**

**Backend (Go):**
- **Repository Pattern:** Abstrahiert Datenzugriff für verschiedene Persistierung
- **Observer Pattern:** Event-driven Automatisierung (Sensor → Bewässerung)
- **Strategy Pattern:** Verschiedene Pflegestrategien je Pflanzentyp
- **Factory Pattern:** Erstellung von Hardware-Komponenten (Sensoren, Aktoren)
- **Command Pattern:** Warteschlangen und Undo-Funktionen für Hardware-Operationen
- **Adapter Pattern:** Hardware-Abstraktion für verschiedene GPIO-Bibliotheken
- **State Pattern:** Pflanzenzustände (Gesund, Trocken, Überwässert, Wartung)
- **CQS Pattern:** Trennung von Commands (ändern State) und Queries (lesen Daten)
- **Dependency Injection:** Lose Kopplung für bessere Testbarkeit

**Frontend (Next.js/React):**
- **Component Composition:** Modulare Dashboard-Komponenten
- **Custom Hooks:** Kapselung von State Management und API-Calls
- **Zustand State Management:** Lightweight Alternative zu Redux
- **Server-Side Rendering:** App Router mit Server Components
- **WebSocket Integration:** Real-Time Updates für Sensor-Daten

### 8.3 Integration in bestehende Architektur

**Erforderliche Erweiterungen:**

**Backend (Go):**
- Hardware-Abstraction-Layer für Sensoren und Bewässerung
- API-Endpunkte für Pflanzenverwaltung und Monitoring
- Event-System für automatisierte Reaktionen
- Datenpersistierung für Sensor-Logs und Konfiguration

**Frontend (Next.js):**
- Dashboard-Komponenten für 20 Pflanzmodule
- Real-Time Datenvisualisierung (Charts, Gauges)
- Steuerelemente für manuelle Bewässerung
- Benachrichtigungssystem für Wartungsalerts

**Kompatibilität:**
Die Erweiterungen bauen vollständig auf der bestehenden Go/Next.js-Architektur auf und erweitern diese um die spezifischen Anforderungen der Raumklima-Pflanzenwand.

---

## Fazit

Dieses Konstruktionskonzept bietet eine vollständig automatisierte Raumklima-Pflanzenwand mit professioneller IoT-Integration. Der modulare Aufbau ermöglicht spätere Erweiterungen und Anpassungen.

**Kernvorteile:**

- ✅ Deutliche Verbesserung der Raumluftqualität  
- ✅ Automatisierte Pflege (95% weniger manueller Aufwand)
- ✅ Skalierbar für größere Installationen
- ✅ Professionelle Sensorüberwachung in Echtzeit
- ✅ Bodenständer-Konstruktion für alle Wandtypen
- ✅ Luftreinigende Pflanzen nach NASA Clean Air Study

**Empfohlene luftreinigende Pflanzen:**

- **Hauptpflanzen:** Bogenhanf, Efeutute, Friedenslilie, Gummibaum
- **Ergänzungen:** Grünlilie, Drachenbaum, Aloe Vera, Bambus-Palme
- **Luftreinigung:** Formaldehyd, Benzol, Ammoniak, Xylol-Filterung
- **Zusatznutzen:** Sauerstoffproduktion, Luftfeuchtigkeit-Regulierung

Das System verbessert messbar das Raumklima und schafft eine beeindruckende, lebendige Atmosphäre bei minimaler Wartung.
