import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_blog/Database/db_client.dart';

class CommentServices {
  Future<Map<String, dynamic>> createComment({
    required String postId,
    required String comment,
  }) async {
    print('currentUser: ${supabase.auth.currentUser}');
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('comments')
        .insert({'comment': comment, 'user_id': userId, 'post_id': postId})
        .select()
        .single();
    return response;
  }

  Future<List<Map<String, dynamic>>> getComments({
    required String postId,
  }) async {
    final response = await supabase
        .from('comments')
        .select('*, comment_images(*)')
        .eq('post_id', postId);
    return response;
  }

  Future<void> updateComment({
    required String commentId,
    required String comment,
  }) async {
    await supabase
        .from('comments')
        .update({'comment': comment})
        .eq('id', commentId);
  }

  Future<void> deleteComment({required String commentId}) async {
    await supabase.from('comments').delete().eq('id', commentId);
  }

  Future<void> deleteCommentImage(String imageId) async {
    await supabase.from('comment_images').delete().eq('id', imageId);
  }

  Future<List<XFile>> pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    return images;
  }

  Future<String> uploadCommentImage({
    required XFile file,
    required String commentId,
  }) async {
    final bytes = await file.readAsBytes();
    final binary =
        'comments/$commentId/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    await supabase.storage.from('post-images').uploadBinary(binary, bytes);
    final URL = supabase.storage.from('post-images').getPublicUrl(binary);
    return URL;
  }

  Future<Map<String, dynamic>> addCommentImage({
    required String commentId,
    required String imageUrl,
  }) async {
    final response = await supabase
        .from('comment_images')
        .insert({'comment_id': commentId, 'image_url': imageUrl})
        .select()
        .single();
    return response;
  }
}
