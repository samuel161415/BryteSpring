import 'package:flutter/material.dart';

class BackAndCancelWidget extends StatelessWidget {
  const BackAndCancelWidget({super.key, required this.controller});

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    Future<bool> _showCancelEditDialog(BuildContext context) async {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap a button
        builder: (context) => AlertDialog(
          title: const Text("Cancel Creating Verse"),
          content: const Text("Are you sure you want to erase your changes?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // stay
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                controller.jumpToPage(0);
              },
              child: const Text("Yes, Cancel"),
            ),
          ],
        ),
      );
      return result ?? false;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            controller.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            _showCancelEditDialog(context);
          },
        ),
      ],
    );
  }
}
