import 'package:lost_n_found/items/backend_services/signin.dart';
import 'package:flutter/material.dart';
import 'package:lost_n_found/items/screens/edit_profile.dart';
import 'package:lost_n_found/items/screens/forget_password.dart';
import 'package:lost_n_found/items/widgets/gradient_container.dart';
import 'signup_screen.dart';
import 'package:google_fonts/google_fonts.dart';


class SigninScreen extends StatefulWidget {
  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();

  final SignInAuth _authService = SignInAuth();

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    String? result = await _authService.signInWithEmail(email, password);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful'),
          duration: Duration(seconds: 1),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EditProfile()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Incorrect login')));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Center(child: Image.asset('assets/images/LOGO.png', height: 300, width: 300,)),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: const Color.fromARGB(255, 100, 100, 100),
                        fontSize: 20),
                        floatingLabelStyle: const TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          backgroundColor: Color.fromARGB(255, 255, 255, 255), 
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        prefixIcon: const Icon(Icons.email),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 255, 255, 255),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          borderSide: const BorderSide(color: Colors.grey),
                      ),
                        errorStyle: const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email-id';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: const Color.fromARGB(255, 100, 100, 100),fontSize: 20),
                        floatingLabelStyle: const TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          backgroundColor: Colors.white, 
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        prefixIcon: const Icon(Icons.lock),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          borderSide: const BorderSide(color: Colors.grey),
                      ),
                        errorStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                          context,
                          MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen(),
                    ),
                  );
                },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.bold,),
                          
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0XFFFFD54F),
                          foregroundColor: Color.fromARGB(255, 0, 0, 0),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          
                        ),
                        child: Text('Login',style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
