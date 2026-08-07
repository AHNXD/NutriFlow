import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/dietitian_profile_providers.dart';
import '../../theme/app_theme.dart';

/// Lets the dietitian set her clinic name + logo once — both then appear on
/// every exported PDF's cover page (spec follow-up: "she can add her logo
/// and name to use in the PDF").
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameCtrl = TextEditingController();
  Uint8List? _pickedLogoBytes;
  String? _existingLogoUrl;
  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _initFromProfile(dynamic profile) {
    if (_initialized || profile == null) return;
    _initialized = true;
    _nameCtrl.text = profile.name ?? '';
    _existingLogoUrl = profile.logoUrl;
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 95);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _pickedLogoBytes = bytes);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final notifier = ref.read(dietitianProfileProvider.notifier);
    try {
      var logoUrl = _existingLogoUrl;
      if (_pickedLogoBytes != null) {
        logoUrl = await notifier.uploadLogo(_pickedLogoBytes!);
      }
      await notifier.save(
        name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
        logoUrl: logoUrl,
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('تم الحفظ')));
      }
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
    final profileAsync = ref.watch(dietitianProfileProvider);
    profileAsync.whenData(_initFromProfile);

    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('تعذّر التحميل: $e')),
        data: (_) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'الشعار والاسم يظهران في صفحة غلاف كل خطة PDF تُصدّرينها',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            _LogoPicker(
              bytes: _pickedLogoBytes,
              existingUrl: _existingLogoUrl,
              onTap: _pickLogo,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'اسم الأخصائية / العيادة',
                hintText: 'مثال: د. لينا — عيادة التغذية',
              ),
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
                  : const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoPicker extends StatelessWidget {
  const _LogoPicker({required this.bytes, required this.existingUrl, required this.onTap});

  final Uint8List? bytes;
  final String? existingUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (bytes != null) {
      child = Image.memory(bytes!, fit: BoxFit.contain);
    } else if (existingUrl != null && existingUrl!.isNotEmpty) {
      child = Image.network(existingUrl!, fit: BoxFit.contain);
    } else {
      child = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined, size: 36, color: Colors.black38),
          SizedBox(height: 8),
          Text('إضافة شعار العيادة', style: TextStyle(color: Colors.black45)),
        ],
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 160,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        child: child,
      ),
    );
  }
}
