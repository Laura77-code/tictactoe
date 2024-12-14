require('dotenv').config();

const express = require("express");
const http = require("http");
const mongoose = require("mongoose");
const { Server } = require("socket.io");
const cors = require("cors");

// Configuración básica
const app = express();
const server = http.createServer(app);
const port = process.env.PORT || 3000;
const DB = process.env.MONGODB_URI;

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
  console.log(`\n🔌 SOCKET CONNECTED: ${socket.id}`);

  // Modified createRoom to ensure first turn is set properly
  socket.on("createRoom", async ({ nickname, maxRounds }) => {
    console.log('\n🎮 CREATE ROOM REQUEST:');
    console.log('----------------------------------------');
    console.log('Nickname:', nickname);
    console.log('Requested Max Rounds:', maxRounds);
    
    try {
      // Create new room
      let room = new Room();
      
      // Ensure maxRounds is a number and at least 1
      const roundsCount = parseInt(maxRounds) || 3;
      room.maxRounds = Math.max(1, roundsCount);
      
      console.log('Setting max rounds to:', room.maxRounds);
      
      let player = {
        socketID: socket.id,
        nickname,
        playerType: 'X',
        points: 0
      };

      room.players.push(player);
      room.turn = player;
      
      await room.save();

      console.log('\n📊 ROOM CREATED:');
      console.log('Room ID:', room._id);
      console.log('Max Rounds:', room.maxRounds);
      console.log('Initial Player:', player.nickname);

      socket.join(room.id);
      io.to(room.id).emit('createRoomSuccess', room.toObject());
      
      console.log('✅ Room creation successful');
      console.log('----------------------------------------');
    } catch (e) {
      console.error('\n❌ Error creating room:', e);
      console.error('Stack:', e.stack);
    }
  });

  socket.on("winner", async ({ winnerSocketId, roomId }) => {
    try {
      console.log('\n🎮 WINNER EVENT RECEIVED:');
      console.log('----------------------------------------');
      console.log('Winner Socket ID:', winnerSocketId);
      console.log('Room ID:', roomId);

      let room = await Room.findById(roomId);
      if (!room) {
        console.log('❌ Room not found');
        return;
      }

      // Find winner
      let winnerPlayer = room.players.find(p => p.socketID === winnerSocketId);
      if (!winnerPlayer) {
        console.log('❌ Winner player not found');
        return;
      }

      // Check if this win has already been processed
      if (room.lastWinner && room.lastWinner.round === room.currentRound) {
        console.log('\n⚠️ DUPLICATE WIN DETECTED:');
        console.log('Current Round:', room.currentRound);
        console.log('Last Winner Round:', room.lastWinner.round);
        console.log('Last Winner ID:', room.lastWinner.socketID);
        return;
      }

      // Save winner info
      room.lastWinner = {
        socketID: winnerSocketId,
        round: room.currentRound
      };

      // Increment points
      console.log('\n📈 UPDATING POINTS:');
      console.log('Winner:', winnerPlayer.nickname);
      console.log('Previous Points:', winnerPlayer.points);
      winnerPlayer.points = (winnerPlayer.points || 0) + 1;
      console.log('New Points:', winnerPlayer.points);

      // Mark for update and save
      console.log('\n💾 SAVING UPDATES:');
      room.markModified('players');
      room.markModified('lastWinner');
      await room.save();
      console.log('✅ Initial save complete');

      // Reload room to ensure we have the latest state
      room = await Room.findById(roomId);
      console.log('\n🔄 RELOADED ROOM STATE:');
      console.log('Current Round:', room.currentRound);
      console.log('Updated Player Points:');
      room.players.forEach(p => {
        console.log(`  ${p.nickname} (${p.playerType}): ${p.points} points (${p.socketID})`);
      });

      // Check if this is the last round
      const isLastRound = room.currentRound >= room.maxRounds;
      console.log('\n🔍 ROUND STATUS CHECK:');
      console.log('Current Round:', room.currentRound);
      console.log('Max Rounds:', room.maxRounds);
      console.log('Is Last Round:', isLastRound);

      if (isLastRound) {
        console.log('\n🏁 PROCESSING FINAL ROUND:');
        
        // Create final scores object
        const finalScores = room.players.map(p => ({
          nickname: p.nickname,
          points: p.points,
          socketID: p.socketID,
          playerType: p.playerType
        }));

        console.log('\n📊 VERIFIED FINAL SCORES:');
        finalScores.forEach(p => {
          console.log(`  ${p.nickname} (${p.playerType}): ${p.points} points (${p.socketID})`);
        });

        // First send the win event to update points
        console.log('\n📡 SENDING GAME WIN EVENT:');
        io.to(roomId).emit("gameWin", { 
          room: room.toObject(),
          winnerSocketId: winnerSocketId,
          isLastRound: true
        });

        // Wait a bit to ensure points are updated on client
        setTimeout(async () => {
          try {
            // Reload room one final time
            room = await Room.findById(roomId);
            
            console.log('\n📡 SENDING GAME END EVENT:');
            console.log('Final Room State:');
            room.players.forEach(p => {
              console.log(`  ${p.nickname} (${p.playerType}): ${p.points} points (${p.socketID})`);
            });

            io.to(roomId).emit("gameEnd", { 
              room: room.toObject(),
              winnerSocketId: winnerSocketId,
              finalScores: finalScores
            });
            console.log('✅ Game end event sent');
          } catch (e) {
            console.error('\n❌ Error sending game end event:', e);
          }
        }, 1000);
      } else {
        console.log('\n🎮 PROCESSING MID-GAME WIN:');
        // For non-final rounds, emit win event and increment round
        io.to(roomId).emit("gameWin", { 
          room: room.toObject(),
          winnerSocketId: winnerSocketId,
          isLastRound: false
        });
        console.log('✅ Game win event sent');

        // Increment round after a delay
        setTimeout(async () => {
          try {
            console.log('\n🔄 INCREMENTING ROUND:');
            room = await Room.findById(roomId);
            if (!room) {
              console.log('❌ Room not found during round increment');
              return;
            }

            const oldRound = room.currentRound;
            room.currentRound += 1;
            await room.save();
            
            console.log(`Round incremented: ${oldRound} -> ${room.currentRound}`);
            console.log('Player States:');
            room.players.forEach(p => {
              console.log(`  ${p.nickname}: ${p.points} points`);
            });

            io.to(roomId).emit("updateRoom", room.toObject());
            console.log('✅ Room update event sent');
          } catch (e) {
            console.error('\n❌ Error in round increment:', e);
          }
        }, 1000);
      }

    } catch (e) {
      console.error("\n❌ ERROR in winner event:", e);
      console.error('Stack:', e.stack);
    }
  });

  socket.on('tap', async ({ index, roomId }) => {
    console.log('\n🎯 TAP EVENT RECEIVED ON SERVER:');
    console.log('----------------------------------------');
    console.log(`Room ID: ${roomId}`);
    console.log(`Index: ${index}`);
    console.log(`Player Socket: ${socket.id}`);

    try {
      let room = await Room.findById(roomId);
      if (!room) {
        console.log('❌ Room not found');
        return;
      }

      console.log('\nCurrent Room State:');
      console.log(`Turn Socket: ${room.turn.socketID}`);
      console.log(`Turn Player: ${room.turn.nickname}`);
      console.log(`Board: ${JSON.stringify(room.board || [])}`);

      // Verify it's player's turn
      if (room.turn.socketID === socket.id) {
        const choice = room.turn.playerType; // X or O
        
        // Initialize board if it doesn't exist
        if (!room.board) {
          room.board = ['', '', '', '', '', '', '', '', ''];
        }
        
        // Update board
        room.board[index] = choice;
        
        // Switch turns
        const nextPlayer = room.players.find(p => p.socketID !== socket.id);
        if (nextPlayer) {
          room.turn = nextPlayer;
        }

        // Save changes
        room.markModified('board');
        room.markModified('turn');
        await room.save();
        
        console.log('\nUpdated Room State:');
        console.log(`Board: ${JSON.stringify(room.board)}`);
        console.log(`Next Turn: ${room.turn.nickname} (${room.turn.socketID})`);

        // Broadcast to all players in the room
        io.to(roomId).emit('tapped', {
          index,
          choice,
          room: room.toObject()
        });

        console.log('\n✅ Move processed and broadcast');
      } else {
        console.log('❌ Invalid turn - not this player\'s turn');
      }
    } catch (error) {
      console.log('\n❌ Error processing tap:');
      console.log(error);
    }
    console.log('----------------------------------------');
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

  socket.on("restart_game", async ({ roomId }) => {
    console.log('\n🔄 GAME RESTART REQUESTED:');
    console.log('----------------------------------------');
    console.log(`Room ID: ${roomId}`);
    console.log(`Requesting Socket: ${socket.id}`);

    try {
      let room = await Room.findById(roomId);
      if (!room) {
        console.log('❌ Room not found');
        return;
      }

      console.log('\nCurrent Room State:');
      console.log(`Round: ${room.currentRound}`);
      console.log(`Board: ${JSON.stringify(room.board)}`);
      console.log(`Players: ${JSON.stringify(room.players.map(p => ({ 
        nickname: p.nickname, 
        points: p.points 
      })))}`);

      // Reset board
      room.board = ['', '', '', '', '', '', '', '', ''];
      room.currentRound++;
      
      // Reset turn to first player
      room.turn = room.players[0];

      console.log('\nUpdated Room State:');
      console.log(`Round: ${room.currentRound}`);
      console.log(`Board: ${JSON.stringify(room.board)}`);
      console.log(`Next Turn: ${room.turn.nickname} (${room.turn.socketID})`);

      io.to(roomId).emit('game_restarted', room);
      console.log('\n✅ Game restart processed and broadcast');
    } catch (error) {
      console.log('\n❌ Error restarting game:');
      console.log(error);
    }
    console.log('----------------------------------------');
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