import 'package:flutter/material.dart';

class StickyHeadExpansionPanel {
  final bool isExpanded;
  final bool canTapOnHeader;
  final Widget Function(BuildContext context, Key key, bool isExpanded)
  headerBuilder;
  final Widget body;

  StickyHeadExpansionPanel({
    required this.headerBuilder,
    required this.isExpanded,
    this.canTapOnHeader = false,
    required this.body,
  });
}

class StickyHeadExpansionPanelList extends StatefulWidget {
  const StickyHeadExpansionPanelList({
    super.key,
    required this.outerScrollController,
    required this.headerTarget,
    this.scrollHeight = 80,
    required this.expansionCallback,
    this.elevation,
    required this.children,
  });

  final double? elevation;
  final ScrollController outerScrollController;
  final double headerTarget;
  final double scrollHeight;
  final ExpansionPanelCallback expansionCallback;
  final List<StickyHeadExpansionPanel> children;

  @override
  State<StickyHeadExpansionPanelList> createState() =>
      _StickyHeadExpansionPanelListState();
}

class _StickyHeadExpansionPanelListState
    extends State<StickyHeadExpansionPanelList> {
  final _headerKey = GlobalKey();

  final ScrollController _innerScrollController = ScrollController();

  double get _getHeaderPosition {
    final box = _headerKey.currentContext!.findRenderObject() as RenderBox;
    return box.localToGlobal(Offset.zero).dy;
  }

  double _prevOuter = 0;
  double _prevInner = 0;
  Future<void> _handleScroll() async {
    // First, get the size of the scrolling
    final outerDiff = widget.outerScrollController.offset - _prevOuter;
    final innerDiff = _innerScrollController.offset - _prevInner;
    // No change in scroll position
    if (outerDiff == 0 && innerDiff == 0) return;

    // Immediately reset the scroll positions
    if (outerDiff != 0) {
      _prevOuter = widget.outerScrollController.offset - outerDiff;
      widget.outerScrollController.jumpTo(_prevOuter);
    } else if (innerDiff != 0) {
      _prevInner = _innerScrollController.offset - innerDiff;
      _innerScrollController.jumpTo(_prevInner);
    }
    // Wait for the scroll callback to be done
    await Future.delayed(Duration.zero);

    // Compute the actual diff to perform
    final headerPosition = _getHeaderPosition;
    double diff = outerDiff + innerDiff;

    if ((headerPosition < widget.headerTarget + widget.scrollHeight / 2) &&
        (headerPosition > widget.headerTarget - widget.scrollHeight / 2) &&
        (_prevInner + diff >= 0) &&
        (_prevInner + diff <=
            _innerScrollController.position.maxScrollExtent)) {
      // If the header is between the sticky target, move the inner scroll
      _prevInner += diff;
      _innerScrollController.jumpTo(_prevInner);
      _prevOuter += (headerPosition - widget.headerTarget);
      widget.outerScrollController.jumpTo(_prevOuter);
    } else {
      // If the header is not between the sticky target, move the outer scroll
      _prevOuter += diff;
      widget.outerScrollController.jumpTo(_prevOuter);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    widget.outerScrollController.addListener(_handleScroll);
    _innerScrollController.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(covariant StickyHeadExpansionPanelList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Make sure not to add multiple listeners
    widget.outerScrollController.removeListener(_handleScroll);
    _innerScrollController.removeListener(_handleScroll);

    // Add listeners to the scroll controllers
    widget.outerScrollController.addListener(_handleScroll);
    _innerScrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    widget.outerScrollController.removeListener(_handleScroll);
    _innerScrollController.removeListener(_handleScroll);
    _innerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      elevation: widget.elevation ?? 2,
      expansionCallback: widget.expansionCallback,
      children:
          widget.children
              .map(
                (sticky) => ExpansionPanel(
                  headerBuilder:
                      (context, isExpanded) =>
                          sticky.headerBuilder(context, _headerKey, isExpanded),
                  canTapOnHeader: sticky.canTapOnHeader,
                  isExpanded: sticky.isExpanded,
                  body: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight:
                          MediaQuery.of(context).size.height -
                          widget.headerTarget,
                    ),
                    child: SingleChildScrollView(
                      controller: _innerScrollController,
                      child: sticky.body,
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}
