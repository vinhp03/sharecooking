const express = require("express");
const { 
    getAllUsers, 
    getUserProfile, 
    updateUserProfile, 
    followUser,
    unfollowUser, 
    addFavoriteRecipe, 
    removeFavoriteRecipe,
    getFollowers,
    getFollowing 
} = require("../controllers/userController");
const authMiddleware = require("../middleware/authMiddleware");
const router = express.Router();

router.get("/all", authMiddleware, getAllUsers);
router.get("/profile", authMiddleware, getUserProfile);
router.put("/profile", authMiddleware, updateUserProfile);
router.post("/follow/:id", authMiddleware, followUser);
router.post("/unfollow/:id", authMiddleware, unfollowUser);
router.get("/followers/:id", authMiddleware, getFollowers);
router.get("/following/:id", authMiddleware, getFollowing);
router.post("/favorite/:recipeId", authMiddleware, addFavoriteRecipe);
router.delete("/favorite/:recipeId", authMiddleware, removeFavoriteRecipe);

module.exports = router;