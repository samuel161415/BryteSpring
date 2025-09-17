import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/constant.dart';
import 'package:mobile/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:mobile/features/dashboard/presentation/bloc/dashboard_bloc.dart';

class DashboardMainContent extends StatefulWidget {
  const DashboardMainContent({super.key});

  @override
  State<DashboardMainContent> createState() => _DashboardMainContentState();
}

class _DashboardMainContentState extends State<DashboardMainContent> {
  final TextEditingController _searchController = TextEditingController();

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
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is DashboardFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Fehler beim Laden der Dashboard-Daten',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Reload dashboard data
                    context.read<DashboardBloc>().add(
                      LoadDashboardData('68c3e2d6f58c817ebed1ca74'),
                    );
                  },
                  child: const Text('Erneut versuchen'),
                ),
              ],
            ),
          );
        } else if (state is DashboardLoaded) {
          return _buildDashboardContent(state.dashboardData);
        } else {
          return const Center(
            child: Text('Dashboard wird geladen...'),
          );
        }
      },
    );
  }

  Widget _buildDashboardContent(DashboardEntity dashboardData) {
    final user = dashboardData.data.user;
    final verse = dashboardData.data.verse;
    final commonData = dashboardData.data.commonData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          _buildWelcomeSection(user, verse),
          
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
          
          const SizedBox(height: 32),
          
          // Admin Data (if available)
          if (dashboardData.data.adminData != null) ...[
            _buildAdminSection(dashboardData.data.adminData!),
            const SizedBox(height: 32),
          ],
          
          // Recent Activity
          if (commonData.recentActivity.isNotEmpty) ...[
            _buildRecentActivitySection(commonData.recentActivity),
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
          'Schön, dass Du zurück bist. Lass uns gemeinsam die Welt ein bisschen strukturierter machen.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
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
              Icon(
                Icons.business,
                color: AppTheme.primary,
                size: 24,
              ),
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
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
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
        const Text(
          'Wonach suchst Du?',
          style: TextStyle(
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
              hintText: 'Suchbegriff eingeben',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey[500],
              ),
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
        const Text(
          'Das hast Du häufig gesucht:',
          style: TextStyle(
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
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
        const Text(
          'Möchtest Du etwas hochladen?',
          style: TextStyle(
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
              const SnackBar(
                content: Text('Datei-Upload wird bald verfügbar sein'),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
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
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  '+ Bild aus Datei wählen',
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

  Widget _buildAdminSection(AdminData adminData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Admin-Bereich',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Mitglieder',
                adminData.statistics.totalMembers.toString(),
                Icons.people,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Kanäle',
                adminData.statistics.totalChannels.toString(),
                Icons.folder,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Ausstehende Einladungen',
                adminData.statistics.pendingInvitations.toString(),
                Icons.pending_actions,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(List<AdminActivity> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Letzte Aktivitäten',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...activities.take(5).map((activity) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getActivityColor(activity.action).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _getActivityIcon(activity.action),
                    color: _getActivityColor(activity.action),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getActivityDescription(activity),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(activity.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Color _getActivityColor(String action) {
    switch (action.toLowerCase()) {
      case 'create':
        return Colors.green;
      case 'update':
        return Colors.blue;
      case 'delete':
        return Colors.red;
      case 'setup_complete':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String action) {
    switch (action.toLowerCase()) {
      case 'create':
        return Icons.add_circle;
      case 'update':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      case 'setup_complete':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  String _getActivityDescription(AdminActivity activity) {
    switch (activity.resourceType) {
      case 'user':
        return 'Neuer Benutzer: ${activity.user.firstName} ${activity.user.lastName}';
      case 'channel':
        return 'Neuer Kanal erstellt';
      case 'folder':
        return 'Neuer Ordner erstellt';
      case 'verse':
        return 'Verse Setup abgeschlossen';
      case 'verse_branding':
        return 'Verse Branding aktualisiert';
      case 'role':
        return 'Neue Rolle erstellt';
      default:
        return 'Aktivität: ${activity.action}';
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return 'vor ${difference.inDays} Tag${difference.inDays > 1 ? 'en' : ''}';
      } else if (difference.inHours > 0) {
        return 'vor ${difference.inHours} Stunde${difference.inHours > 1 ? 'n' : ''}';
      } else if (difference.inMinutes > 0) {
        return 'vor ${difference.inMinutes} Minute${difference.inMinutes > 1 ? 'n' : ''}';
      } else {
        return 'gerade eben';
      }
    } catch (e) {
      return timestamp;
    }
  }
}
