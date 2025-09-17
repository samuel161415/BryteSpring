import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constant.dart';
import 'package:mobile/core/widgets/app_footer.dart';
import 'package:mobile/features/verse_join/presentation/components/top_part_widget.dart';
import 'package:mobile/core/routing/routeLists.dart';

class CreateFolderConfirmationPage extends StatefulWidget {
  final String folderName;
  final String channelName;

  const CreateFolderConfirmationPage({
    super.key,
    required this.folderName,
    required this.channelName,
  });

  @override
  State<CreateFolderConfirmationPage> createState() => _CreateFolderConfirmationPageState();
}

class _CreateFolderConfirmationPageState extends State<CreateFolderConfirmationPage> {
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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success Message Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success message
                Text(
                  'channels.folder_created_success_message'.tr(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // View Channel Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _viewChannel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
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
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Information Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.teal[600],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main slogan
                Text(
                  'channels.bryteverse_slogan'.tr(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Two column layout
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column - Features
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFeatureItem('channels.feature_no_data_send'.tr()),
                          _buildFeatureItem('channels.feature_no_data_store'.tr()),
                          _buildFeatureItem('channels.feature_content_manage'.tr()),
                          _buildFeatureItem('channels.feature_content_share'.tr()),
                          _buildFeatureItem('channels.feature_content_organize'.tr()),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Right column - Social Media & Links
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Social Media
                          Text(
                            'channels.social_media'.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildSocialIcon('f'),
                              const SizedBox(width: 12),
                              _buildSocialIcon('in'),
                              const SizedBox(width: 12),
                              _buildSocialIcon('X'),
                              const SizedBox(width: 12),
                              _buildSocialIcon('V'),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Relevant Links
                          Text(
                            'channels.relevant_links'.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildLinkItem('channels.contact'.tr()),
                          _buildLinkItem('channels.imprint'.tr()),
                          _buildLinkItem('channels.privacy'.tr()),
                          _buildLinkItem('channels.terms'.tr()),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(String icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          icon,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.teal[600],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
          height: 1.4,
        ),
      ),
    );
  }
}
