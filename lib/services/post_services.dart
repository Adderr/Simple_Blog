import 'package:simple_blog/Database/db_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class PostServices {
  Future<Map<String, dynamic>> createPost({
    required String title,
    required String content,
  }) async {
    final userId = supabase.auth.currentUser!.id;

    final response = await supabase
        .from('posts')
        .insert({'title': title, 'content': content, 'user_id': userId})
        .select()
        .single();

    return response;
  }

  Future<void> deletePostImage(String imageId) async {
    await supabase.from('post_images').delete().eq('id', imageId);
  }

  Future<List<XFile>> pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    return images;
  }

  Future<String> uploadPostImage({
    required XFile file,
    required String postId,
  }) async {
    final bytes = await file.readAsBytes();
    final binary =
        '$postId/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    await supabase.storage.from('post-images').uploadBinary(binary, bytes);
    final URL = supabase.storage.from('post-images').getPublicUrl(binary);
    return URL;
  }

  Future<void> addPostImage({
    required String postId,
    required String imageUrl,
  }) async {
    final userId = supabase.auth.currentUser!.id;

    final response = await supabase.from('post_images').insert({
      'post_id': postId,
      'image_url': imageUrl,
    });

    return response;
  }

  Future<Map<String, dynamic>> getPostById(String postId) async {
    final response = await supabase
        .from('posts')
        .select('*, post_images(*)')
        .eq('id', postId)
        .single();

    return response;
  }

  Future<List<Map<String, dynamic>>> getPosts({required int page}) async {
    const pageSize = 10;
    final pageNumber = page * pageSize;
    final pageRange = pageNumber + pageSize - 1;

    final response = await supabase
        .from('posts')
        .select('*, post_images(*)')
        .order('created_at', ascending: false)
        .range(pageNumber, pageRange);
    return response;
  }

  Future<void> deletePost({required String postId}) async {
    await supabase.from('posts').delete().eq('id', postId);
  }

  Future<void> updatePost({
    required String postId,
    required String title,
    required String content,
  }) async {
    await supabase
        .from('posts')
        .update({'title': title, 'content': content})
        .eq('id', postId);
  }
}
