import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_blog/UI/BaceFook.dart';
import 'package:simple_blog/services/post_services.dart';
import 'dart:typed_data';

class CreatePosts extends StatefulWidget {
  final String? postId;
  const CreatePosts({super.key, this.postId});

  @override
  State<CreatePosts> createState() => _CreatePostsState();
}

class _CreatePostsState extends State<CreatePosts> {
  final _key = GlobalKey<FormState>();
  final postServices = PostServices();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isloading = false;
  bool get _isEditMode => widget.postId != null;
  String? _errorMessage;
  List<XFile> _pickedImages = [];
  List<Map<String, dynamic>> _existingImages = [];

  Future<void> _pickImages() async {
    final images = await postServices.pickImages();
    setState(() {
      _pickedImages = images;
    });
  }

  void _removePickedImage(XFile file) {
    setState(() {
      _pickedImages.remove(file);
    });
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();

    if (_isEditMode) {
      _loadExistingPost();
    }
  }

  Future<void> _loadExistingPost() async {
    final post = await postServices.getPostById(widget.postId!);
    setState(() {
      _titleController.text = post['title'];
      _contentController.text = post['content'];
      _existingImages = List<Map<String, dynamic>>.from(
        post['post_images'] ?? [],
      );
    });
  }

  Future<void> _deleteExistingImage(String imageId) async {
    await postServices.deletePostImage(imageId);
    setState(() {
      _existingImages.removeWhere((img) => img['id'] == imageId);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    if (_key.currentState!.validate()) {
      setState(() {
        _isloading = true;
        _errorMessage = null;
      });
      try {
        String postId;
        if (_isEditMode) {
          postId = widget.postId!;
          await postServices.updatePost(
            postId: postId,
            title: _titleController.text,
            content: _contentController.text,
          );
        } else {
          final newPost = await postServices.createPost(
            title: _titleController.text,
            content: _contentController.text,
          );
          postId = newPost['id'];
        }

        for (final image in _pickedImages) {
          final imageUrl = await postServices.uploadPostImage(
            file: image,
            postId: postId,
          );
          await postServices.addPostImage(postId: postId, imageUrl: imageUrl);
        }

        if (mounted) {
          context.go('/');
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        setState(() {
          _isloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaceFook(),
      body: Form(
        key: _key,
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                  const SizedBox(height: 100.0),
                  Text(
                    _isEditMode ? 'Edit Post' : 'Create Post',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 90, 181, 250),
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _titleController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 90, 181, 250),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Content is required';
                      }
                      return null;
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 90, 181, 250),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _isloading ? null : _createPost,
                        child: Text(_isEditMode ? 'Update' : 'Post'),
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 16),
                          backgroundColor: const Color.fromARGB(255, 0, 0, 112),
                          foregroundColor: const Color.fromARGB(
                            255,
                            90,
                            181,
                            250,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      TextButton(
                        onPressed: _pickImages,
                        child: const Text('Upload Image'),
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 16),
                          backgroundColor: const Color.fromARGB(255, 0, 0, 112),
                          foregroundColor: const Color.fromARGB(
                            255,
                            90,
                            181,
                            250,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  if (_isEditMode && _existingImages.isNotEmpty)
                    SizedBox(
                      height: 100,
                      width: (_existingImages.length * 88).toDouble(),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _existingImages.map((img) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: Stack(
                                children: [
                                  Image.network(
                                    img['image_url'],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _deleteExistingImage(img['id']),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 10.0),
                  if (_pickedImages.isNotEmpty)
                    SizedBox(
                      height: 100,
                      width: (_pickedImages.length * 88).toDouble(),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _pickedImages.map((file) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: Stack(
                                children: [
                                  FutureBuilder<Uint8List>(
                                    future: file.readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      if (snapshot.hasData) {
                                        return Image.memory(
                                          snapshot.data!,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        );
                                      }
                                      return const SizedBox(
                                        width: 80,
                                        height: 80,
                                      );
                                    },
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => _removePickedImage(file),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 1, 0, 34),
    );
  }
}
