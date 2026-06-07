import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/auth/cubits/auth_cubit.dart';
import 'package:flutterquiz/features/user_path/cubits/user_path_cubit.dart';
import 'package:flutterquiz/features/user_path/models/user_path.dart';
import 'package:flutterquiz/ui/widgets/custom_rounded_button.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

/// Path Selection Screen - First step in onboarding
/// Shows three main learning path options: Student, Professional, Competition
class PathSelectionScreen extends StatefulWidget {
  const PathSelectionScreen({super.key});

  @override
  State<PathSelectionScreen> createState() => _PathSelectionScreenState();

  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => const PathSelectionScreen());
  }
}

class _PathSelectionScreenState extends State<PathSelectionScreen>
    with SingleTickerProviderStateMixin {
  UserPathType? _selectedPath;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePathSelection(UserPathType path) {
    setState(() {
      _selectedPath = path;
    });
  }

  Future<void> _handleContinue() async {
    if (_selectedPath == null) return;

    final userId = context.read<AuthCubit>().getUserId();

    // Set the user's path
    await context.read<UserPathCubit>().setUserPath(
          userId: userId,
          selectedPath: _selectedPath!,
          dailyGoalMinutes: 10, // Default value
        );

    // Navigate to preferences screen or home
    if (mounted) {
      // TODO: Navigate to PathPreferencesScreen or demo quiz
      // For now, just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome to ${_selectedPath!.displayName}!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        'Welcome to mQuiz!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Choose your learning path',
                        style: TextStyle(
                          fontSize: 18,
                          color: colorScheme.onBackground.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Path Options
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: UserPathType.values.map((pathType) {
                      final isSelected = _selectedPath == pathType;
                      return _PathOptionCard(
                        pathType: pathType,
                        isSelected: isSelected,
                        onTap: () => _handlePathSelection(pathType),
                      );
                    }).toList(),
                  ),
                ),

                // Continue Button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: CustomRoundedButton(
                    widthPercentage: 1.0,
                    backgroundColor: _selectedPath != null
                        ? colorScheme.primary
                        : colorScheme.primary.withOpacity(0.3),
                    buttonTitle: 'Continue',
                    radius: 12,
                    onTap: _selectedPath != null ? _handleContinue : null,
                    titleColor: Colors.white,
                    showBorder: false,
                    height: 56,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PathOptionCard extends StatelessWidget {
  const _PathOptionCard({
    required this.pathType,
    required this.isSelected,
    required this.onTap,
  });

  final UserPathType pathType;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary.withOpacity(0.1)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.onSurface.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        pathType.icon,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pathType.displayName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pathType.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Selection indicator
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Benefits
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pathType.benefits
                    .map(
                      (benefit) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary.withOpacity(0.2)
                              : colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          benefit,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
