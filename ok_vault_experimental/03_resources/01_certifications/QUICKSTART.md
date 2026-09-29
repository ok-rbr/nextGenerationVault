# Zertifizierungs-System Schnellstart

> [!tip] Quick Start Guide
> Diese Anleitung hilft Ihnen, in 5 Minuten mit dem Zertifizierungs-Lernsystem zu starten.

## 🚀 In 5 Minuten starten

### Schritt 1: Template auswählen (1 Min)

Öffnen Sie die Command Palette (Ctrl/Cmd + P) und wählen Sie:
```
Templater: Insert Template
```

Dann wählen Sie eines dieser Templates:
- `cert_overview.md` - Starten Sie hier für eine neue Zertifizierung
- `cert_study_note.md` - Für Studiennotizen zu Modulen/Themen
- `cert_practice_exam.md` - Nach einer Übungsprüfung
- `cert_knowledge_extraction.md` - Um Wissen zu extrahieren

### Schritt 2: Informationen eingeben (2 Min)

Das Template fragt Sie nach:

**Für cert_overview.md**:
- Zertifizierungs-ID (z.B., AZ-900)
- Vollständiger Name
- Provider (Microsoft, AWS, etc.)
- Level (fundamentals, associate, expert)
- Zieldatum
- Priorität

**Für cert_study_note.md**:
- Thema/Modul-Name
- Zertifizierungs-ID
- Modul-Nummer (optional)
- Priorität

### Schritt 3: Automatische Organisation (1 Min)

Das Template:
- ✅ Benennt die Datei automatisch um
- ✅ Verschiebt sie in den richtigen Ordner
- ✅ Erstellt Frontmatter mit Metadaten
- ✅ Fügt Dataview-Queries ein

### Schritt 4: Ausfüllen und Lernen (1 Min Setup)

Füllen Sie die vorgefertigten Sektionen aus:
- Lernziele definieren
- Ressourcen verlinken
- Notizen machen

---

## 📋 Beispiel-Workflow: Microsoft AZ-900

### Tag 1: Setup (10 Minuten)

1. **Zertifizierung anlegen**
   ```
   Template: cert_overview.md
   ID: AZ-900
   Name: Microsoft Azure Fundamentals
   Provider: Microsoft
   Level: fundamentals
   Zieldatum: In 3 Monaten
   ```

2. **Ressourcen sammeln**
   - Link zu Microsoft Learn einfügen
   - Udemy-Kurs verlinken
   - Übungsprüfungen notieren

3. **Studienplan erstellen**
   - Wöchentliche Ziele definieren
   - Geschätzte Zeit: 40 Stunden

### Woche 1-4: Studieren (4-6 Stunden/Woche)

**Für jedes Modul**:
1. Template `cert_study_note.md` nutzen
2. Modul durcharbeiten
3. Notizen in eigenen Worten
4. Hands-on Labs dokumentieren
5. Beispiel-Fragen notieren

**Beispiel-Studiennotizen**:
- AZ-900: Cloud Concepts
- AZ-900: Azure Architecture
- AZ-900: Compute Services
- AZ-900: Storage Services
- ...

### Woche 5: Übungsprüfungen (2-3 Stunden)

1. **Erste Übungsprüfung**
   ```
   Template: cert_practice_exam.md
   Source: Microsoft Learn
   ```

2. **Analyse**
   - Score notieren
   - Falsche Fragen durchgehen
   - Schwache Bereiche identifizieren

3. **Nacharbeit**
   - Schwache Themen nochmal studieren
   - Studiennotizen aktualisieren

4. **Zweite Übungsprüfung**
   - Verbesserung prüfen
   - Bis >80% Score

### Woche 6: Prüfung & Wissensextraktion

1. **Prüfung ablegen**
   - Termin vereinbaren
   - Prüfung durchführen
   - Ergebnis im Overview dokumentieren

2. **Wissen extrahieren**
   ```
   Template: cert_knowledge_extraction.md
   ```
   
   Wichtige Konzepte in Knowledge Base überführen:
   - Infrastructure as Code
   - Cloud Cost Optimization
   - Identity Management
   - High Availability Patterns
   - ...

---

## 📊 Dashboard nutzen

### Alle Zertifizierungen sehen

Öffnen Sie: `03_resources/01_certifications/00_index.md`

Hier sehen Sie:
- ✅ Aktive Zertifizierungen
- 📈 Fortschritt
- 📝 Studiennotizen
- 📊 Übungsprüfungs-Ergebnisse
- 🧠 Extrahiertes Wissen

### Microsoft-spezifisch

Öffnen Sie: `03_resources/01_certifications/microsoft/00_index.md`

Für Microsoft-spezifische Übersichten und Ressourcen.

---

## 💡 Pro-Tipps

### 1. Konsistenz ist key
- **Täglich 30-60 Minuten** ist besser als einmal wöchentlich 5 Stunden
- Nutzen Sie Daily Notes um Lernfortschritt zu tracken

### 2. Aktives Lernen
- Schreiben Sie in eigenen Worten
- Erstellen Sie Beispiele
- Erklären Sie Konzepte anderen

### 3. Hands-on Practice
- Nutzen Sie Azure Free Account
- Machen Sie alle Labs
- Experimentieren Sie selbst

### 4. Übungsprüfungen
- Minimum 3 Übungsprüfungen vor der echten Prüfung
- Analysieren Sie jede falsche Antwort
- Ziel: Konsistent >80% Score

### 5. Wissensextraktion
- Extrahieren Sie während des Lernens
- Nicht erst am Ende
- Fokus auf allgemein anwendbare Konzepte

---

## 🔗 Nächste Schritte

1. **Jetzt starten**: Öffnen Sie die Command Palette und erstellen Sie Ihre erste Zertifizierungs-Overview
2. **Beispiel ansehen**: Schauen Sie sich `EXAMPLE_microsoft_az-900.md` an
3. **Dokumentation lesen**: Für Details siehe `README_CERTIFICATIONS.md`
4. **Community beitreten**: Suchen Sie nach Study Groups für Ihre Zertifizierung

---

## ❓ Häufige Fragen

**Q: Welche Zertifizierung soll ich zuerst machen?**
A: Für Azure: Starten Sie mit AZ-900 (Azure Fundamentals)

**Q: Wie lange brauche ich für eine Fundamentals-Zertifizierung?**
A: Typisch 20-40 Stunden Lernzeit, verteilt über 4-8 Wochen

**Q: Muss ich alle Sektionen ausfüllen?**
A: Nein, passen Sie die Templates an Ihre Bedürfnisse an

**Q: Kann ich das System für andere Provider nutzen?**
A: Ja! Einfach neuen Provider-Ordner erstellen (z.B., aws/, google/)

**Q: Was ist der Unterschied zwischen Study Note und Knowledge Extraction?**
A: Study Notes sind zertifizierungsspezifisch, Knowledge Extraction überführt allgemein anwendbares Wissen in die permanente Knowledge Base

---

## 📚 Weitere Ressourcen

- [[README_CERTIFICATIONS]] - Vollständige Dokumentation
- [[00_index]] - Alle Zertifizierungen Dashboard
- [[microsoft/00_index]] - Microsoft Zertifizierungen
- [[../../00_knowledge/00_index|Knowledge Base]] - Extrahiertes Wissen

---

**Viel Erfolg bei Ihrer Zertifizierung! 🎓**
