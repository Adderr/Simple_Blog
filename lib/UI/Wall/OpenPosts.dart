import 'package:flutter/material.dart';
import 'package:simple_blog/services/post_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:simple_blog/UI/BaceFook.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_blog/Database/db_client.dart';
import 'package:simple_blog/services/services.dart';
import 'package:simple_blog/services/comment_services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

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
  bool _commentsLoading = true;
  String? _editingCommentId;
  final _editController = TextEditingController();

  List<Map<String, dynamic>> _comments = [];
  final _commentController = TextEditingController();
  List<XFile> _newCommentImages = [];
  List<XFile> _editingImages = [];

  @override
  void initState() {
    super.initState();
    _loadPost();
    _loadComments();
  }

  Widget _buildComments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Comments',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        if (_commentsLoading)
          const Center(child: CircularProgressIndicator())
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            itemBuilder: (context, i) {
              final comment = _comments[i];
              final isCommentOwner =
                  comment['user_id'] == _services.currentUser?.id;
              final commentImages = (comment['comment_images'] as List?) ?? [];
              final isEditing = _editingCommentId == comment['id'];

              return Column(
                children: [
                  ListTile(
                    title: isEditing
                        ? TextField(
                            controller: _editController,
                            autofocus: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(isDense: true),
                          )
                        : Text(
                            comment['comment'] ?? '',
                            style: const TextStyle(color: Colors.white),
                          ),
                    subtitle: commentImages.isEmpty
                        ? null
                        : SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: commentImages.length,
                              itemBuilder: (context, j) {
                                final imageEntry = commentImages[j];
                                final url = imageEntry['image_url'];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Image.network(
                                        url,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                      if (isEditing && isCommentOwner)
                                        Positioned(
                                          right: -4,
                                          top: -4,
                                          child: GestureDetector(
                                            onTap: () => _deleteCommentImage(
                                              comment['id'],
                                              imageEntry['id'],
                                            ),
                                            child: const CircleAvatar(
                                              radius: 9,
                                              backgroundColor: Colors.black87,
                                              child: Icon(
                                                Icons.close,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                    trailing: isCommentOwner
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isEditing ? Icons.check : Icons.edit,
                                  size: 20,
                                ),
                                onPressed: () async {
                                  if (isEditing) {
                                    final newText = _editController.text.trim();
                                    if (newText.isNotEmpty) {
                                      await _editComment(
                                        comment['id'],
                                        newText,
                                      );
                                    }
                                    for (final file in _editingImages) {
                                      try {
                                        final url = await CommentServices()
                                            .uploadCommentImage(
                                              file: file,
                                              commentId: comment['id'],
                                            );
                                        final imageRow = await CommentServices()
                                            .addCommentImage(
                                              commentId: comment['id'],
                                              imageUrl: url,
                                            );
                                        setState(() {
                                          final i = _comments.indexWhere(
                                            (c) => c['id'] == comment['id'],
                                          );
                                          final updatedImages = [
                                            ...(_comments[i]['comment_images']
                                                as List),
                                            {
                                              'id': imageRow['id'],
                                              'image_url': url,
                                            },
                                          ];
                                          _comments[i] = {
                                            ..._comments[i],
                                            'comment_images': updatedImages,
                                          };
                                        });
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to add image: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                    setState(() {
                                      _editingCommentId = null;
                                      _editingImages = [];
                                    });
                                  } else {
                                    _editController.text =
                                        comment['comment'] ?? '';
                                    setState(() {
                                      _editingCommentId = comment['id'];
                                      _editingImages = [];
                                    });
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () => _deleteComment(comment['id']),
                              ),
                            ],
                          )
                        : null,
                  ),
                  if (isEditing)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.add_photo_alternate,
                              size: 20,
                            ),
                            onPressed: () async {
                              final picked = await CommentServices()
                                  .pickImages();
                              setState(
                                () => _editingImages = [
                                  ..._editingImages,
                                  ...picked,
                                ],
                              );
                            },
                          ),
                          if (_editingImages.isNotEmpty)
                            Text(
                              '${_editingImages.length} image(s) to add',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        if (_newCommentImages.isNotEmpty)
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _newCommentImages.length,
              itemBuilder: (context, i) {
                final file = _newCommentImages[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      FutureBuilder<Uint8List>(
                        future: file.readAsBytes(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              width: 60,
                              height: 60,
                              child: Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                          return Image.memory(
                            snapshot.data!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                      Positioned(
                        right: -4,
                        top: -4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _newCommentImages.removeAt(i));
                          },
                          child: const CircleAvatar(
                            radius: 9,
                            backgroundColor: Colors.black87,
                            child: Icon(
                              Icons.close,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Write a comment...',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: () async {
                final picked = await CommentServices().pickImages();
                setState(() => _newCommentImages = picked);
              },
            ),
            IconButton(icon: const Icon(Icons.send), onPressed: _submitComment),
          ],
        ),
      ],
    );
  }

  Future<void> _loadComments() async {
    setState(() => _commentsLoading = true);
    try {
      final comments = await CommentServices().getComments(
        postId: widget.postId,
      );
      setState(() {
        _comments = comments;
        _commentsLoading = false;
      });
    } catch (e) {
      setState(() => _commentsLoading = false);
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    try {
      final newComment = await CommentServices().createComment(
        postId: widget.postId,
        comment: text,
      );

      final uploadedImages = <Map<String, dynamic>>[];
      for (final file in _newCommentImages) {
        final url = await CommentServices().uploadCommentImage(
          file: file,
          commentId: newComment['id'],
        );
        final imageRow = await CommentServices().addCommentImage(
          commentId: newComment['id'],
          imageUrl: url,
        );
        uploadedImages.add({'id': imageRow['id'], 'image_url': url});
      }

      setState(() {
        _comments.add({...newComment, 'comment_images': uploadedImages});
        _commentController.clear();
        _newCommentImages = [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to post comment: $e')));
      }
    }
  }

  Future<void> _deleteCommentImage(String commentId, String imageId) async {
    try {
      await CommentServices().deleteCommentImage(imageId);
      setState(() {
        final i = _comments.indexWhere((c) => c['id'] == commentId);
        final updatedImages = (_comments[i]['comment_images'] as List)
            .where((img) => img['id'] != imageId)
            .toList();
        _comments[i] = {..._comments[i], 'comment_images': updatedImages};
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete image: $e')));
      }
    }
  }

  Future<void> _editComment(String commentId, String newText) async {
    await CommentServices().updateComment(
      commentId: commentId,
      comment: newText,
    );
    setState(() {
      final i = _comments.indexWhere((c) => c['id'] == commentId);
      _comments[i] = {..._comments[i], 'comment': newText};
    });
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await CommentServices().deleteComment(commentId: commentId);
      setState(() => _comments.removeWhere((c) => c['id'] == commentId));
    } catch (e) {
      setState(() => _error = e.toString());
    }
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
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _post!['title'],
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
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
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              final imageUrl = images[index]['image_url'];
                              return Padding(
                                padding: const EdgeInsets.only(right: 15.0),
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
                      const SizedBox(height: 20),
                      _buildComments(),
                    ],
                  ),
                ),
              ),
            ),
      backgroundColor: const Color.fromARGB(255, 0, 21, 38),
    );
  }
}
