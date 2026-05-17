import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/pages/Homescreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _loginPasswordVisible = false;
  bool _signUpPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  //  LOGIN USER
  Future<void> _loginUser() async {
    String email = _loginEmailController.text.trim();
    String password = _loginPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Please fill in all fields.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User user = userCredential.user!;

      await user.reload();
      user = _auth.currentUser!;

      if (!user.emailVerified) {
        await _auth.signOut();
        _showMessage(
          "Please verify your email before logging in.",
        );
        setState(() => _isLoading = false);
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showMessage("No user found with this email.");
      } else if (e.code == 'wrong-password') {
        _showMessage("Incorrect password.");
      } else {
        _showMessage(e.message.toString());
      }
    }

    setState(() => _isLoading = false);
  }


  //  SIGN UP USER
  Future<void> _signUpUser() async {
    String email = _signUpEmailController.text.trim();
    String password = _signUpPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Please fill in all fields.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );


      await userCredential.user!.sendEmailVerification();

      _showMessage(
        "Verification email sent! Please verify before login.",
      );


      _tabController.animateTo(0);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showMessage("Email already registered.");
      } else if (e.code == 'weak-password') {
        _showMessage("Password is too weak.");
      } else {
        _showMessage(e.message.toString());
      }
    }

    setState(() => _isLoading = false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("QuickBite",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        backgroundColor: Colors.red,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),


          TabBar(
            controller: _tabController,
            indicatorColor: Colors.red,
            labelColor: Colors.red,
            unselectedLabelColor: Colors.black54,

            labelStyle: const TextStyle(fontSize: 18),
            unselectedLabelStyle: const TextStyle(fontSize: 16),

            tabs: const [
              Tab(text: "Login"),
              Tab(text: "Sign Up"),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [

                //  LOGIN TAB
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Image.asset("assets/images/login.jpg", height: 200),
                        const SizedBox(height: 40),

                        TextField(
                          controller: _loginEmailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(color: Colors.black54),
                            prefixIcon: Icon(Icons.email, color: Colors.red),
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 20),

                        TextField(
                          controller: _loginPasswordController,
                          obscureText: !_loginPasswordVisible,
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: const TextStyle(color: Colors.black54),
                            prefixIcon: const Icon(Icons.lock, color: Colors.red),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _loginPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  _loginPasswordVisible = !_loginPasswordVisible;
                                });
                              },
                            ),
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),

                        const SizedBox(height: 40),

                        _isLoading
                            ? const CircularProgressIndicator(color: Colors.red)
                            : ElevatedButton(
                          onPressed: _loginUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //  SIGN UP TAB
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Image.asset("assets/images/signup.jpg", height: 250),
                        const SizedBox(height: 40),

                        TextField(
                          controller: _signUpEmailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(color: Colors.black54),
                            prefixIcon: Icon(Icons.email_outlined, color: Colors.red),
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 20),

                        TextField(
                          controller: _signUpPasswordController,
                          obscureText: !_signUpPasswordVisible,
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: const TextStyle(color: Colors.black54),
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.red),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _signUpPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  _signUpPasswordVisible =
                                  !_signUpPasswordVisible;
                                });
                              },
                            ),
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),

                        const SizedBox(height: 30),

                        _isLoading
                            ? const CircularProgressIndicator(color: Colors.red)
                            : ElevatedButton(
                          onPressed: _signUpUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text(
                            "Create Account",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

