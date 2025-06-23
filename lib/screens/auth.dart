// import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/widgets/user_image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final databaseName = dotenv.env['DATABASE_NAME'];

// final _firebase = FirebaseAuth.instance;
final _supabase = Supabase.instance.client;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  bool _isLoginScreen = true;
  bool _isAuthenticating = false;

  String _email = '';
  String _username = '';
  String _password = '';
  File? _avatarImage;

  _onSave() async {
    final isValid = _form.currentState!.validate();

    if (!isValid || !_isLoginScreen && _avatarImage == null) {
      //TODO: show error message
      return;
    }

    _form.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLoginScreen) {
        // final userCredentials = await _firebase.signInWithEmailAndPassword(
        //   email: _email,
        //   password: _password,
        // );
        // print(userCredentials);

        final AuthResponse res = await _supabase.auth.signInWithPassword(
          email: _email,
          password: _password,
        );

        final Session? session = res.session;
        final User? user = res.user;
      } else {
        final AuthResponse res = await _supabase.auth.signUp(
          email: _email,
          password: _password,
        );

        final Session? session = res.session;
        final User? user = res.user;

        final imagePath = 'user_images/${user!.id}.jpg';
        await _supabase.storage
            .from(databaseName!)
            .upload(
              imagePath,
              _avatarImage!,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        await _supabase.from('users').insert({
          'username': _username,
          'email': _email,
          'image_path': imagePath,
        });
        // final userCredentials = await _firebase.createUserWithEmailAndPassword(
        //   email: _email,
        //   password: _password,
        // );
        // print(userCredentials);
      }
      setState(() {
        _isAuthenticating = false;
      });
      // } on FirebaseAuthException catch (error) {
    } on AuthException catch (error) {
      if (error.code == 'email-already-in-use') {
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          // SnackBar(content: Text(error.message ?? "Authentication Failed")),
          SnackBar(content: Text(error.message)),
        );
      }
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  right: 20,
                  left: 20,
                  bottom: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLoginScreen) ...[
                            UserImagePicker(
                              onPickImage:
                                  (pickedImage) => _avatarImage = pickedImage,
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: "Username",
                              ),
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return "Please enter at least 4 characters";
                                }
                                return null;
                              },
                              onSaved: (newValue) => _username = newValue!,
                            ),
                          ],
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Email Address",
                            ),
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return "Please enter valid email address";
                              }
                              return null;
                            },
                            onSaved: (value) => _email = value!,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Password",
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return "Password must be atleast 6 characters long";
                              }
                              return null;
                            },
                            onSaved: (value) => _password = value!,
                          ),
                          const SizedBox(height: 12),

                          if (_isAuthenticating)
                            const CircularProgressIndicator(),

                          if (!_isAuthenticating) ...[
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                              ),
                              onPressed: _onSave,
                              child: Text(_isLoginScreen ? "Login" : "Signup"),
                            ),

                            TextButton(
                              onPressed: () {
                                setState(
                                  () => _isLoginScreen = !_isLoginScreen,
                                );
                              },
                              child: Text(
                                _isLoginScreen
                                    ? "Create an account"
                                    : "Already have an account. Login!",
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
