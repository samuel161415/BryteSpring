import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/injection_container.dart';
import 'package:mobile/core/routing/routeLists.dart';
import 'package:mobile/core/widgets/channel_tree_shimmer.dart';
import 'package:mobile/features/Authentication/domain/entities/user.dart';
import 'package:mobile/features/Authentication/domain/repositories/login_repository.dart';
import 'package:mobile/features/channels/domain/entities/channel_entity.dart';
import 'package:mobile/features/channels/presentation/bloc/channel_bloc.dart';
import 'package:mobile/features/channels/presentation/components/channel_tree_view.dart';
import 'package:mobile/features/dashboard/presentation/bloc/dashboard_bloc.dart';

class DashboardSidebar extends StatefulWidget {
  const DashboardSidebar({super.key});

  @override
  State<DashboardSidebar> createState() => _DashboardSidebarState();
}

class _DashboardSidebarState extends State<DashboardSidebar> {
  User? currentUser;
  String? currentVerseId;
  List<ChannelEntity> channels = [];

  @override
  void initState() {
    super.initState();
    _loadUserAndChannels();
    _loadSampleChannels(); // Add sample data for testing
  }

  void _loadSampleChannels() {
    // Sample channels removed - using real data from API
    setState(() {
      // channels = sampleChannels;
    });
  }

  Future<void> _loadUserAndChannels() async {
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
          if (user != null) {
            setState(() {
              currentUser = user;
              // Use the first joined verse from user data
              if (user.joinedVerse.isNotEmpty) {
                currentVerseId = user.joinedVerse.first;
              }
            });

            // Load channels for the first joined verse
            if (currentVerseId != null) {
              context.read<ChannelBloc>().add(
                LoadChannelStructure(currentVerseId!),
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
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading user: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChannelBloc, ChannelState>(
      listener: (context, state) {
        if (state is ChannelStructureLoaded) {
          setState(() {
            channels = state.structure.structure;
          });
        } else if (state is ChannelFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load channels: ${state.message}'),
            ),
          );
        }
      },
      child: BlocBuilder<ChannelBloc, ChannelState>(
        builder: (context, state) {
          return Container(
            width: 280,
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Deine Kanäle
                _buildChannelSection(),

                const SizedBox(height: 32),

                // Deine Assets
                _buildSection(
                  title: 'dashboard.sidebar.assets'.tr(),
                  items: [
                    'dashboard.sidebar.employee_images'.tr(),
                    'dashboard.sidebar.company_materials'.tr(),
                  ],
                  addButtonText: 'dashboard.sidebar.add_assets'.tr(),
                  onAddTap: _showAddAssetDialog,
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
                    'dashboard.sidebar.settings'.tr(),
                    'dashboard.sidebar.links'.tr(),
                    'Statistiken',
                  ],
                  addButtonText: '+ Nutzer hinzufügen',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChannelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          'dashboard.sidebar.channels'.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        // Channel tree view with shimmer loading
        Container(
          constraints: const BoxConstraints(maxHeight: 280),

          width: double.infinity,
          child: SingleChildScrollView(
            child: BlocBuilder<ChannelBloc, ChannelState>(
              builder: (context, state) {
                if (state is ChannelLoading) {
                  return const ChannelTreeShimmer();
                } else if (state is ChannelStructureLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Offline indicator for channels
                      if (state.isFromCache) _buildChannelOfflineIndicator(),
                      ChannelTreeView(
                        channels: state.structure.structure,
                        onChannelTap: _handleChannelTap,
                        onFolderTap: _handleFolderTap,
                      ),
                    ],
                  );
                } else if (state is ChannelFailure) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Offline indicator for error state
                        if (state.isOffline) _buildChannelOfflineIndicator(),
                        Center(
                          child: Text(
                            'dashboard.error.loading_channels'.tr() +
                                ' ${state.message}',
                            style: TextStyle(
                              color: Colors.red[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Fallback to sample data or empty state
                  return ChannelTreeView(
                    channels: channels,
                    onChannelTap: _handleChannelTap,
                    onFolderTap: _handleFolderTap,
                  );
                }
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Add Folder Button
        InkWell(
          onTap: () {
            if (currentVerseId != null) {
              context.pushNamed(
                Routelists.createFolder,
                extra: {'verseId': currentVerseId!},
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'No verse selected. Please join a verse first.',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(Icons.add, size: 16, color: Colors.teal[600]),
                const SizedBox(width: 8),
                Text(
                  'channels.add_folder'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.teal[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleChannelTap(ChannelEntity channel) {
    // TODO: Navigate to channel content or show channel details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected channel: ${channel.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleFolderTap(ChannelEntity folder) {
    // TODO: Handle folder tap (maybe show folder info or navigate)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected folder: ${folder.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildChannelOfflineIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 16, color: Colors.orange[600]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Offline: Kanäle aus Cache',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Trigger channel refresh
              context.read<ChannelBloc>().add(
                RefreshChannelStructure('68c3e2d6f58c817ebed1ca74'),
              );
            },
            child: Text(
              'Aktualisieren',
              style: TextStyle(
                fontSize: 10,
                color: Colors.orange[600],
                fontWeight: FontWeight.w600,
              ),
            ),
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
    VoidCallback? onAddTap,
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
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                item,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ),
        ],

        if (addButtonText.isNotEmpty) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap:
                onAddTap ??
                () {
                  // TODO: Implement add functionality
                },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    addButtonText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.teal[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVerseSection() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        String verseName = 'BRIGHT NETWORKS'; // Default fallback

        if (state is DashboardLoaded) {
          verseName = state.dashboardData.data.verse.name;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Main content
              Column(
                children: [
                  // Downward arrow icon
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 24,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  // Verse name
                  Text(
                    verseName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              // Teal plus icon in top right
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.teal[600],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddAssetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('dashboard.asset.add_dialog_title'.tr()),
          content: Text('dashboard.asset.add_dialog_content'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('dashboard.folder.ok'.tr()),
            ),
          ],
        );
      },
    );
  }
}
