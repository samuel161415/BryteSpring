import 'package:flutter/material.dart';
import 'package:mobile/core/constant.dart';
import 'package:mobile/core/widgets/app_footer.dart';
import 'package:mobile/features/verse_join/presentation/components/top_part_widget.dart';
import 'package:mobile/features/dashboard/presentation/components/dashboard_sidebar.dart';
import 'package:mobile/features/dashboard/presentation/components/dashboard_main_content.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  void _handleLanguageChanged() {
    // Force rebuild when language changes
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: screenSize.width > 1200 ? 1200 : screenSize.width * 0.95,
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
              children: [
                // Dashboard Content
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
                        
                        // Dashboard Content
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
    );
  }
}
