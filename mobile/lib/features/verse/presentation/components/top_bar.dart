import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Profile Image
        const CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(
            "https://avatar.iran.liara.run/public/4",
          ), // replace with real profile
        ),

        // Logo
        Image.asset(
          'assets/images/bryteversebubbles_black_logo.png',
          height: 60,
        ),

        // Menu
        Column(
          children: [
            Text(
              "MENU",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Column(
              children: [
                Container(width: 20, height: 2, color: Colors.red),
                const SizedBox(height: 4),
                Container(width: 20, height: 2, color: Colors.red),
                const SizedBox(height: 4),
                Container(width: 20, height: 2, color: Colors.red),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
