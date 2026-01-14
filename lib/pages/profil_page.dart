import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../services/api_service.dart';
import '../services/api_config.dart';
import 'login_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final _apiService = ApiService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  int _userId = 0;
  bool _isLoading = false;
  File? _profileImage;
  String? _profileImageUrl;
  Uint8List? _webImageBytes; // For web platform image storage

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userId = prefs.getInt('user_id') ?? 0;
        _nameController.text = prefs.getString('name') ?? '';
        _emailController.text = prefs.getString('email') ?? '';
        _profileImageUrl = prefs.getString('profile_image');
        print('DEBUG: Loaded profile image URL: $_profileImageUrl');
        print('DEBUG: User ID: $_userId');
        print('DEBUG: Name: ${_nameController.text}');
        print('DEBUG: Email: ${_emailController.text}');
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      // Check if we're on web platform
      if (kIsWeb) {
        // Web-specific handling
        final pickedFile = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
        );

        if (pickedFile != null) {
          print('DEBUG: Web image picked: ${pickedFile.name}');
          // Read image bytes for web
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            // For web, store the bytes for display
            _profileImage = null; // Web doesn't use File objects
            _webImageBytes = bytes; // Store the web image bytes
          });

          // Show success message for web
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image selected successfully (Web)'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          print('DEBUG: No image selected');
        }
      } else {
        // Mobile/desktop handling
        final pickedFile = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
        );

        if (pickedFile != null) {
          print('DEBUG: Image picked: ${pickedFile.path}');
          setState(() {
            _profileImage = File(pickedFile.path);
          });
          print('DEBUG: Profile image set: ${_profileImage?.path}');
        } else {
          print('DEBUG: No image selected');
        }
      }
    } catch (e) {
      print('DEBUG: Error picking image: $e');
      String errorMessage = 'Error picking image: ${e.toString()}';

      // Provide more specific error messages
      if (e.toString().contains('MissingPluginException')) {
        errorMessage =
            'Image picker plugin not properly configured. Please run on a mobile device or emulator.';
      } else if (e.toString().contains('permission')) {
        errorMessage =
            'Permission denied. Please grant camera/storage permissions.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      print('DEBUG: Starting profile update');
      print('DEBUG: User ID: $_userId');
      print('DEBUG: Has profile image: ${_profileImage != null}');

      // Upload image if selected
      if (_profileImage != null || _webImageBytes != null) {
        print('DEBUG: Uploading profile image...');
        final imageResponse = await _apiService.uploadProfileImage(
          _userId,
          _profileImage ?? _webImageBytes,
        );
        print('DEBUG: Image upload response: $imageResponse');

        if (imageResponse['status'] == 'success') {
          final newImageUrl = imageResponse['image_url'];
          print('DEBUG: Image URL from response: $newImageUrl');

          // Save image URL to preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profile_image', newImageUrl!);
          print('DEBUG: Image URL saved to preferences: $newImageUrl');

          // Update the state with the new URL, but KEEP local bytes for now
          // so the user doesn't see a flicker or error while the network image loads
          if (mounted) {
            setState(() {
              _profileImageUrl = newImageUrl;
              // We'll clear the temporary images in a bit or let _loadProfile handle it
            });
          }
        } else {
          throw Exception(imageResponse['message'] ?? 'Image upload failed');
        }
      } else {
        print(
          'DEBUG: No image to upload, checking existing image URL: $_profileImageUrl',
        );
      }

      print('DEBUG: Updating profile data...');
      final response = await _apiService.updateProfile(
        _userId,
        _nameController.text,
        _emailController.text,
      );
      print('DEBUG: Profile update response: $response');

      if (response['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', _nameController.text);
        await prefs.setString('email', _emailController.text);

        // Simpan profile_image yang dikembalikan oleh server (untuk sinkronisasi)
        if (response['profile_image'] != null) {
          await prefs.setString('profile_image', response['profile_image']);
        }

        // Jangan hapus data lokal (bytes/file) agar tampilan tetap stabil di sesi ini.
        // Data lokal akan diprioritaskan di widget build agar user langsung melihat hasilnya.
        if (mounted) {
          setState(() {
            // Kita biarkan _profileImage dan _webImageBytes tetap terisi.
            // _loadProfile akan memperbarui _profileImageUrl dari preferences.
            _loadProfile();
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(response['message'] ?? 'Profile update failed');
      }
    } catch (e) {
      print('DEBUG: Error in profile update: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildImagePlaceholder({
    required IconData icon,
    required String label,
    String? sublabel,
  }) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(color: Colors.grey[50], shape: BoxShape.circle),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (sublabel != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                sublabel,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.redAccent),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: Build method called');
    print('DEBUG: _profileImage: ${_profileImage != null}');
    print('DEBUG: _webImageBytes: ${_webImageBytes != null}');
    print('DEBUG: _profileImageUrl: $_profileImageUrl');
    print(
      'DEBUG: _profileImageUrl isEmpty: ${_profileImageUrl?.isEmpty ?? true}',
    );
    if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      print(
        'DEBUG: Normalized URL: ${ApiConfig.normalizeUrl(_profileImageUrl!)}',
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          children: [
            // Header with gradient background
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Profil Saya',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kelola informasi pribadi Anda',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Profile Image Section
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.9),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.grey[100],
                            child: ClipOval(
                              child: _profileImage != null
                                  ? Image.file(
                                      _profileImage!,
                                      width: 140,
                                      height: 140,
                                      fit: BoxFit.cover,
                                    )
                                  : _webImageBytes != null
                                  ? Image.memory(
                                      _webImageBytes!,
                                      width: 140,
                                      height: 140,
                                      fit: BoxFit.cover,
                                    )
                                  : (_profileImageUrl != null &&
                                        _profileImageUrl!.isNotEmpty)
                                  ? Image.network(
                                      '${ApiConfig.normalizeUrl(_profileImageUrl!)}&v=${DateTime.now().millisecondsSinceEpoch}',
                                      width: 140,
                                      height: 140,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                value:
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                      errorBuilder: (context, error, stackTrace) {
                                        print(
                                          'DEBUG: Network image error: $error',
                                        );
                                        return _buildImagePlaceholder(
                                          icon: Icons.broken_image_rounded,
                                          label: 'Error',
                                          sublabel: 'Gagal memuat',
                                        );
                                      },
                                    )
                                  : _buildImagePlaceholder(
                                      icon: Icons.person_rounded,
                                      label: 'No Image',
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'ID Profil: $_userId',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const SizedBox(height: 30),
            // Personal Information Card
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Informasi Personal',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _nameController.text.isNotEmpty
                                    ? _nameController.text
                                    : 'Nama Lengkap',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: _nameController.text.isNotEmpty
                                      ? const Color(0xFF2D3748)
                                      : const Color(0xFFA0AEC0),
                                  fontWeight: _nameController.text.isNotEmpty
                                      ? FontWeight.normal
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _emailController.text.isNotEmpty
                                    ? _emailController.text
                                    : 'Email Address',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: _emailController.text.isNotEmpty
                                      ? const Color(0xFF2D3748)
                                      : const Color(0xFFA0AEC0),
                                  fontWeight: _emailController.text.isNotEmpty
                                      ? FontWeight.normal
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Save Button
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Simpan Perubahan',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            // Logout Button
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: TextButton.icon(
                  onPressed: () async {
                    final bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Konfirmasi Logout'),
                        content: const Text('Apakah Anda yakin ingin keluar?'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (route) => false,
                        );
                      }
                    }
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                  ),
                  label: Text(
                    'Keluar dari Akun',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
