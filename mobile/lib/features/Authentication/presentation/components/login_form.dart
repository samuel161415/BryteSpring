import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/core/constant.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

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
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'login_screen.email_placeholder'.tr(),
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: Text(
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
                    onPressed: () {},
                    child: Text(
                      'login_screen.switch_account'.tr(),
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
                      // const SizedBox(height: 2),
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
