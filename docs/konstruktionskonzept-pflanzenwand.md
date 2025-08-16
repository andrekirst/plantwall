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

## 6. Materialliste mit Kostenschätzung

### 6.1 Strukturelle Komponenten

| Komponente                 | Menge  | Einzelpreis | Gesamtpreis  |
| -------------------------- | ------ | ----------- | ------------ |
| Alu-Profile 40x40mm (6m)   | 8 Stk  | 25,00 €     | 200,00 €     |
| Alu-Verbinder              | 24 Stk | 3,50 €      | 84,00 €      |
| Schwerlastdübel M12        | 8 Stk  | 8,00 €      | 64,00 €      |
| HDPE-Pflanzfächer          | 42 Stk | 12,00 €     | 504,00 €     |
| Montage-Material           | 1 Set  | 75,00 €     | 75,00 €      |
| **Struktur Zwischensumme** |        |             | **927,00 €** |

### 6.1a Optionale Bodenstützen (Zusatzausstattung)

| Komponente                    | Menge  | Einzelpreis | Gesamtpreis  |
| ----------------------------- | ------ | ----------- | ------------ |
| Alu-Profile 40x40mm (2,3m)    | 2 Stk  | 20,00 €     | 40,00 €      |
| Höhenverstellbare Füße M12    | 2 Stk  | 15,00 €     | 30,00 €      |
| Bodenanker M12 (120mm)        | 4 Stk  | 12,00 €     | 48,00 €      |
| Verstärkungsverbinder         | 4 Stk  | 8,00 €      | 32,00 €      |
| **Bodenstützen Zwischensumme** |       |             | **150,00 €** |

### 6.2 Bewässerungssystem

| Komponente                    | Menge   | Einzelpreis | Gesamtpreis  |
| ----------------------------- | ------- | ----------- | ------------ |
| Tauchpumpe 12V, 800L/h        | 2 Stk   | 45,00 €     | 90,00 €      |
| Magnetventile 12V             | 7 Stk   | 25,00 €     | 175,00 €     |
| PE-Rohr 20mm (50m)            | 1 Rolle | 65,00 €     | 65,00 €      |
| Mikro-Schläuche 6mm (100m)    | 1 Rolle | 35,00 €     | 35,00 €      |
| Reservoir 100L + Deckel       | 1 Stk   | 85,00 €     | 85,00 €      |
| Dosier-Pumpen (Set)           | 1 Set   | 120,00 €    | 120,00 €     |
| Fittings/Verbinder            | 1 Set   | 80,00 €     | 80,00 €      |
| **Bewässerung Zwischensumme** |         |             | **650,00 €** |

### 6.3 Elektronik und Sensoren

| Komponente                   | Menge | Einzelpreis | Gesamtpreis  |
| ---------------------------- | ----- | ----------- | ------------ |
| Raspberry Pi Zero 2W         | 1 Stk | 18,00 €     | 18,00 €      |
| SD-Karte 32GB (Industrial)   | 1 Stk | 25,00 €     | 25,00 €      |
| GPIO-Expander MCP23017       | 2 Stk | 8,00 €      | 16,00 €      |
| ADC-Wandler ADS1115          | 1 Stk | 12,00 €     | 12,00 €      |
| Relais-Platine 8-Kanal       | 1 Stk | 28,00 €     | 28,00 €      |
| pH-Sensoren                  | 3 Stk | 65,00 €     | 195,00 €     |
| EC-Sensoren                  | 3 Stk | 45,00 €     | 135,00 €     |
| Feuchtigkeit-Sensoren SHT30  | 3 Stk | 15,00 €     | 45,00 €      |
| Lichtsensoren BH1750         | 3 Stk | 8,00 €      | 24,00 €      |
| Gehäuse IP65                 | 1 Stk | 45,00 €     | 45,00 €      |
| Verkabelung                  | 1 Set | 120,00 €    | 120,00 €     |
| **Elektronik Zwischensumme** |       |             | **663,00 €** |

### 6.4 Beleuchtung

