import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constant.dart';
import 'package:mobile/core/routing/routeLists.dart';
import 'package:mobile/core/widgets/app_footer.dart';
import 'package:mobile/features/Authentication/domain/entities/invitation_entity.dart';
import 'package:mobile/features/Authentication/presentation/bloc/invitation_validation_bloc.dart';

class InvitationValidationPage extends StatefulWidget {
  final String token;

  const InvitationValidationPage({super.key, required this.token});

  @override
  State<InvitationValidationPage> createState() =>
      _InvitationValidationPageState();
}

class _InvitationValidationPageState extends State<InvitationValidationPage> {
  @override
  void initState() {
    super.initState();
    // Trigger invitation validation when page loads
    context.read<InvitationValidationBloc>().add(
      ValidateInvitation(widget.token),
    );
  }

  void _handleLanguageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InvitationValidationBloc, InvitationValidationState>(
      listener: (context, state) {
        if (state is InvitationValidationSuccess) {
          // Always go to reset password page
          // The reset password page will handle existing users appropriately
          context.pushNamed(Routelists.resetPassword, extra: state.invitation);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width > 500
                  ? 500
                  : MediaQuery.of(context).size.width * 0.9,
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
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        // Logo or Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.secondary, AppTheme.primary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Icon(
                            Icons.mail_outline,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Content based on state
                        BlocBuilder<
                          InvitationValidationBloc,
                          InvitationValidationState
                        >(
                          builder: (context, state) {
                            if (state is InvitationValidationLoading) {
                              return _buildLoadingContent();
                            } else if (state is InvitationValidationFailure) {
                              return _buildErrorContent(state);
                            } else {
                              return _buildInitialContent();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  AppFooter(onLanguageChanged: _handleLanguageChanged),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
        ),
        const SizedBox(height: 24),
        Text(
          'Validating your invitation...',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please wait while we verify your invitation',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildErrorContent(InvitationValidationFailure state) {
    return Column(
      children: [
        // Error Icon
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: state.isExpired ? Colors.orange : Colors.red,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(
            state.isExpired ? Icons.schedule : Icons.error_outline,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 24),

        // Error Title
        Text(
          state.isExpired ? 'Invitation Expired' : 'Invalid Invitation',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Error Message
        Text(
          state.message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 24),

        // Action Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.goNamed(
                Routelists.almostJoinVerse,
                extra: state.invitation,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Go to Login',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitialContent() {
    return Column(
      children: [
        Text(
          'Invitation Validation',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'We are processing your invitation',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }
}
