import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/network/nestjs_api.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/features/auth/cubit/auth_cubit.dart';

const _languages = [
  ('en', 'English'),
  ('yo', 'Yoruba'),
  ('ha', 'Hausa'),
  ('ig', 'Igbo'),
];

const _ageGroups = [
  ('child', 'Child', '0–12'),
  ('teen', 'Teen', '13–17'),
  ('adult', 'Adult', '18–64'),
  ('senior', 'Senior', '65+'),
];

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _language = 'en';
  String? _ageGroup;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ageGroup == null) {
      setState(() => _error = 'Please select your age group');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await NestJsApi.instance
          .updateMe({
            'name': _nameController.text.trim(),
            'appLanguage': _language,
            'ageGroup': _ageGroup,
          })
          .timeout(const Duration(seconds: 20));
      if (!mounted) return;
      await context.read<AuthCubit>().completeOnboarding();
    } catch (e) {
      if (!mounted) return;
      // If the API is unavailable (cold start / timeout), still mark onboarding
      // done and proceed — the name can be updated later from the profile screen.
      await context.read<AuthCubit>().completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set up your profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text(
                  'What should we call you?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a display name for leaderboards.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    hintText: 'e.g. QuizMaster',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (v.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    if (v.trim().length > 30) {
                      return 'Name must be 30 characters or less';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                // ── Language ──────────────────────────────────────────────
                Text(
                  'Preferred language',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: _languages.map((lang) {
                    final (code, label) = lang;
                    return ChoiceChip(
                      label: Text(label),
                      selected: _language == code,
                      onSelected: (_) => setState(() => _language = code),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                // ── Age group ─────────────────────────────────────────────
                Text(
                  'Age group',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: _ageGroups.map((g) {
                    final (value, label, range) = g;
                    return ChoiceChip(
                      label: Text('$label ($range)'),
                      selected: _ageGroup == value,
                      onSelected: (_) =>
                          setState(() => _ageGroup = value),
                    );
                  }).toList(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(color: AppColors.wrong),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Continue'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
