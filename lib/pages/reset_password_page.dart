import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../services/api_service.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _resetPassword() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password baru harus diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _apiService.resetPassword(
        _emailController.text,
        _passwordController.text,
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        _showError(response['message']);
      }
    } catch (e) {
      _showError('Terjadi kesalahan koneksi');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            FadeInDown(
              child: Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Masukkan email terdaftar untuk memperbarui password Anda.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 40),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Email Terdaftar',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password Baru',
                  prefixIcon: const Icon(Icons.lock_reset_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _resetPassword,
                      child: const Text(
                        'UPDATE PASSWORD',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
