import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/injection_container.dart';
import 'package:mobile/core/services/dynamic_theme_service.dart';
import 'package:mobile/core/widgets/app_footer.dart';
import 'package:mobile/features/verse_join/presentation/components/top_part_widget.dart';
import 'package:mobile/features/Authentication/domain/repositories/login_repository.dart';
import 'package:mobile/features/dashboard/presentation/components/dashboard_sidebar.dart';
import 'package:mobile/features/dashboard/presentation/components/dashboard_main_content_new.dart';
import 'package:mobile/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:mobile/features/Authentication/domain/entities/user.dart';
import 'package:mobile/features/Authentication/domain/entities/invitation_entity.dart';
import 'package:mobile/features/verse_join/domain/usecases/verse_join_usecase.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routing/routeLists.dart';
import 'package:mobile/core/services/auth_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? currentVerseId;
  late DynamicThemeService _themeService;
  User? _user;
  InvitationEntity? _firstPendingInvitation;
  bool _hasNoJoinedVerse = false;
  bool _isAcceptingInvitation = false;
  bool _isLoggingOut = false;
  @override
  void initState() {
    super.initState();
    _themeService = sl<DynamicThemeService>();
    _themeService.addListener(_onThemeChanged);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _themeService.removeListener(_onThemeChanged); // Add this line
    super.dispose();
  }

  void _onThemeChanged() {
    // Add this method
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      final loginRepository = sl<LoginRepository>();

      // Load current user
      final userResult = await loginRepository.getCurrentUser();

      userResult.fold(
        (failure) {
          // Handle error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load user: ${failure.message}'),
              ),
            );
          }
        },
        (user) {
          _user = user;
          if (user != null && user.joinedVerse.isNotEmpty) {
            setState(() {
              currentVerseId = user.joinedVerse.first;
              _hasNoJoinedVerse = false;
              _firstPendingInvitation = null;
            });

            // Load dashboard data for the first joined verse
            context.read<DashboardBloc>().add(
              LoadDashboardData(currentVerseId!),
            );
          } else {
            // No joined verses - auto-handle pending invitation if present
            if (user != null && user.pendingInvitations.isNotEmpty) {
              _firstPendingInvitation = user.pendingInvitations.first;
              // Trigger the same logic as Accept button
              _handlePendingInvitation();
            }
            setState(() {
              _hasNoJoinedVerse = true;
              currentVerseId = null;
            });
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
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenSize.height),
          child: Center(
            child: Container(
              width: screenSize.width > 1200 ? 1200 : screenSize.width,
              // margin: const EdgeInsets.symmetric(vertical: 20.0),
              decoration: BoxDecoration(
                color: _themeService.getCurrentSurfaceColor(),
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
                                      child: DashboardMainContent(
                                        verseId: currentVerseId,
                                      ),
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

  //   Widget _buildNoVerseState(BuildContext context) {
  //     return Container(
  //       width: double.infinity,
  //       child: Padding(
  //         padding: const EdgeInsets.all(24.0),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             const SizedBox(height: 24),
  //             const Icon(Icons.info_outline, color: Colors.orange, size: 40),
  //             const SizedBox(height: 12),
  //             const Text(
  //               'You have not joined a verse yet.',
  //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
  //             ),
  //             const SizedBox(height: 8),
  //             const Text(
  //               'To use the dashboard, please join a pending invitation or create a verse.',
  //               textAlign: TextAlign.center,
  //             ),
  //             const SizedBox(height: 20),
  //             if (_firstPendingInvitation != null)
  //               InkWell(
  //                 onTap: _isAcceptingInvitation ? null : _handlePendingInvitation,
  //                 child: Container(
  //                   width: 200,
  //                   height: 40,
  //                   decoration: BoxDecoration(
  //                     border: Border.all(color: Colors.black, width: 4),
  //                     color: _isAcceptingInvitation ? Colors.grey[200] : null,
  //                   ),
  //                   child: Center(
  //                     child: _isAcceptingInvitation
  //                         ? const SizedBox(
  //                             width: 20,
  //                             height: 20,
  //                             child: CircularProgressIndicator(
  //                               strokeWidth: 2,
  //                               valueColor: AlwaysStoppedAnimation<Color>(
  //                                 Colors.black,
  //                               ),
  //                             ),
  //                           )
  //                         : const Text('Accept invitation'),
  //                   ),
  //                 ),
  //               ),
  //             const SizedBox(height: 12),
  //             InkWell(
  //               onTap: _isLoggingOut ? null : _handleLogout,
  //               child: Container(
  //                 width: 200,
  //                 height: 40,
  //                 decoration: BoxDecoration(
  //                   border: Border.all(color: Colors.black, width: 4),
  //                   color: _isLoggingOut ? Colors.grey[200] : null,
  //                 ),
  //                 child: Center(
  //                   child: _isLoggingOut
  //                       ? const SizedBox(
  //                           width: 20,
  //                           height: 20,
  //                           child: CircularProgressIndicator(
  //                             strokeWidth: 2,
  //                             valueColor: AlwaysStoppedAnimation<Color>(
  //                               Colors.black,
  //                             ),
  //                           ),
  //                         )
  //                       : const Text('Logout'),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 24),
  //           ],
  //         ),
  //       ),
  //     );
  //   }

  Future<void> _handlePendingInvitation() async {
    if (_firstPendingInvitation == null) return;
    try {
      setState(() {
        _isAcceptingInvitation = true;
      });
      final verseUseCase = sl<VerseJoinUseCase>();
      final result = await verseUseCase.getVerse(
        _firstPendingInvitation!.verseId,
      );
      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to fetch verse: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (verse) {
          if (verse.isSetupComplete) {
            // Join flow
            context.pushNamed(
              Routelists.almostJoinVerse,
              extra: _firstPendingInvitation,
            );
          } else {
            // Create/setup flow
            final name = (_user?.firstName ?? '').isNotEmpty
                ? _user!.firstName
                : 'User';
            final email = _user?.email ?? '';
            context.pushNamed(
              Routelists.createVerse,
              extra: {
                'verseId': _firstPendingInvitation!.verseId,
                'currentUserName': name,
                'email': email,
              },
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error handling pending invitation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAcceptingInvitation = false;
        });
      }
    }
  }

  //   Future<void> _handleLogout() async {
  //     try {
  //       setState(() {
  //         _isLoggingOut = true;
  //       });
  //       final authService = sl<AuthService>();
  //       await authService.logout();
  //       if (!mounted) return;
  //       context.goNamed(Routelists.login);
  //     } catch (e) {
  //       if (!mounted) return;
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Logout failed: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     } finally {
  //       if (!mounted) return;
  //       setState(() {
  //         _isLoggingOut = false;
  //       });
  //     }
  //   }
}
