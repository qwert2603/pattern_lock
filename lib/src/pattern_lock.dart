import 'package:flutter/material.dart';
import 'package:pattern_lock/src/utils.dart';

class PatternLock extends StatefulWidget {
  final int dimension;
  final double relativePadding;
  final Color selectedColor;
  final Color notSelectedColor;
  final double pointRadius;
  final bool showInput;
  final int selectThreshold;
  final bool fillPoints;
  final Function(List<int>) onInputComplete;

  /// Creates [PatternLock] with given params.
  ///
  /// [dimension] count of points horizontally and vertically.
  /// [relativePadding] padding of points area relative to distance between points.
  /// [selectedColor] color of selected points.
  /// [notSelectedColor] color of not selected points.
  /// [pointRadius] radius of points.
  /// [showInput] whether show user's input and highlight selected points.
  /// [selectThreshold] needed distance from input to point to select point.
  /// [fillPoints] whether fill points.
  /// [onInputComplete] callback that called when user's input complete. Called if user selected one or more points.
  const PatternLock({
    Key key,
    this.dimension = 3,
    this.relativePadding = 0.7,
    this.selectedColor, // Theme.of(context).primaryColor if null
    this.notSelectedColor,

    /// [Colors.black45] if null
    this.pointRadius = 10,
    this.showInput = true,
    this.selectThreshold = 25,
    this.fillPoints = false,
    @required this.onInputComplete,
  })  : assert(dimension != null),
        assert(relativePadding != null),
        assert(pointRadius != null),
        assert(showInput != null),
        assert(selectThreshold != null),
        assert(fillPoints != null),
        assert(onInputComplete != null),
        super(key: key);

  @override
  _PatternLockState createState() => _PatternLockState();
}

class _PatternLockState extends State<PatternLock> {
  List<int> used = [];
  Offset currentPoint;

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
        RenderBox referenceBox = context.findRenderObject();
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
          selectedColor: widget.selectedColor ?? Theme.of(context).primaryColor,
          notSelectedColor: widget.notSelectedColor ?? Colors.black45,
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
  final Offset currentPoint;
  final double relativePadding;
  final Color selectedColor;
  final Color notSelectedColor;
  final double pointRadius;
  final bool showInput;
  final bool fillPoints;

  final Paint circlePaint;
  final Paint selectedPaint;

  _LockPainter({
    this.dimension,
    this.used,
    this.currentPoint,
    this.relativePadding,
    this.selectedColor,
    this.notSelectedColor,
    this.pointRadius,
    this.showInput,
    this.fillPoints,
  })  : circlePaint = Paint()
          ..color = notSelectedColor
          ..style = fillPoints ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = 2,
        selectedPaint = Paint()
          ..color = selectedColor
          ..style = fillPoints ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2;

  @override
  void paint(Canvas canvas, Size size) {
    Offset circlePosition(int n) =>
        calcCirclePosition(n, size, dimension, relativePadding);

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

    if (showInput) {
      for (int i = 0; i < used.length - 1; ++i) {
        canvas.drawLine(
          circlePosition(used[i]),
          circlePosition(used[i + 1]),
          selectedPaint,
        );
      }

      if (used.isNotEmpty && currentPoint != null) {
        canvas.drawLine(
          circlePosition(used[used.length - 1]),
          currentPoint,
          selectedPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