| Komponente                    | Menge    | Einzelpreis | Gesamtpreis  |
| ----------------------------- | -------- | ----------- | ------------ |
| LED-Strips Vollspektrum 20W/m | 6 × 1,2m | 35,00 €     | 210,00 €     |
| LED-Netzteil 24V, 200W        | 1 Stk    | 55,00 €     | 55,00 €      |
| PWM-Controller                | 1 Stk    | 25,00 €     | 25,00 €      |
| Alu-Profile für LEDs          | 6 Stk    | 18,00 €     | 108,00 €     |
| **Beleuchtung Zwischensumme** |          |             | **398,00 €** |

### 6.5 Substrat und Pflanzen

| Komponente                          | Menge   | Einzelpreis | Gesamtpreis  |
| ----------------------------------- | ------- | ----------- | ------------ |
| Steinwolle-Würfel 10cm³             | 50 Stk  | 1,20 €      | 60,00 €      |
| Blähton 25L                         | 3 Säcke | 12,00 €     | 36,00 €      |
| Nährstoff-Konzentrat A+B            | 2 × 5L  | 35,00 €     | 70,00 €      |
| pH-Regulierer                       | 2 × 1L  | 15,00 €     | 30,00 €      |
| Starter-Pflanzen                    | 42 Stk  | 4,50 €      | 189,00 €     |
| **Substrat/Pflanzen Zwischensumme** |         |             | **385,00 €** |

### 6.6 Kostenschätzung (vereinfacht)

**Gesamtprojektkosten für Raumklima-Pflanzenwand:**

- **Material und Komponenten:** ca. 2.500 - 3.500 €
- **Funktionsumfang:** Automatische Bewässerung, IoT-Sensorik, LED-Beleuchtung
- **Preisrange begründet:** Je nach Ausstattungsgrad und Komponentenqualität

**Kostenverteilung grob:**
- Bodenständer-Konstruktion: ~800 €
- Bewässerung & Elektronik: ~1.200 €  
- Pflanzmodule & Substrat: ~600 €
- LED-Beleuchtung: ~400 €
- Puffer und Montage: ~500 €

_Preise inkl. MwSt., ohne Arbeitszeit_

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

**1. Repository Pattern (Data Access):**
```go
// Domain Interface (interface/repository.go)
type PlantModuleRepository interface {
    GetAll() ([]*PlantModule, error)
    GetByID(id string) (*PlantModule, error)
    Update(module *PlantModule) error
    GetSensorData(moduleID string, timeframe time.Duration) ([]*SensorReading, error)
}

// Infrastructure Implementation (infrastructure/sqlite_repo.go)
type SQLitePlantModuleRepo struct {
    db *sql.DB
}

func (r *SQLitePlantModuleRepo) GetByID(id string) (*PlantModule, error) {
    // SQL implementation
}
```

**2. Observer Pattern (Event-Driven Architecture):**
```go
// Domain Events (domain/events.go)
type EventBus struct {
    subscribers map[string][]chan Event
    mutex       sync.RWMutex
}

type SensorEvent struct {
    ModuleID  string
    Sensor    string
    Value     float64
    Timestamp time.Time
}

// Auto-triggering irrigation based on sensor events
func (s *IrrigationService) OnMoistureChanged(event SensorEvent) {
    if event.Value < s.threshold {
        s.TriggerWatering(event.ModuleID)
    }
}
```

**3. Strategy Pattern (Plant Care Strategies):**
```go
// Different care strategies per plant type
type CareStrategy interface {
    GetWateringSchedule(plant *PlantModule) Schedule
    GetOptimalMoisture() (min, max float64)
    GetLightRequirements() LightSpec
}

type SansevieriaStrategy struct{}  // Drought-resistant
type FicusStrategy struct{}        // Regular watering
type SpathiphyllumStrategy struct{} // High humidity
```

**4. Factory Pattern (Sensor & Hardware Creation):**
```go
type HardwareFactory interface {
    CreateSensor(sensorType string, config SensorConfig) (Sensor, error)
    CreateActuator(actuatorType string, config ActuatorConfig) (Actuator, error)
}

func (f *DefaultHardwareFactory) CreateSensor(sensorType string, config SensorConfig) (Sensor, error) {
    switch sensorType {
    case "moisture":
        return NewMoistureSensor(config.Pin), nil
    case "ph":
        return NewPHSensor(config.Pin, config.CalibrationData), nil
    default:
        return nil, fmt.Errorf("unknown sensor type: %s", sensorType)
    }
}
```

