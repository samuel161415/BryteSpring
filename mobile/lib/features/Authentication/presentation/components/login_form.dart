import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constant.dart';
import 'package:mobile/core/routing/routeLists.dart';
import 'package:mobile/core/services/auth_service.dart';
import 'package:mobile/core/services/saved_accounts_service.dart';
import 'package:mobile/core/injection_container.dart';
import 'package:mobile/features/Authentication/domain/entities/invitation_entity.dart';
import 'package:mobile/features/verse_join/domain/usecases/verse_join_usecase.dart';

class LoginForm extends StatefulWidget {
  final InvitationEntity? invitation;
  const LoginForm({super.key, this.invitation});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = true;
  List<SavedAccount> _savedAccounts = [];
  SavedAccount? _currentAccount;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print('LoginForm initState - invitation: ${widget.invitation}');
    _loadSavedAccounts();
  }

  Future<void> _loadSavedAccounts() async {
    try {
      final savedAccountsService = sl<SavedAccountsService>();
      final accounts = await savedAccountsService.getSavedAccounts();
      
      setState(() {
        _savedAccounts = accounts;
      });

      // If invitation is provided, use invitation email
      if (widget.invitation != null) {
        _emailController.text = widget.invitation!.email;
        print('LoginForm initState - using invitation email: ${widget.invitation!.email}');
      } else if (accounts.isNotEmpty) {
        // Use last used account or first account
        final lastUsedAccount = await savedAccountsService.getLastUsedAccount();
        final accountToUse = lastUsedAccount ?? accounts.first;
        
        _emailController.text = accountToUse.email;
        _passwordController.text = accountToUse.password;
        _currentAccount = accountToUse;
        print('LoginForm initState - using saved account: ${accountToUse.email}');
      }
    } catch (e) {
      print('Error loading saved accounts: $e');
      // Fallback to invitation email if available
      if (widget.invitation != null) {
        _emailController.text = widget.invitation!.email;
      }
    }
  }

  @override
  void didUpdateWidget(LoginForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(
      'LoginForm didUpdateWidget - old invitation: ${oldWidget.invitation}',
    );
    print('LoginForm didUpdateWidget - new invitation: ${widget.invitation}');

    // Update email if invitation changed
    if (oldWidget.invitation != widget.invitation) {
      _emailController.text = widget.invitation?.email ?? '';
      print(
        'LoginForm didUpdateWidget - email updated to: ${_emailController.text}',
      );
      setState(() {});
    }
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = sl<AuthService>();
      final result = await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: ${failure.message}')),
          );
        },
        (user) async {
          print('Login successful for user: ${user.email}');
          print('Invitation present: ${widget.invitation != null}');
          
          // Save account if remember me is checked
          if (_rememberMe) {
            try {
              final savedAccountsService = sl<SavedAccountsService>();
              await savedAccountsService.saveAccount(
                email: _emailController.text.trim(),
                password: _passwordController.text,
                firstName: user.firstName,
                lastName: user.lastName,
              );
              print('Account saved for: ${_emailController.text.trim()}');
            } catch (e) {
              print('Error saving account: $e');
            }
          }
          
          // Login successful
          print('widget.invitation: ${widget.invitation}');
          if (widget.invitation != null) {
            print('Checking verse setup status...');
            // Check verse setup status if invitation is provided
            await _checkVerseSetupAndRedirect();
          } else {
            print('No invitation, redirecting to dashboard');
            // Normal login flow - redirect to dashboard
            context.go('/${Routelists.dashboard}');
          }
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAccountSelectionDialog() {
    if (_savedAccounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No saved accounts found'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('login_screen.switch_account'.tr()),
        content: SizedBox(
          width: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _savedAccounts.length,
            itemBuilder: (context, index) {
              final account = _savedAccounts[index];
              final isCurrentAccount = _currentAccount?.email == account.email;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isCurrentAccount ? Colors.teal[600] : Colors.grey[400],
                  child: Text(
                    account.firstName?.isNotEmpty == true 
                        ? account.firstName![0].toUpperCase()
                        : account.email[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  account.firstName?.isNotEmpty == true 
                      ? '${account.firstName} ${account.lastName ?? ''}'
                      : account.email,
                  style: TextStyle(
                    fontWeight: isCurrentAccount ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(account.email),
                trailing: isCurrentAccount 
                    ? Icon(Icons.check, color: Colors.teal[600])
                    : null,
                onTap: () {
                  setState(() {
                    _emailController.text = account.email;
                    _passwordController.text = account.password;
                    _currentAccount = account;
                  });
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.cancel'.tr()),
          ),
          if (_currentAccount != null)
            TextButton(
              onPressed: () {
                _removeCurrentAccount();
                Navigator.of(context).pop();
              },
              child: Text(
                'Remove',
                style: TextStyle(color: Colors.red[600]),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _removeCurrentAccount() async {
    if (_currentAccount == null) return;
    
    try {
      final savedAccountsService = sl<SavedAccountsService>();
      await savedAccountsService.removeAccount(_currentAccount!.email);
      
      // Reload accounts
      await _loadSavedAccounts();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account removed: ${_currentAccount!.email}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing account: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _checkVerseSetupAndRedirect() async {
    print('_checkVerseSetupAndRedirect - invitation: ${widget.invitation}');
    print(
      '_checkVerseSetupAndRedirect - verseId: ${widget.invitation?.verseId}',
    );

    try {
      final verseJoinUseCase = sl<VerseJoinUseCase>();
      final verseResult = await verseJoinUseCase.getVerse(
        widget.invitation!.verseId,
      );

      verseResult.fold(
        (failure) {
          print('Verse fetch failed: ${failure.message}');
          // If verse fetch fails, show error and redirect to dashboard
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to fetch verse: ${failure.message}'),
              backgroundColor: Colors.orange,
            ),
          );
          // context.go('/${Routelists.dashboard}');
          context.pushNamed(
            Routelists.almostJoinVerse,
            extra: widget.invitation,
          );
        },
        (verse) {
          print(
            'Verse fetched successfully: ${verse.name}, isSetupComplete: ${verse.isSetupComplete}',
          );
          if (verse.isSetupComplete) {
            // Verse setup is complete, redirect to almost join page
            print('Redirecting to almost join page');
            context.pushNamed(
              Routelists.almostJoinVerse,
              extra: widget.invitation,
            );
          } else {
            // Verse setup is not complete, for now do nothing
            // TODO: Implement verse setup flow later
            print(
              'Verse setup not complete, showing message and redirecting to dashboard',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Verse "${verse.name}" setup is not complete yet. Please wait for the admin to complete the setup.',
                ),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 5),
              ),
            );
            // Redirect to dashboard for now
            context.go('/${Routelists.dashboard}');
          }
        },
      );
    } catch (e) {
      print('Error in _checkVerseSetupAndRedirect: $e');
      // Handle any unexpected errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking verse status: $e'),
          backgroundColor: Colors.red,
        ),
      );
      context.go('/${Routelists.dashboard}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [AppTheme.secondary, AppTheme.primary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/bryteversebubbles.png',
                    height: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'login_screen.welcome_message'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'login_screen.email_placeholder'.tr(),
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  // filled: true,
                  // fillColor: const Color(0xFF21262D),
                  border: OutlineInputBorder(
                    // borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    // borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    // borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                textAlign: TextAlign.center,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'login_screen.password_placeholder'.tr(),
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  // filled: true,
                  // fillColor: const Color(0xFF21262D),
                  border: OutlineInputBorder(
                    // borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.white12,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    // borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    // borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                // style: TextStyle(color: AppTheme.text),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Theme(
                    data: ThemeData(
                      unselectedWidgetColor: const Color(0xFF30363D),
                    ),
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (bool? value) {
                        setState(() {
                          _rememberMe = value ?? true;
                        });
                      },
                      activeColor: const Color(0xFFE44D2E),
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.all(
                        const Color(0xFF21262D),
                      ),
                      side: const BorderSide(color: Color(0xFF30363D)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Text(
                    'login_screen.remember_me'.tr(),
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4, left: 4),
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 4),
                        color: Colors.transparent,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 4, right: 4),
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 4),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: const Color.fromARGB(0, 148, 124, 124),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'login_screen.login_button'.tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _showAccountSelectionDialog,
                    child: Text(
                      'login_screen.switch_account'.tr(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Menu',
                        style: TextStyle(color: Colors.black, fontSize: 8),
                      ),
                      Icon(Icons.menu, color: Colors.black, size: 30),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
