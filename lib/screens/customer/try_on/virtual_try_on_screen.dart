import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'photo_try_on_view.dart';
import 'live_try_on_view.dart';

class VirtualTryOnScreen extends StatelessWidget {
  const VirtualTryOnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Virtual Try-On'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(icon: Icon(Icons.photo_camera_outlined), text: 'Photo Try-On'),
              Tab(icon: Icon(Icons.videocam_outlined), text: 'Live Camera'),
            ],
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(), // Prevent horizontal swipe conflicts with sliders
          children: [
            PhotoTryOnView(),
            LiveTryOnView(),
          ],
        ),
      ),
    );
  }
}
