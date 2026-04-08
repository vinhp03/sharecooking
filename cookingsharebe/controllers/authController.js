const bcrypt = require("bcrypt");
const User = require("../models/User"); // Assuming User model is in models folder
const jwt = require("jsonwebtoken");
const dotenv = require("dotenv");
dotenv.config();

// Tạo access token
const generateAccessToken = (userId) => {
  return jwt.sign({ id: userId }, process.env.JWT_SECRET, {
    expiresIn: "30d", // Token hết hạn sau 1 giờ
  });
};

// Tạo refresh token
const generateRefreshToken = (userId) => {
  return jwt.sign({ id: userId }, process.env.REFRESH_TOKEN_SECRET, {
    expiresIn: "30d", // Refresh token hết hạn sau 30 ngày
  });
};

// Đăng ký
exports.signup = async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // Kiểm tra email đã tồn tại
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: "Email already exists" });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Tạo user mới
    const user = new User({
      username,
      email,
      password: hashedPassword,
    });

    await user.save();

    // Tạo tokens
    const accessToken = generateAccessToken(user._id);
    const refreshToken = generateRefreshToken(user._id);

    // Lưu refresh token vào database
    user.refreshToken = refreshToken;
    await user.save();

    res.status(201).json({
      message: "User created successfully",
      token: accessToken,
      refreshToken: refreshToken,
      userId: user._id,
    });
  } catch (error) {
    res.status(500).json({ message: "Error creating user", error: error.message });
  }
};

// Đăng nhập
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Tìm user theo email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    // Kiểm tra password
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    // Tạo tokens mới
    const accessToken = generateAccessToken(user._id);
    const refreshToken = generateRefreshToken(user._id);

    // Cập nhật refresh token trong database
    user.refreshToken = refreshToken;
    await user.save();

    res.status(200).json({
      token: accessToken,
      refreshToken: refreshToken,
      userId: user._id,
    });
  } catch (error) {
    res.status(500).json({ message: "Error logging in", error: error.message });
  }
};

// Refresh token
exports.refresh = async (req, res) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      return res.status(401).json({ message: "Refresh token is required" });
    }

    // Verify refresh token
    const decoded = jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET);
    
    // Tìm user và kiểm tra refresh token
    const user = await User.findById(decoded.id);
    if (!user || user.refreshToken !== refreshToken) {
      return res.status(401).json({ message: "Invalid refresh token" });
    }

    // Tạo access token mới
    const newAccessToken = generateAccessToken(user._id);
    
    // Tùy chọn: tạo refresh token mới (rotation)
    const newRefreshToken = generateRefreshToken(user._id);
    user.refreshToken = newRefreshToken;
    await user.save();

    res.status(200).json({
      token: newAccessToken,
      refreshToken: newRefreshToken,
    });
  } catch (error) {
    if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
      return res.status(401).json({ message: "Invalid or expired refresh token" });
    }
    res.status(500).json({ message: "Error refreshing token", error: error.message });
  }
};

// Đăng xuất
exports.logout = async (req, res) => {
  try {
    const userId = req.userId; // Từ middleware xác thực

    // Xóa refresh token trong database
    await User.findByIdAndUpdate(userId, { refreshToken: null });

    res.status(200).json({ message: "Logged out successfully" });
  } catch (error) {
    res.status(500).json({ message: "Error logging out", error: error.message });
  }
};

