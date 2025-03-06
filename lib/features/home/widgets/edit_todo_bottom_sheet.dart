import 'package:flutter/material.dart';
import '../../../models/todo_model.dart';

class EditTodoBottomSheet extends StatefulWidget {
  final Todo todo;

  const EditTodoBottomSheet({
    super.key,
    required this.todo,
  });

  @override
  State<EditTodoBottomSheet> createState() => _EditTodoBottomSheetState();
}

class _EditTodoBottomSheetState extends State<EditTodoBottomSheet> {
  late final TextEditingController _todoController;

  @override
  void initState() {
    super.initState();
    _todoController = TextEditingController(text: widget.todo.todo);
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  void _updateTodo() {
    if (_todoController.text.trim().isEmpty) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Edit Todo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _todoController,
            decoration: const InputDecoration(
              labelText: 'Todo',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _updateTodo,
            child: const Text('Update Todo'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
