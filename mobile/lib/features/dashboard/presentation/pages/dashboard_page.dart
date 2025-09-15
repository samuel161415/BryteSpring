import 'package:flutter/material.dart';
import 'package:mobile/core/constant.dart';
import 'package:mobile/core/widgets/app_footer.dart';
import 'package:mobile/features/dashboard/presentation/components/dashboard_header.dart';
import 'package:mobile/features/dashboard/presentation/components/dashboard_sidebar.dart';
import 'package:mobile/features/dashboard/presentation/components/dashboard_main_content.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
          
          // Footer - Using existing AppFooter
          AppFooter(
            onLanguageChanged: () {
              setState(() {
                // Force rebuild when language changes
              });
            },
          ),
        ],
      ),
    );
  }
}
