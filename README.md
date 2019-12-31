# Pattern Lock

[![pub package](https://img.shields.io/pub/v/pattern_lock.svg)](https://pub.dartlang.org/packages/pattern_lock)

Pattern Lock as Flutter widget.

# Demo [web-site](https://qwert2603.github.io/pattern_lock).

## Demo

![](https://github.com/qwert2603/pattern_lock/blob/master/art/device20190613185830.gif)

## Usage

```dart
PatternLock(
  // color of selected points.
  selectedColor: Colors.red,
  // radius of points.
  pointRadius: 8,
  // whether show user's input and highlight selected points.
  showInput: true,
  // count of points horizontally and vertically.
  dimension: 3,
  // padding of points area relative to distance between points.
  relativePadding: 0.7,
  // needed distance from input to point to select point.
  selectThreshold: 25,
  // whether fill points.
  fillPoints: true,
  // callback that called when user's input complete. Called if user selected one or more points.
  onInputComplete: (List<int> input) {
    print("pattern is $input");
  },
);
```

## [Example](https://github.com/qwert2603/pattern_lock/tree/master/example)

Example app with pattern setting and checking can be found [here](https://github.com/qwert2603/pattern_lock/tree/master/example).

## Screenshots

![](https://github.com/qwert2603/pattern_lock/blob/master/art/demo.png)
