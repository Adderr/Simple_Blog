import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:simple_blog/services/profile_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_blog/UI/BaceFook.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _profileServices = ProfileServices();
  late TextEditingController _nameController;
  Map<String, dynamic>? _profile;
  bool isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });
    try {
      final profile = await _profileServices.getProfile();
      setState(() {
        _profile = profile;
        _nameController.text = profile['name'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _handleUpdateName() async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });
    try {
      await _profileServices.updateName(name: _nameController.text);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleAvatarUpload() async {
    final file = await _profileServices.pickAvatar();
    if (file == null) return;

    try {
      final newURL = await _profileServices.uploadAvatar(file: file);
      setState(() {
        _profile!['profile_url'] = newURL;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaceFook(),
      body: isLoading && _profile == null
          ? const Center(child: CircularProgressIndicator())
          : Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                            ),
                          ),
                        const SizedBox(height: 20),
                        Center(
                          child: GestureDetector(
                            onTap: _handleAvatarUpload,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: _profile?['profile_url'] != null
                                  ? NetworkImage(_profile!['profile_url'])
                                  : null,
                              child: _profile?['profile_url'] == null
                                  ? const Icon(Icons.person, size: 50)
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'Tap to change photo',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: isLoading ? null : _handleUpdateName,
                          child: const Text('Save'),
                          style: TextButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 16),
                            backgroundColor: const Color.fromARGB(
                              255,
                              0,
                              0,
                              112,
                            ),
                            foregroundColor: const Color.fromARGB(
                              255,
                              90,
                              181,
                              250,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      backgroundColor: const Color.fromARGB(255, 0, 21, 38),
    );
  }
}
