import 'package:flutter/material.dart';

/// [IndexedStack] shows its children one at a time, preserving the state of all the children. But it renders all the children at once.
///
/// With [LazyIndexedWidget] we can load the children lazily, and only when they are needed
class LazyIndexedWidget extends StatefulWidget {
  LazyIndexedWidget({
    super.key,
    required this.index,
    required this.children,
  }) : assert(children.isNotEmpty, 'Children list cannot be empty');

  final int index;
  final List<Widget> children;

  @override
  State<LazyIndexedWidget> createState() => _LazyIndexedWidgetState();
}

class _LazyIndexedWidgetState extends State<LazyIndexedWidget> {
  late List<bool> _shouldBuildView;
  late List<Widget> _children;

  static const SizedBox _emptyWidget = SizedBox.shrink();

  @override
  void initState() {
    super.initState();
    _initializeBuildFlags();
    _initializeChildren();
  }

  @override
  void didUpdateWidget(LazyIndexedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.children.length != widget.children.length) {
      _initializeBuildFlags();
      _initializeChildren();
    } else {
      _updateBuildFlag();
    }
  }

  void _initializeBuildFlags() {
    final safeIndex = _getSafeIndex();
    _shouldBuildView = List.generate(
      widget.children.length,
          (index) => index == safeIndex,
    );
  }

  void _initializeChildren() {
    _children = List.generate(
      widget.children.length,
          (index) => _shouldBuildView[index] ? widget.children[index] : _emptyWidget,
    );
  }

  void _updateBuildFlag() {
    final safeIndex = _getSafeIndex();
    if (safeIndex < _shouldBuildView.length) {
      setState(() {
        _shouldBuildView[safeIndex] = true;
        _children[safeIndex] = widget.children[safeIndex];
      });
    }
  }

  int _getSafeIndex() {
    // Ensure index is within bounds
    return widget.index.clamp(0, widget.children.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _getSafeIndex(),
      children: _children,
    );
  }
}
