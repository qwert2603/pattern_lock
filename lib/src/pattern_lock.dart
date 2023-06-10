import 'package:flutter/material.dart';
import 'package:pattern_lock/src/utils.dart';

class PatternLock extends StatefulWidget {
  /// Count of points horizontally and vertically.
  final int dimension;

  /// Padding of points area relative to distance between points.
  final double relativePadding;

  /// Color of selected points.
  final Color? selectedColor;

  /// Color of not selected points.
  final Color? notSelectedColor;

  /// Color of the links between points.
  final Color? linkColor;

  /// The size of the links between points.
  final int linkSize;

  /// Radius of points.
  final double pointRadius;

  /// Whether show user's input and highlight selected points.
  final bool showInput;

  /// Needed distance from input to point to select point.
  final int selectThreshold;

  /// Whether fill points.
  final bool fillPoints;

  /// Callback that called when user's input complete. Called if user selected one or more points.
  final Function(List<int>) onInputComplete;

  /// Creates [PatternLock] with given params.
  const PatternLock({
    Key? key,
    this.dimension = 3,
    this.relativePadding = 0.7,
    this.selectedColor, // Theme.of(context).primaryColor if null
    this.notSelectedColor,
    this.linkColor, // Colors.grey if null
    this.linkSize = 10,
    this.pointRadius = 10,
    this.showInput = true,
    this.selectThreshold = 25,
    this.fillPoints = false,
    required this.onInputComplete,
  }) : super(key: key);

  @override
  _PatternLockState createState() => _PatternLockState();
}

class _PatternLockState extends State<PatternLock> {
  List<int> used = [];
  Offset? currentPoint;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanEnd: (DragEndDetails details) {
        if (used.isNotEmpty) {
          widget.onInputComplete(used);
        }
        setState(() {
          used = [];
          currentPoint = null;
        });
      },
      onPanUpdate: (DragUpdateDetails details) {
        RenderBox referenceBox = context.findRenderObject() as RenderBox;
        Offset localPosition =
            referenceBox.globalToLocal(details.globalPosition);

        Offset circlePosition(int n) => calcCirclePosition(
              n,
              referenceBox.size,
              widget.dimension,
              widget.relativePadding,
            );

        setState(() {
          currentPoint = localPosition;
          for (int i = 0; i < widget.dimension * widget.dimension; ++i) {
            final toPoint = (circlePosition(i) - localPosition).distance;
            if (!used.contains(i) && toPoint < widget.selectThreshold) {
              used.add(i);
            }
          }
        });
      },
      child: CustomPaint(
        painter: _LockPainter(
          dimension: widget.dimension,
          used: used,
          currentPoint: currentPoint,
          relativePadding: widget.relativePadding,
          selectedColor: widget.selectedColor ?? Theme.of(context).colorScheme.onBackground,
          notSelectedColor: widget.notSelectedColor ?? Theme.of(context).colorScheme.onSurface,
          linkColor: widget.linkColor ?? Colors.grey,
          linkSize: widget.linkSize,
          pointRadius: widget.pointRadius,
          showInput: widget.showInput,
          fillPoints: widget.fillPoints,
        ),
        size: Size.infinite,
      ),
    );
  }
}

@immutable
class _LockPainter extends CustomPainter {
  final int dimension;
  final List<int> used;
  final Offset? currentPoint;
  final double relativePadding;
  final double pointRadius;
  final bool showInput;

  final Paint circlePaint;
  final Paint selectedPaint;
  final Paint linkPaint;

  _LockPainter({
    required this.dimension,
    required this.used,
    this.currentPoint,
    required this.relativePadding,
    required Color selectedColor,
    required Color notSelectedColor,
    required Color linkColor,
    required int linkSize,
    required this.pointRadius,
    required this.showInput,
    required bool fillPoints,
  })   : circlePaint = Paint()
          ..color = notSelectedColor
          ..style = fillPoints ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = 2,
        selectedPaint = Paint()
          ..color = selectedColor
          ..style = fillPoints ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2,
        linkPaint = Paint()
          ..color = linkColor
          ..strokeCap = StrokeCap.round
          ..strokeWidth = linkSize.toDouble();

  @override
  void paint(Canvas canvas, Size size) {
    Offset circlePosition(int n) =>
        calcCirclePosition(n, size, dimension, relativePadding);

    if (showInput) {
      for (int i = 0; i < used.length - 1; ++i) {
        canvas.drawLine(
          circlePosition(used[i]),
          circlePosition(used[i + 1]),
          linkPaint..color = linkPaint.color,
        );
      }

      final currentPoint = this.currentPoint;
      if (used.isNotEmpty && currentPoint != null) {
        canvas.drawLine(
          circlePosition(used[used.length - 1]),
          currentPoint,
          linkPaint,
        );
      }
    }

    for (int i = 0; i < dimension; ++i) {
      for (int j = 0; j < dimension; ++j) {
        canvas.drawCircle(
          circlePosition(i * dimension + j),
          pointRadius,
          showInput && used.contains(i * dimension + j)
              ? selectedPaint
              : circlePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
