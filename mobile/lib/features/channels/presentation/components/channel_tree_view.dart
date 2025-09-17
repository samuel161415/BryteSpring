import 'package:flutter/material.dart';
import 'package:mobile/features/channels/domain/entities/channel_entity.dart';
import 'package:mobile/features/channels/presentation/components/channel_tree_item.dart';

class ChannelTreeView extends StatefulWidget {
  final List<ChannelEntity> channels;
  final Function(ChannelEntity)? onChannelTap;
  final Function(ChannelEntity)? onFolderTap;
  final bool showExpandCollapseButtons;

  const ChannelTreeView({
    super.key,
    required this.channels,
    this.onChannelTap,
    this.onFolderTap,
    this.showExpandCollapseButtons = true,
  });

  @override
  State<ChannelTreeView> createState() => _ChannelTreeViewState();
}

class _ChannelTreeViewState extends State<ChannelTreeView> {
  final Set<String> _expandedItems = <String>{};
  String? _selectedItemId;

  @override
  void initState() {
    super.initState();
    // Expand all folders by default to show sub-folders
    _expandAllFolders();
  }

  @override
  void didUpdateWidget(ChannelTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-expand folders when channels change
    if (oldWidget.channels != widget.channels) {
      _expandAllFolders();
    }
  }

  void _expandAllFolders() {
    _expandedItems.clear();
    _addAllFolderIds(widget.channels);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.channels.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Keine Kanäle verfügbar',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tree items
        ..._buildRecursiveTreeItems(widget.channels, 0),
      ],
    );
  }


  List<Widget> _buildRecursiveTreeItems(List<ChannelEntity> channels, int level) {
    List<Widget> items = [];
    
    for (final channel in channels) {
      final hasChildren = channel.children.isNotEmpty;
      final isExpanded = _expandedItems.contains(channel.id);
      
      // Add the current item
      items.add(
        ChannelTreeItem(
          channel: channel,
          level: level,
          isExpanded: isExpanded,
          isSelected: _selectedItemId == channel.id,
          onTap: () => _handleItemTap(channel),
          onExpandToggle: hasChildren ? () => _toggleExpansion(channel.id) : null,
        ),
      );
      
      // Add children if expanded
      if (isExpanded && hasChildren) {
        items.addAll(_buildRecursiveTreeItems(channel.children, level + 1));
      }
    }
    
    return items;
  }

  void _toggleExpansion(String channelId) {
    setState(() {
      if (_expandedItems.contains(channelId)) {
        _expandedItems.remove(channelId);
      } else {
        _expandedItems.add(channelId);
      }
    });
  }

  void _handleItemTap(ChannelEntity channel) {
    setState(() {
      _selectedItemId = channel.id;
    });

    if (channel.children.isNotEmpty) {
      // Toggle expansion for items with children
      _toggleExpansion(channel.id);
      // Call appropriate callback
      if (channel.type == 'folder') {
        widget.onFolderTap?.call(channel);
      } else {
        widget.onChannelTap?.call(channel);
      }
    } else {
      // Call channel tap callback for items without children
      widget.onChannelTap?.call(channel);
    }
  }

  // Method to expand all folders
  void expandAll() {
    setState(() {
      _expandedItems.clear();
      _addAllFolderIds(widget.channels);
    });
  }

  // Method to collapse all folders
  void collapseAll() {
    setState(() {
      _expandedItems.clear();
    });
  }

  void _addAllFolderIds(List<ChannelEntity> channels) {
    for (final channel in channels) {
      if (channel.type == 'folder' && channel.children.isNotEmpty) {
        _expandedItems.add(channel.id);
        _addAllFolderIds(channel.children);
      }
    }
  }
}
