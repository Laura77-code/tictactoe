const mongoose = require("mongoose");
const playerSchema = require("./player");

const roomSchema = new mongoose.Schema({
  occupancy: {
    type: Number,
    default: 2,
  },
  maxRounds: {
    type: Number,
    default: 3,
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
  isJoin: {
    type: Boolean,
    default: true,
  },
  turn: {
    type: Object,
    required: true,
    default: null,
  },
  turnIndex: {
    type: Number,
    default: 0,
  },
});

const roomModel = mongoose.model("Room", roomSchema);
module.exports = roomModel;