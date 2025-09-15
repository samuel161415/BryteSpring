import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constant.dart';
import 'package:mobile/core/routing/routeLists.dart';
import 'package:mobile/core/services/auth_service.dart';
import 'package:mobile/core/injection_container.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = sl<AuthService>();
      final result = await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${failure.message}')),
          );
        },
        (user) {
          // Login successful, redirect to dashboard
          context.go('/${Routelists.dashboard}');
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [AppTheme.secondary, AppTheme.primary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/bryteversebubbles.png',
                    height: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'login_screen.welcome_message'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _emailController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'login_screen.email_placeholder'.tr(),
                  hintStyle: TextStyle(color: Colors.black),
                  // filled: true,
                  // fillColor: const Color(0xFF21262D),
                  border: OutlineInputBorder(
                    // borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    // borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    // borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: TextStyle(color: AppTheme.text),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                textAlign: TextAlign.center,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'login_screen.password_placeholder'.tr(),
                  hintStyle: TextStyle(color: Colors.black),
                  // filled: true,
                  // fillColor: const Color(0xFF21262D),
                  border: OutlineInputBorder(
                    // borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.white12,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    // borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    // borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: TextStyle(color: AppTheme.text),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Theme(
                    data: ThemeData(
                      unselectedWidgetColor: const Color(0xFF30363D),
                    ),
                    child: Checkbox(
                      value: true,
                      onChanged: (bool? value) {},
                      activeColor: const Color(0xFFE44D2E),
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.all(
                        const Color(0xFF21262D),
                      ),
                      side: const BorderSide(color: Color(0xFF30363D)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Text(
                    'login_screen.remember_me'.tr(),
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4, left: 4),
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 4),
                        color: Colors.transparent,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 4, right: 4),
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 4),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: const Color.fromARGB(0, 148, 124, 124),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'login_screen.login_button'.tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      context.pushNamed(
                        Routelists.invitationValidation,
                        pathParameters: {
                          'token': '6fe3ac76-9438-4eb4-b09f-9875f1306424',
                        },
                      );
                    },
                    child: Text(
                      'reset_password.back_to_login'.tr(),
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Menu',
                        style: TextStyle(color: Colors.black, fontSize: 8),
                      ),
                      Icon(Icons.menu, color: Colors.black, size: 30),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
