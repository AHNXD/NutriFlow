import 'package:flutter/material.dart';

/// Generic single-multiline-text-field add/edit dialog. Returns the trimmed
/// text, or null if cancelled/empty.
Future<String?> showTextFieldDialog(
  BuildContext context, {
  required String title,
  String initial = '',
  String hint = '',
  String confirmLabel = 'حفظ',
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _TextFieldDialog(
      title: title,
      initial: initial,
      hint: hint,
      confirmLabel: confirmLabel,
    ),
  );
}

class _TextFieldDialog extends StatefulWidget {
  const _TextFieldDialog({
    required this.title,
    required this.initial,
    required this.hint,
    required this.confirmLabel,
  });

  final String title;
  final String initial;
  final String hint;
  final String confirmLabel;

  @override
  State<_TextFieldDialog> createState() => _TextFieldDialogState();
}

class _TextFieldDialogState extends State<_TextFieldDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    // Safe here (unlike disposing right after `await showDialog(...)`
    // returns in the caller): the framework only calls this once the
    // dialog route — and this TextField along with it — has actually
    // finished unmounting, well after its exit animation completes.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 1,
        maxLines: 5,
        decoration: InputDecoration(hintText: widget.hint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () {
            final text = _controller.text.trim();
            Navigator.pop(context, text.isEmpty ? null : text);
          },
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
