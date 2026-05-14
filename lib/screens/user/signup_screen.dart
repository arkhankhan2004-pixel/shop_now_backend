import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  const SignupScreen({super.key, required this.onSuccess});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false, _obscure = true;
  late AnimationController _ctrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.signUp(_emailCtrl.text.trim(), _passCtrl.text.trim());
      widget.onSuccess();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? 'Signup failed'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A0B3B), Color(0xFF0B0C2A)],
                begin: Alignment.topRight, end: Alignment.bottomLeft,
              ),
            ),
          ),
          Positioned(top: -80, left: -40,
            child: Container(width: 250, height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: const Color(0xFFFF6584).withOpacity(0.15)))),
          Positioned(bottom: -60, right: -60,
            child: Container(width: 200, height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: const Color(0xFF6C63FF).withOpacity(0.2)))),

          SafeArea(
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6584), Color(0xFF6C63FF)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: const Color(0xFFFF6584).withOpacity(0.4), blurRadius: 20)],
                        ),
                        child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 34),
                      ),
                      const SizedBox(height: 28),
                      const Text('Create\nAccount ✨',
                          style: TextStyle(color: Colors.white, fontSize: 36,
                              fontWeight: FontWeight.w900, height: 1.1)),
                      const SizedBox(height: 8),
                      const Text('Join us and start shopping today!',
                          style: TextStyle(color: Colors.white38, fontSize: 14)),
                      const SizedBox(height: 40),

                      _buildField(
                        controller: _emailCtrl,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        validator: (v) => v!.isEmpty ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _passCtrl,
                        label: 'Password',
                        icon: Icons.lock_outline_rounded,
                        obscure: _obscure,
                        suffix: GestureDetector(
                          onTap: () => setState(() => _obscure = !_obscure),
                          child: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.white38, size: 20),
                        ),
                        validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
                      ),
                      const SizedBox(height: 36),

                      SizedBox(
                        width: double.infinity, height: 58,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6584), Color(0xFF6C63FF)],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [BoxShadow(color: const Color(0xFFFF6584).withOpacity(0.4), blurRadius: 18, offset: const Offset(0, 8))],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            onPressed: _loading ? null : _signup,
                            child: _loading
                                ? const SizedBox(width: 24, height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                : const Text('Create Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Already have an account? ',
                                style: TextStyle(color: Colors.white38, fontSize: 14)),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text('Login',
                                  style: TextStyle(
                                    color: Color(0xFF6C63FF), fontWeight: FontWeight.w800, fontSize: 14,
                                    decoration: TextDecoration.underline, decorationColor: Color(0xFF6C63FF),
                                  )),
                            ),
                          ],
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
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFFFF6584), size: 20),
        suffixIcon: suffix != null ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix) : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF6584), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF6584)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
