import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/camera_model.dart';
import '../providers/camera_provider.dart';

class CameraDetailScreen extends StatefulWidget {
  final CameraModel camera;

  const CameraDetailScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  @override
  State<CameraDetailScreen> createState() => _CameraDetailScreenState();
}

class _CameraDetailScreenState extends State<CameraDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _rtspUrlController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _locationController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.camera.name);
    _rtspUrlController = TextEditingController(text: widget.camera.rtspUrl);
    _usernameController = TextEditingController(text: widget.camera.username);
    _passwordController = TextEditingController(text: widget.camera.password);
    _locationController = TextEditingController(text: widget.camera.location);
    _isActive = widget.camera.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rtspUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final cameraProvider = context.read<CameraProvider>();

    try {
      await cameraProvider.updateCamera(
        widget.camera.id,
        name: _nameController.text.trim(),
        rtspUrl: _rtspUrlController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        location: _locationController.text.trim(),
        isActive: _isActive,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera updated successfully')),
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

  Future<void> _handleDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Camera'),
        content: const Text('Are you sure you want to delete this camera?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      final cameraProvider = context.read<CameraProvider>();
      try {
        await cameraProvider.deleteCamera(widget.camera.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Camera deleted successfully')),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Camera'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _handleDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Camera Name',
                prefixIcon: const Icon(Icons.videocam),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _rtspUrlController,
              decoration: InputDecoration(
                labelText: 'RTSP URL',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active'),
              value: _isActive,
              onChanged: (value) {
                setState(() => _isActive = value);
              },
            ),
            const SizedBox(height: 32),
            Consumer<CameraProvider>(
              builder: (context, cameraProvider, _) {
                return ElevatedButton.icon(
                  onPressed: cameraProvider.isLoading ? null : _handleUpdate,
                  icon: cameraProvider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Update Camera'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
