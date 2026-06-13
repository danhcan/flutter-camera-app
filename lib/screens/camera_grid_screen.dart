import 'package:flutter/material.dart';
import '../models/camera_model.dart' show CameraModel, StreamType;
import 'camera_player_screen.dart';
import 'camera_detail_screen.dart';

class CameraGridScreen extends StatelessWidget {
  final List<CameraModel> cameras;

  const CameraGridScreen({
    Key? key,
    required this.cameras,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: cameras.length,
      itemBuilder: (context, index) {
        final camera = cameras[index];
        return CameraGridTile(
          camera: camera,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CameraPlayerScreen(camera: camera),
            ),
          ),
          onEdit: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CameraDetailScreen(camera: camera),
            ),
          ),
        );
      },
    );
  }
}

class CameraGridTile extends StatelessWidget {
  final CameraModel camera;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const CameraGridTile({
    Key? key,
    required this.camera,
    required this.onTap,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Placeholder background
            Container(
              color: Colors.black87,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam,
                    size: 48,
                    color: camera.isActive ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    camera.isActive ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: camera.isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Camera info overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      camera.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: camera.streamType == StreamType.http
                                ? Colors.orange.shade700
                                : camera.streamType == StreamType.onvif
                                    ? Colors.green.shade700
                                    : Colors.blue.shade700,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            camera.streamType.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            camera.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Edit button
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
                color: Colors.white,
                iconSize: 20,
                splashRadius: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
