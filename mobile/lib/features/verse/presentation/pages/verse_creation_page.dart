import 'package:flutter/material.dart';
import 'package:mobile/core/widgets/app_footer.dart';
import 'package:mobile/features/verse/presentation/components/add_verse_color_name_widget.dart';
import 'package:mobile/features/verse/presentation/components/add_verse_color_widget.dart';
import 'package:mobile/features/verse/presentation/components/add_verse_logo_widget.dart';
import 'package:mobile/features/verse/presentation/components/asset_selection_widget.dart';
import 'package:mobile/features/verse/presentation/components/channel_selection_widget.dart';
import 'package:mobile/features/verse/presentation/components/stracture_verse_widget.dart';
import 'package:mobile/features/verse/presentation/components/verse_complete_widget.dart';
import 'package:mobile/features/verse/presentation/components/verse_loading_widget.dart';
import 'package:provider/provider.dart';

import '../../../../core/constant.dart';
import '../../../../core/injection_container.dart';
import '../../../verse_join/domain/entities/verse_join_entity.dart';
import '../../../verse_join/domain/usecases/verse_join_usecase.dart';
import '../components/add_organization_name_widget.dart';
import '../components/add_verse_domain_widget.dart';
import '../components/add_verse_name_widget.dart';
import '../components/verse_welcome_widget.dart';
import '../../domain/entities/verse.dart';
import '../../domain/usecases/create_verse.dart';

class VerseCreationPage extends StatefulWidget {
  const VerseCreationPage({
    super.key,
    required this.verseId,
    required this.currentUserName,
    required this.email,
  });
  final String verseId;
  final String currentUserName;
  final String email;

  @override
  State<VerseCreationPage> createState() => _VerseCreationPageState();
}

class _VerseCreationPageState extends State<VerseCreationPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  Verse verse = Verse.empty();
  VerseJoinEntity? _verseJoinEntity;
  @override
  void initState() {
    super.initState();
    verse.verseId = widget.verseId;
    verse.email = widget.email;
    _loadVerse();
  }

  bool _isSubmitting = false;

  Future<void> _loadVerse() async {
    try {
      final verseJoinUseCase = sl<VerseJoinUseCase>();
      final verseResult = await verseJoinUseCase.getVerse(widget.verseId);

      verseResult.fold((failure) {}, (verse) {
        print(
          'Verse fetched successfully: ${verse.name}, isSetupComplete: ${verse.isSetupComplete}',
        );
        _verseJoinEntity = verse;
        if (verse.isSetupComplete) {
          // Verse setup is complete, redirect to almost join page
        } else {}
      });
    } catch (e) {
      print('Error in _checkVerseSetupAndRedirect: $e');
      // Handle any unexpected errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking verse status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    void _handleLanguageChanged() {
      // Force rebuild when language changes
      setState(() {});
    }

    final pages = [
      VerseWelcomeWidget(
        name: widget.currentUserName,
        screenSize: screenSize,
        controller: _controller,
      ),
      AddVerseNameWidget(
        name: widget.currentUserName,

        screenSize: screenSize,
        controller: _controller,
        verse: verse,
        verseName: _verseJoinEntity!.name,
      ),
      AddVerseDomainWidget(
        name: widget.currentUserName,

        screenSize: screenSize,
        controller: _controller,
        verse: verse,
        verseSubDomain: _verseJoinEntity!.subdomain,
      ),
      AddOrganizationNameWidget(
        screenSize: screenSize,
        controller: _controller,
        verse: verse,
        organizationName: _verseJoinEntity!.organizationName,
      ),
      AddVerseLogoWidget(
        screenSize: screenSize,
        controller: _controller,
        verse: verse,
      ),
      AddVerseColorWidget(
        screenSize: screenSize,
        controller: _controller,
        verse: verse,
      ),
      AddVerseColorNameWidget(
        screenSize: screenSize,
        controller: _controller,
        verse: verse,
      ),
      StractureVerseWidget(
        screenSize: screenSize,
        controller: _controller,
        verse: verse,

        // onChanged: (value) => _verse = _verse.copyWith(initialChannels: value),
      ),
      ChannelSelectionWidget(
        screenSize: screenSize,
        controller: _controller,
        verse: verse,

        // onChanged: (value) => _verse = _verse.copyWith(channels: value),
      ),
      AssetSelectionWidget(
        name: widget.currentUserName,

        screenSize: screenSize,
        controller: _controller,
        verse: verse,

        // onChanged: (value) => _verse = _verse.copyWith(assets: value),
        // onSubmit: _submitForm,
        // isSubmitting: _isSubmitting,
      ),
      VerseLoadingWidget(
        isLoading: false,
        name: widget.currentUserName,

        screenSize: screenSize,
        controller: _controller,
        verse: verse,
      ),
      VerseCompleteWidget(
        name: widget.currentUserName,

        screenSize: screenSize,
        controller: _controller,
        verse: verse,
      ),
    ];
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              width: screenSize.width > 500 ? 500 : screenSize.width * 0.98,
              // margin: const EdgeInsets.symmetric(vertical: 20.0),
              // height: screenSize.height,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  // LoginHeader(onLanguageChanged: _handleLanguageChanged),
                  Text(verse.name ?? "noting"),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    height: screenSize.height * 0.8,

                    // padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: PageView(
                      controller: _controller,
                      physics:
                          const NeverScrollableScrollPhysics(), // 👈 disables swipe

                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      children: pages.map((page) {
                        return _isSubmitting
                            ? Center(child: CircularProgressIndicator())
                            : page;
                      }).toList(),
                    ),
                  ),
                  SizedBox(
                    // height: screenSize.height * 0.75,
                    child: AppFooter(onLanguageChanged: _handleLanguageChanged),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
