# TicTacToe Multiplayer 

Backend server for the TicTacToe multiplayer game built with Node.js, Express, Socket.IO, and MongoDB.

## Prerequisites

- Node.js (v14 or higher)
- MongoDB (local installation or MongoDB Atlas account)
- npm (Node Package Manager)

## Installation

1. Clone the repository or copy the server folder
```bash
git clone <repository-url>
cd server
```

2. Install dependencies
```bash
npm install
```

3. Create a `.env` file in the server directory with your MongoDB connection string:
```
MONGODB_URI=mongodb://localhost:27017/tictactoe
PORT=3000
```

Note: If you're using MongoDB Atlas, replace the connection string with your Atlas URI.

## Running the Server

1. Start MongoDB service (if using local MongoDB)
```bash
# Windows
net start MongoDB

# Linux/MacOS
sudo service mongod start
```

2. Start the server
```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

The server will start on `http://localhost:3000`

## API Endpoints

The server uses Socket.IO for real-time communication. Here are the main events:

- `connection`: Socket connection event
- `createRoom`: Create a new game room
- `joinRoom`: Join an existing room
- `tap`: Handle player moves
- `gameRestarted`: Handle game restart

## Environment Variables

- `PORT`: Server port (default: 3000)
- `MONGODB_URI`: MongoDB connection string

## Project Structure

```
server/
├── models/
│   ├── room.js     # Room model schema
│   └── player.js   # Player model schema
├── index.js        # Main server file
├── package.json    # Dependencies and scripts
└── .env           # Environment variables (create this)
```

## Troubleshooting

1. MongoDB Connection Issues:
   - Ensure MongoDB service is running
   - Check connection string in `.env`
   - Verify MongoDB port (default: 27017)

2. Socket Connection Issues:
   - Check if server is running
   - Verify port is not in use
   - Check client connection settings

## Common Commands

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Start production server
npm start

# Check MongoDB status (Windows)
sc query MongoDB

# Check MongoDB status (Linux/MacOS)
sudo systemctl status mongod
```

## Required Dependencies

The server uses these main packages:
- `express`: Web framework
- `socket.io`: Real-time communication
- `mongoose`: MongoDB object modeling
- `cors`: Cross-origin resource sharing

All dependencies are listed in `package.json` and will be installed with `npm install`. 