**5. Command Pattern (Hardware Operations):**
```go
type Command interface {
    Execute() error
    Undo() error
    GetDescription() string
}

type WaterModuleCommand struct {
    moduleID string
    duration time.Duration
    pump     PumpController
}

type CommandQueue struct {
    commands []Command
    history  []Command
}

// Allows for queuing, logging, and undo of hardware operations
```

**6. Adapter Pattern (Hardware Abstraction):**
```go
// Adapts different GPIO libraries to common interface
type GPIOAdapter interface {
    SetPin(pin int, state bool) error
    ReadPin(pin int) (bool, error)
}

type PeriphGPIOAdapter struct{}    // Uses periph.io
type RPIOGPIOAdapter struct{}      // Uses rpio library
type MockGPIOAdapter struct{}      // For testing

// Strategy Pattern for GPIO selection
type GPIOFactory struct {
    adapters map[string]GPIOAdapter
}
```

**7. State Pattern (Plant Module States):**
```go
type PlantModuleState interface {
    Water(module *PlantModule) error
    GetStatus() string
    CanTransitionTo(newState PlantModuleState) bool
}

type HealthyState struct{}
type DroughtStressState struct{}
type OverwateredState struct{}
type MaintenanceState struct{}
```

**8. CQS Pattern (Command Query Separation):**
```go
// Commands - change state, return error only
func (s *PlantService) WaterModule(moduleID string, duration time.Duration) error {
    module, err := s.repo.GetByID(moduleID)
    if err != nil {
        return err
    }
    
    // Execute watering command
    err = s.irrigationController.Water(moduleID, duration)
    if err != nil {
        return err
    }
    
    // Update state
    module.LastWatered = time.Now()
    return s.repo.Update(module)
}

// Queries - return data, never change state  
func (s *PlantService) GetModuleStatus(moduleID string) (*PlantModule, error) {
    return s.repo.GetByID(moduleID)
}

func (s *PlantService) GetSensorReadings(moduleID string, since time.Time) ([]*SensorReading, error) {
    return s.repo.GetSensorData(moduleID, since)
}
```

**9. Dependency Injection Container:**
```go
type Container struct {
    services map[string]interface{}
}

func (c *Container) Register(name string, factory func(*Container) interface{}) {
    c.services[name] = factory(c)
}

func NewContainer() *Container {
    container := &Container{services: make(map[string]interface{})}
    
    // Register dependencies
    container.Register("gpio", func(c *Container) interface{} {
        return NewPeriphGPIOAdapter()
    })
    
    container.Register("plantRepo", func(c *Container) interface{} {
        return NewSQLitePlantRepo(c.Get("db"))
    })
    
    return container
}
```

### 8.2 Frontend Architecture Patterns (Next.js/React)

**1. Component Composition Pattern:**
```tsx
// Composable dashboard components
export function PlantWallDashboard() {
  return (
    <DashboardLayout>
      <PlantModuleGrid>
        {modules.map(module => (
          <PlantModuleCard key={module.id} module={module}>
            <SensorReadings sensors={module.sensors} />
            <IrrigationControls moduleId={module.id} />
            <PlantStatus status={module.status} />
          </PlantModuleCard>
        ))}
      </PlantModuleGrid>
      <SystemOverview />
    </DashboardLayout>
  )
}
```

**2. Custom Hooks Pattern (Data Management):**
```tsx
// Custom hooks for state management
function usePlantModules() {
  const [modules, setModules] = useState<PlantModule[]>([])
  const [loading, setLoading] = useState(true)
  
  useEffect(() => {
    // WebSocket connection for real-time updates
    const ws = new WebSocket('ws://localhost:5000/ws')
    ws.onmessage = (event) => {
      const update = JSON.parse(event.data)
      setModules(prev => updateModule(prev, update))
    }
    
    return () => ws.close()
  }, [])
  
  return { modules, loading, waterModule, updateSettings }
}

function useSensorData(moduleId: string) {
  const [data, setData] = useState<SensorReading[]>([])
  
  useEffect(() => {
    const interval = setInterval(async () => {
      const readings = await api.getSensorData(moduleId)
      setData(readings)
    }, 5000)
    
    return () => clearInterval(interval)
  }, [moduleId])
  
  return { data, isStale: Date.now() - data[0]?.timestamp > 30000 }
}
```

