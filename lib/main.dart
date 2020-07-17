import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:password/password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitty/home_screen.dart';

void main() {
  runApp(MyApp());
}

const primaryColor = Color(0xFF344955);
final _firestore = Firestore.instance;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: primaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool isLoading = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
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
                    _obscureText ? Icons.visibility : Icons.visibility_off,
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
                    'Sign In',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Theme.of(context).primaryColor,
                  onPressed: () async {
                    setState(() {
                      isLoading = !isLoading;
                    });
                    var email = _emailController.text;
                    var password = _passwordController.text;
                    var encryptedPassword = Password.hash(password, PBKDF2());

                    try {
                      final loggedUser = await _auth.signInWithEmailAndPassword(
                        email: email,
                        password: encryptedPassword,
                      );

                      if (loggedUser != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      }
                    } catch (e) {
                      print(e);
                      Scaffold.of(context)
                          .showSnackBar(SnackBar(content: Text(e.toString())));
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
                Text("Dont't have an account? "),
                Text("Sign up", style: TextStyle(fontWeight: FontWeight.bold))
              ],
            )
          ],
        ),
      ),
    );
  }

  void saveUserDataToFirestore(String email, String encryptedPassword) {
    _firestore.collection('twitty-user').add({
      'email': email,
      'password': encryptedPassword,
      'dateCreated': Timestamp.now()
    });
  }
}
