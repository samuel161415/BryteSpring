import 'package:flutter/material.dart';
import 'package:mobile/core/constant.dart';
import 'package:mobile/features/channels/domain/entities/channel_entity.dart';

class ChannelTreeItem extends StatefulWidget {
  final ChannelEntity channel;
  final int level;
  final bool isExpanded;
  final VoidCallback? onTap;
  final VoidCallback? onExpandToggle;

  const ChannelTreeItem({
    super.key,
    required this.channel,
    this.level = 0,
    this.isExpanded = false,
    this.onTap,
    this.onExpandToggle,
  });

  @override
  State<ChannelTreeItem> createState() => _ChannelTreeItemState();
}

class _ChannelTreeItemState extends State<ChannelTreeItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.channel.children.isNotEmpty;
    final isFolder = widget.channel.type == 'folder';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.only(
                left: 16 + (widget.level * 20),
                right: 16,
                top: 8,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                color: _isHovered ? Colors.grey[100] : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IntrinsicWidth(
                child: Row(
                  children: [
                    // Expand/Collapse button
                    if (hasChildren)
                      InkWell(
                        onTap: widget.onExpandToggle,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          child: Icon(
                            widget.isExpanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_right,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 20),

                    const SizedBox(width: 8),

                    // Folder/Channel icon
                    Icon(
                      isFolder
                          ? (widget.isExpanded ? Icons.folder_open : Icons.folder)
                          : Icons.video_library,
                      size: 18,
                      color: isFolder
                          ? Colors.orange[600]
                          : AppTheme.primary,
                    ),

                    const SizedBox(width: 8),

                    // Channel/Folder name
                    Expanded(
                      child: Text(
                        widget.channel.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: isFolder ? FontWeight.w500 : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Additional info (optional)
                    if (widget.channel.children.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${widget.channel.children.length}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
