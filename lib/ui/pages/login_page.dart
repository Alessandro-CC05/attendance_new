import 'package:flutter/material.dart';

class AttendanceLoginScreen extends StatefulWidget {
  const AttendanceLoginScreen({super.key});

  @override
  State<AttendanceLoginScreen> createState() => _AttendanceLoginScreenState();
}

class _AttendanceLoginScreenState extends State<AttendanceLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 36, 36),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Image.asset(
                    'lib/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                
                
                const SizedBox(height: 30),
                
                // Title
                const Text(
                  'Attendance',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'Easily manage class attendance',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color.fromARGB(255, 189, 189, 189),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Email Input
                _buildInputField(
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  hintText: 'Email',
                ),
                
                const SizedBox(height: 16),
                
                // Password Input
                _buildInputField(
                  controller: _passwordController,
                  icon: Icons.vpn_key_outlined,
                  hintText: 'Password',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: const Color.fromARGB(255, 219, 218, 218),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot your password?',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Log In Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle login
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 127, 200, 129),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // OR SIGN
                Text(
                  'OR SIGN',
                  style: TextStyle(
                    color: Color.fromARGB(255, 163, 163, 163),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Social Login Buttons
                Row(
                  children: [

                    Expanded(
                      child: _buildSocialButton(
                        'Google',
                        Icons.g_mobiledata,
                        () {},
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New to ',
                      style: TextStyle(
                        color: Color.fromARGB(255, 163, 163, 163),
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                      ),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 196, 196, 196),
                          fontSize: 18,
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
    );
  }

  Widget _buildPuzzlePiece(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Color.fromARGB(221, 0, 0, 0)),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color.fromARGB(255, 213, 213, 213)),
          suffixIcon: suffixIcon,
          hintText: hintText,
          hintStyle: TextStyle(color: const Color.fromARGB(255, 215, 215, 215)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 127, 200, 129),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}