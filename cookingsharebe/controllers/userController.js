const User = require("../models/User")

exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.find().select("-password");
    return res.status(200).json(users);
  } catch (error) {
    return res.status(500).json({ message : "Server error:" , error: error.message});
  }
}

exports.getUserProfile = async (req, res) => {
  try {
    // Lấy userId từ request (được set bởi authMiddleware)
    const userId = req.userId;
    console.log('Looking up user with ID:', userId);
    
    // Kiểm tra xem có userId không
    if (!userId) {
      return res.status(401).json({ message: "Không tìm thấy thông tin người dùng trong token" });
    }

    // Tìm user và populate thêm thông tin followers/following
    const user = await User.findById(userId)
      .select("-password -refreshToken")
      .populate('followers', 'username email')
      .populate('following', 'username email');

    console.log('Found user:', user);

    // Kiểm tra xem có tìm thấy user không
    if (!user) {
      console.log('No user found with ID:', userId);
      return res.status(404).json({ message: "Không tìm thấy thông tin người dùng" });
    }

    return res.status(200).json({
      user,
      message: "Lấy thông tin profile thành công"
    });
  } catch (error) {
    console.error("Error in getUserProfile:", error);
    return res.status(500).json({ 
      message: "Lỗi khi lấy thông tin profile",
      error: error.message 
    });
  }
}

exports.updateUserProfile = async (req, res) => {
  const { email, username} = req.body;
  try {
    const user = await User.findByIdAndUpdate(
      req.userId,
      { email, username },
      { new: true }
    );
    return res.status(200).json(user);
  } catch (error) {
    return res.status(500).json({massage: "Server  error", error: error.massage})
  }  
}


exports.addFavoriteRecipe = async (req, res) => {
  try {
    const userId = req.userId;
    const recipeId = req.params.recipeId;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Kiểm tra xem công thức đã có trong danh sách yêu thích chưa
    if (user.favouriterecipe.includes(recipeId)) {
      return res.status(400).json({ message: "Recipe already in favorites" });
    }

    // Thêm công thức vào danh sách yêu thích và tăng số lượng
    user.favouriterecipe.push(recipeId);
    user.favouritecount += 1;
    await user.save();

    return res.status(200).json({ 
      message: "Recipe added to favorites successfully",
      favouritecount: user.favouritecount
    });
  } catch (error) {
    return res.status(500).json({ message: "Server error", error: error.message });
  }
};

exports.removeFavoriteRecipe = async (req, res) => {
  try {
    const userId = req.userId;
    const recipeId = req.params.recipeId;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Kiểm tra xem công thức có trong danh sách yêu thích không
    if (!user.favouriterecipe.includes(recipeId)) {
      return res.status(400).json({ message: "Recipe not in favorites" });
    }

    // Xóa công thức khỏi danh sách yêu thích và giảm số lượng
    user.favouriterecipe = user.favouriterecipe.filter(id => id.toString() !== recipeId);
    user.favouritecount -= 1;
    await user.save();

    return res.status(200).json({ 
      message: "Recipe removed from favorites successfully",
      favouritecount: user.favouritecount
    });
  } catch (error) {
    return res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Follow a user
exports.followUser = async (req, res) => {
  try {
    const userToFollow = await User.findById(req.params.id);
    const currentUser = await User.findById(req.user.id);

    if (!userToFollow || !currentUser) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng' });
    }

    // Kiểm tra xem đã follow chưa
    if (currentUser.following.includes(userToFollow._id)) {
      return res.status(400).json({ message: 'Bạn đã theo dõi người dùng này rồi' });
    }

    // Thêm vào danh sách following của current user
    currentUser.following.push(userToFollow._id);
    // Thêm vào danh sách followers của user được follow
    userToFollow.followers.push(currentUser._id);

    await Promise.all([currentUser.save(), userToFollow.save()]);

    res.json({ 
      message: 'Theo dõi thành công',
      followersCount: userToFollow.followersCount,
      followingCount: currentUser.followingCount
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Unfollow a user
exports.unfollowUser = async (req, res) => {
  try {
    const userToUnfollow = await User.findById(req.params.id);
    const currentUser = await User.findById(req.user.id);

    if (!userToUnfollow || !currentUser) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng' });
    }

    // Kiểm tra xem có đang follow không
    if (!currentUser.following.includes(userToUnfollow._id)) {
      return res.status(400).json({ message: 'Bạn chưa theo dõi người dùng này' });
    }

    // Xóa khỏi danh sách following của current user
    currentUser.following = currentUser.following.filter(
      id => id.toString() !== userToUnfollow._id.toString()
    );
    // Xóa khỏi danh sách followers của user được unfollow
    userToUnfollow.followers = userToUnfollow.followers.filter(
      id => id.toString() !== currentUser._id.toString()
    );

    await Promise.all([currentUser.save(), userToUnfollow.save()]);

    res.json({ 
      message: 'Đã hủy theo dõi',
      followersCount: userToUnfollow.followersCount,
      followingCount: currentUser.followingCount
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get user's followers
exports.getFollowers = async (req, res) => {
  try {
    const user = await User.findById(req.params.id)
      .populate('followers', 'username email')
      .select('followers followersCount');

    if (!user) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng' });
    }

    res.json({
      followers: user.followers,
      count: user.followersCount
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get user's following
exports.getFollowing = async (req, res) => {
  try {
    const user = await User.findById(req.params.id)
      .populate('following', 'username email')
      .select('following followingCount');

    if (!user) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng' });
    }

    res.json({
      following: user.following,
      count: user.followingCount
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};