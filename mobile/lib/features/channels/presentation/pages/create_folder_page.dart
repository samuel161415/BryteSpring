import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/core/constant.dart';
import 'package:mobile/core/widgets/app_footer.dart';
import 'package:mobile/features/verse_join/presentation/components/top_part_widget.dart';
import 'package:mobile/features/channels/presentation/bloc/channel_bloc.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedChannelId = widget.parentChannelId;
    _selectedChannelName = widget.parentChannelId != null ? 'Corporate Design' : null;
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
    if (!_formKey.currentState!.validate()) return;
    if (_selectedChannelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('channels.select_channel_error'.tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    context.read<ChannelBloc>().add(
      CreateChannel(
        verseId: widget.verseId,
        name: _folderNameController.text.trim(),
        parentChannelId: _selectedChannelId,
        type: 'folder',
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        isPublic: _isPublic,
      ),
    );
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('channels.folder_created_success'.tr()),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is ChannelFailure) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('channels.folder_creation_error'.tr() + ': ${state.message}'),
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
            // Title
            Text(
              'channels.create_folder'.tr(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),

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
                          ? 'channels.channel_label'.tr() + ': $_selectedChannelName'
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
            TextFormField(
              controller: _folderNameController,
              decoration: InputDecoration(
                hintText: 'channels.folder_name_placeholder'.tr(),
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.teal[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.teal[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.teal[600]!, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: const TextStyle(fontSize: 16),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'channels.folder_name_required'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Description Input Field (Optional)
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'channels.folder_description_placeholder'.tr(),
                hintStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.teal[600]!, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Visibility Toggle
            Row(
              children: [
                Checkbox(
                  value: _isPublic,
                  onChanged: (value) {
                    setState(() {
                      _isPublic = value ?? true;
                    });
                  },
                  activeColor: Colors.teal[600],
                ),
                Text(
                  'channels.make_public'.tr(),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Instructional Tip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                'channels.create_folder_tip'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Create Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleCreateFolder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLoading 
                      ? Colors.grey[400] 
                      : Colors.teal[600],
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
                        'channels.create_folder_button'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
