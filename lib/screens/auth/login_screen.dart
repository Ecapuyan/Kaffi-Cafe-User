import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kaffi_cafe/screens/home_screen.dart';
import 'package:kaffi_cafe/screens/auth/signup_screen.dart';
import 'package:kaffi_cafe/utils/colors.dart';
import 'package:kaffi_cafe/widgets/button_widget.dart';
import 'package:kaffi_cafe/widgets/text_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late Auth0 auth0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth0 = Auth0('dev-1x4l6wkco1ygo6sx.us.auth0.com',
        'zkHNki53NiSzkKygX4dsjvQqPqf2XirC');
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _resetEmailController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final box = GetStorage();

  void _handleLogin() async {
    // Basic validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            text: 'Please enter both email and password',
            fontSize: 16,
            color: plainWhite,
            fontFamily: 'Regular',
          ),
          backgroundColor: festiveRed,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Get user data from Firestore using email as document ID
      final userDoc = await _firestore
          .collection('users')
          .doc(_emailController.text.trim())
          .get();

      if (userDoc.exists) {
        // User exists, update last login and get current data
        final userData = userDoc.data() as Map<String, dynamic>;
        await _firestore
            .collection('users')
            .doc(_emailController.text.trim())
            .update({
          'lastLogin': FieldValue.serverTimestamp(),
        });

        // Store complete user data including current points in GetStorage
        final updatedUserData = Map<String, dynamic>.from(userData);
        updatedUserData['lastLogin'] = FieldValue.serverTimestamp();
        box.write('userData', updatedUserData);

        // Also store basic user info for compatibility and ensure it's in sync
        final userName = userData['name']?.toString() ?? 'User';
        box.write('user', {
          'email': _emailController.text.trim(),
          'given_name': userName.split(' ').first,
          'family_name': userName.split(' ').length > 1
              ? userName.split(' ').last
              : 'Name',
          'points': userData['points'] ?? 0, // Keep points in sync
        });
      } else {
        // Create user document if it doesn't exist
        await _firestore
            .collection('users')
            .doc(_emailController.text.trim())
            .set({
          'email': _emailController.text.trim(),
          'name': 'User',
          'createdAt': FieldValue.serverTimestamp(),
          'points': 0,
          'totalOrders': 0,
          'lastLogin': FieldValue.serverTimestamp(),
        });

        // Store initial user data
        box.write('userData', {
          'email': _emailController.text.trim(),
          'name': 'User',
          'points': 0,
          'totalOrders': 0,
        });

        // Also store basic user info for compatibility and ensure it's in sync
        box.write('user', {
          'email': _emailController.text.trim(),
          'given_name': 'User',
          'family_name': 'Name',
          'points': 0, // Keep points in sync
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: TextWidget(
              text: 'Login successful!',
              fontSize: 16,
              color: plainWhite,
              fontFamily: 'Regular',
            ),
            backgroundColor: bayanihanBlue,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred during login';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later';
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: TextWidget(
              text: errorMessage,
              fontSize: 16,
              color: plainWhite,
              fontFamily: 'Regular',
            ),
            backgroundColor: festiveRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: TextWidget(
              text: 'An unexpected error occurred',
              fontSize: 16,
              color: plainWhite,
              fontFamily: 'Regular',
            ),
            backgroundColor: festiveRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleSignUp() {
    // Navigate to SignUpScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final fontSize = screenWidth * 0.036;
        final padding = screenWidth * 0.035;

        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: plainWhite,
          title: TextWidget(
            text: 'Reset Password',
            fontSize: fontSize + 4,
            color: textBlack,
            isBold: true,
            fontFamily: 'Bold',
            letterSpacing: 1.2,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: 'Enter your email to receive a password reset link',
                fontSize: fontSize,
                color: charcoalGray,
                fontFamily: 'Regular',
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: plainWhite,
                    boxShadow: [
                      BoxShadow(
                        color: bayanihanBlue.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(
                        fontSize: fontSize,
                        color: charcoalGray.withOpacity(0.6),
                        fontFamily: 'Regular',
                      ),
                    ),
                    style: TextStyle(
                      fontSize: fontSize,
                      color: textBlack,
                      fontFamily: 'Regular',
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ButtonWidget(
              label: 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
              color: ashGray,
              textColor: textBlack,
              fontSize: fontSize,
              height: 40,
              width: 100,
              radius: 10,
            ),
            ButtonWidget(
              label: 'Send Reset Link',
              onPressed: () async {
                if (_resetEmailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: TextWidget(
                        text: 'Please enter your email',
                        fontSize: 16,
                        color: plainWhite,
                        fontFamily: 'Regular',
                      ),
                      backgroundColor: festiveRed,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  return;
                }

                // Firebase password reset
                try {
                  await _auth.sendPasswordResetEmail(
                    email: _resetEmailController.text.trim(),
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: TextWidget(
                          text:
                              'Password reset link sent to ${_resetEmailController.text}',
                          fontSize: 16,
                          color: plainWhite,
                          fontFamily: 'Regular',
                        ),
                        backgroundColor: bayanihanBlue,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    Navigator.of(context).pop();
                    _resetEmailController.clear();
                  }
                } on FirebaseAuthException catch (e) {
                  String errorMessage = 'Failed to send reset email';

                  switch (e.code) {
                    case 'user-not-found':
                      errorMessage = 'No user found with this email';
                      break;
                    case 'invalid-email':
                      errorMessage = 'Invalid email address';
                      break;
                    case 'too-many-requests':
                      errorMessage =
                          'Too many requests. Please try again later';
                      break;
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: TextWidget(
                          text: errorMessage,
                          fontSize: 16,
                          color: plainWhite,
                          fontFamily: 'Regular',
                        ),
                        backgroundColor: festiveRed,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: TextWidget(
                          text: 'An unexpected error occurred',
                          fontSize: 16,
                          color: plainWhite,
                          fontFamily: 'Regular',
                        ),
                        backgroundColor: festiveRed,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              color: bayanihanBlue,
              textColor: plainWhite,
              fontSize: fontSize,
              height: 40,
              width: 150,
              radius: 10,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.036;
    final padding = screenWidth * 0.035;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 150,
                ),
              ),

              const SizedBox(height: 100),

              // Sign Up Button
              Center(
                child: ButtonWidget(
                  label: 'Login with gmail account',
                  onPressed: () async {
                    final credentials = await auth0
                        .webAuthentication(scheme: 'com.algovision.kafficafe')
                        .login(useHTTPS: true);
                    box.write('user', credentials.user.toMap());

                    // Check if user already exists in Firestore
                    final userDoc = await _firestore
                        .collection('users')
                        .doc(credentials.user.toMap()['email'])
                        .get();

                    if (userDoc.exists) {
                      // User exists, update last login and get current data
                      final userData = userDoc.data() as Map<String, dynamic>;
                      await _firestore
                          .collection('users')
                          .doc(credentials.user.toMap()['email'])
                          .update({
                        'lastLogin': FieldValue.serverTimestamp(),
                      });

                      // Store the complete user data including current points
                      final updatedUserData =
                          Map<String, dynamic>.from(userData);
                      updatedUserData['lastLogin'] =
                          FieldValue.serverTimestamp();

                      // Also update 'user' key for consistency
                      final userName = credentials.user.toMap()['name'] ??
                          '${credentials.user.toMap()['given_name']} ${credentials.user.toMap()['family_name']}';
                      box.write('user', {
                        'email': credentials.user.toMap()['email'],
                        'given_name': credentials.user.toMap()['given_name'],
                        'family_name': credentials.user.toMap()['family_name'],
                        'points':
                            userData['points'] ?? 0, // Keep points in sync
                      });
                      box.write('userData', updatedUserData);
                    } else {
                      // New user, create document with initial points
                      await _firestore
                          .collection('users')
                          .doc(credentials.user.toMap()['email'])
                          .set({
                        'name':
                            '${credentials.user.toMap()['given_name']} ${credentials.user.toMap()['family_name']}',
                        'email': credentials.user.toMap()['email'],
                        'createdAt': FieldValue.serverTimestamp(),
                        'points': 0,
                        'totalOrders': 0,
                        'lastLogin': FieldValue.serverTimestamp(),
                      });

                      // Store initial user data
                      box.write('userData', {
                        'name':
                            '${credentials.user.toMap()['given_name']} ${credentials.user.toMap()['family_name']}',
                        'email': credentials.user.toMap()['email'],
                        'points': 0,
                        'totalOrders': 0,
                      });

                      // Also update 'user' key for consistency
                      box.write('user', {
                        'email': credentials.user.toMap()['email'],
                        'given_name': credentials.user.toMap()['given_name'],
                        'family_name': credentials.user.toMap()['family_name'],
                        'points': 0, // Keep points in sync
                      });
                    }

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                    );
                  },
                  color: primaryBlue,
                  textColor: Colors.white,
                  fontSize: fontSize + 2,
                  height: 50,
                  radius: 12,
                  width: screenWidth * 0.6,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }
}
