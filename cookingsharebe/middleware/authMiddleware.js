const jwt = require("jsonwebtoken");
const dotenv = require("dotenv");
dotenv.config();

const authMiddleware = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  
  if (!authHeader) {
    return res.status(401).json({ message: "Không tìm thấy token xác thực" });
  }

  // Kiểm tra format "Bearer <token>"
  const tokenParts = authHeader.split(' ');
  if (tokenParts.length !== 2 || tokenParts[0] !== 'Bearer') {
    return res.status(401).json({ message: "Token không đúng định dạng" });
  }

  const token = tokenParts[1];
  console.log('Token received:', token);
  console.log('JWT_SECRET:', process.env.JWT_SECRET);

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    console.log('Decoded token:', decoded);
    req.userId = decoded.id;
    next();
  } catch (err) {
    console.error("Token verification error:", {
      name: err.name,
      message: err.message,
      stack: err.stack
    });
    
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ message: "Token đã hết hạn" });
    }
    if (err.name === 'JsonWebTokenError') {
      return res.status(403).json({ 
        message: "Token không hợp lệ",
        error: err.message 
      });
    }
    return res.status(403).json({ 
      message: "Lỗi xác thực",
      error: err.message 
    });
  }
}

module.exports = authMiddleware;