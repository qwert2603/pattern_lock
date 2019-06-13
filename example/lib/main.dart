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
      routes: {
        "check_pattern": (BuildContext context) => CheckPattern(),
        "set_pattern": (BuildContext context) => SetPattern(),
      },
      home: Scaffold(
        appBar: AppBar(
          title: Text("Pattern Lock Demo"),
        ),
        body: HomeWidget(),
      ),
    );
  }
}

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  List<int> pattern;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          MaterialButton(
            color: Colors.lightGreen,
            child: Text("Set Pattern", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              final result = await Navigator.pushNamed(context, "set_pattern");
              if (result is List<int>) {
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text("pattern is $result")),
                );
                setState(() {
                  pattern = result;
                });
              }
            },
          ),
          if (pattern != null) ...[
            SizedBox(height: 16),
            MaterialButton(
              color: Colors.green,
              child:
                  Text("Check Pattern", style: TextStyle(color: Colors.white)),
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  "check_pattern",
                  arguments: pattern,
                );
                if (result == true) {
                  Scaffold.of(context).hideCurrentSnackBar();
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "it's correct",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

class CheckPattern extends StatelessWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final List<int> pattern = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Check Pattern"),
      ),
      body: PatternLock(
        selectedColor: Colors.red,
        pointRadius: 8,
        showInput: true,
        dimension: 3,
        relativePadding: 0.7,
        selectThreshold: 25,
        fillPoints: true,
        onInputComplete: (List<int> input) {
          if (listEquals<int>(input, pattern)) {
            Navigator.of(context).pop(true);
          } else {
            scaffoldKey.currentState.hideCurrentSnackBar();
            scaffoldKey.currentState.showSnackBar(
              SnackBar(
                content: Text(
                  "wrong",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class SetPattern extends StatefulWidget {
  @override
  _SetPatternState createState() => _SetPatternState();
}

class _SetPatternState extends State<SetPattern> {
  bool isConfirm = false;
  List<int> pattern;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Check Pattern"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Flexible(
            child: Text(
              isConfirm ? "Confirm pattern" : "Draw pattern",
              style: TextStyle(fontSize: 26),
            ),
          ),
          Flexible(
            child: PatternLock(
              selectedColor: Colors.amber,
              pointRadius: 12,
              onInputComplete: (List<int> input) {
                if (input.length < 3) {
                  scaffoldKey.currentState.hideCurrentSnackBar();
                  scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      content: Text(
                        "At least 3 points required",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                  return;
                }
                if (isConfirm) {
                  if (listEquals<int>(input, pattern)) {
                    Navigator.of(context).pop(pattern);
                  } else {
                    scaffoldKey.currentState.hideCurrentSnackBar();
                    scaffoldKey.currentState.showSnackBar(
                      SnackBar(
                        content: Text(
                          "Patterns do not match",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                    setState(() {
                      pattern = null;
                      isConfirm = false;
                    });
                  }
                } else {
                  setState(() {
                    pattern = input;
                    isConfirm = true;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
