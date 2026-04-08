import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../recipes/domain/models/recipe.dart';
import '../../recipes/services/recipe_service.dart';
import '../../recipes/screens/recipe_detail_screen.dart';
import '../../recipes/screens/edit_recipe_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  List<Recipe> _userRecipes = [];
  bool _isLoadingRecipes = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _bioController = TextEditingController();
    _loadUserRecipes();
  }

  Future<void> _loadUserRecipes() async {
    if (!mounted) return;
    setState(() => _isLoadingRecipes = true);
    try {
      final recipeService = Provider.of<RecipeService>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        final recipes = await recipeService.getAllRecipes();
        if (mounted) {
          setState(() {
            _userRecipes = recipes.where((recipe) {
              final userMap = recipe.user;
              return userMap != null &&
                  userMap.id == authProvider.currentUser!.id;
            }).toList();
          });
        }
      }
    } catch (e) {
      print('Error loading user recipes: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingRecipes = false);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;
        final isAuthenticated = authProvider.isAuthenticated;

        if (!isAuthenticated || user == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Hồ sơ'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Vui lòng đăng nhập để xem thông tin tài khoản',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Đăng nhập'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!_isEditing) {
          _usernameController.text = user.username;
          _bioController.text = user.bio ?? '';
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Hồ sơ của tôi'),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            titleTextStyle: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w500,
            ),
            actions: [
              IconButton(
                icon: Icon(_isEditing ? Icons.save : Icons.edit),
                onPressed: () {
                  if (_isEditing) {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Implement save profile logic
                      setState(() => _isEditing = false);
                    }
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage:
                            user.avatar != null && user.avatar!.isNotEmpty
                                ? NetworkImage(
                                    'http://localhost:3000${user.avatar}')
                                : null,
                        child: user.avatar == null || user.avatar!.isEmpty
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 18),
                              color: Colors.white,
                              onPressed: () {
                                // TODO: Implement image picker
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _isEditing
                      ? TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Tên người dùng',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập tên người dùng';
                            }
                            return null;
                          },
                        )
                      : Text(
                          user.username,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  _isEditing
                      ? TextFormField(
                          controller: _bioController,
                          decoration: const InputDecoration(
                            labelText: 'Tiểu sử',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        )
                      : Text(
                          user.bio ?? 'Chưa có tiểu sử',
                          style: TextStyle(color: Colors.grey[800]),
                          textAlign: TextAlign.center,
                        ),                  
                  const SizedBox(height: 32),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Công thức món ăn của tôi',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  _isLoadingRecipes
                      ? const Center(child: CircularProgressIndicator())
                      : _userRecipes.isEmpty
                          ? const Center(
                              child: Text('Bạn chưa đăng công thức nào'),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _userRecipes.length,
                              itemBuilder: (context, index) {
                                final recipe = _userRecipes[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16.0),
                                  child: ListTile(
                                    leading: recipe.imageUrl != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              'http://localhost:3000${recipe.imageUrl}',
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                width: 60,
                                                height: 60,
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                    Icons.restaurant),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.restaurant),
                                          ),
                                    title: Text(recipe.title),
                                    subtitle: Text(
                                      recipe.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RecipeDetailScreen(
                                                  recipe: recipe),
                                        ),
                                      );
                                    },
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: Colors.orange),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditRecipeScreen(
                                                        recipe: recipe),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () async {
                                            final confirm =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title:
                                                    const Text('Xác nhận xoá'),
                                                content: const Text(
                                                    'Bạn có chắc muốn xoá công thức này?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(false),
                                                    child: const Text('Huỷ'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(true),
                                                    child: const Text('Xoá',
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              final recipeService =
                                                  Provider.of<RecipeService>(
                                                      context,
                                                      listen: false);
                                              final success =
                                                  await recipeService
                                                      .deleteRecipe(recipe.id);
                                              if (success) {
                                                setState(() {
                                                  _userRecipes.removeAt(index);
                                                });
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'Đã xoá công thức!'),
                                                      backgroundColor:
                                                          Colors.green),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content:
                                                          Text('Xoá thất bại!'),
                                                      backgroundColor:
                                                          Colors.red),
                                                );
                                              }
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
