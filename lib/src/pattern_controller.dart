import 'dart:ui';

class PatternController {
  VoidCallback? clearPattern;

  void dispose() {
    clearPattern = null;
  }
}