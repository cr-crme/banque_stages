import 'package:flutter/material.dart';

class StickyHeadExpansionPanel {
  final bool isExpanded;
  final Widget Function(BuildContext context, Key key, bool isExpanded)
  headerBuilder;
  final Widget child;

  StickyHeadExpansionPanel({
    required this.headerBuilder,
    required this.child,
    required this.isExpanded,
  });
}

class StickyHeadExpansionPanelList extends StatefulWidget {
  const StickyHeadExpansionPanelList({
    super.key,
    required this.outerScrollController,
    required this.headerStickyTarget,
    required this.headerHeight,
    required this.expansionCallback,
    required this.children,
  });

  final ScrollController outerScrollController;
  final double headerStickyTarget;
  final double headerHeight;
  final ExpansionPanelCallback expansionCallback;
  final List<StickyHeadExpansionPanel> children;

  @override
  State<StickyHeadExpansionPanelList> createState() =>
      _StickyHeadExpansionPanelListState();
}

enum _HeaderDirection { up, down, static }

class _StickyHeadExpansionPanelListState
    extends State<StickyHeadExpansionPanelList> {
  final _headerKey = GlobalKey();

  final ScrollController _innerScrollController = ScrollController();

  int _calls = 0;
  int _skipCount = 0;
  double? _headerPosition;
  _HeaderDirection _headerDirection = _HeaderDirection.down;
  void _handleScroll2() {
    setState(() {});
  }

  void _handleScroll() {
    print('Calls #${++_calls} (skipCount: $_skipCount)');
    if (_skipCount > 0) {
      _skipCount--;
      return;
    }

    if (!widget.children[0].isExpanded || _headerKey.currentContext == null) {
      _headerPosition = null;
      return;
    }

    // Get the position of the header relative to the screen
    final box = _headerKey.currentContext!.findRenderObject() as RenderBox;
    final newHeaderPosition = box.localToGlobal(Offset.zero).dy;
    _headerDirection =
        newHeaderPosition == (_headerPosition ?? 0)
            ? _HeaderDirection.static
            : (newHeaderPosition > (_headerPosition ?? 0)
                ? _HeaderDirection.down
                : _HeaderDirection.up);

    switch (_headerDirection) {
      case _HeaderDirection.static:
        // print('static');
        // _dealWithUpwardScrolling(_headerPosition!, newHeaderPosition);
        break;
      case _HeaderDirection.down:
        // print('down');
        break;
      case _HeaderDirection.up:
        // print('up');
        _dealWithUpwardScrolling(_headerPosition!, newHeaderPosition);
        break;
    }

    _headerPosition = newHeaderPosition;

    // setState(() {});
  }

  void _dealWithUpwardScrolling(double previousPosition, double newPosition) {
    if (previousPosition < widget.headerStickyTarget + widget.headerHeight &&
        _innerScrollController.offset <
            _innerScrollController.position.maxScrollExtent) {
      print('Sticky header (${newPosition - previousPosition})');
      _skipCount += 1;
      final diff = widget.headerStickyTarget - newPosition;

      widget.outerScrollController.jumpTo(
        widget.outerScrollController.offset - diff,
      );
      //_innerScrollController.jumpTo(_innerScrollController.offset + diff);
    } else {
      // // In between the sticky target
      // print('Moving header');
      // widget.outerScrollController.jumpTo(widget.outerScrollController.offset);
    }
  }

  @override
  void initState() {
    super.initState();

    widget.outerScrollController.addListener(_handleScroll2);
    _innerScrollController.addListener(_handleScroll2);
  }

  @override
  void didUpdateWidget(covariant StickyHeadExpansionPanelList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // // Make sure not to add multiple listeners
    // widget.outerScrollController.removeListener(_handleScroll);
    // _innerScrollController.removeListener(_handleScroll);

    // // Add listeners to the scroll controllers
    // widget.outerScrollController.addListener(_handleScroll);
    // _innerScrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    widget.outerScrollController.removeListener(_handleScroll2);
    _innerScrollController.removeListener(_handleScroll2);
    _innerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _handleScroll();
    print('Build');
    return ExpansionPanelList(
      expansionCallback: widget.expansionCallback,
      children:
          widget.children
              .map(
                (sticky) => ExpansionPanel(
                  headerBuilder:
                      (context, isExpanded) =>
                          sticky.headerBuilder(context, _headerKey, isExpanded),
                  body: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4,
                    ),
                    child: SingleChildScrollView(
                      controller: _innerScrollController,
                      child: sticky.child,
                    ),
                  ),
                  isExpanded: sticky.isExpanded,
                ),
              )
              .toList(),
    );
  }
}
