const Recipe = require("../models/recipe");
const dotenv = require("dotenv");
const fs = require('fs');
const path = require('path');
dotenv.config();
exports.createRecipe = async (req, res) => {
  try {
    if (!req.body) {
      return res.status(400).json({ message: 'Request body is missing' });
    }

    const { title, description, ingredients, instructions, tag, prepTime, cookTime, difficulty } = req.body;

    if (!title) {
      return res.status(400).json({ message: 'Title is required' });
    }

    // Kiểm tra userId từ middleware
    if (!req.userId) {
      return res.status(400).json({ message: 'User information is required' });
    }

    const imageFile = req.files["image"]?.[0];
    const videoFile = req.files["video"]?.[0];

    const imageUrl = imageFile ? `/assets/img/${imageFile.filename}` : "";
    const videoUrl = videoFile ? `/assets/video/${videoFile.filename}` : "";

    const recipe = new Recipe({
      title,
      description,
      ingredients: JSON.parse(ingredients),
      instructions: JSON.parse(instructions),
      imageUrl,
      videoUrl,
      tag: JSON.parse(tag),
      prepTime,
      cookTime,
      difficulty,
      user: req.userId, // Sử dụng userId từ middleware
      reactions: [],
      reactionCount: 0
    });

    await recipe.save();
    
    // Populate user trước khi trả về
    await recipe.populate('user', 'username email');
    
    res.status(201).json({ message: "Recipe created successfully", recipe });
  } catch (error) {
    console.error('Error creating recipe:', error);
    res.status(500).json({ message: 'Error creating recipe', error: error.message });
  }
};

exports.getAllRecipes = async (req, res) => {
  try {
    const recipes = await Recipe.find()
      .populate({
        path: 'user',
        select: 'username email _id'
      })
      .populate({
        path: 'comments',
        populate: {
          path: 'user',
          select: 'username email'
        }
      })
      .populate({
        path: 'reactions',
        populate: {
          path: 'user',
          select: 'username email'
        }
      })
      .populate({
        path: 'ratings',
        select: 'stars'
      })
      .sort({ createdAt: -1 }); // Sort by newest first

    if (!recipes || recipes.length === 0) {
      return res.status(404).json({ message: "No recipes found" });
    }

    // Chuyển đổi dữ liệu trước khi trả về
    const formattedRecipes = recipes.map(recipe => {
      const recipeObj = recipe.toObject();
      
      // Xử lý title nếu là array
      if (Array.isArray(recipeObj.title)) {
        recipeObj.title = recipeObj.title[0];
      }

      // Lọc comments không hợp lệ
      recipeObj.comments = recipeObj.comments.filter(comment => 
        comment.user && (comment.content || comment.content === '')
      );

      return recipeObj;
    });

    res.status(200).json(formattedRecipes);
  } catch (error) {
    console.error('Error getting recipes:', error);
    return res.status(500).json({ 
      message: "Internal server error",
      error: error.message 
    });
  }
};

exports.getRecipe = async (req, res) => {
  try {
    const recipe = await Recipe.findById(req.params.id)
      .populate({
        path: 'user',
        select: 'username email'
      })
      .populate({
        path: 'comments',
        populate: {
          path: 'user',
          select: 'username email'
        }
      })
      .populate({
        path: 'reactions',
        populate: {
          path: 'user',
          select: 'username email'
        }
      })
      .populate({
        path: 'ratings',
        select: 'stars'
      });

    if (!recipe) {
      return res.status(404).json({message: "Recipe not found"});
    }

    // Xử lý dữ liệu trước khi trả về
    const recipeObj = recipe.toObject();
    if (Array.isArray(recipeObj.title)) {
      recipeObj.title = recipeObj.title[0];
    }

    return res.status(200).json(recipeObj);
  } catch (error) {
    console.error('Error getting recipe:', error);
    return res.status(500).json({ message: "Server error" });
  }
};

