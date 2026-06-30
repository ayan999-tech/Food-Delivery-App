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

  // ─── NEW: Email Verification Popup ───────────────────────────────────────
  void _showVerificationPopup(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        // ── Header ──
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_unread_rounded,
                color: Colors.red,
                size: 48,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Verify Your Email",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        // ── Body ──
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "We sent a verification email to:",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // ── Steps ──
            _popupStep(
              icon: Icons.inbox_rounded,
              color: Colors.blue,
              text: "Check your Inbox first",
            ),
            const SizedBox(height: 10),
            _popupStep(
              icon: Icons.folder_rounded,
              color: Colors.orange,
              text: "Check Spam / Junk folder",
            ),
            const SizedBox(height: 10),
            _popupStep(
              icon: Icons.check_circle_rounded,
              color: Colors.green,
              text: "Mark it as 'Not Spam' if found there",
            ),
            const SizedBox(height: 10),
            _popupStep(
              icon: Icons.touch_app_rounded,
              color: Colors.purple,
              text: "Click the verification link in email",
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.amber.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Marking as 'Not Spam' ensures future emails arrive directly in your inbox.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // ── Actions ──
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _tabController.animateTo(0);
                  },
                  icon: const Icon(Icons.login_rounded),
                  label: const Text(
                    "Go to Login",
                    style: TextStyle(fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  User? user = _auth.currentUser;
                  if (user != null) {
                    await user.sendEmailVerification();
                    _showMessage("Verification email resent! Check your inbox.");
                  }
                },
                icon: const Icon(Icons.refresh_rounded,
                    color: Colors.red, size: 18),
                label: const Text(
                  "Resend Email",
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ],
      ),
    );
  }

  // ─── NEW: Popup Step Widget ───────────────────────────────────────────────
  Widget _popupStep({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  // ─── LOGIN USER (unchanged) ───────────────────────────────────────────────
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
        _showMessage("Please verify your email before logging in.");
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

  // ─── SIGN UP USER (only popup added, all logic unchanged) ────────────────
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

      setState(() => _isLoading = false);

      // ── Show verification popup instead of just snackbar ──
      _showVerificationPopup(email);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showMessage("Email already registered.");
      } else if (e.code == 'weak-password') {
        _showMessage("Password is too weak.");
      } else {
        _showMessage(e.message.toString());
      }
      setState(() => _isLoading = false);
    }
  }

  // ─── BUILD (100% unchanged) ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "QuickBite",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
                // ── LOGIN TAB (unchanged) ──
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Image.asset("assets/images/login.jpg", height: 200),
                        const SizedBox(height: 40),
                        TextField(
                          controller: _loginEmailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(color: Colors.black54),
                            prefixIcon:
                            Icon(Icons.email, color: Colors.red),
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
                            labelStyle:
                            const TextStyle(color: Colors.black54),
                            prefixIcon:
                            const Icon(Icons.lock, color: Colors.red),
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
                                  _loginPasswordVisible =
                                  !_loginPasswordVisible;
                                });
                              },
                            ),
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 40),
                        _isLoading
                            ? const CircularProgressIndicator(
                            color: Colors.red)
                            : ElevatedButton(
                          onPressed: _loginUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize:
                            const Size(double.infinity, 50),
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

                // ── SIGN UP TAB (unchanged) ──
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Image.asset("assets/images/signup.jpg",
                            height: 250),
                        const SizedBox(height: 40),
                        TextField(
                          controller: _signUpEmailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(color: Colors.black54),
                            prefixIcon: Icon(Icons.email_outlined,
                                color: Colors.red),
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
                            labelStyle:
                            const TextStyle(color: Colors.black54),
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Colors.red),
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
                            ? const CircularProgressIndicator(
                            color: Colors.red)
                            : ElevatedButton(
                          onPressed: _signUpUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            minimumSize:
                            const Size(double.infinity, 50),
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