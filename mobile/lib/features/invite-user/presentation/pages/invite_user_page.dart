import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/routing/routeLists.dart';
import 'package:mobile/features/invite-user/domain/model/invitation_model.dart';
import 'package:mobile/features/invite-user/presentation/bloc/invite_user_bloc.dart';
import 'package:mobile/features/invite-user/presentation/bloc/invite_user_event.dart';
import 'package:mobile/features/verse/presentation/components/top_bar.dart';

import '../../../../core/constant.dart';
import '../../../../core/widgets/app_footer.dart';
import '../../../verse/presentation/components/custom_outlined_button.dart';

class InviteUserPage extends StatefulWidget {
  const InviteUserPage({super.key});

  @override
  State<InviteUserPage> createState() => _InviteUserPageState();
}

class _InviteUserPageState extends State<InviteUserPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController postionController = TextEditingController();

  bool isAdmin = false;
  bool isUser = false;
  bool isExpert = false;
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

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isUser,
                                    onChanged: (value) {
                                      // if (value == true) {
                                      //   _selectedAssetsList.add(assets[index]);
                                      // } else if (value == false) {
                                      //   _selectedAssetsList.remove(assets[index]);
                                      // }
                                      setState(() {
                                        isUser = !isUser;
                                      });
                                    },
                                  ),
                                  Text("Redakteur"),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isExpert,
                                    onChanged: (value) {
                                      // if (value == true) {
                                      //   _selectedAssetsList.add(assets[index]);
                                      // } else if (value == false) {
                                      //   _selectedAssetsList.remove(assets[index]);
                                      // }
                                      setState(() {
                                        isExpert = !isExpert;
                                      });
                                    },
                                  ),
                                  Text("Experte"),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isAdmin,
                                    onChanged: (value) {
                                      // if (value == true) {
                                      //   _selectedAssetsList.add(assets[index]);
                                      // } else if (value == false) {
                                      //   _selectedAssetsList.remove(assets[index]);
                                      // }
                                      setState(() {
                                        isAdmin = !isAdmin;
                                      });
                                    },
                                  ),
                                  Text("Administrator"),
                                ],
                              ),
                            ),
                          ],
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
                          text: "Einladung senden",
                          onPressed: () {
                            final user = InvitationUser(
                              email: _emailController.text,
                              position: postionController.text,
                              role: "Redakteur",
                            );
                            context.read<UserInvitationBloc>().add(
                              CreateInvitedUserEvent(user),
                            );

                            context.goNamed(Routelists.dashboard);
                          },
                        ),
                      ],
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
