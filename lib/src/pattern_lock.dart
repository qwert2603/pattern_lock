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
  final Color notSelectedColor;

  /// Color of connecting lines.
  final Color? strokeColor;

  /// Radius of points.
  final double pointRadius;

  /// Whether show user's input and highlight selected points.
  final bool showInput;

  /// Needed distance from input to point to select point.
  final int selectThreshold;

  /// Width of connecting lines
  final double strokeWidth;

  /// Whether fill points.
  final bool fillPoints;

  /// if there are some points between start and end points this flag will add them to list too
  final bool connectMiddlePoints;

  /// clears the selected points on touch end
  final bool clearOnDone;

  /// Callback that called when user's input complete. Called if user selected one or more points.
  final Function(List<int>) onInputComplete;

  /// Creates [PatternLock] with given params.
  const PatternLock({
    Key? key,
    this.dimension = 3,
    this.relativePadding = 0.7,
    this.selectedColor, // Theme.of(context).primaryColor if null
    this.notSelectedColor = Colors.black45,
    this.strokeColor,
    this.pointRadius = 10,
    this.showInput = true,
    this.strokeWidth = 2,
    this.selectThreshold = 25,
    this.fillPoints = false,
    this.connectMiddlePoints = true,
    this.clearOnDone = false,
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
          setState(() {
            currentPoint = null;
            if (widget.clearOnDone) used = [];
          });
        }
      },
      onPanStart: (details) {
        setState(() {
          used = [];
          currentPoint = null;
        });
      },
      onPanUpdate: (DragUpdateDetails details) {
        RenderBox referenceBox = context.findRenderObject() as RenderBox;
        Offset localPosition = referenceBox.globalToLocal(details.globalPosition);

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
              int selectedDot = i;
              // ↑↓ add any vertical points between start and end point
              if (widget.connectMiddlePoints &&
                  used.isNotEmpty &&
                  ((used.last % widget.dimension) == (selectedDot % widget.dimension))) {
                if (used.last > selectedDot) {
                  for (int linePoint = used.last; linePoint >= selectedDot; linePoint -= widget.dimension)
                    if (!used.contains(linePoint)) used.add(linePoint);
                } else {
                  for (int linePoint = used.last; linePoint <= selectedDot; linePoint += widget.dimension)
                    if (!used.contains(linePoint)) used.add(linePoint);
                }
              }
              //←→ add any horizontal points between start and end point
              else if (widget.connectMiddlePoints &&
                  used.isNotEmpty &&
                  used.last ~/ widget.dimension == selectedDot ~/ widget.dimension &&
                  (used.last - selectedDot).abs() > 1) {
                int linePoint = used.last;
                if (used.last > selectedDot) {
                  while (linePoint != selectedDot) {
                    linePoint--;
                    used.add(linePoint);
                  }
                } else if (used.last < selectedDot) {
                  while (linePoint != selectedDot) {
                    linePoint++;
                    used.add(linePoint);
                  }
                }
              }
              // ↖ add any diagonal points between start and end point in ↖ direction
              else if (widget.connectMiddlePoints &&
                  used.isNotEmpty &&
                  used.last > selectedDot &&
                  ((used.last - selectedDot) % (widget.dimension + 1) == 0) &&
                  (used.last % widget.dimension > selectedDot % widget.dimension)) {
                for (int linePoint = used.last; linePoint >= selectedDot; linePoint -= (widget.dimension + 1)) {
                  if (!used.contains(linePoint)) used.add(linePoint);
                }
              }
              // ↘ add any diagonal points between start and end point in ↘ direction
              else if (widget.connectMiddlePoints &&
                  used.isNotEmpty &&
                  used.last < selectedDot &&
                  ((selectedDot - used.last) % (widget.dimension + 1) == 0) &&
                  (used.last % widget.dimension < selectedDot % widget.dimension)) {
                for (int linePoint = used.last; linePoint <= selectedDot; linePoint += (widget.dimension + 1)) {
                  if (!used.contains(linePoint)) used.add(linePoint);
                }
              }
              // ↗ add any diagonal points between start and end point in ↗ direction
              else if (widget.connectMiddlePoints &&
                  used.isNotEmpty &&
                  used.last > selectedDot &&
                  ((used.last - selectedDot) % (widget.dimension - 1) == 0) &&
                  (used.last % widget.dimension < selectedDot % widget.dimension)) {
                for (int linePoint = used.last; linePoint >= selectedDot; linePoint -= (widget.dimension - 1)) {
                  if (!used.contains(linePoint)) used.add(linePoint);
                }
              }
              // ↙ add any diagonal points between start and end point in ↙ direction
              else if (widget.connectMiddlePoints &&
                  used.isNotEmpty &&
                  selectedDot > used.last &&
                  ((selectedDot - used.last) % (widget.dimension - 1) == 0) &&
                  (used.last % widget.dimension > selectedDot % widget.dimension)) {
                for (int linePoint = used.last; linePoint <= selectedDot; linePoint += (widget.dimension - 1)) {
                  if (!used.contains(linePoint)) used.add(linePoint);
                }
              } else {
                used.add(selectedDot);
              }
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
            notSelectedColor: widget.notSelectedColor,
            strokeColor: widget.strokeColor,
            pointRadius: widget.pointRadius,
            showInput: widget.showInput,
            fillPoints: widget.fillPoints,
            strokeWidth: widget.strokeWidth),
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
  final double strokeWidth;
  final bool showInput;

  final Paint circlePaint;
  final Paint selectedPaint;
  final Paint linePaint;
  final Color? strokeColor;

  _LockPainter({
    required this.dimension,
    required this.used,
    this.currentPoint,
    this.strokeWidth = 2,
    required this.relativePadding,
    required Color selectedColor,
    required Color notSelectedColor,
    this.strokeColor,
    required this.pointRadius,
    required this.showInput,
    required bool fillPoints,
  })  : circlePaint = Paint()
          ..color = notSelectedColor
          ..style = fillPoints ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = 2,
        selectedPaint = Paint()
          ..color = selectedColor
          ..style = fillPoints ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 2,
        linePaint = Paint()
          ..color = strokeColor ?? selectedColor
          ..style = fillPoints ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    Offset circlePosition(int n) => calcCirclePosition(n, size, dimension, relativePadding);

    for (int i = 0; i < dimension; ++i) {
      for (int j = 0; j < dimension; ++j) {
        canvas.drawCircle(
          circlePosition(i * dimension + j),
          pointRadius,
          showInput && used.contains(i * dimension + j) ? selectedPaint : circlePaint,
        );
      }
    }

    if (showInput) {
      for (int i = 0; i < used.length - 1; ++i) {
        canvas.drawLine(
          circlePosition(used[i]),
          circlePosition(used[i + 1]),
          linePaint,
        );
      }

      final currentPoint = this.currentPoint;
      if (used.isNotEmpty && currentPoint != null) {
        canvas.drawLine(
          circlePosition(used[used.length - 1]),
          currentPoint,
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
