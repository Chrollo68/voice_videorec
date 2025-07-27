import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final AudioPlayer _player = AudioPlayer();
  List<FileSystemEntity> _audioFiles = [];
  bool _isRecording = false;
  late Directory _dir;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _dir = await getApplicationDocumentsDirectory();
    await _recorder.openRecorder();
    _loadFiles();
  }

  void _loadFiles() {
    final files =
        _dir.listSync().where((f) => f.path.endsWith(".aac")).toList();
    setState(() => _audioFiles = files);
  }

  Future<void> _startRecording() async {
    final path =
        "${_dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac";
    await _recorder.startRecorder(toFile: path);
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() => _isRecording = false);
    _loadFiles();
  }

  Future<void> _playAudio(String path) async {
    await _player.setFilePath(path);
    _player.play();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Audio Recordings")),
      body: ListView.builder(
        itemCount: _audioFiles.length,
        itemBuilder: (context, index) {
          final file = _audioFiles[index];
          return ListTile(
            leading: const Icon(Icons.audiotrack),
            title: Text(file.path.split('/').last),
            onTap: () => _playAudio(file.path),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(_isRecording ? Icons.stop : Icons.mic),
        onPressed: () => _isRecording ? _stopRecording() : _startRecording(),
      ),
    );
  }
}
