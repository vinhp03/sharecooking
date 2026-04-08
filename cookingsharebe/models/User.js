const mongoose = require('mongoose');
const userSchema = new mongoose.Schema({
  username: {
    type: String, required: true, unique: true, trim: true, minlength: 3
  },
  email:  {
    type: String, required: true, unique: true, trim: true, minlength: 3
  },
  password: {
    type: String, required: true, unique: true, trim: true, minlength: 8
  },
  following: [{ 
    type: mongoose.Schema.Types.ObjectId, ref: 'User' 
  }],
  followers: [{ 
    type: mongoose.Schema.Types.ObjectId, ref: 'User' 
  }],
  followersCount: {
    type: Number,
    default: 0
  },
  followingCount: {
    type: Number,
    default: 0
  },
  favouriterecipe: [{
    type: mongoose.Schema.Types.ObjectId, ref: 'Recipe'
  }],
  favouritecount: {
    type: Number,
    default: 0
  },
  refreshToken: {
    type: String,
    default: null
  }
}, {
  timestamps: true,
  collection: 'users'
});

// Middleware để tự động cập nhật số lượng followers và following
userSchema.pre('save', async function(next) {
  if (this.isModified('followers') || this.isNew) {
    this.followersCount = this.followers.length;
  }
  if (this.isModified('following') || this.isNew) {
    this.followingCount = this.following.length;
  }
  next();
});

// Đảm bảo model chỉ được đăng ký một lần
const User = mongoose.models.User || mongoose.model('User', userSchema);
module.exports = User;
