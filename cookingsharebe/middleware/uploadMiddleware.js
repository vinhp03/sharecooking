const multer = require("multer");
const path = require("path");
const fs = require("fs");

// Hàm xác định nơi lưu file
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const isImage = file.mimetype.startsWith("image/");
    const isVideo = file.mimetype.startsWith("video/");
    let folder = "";

    if (isImage) folder = "assets/img";
    else if (isVideo) folder = "assets/video";
    else
      return cb(new Error("File không hợp lệ. Chỉ chấp nhận ảnh hoặc video."));

    // Tạo thư mục nếu chưa tồn tại
    fs.mkdirSync(folder, { recursive: true });

    cb(null, folder);
  },

  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname); // .jpg, .mp4
    const uniqueName = Date.now() + "-" + Math.round(Math.random() * 1e9) + ext;
    cb(null, uniqueName);
  },
});

// Bộ lọc định dạng file (chỉ cho phép ảnh và video)
const fileFilter = (req, file, cb) => {
  const isImage = file.mimetype.startsWith("image/");
  const isVideo = file.mimetype.startsWith("video/");

  if (isImage || isVideo) {
    cb(null, true);
  } else {
    cb(new Error("Chỉ cho phép upload ảnh hoặc video!"), false);
  }
};

const upload = multer({ storage: storage, fileFilter: fileFilter });

module.exports = upload;
