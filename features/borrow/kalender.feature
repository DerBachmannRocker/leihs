# language: de

Funktionalität: Kalender

  Um einen Gegenstand einer Bestellung hinzuzufügen
  möchte ich als Ausleihender
  den Gegenstand der Bestellung hinzufügen können

  @javascript
  Szenario: Kalenderkomponenten
    Angenommen man ist "Normin"
    Wenn man einen Gegenstand aus der Modellliste hinzufügt
    Dann öffnet sich der Kalender
    Und der Kalender beinhaltet die folgenden Komponenten
    |Modellname                       |
    |Aktueller Monat                  |
    |Kalender                         |
    |Geräteparkauswahl                |
    |Startdatumfeld                   |
    |Enddatumfeld                     |
    |Anzahlfeld                       |
    |Artikel hinzufügen Schaltfläche  |
    |Abbrechen Schaltfläche           |

  @javascript
  Szenario: Kalender Grundeinstellung
    Angenommen man ist "Normin"
    Wenn man einen Gegenstand aus der Modellliste hinzufügt
    Dann öffnet sich der Kalender
    Und das aktuelle Startdatum ist heute
    Und das Enddatum ist morgen
    Und die Anzahl ist 1
    Und es sind alle Geräteparks angezeigt die Gegenstände von dem Modell haben

  @javascript
  Szenario: Kalender Grundeinstellung wenn Zeitspanne bereits ausgewählt
    Angenommen man ist "Normin"
    Und man befindet sich auf der Modellliste
    Und man hat eine Zeitspanne ausgewählt
    Wenn man einen in der Zeitspanne verfügbaren Gegenstand aus der Modellliste hinzufügt
    Dann öffnet sich der Kalender
    Und das Startdatum entspricht dem vorausgewählten Startdatum
    Und das Enddatum entspricht dem vorausgewählten Enddatum

  @javascript
  Szenario: Kalender Grundeinstellung wenn Geräteparks bereits ausgewählt sind
    Angenommen man ist "Normin"
    Und man befindet sich auf der Modellliste
    Und man die Geräteparks begrenzt
    Und man ein Modell welches über alle Geräteparks der begrenzten Liste beziehbar ist zur Bestellung hinzufügt
    Dann öffnet sich der Kalender
    Und es wird der alphabetisch erste Gerätepark ausgewählt der teil der begrenzten Geräteparks ist

  @javascript
  Szenario: Kalender Verfügbarkeitsanzeige
    Angenommen man ist "Normin"
    Und es existiert ein Modell für das eine Bestellung vorhanden ist
    Wenn man dieses Modell aus der Modellliste hinzufügt
    Dann öffnet sich der Kalender
    Und wird die Verfügbarkeit des Modells im Kalendar angezeigt
    
  @javascript
  Szenario: Kalender Verfügbarkeitsanzeige nach Änderung der Kalenderdaten
    Angenommen man ist "Normin"
    Und es existiert ein Modell für das eine Bestellung vorhanden ist
    Wenn man dieses Modell aus der Modellliste hinzufügt
    Dann öffnet sich der Kalender
    Wenn man ein Start und Enddatum ändert
    Dann wird die Verfügbarkeit des Gegenstandes aktualisiert
    Wenn man die Anzahl ändert
    Dann wird die Verfügbarkeit des Gegenstandes aktualisiert
    
  @javascript
  Szenario: Kalender max. Verfügbarkeit
    Angenommen man ist "Normin"
    Und man hat den Buchungskalender geöffnet
    Dann wird die maximal ausleihbare Anzahl des ausgewählten Modells angezeigt
    Und man kann maximal die maximal ausleihbare Anzahl eingeben

  @javascript
  Szenario: Auswählbare Geräteparks im Kalender
    Angenommen man ist "Normin"
    Und man hat den Buchungskalender geöffnet
    Dann sind nur diejenigen Geräteparks auswählbar, welche über Kapizäteten für das ausgewählte Modell verfügen
    Und die Geräteparks sind alphabetisch sortiert
    
  @javascript
  Szenario: Kalender Anzeige der Schliesstage
    Angenommen man ist "Normin"
    Und man hat den Buchungskalender geöffnet
    Dann werden die Schliesstage gemäss gewähltem Gerätepark angezeigt
    
  @javascript
  Szenario: Kalender zwischen Monaten hin und herspringen
    Angenommen man ist "Normin"
    Und man hat den Buchungskalender geöffnet
    Wenn man zwischen den Monaten hin und herspring
    Dann wird der Kalender gemäss aktuell gewähltem Monat angezeigt
    
  @javascript
  Szenario: Kalender Sprung zu Start und Enddatum
    Angenommen man ist "Normin"
    Und man hat den Buchungskalender geöffnet
    Wenn man anhand der Sprungtaste zum aktuellen Startdatum springt
    Dann wird das Startdatum im Kalender angezeigt
    Wenn man anhand der Sprungtaste zum aktuellen Enddatum springt
    Dann wird das Enddatum im Kalender angezeigt
    
  @javascript
  Szenario: Meiner Bestellung einen Gegenstand hinzufügen
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Und man auf einem Model "Zur Bestellung hinzufügen" wählt
    Dann öffnet sich der Kalender
    Wenn alle Angaben die ich im Kalender mache gültig sind
    Dann ist das Modell mit Start- und Enddatum, Anzahl und Gerätepark der Bestellung hinzugefügt worden

  @javascript
  Szenario: Kalender Bestellung nicht möglich, wenn Auswahl nicht verfügbar
    Angenommen man ist "Normin"
    Wenn man versucht ein Modell zur Bestellung hinzufügen, welches nicht verfügbar ist
    Dann schlägt der Versuch es hinzufügen fehl
    Und ich sehe die Fehlermeldung, dass das ausgewählte Modell im ausgewählten Zeitraum nicht verfügbar ist

  @javascript
  Szenario: Bestellkalender schliessen
    Angenommen man ist "Normin"
    Wenn man sich auf der Modellliste befindet
    Und man auf einem Model "Zur Bestellung hinzufügen" wählt
    Dann öffnet sich der Kalender
    Wenn ich den Kalender schliesse
    Dann schliesst das Dialogfenster

  @javascript
  Szenario: Bestellkalender nutzen nach dem man alle Filter zurückgesetzt hat
    Angenommen man ist "Normin"
    Wenn ich ein Modell der Bestellung hinzufüge
    Und man sich auf der Modellliste befindet
    Und man den zweiten Gerätepark in der Geräteparkauswahl auswählt
    Wenn man "Alles zurücksetzen" wählt
    Und man auf einem Model "Zur Bestellung hinzufügen" wählt
    Dann öffnet sich der Kalender
    Wenn alle Angaben die ich im Kalender mache gültig sind
    Dann lässt sich das Modell mit Start- und Enddatum, Anzahl und Gerätepark der Bestellung hinzugefügen

  @javascript
  Szenario: Etwas bestellen, was nur Gruppen vorbehalten ist
    Angenommen man ist "Normin"
    Wenn ein Modell existiert, welches nur einer Gruppe vorbehalten ist
    Dann kann ich dieses Modell ausleihen, wenn ich in dieser Gruppe bin