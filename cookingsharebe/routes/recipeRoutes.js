const express = require('express');
const router = express.Router();
const {
  createRecipe,
  getAllRecipes,
  searchController,
  getRecipe,
  deleteRecipeByID,
  reactionRecipe,
  commentRecpie,
  updateRecipe,
} = require("../controllers/recipeController");
const upload = require('../middleware/uploadMiddleware'); // Assuming you have multer middleware
const authenticateToken = require('../middleware/authMiddleware');

router.post('/', authenticateToken, upload.fields([
  { name: 'image', maxCount: 1 },
  { name: 'video', maxCount: 1 }
]), createRecipe);

router.get('/', getAllRecipes);
router.get('/search', searchController);
router.get('/:id', authenticateToken, getRecipe);
router.delete('/:id', authenticateToken, deleteRecipeByID);

router.post('/:id/reaction', authenticateToken, reactionRecipe);
router.post('/:id/comment', authenticateToken, commentRecpie);

router.put('/:id', updateRecipe);

module.exports = router;
