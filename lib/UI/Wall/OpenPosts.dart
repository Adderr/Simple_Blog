import 'package:flutter/material.dart';
import 'package:simple_blog/services/post_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:simple_blog/UI/BaceFook.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_blog/Database/db_client.dart';
import 'package:simple_blog/services/services.dart';

class PostDetail extends StatefulWidget {
  final String postId;
  const PostDetail({super.key, required this.postId});

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final _services = AuthService();
  bool get _isOwner =>
      _post != null && _post!['user_id'] == _services.currentUser?.id;
  List get images => (_post?['post_images'] as List?) ?? [];
  final _postsServices = PostServices();
  Map<String, dynamic>? _post;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _handleDelete() async {
    try {
      await _postsServices.deletePost(postId: widget.postId);
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _loadPost() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final post = await _postsServices.getPostById(widget.postId);
      setState(() {
        _post = post;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaceFook(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _post == null
          ? const Center(child: Text('Post not found'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _post!['title'],
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _post!['content'],
                      style: const TextStyle(color: Colors.white70),
                    ),
                    SizedBox(height: 15),
                    if (images.isNotEmpty)
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 450),
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            final imageUrl = images[index]['image_url'];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Image.network(
                                imageUrl,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                    SizedBox(height: 20),
                    if (_isOwner)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (_isOwner)
                            TextButton(
                              onPressed: () => context.go(
                                '/BaceFook/Posts/${widget.postId}/edit',
                              ),
                              child: const Text('Edit'),
                              style: TextButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 16),
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  0,
                                  0,
                                  112,
                                ),
                                foregroundColor: const Color.fromARGB(
                                  255,
                                  90,
                                  181,
                                  250,
                                ),
                              ),
                            ),
                          SizedBox(width: 15),
                          TextButton(
                            onPressed: _handleDelete,
                            child: const Text('Delete'),
                            style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 16),
                              backgroundColor: const Color.fromARGB(
                                255,
                                255,
                                0,
                                0,
                              ),
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
                  ],
                ),
              ),
            ),
      backgroundColor: const Color.fromARGB(255, 0, 21, 38),
    );
  }
}
