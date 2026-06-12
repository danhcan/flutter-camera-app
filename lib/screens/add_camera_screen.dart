import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/camera_provider.dart';

class AddCameraScreen extends StatefulWidget {
  const AddCameraScreen({Key? key}) : super(key: key);

  @override
  State<AddCameraScreen> createState() => _AddCameraScreenState();
}

class _AddCameraScreenState extends State<AddCameraScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rtspUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _rtspUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleAddCamera() async {
    if (!_formKey.currentState!.validate()) return;

    final cameraProvider = context.read<CameraProvider>();

    try {
      await cameraProvider.addCamera(
        name: _nameController.text.trim(),
        rtspUrl: _rtspUrlController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        location: _locationController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera added successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Camera'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Camera Name',
                  prefixIcon: const Icon(Icons.videocam),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter camera name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rtspUrlController,
                decoration: InputDecoration(
                  labelText: 'RTSP URL',
                  prefixIcon: const Icon(Icons.link),
                  hintText: 'rtsp://192.168.1.100:554/stream',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter RTSP URL';
                  }
                  if (!value.startsWith('rtsp://')) {
                    return 'URL must start with rtsp://';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username (Optional)',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password (Optional)',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  prefixIcon: const Icon(Icons.location_on),
                  hintText: 'e.g., Front Door, Living Room',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Consumer<CameraProvider>(
                builder: (context, cameraProvider, _) {
                  return ElevatedButton.icon(
                    onPressed: cameraProvider.isLoading ? null : _handleAddCamera,
                    icon: cameraProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add),
                    label: const Text('Add Camera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
