import 'package:flutter/material.dart';

class TopHeader extends StatelessWidget {
  final List<String>? avatarUrls;
  final VoidCallback? onMenuTap;
  final double height;

  const TopHeader({Key? key, this.avatarUrls, this.onMenuTap, this.height = 56})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    const menuAccent = Color(0xFF3EC1B7);
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildAvatars(),
          Image.asset('assets/images/publify.png', height: 45),
          InkWell(
            onTap:
                onMenuTap ??
                () => ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Menu tapped'))),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'MENU',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      return Container(
                        width: 28,
                        height: 2,
                        margin: EdgeInsets.only(bottom: i == 2 ? 0 : 4),
                        decoration: BoxDecoration(
                          color: menuAccent.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatars() {
    final urls = avatarUrls ?? [];
    final first = urls.isNotEmpty ? urls[0] : null;
    final second = urls.length > 1 ? urls[1] : null;

    const avatarSize = 36.0;
    const overlap = 24.0;

    return SizedBox(
      width: avatarSize + overlap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            child: _avatar(first, radius: avatarSize / 2, initials: 'S'),
          ),
          Positioned(
            left: overlap,
            child: _avatar(second, radius: avatarSize / 2, initials: 'J'),
          ),
        ],
      ),
    );
  }

  Widget _avatar(
    String? url, {
    required double radius,
    required String initials,
  }) {
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(radius: radius, backgroundImage: NetworkImage(url));
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade700,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
