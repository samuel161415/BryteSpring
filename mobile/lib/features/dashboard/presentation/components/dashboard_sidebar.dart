import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/constant.dart';
import 'package:mobile/core/injection_container.dart';
import 'package:mobile/features/Authentication/domain/entities/user.dart';
import 'package:mobile/features/Authentication/domain/repositories/login_repository.dart';
import 'package:mobile/features/channels/domain/entities/channel_entity.dart';
import 'package:mobile/features/channels/presentation/bloc/channel_bloc.dart';
import 'package:mobile/features/channels/presentation/components/channel_tree_view.dart';

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
  }

  Future<void> _loadUserAndChannels() async {
    try {
      final loginRepository = sl<LoginRepository>();
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
          if (user != null && user.joinedVerse.isNotEmpty) {
            setState(() {
              currentUser = user;
              currentVerseId = user.joinedVerse.first; // Use first joined verse
            });

            // Load channels for the first joined verse
            context.read<ChannelBloc>().add(
              LoadChannelStructure(user.joinedVerse.first),
            );
          } else {
            // If no user or no joined verses, load with hardcoded verse ID for testing
            context.read<ChannelBloc>().add(
              LoadChannelStructure('68c3e2d6f58c817ebed1ca74'),
            );
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
            // width: 280,
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
        },
      ),
    );
  }

  List<String> _buildChannelItems() {
    if (channels.isEmpty) {
      return ['dashboard.sidebar.no_channels'.tr()];
    }

    return channels.map((channel) => channel.name).toList();
  }

  Widget _buildChannelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and add button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'dashboard.sidebar.channels'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement add channel functionality
                _showAddChannelDialog();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              child: Text(
                'dashboard.sidebar.add_channel'.tr(),
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Channel tree view
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: SingleChildScrollView(
            child: ChannelTreeView(
              channels: channels,
              onChannelTap: _handleChannelTap,
              onFolderTap: _handleFolderTap,
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

  void _showAddChannelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('dashboard.sidebar.add_channel'.tr()),
        content: const Text(
          'Add channel functionality will be implemented here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement actual add channel logic
            },
            child: const Text('Add'),
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
                  children: List.generate(
                    2,
                    (index) => Container(
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
