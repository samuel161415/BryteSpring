import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/verse/presentation/components/custom_outlined_button.dart';
import 'package:mobile/features/verse/presentation/components/verse_loading_widget.dart';
import '../bloc/verse_bloc.dart';
import '../bloc/verse_state.dart';
import 'top_bar.dart';
import '../../domain/entities/verse.dart';
import '../bloc/verse_event.dart';

class AssetSelectionWidget extends StatefulWidget {
  const AssetSelectionWidget({
    super.key,
    required this.screenSize,
    required this.controller,
    required this.verse,
    required this.name,
  });
  final PageController controller;
  final Verse verse;
  final String name;

  final Size screenSize;

  @override
  State<AssetSelectionWidget> createState() => _AssetSelectionWidgetState();
}

class _AssetSelectionWidgetState extends State<AssetSelectionWidget> {
  final List<String> assets = [
    "verse_creation_page.asset_employee_photos",
    "verse_creation_page.asset_employee_data",
    "verse_creation_page.asset_marketing_texts",
    "verse_creation_page.asset_marketing_images",
    "verse_creation_page.asset_product_texts",
    "verse_creation_page.asset_product_images",
    "verse_creation_page.asset_company_data",
    "verse_creation_page.asset_documentation",
    "verse_creation_page.asset_quotes_poetry",
    "verse_creation_page.asset_customer_data",
    "verse_creation_page.asset_templates",
    "verse_creation_page.asset_layouts",
  ];

  final List<bool> _selectedAssets = List.filled(12, false);
  List<String> _selectedAssetsList = [];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<VerseBloc, VerseState>(
      listener: (context, state) {
        if (state is VerseCreationLoading) {
          setState(() => isLoading = true);
        } else if (state is VerseCreationSuccess) {
          setState(() {
            isLoading = false;
          });
        } else if (state is VerseCreationFailure) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: ${state.message}")));
        }
      },
      child: isLoading
          ? VerseLoadingWidget(
              name: widget.name,

              screenSize: widget.screenSize,
              controller: widget.controller,
              verse: widget.verse,
            )
          : Container(
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
                    "verse_creation_page.assets_question".tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Assets list
                  Expanded(
                    child: GridView.builder(
                      itemCount: assets.length,
                      shrinkWrap:
                          true, // ✅ important for grids inside scrollables
                      physics:
                          const NeverScrollableScrollPhysics(), // ✅ avoid scroll conflict
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // number of columns
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                            childAspectRatio:
                                5, // adjust height/width of each tile
                          ),
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Checkbox(
                              value: _selectedAssets[index],
                              onChanged: (value) {
                                // if (value == true) {
                                //   _selectedAssetsList.add(assets[index]);
                                // } else if (value == false) {
                                //   _selectedAssetsList.remove(assets[index]);
                                // }
                                setState(() {
                                  _selectedAssets[index] = value!;
                                });
                              },
                            ),
                            Expanded(child: Text(assets[index].tr())),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Description
                  Text(
                    "verse_creation_page.assets_tip".tr(),
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
                    text: "verse_creation_page.confirm_assets".tr(),
                    onPressed: () {
                      _selectedAssetsList.clear();

                      for (var i = 0; i < _selectedAssets.length; i++) {
                        if (_selectedAssets[i] == true) {
                          _selectedAssetsList.add(assets[i]);
                        }
                      }
                      if (_selectedAssets.isNotEmpty) {
                        widget.verse.assets = _selectedAssetsList;

                        // Dispatch event to send verse to backend
                        BlocProvider.of<VerseBloc>(
                          context,
                        ).add(CreateVerseRequested(widget.verse));

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
