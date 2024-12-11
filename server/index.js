const express = require("express");
const http = require("http");
const mongoose = require("mongoose");
const { Server } = require("socket.io");
const cors = require("cors");

// Configuración básica
const app = express();
const server = http.createServer(app);
const port = process.env.PORT || 3000;
const DB = "mongodb+srv://laura:1234@cluster0.hbpzu.mongodb.net/tictactoe";

// Configurar middleware
app.use(cors({
  origin: "*",
  methods: ["GET", "POST"],
  allowedHeaders: ["Content-Type"]
}));
app.use(express.json());

// Configurar Socket.IO con opciones específicas
const io = new Server(server, {
  pingTimeout: 60000,
  pingInterval: 25000,
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
    credentials: true
  },
  allowEIO3: true,
  transports: ['polling', 'websocket']
});

// Ruta de prueba para verificar que el servidor está funcionando
app.get('/', (req, res) => {
  res.send('Server is running');
});

// Modelo de la sala
const roomSchema = new mongoose.Schema({
  isJoin: {
    type: Boolean,
    default: true,
  },
  currentRound: {
    type: Number,
    default: 1,
  },
  players: [{
    nickname: String,
    socketID: String,
    playerType: String,
    points: {
      type: Number,
      default: 0,
    },
  }],
  turn: Object,
  turnIndex: {
    type: Number,
    default: 0,
  },
  maxRounds: {
    type: Number,
    default: 3,
  },
  lastWinner: {
    socketID: String,
    round: Number
  }
});

const Room = mongoose.model("Room", roomSchema);

// Manejo de conexiones Socket.IO
io.on("connection", (socket) => {
  console.log("✅ New client connected! Socket ID:", socket.id);

  // Modified createRoom to ensure first turn is set properly
  socket.on("createRoom", async ({ nickname }) => {
    console.log("Creating room for:", nickname);
    try {
      let room = new Room({
        isJoin: true,
        players: [],
        turn: null,
        turnIndex: 0,
      });
  
      let player = {
        socketID: socket.id,
        nickname,
        playerType: "X",
        points: 0,
      };
  
      room.players.push(player);
      room.turn = player;  // First player (X) always starts the first game
      room = await room.save();
      
      const roomId = room._id.toString();
      console.log("Room created with ID:", roomId);
      console.log("First turn set to:", player.nickname);
  
      socket.join(roomId);
      io.to(roomId).emit("createRoomSuccess", room);
    } catch (e) {
      console.error("Error creating room:", e);
      socket.emit("errorOccurred", "Error creating room: " + e.message);
    }
  });

  socket.on("winner", async ({ winnerSocketId, roomId }) => {
    try {
      let room = await Room.findById(roomId);
      if (!room) return;
  
      // Find winner
      let winnerPlayer = room.players.find(p => p.socketID === winnerSocketId);
      if (!winnerPlayer) return;
  
      // Verificar si ya se actualizó este ganador en esta ronda
      const lastWinner = room.lastWinner || {};
      if (lastWinner.socketID === winnerSocketId && lastWinner.round === room.currentRound) {
        return; // Salir silenciosamente si ya fue procesado
      }
  
      // Increment points
      winnerPlayer.points = Number(winnerPlayer.points || 0) + 1;
  
      // Increment round
      if (room.currentRound < room.maxRounds) {
        room.currentRound += 1;
      }
  
      // Guardar información del último ganador
      room.lastWinner = {
        socketID: winnerSocketId,
        round: room.currentRound
      };
  
      // Switch turn
      const otherPlayerIndex = room.players.findIndex(p => p.socketID !== winnerSocketId);
      room.turn = room.players[otherPlayerIndex];
      room.turnIndex = otherPlayerIndex;
  
      // Save and emit immediately
      room = await room.save();
      io.to(roomId).emit("gameWin", { room: room.toObject() });
  
    } catch (e) {
      console.error("Error handling winner:", e);
    }
  }); 
 
  socket.on("tap", async ({ index, roomId }) => {
    try {
      let room = await Room.findById(roomId);
      if (!room) {
        socket.emit("errorOccurred", "Room not found.");
        return;
      }
  
      console.log('Tap received:');
      console.log('Socket ID:', socket.id);
      console.log('Current turn:', room.turn.socketID);
  
      // Verify it's the correct player's turn
      if (socket.id !== room.turn.socketID) {
        console.log('Not your turn');
        return;
      }
  
      let choice = room.turn.playerType;
      // Switch to other player's turn
      const nextTurnIndex = room.turnIndex === 0 ? 1 : 0;
      room.turn = room.players[nextTurnIndex];
      room.turnIndex = nextTurnIndex;
  
      room = await room.save();
      console.log('Turn updated:', room.turn.nickname);
  
      io.to(roomId).emit("tapped", {
        index,
        choice,
        room,
      });
    } catch (e) {
      console.error("Error handling tap:", e);
      socket.emit("errorOccurred", "Error handling tap: " + e.message);
    }
  });

  socket.on("joinRoom", async ({ nickname, roomId }) => {
    try {
      console.log(`Join room request: ${nickname} trying to join ${roomId}`);
      
      if (!roomId.match(/^[0-9a-fA-F]{24}$/)) {
        socket.emit("errorOccurred", "Please enter a valid room ID");
        return;
      }
      
      let room = await Room.findById(roomId);
      
      if (!room) {
        socket.emit("errorOccurred", "Room not found");
        return;
      }
  
      if (room.isJoin) {
        let player = {
          nickname,
          socketID: socket.id,
          playerType: "O",
          points: 0,
        };
        
        socket.join(roomId);
        room.players.push(player);
        room.isJoin = false;
        room = await room.save();
        
        console.log(`Room ${roomId} updated:`, room);
        
        io.to(roomId).emit("updateRoom", room);
        socket.emit("joinRoomSuccess", room);
        
        const creator = room.players.find(p => p.playerType === "X");
        if (creator) {
          io.to(creator.socketID).emit("startGame", room);
        }
      } else {
        socket.emit("errorOccurred", "Game is in progress");
      }
    } catch (e) {
      console.error("Error joining room:", e);
      socket.emit("errorOccurred", e.message);
    }
  });

  socket.on("disconnect", async () => {
    try {
      const rooms = await Room.find({ "players.socketID": socket.id });
      for (const room of rooms) {
        room.players = room.players.filter(player => player.socketID !== socket.id);
        if (room.players.length === 0) {
          await Room.findByIdAndDelete(room._id);
        } else {
          room.isJoin = true;
          await room.save();
          io.to(room._id.toString()).emit("playerLeft", {
            room: room,
            playerSocketId: socket.id
          });
        }
      }
    } catch (e) {
      console.error("❌ Error handling disconnect:", e);
    }
  });
});

// Manejo mejorado de errores
io.engine.on("connection_error", (err) => {
  console.log("❌ Connection Error:", err);
});

// Iniciar el servidor
const startServer = async () => {
  try {
    await mongoose.connect(DB);
    console.log("✅ MongoDB connected successfully!");
    
    server.listen(port, "0.0.0.0", () => {
      console.log(` Server started and running on port ${port}`);
      console.log(`📝 Test the server at: http://localhost:${port}`);
      console.log(`🔌 Socket.IO is configured and ready`);
    });
  } catch (e) {
    console.error("❌ Server startup error:", e);
    process.exit(1);
  }
};

startServer();