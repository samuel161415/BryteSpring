import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/core/theme/app_theme.dart';

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Deine Kanäle
          _buildSection(
            title: 'dashboard.sidebar.channels'.tr(),
            items: [
              'dashboard.sidebar.my_channels'.tr(),
              'dashboard.sidebar.company'.tr(),
              'dashboard.sidebar.publishing'.tr(),
            ],
            addButtonText: 'dashboard.sidebar.add_channel'.tr(),
          ),
          
          const SizedBox(height: 32),
          
          // Deine Assets
          _buildSection(
            title: 'dashboard.sidebar.assets'.tr(),
            items: [
              'dashboard.sidebar.employee_images'.tr(),
              'dashboard.sidebar.company_materials'.tr(),
            ],
            addButtonText: 'dashboard.sidebar.add_assets'.tr(),
          ),
          
          const SizedBox(height: 32),
          
          // Deine Verse
          _buildSection(
            title: 'dashboard.sidebar.verses'.tr(),
            items: [],
            addButtonText: '',
            customWidget: _buildVerseSection(),
          ),
          
          const SizedBox(height: 32),
          
          // Einstellungen
          _buildSection(
            title: 'dashboard.sidebar.settings'.tr(),
            items: [
              'dashboard.sidebar.links'.tr(),
              'dashboard.sidebar.help_support'.tr(),
            ],
            addButtonText: 'dashboard.sidebar.add_more'.tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> items,
    required String addButtonText,
    Widget? customWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        
        if (customWidget != null) ...[
          const SizedBox(height: 16),
          customWidget,
        ] else ...[
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          )),
        ],
        
        if (addButtonText.isNotEmpty) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              // TODO: Implement add functionality
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
            child: Text(
              addButtonText,
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVerseSection() {
    return Row(
      children: [
        // BryteVerse Logo (smaller version)
        Column(
          children: [
            Row(
              children: [
                Text(
                  'BRYTE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 4),
                Row(
                  children: List.generate(2, (index) => 
                    Container(
                      width: 3,
                      height: 3,
                      margin: const EdgeInsets.only(right: 1),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'VERSE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
        
        const SizedBox(width: 12),
        
        // Notification badge
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primary,
          ),
          child: const Center(
            child: Text(
              '1',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
