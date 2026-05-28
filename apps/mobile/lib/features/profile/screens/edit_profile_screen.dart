import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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

  File? _pickedImage;
  bool _uploadingImage = false;

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _pickedImage = File(picked.path));
  }

  Future<String?> _uploadImage(File file) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final ext = file.path.split('.').last.toLowerCase();
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images/$uid.${ext.isNotEmpty ? ext : 'jpg'}');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<ProfileCubit>().state;
    final profile = s is ProfileLoaded ? s.profile : null;
    final saving = s is ProfileLoaded && s.saving;
    final busy = saving || _uploadingImage;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Profile picture ────────────────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: busy ? null : _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                          backgroundImage: _pickedImage != null
                              ? FileImage(_pickedImage!) as ImageProvider
                              : (profile?.profileImage != null
                                  ? CachedNetworkImageProvider(profile!.profileImage!)
                                  : null),
                          child: (_pickedImage == null && profile?.profileImage == null)
                              ? Icon(Icons.person, size: 52, color: AppColors.primary)
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // ── Name ──────────────────────────────────────────────────
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
                // ── Mobile ────────────────────────────────────────────────
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
                  loading: busy,
                  onPressed: busy ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    String? uploadedUrl;
    if (_pickedImage != null) {
      setState(() => _uploadingImage = true);
      try {
        uploadedUrl = await _uploadImage(_pickedImage!);
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image upload failed. Try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _uploadingImage = false);
        return;
      }
      setState(() => _uploadingImage = false);
    }

    final patch = <String, dynamic>{
      'name': _name.text.trim(),
      if (_mobile.text.trim().isNotEmpty) 'mobile': _mobile.text.trim(),
      if (uploadedUrl != null) 'profile': uploadedUrl,
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

