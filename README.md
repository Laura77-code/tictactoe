# TicTacToe Multiplayer

A real-time multiplayer TicTacToe game built with Flutter and Node.js. Create or join rooms, share them via QR code, and play multiple rounds with live score tracking.

## Demo

**Video demo:** [Watch on YouTube](https://youtu.be/uqtY5cOIHM4)

[![Demo Video](https://img.youtube.com/vi/uqtY5cOIHM4/0.jpg)](https://youtu.be/uqtY5cOIHM4)

## Key Features

![Key Features](demoImg/Key%20Features.png)

- Real-time multiplayer gaming with Socket.IO
- Room-based gameplay (create or join)
- QR code room sharing and scanning
- Score tracking across multiple rounds
- Responsive design for different screen sizes

## Technical Stack

![Technical Stack](demoImg/Technical%20Stack.png)

| Layer | Technology |
|-------|------------|
| Frontend | Flutter / Dart |
| Backend | Node.js with Express |
| Database | MongoDB |
| Real-time | Socket.IO |
| Deployment | Railway (Docker) |
| Extras | QR scanning/generation, Provider, Docker |

## Project Architecture

![Project Architecture](demoImg/Project%20Arquitecture.png)

```
tictactoe/
├── lib/                    # Flutter client
│   ├── main.dart           # Entry point
│   ├── screens/            # UI screens
│   ├── provider/           # State management
│   ├── resources/          # Socket & game logic
│   ├── utils/              # Helper functions
│   └── widgets/            # Reusable UI components
└── server/                 # Node.js backend
    ├── index.js            # Main server file
    ├── models/             # Database schemas
    └── Dockerfile          # Container configuration
```

## Technical Implementation

### 1. Socket.IO Connection Setup

![Socket.IO Connection Setup](demoImg/Technical%20Implementation%201.png)

The Flutter client connects to the Node.js server using WebSocket transport. The server listens for incoming connections and handles game events.

### 2. Room Management & 3. State Management

![Room Management and State Management](demoImg/Technical%20Implementation%202%20-%203.png)

- **Room creation:** The server creates rooms, assigns player types (X/O), and persists them in MongoDB.
- **State management:** `RoomDataProvider` (Provider) keeps room data, rounds, and scores in sync across the UI.

### 4. Game Logic

![Game Logic Implementation](demoImg/Technical%20Implementation%204.png)

Win conditions are checked on the client and winner events are emitted to the server to update scores and trigger the next round.

## Server Deployment

![Server Deployment](demoImg/Server%20Deployment.png)

- **Railway:** Containerized with Docker, Git-integrated auto-deploy, and environment variable management.
- **Android APK:** Debug and release builds with network security configuration for local/server connections.

---

## Getting Started

### Prerequisites

- Flutter 3.5.1+ / Dart 3.5.1+
- Node.js 18.x
- MongoDB (local or Atlas)
- Android SDK (minSdk 21, targetSdk 34)

### Flutter Client

1. Install dependencies:

```bash
flutter pub get
```

2. Update the server IP in `lib/resources/socket_client.dart` to match your backend address.

3. Run the app:

```bash
flutter run
```

**Required permissions:** Internet, Camera (for QR scanning)

**Tested on:** Samsung Galaxy S21 (Android 14), Pixel 7 Emulator (Android 13)

### Backend Server

1. Navigate to the server folder and install dependencies:

```bash
cd server
npm install
```

2. Create a `.env` file:

```
MONGODB_URI=mongodb://localhost:27017/tictactoe
PORT=3000
```

3. Start MongoDB (if running locally):

```bash
# Windows
net start MongoDB

# Linux/macOS
sudo service mongod start
```

4. Start the server:

```bash
# Development (auto-reload)
npm run dev

# Production
npm start
```

The server runs at `http://localhost:3000`.

## Socket.IO Events

| Event | Description |
|-------|-------------|
| `connection` | Client connects to the server |
| `createRoom` | Host creates a new game room |
| `joinRoom` | Guest joins an existing room |
| `tap` | Player makes a move on the board |
| `gameRestarted` | Starts a new round after a win/draw |

## Environment Variables

| Variable | Description |
|----------|-------------|
| `PORT` | Server port (default: 3000) |
| `MONGODB_URI` | MongoDB connection string |

## Troubleshooting

**MongoDB connection issues**
- Ensure MongoDB is running
- Verify the connection string in `.env`
- Default port: 27017

**Socket connection issues**
- Confirm the server is running
- Check that `SERVER_IP` in `socket_client.dart` matches your machine's IP
- Ensure the port is not blocked by a firewall

**Check MongoDB status**

```bash
# Windows
sc query MongoDB

# Linux/macOS
sudo systemctl status mongod
```

## Dependencies

**Flutter:** `provider`, `socket_io_client`, `qr_flutter`, `mobile_scanner`, `share_plus`

**Server:** `express`, `socket.io`, `mongoose`, `cors`, `dotenv`
