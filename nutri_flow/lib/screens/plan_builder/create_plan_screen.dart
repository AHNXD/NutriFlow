import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/plan.dart';
import '../../providers/dietitian_profile_providers.dart';
import '../../providers/plan_providers.dart';
import '../../theme/pdf_themes.dart';
import '../../widgets/pdf_layout_picker.dart';
import '../../widgets/layout.dart';
import '../../widgets/pdf_theme_picker.dart';

class CreatePlanScreen extends ConsumerStatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  ConsumerState<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends ConsumerState<CreatePlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientCtrl = TextEditingController();
  final _dietitianCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '7');
  final _fastingHoursCtrl = TextEditingController();
  final _fastingNotesCtrl = TextEditingController();
  final _generalNotesCtrl = TextEditingController();
  String _theme = 'emerald';
  String _pdfLayout = 'aurora';
  bool _saving = false;
  bool _dietitianPrefilled = false;

  @override
  void dispose() {
    _patientCtrl.dispose();
    _dietitianCtrl.dispose();
    _durationCtrl.dispose();
    _fastingHoursCtrl.dispose();
    _fastingNotesCtrl.dispose();
    _generalNotesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final plan = Plan(
        id: const Uuid().v4(),
        patientName: _patientCtrl.text.trim(),
        dietitianName: _dietitianCtrl.text.trim(),
        durationDays: int.tryParse(_durationCtrl.text.trim()) ?? 7,
        fastingHours: _fastingHoursCtrl.text.trim().isEmpty
            ? null
            : int.tryParse(_fastingHoursCtrl.text.trim()),
        fastingNotes: _fastingNotesCtrl.text.trim().isEmpty
            ? null
            : _fastingNotesCtrl.text.trim(),
        generalNotes: _generalNotesCtrl.text.trim().isEmpty
            ? null
            : _generalNotesCtrl.text.trim(),
        theme: _theme,
        pdfLayout: _pdfLayout,
      );
      final created = await ref.read(planListProvider.notifier).create(plan);
      if (mounted) Navigator.pop(context, created);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تعذّر إنشاء الخطة: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prefill the dietitian name from the saved profile (Settings) once,
    // without overwriting anything already typed.
    final profile = ref.watch(dietitianProfileProvider).valueOrNull;
    if (!_dietitianPrefilled &&
        profile?.name != null &&
        _dietitianCtrl.text.isEmpty) {
      _dietitianPrefilled = true;
      _dietitianCtrl.text = profile!.name!;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('خطة جديدة')),
      body: PageBody.form(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _patientCtrl,
                decoration: const InputDecoration(labelText: 'اسم المريض/ة'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dietitianCtrl,
                decoration: const InputDecoration(labelText: 'اسم الأخصائي/ة'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationCtrl,
                decoration: const InputDecoration(labelText: 'عدد الأيام'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v?.trim() ?? '');
                  if (n == null || n < 1 || n > 31) {
                    return 'الرجاء إدخال رقم بين 1 و31';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fastingHoursCtrl,
                decoration: const InputDecoration(
                  labelText: 'ساعات الصيام (اختياري، مثال: 16)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fastingNotesCtrl,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات الصيام (اختياري)',
                ),
                minLines: 1,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _generalNotesCtrl,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات عامة (اختياري)',
                ),
                minLines: 1,
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              PdfThemePicker(
                selected: _theme,
                onChanged: (id) => setState(() => _theme = id),
              ),
              const SizedBox(height: 20),
              PdfLayoutPicker(
                selected: _pdfLayout,
                theme: PdfThemes.byId(_theme),
                onChanged: (id) => setState(() => _pdfLayout = id),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('إنشاء الخطة ومتابعة بناء الأيام'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
