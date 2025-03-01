// test/mocks.dart

import 'package:mockito/mockito.dart';
import 'package:camera/camera.dart';

// Simulando el CameraController con un Mock
class MockCameraController extends Mock implements CameraController {}

// Simulando el CameraDescription con un Mock
class MockCameraDescription extends Mock implements CameraDescription {}