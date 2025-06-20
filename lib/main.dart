// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screens/auth.dart';
import 'package:flutter_chat_app/screens/chat.dart';
import 'package:flutter_chat_app/screens/splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['ANON_KEY']!,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat',
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 63, 17, 177),
        ),
      ),
      home: StreamBuilder<AuthState>(
        // stream: FirebaseAu0th.instance.authStateChanges(),
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          final event = snapshot.data?.event;
          if (event == AuthChangeEvent.signedIn) {
            return const ChatScreen();
          }

          return const AuthScreen();
          // if (snapshot.hasData) {
          //   return const ChatScreen();
          // }
          // return const AuthScreen();
        },
      ),
    );
  }
}
