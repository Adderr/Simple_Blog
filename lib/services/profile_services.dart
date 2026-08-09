import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_blog/Database/db_client.dart';

class ProfileServices {
  Future<Map<String, dynamic>> getProfile() async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return response;
  }

  Future<void> updateName({required String name}) async {
    final userId = supabase.auth.currentUser!.id;
    await supabase.from('profiles').update({'name': name}).eq('id', userId);
  }

  Future<String> uploadAvatar({required XFile file}) async {
    final userId = supabase.auth.currentUser!.id;
    final bytes = await file.readAsBytes();
    final path =
        '$userId/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

    await supabase.storage.from('avatars').uploadBinary(path, bytes);
    final publicUrl = supabase.storage.from('avatars').getPublicUrl(path);

    await supabase
        .from('profiles')
        .update({'profile_url': publicUrl})
        .eq('id', userId);

    return publicUrl;
  }

  Future<XFile?> pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    return image;
  }
}
