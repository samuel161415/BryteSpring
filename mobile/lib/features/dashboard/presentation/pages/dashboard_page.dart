import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/dashboard/presentation/components/dashboard_header.dart';
import 'package:mobile/features/dashboard/presentation/components/dashboard_sidebar.dart';
import 'package:mobile/features/dashboard/presentation/components/dashboard_main_content.dart';
import 'package:mobile/features/dashboard/presentation/components/dashboard_footer.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Header
          const DashboardHeader(),
          
          // Main content area
          Expanded(
            child: Row(
              children: [
                // Sidebar
                const DashboardSidebar(),
                
                // Main content
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: const DashboardMainContent(),
                  ),
                ),
              ],
            ),
          ),
          
          // Footer
          const DashboardFooter(),
        ],
      ),
    );
  }
}
