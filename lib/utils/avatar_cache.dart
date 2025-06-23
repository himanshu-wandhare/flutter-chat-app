import 'package:supabase_flutter/supabase_flutter.dart';

class AvatarCache {
  static final _cache = <String, String>{};

  static Future<String?> getUrl(String? avatarPath) async {
    if (avatarPath == null) return null;

    if (_cache.containsKey(avatarPath)) {
      return _cache[avatarPath];
    }

    final url = await Supabase.instance.client.storage
        .from('avatars')
        .createSignedUrl(avatarPath, 3600); // 1 hour

    _cache[avatarPath] = url;
    return url;
  }
}
