import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  List<FileSystemEntity> _videoFiles = [];
  late Directory _dir;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _dir = await getApplicationDocumentsDirectory();
    _loadFiles();
  }

  void _loadFiles() {
    final files =
        _dir.listSync().where((f) => f.path.endsWith(".mp4")).toList();
    setState(() => _videoFiles = files);
  }

  Future<void> _recordVideo() async {
    final cameras = await availableCameras();
    final controller = CameraController(cameras[0], ResolutionPreset.medium);
    await controller.initialize();

    final path =
        "${_dir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4";
    await controller.startVideoRecording();
    await Future.delayed(const Duration(seconds: 5)); // short recording
    final video = await controller.stopVideoRecording();
    await video.saveTo(path);
    await controller.dispose();
    _loadFiles();
  }

  void _playVideo(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VideoPlayerScreen(path: path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Recordings")),
      body: ListView.builder(
        itemCount: _videoFiles.length,
        itemBuilder: (context, index) {
          final file = _videoFiles[index];
          return ListTile(
            leading: const Icon(Icons.videocam),
            title: Text(file.path.split('/').last),
            onTap: () => _playVideo(file.path),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _recordVideo,
        child: const Center(child: Icon(Icons.videocam)),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String path;
  const VideoPlayerScreen({super.key, required this.path});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Playing Video")),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller))
            : const CircularProgressIndicator(),
      ),
    );
  }
}
