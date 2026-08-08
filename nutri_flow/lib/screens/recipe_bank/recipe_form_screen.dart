import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/breakpoints.dart';
import '../../widgets/layout.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../models/ingredient.dart';
import '../../models/meal_type.dart';
import '../../models/recipe.dart';
import '../../providers/recipe_providers.dart';
import '../../widgets/ingredient_list_editor.dart';
import '../../widgets/steps_list_editor.dart';

/// Add/edit form for a single bank recipe. Pass [existing] to edit.
class RecipeFormScreen extends ConsumerStatefulWidget {
  const RecipeFormScreen({super.key, this.existing});

  final Recipe? existing;

  @override
  ConsumerState<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends ConsumerState<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _tipCtrl;
  late final TextEditingController _tagsCtrl;
  late MealType _mealType;
  List<Ingredient> _ingredients = [];
  List<String> _steps = [];

  Uint8List? _pickedImageBytes;
  String? _existingImageUrl;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final r = widget.existing;
    _nameCtrl = TextEditingController(text: r?.name ?? '');
    _tipCtrl = TextEditingController(text: r?.tip ?? '');
    _tagsCtrl = TextEditingController(text: r?.tags.join('، ') ?? '');
    _mealType = r?.mealType ?? MealType.breakfast;
    _ingredients = r?.ingredients ?? [];
    _steps = r?.steps ?? [];
    _existingImageUrl = r?.imageUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tipCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _pickedImageBytes = bytes);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final notifier = ref.read(recipeListProvider.notifier);
    try {
      final tags = _tagsCtrl.text
          .split(RegExp(r'[،,]'))
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final recipe = Recipe(
        id: widget.existing?.id ?? const Uuid().v4(),
        name: _nameCtrl.text.trim(),
        mealType: _mealType,
        imageUrl: _existingImageUrl,
        ingredients: _ingredients,
        steps: _steps,
        tip: _tipCtrl.text.trim().isEmpty ? null : _tipCtrl.text.trim(),
        tags: tags,
      );

      final saved = _isEditing
          ? await notifier.updateRecipe(recipe)
          : await notifier.createRecipe(recipe);

      if (_pickedImageBytes != null) {
        final url = await notifier.uploadImage(
          recipeId: saved.id,
          bytes: _pickedImageBytes!,
        );
        await notifier.updateRecipe(saved.copyWith(imageUrl: url));
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تعذّر الحفظ: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل أكلة' : 'إضافة أكلة جديدة'),
      ),
      body: PageBody(
        maxWidth: Breakpoints.maxFormWidth,
        padding: EdgeInsets.zero,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ImagePicker(
                bytes: _pickedImageBytes,
                existingUrl: _existingImageUrl,
                onTap: _pickImage,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'اسم الأكلة'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<MealType>(
                initialValue: _mealType,
                decoration: const InputDecoration(labelText: 'نوع الوجبة'),
                items: MealType.values
                    .map(
                      (m) => DropdownMenuItem(value: m, child: Text(m.labelAr)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _mealType = v ?? _mealType),
              ),
              const SizedBox(height: 20),
              IngredientListEditor(
                initial: _ingredients,
                onChanged: (v) => _ingredients = v,
              ),
              const SizedBox(height: 20),
              StepsListEditor(initial: _steps, onChanged: (v) => _steps = v),
              const SizedBox(height: 20),
              TextFormField(
                controller: _tipCtrl,
                decoration: const InputDecoration(
                  labelText: 'نصيحة خاصة بالوصفة (اختياري)',
                ),
                minLines: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagsCtrl,
                decoration: const InputDecoration(
                  labelText: 'وسوم (افصل بفاصلة، مثل: عالي بروتين، نباتي)',
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'حفظ التعديلات' : 'إضافة الأكلة'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePicker extends StatelessWidget {
  const _ImagePicker({
    required this.bytes,
    required this.existingUrl,
    required this.onTap,
  });

  final Uint8List? bytes;
  final String? existingUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (bytes != null) {
      child = Image.memory(bytes!, fit: BoxFit.cover);
    } else if (existingUrl != null && existingUrl!.isNotEmpty) {
      child = Image.network(existingUrl!, fit: BoxFit.cover);
    } else {
      child = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 36,
            color: Colors.black38,
          ),
          SizedBox(height: 8),
          Text('إضافة صورة', style: TextStyle(color: Colors.black45)),
        ],
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 180,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        child: child,
      ),
    );
  }
}
