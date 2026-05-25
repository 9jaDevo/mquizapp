import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/profile/cubit/profile_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _mobile;

  @override
  void initState() {
    super.initState();
    final s = context.read<ProfileCubit>().state;
    final profile = s is ProfileLoaded ? s.profile : null;
    _name = TextEditingController(text: profile?.name ?? '');
    _mobile = TextEditingController(text: profile?.mobile ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final saving = state is ProfileLoaded && state.saving;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 50,
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.length < 2) return 'Name must be at least 2 characters';
                        if (t.length > 50) return 'Name must be at most 50 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mobile,
                      decoration: const InputDecoration(
                        labelText: 'Mobile (optional)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.isEmpty) return null;
                        if (!RegExp(r'^\+?[0-9 \-]{6,20}$').hasMatch(t)) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const Spacer(),
                    PrimaryButton(
                      label: 'Save Changes',
                      icon: Icons.save_outlined,
                      loading: saving,
                      onPressed: saving ? null : _save,
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final patch = <String, dynamic>{
      'name': _name.text.trim(),
      if (_mobile.text.trim().isNotEmpty) 'mobile': _mobile.text.trim(),
    };
    final ok = await context.read<ProfileCubit>().updateProfile(patch);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save changes'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
