import 'package:flutter/material.dart';

/// Generic single-multiline-text-field add/edit dialog. Returns the trimmed
/// text, or null if cancelled/empty.
Future<String?> showTextFieldDialog(
  BuildContext context, {
  required String title,
  String initial = '',
  String hint = '',
  String confirmLabel = 'حفظ',
}) async {
  final controller = TextEditingController(text: initial);
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        minLines: 1,
        maxLines: 5,
        decoration: InputDecoration(hintText: hint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () {
            final text = controller.text.trim();
            Navigator.pop(context, text.isEmpty ? null : text);
          },
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}