exports.searchController = async (req, res) => {
  try {
    const { keyword, ingredients, tag } = req.query;
    const query = {};
    
    if (keyword) {
      query.title = { $regex: keyword, $options: "i" };
    }
    
    if (ingredients) {
      query.ingredients = { $regex: ingredients, $options: "i" };
    }
    
    if (tag) {
      query.tag = { $in: tag.split(",") };
    }
    
    const recipes = await Recipe.find(query)
      .populate({
        path: 'user',
        select: 'username email'
      })
      .populate({
        path: 'comments',
        populate: {
          path: 'user',
          select: 'username email'
        }
      })
      .populate({
        path: 'reactions',
        populate: {
          path: 'user',
          select: 'username email'
        }
      })
      .populate({
        path: 'ratings',
        select: 'stars'
      })
      .sort({ createdAt: -1 });

    if (!recipes || recipes.length === 0) {
      return res.status(404).json({ message: "Not found" });
    }

    // Xử lý dữ liệu trước khi trả về
    const formattedRecipes = recipes.map(recipe => {
      const recipeObj = recipe.toObject();
      
      // Xử lý title nếu là array
      if (Array.isArray(recipeObj.title)) {
        recipeObj.title = recipeObj.title[0];
      }

      // Lọc comments không hợp lệ
      recipeObj.comments = recipeObj.comments.filter(comment => 
        comment.user && (comment.content || comment.content === '')
      );

      return recipeObj;
    });

    return res.status(200).json(formattedRecipes);
  } catch (error) {
    console.error('Error searching recipes:', error);
    res.status(500).json({ message: 'Error searching recipes', error: error.message });
  }
}

exports.deleteRecipeByID = async (req, res) => {
  const {id} = req.params;
  try {
    // Tìm recipe trước khi xóa để lấy thông tin về file
    const recipe = await Recipe.findById(id);
    if (!recipe) {
      return res.status(404).json({ message: "Recipe not found" });
    }

    // Xóa file ảnh nếu có
    if (recipe.imageUrl) {
      const imagePath = path.join(__dirname, '..', recipe.imageUrl);
      if (fs.existsSync(imagePath)) {
        fs.unlinkSync(imagePath);
      }
    }

    // Xóa file video nếu có
    if (recipe.videoUrl) {
      const videoPath = path.join(__dirname, '..', recipe.videoUrl);
      if (fs.existsSync(videoPath)) {
        fs.unlinkSync(videoPath);
      }
    }

    // Xóa recipe từ database
    await Recipe.findByIdAndDelete(id);
    return res.status(200).json({ message: "Recipe deleted successfully" });
  } catch (error) {
    console.error('Error deleting recipe:', error);
    return res.status(500).json({ message: "Server error", error: error.message });
  }
}

exports.reactionRecipe = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.userId; 
    // Tìm recipe
    const recipe = await Recipe.findById(id);
    if (!recipe) {
      return res.status(404).json({ message: "Recipe not found" });
    }

    // Kiểm tra xem user đã like chưa
    const existingReaction = recipe.reactions.find(
      reaction => reaction.user.toString() === userId
    );

    if (existingReaction) {
      // Nếu đã like thì unlike
      recipe.reactions = recipe.reactions.filter(
        reaction => reaction.user.toString() !== userId
      );
      recipe.reactionCount -= 1;
    } else {
      // Nếu chưa like thì like
      recipe.reactions.push({ user: userId });
      recipe.reactionCount += 1;
    }

    await recipe.save();

    return res.status(200).json({ 
      message: existingReaction ? "Recipe unliked successfully" : "Recipe liked successfully",
      recipe: {
        id: recipe._id,
        title: recipe.title,
        reactionCount: recipe.reactionCount,
        isLiked: !existingReaction
      }
    });
  } catch (error) {
    console.error('Error toggling reaction:', error);
    return res.status(500).json({ 
      message: "Server error", 
      error: error.message 
    });
  }
}

exports.commentRecpie = async (req, res) => {
  const { comments } = req.body;
  const userId = req.userId; 
  try {
    const recipe = await Recipe.findById(req.params.id);
    if (!recipe) {
      return res.status(404).json({ message: "Recipe not found" });
    }
    recipe.comments.push({ 
      user: userId, 
      content: comments
    });
    await recipe.save();
    return res.status(200).json(recipe);
  } catch (error) {
    console.error("Error adding comment:", error);
    return res.status(500).json({
      message: "Server error",
      error: error.message,
    });
  }
}

exports.updateRecipe = async (req, res) => {
  try {
    const recipeId = req.params.id;
    const updateData = req.body;

    // Tùy vào logic, có thể kiểm tra quyền sở hữu ở đây

    const updatedRecipe = await Recipe.findByIdAndUpdate(
      recipeId,
      updateData,
      { new: true } // trả về bản ghi đã cập nhật
    );

    if (!updatedRecipe) {
      return res.status(404).json({ message: 'Không tìm thấy công thức' });
    }

    res.json(updatedRecipe);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi cập nhật công thức', error: error.message });
  }
};