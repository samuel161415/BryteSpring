import 'package:flutter/material.dart';
import 'package:mobile/features/channels/domain/entities/channel_entity.dart';

class ChannelTreeItem extends StatefulWidget {
  final ChannelEntity channel;
  final int level;
  final bool isExpanded;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onExpandToggle;

  const ChannelTreeItem({
    super.key,
    required this.channel,
    this.level = 0,
    this.isExpanded = false,
    this.isSelected = false,
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
    final isFolder = widget.channel.type == 'folder';
    final isSubItem = widget.level > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: EdgeInsets.only(
                left: isSubItem ? 16 + (widget.level * 16) : 0,
                right: 16,
                top: 6,
                bottom: 6,
              ),
              decoration: BoxDecoration(
                color: _isHovered ? Colors.grey[50] : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: IntrinsicWidth(
                child: Row(
                  children: [
                    // Prefix for sub-items (=)
                    if (isSubItem)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          '=',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),

                    // Channel/Folder name with bold styling for selected/expanded
                    Expanded(
                      child: Text(
                        widget.channel.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: (widget.isSelected || widget.isExpanded) 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Additional info (optional)
                    if (widget.channel.children.isNotEmpty && isFolder)
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
