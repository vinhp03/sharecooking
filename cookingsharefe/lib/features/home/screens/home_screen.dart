import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import '../../../core/providers/auth_provider.dart';
import '../../recipes/domain/models/recipe.dart';
import '../../recipes/services/recipe_service.dart';
import '../../recipes/screens/recipe_detail_screen.dart';
import '../../search/screens/search_screen.dart';
import '../widgets/app_drawer.dart';
import '../../recipes/screens/add_recipe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late RecipeService _recipeService;
  List<Recipe> _recipes = [];
  List<String> _categories = ['Tất cả'];
  String _selectedCategory = 'Tất cả';
  bool _isLoading = true;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _recipeService = Provider.of<RecipeService>(context);
      _loadRecipes();
      _isInitialized = true;
    }
  }

  Future<void> _loadRecipes() async {
    try {
      final recipes = await _recipeService.getAllRecipes();
      print('Loaded recipes: ${recipes.length}');

      // Extract unique tags from recipes
      final Set<String> uniqueTags = {'Tất cả'};
      for (var recipe in recipes) {
        uniqueTags.addAll(recipe.tag);
      }

      if (mounted) {
        setState(() {
          _recipes = recipes;
          _categories = uniqueTags.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading recipes: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading recipes: $e')),
        );
      }
    }
  }

  List<Recipe> get _filteredRecipes {
    if (_selectedCategory == 'Tất cả') {
      return _recipes;
    }
    return _recipes
        .where((recipe) => recipe.tag.contains(_selectedCategory))
        .toList();
  }

  Widget _buildCategoryChip(String category, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedCategory = selected ? category : 'Tất cả';
          });
        },
        backgroundColor: isSelected ? Colors.orange : Colors.grey[200],
        selectedColor: Colors.orange,
        showCheckmark: false,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isSelected
              ? const BorderSide(color: Colors.orange, width: 1)
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    // Tính tổng thời gian nấu (thời gian chuẩn bị + thời gian nấu)
    final int totalTime = (recipe.prepTime ?? 0) + (recipe.cookTime ?? 0);
    final String cookingTimeText =
        totalTime > 0 ? '$totalTime phút' : 'Không xác định';

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: recipe.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: 'http://localhost:3000${recipe.imageUrl}',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Thời gian nấu
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.orange.withOpacity(0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      cookingTimeText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      recipe.isReacted ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: recipe.isReacted
                          ? Colors.red
                          : Colors.orange.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.reactionCount}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.comment_outlined,
                      size: 16,
                      color: Colors.orange.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.comments.length}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cooking Share',
          style: GoogleFonts.dancingScript(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRecipes,
              color: Colors.orange,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _categories
                                  .map((category) => _buildCategoryChip(
                                        category,
                                        category == _selectedCategory,
                                      ))
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Món ăn nổi bật',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFeaturedRecipes(),
                          const SizedBox(height: 24),
                          const Text(
                            'Tất cả món ăn',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childCount: _filteredRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _filteredRecipes[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RecipeDetailScreen(recipe: recipe),
                              ),
                            );
                          },
                          child: _buildRecipeCard(recipe),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: authProvider.isAuthenticated
          ? Stack(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddRecipeScreen(),
                      ),
                    );
                  },
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.restaurant),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: Colors.orange, width: 2),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.orange,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddRecipeScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildFeaturedRecipes() {
    // Lấy 5 món ăn có nhiều lượt thích nhất
    final featuredRecipes = List<Recipe>.from(_recipes)
      ..sort((a, b) => b.reactionCount.compareTo(a.reactionCount));
    final topRecipes = featuredRecipes.take(5).toList();

    if (topRecipes.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('Không có món ăn nổi bật'),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: FlutterCarousel(
        options: CarouselOptions(
          height: 220,
          showIndicator: true,
          viewportFraction: 0.8,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 3),
          enableInfiniteScroll: true,
          enlargeCenterPage: true,
        ),
        items: topRecipes
            .map((recipe) => _buildFeaturedRecipeCard(recipe))
            .toList(),
      ),
    );
  }

  Widget _buildFeaturedRecipeCard(Recipe recipe) {
    // Tính tổng thời gian nấu (thời gian chuẩn bị + thời gian nấu)
    final int totalTime = (recipe.prepTime ?? 0) + (recipe.cookTime ?? 0);
    final String cookingTimeText =
        totalTime > 0 ? '$totalTime phút' : 'Không xác định';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Hình ảnh món ăn
              SizedBox(
                width: double.infinity,
                height: 220,
                child: recipe.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: 'http://localhost:3000${recipe.imageUrl}',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
              // Thông tin món ăn
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Thời gian nấu
                          const Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            cookingTimeText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Độ khó
                          const Icon(
                            Icons.restaurant,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getDifficultyText(recipe.difficulty ?? 'medium'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'Dễ';
      case 'medium':
        return 'Trung bình';
      case 'hard':
        return 'Khó';
      default:
        return 'Trung bình';
    }
  }
}
