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

  @override
  Widget build(BuildContext context) {
    if (widget.channels.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No channels available',
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
        // Expand/Collapse All buttons
        if (widget.showExpandCollapseButtons && _hasFolders(widget.channels))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                TextButton(
                  onPressed: expandAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Expand All',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: collapseAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Collapse All',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Tree items
        ..._buildRecursiveTreeItems(widget.channels, 0),
      ],
    );
  }

  bool _hasFolders(List<ChannelEntity> channels) {
    for (final channel in channels) {
      if (channel.type == 'folder' || channel.children.isNotEmpty) {
        return true;
      }
    }
    return false;
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
    if (channel.type == 'folder') {
      // Toggle folder expansion
      _toggleExpansion(channel.id);
      // Call folder tap callback if provided
      widget.onFolderTap?.call(channel);
    } else {
      // Call channel tap callback
      widget.onChannelTap?.call(channel);
    }
  }

  // Method to expand all folders
  void expandAll() {
    setState(() {
      _expandedItems.clear();
      _addAllChannelIds(widget.channels);
    });
  }

  // Method to collapse all folders
  void collapseAll() {
    setState(() {
      _expandedItems.clear();
    });
  }

  void _addAllChannelIds(List<ChannelEntity> channels) {
    for (final channel in channels) {
      if (channel.children.isNotEmpty) {
        _expandedItems.add(channel.id);
        _addAllChannelIds(channel.children);
      }
    }
  }
}
