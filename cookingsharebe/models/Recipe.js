const mongoose = require('mongoose');
const dotenv = require('dotenv');
dotenv.config();
const Schema = mongoose.Schema;

const recipeSchema = new Schema({
  title: {
    type: String,
    required: [true, "Title is required"],
  },
  description: {
    type: String,
    required: true,
  },
  // Nguyên lieu
  ingredients: {
    type: [String],
    required: true,
  },
  // Huong dan nau
  instructions: {
    type: [String],
    required: true,
  },
  imageUrl: {
    type: String,
    required: false,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  comments: [
  {
    user: { type: Schema.Types.ObjectId, ref: 'User' },
    content: String,
    createdAt: { type: Date, default: Date.now }
  }
  ],
  videoUrl: {
    type: String,
    required: false,
  },
  // tac gia
  user: {
    type: Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  tag: {
    type: [String],
    required: true,
  },
  // Thoi gian chuan bi va nau
  prepTime: {
    type: Number,
    required: true,
    min: 0
  },
  cookTime: {
    type: Number,
    required: true,
    min: 0
  },
  // Do kho
  difficulty: {
    type: String,
    enum: ["Dễ", "Trung bình", "Khó"],
    required: true
  },
  reactions: [{
    user: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  reactionCount: {
    type: Number,
    default: 0
  },
  // Thêm các trường cho tính năng đánh giá
  averageRating: {
    type: Number,
    default: 0
  },
  ratingCount: {
    type: Number,
    default: 0
  },
  ratings: [{
    type: Schema.Types.ObjectId,
    ref: 'Rating'
  }]
}, {
  timestamps: true,
  collection: 'recipes' // Chỉ định rõ tên collection
});

// Đảm bảo model chỉ được đăng ký một lần
const Recipe = mongoose.models.Recipe || mongoose.model("Recipe", recipeSchema);
module.exports = Recipe;