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
        primarySwatch: Colors.deepOrange,
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
        usedColor: Colors.red,
        pointRadius: 8,
        showInput: true,
        dimension: 3,
        minPoints: 3,
        relativePadding: 0.7,
        inputThreshold: 25,
        fillPoints: true,
        onInputComplete: (points) {
          final ok = listEquals<int>(points, [0, 3, 7]);
          Scaffold.of(context).hideCurrentSnackBar();
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ok ? "done" : "wrong",
                style: TextStyle(color: ok ? Colors.green : Colors.red),
              ),
            ),
          );
        },
      ),
    );
  }
}
