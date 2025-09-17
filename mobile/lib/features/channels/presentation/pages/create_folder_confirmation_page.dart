import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constant.dart';
import 'package:mobile/core/widgets/app_footer.dart';
import 'package:mobile/features/verse_join/presentation/components/top_part_widget.dart';
import 'package:mobile/core/routing/routeLists.dart';
import 'package:mobile/core/injection_container.dart';
import 'package:mobile/features/Authentication/domain/entities/user.dart';
import 'package:mobile/features/Authentication/domain/repositories/login_repository.dart';

class CreateFolderConfirmationPage extends StatefulWidget {
  final String folderName;
  final String channelName;

  const CreateFolderConfirmationPage({
    super.key,
    required this.folderName,
    required this.channelName,
  });

  @override
  State<CreateFolderConfirmationPage> createState() =>
      _CreateFolderConfirmationPageState();
}

class _CreateFolderConfirmationPageState
    extends State<CreateFolderConfirmationPage> {
  User? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final loginRepository = sl<LoginRepository>();
      final userResult = await loginRepository.getCurrentUser();
      
      userResult.fold(
        (failure) {
          print('Error loading user: ${failure.message}');
          setState(() {
            isLoading = false;
          });
        },
        (user) {
          setState(() {
            currentUser = user;
            isLoading = false;
          });
        },
      );
    } catch (e) {
      print('Error in _loadCurrentUser: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handleLanguageChanged() {
    setState(() {});
  }

  void _viewChannel() {
    // Navigate back to dashboard to view the channel
    context.goNamed(Routelists.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenSize.height),
          child: Center(
            child: Container(
              width: screenSize.width > 1200 ? 1200 : screenSize.width * 0.95,
              margin: const EdgeInsets.symmetric(vertical: 20.0),
              decoration: BoxDecoration(
                color: AppTheme.primary,
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
                children: [
                  // Main Content
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Top Header
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: TopHeader(),
                          ),

                          // Success Content
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Main success content
                                  Expanded(
                                    child: Container(
                                      color: Colors.white,
                                      child: _buildSuccessContent(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  AppFooter(onLanguageChanged: _handleLanguageChanged),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success Message Section
          SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  context.goNamed(Routelists.dashboard);
                },
                child: Icon(Icons.close, size: 32, color: Colors.black),
              ),
            ],
          ),
          SizedBox(height: 24),
          Container(
            width: double.infinity,

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success message
                Text(
                  isLoading 
                      ? 'channels.folder_created_success_message'.tr()
                      : 'channels.folder_created_success_message_with_name'.tr(
                          namedArgs: {'name': currentUser?.firstName ?? 'User'}
                        ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),

                // View Channel Button
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: _viewChannel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        // borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.black87, width: 3),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'channels.view_channel_button'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          const SizedBox(height: 150),

          // Information Section
        ],
      ),
    );
  }
}
