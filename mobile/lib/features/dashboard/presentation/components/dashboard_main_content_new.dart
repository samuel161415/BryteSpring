import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/core/constant.dart';
import 'package:mobile/core/widgets/dashboard_shimmer.dart';
import 'package:mobile/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:mobile/features/dashboard/presentation/bloc/dashboard_bloc.dart';

class DashboardMainContent extends StatefulWidget {
  final String? verseId;
  
  const DashboardMainContent({super.key, this.verseId});

  @override
  State<DashboardMainContent> createState() => _DashboardMainContentState();
}

class _DashboardMainContentState extends State<DashboardMainContent> {
  final TextEditingController _searchController = TextEditingController();
  bool _isNotificationExpanded = true; // Default to expanded

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const DashboardShimmer();
        } else if (state is DashboardFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  state.isOffline ? Icons.cloud_off : Icons.error_outline, 
                  size: 64, 
                  color: state.isOffline ? Colors.orange[300] : Colors.red[300]
                ),
                const SizedBox(height: 16),
                Text(
                  state.isOffline 
                      ? 'dashboard.error.offline'.tr()
                      : 'dashboard.error.loading_dashboard'.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: widget.verseId != null ? () {
                    // Reload dashboard data
                    context.read<DashboardBloc>().add(
                      LoadDashboardData(widget.verseId!),
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.isOffline ? Colors.orange[600] : Colors.teal[600],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    state.isOffline 
                        ? 'dashboard.error.retry_offline'.tr()
                        : 'dashboard.error.retry'.tr()
                  ),
                ),
              ],
            ),
          );
        } else if (state is DashboardLoaded) {
          return _buildDashboardContent(state.dashboardData, state.isFromCache);
        } else {
          return Center(child: Text('dashboard.error.loading'.tr()));
        }
      },
    );
  }

  Widget _buildDashboardContent(
    DashboardEntity dashboardData,
    bool isFromCache,
  ) {
    final user = dashboardData.data.user;
    final verse = dashboardData.data.verse;
    final commonData = dashboardData.data.commonData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Offline indicator
          if (isFromCache) _buildOfflineIndicator(),

          // Welcome Section
          _buildWelcomeSection(user, verse),

          const SizedBox(height: 24),

          // Notification Section
          _buildNotificationSection(),

          const SizedBox(height: 32),

          // Search Section
          _buildSearchSection(),

          const SizedBox(height: 32),

          // Recent Searches
          if (commonData.recentSearches.isNotEmpty) ...[
            _buildRecentSearchesSection(commonData.recentSearches),
            const SizedBox(height: 32),
          ],

          // Upload Section
          _buildUploadSection(),
        ],
      ),
    );
  }

  Widget _buildOfflineIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 20, color: Colors.orange[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline-Modus: Daten aus dem Cache',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Trigger refresh
              context.read<DashboardBloc>().add(
                RefreshDashboardData('68c3e2d6f58c817ebed1ca74'),
              );
            },
            child: Text(
              'Aktualisieren',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Hinweis:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isNotificationExpanded = !_isNotificationExpanded;
                  });
                },
                child: Icon(
                  _isNotificationExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          if (_isNotificationExpanded) ...[
            const SizedBox(height: 8),
            Text(
              'Stephan Tomat hat Deine Einladung angenommen und ist dem Verse als Experte beigetreten.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(DashboardUser user, DashboardVerse verse) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hallo, ${user.firstName}!',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'dashboard.greeting.welcome_back'.tr(),
          style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.business, color: AppTheme.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      verse.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (verse.organizationName != null)
                      Text(
                        verse.organizationName!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'dashboard.search.title'.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'dashboard.search.placeholder'.tr(),
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSearchesSection(List<String> recentSearches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'dashboard.frequent.title'.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recentSearches.map((search) {
            return InkWell(
              onTap: () {
                _searchController.text = search;
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  search,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'dashboard.upload.title'.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () {
            // TODO: Implement file upload
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('dashboard.upload.coming_soon'.tr())),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 2,
                style: BorderStyle.solid,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Image icon
                // Container(
                //   width: 48,
                //   height: 48,
                //   decoration: BoxDecoration(
                //     color: Colors.grey[100],
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   //   child: Icon(
                //   //     Icons.image_outlined,
                //   //     size: 32,
                //   //     color: Colors.grey[400],
                //   //   ),
                // ),
                // const SizedBox(height: 12),
                Text(
                  'dashboard.upload.choose_file'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
