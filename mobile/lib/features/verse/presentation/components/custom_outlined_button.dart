import 'package:flutter/material.dart';

class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isEnabled;
  final bool isLoading;

  const CustomOutlinedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.isEnabled,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4, right: 4),
      height: 48,
      width: 390,
      decoration: BoxDecoration(
        border: Border.all(
          color: isEnabled ? Colors.black : Colors.grey,
          width: 4,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size.fromHeight(48),
        ),
        child: isLoading
            ? CircularProgressIndicator()
            : Text(
                text,
                style: TextStyle(
                  color: isEnabled ? Colors.black : Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
