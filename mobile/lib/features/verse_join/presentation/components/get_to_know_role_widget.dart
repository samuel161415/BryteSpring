import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routing/routeLists.dart';
import 'package:mobile/features/verse_join/presentation/components/top_part_widget.dart';
import 'package:mobile/features/verse_join/presentation/bloc/join_verse_bloc.dart';
import 'package:mobile/features/Authentication/domain/entities/invitation_entity.dart';

class GetToKnowRoleWidget extends StatefulWidget {
  final InvitationEntity invitation;

  const GetToKnowRoleWidget({super.key, required this.invitation});

  @override
  State<GetToKnowRoleWidget> createState() => _GetToKnowRoleWidgetState();
}

class _GetToKnowRoleWidgetState extends State<GetToKnowRoleWidget> {
  String _getGreeting() {
    final firstName = widget.invitation.firstName;
    if (firstName.isNotEmpty) {
      return 'join_verse.greeting_name'.tr(
        namedArgs: {'name': firstName},
      );
    }
    return 'join_verse.greeting_name'.tr(namedArgs: {'name': 'there'});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JoinVerseBloc, JoinVerseState>(
      listener: (context, state) {
        if (state is JoinVerseSuccess) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully joined ${state.verse.name}!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to dashboard
          context.goNamed(Routelists.dashboard);
        } else if (state is JoinVerseFailure) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to join verse: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<JoinVerseBloc, JoinVerseState>(
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              // height: 600,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TopHeader(),

                    SizedBox(height: 24),
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 36),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [Icon(Icons.close)],
                    ),
                    SizedBox(height: 24),
                    Text(
                      'join_verse.role.title'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'join_verse.role.intro'.tr(),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    _ChecklistItem(text: 'join_verse.role.bullet_1'.tr()),
                    _ChecklistItem(text: 'join_verse.role.bullet_2'.tr()),
                    _ChecklistItem(text: 'join_verse.role.bullet_3'.tr()),
                    _ChecklistItem(text: 'join_verse.role.bullet_4'.tr()),
                    const SizedBox(height: 12),
                    Text(
                      'join_verse.role.hint'.tr(),
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    InkWell(
                      onTap: state is JoinVerseLoading
                          ? null
                          : _handleJoinVerse,
                      child: Container(
                        width: 230,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 4),
                          color: state is JoinVerseLoading
                              ? Colors.grey[200]
                              : null,
                        ),
                        child: Center(
                          child: state is JoinVerseLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black,
                                    ),
                                  ),
                                )
                              : Text('join_verse.role.cta'.tr()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleJoinVerse() {
    // Call join verse API with the verse ID from invitation
    context.read<JoinVerseBloc>().add(JoinVerse(widget.invitation.verseId));
    context.goNamed(Routelists.joinVerseSuccess, extra: widget.invitation);
  }
}

class _ChecklistItem extends StatelessWidget {
  final String text;
  const _ChecklistItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(Icons.check, color: Color(0xFF3EC1B7), size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
