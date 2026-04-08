const Rating = require('../models/rating');
const Recipe = require('../models/recipe');
const mongoose = require('mongoose');

// Thêm hoặc cập nhật đánh giá
exports.rateRecipe = async (req, res) => {
    try {
        const { recipeId } = req.params;
        const { stars } = req.body;
        const userId = req.userId;

        if (!stars || stars < 1 || stars > 5) {
            return res.status(400).json({ message: 'Số sao phải từ 1 đến 5' });
        }

        const session = await mongoose.startSession();
        session.startTransaction();

        try {
            // Kiểm tra xem người dùng đã đánh giá công thức này chưa
            let rating = await Rating.findOne({ user: userId, recipe: recipeId });
            const recipe = await Recipe.findById(recipeId);

            if (!recipe) {
                await session.abortTransaction();
                session.endSession();
                return res.status(404).json({ message: 'Không tìm thấy công thức' });
            }

            let oldRating = 0;
            if (rating) {
                // Lưu giá trị rating cũ trước khi cập nhật
                oldRating = rating.stars;
                // Cập nhật đánh giá hiện có
                rating.stars = stars;
                await rating.save({ session });
            } else {
                // Tạo đánh giá mới
                rating = new Rating({
                    user: userId,
                    recipe: recipeId,
                    stars
                });
                await rating.save({ session });

                // Thêm rating vào mảng ratings của recipe
                recipe.ratings.push(rating._id);
                recipe.ratingCount += 1;
            }

            // Tính lại điểm trung bình
            if (recipe.ratingCount === 1) {
                // Nếu đây là rating đầu tiên
                recipe.averageRating = stars;
            } else if (rating && oldRating > 0) {
                // Nếu đang cập nhật rating cũ
                const totalStars = (recipe.averageRating * recipe.ratingCount) - oldRating + stars;
                recipe.averageRating = totalStars / recipe.ratingCount;
            } else {
                // Nếu thêm rating mới
                const totalStars = (recipe.averageRating * (recipe.ratingCount - 1)) + stars;
                recipe.averageRating = totalStars / recipe.ratingCount;
            }

            // Đảm bảo averageRating là số hợp lệ
            if (isNaN(recipe.averageRating)) {
                recipe.averageRating = stars;
            }

            await recipe.save({ session });
            await session.commitTransaction();
            session.endSession();

            return res.status(200).json({
                message: 'Đánh giá thành công',
                rating: {
                    stars,
                    averageRating: recipe.averageRating,
                    ratingCount: recipe.ratingCount
                }
            });
        } catch (error) {
            await session.abortTransaction();
            session.endSession();
            throw error;
        }
    } catch (error) {
        console.error('Rate recipe error:', error);
        return res.status(500).json({ message: 'Lỗi server' });
    }
};

// Lấy đánh giá của người dùng cho một công thức
exports.getUserRating = async (req, res) => {
    try {
        const { recipeId } = req.params;
        const userId = req.userId;

        const rating = await Rating.findOne({ user: userId, recipe: recipeId });
        if (!rating) {
            return res.status(404).json({ message: 'Chưa có đánh giá' });
        }

        return res.status(200).json({ rating });
    } catch (error) {
        console.error('Get user rating error:', error);
        return res.status(500).json({ message: 'Lỗi server' });
    }
};

// Xóa đánh giá
exports.deleteRating = async (req, res) => {
    try {
        const { recipeId } = req.params;
        const userId = req.userId;

        const session = await mongoose.startSession();
        session.startTransaction();

        try {
            const rating = await Rating.findOne({ user: userId, recipe: recipeId });
            if (!rating) {
                await session.abortTransaction();
                session.endSession();
                return res.status(404).json({ message: 'Không tìm thấy đánh giá' });
            }

            const recipe = await Recipe.findById(recipeId);
            if (!recipe) {
                await session.abortTransaction();
                session.endSession();
                return res.status(404).json({ message: 'Không tìm thấy công thức' });
            }

            // Xóa rating khỏi mảng ratings của recipe
            recipe.ratings = recipe.ratings.filter(r => !r.equals(rating._id));
            recipe.ratingCount -= 1;

            // Tính lại điểm trung bình
            if (recipe.ratingCount > 0) {
                const allRatings = await Rating.find({ recipe: recipeId });
                const totalStars = allRatings.reduce((sum, r) => sum + r.stars, 0);
                recipe.averageRating = totalStars / allRatings.length;
            } else {
                recipe.averageRating = 0;
            }

            await Rating.findByIdAndDelete(rating._id, { session });
            await recipe.save({ session });
            await session.commitTransaction();
            session.endSession();

            return res.status(200).json({
                message: 'Xóa đánh giá thành công',
                averageRating: recipe.averageRating,
                ratingCount: recipe.ratingCount
            });
        } catch (error) {
            await session.abortTransaction();
            session.endSession();
            throw error;
        }
    } catch (error) {
        console.error('Delete rating error:', error);
        return res.status(500).json({ message: 'Lỗi server' });
    }
}; 