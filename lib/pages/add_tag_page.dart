import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:todo_app/models/tag.dart';
import 'package:todo_app/services/tag_storage_service.dart';

class AddTagPage extends StatefulWidget {
  const AddTagPage({super.key});

  @override
  _AddTagPageState createState() => _AddTagPageState();
}

class _AddTagPageState extends State<AddTagPage> {
  final TextEditingController _tagNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagColorController = TextEditingController();
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

  bool isLoading = false;

  @override
  void dispose() {
    _tagNameController.dispose();
    super.dispose();
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  Future<void> _addTag() async {
    if (_tagNameController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final tag = Tag(
        name: _tagNameController.text,
        color: _tagColorController.text.isNotEmpty
            ? _tagColorController.text
            : '#${pickerColor.value.toRadixString(16).substring(2, 8).toUpperCase()}',
        description: _descriptionController.text);

    setState(() {
      isLoading = true;
    });
    try {
      await TagStorageService.addTag(tag);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding tag')),
      );
      return;
    }

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context, tag);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tag added successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Add Tag'),
        ),
        body: Center(
          child: LoadingAnimationWidget.newtonCradle(
            color: Theme.of(context).colorScheme.primary,
            size: 50,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Tag'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _addTag,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagNameController,
                    decoration: const InputDecoration(
                      labelText: 'Tag Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                CircleAvatar(
                  backgroundColor: currentColor,
                  radius: 24.0,
                ),
                IconButton(
                  onPressed: () {
                    // Open color picker dialog
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Pick a color'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: pickerColor,
                              onColorChanged: changeColor,
                              labelTypes: const [],
                              pickerAreaHeightPercent: 0.8,
                              enableAlpha: false,
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Done'),
                              onPressed: () {
                                setState(() {
                                  currentColor = pickerColor;
                                  // Update the text field with the selected color as rgb #RRGGBB
                                  _tagColorController.text =
                                      '#${pickerColor.value.toRadixString(16).substring(2, 8).toUpperCase()}';
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.color_lens),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
