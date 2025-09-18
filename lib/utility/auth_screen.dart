// File: lib/auth_screen.dart
import 'package:flutter/material.dart';
import '../home/home_page.dart';
import '../models/user_model.dart';

// Database pengguna sementara (in-memory)
final Map<String, User> _usersDatabase = {};

class AuthScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const AuthScreen({super.key, required this.toggleTheme});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginMode = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isPasswordVisible = false;

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  void _submitForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    FocusScope.of(context).unfocus();

    if (!isValid) return;

    final email = _emailController.text.trim();
    if (_isLoginMode) {
      final user = _usersDatabase[email];
      if (user != null && user.password == _passwordController.text) {
        // Ambil data pengguna yang berhasil login
        final loggedInUser = _usersDatabase[email]!;

        // Navigasi ke HomePage dan teruskan nama pengguna
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (ctx) => HomePage(
              userName: loggedInUser.fullName,
              toggleTheme: widget.toggleTheme,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Email atau password salah.'),
                backgroundColor: Colors.red
            )
        );
      }
    } else {
      if (_usersDatabase.containsKey(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Email sudah terdaftar.'),
                backgroundColor: Colors.orange
            )
        );
      } else {
        final newUser = User(
            fullName: _nameController.text.trim(),
            email: email,
            password: _passwordController.text
        );
        _usersDatabase[email] = newUser;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Akun berhasil dibuat! Silakan login.'),
                backgroundColor: Colors.green
            )
        );
        _switchAuthMode();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [primaryColor.withOpacity(0.2), backgroundColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter
            )
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8.0,
              shadowColor: primaryColor.withOpacity(0.2),
              color: Colors.green.shade50,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Lenovo_Global_Corporate_Logo.png/1280px-Lenovo_Global_Corporate_Logo.png',
                        height: 50,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Text('Lenovo', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor));
                        },
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                          _isLoginMode ? 'Welcome !' : 'Create Account',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold
                          )
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        _isLoginMode ? 'Sign in to continue' : 'Sign up to get started',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      if (!_isLoginMode)
                        TextFormField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          validator: (value) => value == null || value.trim().isEmpty ? 'Nama tidak boleh kosong.' : null,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_emailFocusNode);
                          },
                        ),
                      if (!_isLoginMode) const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) => value == null || !value.contains('@') ? 'Masukkan email yang valid.' : null,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_passwordFocusNode);
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        validator: (value) => value == null || value.length < 6 ? 'Password minimal 6 karakter.' : null,
                        onFieldSubmitted: (_) => _submitForm(),
                      ),
                      const SizedBox(height: 30.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          child: Text(_isLoginMode ? 'Login' : 'Create Account'),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextButton(
                        onPressed: _switchAuthMode,
                        child: Text(
                            _isLoginMode ? 'Don\'t have an account? Sign Up' : 'Already have an account? Login',
                            style: TextStyle(color: primaryColor)
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}