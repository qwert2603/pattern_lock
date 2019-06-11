import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pattern_lock/pattern_lock.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pattern Lock Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Pattern Lock Demo"),
        ),
        body: new NewWidget(),
      ),
    );
  }
}

class NewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: PatternLock(
        usedColor: Colors.orange,
        pointRadius: 8,
        showInput: true,
        dimension: 3,
        minPoints: 3,
        relativePadding: 0.7,
        inputThreshold: 20,
        inputChecker: (points) => listEquals<int>(points, [0, 3, 7]),
        onCorrectInput: (points) {
          Scaffold.of(context).hideCurrentSnackBar();
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "done",
                style: TextStyle(color: Colors.green),
              ),
            ),
          );
        },
        onIncorrectInput: () {
          Scaffold.of(context).hideCurrentSnackBar();
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "wrong",
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        },
      ),
    );
  }
}
