import 'package:flutter/material.dart';

/// Dynamic add/remove/reorder-free list of free-text steps, shared by the
/// recipe form and the helper-drink form.
class StepsListEditor extends StatefulWidget {
  const StepsListEditor({
    super.key,
    required this.initial,
    required this.onChanged,
    this.label = 'طريقة التحضير',
  });

  final List<String> initial;
  final ValueChanged<List<String>> onChanged;
  final String label;

  @override
  State<StepsListEditor> createState() => _StepsListEditorState();
}

class _StepsListEditorState extends State<StepsListEditor> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.initial.isEmpty
        ? [TextEditingController()]
        : widget.initial.map((s) => TextEditingController(text: s)).toList();
  }

  void _emit() {
    widget.onChanged(_controllers
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            TextButton.icon(
              onPressed: () =>
                  setState(() => _controllers.add(TextEditingController())),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('إضافة خطوة'),
            ),
          ],
        ),
        for (var i = 0; i < _controllers.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 14, left: 8),
                  child: CircleAvatar(
                    radius: 12,
                    child: Text('${i + 1}', style: const TextStyle(fontSize: 12)),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controllers[i],
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'وصف الخطوة'),
                    onChanged: (_) => _emit(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: _controllers.length == 1
                      ? null
                      : () => setState(() {
                            _controllers[i].dispose();
                            _controllers.removeAt(i);
                            _emit();
                          }),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
