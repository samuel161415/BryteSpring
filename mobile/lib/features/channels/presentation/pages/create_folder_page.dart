import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constant.dart';
import 'package:mobile/core/widgets/app_footer.dart';
import 'package:mobile/features/verse_join/presentation/components/top_part_widget.dart';
import 'package:mobile/features/channels/presentation/bloc/channel_bloc.dart';
import 'package:mobile/core/routing/routeLists.dart';

class CreateFolderPage extends StatefulWidget {
  final String? parentChannelId;
  final String verseId;

  const CreateFolderPage({
    super.key,
    this.parentChannelId,
    required this.verseId,
  });

  @override
  State<CreateFolderPage> createState() => _CreateFolderPageState();
}

class _CreateFolderPageState extends State<CreateFolderPage> {
  final _formKey = GlobalKey<FormState>();
  final _folderNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedChannelId;
  String? _selectedChannelName;
  bool _isPublic = true;
  bool _isLoading = false;
  int _currentStep = 0;

  // Content type selections
  bool _isImages = false;
  bool _isTexts = false;
  bool _isData = false;
  bool _isDocuments = false;

  @override
  void initState() {
    super.initState();
    _selectedChannelId = widget.parentChannelId;
    _selectedChannelName = widget.parentChannelId != null
        ? 'Corporate Design'
        : null;
    _folderNameController.text = 'Mitarbeiterfotos'; // Pre-fill with example
    _descriptionController.text =
        'Inhalte sind vorwiegend Bilder'; // Pre-fill with example
  }

