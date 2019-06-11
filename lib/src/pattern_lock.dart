import 'package:flutter/material.dart';

class PatternLock extends StatefulWidget {
  final int dimension;
  final double relativePadding;
  final int minPoints;
  final Color usedColor;
  final double pointRadius;
  final bool showInput;
  final int inputThreshold;
  final bool Function(List<int>) inputChecker;
  final Function(List<int>) onCorrectInput;
  final Function() onIncorrectInput;

  const PatternLock({
    Key key,
    this.dimension = 3,
    this.relativePadding = 0.7,
    this.minPoints = 3,
    this.usedColor, // Theme.of(context).primaryColor if null
    this.pointRadius = 10,
    this.showInput = true,
    this.inputThreshold = 25,
    @required this.inputChecker,
    @required this.onCorrectInput,
    this.onIncorrectInput,
  })  : assert(inputChecker != null),
        assert(onCorrectInput != null),
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
        if (used.length >= widget.minPoints) {
          if (widget.inputChecker(used)) {
            widget.onCorrectInput(used);
          } else {
            if (widget.onIncorrectInput != null) widget.onIncorrectInput();
          }
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

        Offset circlePosition(int n) => _circlePosition(
              n,
              referenceBox.size,
              widget.dimension,
              widget.relativePadding,
            );

        setState(() {
          currentPoint = localPosition;
          for (int i = 0; i < widget.dimension * widget.dimension; ++i) {
            final toPoint = (circlePosition(i) - localPosition).distance;
            if (!used.contains(i) && toPoint < widget.inputThreshold) {
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
          usedColor: widget.usedColor ?? Theme.of(context).primaryColor,
          pointRadius: widget.pointRadius,
          showInput: widget.showInput,
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
  final Color usedColor;
  final double pointRadius;
  final bool showInput;

  _LockPainter({
    this.dimension,
    this.used,
    this.currentPoint,
    this.relativePadding,
    this.usedColor,
    this.pointRadius,
    this.showInput,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Offset circlePosition(int n) =>
        _circlePosition(n, size, dimension, relativePadding);

    final circlePaint = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final usedCirclePaint = Paint()
      ..color = usedColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < dimension; ++i) {
      for (int j = 0; j < dimension; ++j) {
        canvas.drawCircle(
          circlePosition(i * dimension + j),
          pointRadius,
          showInput && used.contains(i * dimension + j)
              ? usedCirclePaint
              : circlePaint,
        );
      }
    }

    if (showInput) {
      for (int i = 0; i < used.length - 1; ++i) {
        canvas.drawLine(
          circlePosition(used[i]),
          circlePosition(used[i + 1]),
          usedCirclePaint,
        );
      }

      if (used.isNotEmpty && currentPoint != null) {
        canvas.drawLine(
          circlePosition(used[used.length - 1]),
          currentPoint,
          usedCirclePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

Offset _circlePosition(
    int n, Size size, int dimension, double relativePadding) {
  final o = size.width > size.height
      ? Offset((size.width - size.height) / 2, 0)
      : Offset(0, (size.height - size.width) / 2);
  return o +
      Offset(
        size.shortestSide /
            (dimension - 1 + relativePadding * 2) *
            (n % dimension + relativePadding),
        size.shortestSide /
            (dimension - 1 + relativePadding * 2) *
            (n ~/ dimension + relativePadding),
      );
}
