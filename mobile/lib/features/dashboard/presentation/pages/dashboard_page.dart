import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/constant.dart';
import 'package:mobile/core/injection_container.dart';
import 'package:mobile/core/widgets/app_footer.dart';
import 'package:mobile/features/verse_join/presentation/components/top_part_widget.dart';
import 'package:mobile/features/verse_join/domain/repositories/verse_join_repository.dart';
import 'package:mobile/features/dashboard/presentation/components/dashboard_sidebar.dart';
import 'package:mobile/features/dashboard/presentation/components/dashboard_main_content_new.dart';
import 'package:mobile/features/dashboard/presentation/bloc/dashboard_bloc.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? currentVerseId;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final verseJoinRepository = sl<VerseJoinRepository>();
      
      // Load joined verses and use the first one
      final joinedVersesResult = await verseJoinRepository.getJoinedVerses();
      
      joinedVersesResult.fold(
        (failure) {
          // Handle error - no joined verses
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No joined verses found: ${failure.message}'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        (joinedVerses) {
          if (joinedVerses.isNotEmpty) {
            setState(() {
              currentVerseId = joinedVerses.first.id;
            });
            
            // Load dashboard data for the first joined verse
            context.read<DashboardBloc>().add(
              LoadDashboardData(joinedVerses.first.id),
            );
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No joined verses found'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleLanguageChanged() {
    // Force rebuild when language changes
    setState(() {});
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
}
