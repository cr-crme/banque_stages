import 'package:flutter/material.dart';

enum ScreenSize {
  small,
  medium,
  large;

  static ScreenSize fromWidth(double width) {
    if (width < ResponsiveService.smallScreenWidth) {
      return ScreenSize.small;
    } else if (width >= ResponsiveService.smallScreenWidth &&
        width < ResponsiveService.largeScreenWidth) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.large;
    }
  }

  bool operator <(ScreenSize other) {
    return index < other.index;
  }

  bool operator >(ScreenSize other) {
    return index > other.index;
  }

  bool operator <=(ScreenSize other) {
    return index <= other.index;
  }

  bool operator >=(ScreenSize other) {
    return index >= other.index;
  }
}

class ResponsiveService {
  // Define the breakpoints
  static final smallScreenWidth = 600.0;
  static final largeScreenWidth = 1024.0;
  static final maxBodyWidth = 800.0;

  // Method to check if the current screen size is mobile
  static ScreenSize getScreenSize(BuildContext context) {
    return ScreenSize.fromWidth(MediaQuery.of(context).size.width);
  }

  static void popOf(BuildContext context) {
    if (ResponsiveService.getScreenSize(context) != ScreenSize.small) return;
    if (!Navigator.canPop(context)) return;

    Navigator.of(context).pop();
  }

  static Scaffold scaffoldOf(
    BuildContext context, {
    PreferredSizeWidget? appBar,
    Widget? smallDrawer,
    Widget? mediumDrawer,
    Widget? largeDrawer,
    required Widget body,
  }) {
    final screenSize = ResponsiveService.getScreenSize(context);

    return Scaffold(
      appBar: appBar,
      drawer:
          smallDrawer != null && screenSize == ScreenSize.small
              ? smallDrawer
              : null,
      body: switch (screenSize) {
        ScreenSize.small => body,
        ScreenSize.medium =>
          mediumDrawer != null
              ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  mediumDrawer,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: body,
                    ),
                  ),
                ],
              )
              : body,
        ScreenSize.large =>
          largeDrawer != null
              ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  largeDrawer,
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < maxBodyWidth) return body;
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                (constraints.maxWidth - maxBodyWidth) / 2,
                          ),
                          child: body,
                        );
                      },
                    ),
                  ),
                ],
              )
              : body,
      },
    );
  }

  static PreferredSizeWidget appBarOf(
    BuildContext context, {
    Widget? title,
    List<Widget>? actions,
    Widget? leading,
    PreferredSizeWidget? bottom,
  }) {
    return AppBar(
      title: title,
      actions: actions,
      leadingWidth:
          ResponsiveService.getScreenSize(context) == ScreenSize.small
              ? null
              : 0,
      leading:
          (ResponsiveService.getScreenSize(context) == ScreenSize.small
              ? leading
              : SizedBox.shrink()),
      bottom: bottom,
    );
  }
}
