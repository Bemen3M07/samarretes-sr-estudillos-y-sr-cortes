import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Se obtiene la lista de cámaras disponibles para la pantalla de cámara.
  final cameras = await availableCameras();
  runApp(ApplicacionMovil(cameras: cameras));
}

class ApplicacionMovil extends StatelessWidget {
  final List<CameraDescription> cameras;
  const ApplicacionMovil({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(cameras: cameras),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const HomeScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;
  List<File> _images = [];  // Lista de imágenes compartida

  @override
  void initState() {
    super.initState();
    _screens = [
      CameraScreen(cameras: widget.cameras, onImageCaptured: _addImage),
      GalleryScreen(images: []),
      MusicScreen(),
    ];
  }

  void _addImage(File image) {
    setState(() {
      _images.add(image);  // Agregar imagen a la lista
      _screens[1] = GalleryScreen(images: _images); // Actualizar GalleryScreen
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Cámara'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_library), label: 'Galería'),
          BottomNavigationBarItem(icon: Icon(Icons.audiotrack), label: 'Música'),
        ],
      ),
    );
  }
}

/// ------------------------
/// Código de la Camara
/// ------------------------

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Function(File) onImageCaptured;  // Función para enviar imágenes a HomeScreen
  const CameraScreen({Key? key, required this.cameras, required this.onImageCaptured}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isRecording = false;
  String _mode = "menu";
  int _cameraIndex = 0;
  FlashMode _flashMode = FlashMode.auto;
  List<String> _gallery = [];
  List<File> images = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isEmpty) return;
    _controller = CameraController(widget.cameras[_cameraIndex], ResolutionPreset.high);
    await _controller!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  void _toggleCamera() {
    if (widget.cameras.length > 1) {
      _cameraIndex = (_cameraIndex + 1) % widget.cameras.length;
      _initializeCamera();
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller != null) {
      setState(() {
        _flashMode = _flashMode == FlashMode.off
            ? FlashMode.always
            : _flashMode == FlashMode.always
                ? FlashMode.auto
                : FlashMode.off;
      });
      await _controller!.setFlashMode(_flashMode);
    }
  }

  Future<String> _getStoragePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/MyAppMedia';
    await Directory(path).create(recursive: true);
    return path;
  }

  Future<void> _captureImage() async {
    if (_controller != null && _controller!.value.isInitialized) {
      await _controller!.setFlashMode(_flashMode);
      final XFile image = await _controller!.takePicture();
      final path = await _getStoragePath();
      final imagePath = '$path/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await image.saveTo(imagePath);
      setState(() {
        _gallery.insert(0, imagePath);
        images.add(File(imagePath));

      });

      widget.onImageCaptured(File(imagePath));  // Enviar imagen a HomeScreen
    }
  }

  Widget _cameraControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FloatingActionButton(
          onPressed: _captureImage,
          child: Icon(Icons.camera_alt),
        ),
        FloatingActionButton(
          onPressed: _toggleCamera,
          child: Icon(Icons.switch_camera),
        ),
        FloatingActionButton(
          onPressed: _toggleFlash,
          child: Icon(
            _flashMode == FlashMode.off ? Icons.flash_off :
            _flashMode == FlashMode.always ? Icons.flash_on :
            Icons.flash_auto,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_mode != "gallery") Positioned.fill(child: CameraPreview(_controller!)),
          Positioned(
            top: 30,
            left: 20,
            child: FloatingActionButton(
              onPressed: () => setState(() => _mode = "menu"),
              child: Icon(Icons.arrow_back),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: _cameraControls(),
          ),
        ],
      ),
    );
  }

}

/// ------------------------
/// Código de la galeria
/// ------------------------

class GalleryScreen extends StatelessWidget {
  final List<File> images;

  void _openMedia(BuildContext context, File image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.file(image),
        ),
      ),
    );
  }

  GalleryScreen({required this.images});

  @override
  Widget build(BuildContext context) {
    return images.isEmpty
    ? Center(child: Text("No hay fotos aún"))
    : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: images.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _openMedia(context, images[index]),
              child: Image.file(images[index], fit: BoxFit.cover),
            );
          },
        ),
      );
  }
}

/// ------------------------
/// Código del REPRODUCTOR DE MÚSICA (MusicScreen)
/// ------------------------

class MusicScreen extends StatefulWidget {
  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentAudio;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isAudioPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration(seconds: 1);
  bool _isSeeking = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _totalDuration = duration;
      });
    });
    _audioPlayer.onPositionChanged.listen((Duration position) {
      if (!_isSeeking) {
        setState(() {
          _currentPosition = position;
        });
      }
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _currentPosition = Duration.zero;
        _isAudioPlaying = false;
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> _playAudio(String fileName) async {
    _currentAudio = fileName;
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(fileName));
    setState(() {
      _isPlaying = true;
      _isAudioPlaying = true;
    });
  }

  void _togglePlayPause() async {
    if (_isPlaying && !_isPaused) {
      await _audioPlayer.pause();
      setState(() {
        _isPaused = true;
        _isAudioPlaying = false;
      });
    } else if (_isPlaying) {
      await _audioPlayer.resume();
      setState(() {
        _isPaused = false;
        _isAudioPlaying = true;
      });
    }
  }

  void _forward10Seconds() async {
    int current = (await _audioPlayer.getCurrentPosition())?.inMilliseconds ?? 0;
    await _audioPlayer.seek(Duration(milliseconds: current + 10000));
  }

  void _rewind10Seconds() async {
    int current = (await _audioPlayer.getCurrentPosition())?.inMilliseconds ?? 0;
    await _audioPlayer.seek(Duration(milliseconds: current - 10000));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Music Player"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentAudio ?? "Seleccione un audio",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Slider(
              min: 0,
              max: _totalDuration.inMilliseconds.toDouble(),
              value: _currentPosition.inMilliseconds.toDouble().clamp(0, _totalDuration.inMilliseconds.toDouble()),
              onChangeStart: (value) {
                _isSeeking = true;
              },
              onChanged: (value) {
                setState(() {
                  _currentPosition = Duration(milliseconds: value.toInt());
                });
              },
              onChangeEnd: (value) async {
                _isSeeking = false;
                await _audioPlayer.seek(Duration(milliseconds: value.toInt()));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_formatDuration(_currentPosition)),
                SizedBox(width: 10),
                Text("/"),
                SizedBox(width: 10),
                Text(_formatDuration(_totalDuration)),
              ],
            ),
            SizedBox(height: 10),
            IconButton(
              icon: Icon(_isAudioPlaying ? Icons.pause : Icons.play_arrow, size: 50),
              onPressed: () {
                if (_isPlaying) {
                  _togglePlayPause();
                } else {
                  _playAudio("Music1.mp3");
                }
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.replay_10, size: 30),
                  onPressed: _rewind10Seconds,
                ),
                IconButton(
                  icon: Icon(Icons.forward_10, size: 30),
                  onPressed: _forward10Seconds,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
