import 'package:flutter/material.dart';
import 'package:mobile/core/constant.dart';
import 'package:mobile/core/widgets/app_footer.dart';
import 'package:mobile/features/Authentication/presentation/components/login_header.dart';
import 'package:mobile/features/Authentication/presentation/components/login_form.dart';
import 'package:mobile/features/Authentication/presentation/components/login_footer.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _handleLanguageChanged() {
    // Force rebuild when language changes
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Get screkkjhhggfffdduyytghggen dimensionhhjkjuok9009099iip[yuuigihfdguyhis for responsive layout
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: screenSize.width > 500 ? 500 : screenSize.width * 0.9,
            margin: const EdgeInsets.symmetric(vertical: 20.0),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),hhhhh
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // LoginHeader(onLa nguageChanged: _handleLanguageChanged),
                LoginForm(),
                AppFooter(onLanguageChanged: _handleLanguageChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
