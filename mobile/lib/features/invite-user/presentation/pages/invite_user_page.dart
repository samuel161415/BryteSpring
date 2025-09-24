import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/injection_container.dart';
import 'package:mobile/core/routing/routeLists.dart';
import 'package:mobile/features/Authentication/domain/repositories/login_repository.dart';
import 'package:mobile/features/invite-user/domain/model/invitation_model.dart';
import 'package:mobile/features/invite-user/presentation/bloc/invite_user_bloc.dart';
import 'package:mobile/features/invite-user/presentation/bloc/invite_user_event.dart';
import 'package:mobile/features/invite-user/presentation/bloc/invite_user_role_bloc.dart';
import 'package:mobile/features/invite-user/presentation/bloc/invite_user_state.dart';
import 'package:mobile/features/invite-user/presentation/bloc/invite_verse_role_event.dart';
import 'package:mobile/features/invite-user/presentation/bloc/invite_verse_role_state.dart';
import 'package:mobile/features/verse/presentation/components/top_bar.dart';

import '../../../../core/constant.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../verse/presentation/components/custom_outlined_button.dart';

class InviteUserPage extends StatefulWidget {
  const InviteUserPage({super.key, this.verseId});
  final String? verseId;

  @override
  State<InviteUserPage> createState() => _InviteUserPageState();
}

class _InviteUserPageState extends State<InviteUserPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController postionController = TextEditingController();
  String selectedRoleId = "";
  bool isAdmin = false;
  bool isUser = false;
  bool isExpert = false;
  String firstName = "";
  String lastName = "";
  String position = "";
  String? selectedRole;
  String? currentUserName;
  @override
  void initState() {
    super.initState();
    context.read<InvitedVerseUserRoleBloc>().add(
      GetInviteVerseRoleEvent(widget.verseId ?? ""),
    );
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final loginRepository = sl<LoginRepository>();

      // Load current user
      final userResult = await loginRepository.getCurrentUser();

      userResult.fold(
        (failure) {
          // Handle error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load user: ${failure.message}'),
              ),
            );
          }
        },
        (user) {
          if (user != null) {
            setState(() {
              currentUserName = user.firstName;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void parseUserInput(String input) {
    // Normalize the input by replacing commas with spaces, then clean up multiple spaces
    final normalizedInput = input
        .replaceAll(',', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // Split by spaces
    final parts = normalizedInput.split(' ');

    if (parts.length < 2) {
      print("Invalid input format. Use: FirstName LastName, Position");
      return;
    }

    // Position is the last part
    position = parts.last;

    // Everything before the last part is the name
    final nameParts = parts.sublist(0, parts.length - 1);

    if (nameParts.isNotEmpty) {
      firstName = nameParts.first;
      lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    void _handleLanguageChanged() {
      // Force rebuild when language changes
      setState(() {});
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: SingleChildScrollView(
            child: BlocListener<UserInvitationBloc, InvitedUserState>(
              listener: (context, state) {
                if (state is InvitedUserSuccess) {
                  context.pushNamed(
                    Routelists.completeUserInvite,
                    extra: {
                      "invitedUserName": firstName,
                      "inviterUame": currentUserName ?? "User",
                    },
                  );
                } else if (state is InvitedUserFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${state.error}')),
                  );
                }
              },
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
                    Container(
                      // height: widget.screenSize.height * 0.6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Top bar
                          TopBar(),

                          const SizedBox(height: 30),

                          // Greeting
                          Text(
                            "Nutzer hinzufügen",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Title textfield
                          TextField(
                            onChanged: (value) {
                              setState(() {});
                            },
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText:
                                  "Mail        @brightnetworks.de  Domän ändern",
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2.0,
                                ), // Red border
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2.0,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2.0,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Title textfield
                          TextField(
                            onChanged: (value) {
                              parseUserInput(postionController.text);

                              setState(() {});
                            },
                            controller: postionController,
                            decoration: InputDecoration(
                              hintText: "Vor- und Nachname, Position",
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2.0,
                                ), // Red border
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2.0,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2.0,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Description
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              "Bitte wähle die Rolle aus:",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          BlocBuilder<
                            InvitedVerseUserRoleBloc,
                            InviteVerseRoleState
                          >(
                            builder: (context, state) {
                              if (state is InviteVerseRoleLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (state is InviteVerseRoleFailure) {
                                return Center(
                                  child: Text("Error: ${state.error}"),
                                );
                              } else if (state is InviteVerseRoleSuccess) {
                                final roles = state.invitedVerseRole;
                                // roles could be like: [{ "id": "user", "label": "Redakteur", "selected": false }, ...]

                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: roles.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3, // 3 columns
                                        mainAxisExtent:
                                            50, // height of each item
                                      ),
                                  itemBuilder: (context, index) {
                                    final role = roles[index];
                                    return Row(
                                      children: [
                                        Checkbox(
                                          value: role.role == selectedRole,
                                          onChanged: (value) {
                                            if (role.isSelected != false) {
                                              selectedRoleId = role.roleId;
                                            }
                                            setState(() {
                                              selectedRole = role.role;
                                            });
                                            // context
                                            //     .read<
                                            //       InvitedVerseUserRoleBloc
                                            //     >()
                                            //     .add(
                                            //       ToggleRoleEvent(
                                            //         role.roleId,
                                            //         value ?? false,
                                            //       ),
                                            //     );
                                          },
                                        ),
                                        Expanded(child: Text(role.role)),
                                      ],
                                    );
                                  },
                                );
                              }

                              return const SizedBox.shrink(); // fallback
                            },
                          ),

                          const SizedBox(height: 20),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              "Was muss Deine Organisation über Stephan wissen?Wenn Stephan ein Mitarbeiter Deiner Organisation ist, kannst Du sein Mitarbeiterprofil verknüpfen. ",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          const SizedBox(height: 40),
                          // Button
                          CustomOutlinedButton(
                            isEnabled:
                                widget.verseId != null &&
                                selectedRoleId.isNotEmpty &&
                                position.isNotEmpty &&
                                firstName.isNotEmpty &&
                                lastName.isNotEmpty,

                            text: "Einladung senden",
                            onPressed: () {
                              parseUserInput(postionController.text);
                              setState(() {});
                              if (widget.verseId != null &&
                                  selectedRoleId.isNotEmpty &&
                                  position.isNotEmpty &&
                                  firstName.isNotEmpty &&
                                  lastName.isNotEmpty) {
                                final user = InvitationUser(
                                  email: _emailController.text,
                                  position: position,
                                  roleId: selectedRoleId,
                                  verseId: widget.verseId!,
                                  firstName: firstName,
                                  lastName: lastName,
                                  subdomain: "brightnetworks",
                                );
                                context.read<UserInvitationBloc>().add(
                                  CreateInvitedUserEvent(user),
                                );
                              }

                              // context.goNamed(Routelists.dashboard);
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      // height: screenSize.height * 0.75,
                      child: AppFooter(
                        onLanguageChanged: _handleLanguageChanged,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
