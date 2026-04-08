const express = require('express');
const router = express.Router();
const ratingController = require('../controllers/ratingController');
const authMiddleware = require('../middleware/authMiddleware');

// Thêm/cập nhật đánh giá cho công thức
// POST /api/recipes/:recipeId/rating
router.post('/:recipeId/rating', authMiddleware, ratingController.rateRecipe);

// Lấy đánh giá của người dùng cho một công thức
// GET /api/recipes/:recipeId/rating
router.get('/:recipeId/rating', authMiddleware, ratingController.getUserRating);

// Xóa đánh giá
// DELETE /api/recipes/:recipeId/rating
router.delete('/:recipeId/rating', authMiddleware, ratingController.deleteRating);

module.exports = router; 