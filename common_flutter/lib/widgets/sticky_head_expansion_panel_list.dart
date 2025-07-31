import 'package:flutter/gestures.dart';
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

class _StickyHeadExpansionPanelListState
    extends State<StickyHeadExpansionPanelList> {
  final _headerKey = GlobalKey();

  final ScrollController _innerScrollController = ScrollController();

  double get _headerOffset {
    if (_headerKey.currentContext == null) return 0.0;

    // Get the position of the header relative to the screen
    final box = _headerKey.currentContext!.findRenderObject() as RenderBox;
    return box.localToGlobal(Offset.zero).dy;
  }

  @override
  void initState() {
    super.initState();
    //widget.outerScrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    //widget.outerScrollController.removeListener(_handleScroll);
    _innerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.headerStickyTarget;
    final height = widget.headerHeight;

    return ExpansionPanelList(
      expansionCallback: widget.expansionCallback,
      children:
          widget.children
              .map(
                (sticky) => ExpansionPanel(
                  headerBuilder:
                      (context, isExpanded) =>
                          sticky.headerBuilder(context, _headerKey, isExpanded),
                  body: Listener(
                    onPointerSignal: (event) {
                      // Transfer scroll to inner controller only if header is at top
                      if (event is PointerScrollEvent) {
                        final futureOffset = _headerOffset;
                        print(
                          'Future Offset: $futureOffset, Target: $target, Header Offset: ${event.scrollDelta.dy}',
                        );

                        return;

                        final duration = Duration(milliseconds: 100);
                        final curve = Curves.easeInOut;

                        if (futureOffset >= target - height &&
                            futureOffset <= target + height) {
                          _innerScrollController.animateTo(
                            _innerScrollController.offset +
                                event.scrollDelta.dy,
                            duration: duration,
                            curve: curve,
                          );
                          widget.outerScrollController.jumpTo(
                            widget.outerScrollController.offset -
                                (target - _headerOffset),
                          );
                        } else {
                          if (futureOffset < target - height) {
                            _innerScrollController.jumpTo(
                              _innerScrollController.position.maxScrollExtent,
                            );
                          } else if (futureOffset > target + height) {
                            _innerScrollController.jumpTo(
                              _innerScrollController.position.minScrollExtent,
                            );
                          }
                          widget.outerScrollController.animateTo(
                            widget.outerScrollController.offset +
                                event.scrollDelta.dy,
                            duration: duration,
                            curve: curve,
                          );
                        }
                      }
                    },
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.6,
                      ),
                      child: SingleChildScrollView(
                        controller: _innerScrollController,
                        child: sticky.child,
                      ),
                    ),
                  ),
                  isExpanded: sticky.isExpanded,
                ),
              )
              .toList(),
    );
  }
}
