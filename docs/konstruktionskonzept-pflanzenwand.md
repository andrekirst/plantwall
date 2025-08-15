# Konstruktionskonzept: Automatisierte Pflanzenwand

**Projektspezifikationen:**

- Abmessungen: 2,8m (Breite) × 2,3m (Höhe)
- Steuerung: Raspberry Pi Zero 2W
- Automatische Bewässerung und Sensorüberwachung
- Hydroponisches System für optimale Automation

---

## 1. Struktureller Aufbau

### 1.1 Tragkonstruktion und Wandbefestigung

**Hauptrahmen:**

- Material: Aluminium-Profile 40x40mm (Serie 8)
- Begründung: Korrosionsbeständig, leicht, hohe Tragkraft
- Wandbefestigung: 8x M12 Schwerlastdübel (min. 120mm Einbaulänge)
- Wandabstand: 15cm für Kabelführung und Wartungszugang

**🔧 Zusatzoption: Bodenstützen für reduzierte Wandbelastung**

- **Einsatzgebiet:** Bei unsicherer Wandtraglast oder Altbau-Wänden
- **Bodenstützen:** 2x Aluminium-Profile 40x40mm vertikal, höhenverstellbar
- **Vorteile:** Wandbelastung reduziert um 60-70% (von 387kg auf ~120kg)
- **Bodenanker:** 4x M12 Schwerlastanker in Estrich/Beton

**Konstruktionsschema:**

```
Draufsicht Tragkonstruktion:
┌─────────────────────────────────────────────────┐ 2,8m
│ ┌─┐     ┌─┐     ┌─┐     ┌─┐     ┌─┐     ┌─┐ │
│ │█│     │█│     │█│     │█│     │█│     │█│ │ Wandbefestigungspunkte
│ └─┘     └─┘     └─┘     └─┘     └─┘     └─┘ │
│                                             │
│ ┌─┐     ┌─┐     ┌─┐     ┌─┐     ┌─┐     ┌─┐ │
│ │█│     │█│     │█│     │█│     │█│     │█│ │
│ └─┘     └─┘     └─┘     └─┘     └─┘     └─┘ │
└─────────────────────────────────────────────────┘
 ▼                                           ▼
[⚫]  Optionale Bodenstützen                [⚫]  
```

**Seitenansicht mit Bodenstützen:**

```
Wand    ┌─────────────────────────┐ ← Pflanzenwand (2,3m hoch)
 █████  │  ░░░░░░░░░░░░░░░░░░░░░░  │
 █████  │  ░░ Pflanzen ░░░░░░░░░░  │   
 █████  │  ░░░░░░░░░░░░░░░░░░░░░░  │   ┌─ Wandhalterung (reduzierte Last)
 █████  │  ░░░░░░░░░░░░░░░░░░░░░░  │ ──┤
 █████  │  ░░░░░░░░░░░░░░░░░░░░░░  │   └─ Stabilisierung
 █████  └─────────────────────────┘
        │                         │
        │  Bodenstütze            │  Bodenstütze
        ▼  (höhenverstellbar)     ▼  (höhenverstellbar)
      ┌─┴─┐                     ┌─┴─┐
      │⚫⚫│ ← Bodenanker        │⚫⚫│ ← Bodenanker
      └───┘                     └───┘
    Boden/Estrich             Boden/Estrich
```

### 1.2 Materialauswahl mit Begründung

**Tragstruktur:**

- Aluminium-Profile: Gewicht 3,2 kg/m, Tragkraft 2000N/m
- Edelstahl-Verbinder: V4A für Feuchtigkeitsresistenz
- EPDM-Dichtungen: UV-beständig, 15 Jahre Haltbarkeit

**Pflanzfächer:**

- HDPE-Kunststoff: Lebensmittelecht, UV-stabil
- Wandstärke: 3mm für Stabilität bei Vollfüllung

### 1.3 Gewichtsverteilung und Traglast-Berechnungen

**Gewichtsanalyse pro m²:**

- Tragkonstruktion: 15 kg/m²
- Pflanzfächer (gefüllt): 25 kg/m²
- Wasser (gesättigt): 8 kg/m²
- Pflanzen und Substrat: 12 kg/m²
- **Gesamtgewicht: 60 kg/m² = 387 kg total**

**Sicherheitsfaktor:** 2,5
**Erforderliche Wandtraglast:** 968 kg

**🏗️ Mit optionalen Bodenstützen:**
- Wandbelastung reduziert auf: ~120 kg (70% weniger)
- Bodenbelastung: ~270 kg (verteilt auf 4 Ankerpunkte = 67,5 kg/Punkt)
- Geeignet für: Altbau, Gipskarton-Wände, unsichere Wandtragfähigkeit

## 2. Modulares Pflanzensystem

### 2.1 Anzahl und Dimensionen der Pflanzfächer

**Fach-Layout (Grid-System):**

- 7 Fächer horizontal × 6 Fächer vertikal = **42 Pflanzfächer**
- Einzelfach: 35cm (B) × 35cm (H) × 15cm (T)
- Nutzvolumen: 1,84 Liter pro Fach

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

### 2.2 Substratsystem (Hydroponik)

**Gewähltes System: NFT (Nutrient Film Technique)**

- Substrat: Steinwolle-Würfel (10×10×10cm)
- Zusätzlich: Expandierter Blähton als Stützmaterial
- Wurzelraum: Optimiert für schnelles Wachstum und einfache Überwachung

**Vorteile für Automation:**

- Präzise Nährstoffkontrolle
- Reduzierter Wasserbedarf (60% weniger als Erde)
- Keine Schädlinge aus Boden
- Gleichmäßige Bewässerung
- Einfache pH- und EC-Messung

### 2.3 Drainage-System

**Aufbau (von oben nach unten):**

1. Überlauf-Schutz: 5mm über maximaler Füllhöhe
2. Hauptdrainagerohr: DN32 PVC mit 2% Gefälle
3. Sammelrinne: Edelstahl V2A, 50mm breit
4. Rücklauf zum Reservoir: Schwerkraft-gesteuert

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

### 6.6 Gesamtkostenschätzung

**Grundausstattung (reine Wandmontage):**

| Kategorie                           | Kosten         |
| ----------------------------------- | -------------- |
| Strukturelle Komponenten            | 927,00 €       |
| Bewässerungssystem                  | 650,00 €       |
| Elektronik und Sensoren             | 663,00 €       |
| Beleuchtung                         | 398,00 €       |
| Substrat und Pflanzen               | 385,00 €       |
| **Materialkosten gesamt**           | **3.023,00 €** |
| Werkzeug/Verbrauchsmaterial (+5%)   | 151,15 €       |
| Puffer für Unvorhergesehenes (+10%) | 317,42 €       |
| **Gesamtprojektkosten Grundversion** | **3.491,57 €** |

**Mit optionalen Bodenstützen:**

| Zusätzliche Komponente              | Kosten         |
| ----------------------------------- | -------------- |
| Bodenstützen-Set (komplett)         | 150,00 €       |
| **Gesamtprojektkosten mit Bodenstützen** | **3.641,57 €** |

_Alle Preise inkl. MwSt., Stand 2024. Arbeitszeit nicht eingerechnet._

**💡 Empfehlung:** Bei unsicherer Wandtragfähigkeit die Bodenstützen-Option wählen (+150€ für deutlich mehr Sicherheit und Flexibilität bei der Wandauswahl).

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

### 8.1 Anbindung an bestehende Go/Next.js Architektur

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
