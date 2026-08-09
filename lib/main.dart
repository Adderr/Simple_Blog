import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_blog/UI/Signup/signup.dart';
import 'package:simple_blog/UI/Wall/Posts.dart';
import 'package:simple_blog/UI/Wall/wall.dart';
import 'package:simple_blog/UI/Login/login.dart';
import 'package:simple_blog/services/profile_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:simple_blog/Database/db_constants.dart';
import 'package:simple_blog/UI/Wall/OpenPosts.dart';
import 'package:simple_blog/UI/Profile/userProfile.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => Wall()),
    GoRoute(path: '/BaceFook/Login', builder: (context, state) => Login()),
    GoRoute(path: '/BaceFook/Signup', builder: (context, state) => Signup()),
    GoRoute(path: '/BaceFook/Profile', builder: (context, state) => Profile()),
    GoRoute(
      path: '/BaceFook/Posts',
      builder: (context, state) => CreatePosts(),
    ),
    GoRoute(
      path: '/BaceFook/Posts/:postId',
      builder: (context, state) {
        final postId = state.pathParameters['postId']!;
        return PostDetail(postId: postId);
      },
    ),
    GoRoute(
      path: '/BaceFook/Posts/:postId/edit',
      builder: (context, state) {
        final postId = state.pathParameters['postId']!;
        return CreatePosts(postId: postId);
      },
    ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: DatabaseConstants.url,
    anonKey: DatabaseConstants.anonKey,
  );

  runApp(SimpleBlog());
}

class SimpleBlog extends StatelessWidget {
  const SimpleBlog({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: _router);
  }
}
