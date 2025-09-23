import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/features/verse/presentation/components/back_and_cancel_widget.dart';
import 'package:mobile/features/verse/presentation/components/custom_outlined_button.dart';
import 'top_bar.dart';
import '../../domain/entities/verse.dart';

class ChannelSelectionWidget extends StatefulWidget {
  const ChannelSelectionWidget({
    super.key,
    required this.screenSize,
    required this.controller,
    required this.verse,
  });
  final PageController controller;
  final Verse verse;

  final Size screenSize;

  @override
  State<ChannelSelectionWidget> createState() => _ChannelSelectionWidgetState();
}

class _ChannelSelectionWidgetState extends State<ChannelSelectionWidget> {
  final List<String> channels = [
    "verse_creation_page.channel_corporate_website",
    "verse_creation_page.channel_microsite",
    "verse_creation_page.channel_online_shop",
    "verse_creation_page.channel_social_media",
    "verse_creation_page.channel_newsletter",
    "verse_creation_page.channel_seo",
    "verse_creation_page.channel_business_material",
    "verse_creation_page.channel_marketing_print",
    "verse_creation_page.channel_publishing",
    "verse_creation_page.channel_hr_files",
    "verse_creation_page.channel_intranet",
    "verse_creation_page.channel_internal_systems",
  ];

  final List<bool> _selectedChannels = List.filled(12, false);
  List<String> _selectedChannelsList = [];
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
              widget.controller.jumpToPage(0);
            },
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: widget.screenSize.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top bar
          TopBar(),
          BackAndCancelWidget(controller: widget.controller),

          const SizedBox(height: 20),

          // Greeting
          Text(
            "verse_creation_page.channels_question".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 10),

          // Channels list
          Expanded(
            child: GridView.builder(
              itemCount: channels.length,
              shrinkWrap: true, // ✅ important for grids inside scrollables
              physics:
                  const NeverScrollableScrollPhysics(), // ✅ avoid scroll conflict
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // number of columns
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 5, // adjust height/width of each tile
              ),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Checkbox(
                      value: _selectedChannels[index],
                      onChanged: (value) {
                        if (value == true) {
                          _selectedChannelsList.add(channels[index]);
                        } else if (value == false) {
                          _selectedChannelsList.remove(channels[index]);
                        }
                        setState(() {
                          _selectedChannels[index] = value!;
                        });
                      },
                    ),
                    Expanded(child: Text(channels[index].tr())),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          // Description
          Text(
            "verse_creation_page.channels_tip".tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 10),
          // Confirm button
          CustomOutlinedButton(
            isEnabled: _selectedChannelsList.isNotEmpty,

            text: "verse_creation_page.confirm_channels".tr(),
            onPressed: () {
              _selectedChannelsList.clear();

              for (var i = 0; i < _selectedChannels.length; i++) {
                if (_selectedChannels[i] == true) {
                  _selectedChannelsList.add(channels[i]);
                }
              }
              if (_selectedChannelsList.isNotEmpty) {
                widget.verse.channels = _selectedChannelsList;
                widget.controller.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
