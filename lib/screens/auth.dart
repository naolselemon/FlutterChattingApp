import "dart:convert";
import "dart:io";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";

import "package:chatting/widgets/user_image_picker.dart";

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  File? _selectedImage;
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String? _base64Image;
  var _isLogin = true;
  var _email = "";
  var _password = "";
  var _username = "";
  var _isAuthenticated = false;

  Future<void> _submit() async {
    var isValid = _formKey.currentState!.validate();

    if (!isValid || !_isLogin && _selectedImage == null) {
      return;
    }

    if (isValid) {
      _formKey.currentState!.save();

      try {
        setState(() {
          _isAuthenticated = true;
        });
        if (_isLogin) {
          UserCredential userCredential = await _auth
              .signInWithEmailAndPassword(email: _email, password: _password);
        } else {
          UserCredential userCredentials =
              await _auth.createUserWithEmailAndPassword(
            email: _email,
            password: _password,
          );

          if (_selectedImage != null) {
            final imageByte = await _selectedImage!
                .readAsBytes(); // reading each and every byte on the image that explains color, shapes ...
            _base64Image = base64Encode(imageByte);
          }
          // final storageRef = FirebaseStorage.instance
          //     .ref()
          //     .child("user-images")
          //     .child("${userCredentials.user!.uid}.jpg");
          // final imageUrl = await storageRef.putFile(_selectedImage!);
          // final downloadUrl = await imageUrl.ref.getDownloadURL();

          FirebaseFirestore.instance
              .collection("users")
              .doc(userCredentials.user!.uid)
              .set({
            "username": _username,
            "email": _email,
            "image": _base64Image,
          });
        }
      } on FirebaseAuthException catch (error) {
        if (error.code == "email-already-in-use") {
          if (!mounted) {
            return;
          }

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Center(child: Text("Email already in use by other account.")),
            ),
          );
        } else {
          if (!mounted) {
            return;
          }

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.message ?? "Authentication failed"),
            ),
          );
        }
      }
      setState(() {
        _isAuthenticated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset("assets/images/chat.png"),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(
                              onPickedImage: (pickedImage) =>
                                  _selectedImage = pickedImage,
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Email",
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Email is required";
                              }
                              if (!value.contains("@")) {
                                return "Please enter a valid email.";
                              }

                              return null;
                            },
                            onSaved: (newValue) => _email = newValue!,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Password",
                            ),
                            obscureText: true,
                            autocorrect: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password is required";
                              }
                              if (value.length < 6) {
                                return "Please enter minimum of 6 characters";
                              }

                              return null;
                            },
                            onSaved: (newValue) => _password = newValue!,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (!_isLogin)
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: "Username"),
                              autocorrect: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Username is required";
                                }
                                if (value.length < 3) {
                                  return "Please enter minimum of 3 characters";
                                }

                                return null;
                              },
                              onSaved: (value) => _username = value!,
                            ),
                          const SizedBox(height: 20),
                          if (_isAuthenticated)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticated)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                              child: Text(_isLogin ? "Login" : "Signup"),
                            ),
                          const SizedBox(height: 10),
                          if (!_isAuthenticated)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(
                                _isLogin
                                    ? "Create an account"
                                    : "Already have an account",
                              ),
                            ),
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