  @override
  void dispose() {
    _folderNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleLanguageChanged() {
    setState(() {});
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _showChannelSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('channels.select_channel'.tr()),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildChannelOption('Corporate Design', 'corp-design'),
              _buildChannelOption('Unternehmensdaten', 'company-data'),
              _buildChannelOption('Marketing Materialien', 'marketing'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.cancel'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelOption(String name, String id) {
    return ListTile(
      title: Text(name),
      leading: Radio<String>(
        value: id,
        groupValue: _selectedChannelId,
        onChanged: (value) {
          setState(() {
            _selectedChannelId = value;
            _selectedChannelName = name;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _handleCreateFolder() async {
    context.pushNamed(Routelists.createFolderConfirmation);
    // if (!_formKey.currentState!.validate()) return;
    // if (_selectedChannelId == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('channels.select_channel_error'.tr()),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

    // setState(() {
    //   _isLoading = true;
    // });

    // context.read<ChannelBloc>().add(
    //   CreateChannel(
    //     verseId: widget.verseId,
    //     name: _folderNameController.text.trim(),
    //     parentChannelId: _selectedChannelId,
    //     type: 'folder',
    //     description: _descriptionController.text.trim().isEmpty
    //         ? null
    //         : _descriptionController.text.trim(),
    //     isPublic: _isPublic,
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: BlocListener<ChannelBloc, ChannelState>(
        listener: (context, state) {
          if (state is ChannelCreated) {
            setState(() {
              _isLoading = false;
            });
            // Navigate to confirmation page instead of showing snackbar
            context.goNamed(
              Routelists.createFolderConfirmation,
              extra: {
                'folderName': _folderNameController.text.trim(),
                'channelName': _selectedChannelName ?? 'Channel',
              },
            );
          } else if (state is ChannelFailure) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'channels.folder_creation_error'.tr() + ': ${state.message}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenSize.height),
            child: Center(
              child: Container(
                width: screenSize.width > 1200 ? 1200 : screenSize.width * 0.95,
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
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
                  children: [
                    // Main Content
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            // Top Header
                            const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: TopHeader(),
                            ),

                            // Create Folder Content
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Main form content
                                    Expanded(
                                      child: Container(
                                        color: Colors.white,
                                        child: _buildCreateFolderForm(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),

                    // Footer
                    AppFooter(onLanguageChanged: _handleLanguageChanged),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateFolderForm() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with close button
            Row(
              children: [
                Expanded(
                  child: Text(
                    'channels.create_folder'.tr(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 24,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Step-by-step content
            _buildStepContent(),

            const SizedBox(height: 32),

            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return _buildStep1();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Channel Selection Field
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedChannelName != null
                      ? 'channels.channel_label'.tr() +
                            ': $_selectedChannelName'
                      : 'channels.select_channel'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedChannelName != null
                        ? Colors.black87
                        : Colors.grey[600],
                  ),
                ),
              ),
              GestureDetector(
                onTap: _showChannelSelectionDialog,
                child: Text(
                  'channels.change_channel'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.teal[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Folder Name Input Field
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.teal[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _folderNameController.text,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              GestureDetector(
                onTap: _showNameEditDialog,
                child: Text(
                  'channels.change_name'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.teal[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Content Description Field
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _descriptionController.text,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              GestureDetector(
                onTap: _showDescriptionEditDialog,
                child: Text(
                  'channels.change_contents'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.teal[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Information text
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'channels.folder_inheritance_info'.tr(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Checkboxes
        Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: true, // Default checked
                  onChanged: (value) {},
                  activeColor: Colors.teal[600],
                ),
                Text(
                  'channels.yes_correct'.tr(),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: (value) {
                    setState(() {
                      _currentStep = 0; // Go back to channel selection
                    });
                  },
                  activeColor: Colors.teal[600],
                ),
                Text(
                  'channels.select_other_folder'.tr(),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Channel Selection Field
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedChannelName != null
                      ? 'channels.channel_label'.tr() +
                            ': $_selectedChannelName'
                      : 'channels.select_channel'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedChannelName != null
                        ? Colors.black87
                        : Colors.grey[600],
                  ),
                ),
              ),
              GestureDetector(
                onTap: _showChannelSelectionDialog,
                child: Text(
                  'channels.change_channel'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.teal[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Folder Name Input Field
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.teal[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _folderNameController.text,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              GestureDetector(
                onTap: _showNameEditDialog,
                child: Text(
                  'channels.change_name'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.teal[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Content type question
        Text(
          'channels.content_type_question'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Content type checkboxes
        Row(
          children: [
            Expanded(
              child: _buildContentTypeCheckbox(
                'channels.images'.tr(),
                _isImages,
                (value) {
                  setState(() {
                    _isImages = value ?? false;
                  });
                },
              ),
            ),
            Expanded(
              child: _buildContentTypeCheckbox(
                'channels.texts'.tr(),
                _isTexts,
                (value) {
                  setState(() {
                    _isTexts = value ?? false;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildContentTypeCheckbox('channels.data'.tr(), _isData, (
                value,
              ) {
                setState(() {
                  _isData = value ?? false;
                });
              }),
            ),
            Expanded(
              child: _buildContentTypeCheckbox(
                'channels.documents'.tr(),
                _isDocuments,
                (value) {
                  setState(() {
                    _isDocuments = value ?? false;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Channel Selection Field
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedChannelName != null
                      ? 'channels.channel_label'.tr() +
                            ': $_selectedChannelName'
                      : 'channels.select_channel'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedChannelName != null
                        ? Colors.black87
                        : Colors.grey[600],
                  ),
                ),
              ),
              GestureDetector(
                onTap: _showChannelSelectionDialog,
                child: Text(
                  'channels.change_channel'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.teal[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Folder Name Input Field
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.teal[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _folderNameController.text,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              GestureDetector(
                onTap: _showNameEditDialog,
                child: Text(
                  'channels.change_name'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.teal[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Tips section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'channels.tip_title'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'channels.tip_channel_selection'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'channels.tip_unique_name'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentTypeCheckbox(
    String label,
    bool value,
    Function(bool?) onChanged,
  ) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.teal[600],
        ),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: ElevatedButton(
              onPressed: _previousStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'common.back'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _getNextButtonAction(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isLoading ? Colors.grey[400] : Colors.teal[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _getNextButtonText(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  String _getNextButtonText() {
    if (_currentStep == 2) {
      return 'channels.create_folder_button'.tr();
    }
    return 'common.next'.tr();
  }

  VoidCallback? _getNextButtonAction() {
    if (_currentStep == 2) {
      return _handleCreateFolder;
    }
    return _nextStep;
  }

  void _showNameEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('channels.edit_folder_name'.tr()),
        content: TextFormField(
          controller: _folderNameController,
          decoration: InputDecoration(
            hintText: 'channels.folder_name_placeholder'.tr(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {});
            },
            child: Text('common.save'.tr()),
          ),
        ],
      ),
    );
  }

  void _showDescriptionEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('channels.edit_description'.tr()),
        content: TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'channels.folder_description_placeholder'.tr(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {});
            },
            child: Text('common.save'.tr()),
          ),
        ],
      ),
    );
  }
}