**3. State Management with Zustand (Lightweight Redux Alternative):**
```tsx
// Global state management
import { create } from 'zustand'

interface PlantWallStore {
  modules: PlantModule[]
  systemStatus: SystemStatus
  alerts: Alert[]
  
  // Actions
  updateModule: (id: string, update: Partial<PlantModule>) => void
  triggerWatering: (moduleId: string, duration: number) => Promise<void>
  dismissAlert: (alertId: string) => void
}

export const usePlantWallStore = create<PlantWallStore>((set, get) => ({
  modules: [],
  systemStatus: 'healthy',
  alerts: [],
  
  updateModule: (id, update) => 
    set(state => ({
      modules: state.modules.map(m => 
        m.id === id ? { ...m, ...update } : m
      )
    })),
    
  triggerWatering: async (moduleId, duration) => {
    await api.waterModule(moduleId, duration)
    // State will be updated via WebSocket
  },
}))
```

**4. Server-Side Rendering with Data Fetching:**
```tsx
// Next.js App Router with Server Components
export default async function PlantWallPage() {
  // Server-side data fetching
  const initialData = await getPlantModules()
  
  return (
    <PlantWallDashboard initialData={initialData}>
      <Suspense fallback={<LoadingSkeleton />}>
        <RealTimeUpdates />
      </Suspense>
    </PlantWallDashboard>
  )
}

// API Route Handler
export async function GET(request: Request) {
  const modules = await plantService.getAllModules()
  return Response.json(modules)
}

export async function POST(request: Request) {
  const command = await request.json()
  await commandHandler.handle(command)
  return Response.json({ success: true })
}
```

### 8.3 Anbindung an bestehende Go/Next.js Architektur

**Neue Go-Packages erforderlich:**

```go
// Erweiterung der Hardware-Abstraction-Layer
src/plant-wall-control/hardware/
├── sensors/
│   ├── ph_sensor.go         // pH-Wert Messung
│   ├── ec_sensor.go         // Leitfähigkeit
│   ├── moisture_sensor.go   // Bodenfeuchtigkeit
│   └── environment.go       // Temp/Humidity/Light
├── irrigation/
│   ├── pump_control.go      // Pumpen-Steuerung
│   ├── valve_control.go     // Ventil-Management
│   └── dosing_system.go     // Nährstoff-Dosierung
└── monitoring/
    ├── data_logger.go       // Sensor-Datensammlung
    ├── alerts.go           // Alarm-System
    └── automation.go       // Bewässerungs-Automatik
```

**Integration in bestehende main.go:**

```go
func main() {
    // Bestehende Initialisierung...

    // Neue Hardware-Module
    sensorManager := sensors.NewManager()
    irrigationController := irrigation.NewController()
    monitoringSystem := monitoring.NewSystem()

    // API-Routen erweitern
    router.HandleFunc("/api/sensors", handleSensors)
    router.HandleFunc("/api/irrigation", handleIrrigation)
    router.HandleFunc("/api/monitoring", handleMonitoring)
    router.HandleFunc("/api/plants/{id}", handlePlantControl)
}
```

### 8.2 Hardware-Abstraction-Layer Erweiterungen

**Sensor-Interface (sensors/interface.go):**

```go
type SensorManager interface {
    ReadPH(zone int) (float64, error)
    ReadEC(zone int) (float64, error)
    ReadMoisture(zone int) (float64, error)
    ReadEnvironment(zone int) (EnvData, error)
    CalibrateAllSensors() error
}

type EnvData struct {
    Temperature float64 `json:"temperature"`
    Humidity    float64 `json:"humidity"`
    LightLevel  float64 `json:"lightLevel"`
    Timestamp   time.Time `json:"timestamp"`
}
```

**Irrigation-Interface (irrigation/interface.go):**

```go
type IrrigationController interface {
    StartWatering(zones []int, duration time.Duration) error
    StopWatering(zones []int) error
    SetNutrientConcentration(ecTarget float64) error
    GetSystemStatus() IrrigationStatus
    ScheduleWatering(schedule WateringSchedule) error
}

type WateringSchedule struct {
    Zones       []int     `json:"zones"`
    StartTime   time.Time `json:"startTime"`
    Duration    time.Duration `json:"duration"`
    Frequency   time.Duration `json:"frequency"`
    NutrientEC  float64   `json:"nutrientEC"`
}
```

