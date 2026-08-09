import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_blog/UI/BaceFook.dart';
import 'package:simple_blog/Database/db_client.dart';
import 'package:simple_blog/services/services.dart';
import 'package:simple_blog/services/post_services.dart';
import 'package:simple_blog/UI/Profile/userProfile.dart';

class Wall extends StatefulWidget {
  const Wall({super.key});

  @override
  State<Wall> createState() => _WallState();
}

class _WallState extends State<Wall> {
  final _services = AuthService();
  final _postsServices = PostServices();
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  String? _error;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final posts = await _postsServices.getPosts(page: _page);
      setState(() {
        _posts.addAll(posts);
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
      appBar: BaceFook(
        onLogoPress: () {
          context.go('/');
          setState(() {
            _posts.clear();
            _page = 0;
          });
          _loadPosts();
        },
        actions: _services.isLoggedIn
            ? [
                TextButton(
                  onPressed: () {
                    context.go('/BaceFook/Profile');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 1, 0, 34),
                  ),
                  child: const Text(
                    'Profile',
                    style: TextStyle(
                      color: Color.fromARGB(255, 90, 181, 250),
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                TextButton(
                  onPressed: () {
                    context.go('/BaceFook/Posts');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 1, 0, 34),
                  ),
                  child: const Text(
                    'Create Post',
                    style: TextStyle(
                      color: Color.fromARGB(255, 90, 181, 250),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                TextButton(
                  onPressed: () async {
                    await _services.signOut();
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 1, 0, 34),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Color.fromARGB(255, 90, 181, 250),
                      fontSize: 16,
                    ),
                  ),
                ),
              ]
            : [
                TextButton(
                  onPressed: () => context.go('/BaceFook/Login'),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 1, 0, 34),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Color.fromARGB(255, 90, 181, 250),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                TextButton(
                  onPressed: () => context.go('/BaceFook/Signup'),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 1, 0, 34),
                  ),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      color: Color.fromARGB(255, 90, 181, 250),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
          ? const Center(
              child: Text(
                'No posts available',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 90, 181, 250),
                  fontSize: 16,
                ),
              ),
            )
          : Center(
              child: SingleChildScrollView(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    final images = (post['post_images'] as List?) ?? [];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () =>
                            context.go('/BaceFook/Posts/${post['id']}'),
                        child: Card(
                          color: Color.fromARGB(255, 0, 21, 38),
                          child: Column(
                            children: [
                              Text(
                                post['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              Text(
                                post['content'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              if (images.isNotEmpty)
                                Image.network(
                                  images[0]['image_url'],
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.cover,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
      backgroundColor: const Color.fromARGB(255, 0, 21, 38),
    );
  }
}
