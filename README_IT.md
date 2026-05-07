# Pixel Fury Arena

Un videogioco multiplayer 2D in Flutter simile a Brawl Stars, con interfaccia grafica basata su SVG.

## 🎮 Caratteristiche

- **Multiplayer in tempo reale**: Gioca con altri giocatori online tramite WebSocket
- **Grafica SVG**: Asset grafici scalabili e leggeri
- **Controlli touch**: Joystick virtuale per il movimento e mira touch-and-shoot
- **Sistema di combattimento**: Proiettili, collisioni e sistema di salute
- **HUD completo**: Barra della salute, punteggio, timer di gioco
- **Architettura pulita**: Separazione tra modelli, provider, schermate e widget

## 📁 Struttura del Progetto

```
lib/
├── main.dart                    # Punto di ingresso dell'app
├── models/
│   └── game_models.dart         # Modelli dati (Player, Projectile, Vector2D)
├── providers/
│   └── game_provider.dart       # Gestione stato del gioco
├── screens/
│   ├── lobby_screen.dart        # Schermata iniziale e login
│   └── game_screen.dart         # Schermata di gioco principale
├── services/
│   └── network_service.dart     # Comunicazione WebSocket
├── widgets/
│   ├── player_widget.dart       # Widget personaggio giocatore
│   ├── projectile_widget.dart   # Widget proiettili
│   ├── virtual_joystick.dart    # Joystick virtuale
│   └── game_hud.dart            # Interfaccia utente di gioco
└── assets/
    └── svg/                     # Asset grafici SVG
```

## 🚀 Dipendenze

Il progetto utilizza i seguenti pacchetti Flutter:

- **flutter_svg**: Rendering di grafica SVG
- **flame**: Game engine per Flutter
- **forge2d**: Motore fisico 2D
- **web_socket_channel**: Comunicazione multiplayer
- **provider**: Gestione dello stato
- **audioplayers**: Effetti sonori

## 🎯 Come Funziona

### 1. Lobby Screen
- Inserisci il tuo nome giocatore
- Anteprima dei personaggi disponibili
- Pulsante "Join Battle" per iniziare

### 2. Game Screen
- **Joystick virtuale** (in basso a sinistra): Controlla il movimento del personaggio
- **Touch to aim**: Tocca lo schermo per mirare
- **Pulsante shoot** (in basso a destra): Spara nella direzione frontale
- **Camera follow**: La telecamera segue automaticamente il tuo personaggio

### 3. Sistema Multiplayer
- Connessione WebSocket al server di gioco
- Sincronizzazione in tempo reale delle posizioni
- Gestione di ingressi/uscite giocatori
- Aggiornamento stato proiettili e collisioni

## 🔧 Configurazione

### Prerequisiti
- Flutter SDK 3.11.4 o superiore
- Dart SDK corrispondente

### Installazione

1. Clona il repository
2. Installa le dipendenze:
   ```bash
   flutter pub get
   ```

3. Esegui l'app:
   ```bash
   flutter run
   ```

## 🎮 Gameplay

### Obiettivo
Sconfiggi gli altri giocatori nell'arena per guadagnare punti!

### Controlli
- **Movimento**: Usa il joystick virtuale in basso a sinistra
- **Mira**: Tocca qualsiasi punto dello schermo per mirare
- **Spara**: Rilascia il tocco o usa il pulsante rosso in basso a destra

### Sistema di Salute
- Ogni giocatore inizia con 100 HP
- I proiettili infliggono 10 danni
- La barra della salute cambia colore:
  - 🟢 Verde: > 60% HP
  - 🟠 Arancione: 30-60% HP
  - 🔴 Rosso: < 30% HP

## 🏗️ Architettura Tecnica

### Game Loop
Il gioco utilizza un `Ticker` per aggiornare lo stato a ogni frame:
- Aggiornamento posizione proiettili
- Rilevamento collisioni
- Aggiornamento camera
- Sincronizzazione network

### Network Protocol
Messaggi WebSocket supportati:
- `join_game`: Unisciti alla partita
- `move`: Aggiorna posizione giocatore
- `shoot`: Sparo proiettile
- `player_hit`: Danno subito
- `game_update`: Stato del gioco

### Rendering
- Tutti i personaggi e proiettili sono renderizzati come SVG
- La mappa è disegnata con `CustomPainter`
- La camera è implementata con trasformazione coordinate mondo → schermo

## 📝 Note per lo Sviluppo Futuro

### Da Implementare
- [ ] Server backend per multiplayer reale
- [ ] Sistema di matchmaking
- [ ] Più personaggi con abilità uniche
- [ ] Power-ups e oggetti nell'arena
- [ ] Classifiche e statistiche
- [ ] Effetti particellari
- [ ] Audio e musica
- [ ] Skin personalizzabili

### Ottimizzazioni
- Utilizzare Flame engine per rendering più performante
- Implementare object pooling per proiettili
- Aggiungere LOD (Level of Detail) per SVG complessi
- Compressione asset grafici

## 🚧 Funzionalità in Sviluppo

- [ ] Bot AI per modalità single player
- [ ] Sistema di power-up
- [ ] Multiple arene
- [ ] Classifiche e statistiche
- [ ] Effetti particellari
- [ ] Audio e musica
- [ ] Skin personalizzabili
- [ ] Chat in-game

## 🤝 Contribuire

Sentiti libero di forkare il progetto e inviare pull request!

## 📄 Licenza

Questo progetto è open source e disponibile sotto licenza MIT.

---

**Pixel Fury Arena** - Combatti nell'arena, diventa il campione! 🏆
