import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:todo_app/models/tag.dart';
import 'package:todo_app/services/tag_storage_service.dart';

class TagsPage extends StatefulWidget {
  const TagsPage({Key? key}) : super(key: key);

  @override
  _TagsPageState createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {

  bool isLoading = true;
  List<Tag> tags = []; // Replace with your actual tag model

  @override
  void initState() {
    super.initState();
    // Initialize any data or state here if needed
    fetchTags();
  }

  Future<void> fetchTags() async {
    tags = await TagStorageService.fetchTags();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    if(isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tags'),
        ),
        body:  Center(
            child: LoadingAnimationWidget.newtonCradle(
              color: Theme.of(context).colorScheme.primary,
              size: 50,
            ),
          )
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        child: ListView.builder(
            itemCount: tags.length,
            itemBuilder: (context, index) {
              final tag = tags[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  title: tag.isDeleted 
                      ? Text(
                          tag.name,
                          style: const TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        )
                      : Text(tag.name),
                  subtitle: tag.description.isNotEmpty ? (tag.isDeleted 
                      ? Text(
                          tag.description,
                          style: const TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        )
                      : Text(tag.description)) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade400)),
                  leading: CircleAvatar(
                    backgroundColor: tag.isDeleted ? Colors.grey : Color(int.parse(tag.color.replaceFirst('#', '0xff'))),
                    child: Text(tag.name[0].toUpperCase()),
                  ),
                  trailing: PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      if(tag.isDeleted) 
                        const PopupMenuItem(
                          value: 'restore',
                          child: Text('Restore'),
                        ),
                      if(!tag.isDeleted)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      if(!tag.isDeleted)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'edit') {
                        // Navigate to edit tag page or show dialog
                        final result = await Navigator.pushNamed(context, '/edit-tag', arguments: tag);
                        if (result != null && result is Tag) {
                          setState(() {
                            tags[index] = result; // Update the tag in the list
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${result.name} updated successfully'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      } else if (value == 'delete') {
                        setState(() {
                          isLoading = true;
                        });
                        // Handle delete tag action
                        await TagStorageService.deleteTag(tag.id);

                        setState(() {
                        // Check if has ScaffoldMessenger
                          tag.isDeleted = true;
                          isLoading = false;
                        });
                      } else if (value == 'restore') {
                        setState(() {
                          isLoading = true;
                        });
                        // Handle restore tag action
                        await TagStorageService.restoreTag(tag.id);

                        setState(() {
                          tag.isDeleted = false;
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${tag.name} restored successfully'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          final result = await Navigator.pushNamed(context, '/add-tag');
          if (result != null && result is Tag) {
            setState(() {
              tags.add(result);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
