import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/helper_drink.dart';
import '../../models/ingredient.dart';
import '../../providers/drink_supplement_providers.dart';
import '../../widgets/ingredient_list_editor.dart';
import '../../widgets/steps_list_editor.dart';

class DrinkFormScreen extends ConsumerStatefulWidget {
  const DrinkFormScreen({super.key, this.existing});
  final HelperDrink? existing;

  @override
  ConsumerState<DrinkFormScreen> createState() => _DrinkFormScreenState();
}

class _DrinkFormScreenState extends ConsumerState<DrinkFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _timingCtrl;
  List<Ingredient> _ingredients = [];
  List<String> _steps = [];
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final d = widget.existing;
    _nameCtrl = TextEditingController(text: d?.name ?? '');
    _timingCtrl = TextEditingController(text: d?.timing ?? '');
    _ingredients = d?.ingredients ?? [];
    _steps = d?.steps ?? [];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _timingCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final notifier = ref.read(helperDrinkListProvider.notifier);
    try {
      final drink = HelperDrink(
        id: widget.existing?.id ?? const Uuid().v4(),
        name: _nameCtrl.text.trim(),
        ingredients: _ingredients,
        steps: _steps,
        timing: _timingCtrl.text.trim().isEmpty ? null : _timingCtrl.text.trim(),
      );
      if (_isEditing) {
        await notifier.updateDrink(drink);
      } else {
        await notifier.create(drink);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('تعذّر الحفظ: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'تعديل مشروب' : 'مشروب مساعد جديد')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'اسم المشروب'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _timingCtrl,
              decoration: const InputDecoration(
                labelText: 'التوقيت (مثال: مرة يوميًا بعد الغداء بساعة)',
              ),
            ),
            const SizedBox(height: 20),
            IngredientListEditor(
              initial: _ingredients,
              onChanged: (v) => _ingredients = v,
            ),
            const SizedBox(height: 20),
            StepsListEditor(
              initial: _steps,
              onChanged: (v) => _steps = v,
              label: 'طريقة التحضير',
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
                  : Text(_isEditing ? 'حفظ التعديلات' : 'إضافة المشروب'),
            ),
          ],
        ),
      ),
    );
  }
}