### 8.3 API-Endpunkte für neue Hardware-Komponenten

**Neue REST-Endpunkte:**

**Sensor-Daten:**

```
GET  /api/sensors                    // Alle aktuellen Sensorwerte
GET  /api/sensors/{zone}             // Spezifische Zone
GET  /api/sensors/history/{hours}    // Historische Daten
POST /api/sensors/calibrate          // Sensor-Kalibrierung
```

**Bewässerungs-Steuerung:**

```
GET  /api/irrigation/status          // Aktueller Bewässerungs-Status
POST /api/irrigation/start           // Manuell starten
POST /api/irrigation/stop            // Stoppen
GET  /api/irrigation/schedule        // Zeitpläne abrufen
POST /api/irrigation/schedule        // Neuen Zeitplan erstellen
```

**Pflanzen-Management:**

```
GET  /api/plants                     // Alle Pflanzen-Status
GET  /api/plants/{id}                // Einzelne Pflanze
POST /api/plants/{id}/water          // Gezielt bewässern
POST /api/plants/{id}/light          // Beleuchtung anpassen
```

**Frontend-Integration (React-Komponenten):**

**Neue Komponenten erforderlich:**

```typescript
// src/components/PlantWall/
├── SensorDashboard.tsx      // Echtzeit-Sensorwerte
├── IrrigationControl.tsx    // Bewässerungs-Interface
├── PlantGrid.tsx           // 42-Fächer Übersicht
├── ZoneManager.tsx         // 3-Zonen Verwaltung
├── ScheduleEditor.tsx      // Zeitplan-Editor
└── AlertsPanel.tsx         // Alarm-Anzeige
```

**Datenstrukturen (types/plantwall.ts):**

```typescript
interface PlantWallStatus {
  zones: ZoneStatus[];
  irrigation: IrrigationStatus;
  alerts: Alert[];
  systemHealth: HealthStatus;
}

interface ZoneStatus {
  id: number;
  plants: PlantStatus[];
  sensors: SensorReading[];
  lastWatered: Date;
  nextWatering: Date;
}

interface PlantStatus {
  id: number;
  position: { row: number; col: number };
  species: string;
  health: "excellent" | "good" | "warning" | "critical";
  daysSincePlanted: number;
  moisture: number;
  nutrients: number;
}
```

**API-Client Erweiterung (utils/api.ts):**

```typescript
export const plantWallAPI = {
  // Sensor-Daten
  getSensorData: () => api.get<SensorReading[]>("/sensors"),
  getSensorHistory: (hours: number) =>
    api.get<SensorReading[]>(`/sensors/history/${hours}`),

  // Bewässerung
  getIrrigationStatus: () => api.get<IrrigationStatus>("/irrigation/status"),
  startWatering: (zones: number[], duration: number) =>
    api.post("/irrigation/start", { zones, duration }),

  // Pflanzen
  getPlants: () => api.get<PlantStatus[]>("/plants"),
  waterPlant: (plantId: number, amount: number) =>
    api.post(`/plants/${plantId}/water`, { amount }),
};
```

---

## Fazit

Dieses Konstruktionskonzept bietet eine vollständig automatisierte, skalierbare Pflanzenwand-Lösung mit professioneller IoT-Integration. Der modulare Aufbau ermöglicht spätere Erweiterungen und Anpassungen.

**Kernvorteile:**

- ✅ Vollautomatisierte Pflege (95% weniger manueller Aufwand)
- ✅ Skalierbar für größere Installationen
- ✅ Professionelle Sensorüberwachung in Echtzeit
- ✅ Integration in bestehende Smart-Home-Systeme
- ✅ Niedrige Betriebskosten (30€/Jahr Strom + Nährstoffe)
- ✅ ROI durch höhere Erträge und Zeitersparnis

**Empfohlene Pflanzenarten für Hydroponik:**

- Salate: Kopfsalat, Rucola, Feldsalat
- Kräuter: Basilikum, Petersilie, Schnittlauch, Thymian
- Gemüse: Cherry-Tomaten, Paprika, Gurken (Mini)
- Grünfutter: Spinat, Mangold, Pak Choi

Die Gesamtinvestition von ca. 3.500€ amortisiert sich über 2-3 Jahre durch Einsparungen bei Lebensmitteleinkäufen und den Mehrwert einer automatisierten Anlage.
