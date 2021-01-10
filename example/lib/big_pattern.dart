import 'package:example/util.dart';
import 'package:flutter/material.dart';
import 'package:pattern_lock/pattern_lock.dart';

class BigPattern extends StatelessWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Big Pattern"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Flexible(
            child: Text(
              "For super security",
              style: TextStyle(fontSize: 26),
            ),
          ),
          Flexible(
            flex: 2,
            child: PatternLock(
              selectedColor: Colors.green,
              notSelectedColor: Colors.black26,
              dimension: 5,
              pointRadius: 12,
              fillPoints: true,
              onInputComplete: (List<int> input) {
                if (input.length < 4) {
                  context.replaceSnackbar(
                    content: Text(
                      "At least 4 points required",
                      style: TextStyle(color: Colors.red),
                    ),
                  );

                  return;
                }

                context.replaceSnackbar(
                  content: Text("pattern is $input"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
