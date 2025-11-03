import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/models/user_type.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../navigation/main_navigation.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKeys = <GlobalKey<FormState>>[
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      // Clear fields when switching tabs for better UX
      if (!_tabController.indexIsChanging) {
        _emailController.clear();
        _passwordController.clear();
        // Reset validation state
        for (var key in _formKeys) {
          key.currentState?.reset();
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(UserType userType) async {
    final formIndex = UserType.values.indexOf(userType);
    if (!_formKeys[formIndex].currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
        userType,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (success) {
          // Navigate to main navigation with selected user type
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainNavigation(userType: userType),
            ),
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logged in as ${userType.label}'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid credentials or wrong user type for ${userType.label} login'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  IconData _getIconForUserType(UserType userType) {
    switch (userType) {
      case UserType.student:
        return Icons.school;
      case UserType.driver:
        return Icons.directions_bus;
      case UserType.admin:
        return Icons.admin_panel_settings;
    }
  }

  Widget _buildLoginForm(UserType userType) {
    final formIndex = UserType.values.indexOf(userType);
    return Form(
      key: _formKeys[formIndex],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            label: 'Email',
            hint: 'Enter your email',
            controller: _emailController,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          CustomTextField(
            label: 'Password',
            hint: 'Enter your password',
            controller: _passwordController,
            prefixIcon: Icons.lock_outlined,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Login as ${userType.label}',
            onPressed: () => _handleLogin(userType),
            isLoading: _isLoading,
            icon: _getIconForUserType(userType),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {
                // Handle forgot password
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth > 600 ? 32 : 20,
              vertical: isSmallScreen ? 12 : 16,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 500,
                minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - (isSmallScreen ? 24 : 32),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo and Title
                  FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      children: [
                        Container(
                          width: isSmallScreen ? 70 : 90,
                          height: isSmallScreen ? 70 : 90,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: const DecorationImage(
                              image: AssetImage('assets/icons/app_icon.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 16),
                        Text(
                          'PingMyRide',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 28 : 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 4 : 6),
                        Text(
                          'Your reliable ride tracking companion',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 24),
                  
                  // Login Card
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // User Type Selector Header
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicatorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              labelColor: Theme.of(context).colorScheme.onPrimary,
                              unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
                              labelStyle: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                              unselectedLabelStyle: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                              tabs: UserType.values
                                  .map((type) => Tab(
                                        icon: Icon(
                                          _getIconForUserType(type),
                                          size: isSmallScreen ? 20 : 24,
                                        ),
                                        text: type.label,
                                      ))
                                  .toList(),
                            ),
                          ),
                          
                          // Login Form
                          Padding(
                            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // TabBarView with intrinsic sizing
                                SizedBox(
                                  height: isSmallScreen ? 280 : 320,
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: UserType.values
                                        .map((type) => SingleChildScrollView(
                                              child: _buildLoginForm(type),
                                            ))
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  
                  // Sign Up Link
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 400),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                        const SizedBox(width: 2),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const SignUpPage()),
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
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