import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../user/data/repositories/user_repository.dart';
import '../../user/domain/models/user.dart' as app_user;
import '../domain/models/recipe.dart';
import '../services/recipe_service.dart';
import '../../../core/constants/app_colors.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final User? author;

  const RecipeDetailScreen({
    Key? key,
    required this.recipe,
    this.author,
  }) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Recipe _recipe;
  User? _author;
  double? _userRating;
  bool _isFavorite = false;
  late final RecipeService _recipeService;
  final TextEditingController _commentController = TextEditingController();
  bool _isInitialized = false;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
    _author = widget.author;
    // Log recipe info when screen initializes
    print('Recipe Info:');
    print('ID: ${widget.recipe.id}');
    print('Title: ${widget.recipe.title}');
    print('Average Rating: ${widget.recipe.averageRating}');
    print('Rating Count: ${widget.recipe.ratingCount}');
    print('Full Recipe Object: ${widget.recipe.toString()}');

    if (widget.recipe.videoUrl != null && widget.recipe.videoUrl!.isNotEmpty) {
      _initializeVideo();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _recipeService = Provider.of<RecipeService>(context, listen: false);
      _isInitialized = true;
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    // Check auth status without affecting the UI
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = await authProvider.loadAuthData();

    if (!mounted) return;

    // Only load user-specific data if authenticated
    if (isAuthenticated && mounted) {
      await Future.wait([
        _loadReactionStatus(),
        _loadUserRating(),
        _checkFavoriteStatus(),
      ]);
    }
  }

  Future<void> _loadReactionStatus() async {
    if (!mounted) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final reactions = await _recipeService.getRecipeReactions(
        _recipe.id,
        authProvider.currentUser?.id,
      );

      if (mounted) {
        setState(() {
          _recipe.isReacted = reactions['isLiked'];
          _recipe.reactionCount = reactions['reactionCount'];
        });
      }
    } catch (e) {
      print('Error loading reaction status: $e');
    }
  }

  Future<void> _loadUserRating() async {
    if (!mounted) return;

    try {
      final rating = await _recipeService.getUserRating(_recipe.id);
      if (mounted) {
        setState(() {
          _userRating = rating['rating']?.toDouble();
        });
      }
    } catch (e) {
      print('Error loading user rating: $e');
    }
  }

  Future<void> _checkFavoriteStatus() async {
    if (!mounted) return;

    try {
      final favorites = await _recipeService.getFavoriteRecipes();
      if (mounted) {
        setState(() {
          _isFavorite = favorites.any((recipe) => recipe.id == _recipe.id);
        });
      }
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  Future<void> _initializeVideo() async {
    try {
      final videoUrl = Uri.parse('http://localhost:3000${_recipe.videoUrl}');
      _videoPlayerController =
          VideoPlayerController.network(videoUrl.toString());

      await _videoPlayerController!.initialize();

      if (mounted) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: false,
            looping: false,
            allowMuting: true,
            allowPlaybackSpeedChanging: true,
            showControls: true,
            aspectRatio: _videoPlayerController!.value.aspectRatio,
            errorBuilder: (context, errorMessage) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 30),
                    const SizedBox(height: 8),
                    Text(
                      'Lỗi khi tải video: $errorMessage',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          );
          _isVideoInitialized = true;
        });
      }
    } catch (error) {
      print('Error initializing video: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải video: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để thực hiện thao tác này'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      bool success;
      if (_isFavorite) {
        success = await _recipeService.removeFromFavorites(_recipe.id);
      } else {
        success = await _recipeService.addToFavorites(_recipe.id);
      }

      if (success && mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleReaction() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để thực hiện thao tác này'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final result = await _recipeService.toggleReaction(_recipe.id);
      if (mounted) {
        setState(() {
          _recipe.isReacted = result['isLiked'];
          _recipe.reactionCount = result['reactionCount'];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showRatingDialog() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để đánh giá'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    double tempRating = _userRating ?? 0;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đánh giá công thức'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Chọn số sao bạn muốn đánh giá:'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < tempRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () {
                    tempRating = index + 1.0;
                    (context as Element).markNeedsBuild();
                  },
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              if (tempRating > 0) {
                try {
                  final result = await _recipeService.rateRecipe(
                    _recipe.id,
                    tempRating,
                  );
                  if (mounted) {
                    setState(() {
                      _userRating = tempRating;
                      _recipe.averageRating = result['averageRating'];
                      _recipe.ratingCount = result['ratingCount'];
                    });
                  }
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đánh giá thành công!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi khi đánh giá: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Đánh giá'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 20,
            pinned: true,
            floating: false,
            backgroundColor: Colors.orange,
            elevation: 4,
            scrolledUnderElevation: 4,
            shadowColor: Colors.black26,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                icon: Icon(
                  _recipe.isReacted ? Icons.favorite : Icons.favorite_border,
                  color: _recipe.isReacted ? Colors.red : Colors.white,
                ),
                onPressed: _toggleReaction,
              ),
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Ảnh recipe
                Container(
                  width: double.infinity,
                  height: 300,
                  child: _recipe.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: 'http://localhost:3000${_recipe.imageUrl}',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.orange.shade50,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.orange.shade50,
                            child:
                                const Icon(Icons.error, color: Colors.orange),
                          ),
                        )
                      : Container(
                          color: Colors.orange.shade50,
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.orange),
                        ),
                ),
                // Nội dung recipe
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              _recipe.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildRatingStars(),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_author != null)
                        Row(
                          children: [
                            const Icon(Icons.person,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              _author!.username,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      if (_recipe.description != null &&
                          _recipe.description!.isNotEmpty)
                        Text(
                          _recipe.description!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      const SizedBox(height: 24),
                      const Text(
                        'Thời gian & Độ khó',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimeInfo(
                              'Chuẩn bị',
                              _recipe.prepTime ?? 0,
                            ),
                          ),
                          Expanded(
                            child: _buildTimeInfo(
                              'Nấu',
                              _recipe.cookTime ?? 0,
                            ),
                          ),
                          Expanded(
                            child: _buildTimeInfo(
                              'Độ khó',
                              0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Nguyên liệu',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildIngredientsList(),
                      const SizedBox(height: 24),
                      const Text(
                        'Hướng dẫn',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInstructionsList(),
                      if (_recipe.videoUrl != null &&
                          _recipe.videoUrl!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Video hướng dẫn',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_isVideoInitialized && _chewieController != null)
                          AspectRatio(
                            aspectRatio:
                                _videoPlayerController!.value.aspectRatio,
                            child: Chewie(controller: _chewieController!),
                          )
                        else
                          const Center(child: CircularProgressIndicator()),
                      ],
                      _buildRatingAndComments(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(String label, int minutes) {
    IconData getIcon() {
      switch (label) {
        case 'Chuẩn bị':
          return Icons.kitchen;
        case 'Nấu':
          return Icons.outdoor_grill;
        case 'Độ khó':
          return Icons.trending_up;
        default:
          return Icons.access_time;
      }
    }

    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(
              getIcon(),
              color: Colors.orange,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label == 'Độ khó'
                  ? (_recipe.difficulty ?? 'Chưa xác định')
                  : '$minutes phút',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recipe.ingredients.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant,
                color: Colors.orange.shade400,
                size: 20,
              ),
            ),
            title: Text(
              _recipe.ingredients[index],
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructionsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recipe.instructions.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade400,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _recipe.instructions[index],
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            if (index < _recipe.averageRating.floor()) {
              return const Icon(Icons.star, color: Colors.amber, size: 20);
            } else if (index == _recipe.averageRating.floor() &&
                _recipe.averageRating % 1 > 0) {
              return const Icon(Icons.star_half, color: Colors.amber, size: 20);
            } else {
              return const Icon(Icons.star_border,
                  color: Colors.amber, size: 20);
            }
          }),
        ),
        const SizedBox(width: 4),
        Text(
          '(${_recipe.ratingCount})',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingAndComments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Đánh giá',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đánh giá trung bình',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              _recipe.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: List.generate(5, (index) {
                                if (index < _recipe.averageRating.floor()) {
                                  return const Icon(Icons.star,
                                      color: Colors.amber, size: 24);
                                } else if (index ==
                                        _recipe.averageRating.floor() &&
                                    _recipe.averageRating % 1 > 0) {
                                  return const Icon(Icons.star_half,
                                      color: Colors.amber, size: 24);
                                } else {
                                  return const Icon(Icons.star_border,
                                      color: Colors.amber, size: 24);
                                }
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_recipe.ratingCount} lượt đánh giá',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        if (_userRating != null) ...[
                          Text(
                            'Đánh giá của bạn',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < _userRating!
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 24,
                              );
                            }),
                          ),
                        ],
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _showRatingDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(_userRating == null
                              ? 'Đánh giá ngay'
                              : 'Sửa đánh giá'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Bình luận',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildCommentsList(),
      ],
    );
  }

  Widget _buildCommentsList() {
    if (_recipe.comments.isEmpty) {
      return Column(
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Chưa có bình luận nào.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildCommentInput(),
        ],
      );
    }

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recipe.comments.length,
          itemBuilder: (context, index) {
            final comment = _recipe.comments[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(
                        comment.user?.username ?? 'Unknown User',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(comment.content ?? ''),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(comment.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildCommentInput(),
      ],
    );
  }

  Widget _buildCommentInput() {
    final commentController = TextEditingController();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: 'Thêm bình luận...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                maxLines: null,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () async {
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                if (!authProvider.isAuthenticated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng đăng nhập để bình luận'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                if (commentController.text.trim().isNotEmpty) {
                  try {
                    final updatedRecipe = await _recipeService.addComment(
                      _recipe.id,
                      commentController.text.trim(),
                    );

                    if (updatedRecipe != null) {
                      setState(() {
                        _recipe = updatedRecipe;
                      });
                      commentController.clear();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bình luận đã được thêm'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Không thể thêm bình luận'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    print('Error adding comment: $e');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Không thể thêm bình luận'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
