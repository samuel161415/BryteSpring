import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constant.dart';
import 'package:mobile/core/routing/routeLists.dart';
import 'package:mobile/core/storage/secure_storage.dart';
import 'package:mobile/core/widgets/app_footer.dart';
import 'package:mobile/core/widgets/loading_widget.dart';
import 'package:mobile/features/Authentication/domain/entities/invitation_entity.dart';
import 'package:mobile/features/Authentication/domain/entities/register_user_entity.dart';
import 'package:mobile/features/Authentication/presentation/bloc/register_user_bloc.dart';

class ResetPasswordPage extends StatefulWidget {
  final InvitationEntity invitation;
  const ResetPasswordPage({super.key, required this.invitation});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _handleLanguageChanged() {
    setState(() {});
  }

  void _handleRegisterUser(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final request = RegisterUserRequest(
        email: widget.invitation.email,
        password: _passwordController.text,
        invitationToken: widget.invitation.token,
      );

      context.read<RegisterUserBloc>().add(RegisterUserSubmitted(request));
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterUserBloc, RegisterUserState>(
      listener: (context, state) {
        if (state is RegisterUserSuccess) {
          // Save tokens to secure storage
          // Use token as refreshToken if refreshToken is not provided
          // final refreshToken =
          //     state.response.refreshToken ?? state.response.token;
          // SecureStorage.saveTokens(state.response.token, refreshToken);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Account created successfully! Welcome ${state.response.firstName}!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to dashboard after successful registration
          context.goNamed(Routelists.login, extra: widget.invitation);
        } else if (state is RegisterUserFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Builder(
        builder: (context) => BlocBuilder<RegisterUserBloc, RegisterUserState>(
          builder: (context, state) {
            return _buildRegisterUserForm(context);
          },
        ),
      ),
    );
  }

  Widget _buildRegisterUserForm(BuildContext context) {
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
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.secondary, AppTheme.primary],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Personalized greeting
                          const SizedBox(height: 24),
                          Text(
                            'login_screen.welcome_message'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Set your password to complete your account setup',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(height: 24),
                          // Align(
                          //   alignment: Alignment.centerLeft,
                          //   child: Text(
                          //     'reset_password.password_label'.tr(),
                          //     style: const TextStyle(
                          //       color: Colors.black,
                          //       fontWeight: FontWeight.w600,
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            textAlign: TextAlign.center,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'reset_password.password_hint'.tr(),
                              hintStyle: const TextStyle(color: Colors.black54),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Align(
                          //   alignment: Alignment.centerLeft,
                          //   child: Text(
                          //     'reset_password.confirm_label'.tr(),
                          //     style: const TextStyle(
                          //       color: Colors.black,
                          //       fontWeight: FontWeight.w600,
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmController,
                            obscureText: true,
                            textAlign: TextAlign.center,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'reset_password.confirm_hint'.tr(),
                              hintStyle: const TextStyle(color: Colors.black54),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          BlocBuilder<RegisterUserBloc, RegisterUserState>(
                            builder: (context, state) {
                              return SizedBox(
                                width: double.infinity,
                                child: Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                        top: 4,
                                        left: 4,
                                      ),
                                      height: 48,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 4,
                                        ),
                                        color: Colors.transparent,
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(
                                        bottom: 4,
                                        right: 4,
                                      ),
                                      height: 48,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 4,
                                        ),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: state is RegisterUserLoading
                                            ? null
                                            : () =>
                                                  _handleRegisterUser(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: const Color.fromARGB(
                                            0,
                                            148,
                                            124,
                                            124,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          minimumSize: const Size.fromHeight(
                                            48,
                                          ),
                                        ),
                                        child: state is RegisterUserLoading
                                            ? const LoadingWidget(
                                                size: 20,
                                                color: Colors.white,
                                                showMessage: false,
                                              )
                                            : Text(
                                                'Create Account',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              context.pushNamed(
                                Routelists.login,
                                extra: widget.invitation,
                              );
                            },
                            child: Text(
                              'reset_password.back_to_login'.tr(),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                          const SizedBox(height: 60),
                        ],
                      ),
                    ),
                  ),
                ),
                AppFooter(onLanguageChanged: _handleLanguageChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
