import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_aws_s3_client/flutter_aws_s3_client.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/features/upload/presentation/bloc/upload_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../upload/presentation/bloc/upload_event.dart';
import '../../../upload/presentation/bloc/upload_state.dart';
import 'verse_welcome_widget.dart';
import 'top_bar.dart';
import 'custom_outlined_button.dart';
import '../../domain/entities/verse.dart';

class AddVerseLogoWidget extends StatefulWidget {
  const AddVerseLogoWidget({
    super.key,
    required this.screenSize,
    required this.controller,
    required this.verse,
  });
  final PageController controller;
  final Verse verse;

  final Size screenSize;

  @override
  State<AddVerseLogoWidget> createState() => _AddVerseLogoWidgetState();
}

class _AddVerseLogoWidgetState extends State<AddVerseLogoWidget> {
  TextEditingController verseNameController = TextEditingController();
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  // DigitalOcean Spaces config
  final String accessKey = "DO00HGQXXCK8LBVQZBMK";
  final String secretKey = "3p1PxKX1WDMezrJ50YV6QyCRgtlUfBp43ySlenl3yCM";
  final String endpoint =
      "https://brightspace.fra1.digitaloceanspaces.com"; // your region
  final String bucket = "brightspace";

  // Pick image
  Future<void> _pickImage() async {
    // Request storage permission
    // final XFile? pickedFile = await _picker.pickImage(
    //   source: ImageSource.gallery,
    // );
    PermissionStatus status = await Permission.photos
        .request(); // or Permission.storage for Android

    // if (status.isGranted) {
    //   final XFile? pickedFile = await _picker.pickImage(
    //     source: ImageSource.gallery,
    //   );
    //   if (pickedFile != null) {
    //     // Use pickedFile (e.g., show preview or upload)
    //     setState(() {
    //       _selectedImage = File(pickedFile.path);
    //     });
    //   }
    // } else if (status.isDenied) {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      // Use pickedFile (e.g., show preview or upload)
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
    // openAppSettings();

    print("Permission denied by user");
    // }
    // else if (status.isPermanentlyDenied) {
    //   print("Permission permanently denied, open app settings");
    //   openAppSettings();
    // }
  }

  // Upload image to DigitalOcean Spaces using Dio

  Future<void> uploadFile() async {
    try {
      final dio = Dio();

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: _selectedImage!.path, // keeps original filename
        ),
        "verse_id": "68cb9ec5fdfa9ba64f6f6146",
        "folder_path": "logo",
      });

      final response = await dio.post(
        "https://brytespring-app-itrx7.ondigitalocean.app/upload/single", // replace with your backend endpoint
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
            "Authorization":
                "Bearer ${"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4Yzk1ODBiMDY0ZDhkOGM1NTlkNjE5OSIsImlhdCI6MTc1ODE3NDY2NCwiZXhwIjoxNzU4Nzc5NDY0fQ.umrk7iGIlhEuw6mRC4embnm93VmeGBzzo11oK9jsXpE"}", // optional
          },
        ),
      );

      print("✅ Upload success: ${response.data}");
    } catch (e) {
      print("❌ Upload failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UploadBloc, UploadState>(
      listener: (context, state) {
        if (state is UploadSuccess) {
          widget.verse.logo = state.url;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Uploaded Sucessfully")));
          widget.controller.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Container(
        // height: widget.screenSize.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top bar
            TopBar(),

            const SizedBox(height: 20),

            // Greeting
            Text(
              "verse_creation_page.logo_question".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 16),
            _selectedImage != null
                ? Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: BoxBorder.all(color: Colors.grey),
                      // borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.all(12),

                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            _pickImage();
                          },
                          child: Text("verse_creation_page.choose_logo".tr()),
                        ),
                        Image.file(_selectedImage!, height: 120),
                      ],
                    ),
                  )
                : CustomOutlinedButton(
                    text: "verse_creation_page.choose_logo".tr(),
                    onPressed: () {
                      _pickImage();
                    },
                  ),

            const SizedBox(height: 6),

            // Description
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "verse_creation_page.logo_tip".tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 40),
            // Button
            CustomOutlinedButton(
              text: "verse_creation_page.preview_logo".tr(),
              onPressed: () {
                if (_selectedImage != null) {
                  context.read<UploadBloc>().add(
                    UploadImageEvent(
                      _selectedImage!,
                      "68cb9ec5fdfa9ba64f6f6146",
                      "logo",
                    ),
                  );
                  // uploadFile();
                  widget.controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
