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
    _loadSampleChannels(); // Add sample data for testing
  }

  void _loadSampleChannels() {
    // Create sample hierarchical channel data
    final sampleChannels = [
      ChannelEntity(
        id: '1',
        verseId: '68c3e2d6f58c817ebed1ca74',
        name: 'Unternehmensdaten',
        type: 'folder',
        description: 'Corporate data folder',
        path: '/unternehmensdaten',
        assetTypes: [],
        visibility: const ChannelVisibility(isPublic: true, inheritedFromParent: false),
        folderSettings: const ChannelFolderSettings(allowSubfolders: true, maxDepth: 5),
        createdBy: const CreatedBy(id: '1', firstName: 'Admin', lastName: 'User'),
        createdAt: DateTime.now(),
        children: [
          ChannelEntity(
            id: '2',
            verseId: '68c3e2d6f58c817ebed1ca74',
            name: 'Corporate Data',
            type: 'folder',
            description: 'Corporate data subfolder',
            path: '/unternehmensdaten/corporate-data',
            assetTypes: [],
            visibility: const ChannelVisibility(isPublic: true, inheritedFromParent: true),
            folderSettings: const ChannelFolderSettings(allowSubfolders: true, maxDepth: 4),
            createdBy: const CreatedBy(id: '1', firstName: 'Admin', lastName: 'User'),
            createdAt: DateTime.now(),
            children: [],
          ),
          ChannelEntity(
            id: '3',
            verseId: '68c3e2d6f58c817ebed1ca74',
            name: 'Corporate Design',
            type: 'folder',
            description: 'Corporate design subfolder',
            path: '/unternehmensdaten/corporate-design',
            assetTypes: [],
            visibility: const ChannelVisibility(isPublic: true, inheritedFromParent: true),
            folderSettings: const ChannelFolderSettings(allowSubfolders: true, maxDepth: 4),
            createdBy: const CreatedBy(id: '1', firstName: 'Admin', lastName: 'User'),
            createdAt: DateTime.now(),
            children: [
              ChannelEntity(
                id: '4',
                verseId: '68c3e2d6f58c817ebed1ca74',
                name: 'Logos',
                type: 'folder',
                description: 'Logo assets',
                path: '/unternehmensdaten/corporate-design/logos',
                assetTypes: ['image'],
                visibility: const ChannelVisibility(isPublic: true, inheritedFromParent: true),
                folderSettings: const ChannelFolderSettings(allowSubfolders: false, maxDepth: 3),
                createdBy: const CreatedBy(id: '1', firstName: 'Admin', lastName: 'User'),
                createdAt: DateTime.now(),
                children: [],
              ),
              ChannelEntity(
                id: '5',
                verseId: '68c3e2d6f58c817ebed1ca74',
                name: 'Brand Guidelines',
                type: 'folder',
                description: 'Brand guideline documents',
                path: '/unternehmensdaten/corporate-design/brand-guidelines',
                assetTypes: ['document'],
                visibility: const ChannelVisibility(isPublic: true, inheritedFromParent: true),
                folderSettings: const ChannelFolderSettings(allowSubfolders: false, maxDepth: 3),
                createdBy: const CreatedBy(id: '1', firstName: 'Admin', lastName: 'User'),
                createdAt: DateTime.now(),
                children: [],
              ),
            ],
          ),
        ],
      ),
    ];

    setState(() {
      channels = sampleChannels;
    });
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
            width: 280,
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

  Widget _buildChannelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back to Dashboard link
        InkWell(
          onTap: () {
            // TODO: Navigate back to dashboard
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'zurück zum Dashboard',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),

        // Main heading - Unternehmensdaten
        Text(
          'Unternehmensdaten',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 12),

        // Channel tree view
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          width: double.infinity,
          child: SingleChildScrollView(
            child: ChannelTreeView(
              channels: channels,
              onChannelTap: _handleChannelTap,
              onFolderTap: _handleFolderTap,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Action buttons
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add folder button
            InkWell(
              onTap: () {
                // TODO: Implement add folder functionality
                _showAddFolderDialog();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.add, size: 16, color: Colors.teal[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Ordner hinzufügen',
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

            const SizedBox(height: 8),

            // Add asset button
            InkWell(
              onTap: () {
                // TODO: Implement add asset functionality
                _showAddAssetDialog();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.add, size: 16, color: Colors.teal[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Asset hinzufügen',
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

  void _showAddFolderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ordner hinzufügen'),
          content: const Text('Funktion wird bald verfügbar sein.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAddAssetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Asset hinzufügen'),
          content: const Text('Funktion wird bald verfügbar sein.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
