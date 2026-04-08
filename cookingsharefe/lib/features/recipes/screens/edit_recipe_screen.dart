import 'package:flutter/material.dart';
import '../domain/models/recipe.dart';
import 'package:provider/provider.dart';
import '../services/recipe_service.dart';

class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;
  const EditRecipeScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _ingredientsController;
  late TextEditingController _instructionsController;
  late TextEditingController _prepTimeController;
  late TextEditingController _cookTimeController;
  late TextEditingController _difficultyController;
  late TextEditingController _tagController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.recipe.title);
    _descriptionController =
        TextEditingController(text: widget.recipe.description);
    _ingredientsController =
        TextEditingController(text: widget.recipe.ingredients.join('\n'));
    _instructionsController =
        TextEditingController(text: widget.recipe.instructions.join('\n'));
    _prepTimeController =
        TextEditingController(text: widget.recipe.prepTime?.toString() ?? '');
    _cookTimeController =
        TextEditingController(text: widget.recipe.cookTime?.toString() ?? '');
    _difficultyController =
        TextEditingController(text: widget.recipe.difficulty ?? '');
    _tagController = TextEditingController(
        text: widget.recipe.tag != null ? widget.recipe.tag.join(', ') : '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _difficultyController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final recipeService = Provider.of<RecipeService>(context, listen: false);
    final data = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'ingredients': _ingredientsController.text.trim().split('\n'),
      'instructions': _instructionsController.text.trim().split('\n'),
      'prepTime': int.tryParse(_prepTimeController.text.trim()) ?? 0,
      'cookTime': int.tryParse(_cookTimeController.text.trim()) ?? 0,
      'difficulty': _difficultyController.text.trim(),
      'tag':
          _tagController.text.trim().split(',').map((e) => e.trim()).toList(),
    };
    final success = await recipeService.updateRecipe(widget.recipe.id, data);
    setState(() => _isLoading = false);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Cập nhật thành công!'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Cập nhật thất bại!'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa công thức'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tên món ăn'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Không được để trống'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                    labelText: 'Nguyên liệu (mỗi dòng 1 nguyên liệu)'),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                    labelText: 'Hướng dẫn (mỗi dòng 1 bước)'),
                maxLines: 6,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _prepTimeController,
                      decoration: const InputDecoration(
                          labelText: 'Thời gian chuẩn bị (phút)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cookTimeController,
                      decoration: const InputDecoration(
                          labelText: 'Thời gian nấu (phút)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _difficultyController,
                decoration: const InputDecoration(labelText: 'Độ khó'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagController,
                decoration: const InputDecoration(
                    labelText: 'Tag (phân cách bằng dấu phẩy)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Lưu thay đổi',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
