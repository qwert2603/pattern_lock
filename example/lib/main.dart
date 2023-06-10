import 'package:example/big_pattern.dart';
import 'package:example/check_pattern.dart';
import 'package:example/set_pattern.dart';
import 'package:example/util.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pattern Lock Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        useMaterial3: true
      ),
      routes: {
        "/check_pattern": (BuildContext context) => CheckPattern(),
        "/set_pattern": (BuildContext context) => SetPattern(),
        "/big_pattern": (BuildContext context) => BigPattern(),
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
  List<int>? pattern;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'This is demo of "Pattern Lock" Flutter library',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 4),
          TextButton(onPressed: () => launch("https://github.com/qwert2603/pattern_lock"), child: Text(
            'https://github.com/qwert2603/pattern_lock',
            style: TextStyle(fontSize: 16, color: Colors.deepOrange),
          )),
          SizedBox(height: 4),
          TextButton(onPressed: () => launch("https://pub.dev/packages/pattern_lock"), child: Text(
            'https://pub.dev/packages/pattern_lock',
            style: TextStyle(fontSize: 16, color: Colors.deepOrange),
          )),
          SizedBox(height: 24),
          FilledButton.tonal(
            style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.lightGreen)),
            child: Text("Set Pattern", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              final result = await Navigator.pushNamed(context, "/set_pattern");
              if (result is List<int>) {
                context.replaceSnackbar(
                  content: Text("pattern is $result"),
                );
                setState(() {
                  pattern = result;
                });
              }
            },
          ),
          if (pattern != null) ...[
            SizedBox(height: 16),
            FilledButton.tonal(
              style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.green)),
              child:
                  Text("Check Pattern", style: TextStyle(color: Colors.white)),
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  "/check_pattern",
                  arguments: pattern,
                );
                if (result == true) {
                  context.replaceSnackbar(
                    content: Text(
                      "it's correct",
                      style: TextStyle(color: Colors.green),
                    ),
                  );
                }
              },
            ),
          ],
          SizedBox(height: 24),
          FilledButton.tonal(
            style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red)),
            child: Text("Big Pattern", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pushNamed(context, "/big_pattern"),
          ),
        ],
      ),
    );
  }
}
