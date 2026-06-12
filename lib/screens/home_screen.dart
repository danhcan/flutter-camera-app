import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/camera_provider.dart';
import '../providers/auth_provider.dart';
import 'camera_grid_screen.dart';
import 'add_camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final cameraProvider = context.read<CameraProvider>();
    if (authProvider.currentUser != null) {
      cameraProvider.setCurrentUserId(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cameras'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _showProfileMenu(context),
          ),
        ],
      ),
      body: Consumer<CameraProvider>(
        builder: (context, cameraProvider, _) {
          if (cameraProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cameraProvider.cameras.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No cameras added yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first camera',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return CameraGridScreen(cameras: cameraProvider.cameras);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddCameraScreen()),
        ),
        tooltip: 'Add Camera',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(user?.displayName ?? 'User'),
              subtitle: Text(user?.email ?? ''),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                Navigator.pop(context);
                authProvider.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
