import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:password/password.dart';
import 'package:twitty/model/user.dart';
import 'package:twitty/utils/constants.dart';

final _firestore = Firestore.instance;

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool isLoading = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            isLoading ? CircularProgressIndicator() : Container(),
            Text(
              'Twitty',
              style: TextStyle(
                color: primaryColor,
                fontSize: 36,
                fontFamily: 'MuseoModerno',
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Email',
              ),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Username',
              ),
            ),
            TextField(
              controller: _displayNameController,
              decoration: InputDecoration(
                hintText: 'Display Name',
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
                hintText: 'Password',
              ),
            ),
            Builder(
              builder: (context) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: RaisedButton(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Theme.of(context).primaryColor,
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    var email = _emailController.text;
                    var username = _usernameController.text;
                    var displayName = _usernameController.text;
                    var password = _passwordController.text;
                    var encryptedPassword = Password.hash(password, PBKDF2());

                    try {
                      final newUser =
                          await _auth.createUserWithEmailAndPassword(
                        email: email,
                        password: encryptedPassword,
                      );

                      var user = User(
                        id: newUser.user.uid,
                        email: email,
                        username: username,
                        displayName: displayName,
                        password: encryptedPassword,
                      );

                      if (newUser != null) {
                        saveUserDataToFirestore(user);
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      print(e);
                      final snackbar = SnackBar(content: Text(e.toString()));
                      Scaffold.of(context).showSnackBar(snackbar);
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Already have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text("Sign in",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void saveUserDataToFirestore(User user) {
    _firestore.collection('twitty-user').document(user.id).setData({
      'id': user.id,
      'email': user.email,
      'password': user.password,
      'username': '@${user.username}',
      'displayName': user.displayName,
      'dateCreated': Timestamp.now()
    });
  }
}
