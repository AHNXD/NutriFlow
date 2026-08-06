import 'package:flutter/material.dart';

/// Shows a confirmation dialog and returns true only if the user confirmed.
Future<bool> confirmDelete(
  BuildContext context, {
  required String title,
  String message = 'لا يمكن التراجع عن هذا الإجراء.',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('حذف'),
        ),
      ],
    ),
  );
  return result ?? false;
}
