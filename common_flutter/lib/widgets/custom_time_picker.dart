// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// Examples can assume:
// late BuildContext context;

const Duration _kDialogSizeAnimationDuration = Duration(milliseconds: 200);
const Duration _kDialAnimateDuration = Duration(milliseconds: 200);
const double _kTwoPi = 2 * math.pi;
const Duration _kVibrateCommitDelay = Duration(milliseconds: 100);

const double _kTimePickerHeaderLandscapeWidth = 216;
const double _kTimePickerInnerDialOffset = 28;
const double _kTimePickerDialMinRadius = 50;
const double _kTimePickerDialPadding = 28;

/// Interactive input mode of the time picker dialog.
///
/// In [TimePickerEntryMode.dial] mode, a clock dial is displayed and the user
/// taps or drags the time they wish to select. In TimePickerEntryMode.input]
/// mode, [TextField]s are displayed and the user types in the time they wish to
/// select.
///
/// See also:
///
/// * [showCustomTimePicker], a function that shows a [CustomTimePickerDialog] and returns
///   the selected time as a [Future].
enum TimePickerEntryMode {
  /// User picks time from a clock dial.
  ///
  /// Can switch to [input] by activating a mode button in the dialog.
  dial,

  /// User can input the time by typing it into text fields.
  ///
  /// Can switch to [dial] by activating a mode button in the dialog.
  input,

  /// User can only pick time from a clock dial.
  ///
  /// There is no user interface to switch to another mode.
  dialOnly,

  /// User can only input the time by typing it into text fields.
  ///
  /// There is no user interface to switch to another mode.
  inputOnly,
}

// Whether the dial-mode time picker is currently selecting the hour or the
// minute.
enum _HourMinuteMode { hour, minute }

// Aspects of _TimePickerModel that can be depended upon.
enum _TimePickerAspect {
  use24HourFormat,
  entryMode,
  hourMinuteMode,
  onHourMinuteModeChanged,
  onHourDoubleTapped,
  onMinuteDoubleTapped,
  hourDialType,
  selectedTime,
  onSelectedTimeChanged,
  orientation,
  theme,
  defaultTheme,
}

class _TimePickerModel extends InheritedModel<_TimePickerAspect> {
  const _TimePickerModel({
    required this.entryMode,
    required this.hourMinuteMode,
    required this.onHourMinuteModeChanged,
    required this.onHourDoubleTapped,
    required this.onMinuteDoubleTapped,
    required this.selectedTime,
    required this.onSelectedTimeChanged,
    required this.use24HourFormat,
    required this.hourDialType,
    required this.orientation,
    required this.theme,
    required this.defaultTheme,
    required super.child,
  });

  final TimePickerEntryMode entryMode;
  final _HourMinuteMode hourMinuteMode;
  final ValueChanged<_HourMinuteMode> onHourMinuteModeChanged;
  final GestureTapCallback onHourDoubleTapped;
  final GestureTapCallback onMinuteDoubleTapped;
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay> onSelectedTimeChanged;
  final bool use24HourFormat;
  final _HourDialType hourDialType;
  final Orientation orientation;
  final TimePickerThemeData theme;
  final _TimePickerDefaults defaultTheme;

  static _TimePickerModel of(
    BuildContext context, [
    _TimePickerAspect? aspect,
  ]) => InheritedModel.inheritFrom<_TimePickerModel>(context, aspect: aspect)!;
  static TimePickerEntryMode entryModeOf(BuildContext context) =>
      of(context, _TimePickerAspect.entryMode).entryMode;
  static _HourMinuteMode hourMinuteModeOf(BuildContext context) =>
      of(context, _TimePickerAspect.hourMinuteMode).hourMinuteMode;
  static TimeOfDay selectedTimeOf(BuildContext context) =>
      of(context, _TimePickerAspect.selectedTime).selectedTime;
  static bool use24HourFormatOf(BuildContext context) =>
      of(context, _TimePickerAspect.use24HourFormat).use24HourFormat;
  static _HourDialType hourDialTypeOf(BuildContext context) =>
      of(context, _TimePickerAspect.hourDialType).hourDialType;
  static Orientation orientationOf(BuildContext context) =>
      of(context, _TimePickerAspect.orientation).orientation;
  static TimePickerThemeData themeOf(BuildContext context) =>
      of(context, _TimePickerAspect.theme).theme;
  static _TimePickerDefaults defaultThemeOf(BuildContext context) =>
      of(context, _TimePickerAspect.defaultTheme).defaultTheme;

  static void setSelectedTime(BuildContext context, TimeOfDay value) => of(
    context,
    _TimePickerAspect.onSelectedTimeChanged,
  ).onSelectedTimeChanged(value);
  // coverage:ignore-start
  static void setHourMinuteMode(BuildContext context, _HourMinuteMode value) =>
      of(
        context,
        _TimePickerAspect.onHourMinuteModeChanged,
      ).onHourMinuteModeChanged(value);
  // coverage:ignore-end

  @override
  bool updateShouldNotifyDependent(
    _TimePickerModel oldWidget,
    Set<_TimePickerAspect> dependencies,
  ) {
    // coverage:ignore-start
    if (use24HourFormat != oldWidget.use24HourFormat &&
        dependencies.contains(_TimePickerAspect.use24HourFormat)) {
      return true;
    }
    if (entryMode != oldWidget.entryMode &&
        dependencies.contains(_TimePickerAspect.entryMode)) {
      return true;
    }
    if (hourMinuteMode != oldWidget.hourMinuteMode &&
        dependencies.contains(_TimePickerAspect.hourMinuteMode)) {
      return true;
    }
    if (onHourMinuteModeChanged != oldWidget.onHourMinuteModeChanged &&
        dependencies.contains(_TimePickerAspect.onHourMinuteModeChanged)) {
      return true;
    }
    if (onHourMinuteModeChanged != oldWidget.onHourDoubleTapped &&
        dependencies.contains(_TimePickerAspect.onHourDoubleTapped)) {
      return true;
    }
    if (onHourMinuteModeChanged != oldWidget.onMinuteDoubleTapped &&
        dependencies.contains(_TimePickerAspect.onMinuteDoubleTapped)) {
      return true;
    }
    if (hourDialType != oldWidget.hourDialType &&
        dependencies.contains(_TimePickerAspect.hourDialType)) {
      return true;
    }
    if (selectedTime != oldWidget.selectedTime &&
        dependencies.contains(_TimePickerAspect.selectedTime)) {
      return true;
    }
    if (onSelectedTimeChanged != oldWidget.onSelectedTimeChanged &&
        dependencies.contains(_TimePickerAspect.onSelectedTimeChanged)) {
      return true;
    }
    if (orientation != oldWidget.orientation &&
        dependencies.contains(_TimePickerAspect.orientation)) {
      return true;
    }
    if (theme != oldWidget.theme &&
        dependencies.contains(_TimePickerAspect.theme)) {
      return true;
    }
    if (defaultTheme != oldWidget.defaultTheme &&
        dependencies.contains(_TimePickerAspect.defaultTheme)) {
      return true;
    }
    return false;
    // coverage:ignore-end
  }

  @override
  bool updateShouldNotify(_TimePickerModel oldWidget) {
    return use24HourFormat != oldWidget.use24HourFormat ||
        entryMode != oldWidget.entryMode ||
        hourMinuteMode != oldWidget.hourMinuteMode ||
        onHourMinuteModeChanged != oldWidget.onHourMinuteModeChanged ||
        onHourDoubleTapped != oldWidget.onHourDoubleTapped ||
        onMinuteDoubleTapped != oldWidget.onMinuteDoubleTapped ||
        hourDialType != oldWidget.hourDialType ||
        selectedTime != oldWidget.selectedTime ||
        onSelectedTimeChanged != oldWidget.onSelectedTimeChanged ||
        orientation != oldWidget.orientation ||
        theme != oldWidget.theme ||
        defaultTheme != oldWidget.defaultTheme;
  }
}

class _TimePickerHeader extends StatelessWidget {
  const _TimePickerHeader({required this.helpText});

  final String helpText;

  @override
  Widget build(BuildContext context) {
    final TimeOfDayFormat timeOfDayFormat = MaterialLocalizations.of(
      context,
    ).timeOfDayFormat(
      alwaysUse24HourFormat: _TimePickerModel.use24HourFormatOf(context),
    );

    final _HourDialType hourDialType = _TimePickerModel.hourDialTypeOf(context);
    switch (_TimePickerModel.orientationOf(context)) {
      // coverage:ignore-start
      case Orientation.portrait:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 24),
              child: Text(
                helpText,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Row(
              children: <Widget>[
                if (hourDialType == _HourDialType.twelveHour &&
                    timeOfDayFormat == TimeOfDayFormat.a_space_h_colon_mm)
                  const _DayPeriodControl(),
                Expanded(
                  child: Row(
                    // Hour/minutes should not change positions in RTL locales.
                    textDirection: TextDirection.ltr,
                    children: <Widget>[
                      const Expanded(child: _HourControl()),
                      _StringFragment(timeOfDayFormat: timeOfDayFormat),
                      const Expanded(child: _MinuteControl()),
                    ],
                  ),
                ),
                if (hourDialType == _HourDialType.twelveHour &&
                    timeOfDayFormat !=
                        TimeOfDayFormat.a_space_h_colon_mm) ...<Widget>[
                  const SizedBox(width: 12),
                  const _DayPeriodControl(),
                ],
              ],
            ),
          ],
        );
      // coverage:ignore-end
      case Orientation.landscape:
        return SizedBox(
          width: _kTimePickerHeaderLandscapeWidth,
          child: Stack(
            children: <Widget>[
              Text(helpText, style: Theme.of(context).textTheme.titleMedium),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // coverage:ignore-start
                  if (hourDialType == _HourDialType.twelveHour &&
                      timeOfDayFormat == TimeOfDayFormat.a_space_h_colon_mm)
                    const _DayPeriodControl(),
                  // coverage:ignore-end
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: hourDialType == _HourDialType.twelveHour ? 12 : 0,
                    ),
                    child: Row(
                      // Hour/minutes should not change positions in RTL locales.
                      textDirection: TextDirection.ltr,
                      children: <Widget>[
                        const Expanded(child: _HourControl()),
                        _StringFragment(timeOfDayFormat: timeOfDayFormat),
                        const Expanded(child: _MinuteControl()),
                      ],
                    ),
                  ),
                  // coverage:ignore-start
                  if (hourDialType == _HourDialType.twelveHour &&
                      timeOfDayFormat != TimeOfDayFormat.a_space_h_colon_mm)
                    const _DayPeriodControl(),
                  // coverage:ignore-end
                ],
              ),
            ],
          ),
        );
    }
  }
}

class _HourMinuteControl extends StatelessWidget {
  const _HourMinuteControl({
    required this.text,
    required this.onTap,
    required this.onDoubleTap,
    required this.isSelected,
  });

  final String text;
  final GestureTapCallback onTap;
  final GestureTapCallback onDoubleTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final TimePickerThemeData timePickerTheme = _TimePickerModel.themeOf(
      context,
    );
    final _TimePickerDefaults defaultTheme = _TimePickerModel.defaultThemeOf(
      context,
    );
    final Color backgroundColor =
        timePickerTheme.hourMinuteColor ?? defaultTheme.hourMinuteColor;
    final ShapeBorder shape =
        timePickerTheme.hourMinuteShape ?? defaultTheme.hourMinuteShape;

    final Set<WidgetState> states = <WidgetState>{
      if (isSelected) WidgetState.selected,
    };
    final Color effectiveTextColor = WidgetStateProperty.resolveAs<Color>(
      _TimePickerModel.themeOf(context).hourMinuteTextColor ??
          _TimePickerModel.defaultThemeOf(context).hourMinuteTextColor,
      states,
    );
    final TextStyle effectiveStyle = WidgetStateProperty.resolveAs<TextStyle>(
      timePickerTheme.hourMinuteTextStyle ?? defaultTheme.hourMinuteTextStyle,
      states,
    ).copyWith(color: effectiveTextColor);

    final double height;
    switch (_TimePickerModel.entryModeOf(context)) {
      case TimePickerEntryMode.dial:
      case TimePickerEntryMode.dialOnly: // coverage:ignore-line
        height = defaultTheme.hourMinuteSize.height;
        break;
      // coverage:ignore-start
      case TimePickerEntryMode.input:
      case TimePickerEntryMode.inputOnly:
        height = defaultTheme.hourMinuteInputSize.height;
        break;
      // coverage:ignore-end
    }

    return SizedBox(
      height: height,
      child: Material(
        color: WidgetStateProperty.resolveAs(backgroundColor, states),
        clipBehavior: Clip.antiAlias,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          onDoubleTap: isSelected ? onDoubleTap : null,
          child: Center(
            child: Text(
              text,
              style: effectiveStyle,
              textScaler: TextScaler.noScaling,
            ),
          ),
        ),
      ),
    );
  }
}

/// Displays the hour fragment.
///
/// When tapped changes time picker dial mode to [_HourMinuteMode.hour].
class _HourControl extends StatelessWidget {
  const _HourControl();

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final bool alwaysUse24HourFormat = MediaQuery.alwaysUse24HourFormatOf(
      context,
    );
    final TimeOfDay selectedTime = _TimePickerModel.selectedTimeOf(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final String formattedHour = localizations.formatHour(
      selectedTime,
      alwaysUse24HourFormat: _TimePickerModel.use24HourFormatOf(context),
    );

    TimeOfDay hoursFromSelected(int hoursToAdd) {
      switch (_TimePickerModel.hourDialTypeOf(context)) {
        case _HourDialType.twentyFourHour:
        case _HourDialType.twentyFourHourDoubleRing: // coverage:ignore-line
          final int selectedHour = selectedTime.hour;
          return selectedTime.replacing(
            hour: (selectedHour + hoursToAdd) % TimeOfDay.hoursPerDay,
          );
        // coverage:ignore-start
        case _HourDialType.twelveHour:
          // Cycle 1 through 12 without changing day period.
          final int periodOffset = selectedTime.periodOffset;
          final int hours = selectedTime.hourOfPeriod;
          return selectedTime.replacing(
            hour:
                periodOffset + (hours + hoursToAdd) % TimeOfDay.hoursPerPeriod,
          );
        // coverage:ignore-end
      }
    }

    final TimeOfDay nextHour = hoursFromSelected(1);
    final String formattedNextHour = localizations.formatHour(
      nextHour,
      alwaysUse24HourFormat: alwaysUse24HourFormat,
    );
    final TimeOfDay previousHour = hoursFromSelected(-1);
    final String formattedPreviousHour = localizations.formatHour(
      previousHour,
      alwaysUse24HourFormat: alwaysUse24HourFormat,
    );

    return Semantics(
      value: '${localizations.timePickerHourModeAnnouncement} $formattedHour',
      excludeSemantics: true,
      increasedValue: formattedNextHour,
      // coverage:ignore-start
      onIncrease: () {
        _TimePickerModel.setSelectedTime(context, nextHour);
      },
      decreasedValue: formattedPreviousHour,
      onDecrease: () {
        _TimePickerModel.setSelectedTime(context, previousHour);
      },
      // coverage:ignore-end
      child: _HourMinuteControl(
        isSelected:
            _TimePickerModel.hourMinuteModeOf(context) == _HourMinuteMode.hour,
        text: formattedHour,
        // coverage:ignore-start
        onTap:
            Feedback.wrapForTap(
              () => _TimePickerModel.setHourMinuteMode(
                context,
                _HourMinuteMode.hour,
              ),
              context,
            )!,
        // coverage:ignore-end
        onDoubleTap:
            _TimePickerModel.of(
              context,
              _TimePickerAspect.onHourDoubleTapped,
            ).onHourDoubleTapped,
      ),
    );
  }
}

/// A passive fragment showing a string value.
///
/// Used to display the appropriate separator between the input fields.
class _StringFragment extends StatelessWidget {
  const _StringFragment({required this.timeOfDayFormat});

  final TimeOfDayFormat timeOfDayFormat;

  String _stringFragmentValue(TimeOfDayFormat timeOfDayFormat) {
    switch (timeOfDayFormat) {
      case TimeOfDayFormat.h_colon_mm_space_a:
      case TimeOfDayFormat.a_space_h_colon_mm:
      case TimeOfDayFormat.H_colon_mm:
      case TimeOfDayFormat.HH_colon_mm:
        return ':';
      case TimeOfDayFormat.HH_dot_mm:
        return '.';
      case TimeOfDayFormat.frenchCanadian:
        return 'h';
    }
  }

  @override
  Widget build(BuildContext context) {
    final TimePickerThemeData timePickerTheme = TimePickerTheme.of(context);
    final _TimePickerDefaults defaultTheme = _TimePickerDefaultsM2(context);
    final Set<WidgetState> states = <WidgetState>{};

    final Color effectiveTextColor = WidgetStateProperty.resolveAs<Color>(
      timePickerTheme.hourMinuteTextColor ?? defaultTheme.hourMinuteTextColor,
      states,
    );
    final TextStyle effectiveStyle = WidgetStateProperty.resolveAs<TextStyle>(
      timePickerTheme.hourMinuteTextStyle ?? defaultTheme.hourMinuteTextStyle,
      states,
    ).copyWith(color: effectiveTextColor);

    final double height;
    switch (_TimePickerModel.entryModeOf(context)) {
      case TimePickerEntryMode.dial:
      case TimePickerEntryMode.dialOnly:
        height = defaultTheme.hourMinuteSize.height;
        break;
      case TimePickerEntryMode.input:
      case TimePickerEntryMode.inputOnly: // coverage:ignore-line
        height = defaultTheme.hourMinuteInputSize.height;
        break;
    }

    return ExcludeSemantics(
      child: SizedBox(
        width: timeOfDayFormat == TimeOfDayFormat.frenchCanadian ? 36 : 24,
        height: height,
        child: Center(
          child: Text(
            _stringFragmentValue(timeOfDayFormat),
            style: effectiveStyle,
            textScaler: TextScaler.noScaling,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Displays the minute fragment.
///
/// When tapped changes time picker dial mode to [_HourMinuteMode.minute].
class _MinuteControl extends StatelessWidget {
  const _MinuteControl();

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final TimeOfDay selectedTime = _TimePickerModel.selectedTimeOf(context);
    final String formattedMinute = localizations.formatMinute(selectedTime);
    final TimeOfDay nextMinute = selectedTime.replacing(
      minute: (selectedTime.minute + 1) % TimeOfDay.minutesPerHour,
    );
    final String formattedNextMinute = localizations.formatMinute(nextMinute);
    final TimeOfDay previousMinute = selectedTime.replacing(
      minute: (selectedTime.minute - 1) % TimeOfDay.minutesPerHour,
    );
    final String formattedPreviousMinute = localizations.formatMinute(
      previousMinute,
    );

    return Semantics(
      excludeSemantics: true,
      value:
          '${localizations.timePickerMinuteModeAnnouncement} $formattedMinute',
      increasedValue: formattedNextMinute,
      // coverage:ignore-start
      onIncrease: () {
        _TimePickerModel.setSelectedTime(context, nextMinute);
      },
      decreasedValue: formattedPreviousMinute,
      onDecrease: () {
        _TimePickerModel.setSelectedTime(context, previousMinute);
      },
      // coverage:ignore-end
      child: _HourMinuteControl(
        isSelected:
            _TimePickerModel.hourMinuteModeOf(context) ==
            _HourMinuteMode.minute,
        text: formattedMinute,
        // coverage:ignore-start
        onTap:
            Feedback.wrapForTap(
              () => _TimePickerModel.setHourMinuteMode(
                context,
                _HourMinuteMode.minute,
              ),
              context,
            )!,
        // coverage:ignore-end
        onDoubleTap:
            _TimePickerModel.of(
              context,
              _TimePickerAspect.onMinuteDoubleTapped,
            ).onMinuteDoubleTapped,
      ),
    );
  }
}

// coverage:ignore-start
/// Displays the am/pm fragment and provides controls for switching between am
/// and pm.
class _DayPeriodControl extends StatelessWidget {
  const _DayPeriodControl({this.onPeriodChanged});

  final ValueChanged<TimeOfDay>? onPeriodChanged;

  void _togglePeriod(BuildContext context) {
    final TimeOfDay selectedTime = _TimePickerModel.selectedTimeOf(context);
    final int newHour =
        (selectedTime.hour + TimeOfDay.hoursPerPeriod) % TimeOfDay.hoursPerDay;
    final TimeOfDay newTime = selectedTime.replacing(hour: newHour);
    if (onPeriodChanged != null) {
      onPeriodChanged!.call(newTime);
    } else {
      _TimePickerModel.setSelectedTime(context, newTime);
    }
  }

  void _setAm(BuildContext context) {
    final TimeOfDay selectedTime = _TimePickerModel.selectedTimeOf(context);
    if (selectedTime.period == DayPeriod.am) {
      return;
    }
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _announceToAccessibility(
          context,
          MaterialLocalizations.of(context).anteMeridiemAbbreviation,
        );
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
    _togglePeriod(context);
  }

  void _setPm(BuildContext context) {
    final TimeOfDay selectedTime = _TimePickerModel.selectedTimeOf(context);
    if (selectedTime.period == DayPeriod.pm) {
      return;
    }
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _announceToAccessibility(
          context,
          MaterialLocalizations.of(context).postMeridiemAbbreviation,
        );
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
    _togglePeriod(context);
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations materialLocalizations =
        MaterialLocalizations.of(context);
    final TimePickerThemeData timePickerTheme = _TimePickerModel.themeOf(
      context,
    );
    final _TimePickerDefaults defaultTheme = _TimePickerModel.defaultThemeOf(
      context,
    );
    final TimeOfDay selectedTime = _TimePickerModel.selectedTimeOf(context);
    final bool amSelected = selectedTime.period == DayPeriod.am;
    final bool pmSelected = !amSelected;
    final BorderSide resolvedSide =
        timePickerTheme.dayPeriodBorderSide ?? defaultTheme.dayPeriodBorderSide;
    final OutlinedBorder resolvedShape = (timePickerTheme.dayPeriodShape ??
            defaultTheme.dayPeriodShape)
        .copyWith(side: resolvedSide);

    final Widget amButton = _AmPmButton(
      selected: amSelected,
      onPressed: () => _setAm(context),
      label: materialLocalizations.anteMeridiemAbbreviation,
    );

    final Widget pmButton = _AmPmButton(
      selected: pmSelected,
      onPressed: () => _setPm(context),
      label: materialLocalizations.postMeridiemAbbreviation,
    );

    Size dayPeriodSize;
    final Orientation orientation;
    switch (_TimePickerModel.entryModeOf(context)) {
      case TimePickerEntryMode.dial:
      case TimePickerEntryMode.dialOnly:
        orientation = _TimePickerModel.orientationOf(context);
        switch (orientation) {
          case Orientation.portrait:
            dayPeriodSize = defaultTheme.dayPeriodPortraitSize;
            break;
          case Orientation.landscape:
            dayPeriodSize = defaultTheme.dayPeriodLandscapeSize;
            break;
        }
        break;
      case TimePickerEntryMode.input:
      case TimePickerEntryMode.inputOnly:
        orientation = Orientation.portrait;
        dayPeriodSize = defaultTheme.dayPeriodInputSize;
        break;
    }

    final Widget result;
    switch (orientation) {
      case Orientation.portrait:
        result = _DayPeriodInputPadding(
          minSize: dayPeriodSize,
          orientation: orientation,
          child: SizedBox.fromSize(
            size: dayPeriodSize,
            child: Material(
              clipBehavior: Clip.antiAlias,
              color: Colors.transparent,
              shape: resolvedShape,
              child: Column(
                children: <Widget>[
                  Expanded(child: amButton),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(top: resolvedSide),
                    ),
                    height: 1,
                  ),
                  Expanded(child: pmButton),
                ],
              ),
            ),
          ),
        );
        break;
      case Orientation.landscape:
        result = _DayPeriodInputPadding(
          minSize: dayPeriodSize,
          orientation: orientation,
          child: SizedBox(
            height: dayPeriodSize.height,
            child: Material(
              clipBehavior: Clip.antiAlias,
              color: Colors.transparent,
              shape: resolvedShape,
              child: Row(
                children: <Widget>[
                  Expanded(child: amButton),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(left: resolvedSide),
                    ),
                    width: 1,
                  ),
                  Expanded(child: pmButton),
                ],
              ),
            ),
          ),
        );
        break;
    }
    return result;
  }
}
// coverage:ignore-end

// coverage:ignore-start
class _AmPmButton extends StatelessWidget {
  const _AmPmButton({
    required this.onPressed,
    required this.selected,
    required this.label,
  });

  final bool selected;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final Set<WidgetState> states = <WidgetState>{
      if (selected) WidgetState.selected,
    };
    final TimePickerThemeData timePickerTheme = _TimePickerModel.themeOf(
      context,
    );
    final _TimePickerDefaults defaultTheme = _TimePickerModel.defaultThemeOf(
      context,
    );
    final Color resolvedBackgroundColor = WidgetStateProperty.resolveAs<Color>(
      timePickerTheme.dayPeriodColor ?? defaultTheme.dayPeriodColor,
      states,
    );
    final Color resolvedTextColor = WidgetStateProperty.resolveAs<Color>(
      timePickerTheme.dayPeriodTextColor ?? defaultTheme.dayPeriodTextColor,
      states,
    );
    final TextStyle? resolvedTextStyle =
        WidgetStateProperty.resolveAs<TextStyle?>(
          timePickerTheme.dayPeriodTextStyle ?? defaultTheme.dayPeriodTextStyle,
          states,
        )?.copyWith(color: resolvedTextColor);
    final TextScaler buttonTextScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(maxScaleFactor: 2.0);

    return Material(
      color: resolvedBackgroundColor,
      child: InkWell(
        onTap: Feedback.wrapForTap(onPressed, context),
        child: Semantics(
          checked: selected,
          inMutuallyExclusiveGroup: true,
          button: true,
          child: Center(
            child: Text(
              label,
              style: resolvedTextStyle,
              textScaler: buttonTextScaler,
            ),
          ),
        ),
      ),
    );
  }
}
// coverage:ignore-end

// coverage:ignore-start
/// A widget to pad the area around the [_DayPeriodControl]'s inner [Material].
class _DayPeriodInputPadding extends SingleChildRenderObjectWidget {
  const _DayPeriodInputPadding({
    required Widget super.child,
    required this.minSize,
    required this.orientation,
  });

  final Size minSize;
  final Orientation orientation;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderInputPadding(minSize, orientation);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderInputPadding renderObject,
  ) {
    renderObject
      ..minSize = minSize
      ..orientation = orientation;
  }
}
// coverage:ignore-end

// coverage:ignore-start
class _RenderInputPadding extends RenderShiftedBox {
  _RenderInputPadding(this._minSize, this._orientation, [RenderBox? child])
    : super(child);

  Size get minSize => _minSize;
  Size _minSize;
  set minSize(Size value) {
    if (_minSize == value) {
      return;
    }
    _minSize = value;
    markNeedsLayout();
  }

  Orientation get orientation => _orientation;
  Orientation _orientation;
  set orientation(Orientation value) {
    if (_orientation == value) {
      return;
    }
    _orientation = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (child != null) {
      return math.max(child!.getMinIntrinsicWidth(height), minSize.width);
    }
    return 0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (child != null) {
      return math.max(child!.getMinIntrinsicHeight(width), minSize.height);
    }
    return 0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (child != null) {
      return math.max(child!.getMaxIntrinsicWidth(height), minSize.width);
    }
    return 0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (child != null) {
      return math.max(child!.getMaxIntrinsicHeight(width), minSize.height);
    }
    return 0;
  }

  Size _computeSize({
    required BoxConstraints constraints,
    required ChildLayouter layoutChild,
  }) {
    if (child != null) {
      final Size childSize = layoutChild(child!, constraints);
      final double width = math.max(childSize.width, minSize.width);
      final double height = math.max(childSize.height, minSize.height);
      return constraints.constrain(Size(width, height));
    }
    return Size.zero;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.dryLayoutChild,
    );
  }

  @override
  void performLayout() {
    size = _computeSize(
      constraints: constraints,
      layoutChild: ChildLayoutHelper.layoutChild,
    );
    if (child != null) {
      final BoxParentData childParentData = child!.parentData! as BoxParentData;
      childParentData.offset = Alignment.center.alongOffset(
        size - child!.size as Offset,
      );
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (super.hitTest(result, position: position)) {
      return true;
    }

    if (position.dx < 0 ||
        position.dx > math.max(child!.size.width, minSize.width) ||
        position.dy < 0 ||
        position.dy > math.max(child!.size.height, minSize.height)) {
      return false;
    }

    Offset newPosition = child!.size.center(Offset.zero);
    switch (orientation) {
      case Orientation.portrait:
        if (position.dy > newPosition.dy) {
          newPosition += const Offset(0, 1);
        } else {
          newPosition += const Offset(0, -1);
        }
        break;
      case Orientation.landscape:
        if (position.dx > newPosition.dx) {
          newPosition += const Offset(1, 0);
        } else {
          newPosition += const Offset(-1, 0);
        }
        break;
    }

    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(newPosition),
      position: newPosition,
      hitTest: (BoxHitTestResult result, Offset position) {
        assert(position == newPosition);
        return child!.hitTest(result, position: newPosition);
      },
    );
  }
}
// coverage:ignore-end

class _TappableLabel {
  _TappableLabel({
    required this.value,
    required this.inner,
    required this.painter,
    required this.onTap,
  });

  /// The value this label is displaying.
  final int value;

  /// This value is part of the "inner" ring of values on the dial, used for 24
  /// hour input.
  final bool inner;

  /// Paints the text of the label.
  final TextPainter painter;

  /// Called when a tap gesture is detected on the label.
  final VoidCallback onTap;
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.primaryLabels,
    required this.selectedLabels,
    required this.backgroundColor,
    required this.handColor,
    required this.handWidth,
    required this.dotColor,
    required this.dotRadius,
    required this.centerRadius,
    required this.theta,
    required this.radius,
    required this.textDirection,
    required this.selectedValue,
  }) : super(repaint: PaintingBinding.instance.systemFonts);

  final List<_TappableLabel> primaryLabels;
  final List<_TappableLabel> selectedLabels;
  final Color backgroundColor;
  final Color handColor;
  final double handWidth;
  final Color dotColor;
  final double dotRadius;
  final double centerRadius;
  final double theta;
  final double radius;
  final TextDirection textDirection;
  final int selectedValue;

  void dispose() {
    for (final _TappableLabel label in primaryLabels) {
      label.painter.dispose();
    }
    for (final _TappableLabel label in selectedLabels) {
      label.painter.dispose();
    }
    primaryLabels.clear();
    selectedLabels.clear();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double dialRadius = clampDouble(
      size.shortestSide / 2,
      _kTimePickerDialMinRadius + dotRadius,
      double.infinity,
    );
    final double labelRadius = clampDouble(
      dialRadius - _kTimePickerDialPadding,
      _kTimePickerDialMinRadius,
      double.infinity,
    );
    final double innerLabelRadius = clampDouble(
      labelRadius - _kTimePickerInnerDialOffset,
      0,
      double.infinity,
    );
    final double handleRadius = clampDouble(
      labelRadius - (radius < 0.5 ? 1 : 0) * (labelRadius - innerLabelRadius),
      _kTimePickerDialMinRadius,
      double.infinity,
    );
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Offset centerPoint = center;
    canvas.drawCircle(
      centerPoint,
      dialRadius,
      Paint()..color = backgroundColor,
    );

    Offset getOffsetForTheta(double theta, double radius) {
      return center +
          Offset(radius * math.cos(theta), -radius * math.sin(theta));
    }

    void paintLabels(List<_TappableLabel> labels, double radius) {
      if (labels.isEmpty) {
        return;
      }
      final double labelThetaIncrement = -_kTwoPi / labels.length;
      double labelTheta = math.pi / 2;

      for (final _TappableLabel label in labels) {
        final TextPainter labelPainter = label.painter;
        final Offset labelOffset = Offset(
          -labelPainter.width / 2,
          -labelPainter.height / 2,
        );
        labelPainter.paint(
          canvas,
          getOffsetForTheta(labelTheta, radius) + labelOffset,
        );
        labelTheta += labelThetaIncrement;
      }
    }

    void paintInnerOuterLabels(List<_TappableLabel>? labels) {
      if (labels == null) {
        return;
      }

      paintLabels(
        labels.where((_TappableLabel label) => !label.inner).toList(),
        labelRadius,
      );
      paintLabels(
        labels.where((_TappableLabel label) => label.inner).toList(),
        innerLabelRadius,
      );
    }

    paintInnerOuterLabels(primaryLabels);

    final Paint selectorPaint = Paint()..color = handColor;
    final Offset focusedPoint = getOffsetForTheta(theta, handleRadius);
    canvas.drawCircle(centerPoint, centerRadius, selectorPaint);
    canvas.drawCircle(focusedPoint, dotRadius, selectorPaint);
    selectorPaint.strokeWidth = handWidth;
    canvas.drawLine(centerPoint, focusedPoint, selectorPaint);

    // Add a dot inside the selector but only when it isn't over the labels.
    // This checks that the selector's theta is between two labels. A remainder
    // between 0.1 and 0.45 indicates that the selector is roughly not above any
    // labels. The values were derived by manually testing the dial.
    final double labelThetaIncrement = -_kTwoPi / primaryLabels.length;
    if (theta % labelThetaIncrement > 0.1 &&
        theta % labelThetaIncrement < 0.45) {
      canvas.drawCircle(focusedPoint, 2, selectorPaint..color = dotColor);
    }

    final Rect focusedRect = Rect.fromCircle(
      center: focusedPoint,
      radius: dotRadius,
    );
    canvas
      ..save()
      ..clipPath(Path()..addOval(focusedRect));
    paintInnerOuterLabels(selectedLabels);
    canvas.restore();
  }

  // coverage:ignore-start
  @override
  bool shouldRepaint(_DialPainter oldPainter) {
    return oldPainter.primaryLabels != primaryLabels ||
        oldPainter.selectedLabels != selectedLabels ||
        oldPainter.backgroundColor != backgroundColor ||
        oldPainter.handColor != handColor ||
        oldPainter.theta != theta;
  }

  // coverage:ignore-end
}

// Which kind of hour dial being presented.
enum _HourDialType { twentyFourHour, twentyFourHourDoubleRing, twelveHour }

class _Dial extends StatefulWidget {
  const _Dial({
    required this.selectedTime,
    required this.hourMinuteMode,
    required this.hourDialType,
    required this.onChanged,
    required this.onHourSelected,
  });

  final TimeOfDay selectedTime;
  final _HourMinuteMode hourMinuteMode;
  final _HourDialType hourDialType;
  final ValueChanged<TimeOfDay>? onChanged;
  final VoidCallback? onHourSelected;

  @override
  _DialState createState() => _DialState();
}

class _DialState extends State<_Dial> with SingleTickerProviderStateMixin {
  late ThemeData themeData;
  late MaterialLocalizations localizations;
  _DialPainter? painter;
  late AnimationController _animationController;
  late Tween<double> _thetaTween;
  late Animation<double> _theta;
  late Tween<double> _radiusTween;
  late Animation<double> _radius;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: _kDialAnimateDuration,
      vsync: this,
    );
    _thetaTween = Tween<double>(begin: _getThetaForTime(widget.selectedTime));
    _radiusTween = Tween<double>(begin: _getRadiusForTime(widget.selectedTime));
    _theta = _animationController
      .drive(CurveTween(curve: Easing.standard))
      .drive(_thetaTween)..addListener(
      () => setState(() {
        /* _theta.value has changed */
      }),
    );
    _radius = _animationController
      .drive(CurveTween(curve: Easing.standard))
      .drive(_radiusTween)..addListener(
      () => setState(() {
        /* _radius.value has changed */
      }),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(debugCheckHasMediaQuery(context));
    themeData = Theme.of(context);
    localizations = MaterialLocalizations.of(context);
  }

  // coverage:ignore-start
  @override
  void didUpdateWidget(_Dial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hourMinuteMode != oldWidget.hourMinuteMode ||
        widget.selectedTime != oldWidget.selectedTime) {
      if (!_dragging) {
        _animateTo(
          _getThetaForTime(widget.selectedTime),
          _getRadiusForTime(widget.selectedTime),
        );
      }
    }
  }
  // coverage:ignore-end

  @override
  void dispose() {
    _animationController.dispose();
    painter?.dispose();
    super.dispose();
  }

  // coverage:ignore-start
  static double _nearest(double target, double a, double b) {
    return ((target - a).abs() < (target - b).abs()) ? a : b;
  }
  // coverage:ignore-end

  // coverage:ignore-start
  void _animateTo(double targetTheta, double targetRadius) {
    void animateToValue({
      required double target,
      required Animation<double> animation,
      required Tween<double> tween,
      required AnimationController controller,
      required double min,
      required double max,
    }) {
      double beginValue = _nearest(target, animation.value, max);
      beginValue = _nearest(target, beginValue, min);
      tween
        ..begin = beginValue
        ..end = target;
      controller
        ..value = 0
        ..forward();
    }

    animateToValue(
      target: targetTheta,
      animation: _theta,
      tween: _thetaTween,
      controller: _animationController,
      min: _theta.value - _kTwoPi,
      max: _theta.value + _kTwoPi,
    );
    animateToValue(
      target: targetRadius,
      animation: _radius,
      tween: _radiusTween,
      controller: _animationController,
      min: 0,
      max: 1,
    );
  }
  // coverage:ignore-end

  double _getRadiusForTime(TimeOfDay time) {
    switch (widget.hourMinuteMode) {
      case _HourMinuteMode.hour:
        switch (widget.hourDialType) {
          // coverage:ignore-start
          case _HourDialType.twentyFourHourDoubleRing:
            return time.hour >= 12 ? 0 : 1;
          case _HourDialType.twentyFourHour:
          case _HourDialType.twelveHour:
            return 1;
          // coverage:ignore-end
        }
      // coverage:ignore-start
      case _HourMinuteMode.minute:
        return 1;
      // coverage:ignore-end
    }
  }

  double _getThetaForTime(TimeOfDay time) {
    final int hoursFactor;
    switch (widget.hourDialType) {
      case _HourDialType.twentyFourHour:
        hoursFactor = TimeOfDay.hoursPerDay;
        break;
      // coverage:ignore-start
      case _HourDialType.twentyFourHourDoubleRing:
        hoursFactor = TimeOfDay.hoursPerPeriod;
        break;
      case _HourDialType.twelveHour:
        hoursFactor = TimeOfDay.hoursPerPeriod;
        break;
      // coverage:ignore-end
    }
    final double fraction;
    switch (widget.hourMinuteMode) {
      case _HourMinuteMode.hour:
        fraction = (time.hour / hoursFactor) % hoursFactor;
        break;
      // coverage:ignore-start
      case _HourMinuteMode.minute:
        fraction =
            (time.minute / TimeOfDay.minutesPerHour) % TimeOfDay.minutesPerHour;
        break;
      // coverage:ignore-end
    }
    return (math.pi / 2 - fraction * _kTwoPi) % _kTwoPi;
  }

  // coverage:ignore-start
  TimeOfDay _getTimeForTheta(
    double theta, {
    bool roundMinutes = false,
    required double radius,
  }) {
    final double fraction = (0.25 - (theta % _kTwoPi) / _kTwoPi) % 1;
    switch (widget.hourMinuteMode) {
      case _HourMinuteMode.hour:
        int newHour;
        switch (widget.hourDialType) {
          case _HourDialType.twentyFourHour:
            newHour =
                (fraction * TimeOfDay.hoursPerDay).round() %
                TimeOfDay.hoursPerDay;
            break;
          case _HourDialType.twentyFourHourDoubleRing:
            newHour =
                (fraction * TimeOfDay.hoursPerPeriod).round() %
                TimeOfDay.hoursPerPeriod;
            if (radius < 0.5) {
              newHour = newHour + TimeOfDay.hoursPerPeriod;
            }
            break;
          case _HourDialType.twelveHour:
            newHour =
                (fraction * TimeOfDay.hoursPerPeriod).round() %
                TimeOfDay.hoursPerPeriod;
            newHour = newHour + widget.selectedTime.periodOffset;
            break;
        }
        return widget.selectedTime.replacing(hour: newHour);
      case _HourMinuteMode.minute:
        int minute =
            (fraction * TimeOfDay.minutesPerHour).round() %
            TimeOfDay.minutesPerHour;
        if (roundMinutes) {
          // Round the minutes to nearest 5 minute interval.
          minute = ((minute + 2) ~/ 5) * 5 % TimeOfDay.minutesPerHour;
        }
        return widget.selectedTime.replacing(minute: minute);
    }
  }

  TimeOfDay _notifyOnChangedIfNeeded({bool roundMinutes = false}) {
    final TimeOfDay current = _getTimeForTheta(
      _theta.value,
      roundMinutes: roundMinutes,
      radius: _radius.value,
    );
    if (widget.onChanged == null) {
      return current;
    }
    if (current != widget.selectedTime) {
      widget.onChanged!(current);
    }
    return current;
  }

  void _updateThetaForPan({bool roundMinutes = false}) {
    setState(() {
      final Offset offset = _position! - _center!;
      final double labelRadius =
          _dialSize!.shortestSide / 2 - _kTimePickerDialPadding;
      final double innerRadius = labelRadius - _kTimePickerInnerDialOffset;
      double angle = (math.atan2(offset.dx, offset.dy) - math.pi / 2) % _kTwoPi;
      final double radius = clampDouble(
        (offset.distance - innerRadius) / _kTimePickerInnerDialOffset,
        0,
        1,
      );
      if (roundMinutes) {
        angle = _getThetaForTime(
          _getTimeForTheta(angle, roundMinutes: roundMinutes, radius: radius),
        );
      }
      // The controller doesn't animate during the pan gesture.
      _thetaTween
        ..begin = angle
        ..end = angle;
      _radiusTween
        ..begin = radius
        ..end = radius;
    });
  }

  Offset? _position;
  Offset? _center;
  Size? _dialSize;

  void _handlePanStart(DragStartDetails details) {
    assert(!_dragging);
    _dragging = true;
    final RenderBox box = context.findRenderObject()! as RenderBox;
    _position = box.globalToLocal(details.globalPosition);
    _dialSize = box.size;
    _center = _dialSize!.center(Offset.zero);
    _updateThetaForPan();
    _notifyOnChangedIfNeeded();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _position = _position! + details.delta;
    _updateThetaForPan();
    _notifyOnChangedIfNeeded();
  }

  void _handlePanEnd(DragEndDetails details) {
    assert(_dragging);
    _dragging = false;
    _position = null;
    _center = null;
    _dialSize = null;
    _animateTo(
      _getThetaForTime(widget.selectedTime),
      _getRadiusForTime(widget.selectedTime),
    );
    if (widget.hourMinuteMode == _HourMinuteMode.hour) {
      widget.onHourSelected?.call();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final RenderBox box = context.findRenderObject()! as RenderBox;
    _position = box.globalToLocal(details.globalPosition);
    _center = box.size.center(Offset.zero);
    _dialSize = box.size;
    _updateThetaForPan(roundMinutes: true);
    final TimeOfDay newTime = _notifyOnChangedIfNeeded(roundMinutes: true);
    if (widget.hourMinuteMode == _HourMinuteMode.hour) {
      switch (widget.hourDialType) {
        case _HourDialType.twentyFourHour:
        case _HourDialType.twentyFourHourDoubleRing:
          _announceToAccessibility(
            context,
            localizations.formatDecimal(newTime.hour),
          );
          break;
        case _HourDialType.twelveHour:
          _announceToAccessibility(
            context,
            localizations.formatDecimal(newTime.hourOfPeriod),
          );
          break;
      }
      widget.onHourSelected?.call();
    } else {
      _announceToAccessibility(
        context,
        localizations.formatDecimal(newTime.minute),
      );
    }
    final TimeOfDay time = _getTimeForTheta(
      _theta.value,
      roundMinutes: true,
      radius: _radius.value,
    );
    _animateTo(_getThetaForTime(time), _getRadiusForTime(time));
    _dragging = false;
    _position = null;
    _center = null;
    _dialSize = null;
  }

  void _selectHour(int hour) {
    _announceToAccessibility(context, localizations.formatDecimal(hour));
    final TimeOfDay time;

    TimeOfDay getAmPmTime() {
      switch (widget.selectedTime.period) {
        case DayPeriod.am:
          return TimeOfDay(hour: hour, minute: widget.selectedTime.minute);
        case DayPeriod.pm:
          return TimeOfDay(
            hour: hour + TimeOfDay.hoursPerPeriod,
            minute: widget.selectedTime.minute,
          );
      }
    }

    switch (widget.hourMinuteMode) {
      case _HourMinuteMode.hour:
        switch (widget.hourDialType) {
          case _HourDialType.twentyFourHour:
          case _HourDialType.twentyFourHourDoubleRing:
            time = TimeOfDay(hour: hour, minute: widget.selectedTime.minute);
            break;
          case _HourDialType.twelveHour:
            time = getAmPmTime();
            break;
        }
        break;
      case _HourMinuteMode.minute:
        time = getAmPmTime();
        break;
    }
    final double angle = _getThetaForTime(time);
    _thetaTween
      ..begin = angle
      ..end = angle;
    _notifyOnChangedIfNeeded();
  }

  void _selectMinute(int minute) {
    _announceToAccessibility(context, localizations.formatDecimal(minute));
    final TimeOfDay time = TimeOfDay(
      hour: widget.selectedTime.hour,
      minute: minute,
    );
    final double angle = _getThetaForTime(time);
    _thetaTween
      ..begin = angle
      ..end = angle;
    _notifyOnChangedIfNeeded();
  }
  // coverage:ignore-end

  static const List<TimeOfDay> _amHours = <TimeOfDay>[
    TimeOfDay(hour: 12, minute: 0),
    TimeOfDay(hour: 1, minute: 0),
    TimeOfDay(hour: 2, minute: 0),
    TimeOfDay(hour: 3, minute: 0),
    TimeOfDay(hour: 4, minute: 0),
    TimeOfDay(hour: 5, minute: 0),
    TimeOfDay(hour: 6, minute: 0),
    TimeOfDay(hour: 7, minute: 0),
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 11, minute: 0),
  ];

  // On M2, there's no inner ring of numbers.
  static const List<TimeOfDay> _twentyFourHoursM2 = <TimeOfDay>[
    TimeOfDay(hour: 0, minute: 0),
    TimeOfDay(hour: 2, minute: 0),
    TimeOfDay(hour: 4, minute: 0),
    TimeOfDay(hour: 6, minute: 0),
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 12, minute: 0),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
    TimeOfDay(hour: 18, minute: 0),
    TimeOfDay(hour: 20, minute: 0),
    TimeOfDay(hour: 22, minute: 0),
  ];

  _TappableLabel _buildTappableLabel({
    required TextStyle? textStyle,
    required int selectedValue,
    required int value,
    required bool inner,
    required String label,
    required VoidCallback onTap,
  }) {
    return _TappableLabel(
      value: value,
      inner: inner,
      painter: TextPainter(
        text: TextSpan(style: textStyle, text: label),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 2.0),
      )..layout(),
      onTap: onTap,
    );
  }

  List<_TappableLabel> _build24HourRing({
    required TextStyle? textStyle,
    required int selectedValue,
  }) {
    return <_TappableLabel>[
      for (final TimeOfDay timeOfDay in _twentyFourHoursM2)
        _buildTappableLabel(
          textStyle: textStyle,
          selectedValue: selectedValue,
          inner: false,
          value: timeOfDay.hour,
          label: localizations.formatHour(
            timeOfDay,
            alwaysUse24HourFormat: true,
          ),
          onTap: () => _selectHour(timeOfDay.hour), // coverage:ignore-line
        ),
    ];
  }

  // coverage:ignore-start
  List<_TappableLabel> _build12HourRing({
    required TextStyle? textStyle,
    required int selectedValue,
  }) {
    return <_TappableLabel>[
      for (final TimeOfDay timeOfDay in _amHours)
        _buildTappableLabel(
          textStyle: textStyle,
          selectedValue: selectedValue,
          inner: false,
          value: timeOfDay.hour,
          label: localizations.formatHour(
            timeOfDay,
            alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
          ),
          onTap: () {
            _selectHour(timeOfDay.hour);
          },
        ),
    ];
  }
  // coverage:ignore-end

  // coverage:ignore-start
  List<_TappableLabel> _buildMinutes({
    required TextStyle? textStyle,
    required int selectedValue,
  }) {
    const List<TimeOfDay> minuteMarkerValues = <TimeOfDay>[
      TimeOfDay(hour: 0, minute: 0),
      TimeOfDay(hour: 0, minute: 5),
      TimeOfDay(hour: 0, minute: 10),
      TimeOfDay(hour: 0, minute: 15),
      TimeOfDay(hour: 0, minute: 20),
      TimeOfDay(hour: 0, minute: 25),
      TimeOfDay(hour: 0, minute: 30),
      TimeOfDay(hour: 0, minute: 35),
      TimeOfDay(hour: 0, minute: 40),
      TimeOfDay(hour: 0, minute: 45),
      TimeOfDay(hour: 0, minute: 50),
      TimeOfDay(hour: 0, minute: 55),
    ];

    return <_TappableLabel>[
      for (final TimeOfDay timeOfDay in minuteMarkerValues)
        _buildTappableLabel(
          textStyle: textStyle,
          selectedValue: selectedValue,
          inner: false,
          value: timeOfDay.minute,
          label: localizations.formatMinute(timeOfDay),
          onTap: () {
            _selectMinute(timeOfDay.minute);
          },
        ),
    ];
  }
  // coverage:ignore-end

  @override
  Widget build(BuildContext context) {
    final TimePickerThemeData timePickerTheme = TimePickerTheme.of(context);
    final _TimePickerDefaults defaultTheme = _TimePickerDefaultsM2(context);
    final Color backgroundColor =
        timePickerTheme.dialBackgroundColor ?? defaultTheme.dialBackgroundColor;
    final Color dialHandColor =
        timePickerTheme.dialHandColor ?? defaultTheme.dialHandColor;
    final TextStyle labelStyle =
        timePickerTheme.dialTextStyle ?? defaultTheme.dialTextStyle;
    final Color dialTextUnselectedColor = WidgetStateProperty.resolveAs<Color>(
      timePickerTheme.dialTextColor ?? defaultTheme.dialTextColor,
      <WidgetState>{},
    );
    final Color dialTextSelectedColor = WidgetStateProperty.resolveAs<Color>(
      timePickerTheme.dialTextColor ?? defaultTheme.dialTextColor,
      <WidgetState>{WidgetState.selected},
    );
    final TextStyle resolvedUnselectedLabelStyle = labelStyle.copyWith(
      color: dialTextUnselectedColor,
    );
    final TextStyle resolvedSelectedLabelStyle = labelStyle.copyWith(
      color: dialTextSelectedColor,
    );
    final Color dotColor = dialTextSelectedColor;

    List<_TappableLabel> primaryLabels;
    List<_TappableLabel> selectedLabels;
    final int selectedDialValue;
    final double radiusValue;
    switch (widget.hourMinuteMode) {
      case _HourMinuteMode.hour:
        switch (widget.hourDialType) {
          case _HourDialType.twentyFourHour:
          case _HourDialType.twentyFourHourDoubleRing: // coverage:ignore-line
            selectedDialValue = widget.selectedTime.hour;
            primaryLabels = _build24HourRing(
              textStyle: resolvedUnselectedLabelStyle,
              selectedValue: selectedDialValue,
            );
            selectedLabels = _build24HourRing(
              textStyle: resolvedSelectedLabelStyle,
              selectedValue: selectedDialValue,
            );
            radiusValue = 1;
            break;
          // coverage:ignore-start
          case _HourDialType.twelveHour:
            selectedDialValue = widget.selectedTime.hourOfPeriod;
            primaryLabels = _build12HourRing(
              textStyle: resolvedUnselectedLabelStyle,
              selectedValue: selectedDialValue,
            );
            selectedLabels = _build12HourRing(
              textStyle: resolvedSelectedLabelStyle,
              selectedValue: selectedDialValue,
            );
            radiusValue = 1;
            break;
          // coverage:ignore-end
        }
        break;
      // coverage:ignore-start
      case _HourMinuteMode.minute:
        selectedDialValue = widget.selectedTime.minute;
        primaryLabels = _buildMinutes(
          textStyle: resolvedUnselectedLabelStyle,
          selectedValue: selectedDialValue,
        );
        selectedLabels = _buildMinutes(
          textStyle: resolvedSelectedLabelStyle,
          selectedValue: selectedDialValue,
        );
        radiusValue = 1;
        break;
      // coverage:ignore-end
    }
    painter?.dispose();
    painter = _DialPainter(
      selectedValue: selectedDialValue,
      primaryLabels: primaryLabels,
      selectedLabels: selectedLabels,
      backgroundColor: backgroundColor,
      handColor: dialHandColor,
      handWidth: defaultTheme.handWidth,
      dotColor: dotColor,
      dotRadius: defaultTheme.dotRadius,
      centerRadius: defaultTheme.centerRadius,
      theta: _theta.value,
      radius: radiusValue,
      textDirection: Directionality.of(context),
    );

    return GestureDetector(
      excludeFromSemantics: true,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTapUp: _handleTapUp,
      child: CustomPaint(
        key: const ValueKey<String>('time-picker-dial'),
        painter: painter,
      ),
    );
  }
}

class _TimePickerInput extends StatefulWidget {
  const _TimePickerInput({
    required this.initialSelectedTime,
    required this.errorInvalidText,
    required this.hourLabelText,
    required this.minuteLabelText,
    required this.helpText,
    required this.autofocusHour,
    required this.autofocusMinute,
    this.restorationId,
  });

  /// The time initially selected when the dialog is shown.
  final TimeOfDay initialSelectedTime;

  /// Optionally provide your own validation error text.
  final String? errorInvalidText;

  /// Optionally provide your own hour label text.
  final String? hourLabelText;

  /// Optionally provide your own minute label text.
  final String? minuteLabelText;

  final String helpText;

  final bool? autofocusHour;

  final bool? autofocusMinute;

  /// Restoration ID to save and restore the state of the time picker input
  /// widget.
  ///
  /// If it is non-null, the widget will persist and restore its state
  ///
  /// The state of this widget is persisted in a [RestorationBucket] claimed
  /// from the surrounding [RestorationScope] using the provided restoration ID.
  final String? restorationId;

  @override
  _TimePickerInputState createState() => _TimePickerInputState();
}

class _TimePickerInputState extends State<_TimePickerInput>
    with RestorationMixin {
  late final RestorableTimeOfDay _selectedTime = RestorableTimeOfDay(
    widget.initialSelectedTime,
  );
  final RestorableBool hourHasError = RestorableBool(false);
  final RestorableBool minuteHasError = RestorableBool(false);

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedTime, 'selected_time');
    registerForRestoration(hourHasError, 'hour_has_error');
    registerForRestoration(minuteHasError, 'minute_has_error');
  }

  int? _parseHour(String? value) {
    if (value == null) {
      return null;
    }

    int? newHour = int.tryParse(value);
    if (newHour == null) {
      return null;
    }

    if (MediaQuery.alwaysUse24HourFormatOf(context)) {
      if (newHour >= 0 && newHour < 24) {
        return newHour;
      }
    } else {
      // coverage:ignore-start
      if (newHour > 0 && newHour < 13) {
        if ((_selectedTime.value.period == DayPeriod.pm && newHour != 12) ||
            (_selectedTime.value.period == DayPeriod.am && newHour == 12)) {
          newHour =
              (newHour + TimeOfDay.hoursPerPeriod) % TimeOfDay.hoursPerDay;
        }
        return newHour;
      }
      // coverage:ignore-end
    }
    return null;
  }

  int? _parseMinute(String? value) {
    if (value == null) {
      return null;
    }

    final int? newMinute = int.tryParse(value);
    if (newMinute == null) {
      return null;
    }

    if (newMinute >= 0 && newMinute < 60) {
      return newMinute;
    }
    return null;
  }

  void _handleHourSavedSubmitted(String? value) {
    final int? newHour = _parseHour(value);
    if (newHour != null) {
      _selectedTime.value = TimeOfDay(
        hour: newHour,
        minute: _selectedTime.value.minute,
      );
      _TimePickerModel.setSelectedTime(context, _selectedTime.value);
      FocusScope.of(context).requestFocus();
    }
  }

  void _handleHourChanged(String value) {
    final int? newHour = _parseHour(value);
    if (newHour != null && value.length == 2) {
      // If a valid hour is typed, move focus to the minute TextField.
      FocusScope.of(context).nextFocus();
    }
  }

  void _handleMinuteSavedSubmitted(String? value) {
    final int? newMinute = _parseMinute(value);
    if (newMinute != null) {
      _selectedTime.value = TimeOfDay(
        hour: _selectedTime.value.hour,
        minute: int.parse(value!),
      );
      _TimePickerModel.setSelectedTime(context, _selectedTime.value);
      FocusScope.of(context).unfocus();
    }
  }

  // coverage:ignore-start
  void _handleDayPeriodChanged(TimeOfDay value) {
    _selectedTime.value = value;
    _TimePickerModel.setSelectedTime(context, _selectedTime.value);
  }
  // coverage:ignore-end

  String? _validateHour(String? value) {
    final int? newHour = _parseHour(value);
    setState(() {
      hourHasError.value = newHour == null;
    });
    // This is used as the validator for the [TextFormField].
    // Returning an empty string allows the field to go into an error state.
    // Returning null means no error in the validation of the entered text.
    return newHour == null ? '' : null;
  }

  String? _validateMinute(String? value) {
    final int? newMinute = _parseMinute(value);
    setState(() {
      minuteHasError.value = newMinute == null;
    });
    // This is used as the validator for the [TextFormField].
    // Returning an empty string allows the field to go into an error state.
    // Returning null means no error in the validation of the entered text.
    return newMinute == null ? '' : null;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final TimeOfDayFormat timeOfDayFormat = MaterialLocalizations.of(
      context,
    ).timeOfDayFormat(
      alwaysUse24HourFormat: _TimePickerModel.use24HourFormatOf(context),
    );
    final bool use24HourDials = hourFormat(of: timeOfDayFormat) != HourFormat.h;
    final ThemeData theme = Theme.of(context);
    final TimePickerThemeData timePickerTheme = _TimePickerModel.themeOf(
      context,
    );
    final _TimePickerDefaults defaultTheme = _TimePickerModel.defaultThemeOf(
      context,
    );
    final TextStyle hourMinuteStyle =
        timePickerTheme.hourMinuteTextStyle ?? defaultTheme.hourMinuteTextStyle;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 24),
            child: Text(
              widget.helpText,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // coverage:ignore-start
              if (!use24HourDials &&
                  timeOfDayFormat ==
                      TimeOfDayFormat.a_space_h_colon_mm) ...<Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                  child: _DayPeriodControl(
                    onPeriodChanged: _handleDayPeriodChanged,
                  ),
                ),
              ],
              // coverage:ignore-end
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // Hour/minutes should not change positions in RTL locales.
                  textDirection: TextDirection.ltr,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _HourTextField(
                              restorationId: 'hour_text_field',
                              selectedTime: _selectedTime.value,
                              style: hourMinuteStyle,
                              autofocus: widget.autofocusHour,
                              inputAction: TextInputAction.next,
                              validator: _validateHour,
                              onSavedSubmitted: _handleHourSavedSubmitted,
                              onChanged: _handleHourChanged,
                              hourLabelText: widget.hourLabelText,
                            ),
                          ),
                          if (!hourHasError.value && !minuteHasError.value)
                            ExcludeSemantics(
                              child: Text(
                                widget.hourLabelText ??
                                    MaterialLocalizations.of(
                                      context,
                                    ).timePickerHourLabel,
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    _StringFragment(timeOfDayFormat: timeOfDayFormat),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _MinuteTextField(
                              restorationId: 'minute_text_field',
                              selectedTime: _selectedTime.value,
                              style: hourMinuteStyle,
                              autofocus: widget.autofocusMinute,
                              inputAction: TextInputAction.done,
                              validator: _validateMinute,
                              onSavedSubmitted: _handleMinuteSavedSubmitted,
                              minuteLabelText: widget.minuteLabelText,
                            ),
                          ),
                          if (!hourHasError.value && !minuteHasError.value)
                            ExcludeSemantics(
                              child: Text(
                                widget.minuteLabelText ??
                                    MaterialLocalizations.of(
                                      context,
                                    ).timePickerMinuteLabel,
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // coverage:ignore-start
              if (!use24HourDials &&
                  timeOfDayFormat !=
                      TimeOfDayFormat.a_space_h_colon_mm) ...<Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12),
                  child: _DayPeriodControl(
                    onPeriodChanged: _handleDayPeriodChanged,
                  ),
                ),
                // coverage:ignore-end
              ],
            ],
          ),
          if (hourHasError.value || minuteHasError.value)
            Text(
              widget.errorInvalidText ??
                  MaterialLocalizations.of(context).invalidTimeLabel,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.error,
              ),
            )
          else
            const SizedBox(height: 2),
        ],
      ),
    );
  }
}

class _HourTextField extends StatelessWidget {
  const _HourTextField({
    required this.selectedTime,
    required this.style,
    required this.autofocus,
    required this.inputAction,
    required this.validator,
    required this.onSavedSubmitted,
    required this.onChanged,
    required this.hourLabelText,
    this.restorationId,
  });

  final TimeOfDay selectedTime;
  final TextStyle style;
  final bool? autofocus;
  final TextInputAction inputAction;
  final FormFieldValidator<String> validator;
  final ValueChanged<String?> onSavedSubmitted;
  final ValueChanged<String> onChanged;
  final String? hourLabelText;
  final String? restorationId;

  @override
  Widget build(BuildContext context) {
    return _HourMinuteTextField(
      restorationId: restorationId,
      selectedTime: selectedTime,
      isHour: true,
      autofocus: autofocus,
      inputAction: inputAction,
      style: style,
      semanticHintText:
          hourLabelText ??
          MaterialLocalizations.of(context).timePickerHourLabel,
      validator: validator,
      onSavedSubmitted: onSavedSubmitted,
      onChanged: onChanged,
    );
  }
}

class _MinuteTextField extends StatelessWidget {
  const _MinuteTextField({
    required this.selectedTime,
    required this.style,
    required this.autofocus,
    required this.inputAction,
    required this.validator,
    required this.onSavedSubmitted,
    required this.minuteLabelText,
    this.restorationId,
  });

  final TimeOfDay selectedTime;
  final TextStyle style;
  final bool? autofocus;
  final TextInputAction inputAction;
  final FormFieldValidator<String> validator;
  final ValueChanged<String?> onSavedSubmitted;
  final String? minuteLabelText;
  final String? restorationId;

  @override
  Widget build(BuildContext context) {
    return _HourMinuteTextField(
      restorationId: restorationId,
      selectedTime: selectedTime,
      isHour: false,
      autofocus: autofocus,
      inputAction: inputAction,
      style: style,
      semanticHintText:
          minuteLabelText ??
          MaterialLocalizations.of(context).timePickerMinuteLabel,
      validator: validator,
      onSavedSubmitted: onSavedSubmitted,
    );
  }
}

class _HourMinuteTextField extends StatefulWidget {
  const _HourMinuteTextField({
    required this.selectedTime,
    required this.isHour,
    required this.autofocus,
    required this.inputAction,
    required this.style,
    required this.semanticHintText,
    required this.validator,
    required this.onSavedSubmitted,
    this.restorationId,
    this.onChanged,
  });

  final TimeOfDay selectedTime;
  final bool isHour;
  final bool? autofocus;
  final TextInputAction inputAction;
  final TextStyle style;
  final String semanticHintText;
  final FormFieldValidator<String> validator;
  final ValueChanged<String?> onSavedSubmitted;
  final ValueChanged<String>? onChanged;
  final String? restorationId;

  @override
  _HourMinuteTextFieldState createState() => _HourMinuteTextFieldState();
}

class _HourMinuteTextFieldState extends State<_HourMinuteTextField>
    with RestorationMixin {
  final RestorableTextEditingController controller =
      RestorableTextEditingController();
  final RestorableBool controllerHasBeenSet = RestorableBool(false);
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode =
        FocusNode()..addListener(() {
          setState(() {
            // Rebuild when focus changes.
          });
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only set the text value if it has not been populated with a localized
    // version yet.
    if (!controllerHasBeenSet.value) {
      controllerHasBeenSet.value = true;
      controller.value.text = _formattedValue;
    }
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(controller, 'text_editing_controller');
    registerForRestoration(controllerHasBeenSet, 'has_controller_been_set');
  }

  String get _formattedValue {
    final bool alwaysUse24HourFormat = MediaQuery.alwaysUse24HourFormatOf(
      context,
    );
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    return !widget.isHour
        ? localizations.formatMinute(widget.selectedTime)
        : localizations.formatHour(
          widget.selectedTime,
          alwaysUse24HourFormat: alwaysUse24HourFormat,
        );
  }

  @override
  Widget build(BuildContext context) {
    final TimePickerThemeData timePickerTheme = TimePickerTheme.of(context);
    final _TimePickerDefaults defaultTheme = _TimePickerDefaultsM2(context);
    final bool alwaysUse24HourFormat = MediaQuery.alwaysUse24HourFormatOf(
      context,
    );

    final InputDecorationTheme inputDecorationTheme =
        timePickerTheme.inputDecorationTheme ??
        defaultTheme.inputDecorationTheme;
    InputDecoration inputDecoration = const InputDecoration().applyDefaults(
      inputDecorationTheme,
    );
    // Remove the hint text when focused because the centered cursor
    // appears odd above the hint text.
    final String? hintText = focusNode.hasFocus ? null : _formattedValue;

    // Because the fill color is specified in both the inputDecorationTheme and
    // the TimePickerTheme, if there's one in the user's input decoration theme,
    // use that. If not, but there's one in the user's
    // timePickerTheme.hourMinuteColor, use that, and otherwise use the default.
    // We ignore the value in the fillColor of the input decoration in the
    // default theme here, but it's the same as the hourMinuteColor.
    final Color startingFillColor =
        timePickerTheme.inputDecorationTheme?.fillColor ??
        timePickerTheme.hourMinuteColor ??
        defaultTheme.hourMinuteColor;
    final Color fillColor =
        focusNode.hasFocus ? Colors.transparent : startingFillColor;

    inputDecoration = inputDecoration.copyWith(
      hintText: hintText,
      fillColor: fillColor,
    );

    final Set<WidgetState> states = <WidgetState>{
      if (focusNode.hasFocus) WidgetState.focused,
      if (focusNode.hasFocus) WidgetState.selected,
    };
    final Color effectiveTextColor = WidgetStateProperty.resolveAs<Color>(
      timePickerTheme.hourMinuteTextColor ?? defaultTheme.hourMinuteTextColor,
      states,
    );
    final TextStyle effectiveStyle = WidgetStateProperty.resolveAs<TextStyle>(
      widget.style,
      states,
    ).copyWith(color: effectiveTextColor);

    return SizedBox.fromSize(
      size:
          alwaysUse24HourFormat
              ? defaultTheme.hourMinuteInputSize24Hour
              : defaultTheme.hourMinuteInputSize, // coverage:ignore-line
      child: MediaQuery.withNoTextScaling(
        child: UnmanagedRestorationScope(
          bucket: bucket,
          child: Semantics(
            label: widget.semanticHintText,
            child: TextFormField(
              restorationId: 'hour_minute_text_form_field',
              autofocus: widget.autofocus ?? false,
              expands: true,
              maxLines: null,
              // coverage:ignore-start
              onTap:
                  () =>
                      controller.value.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: controller.value.text.length,
                      ),
              // coverage:ignore-end
              inputFormatters: <TextInputFormatter>[
                LengthLimitingTextInputFormatter(2),
              ],
              focusNode: focusNode,
              textAlign: TextAlign.center,
              textInputAction: widget.inputAction,
              keyboardType: TextInputType.number,
              style: effectiveStyle,
              controller: controller.value,
              decoration: inputDecoration,
              validator: widget.validator,
              // coverage:ignore-start
              onEditingComplete:
                  () => widget.onSavedSubmitted(controller.value.text),
              // coverage:ignore-end
              onSaved: widget.onSavedSubmitted,
              onFieldSubmitted: widget.onSavedSubmitted,
              onChanged: widget.onChanged,
            ),
          ),
        ),
      ),
    );
  }
}

/// Signature for when the time picker entry mode is changed.
typedef EntryModeChangeCallback = void Function(TimePickerEntryMode);

/// A Material Design time picker designed to appear inside a popup dialog.
///
/// Pass this widget to [showDialog]. The value returned by [showDialog] is the
/// selected [TimeOfDay] if the user taps the "OK" button, or null if the user
/// taps the "CANCEL" button. The selected time is reported by calling
/// [Navigator.pop].
class CustomTimePickerDialog extends StatefulWidget {
  /// Creates a Material Design time picker.
  ///
  /// [initialTime] must not be null.
  const CustomTimePickerDialog({
    super.key,
    required this.initialTime,
    this.cancelText,
    this.confirmText,
    this.helpText,
    this.errorInvalidText,
    this.hourLabelText,
    this.minuteLabelText,
    this.restorationId,
    this.initialEntryMode = TimePickerEntryMode.dial,
    this.orientation,
    this.onEntryModeChanged,
  });

  /// The time initially selected when the dialog is shown.
  final TimeOfDay initialTime;

  /// Optionally provide your own text for the cancel button.
  ///
  /// If null, the button uses [MaterialLocalizations.cancelButtonLabel].
  final String? cancelText;

  /// Optionally provide your own text for the confirm button.
  ///
  /// If null, the button uses [MaterialLocalizations.okButtonLabel].
  final String? confirmText;

  /// Optionally provide your own help text to the header of the time picker.
  final String? helpText;

  /// Optionally provide your own validation error text.
  final String? errorInvalidText;

  /// Optionally provide your own hour label text.
  final String? hourLabelText;

  /// Optionally provide your own minute label text.
  final String? minuteLabelText;

  /// Restoration ID to save and restore the state of the [CustomTimePickerDialog].
  ///
  /// If it is non-null, the time picker will persist and restore the
  /// dialog's state.
  ///
  /// The state of this widget is persisted in a [RestorationBucket] claimed
  /// from the surrounding [RestorationScope] using the provided restoration ID.
  ///
  /// See also:
  ///
  ///  * [RestorationManager], which explains how state restoration works in
  ///    Flutter.
  final String? restorationId;

  /// The entry mode for the picker. Whether it's text input or a dial.
  final TimePickerEntryMode initialEntryMode;

  /// The optional [orientation] parameter sets the [Orientation] to use when
  /// displaying the dialog.
  ///
  /// By default, the orientation is derived from the [MediaQueryData.size] of
  /// the ambient [MediaQuery]. If the aspect of the size is tall, then
  /// [Orientation.portrait] is used, if the size is wide, then
  /// [Orientation.landscape] is used.
  ///
  /// Use this parameter to override the default and force the dialog to appear
  /// in either portrait or landscape mode regardless of the aspect of the
  /// [MediaQueryData.size].
  final Orientation? orientation;

  /// Callback called when the selected entry mode is changed.
  final EntryModeChangeCallback? onEntryModeChanged;

  @override
  State<CustomTimePickerDialog> createState() => _CustomTimePickerDialogState();
}

class _CustomTimePickerDialogState extends State<CustomTimePickerDialog>
    with RestorationMixin {
  late final RestorableEnum<TimePickerEntryMode> _entryMode =
      RestorableEnum<TimePickerEntryMode>(
        widget.initialEntryMode,
        values: TimePickerEntryMode.values,
      );
  late final RestorableTimeOfDay _selectedTime = RestorableTimeOfDay(
    widget.initialTime,
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RestorableEnum<AutovalidateMode> _autovalidateMode =
      RestorableEnum<AutovalidateMode>(
        AutovalidateMode.disabled,
        values: AutovalidateMode.values,
      );
  late final RestorableEnumN<Orientation> _orientation =
      RestorableEnumN<Orientation>(
        widget.orientation,
        values: Orientation.values,
      );

  // Base sizes
  static const Size _kTimePickerPortraitSize = Size(310, 468);
  static const Size _kTimePickerLandscapeSize = Size(524, 342);
  static const Size _kTimePickerLandscapeSizeM2 = Size(508, 300);
  static const Size _kTimePickerInputSize = Size(312, 216);

  // Absolute minimum dialog sizes, which is the point at which it begins
  // scrolling to fit everything in.
  static const Size _kTimePickerMinPortraitSize = Size(238, 326);
  static const Size _kTimePickerMinLandscapeSize = Size(416, 248);
  static const Size _kTimePickerMinInputSize = Size(312, 196);

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedTime, 'selected_time');
    registerForRestoration(_entryMode, 'entry_mode');
    registerForRestoration(_autovalidateMode, 'autovalidate_mode');
    registerForRestoration(_orientation, 'orientation');
  }

  void _handleTimeChanged(TimeOfDay value) {
    if (value != _selectedTime.value) {
      setState(() {
        _selectedTime.value = value;
      });
    }
  }

  void _handleEntryModeChanged(TimePickerEntryMode value) {
    if (value != _entryMode.value) {
      setState(() {
        switch (_entryMode.value) {
          case TimePickerEntryMode.dial:
            _autovalidateMode.value = AutovalidateMode.disabled;
            break;
          // coverage:ignore-start
          case TimePickerEntryMode.input:
            _formKey.currentState!.save();
            break;
          case TimePickerEntryMode.dialOnly:
            break;
          case TimePickerEntryMode.inputOnly:
            break;
          // coverage:ignore-end
        }
        _entryMode.value = value;
        widget.onEntryModeChanged?.call(value);
      });
    }
  }

  void _toggleEntryMode() {
    switch (_entryMode.value) {
      case TimePickerEntryMode.dial:
        _handleEntryModeChanged(TimePickerEntryMode.input);
        break;
      // coverage:ignore-start
      case TimePickerEntryMode.input:
        _handleEntryModeChanged(TimePickerEntryMode.dial);
        break;
      case TimePickerEntryMode.dialOnly:
      case TimePickerEntryMode.inputOnly:
        FlutterError('Can not change entry mode from $_entryMode');
      // coverage:ignore-end
    }
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOk() {
    if (_entryMode.value == TimePickerEntryMode.input ||
        _entryMode.value == TimePickerEntryMode.inputOnly) {
      final FormState form = _formKey.currentState!;
      if (!form.validate()) {
        setState(() {
          _autovalidateMode.value = AutovalidateMode.always;
        });
        return;
      }
      form.save();
    }
    Navigator.pop(context, _selectedTime.value);
  }

  Size _minDialogSize(BuildContext context) {
    final Orientation orientation =
        _orientation.value ?? MediaQuery.orientationOf(context);

    switch (_entryMode.value) {
      case TimePickerEntryMode.dial:
      case TimePickerEntryMode.dialOnly:
        switch (orientation) {
          case Orientation.portrait:
            return _kTimePickerMinPortraitSize;
          case Orientation.landscape:
            return _kTimePickerMinLandscapeSize;
        }
      case TimePickerEntryMode.input:
      case TimePickerEntryMode.inputOnly: // coverage:ignore-line
        final MaterialLocalizations localizations = MaterialLocalizations.of(
          context,
        );
        final TimeOfDayFormat timeOfDayFormat = localizations.timeOfDayFormat(
          alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
        );
        final double timePickerWidth;
        switch (timeOfDayFormat) {
          case TimeOfDayFormat.HH_colon_mm:
          case TimeOfDayFormat.HH_dot_mm:
          case TimeOfDayFormat.frenchCanadian:
          case TimeOfDayFormat.H_colon_mm: // coverage:ignore-line
            final _TimePickerDefaults defaultTheme = _TimePickerDefaultsM2(
              context,
            );
            timePickerWidth =
                _kTimePickerMinInputSize.width -
                defaultTheme.dayPeriodPortraitSize.width -
                12;
            break;
          // coverage:ignore-start
          case TimeOfDayFormat.a_space_h_colon_mm:
          case TimeOfDayFormat.h_colon_mm_space_a:
            timePickerWidth = _kTimePickerMinInputSize.width;
            break;
          // coverage:ignore-end
        }
        return Size(timePickerWidth, _kTimePickerMinInputSize.height);
    }
  }

  Size _dialogSize(BuildContext context) {
    final Orientation orientation =
        _orientation.value ?? MediaQuery.orientationOf(context);
    // Constrain the textScaleFactor to prevent layout issues. Since only some
    // parts of the time picker scale up with textScaleFactor, we cap the factor
    // to 1.1 as that provides enough space to reasonably fit all the content.
    //
    // 14 is a common font size used to compute the effective text scale.
    const double fontSizeToScale = 14.0;
    final double textScaleFactor =
        MediaQuery.textScalerOf(
          context,
        ).clamp(maxScaleFactor: 1.1).scale(fontSizeToScale) /
        fontSizeToScale;

    final Size timePickerSize;
    switch (_entryMode.value) {
      case TimePickerEntryMode.dial:
      case TimePickerEntryMode.dialOnly:
        switch (orientation) {
          case Orientation.portrait:
            timePickerSize = _kTimePickerPortraitSize;
            break;
          case Orientation.landscape:
            timePickerSize = Size(
              _kTimePickerLandscapeSize.width * textScaleFactor,
              _kTimePickerLandscapeSizeM2.height,
            );
            break;
        }
        break;
      case TimePickerEntryMode.input:
      case TimePickerEntryMode.inputOnly: // coverage:ignore-line
        final MaterialLocalizations localizations = MaterialLocalizations.of(
          context,
        );
        final TimeOfDayFormat timeOfDayFormat = localizations.timeOfDayFormat(
          alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
        );
        final double timePickerWidth;
        switch (timeOfDayFormat) {
          case TimeOfDayFormat.HH_colon_mm:
          case TimeOfDayFormat.HH_dot_mm:
          case TimeOfDayFormat.frenchCanadian:
          case TimeOfDayFormat.H_colon_mm: // coverage:ignore-line
            final _TimePickerDefaults defaultTheme = _TimePickerDefaultsM2(
              context,
            );
            timePickerWidth =
                _kTimePickerInputSize.width -
                defaultTheme.dayPeriodPortraitSize.width -
                12;
            break;
          // coverage:ignore-start
          case TimeOfDayFormat.a_space_h_colon_mm:
          case TimeOfDayFormat.h_colon_mm_space_a:
            timePickerWidth = _kTimePickerInputSize.width;
            break;
          // coverage:ignore-end
        }
        timePickerSize = Size(timePickerWidth, _kTimePickerInputSize.height);
        break;
    }
    return Size(timePickerSize.width, timePickerSize.height * textScaleFactor);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final ThemeData theme = Theme.of(context);
    final TimePickerThemeData pickerTheme = TimePickerTheme.of(context);
    final _TimePickerDefaults defaultTheme = _TimePickerDefaultsM2(context);
    final ShapeBorder shape = pickerTheme.shape ?? defaultTheme.shape;
    final Color entryModeIconColor =
        pickerTheme.entryModeIconColor ?? defaultTheme.entryModeIconColor;
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );

    final Widget actions = Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Row(
        children: <Widget>[
          if (_entryMode.value == TimePickerEntryMode.dial ||
              _entryMode.value == TimePickerEntryMode.input)
            IconButton(
              // In material3 mode, we want to use the color as part of the
              // button style which applies its own opacity. In material2 mode,
              // we want to use the color as the color, which already includes
              // the opacity.
              color: entryModeIconColor,
              style: null, // color overrides style
              onPressed: _toggleEntryMode,
              icon: Icon(
                _entryMode.value == TimePickerEntryMode.dial
                    ? Icons.keyboard_outlined
                    : Icons.access_time,
              ),
              tooltip:
                  _entryMode.value == TimePickerEntryMode.dial
                      ? MaterialLocalizations.of(
                        context,
                      ).inputTimeModeButtonLabel
                      : MaterialLocalizations.of(context).dialModeButtonLabel,
            ),
          Expanded(
            child: Container(
              alignment: AlignmentDirectional.centerEnd,
              constraints: const BoxConstraints(minHeight: 36),
              child: OverflowBar(
                spacing: 8,
                overflowAlignment: OverflowBarAlignment.end,
                children: <Widget>[
                  OutlinedButton(
                    onPressed: _handleCancel,
                    child: Text(
                      widget.cancelText ?? localizations.cancelButtonLabel,
                    ),
                  ),
                  TextButton(
                    onPressed: _handleOk,
                    child: Text(
                      widget.confirmText ?? localizations.okButtonLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final Offset tapTargetSizeOffset;
    switch (theme.materialTapTargetSize) {
      case MaterialTapTargetSize.padded:
        tapTargetSizeOffset = Offset.zero;
        break;
      // coverage:ignore-start
      case MaterialTapTargetSize.shrinkWrap:
        // _dialogSize returns "padded" sizes.
        tapTargetSizeOffset = const Offset(0, -12);
        break;
      // coverage:ignore-end
    }
    final Size dialogSize = _dialogSize(context) + tapTargetSizeOffset;
    final Size minDialogSize = _minDialogSize(context) + tapTargetSizeOffset;
    return Dialog(
      shape: shape,
      elevation: pickerTheme.elevation ?? defaultTheme.elevation,
      backgroundColor:
          pickerTheme.backgroundColor ?? defaultTheme.backgroundColor,
      insetPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical:
            (_entryMode.value == TimePickerEntryMode.input ||
                    _entryMode.value == TimePickerEntryMode.inputOnly)
                ? 0
                : 24,
      ),
      child: Padding(
        padding: pickerTheme.padding ?? defaultTheme.padding,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Size constrainedSize = constraints.constrain(dialogSize);
            // coverage:ignore-start
            final Size allowedSize = Size(
              constrainedSize.width < minDialogSize.width
                  ? minDialogSize.width
                  : constrainedSize.width,
              constrainedSize.height < minDialogSize.height
                  ? minDialogSize.height
                  : constrainedSize.height,
            );
            // coverage:ignore-end
            return SingleChildScrollView(
              restorationId: 'time_picker_scroll_view_horizontal',
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                restorationId: 'time_picker_scroll_view_vertical',
                child: AnimatedContainer(
                  width: allowedSize.width,
                  height: allowedSize.height,
                  duration: _kDialogSizeAnimationDuration,
                  curve: Curves.easeIn,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Form(
                          key: _formKey,
                          autovalidateMode: _autovalidateMode.value,
                          child: _TimePicker(
                            time: widget.initialTime,
                            onTimeChanged: _handleTimeChanged,
                            helpText: widget.helpText,
                            cancelText: widget.cancelText,
                            confirmText: widget.confirmText,
                            errorInvalidText: widget.errorInvalidText,
                            hourLabelText: widget.hourLabelText,
                            minuteLabelText: widget.minuteLabelText,
                            restorationId: 'time_picker',
                            entryMode: _entryMode.value,
                            orientation: widget.orientation,
                            onEntryModeChanged: _handleEntryModeChanged,
                          ),
                        ),
                      ),
                      actions,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// The _TimePicker widget is constructed so that in the future we could expose
// this as a public API for embedding time pickers into other non-dialog
// widgets, once we're sure we want to support that.

/// A Time Picker widget that can be embedded into another widget.
class _TimePicker extends StatefulWidget {
  /// Creates a const Material Design time picker.
  const _TimePicker({
    required this.time,
    required this.onTimeChanged,
    this.helpText,
    this.cancelText,
    this.confirmText,
    this.errorInvalidText,
    this.hourLabelText,
    this.minuteLabelText,
    this.restorationId,
    this.entryMode = TimePickerEntryMode.dial,
    this.orientation,
    this.onEntryModeChanged,
  });

  /// Optionally provide your own text for the help text at the top of the
  /// control.
  ///
  /// If null, the widget uses [MaterialLocalizations.timePickerDialHelpText]
  /// when the [entryMode] is [TimePickerEntryMode.dial], and
  /// [MaterialLocalizations.timePickerInputHelpText] when the [entryMode] is
  /// [TimePickerEntryMode.input].
  final String? helpText;

  /// Optionally provide your own text for the cancel button.
  ///
  /// If null, the button uses [MaterialLocalizations.cancelButtonLabel].
  final String? cancelText;

  /// Optionally provide your own text for the confirm button.
  ///
  /// If null, the button uses [MaterialLocalizations.okButtonLabel].
  final String? confirmText;

  /// Optionally provide your own validation error text.
  final String? errorInvalidText;

  /// Optionally provide your own hour label text.
  final String? hourLabelText;

  /// Optionally provide your own minute label text.
  final String? minuteLabelText;

  /// Restoration ID to save and restore the state of the [CustomTimePickerDialog].
  ///
  /// If it is non-null, the time picker will persist and restore the
  /// dialog's state.
  ///
  /// The state of this widget is persisted in a [RestorationBucket] claimed
  /// from the surrounding [RestorationScope] using the provided restoration ID.
  ///
  /// See also:
  ///
  ///  * [RestorationManager], which explains how state restoration works in
  ///    Flutter.
  final String? restorationId;

  /// The initial entry mode for the picker. Whether it's text input or a dial.
  final TimePickerEntryMode entryMode;

  /// The currently selected time of day.
  final TimeOfDay time;

  final ValueChanged<TimeOfDay>? onTimeChanged;

  /// The optional [orientation] parameter sets the [Orientation] to use when
  /// displaying the dialog.
  ///
  /// By default, the orientation is derived from the [MediaQueryData.size] of
  /// the ambient [MediaQuery]. If the aspect of the size is tall, then
  /// [Orientation.portrait] is used, if the size is wide, then
  /// [Orientation.landscape] is used.
  ///
  /// Use this parameter to override the default and force the dialog to appear
  /// in either portrait or landscape mode regardless of the aspect of the
  /// [MediaQueryData.size].
  final Orientation? orientation;

  /// Callback called when the selected entry mode is changed.
  final EntryModeChangeCallback? onEntryModeChanged;

  @override
  State<_TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<_TimePicker> with RestorationMixin {
  Timer? _vibrateTimer;
  late MaterialLocalizations localizations;
  final RestorableEnum<_HourMinuteMode> _hourMinuteMode =
      RestorableEnum<_HourMinuteMode>(
        _HourMinuteMode.hour,
        values: _HourMinuteMode.values,
      );
  final RestorableEnumN<_HourMinuteMode> _lastModeAnnounced =
      RestorableEnumN<_HourMinuteMode>(null, values: _HourMinuteMode.values);
  final RestorableBoolN _autofocusHour = RestorableBoolN(null);
  final RestorableBoolN _autofocusMinute = RestorableBoolN(null);
  final RestorableBool _announcedInitialTime = RestorableBool(false);
  late final RestorableEnumN<Orientation> _orientation =
      RestorableEnumN<Orientation>(
        widget.orientation,
        values: Orientation.values,
      );
  RestorableTimeOfDay get selectedTime => _selectedTime; // coverage:ignore-line
  late final RestorableTimeOfDay _selectedTime = RestorableTimeOfDay(
    widget.time,
  );

  @override
  void dispose() {
    _vibrateTimer?.cancel();
    _vibrateTimer = null;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
    _announceInitialTimeOnce();
    _announceModeOnce();
  }

  // coverage:ignore-start
  @override
  void didUpdateWidget(_TimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orientation != widget.orientation) {
      _orientation.value = widget.orientation;
    }
    if (oldWidget.time != widget.time) {
      _selectedTime.value = widget.time;
    }
  }
  // coverage:ignore-end

  // coverage:ignore-start
  void _setEntryMode(TimePickerEntryMode mode) {
    widget.onEntryModeChanged?.call(mode);
  }
  // coverage:ignore-end

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_hourMinuteMode, 'hour_minute_mode');
    registerForRestoration(_lastModeAnnounced, 'last_mode_announced');
    registerForRestoration(_autofocusHour, 'autofocus_hour');
    registerForRestoration(_autofocusMinute, 'autofocus_minute');
    registerForRestoration(_announcedInitialTime, 'announced_initial_time');
    registerForRestoration(_selectedTime, 'selected_time');
    registerForRestoration(_orientation, 'orientation');
  }

  // coverage:ignore-start
  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        _vibrateTimer?.cancel();
        _vibrateTimer = Timer(_kVibrateCommitDelay, () {
          HapticFeedback.vibrate();
          _vibrateTimer = null;
        });
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
  }
  // coverage:ignore-end

  // coverage:ignore-start
  void _handleHourMinuteModeChanged(_HourMinuteMode mode) {
    _vibrate();
    setState(() {
      _hourMinuteMode.value = mode;
      _announceModeOnce();
    });
  }
  // coverage:ignore-end

  // coverage:ignore-start
  void _handleEntryModeToggle() {
    setState(() {
      TimePickerEntryMode newMode = widget.entryMode;
      switch (widget.entryMode) {
        case TimePickerEntryMode.dial:
          newMode = TimePickerEntryMode.input;
          break;
        case TimePickerEntryMode.input:
          _autofocusHour.value = false;
          _autofocusMinute.value = false;
          newMode = TimePickerEntryMode.dial;
          break;
        case TimePickerEntryMode.dialOnly:
        case TimePickerEntryMode.inputOnly:
          FlutterError('Can not change entry mode from ${widget.entryMode}');
      }
      _setEntryMode(newMode);
    });
  }
  // coverage:ignore-end

  void _announceModeOnce() {
    if (_lastModeAnnounced.value == _hourMinuteMode.value) {
      // Already announced it.
      return;
    }

    switch (_hourMinuteMode.value) {
      case _HourMinuteMode.hour:
        _announceToAccessibility(
          context,
          localizations.timePickerHourModeAnnouncement,
        );
        break;
      // coverage:ignore-start
      case _HourMinuteMode.minute:
        _announceToAccessibility(
          context,
          localizations.timePickerMinuteModeAnnouncement,
        );
        break;
      // coverage:ignore-end
    }
    _lastModeAnnounced.value = _hourMinuteMode.value;
  }

  void _announceInitialTimeOnce() {
    if (_announcedInitialTime.value) {
      return;
    }

    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    _announceToAccessibility(
      context,
      localizations.formatTimeOfDay(
        _selectedTime.value,
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
      ),
    );
    _announcedInitialTime.value = true;
  }

  void _handleTimeChanged(TimeOfDay value) {
    _vibrate();
    setState(() {
      _selectedTime.value = value;
      widget.onTimeChanged?.call(value);
    });
  }

  // coverage:ignore-start
  void _handleHourDoubleTapped() {
    _autofocusHour.value = true;
    _handleEntryModeToggle();
  }

  void _handleMinuteDoubleTapped() {
    _autofocusMinute.value = true;
    _handleEntryModeToggle();
  }

  void _handleHourSelected() {
    setState(() {
      _hourMinuteMode.value = _HourMinuteMode.minute;
    });
  }
  // coverage:ignore-end

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final TimeOfDayFormat timeOfDayFormat = localizations.timeOfDayFormat(
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    final ThemeData theme = Theme.of(context);
    final _TimePickerDefaults defaultTheme = _TimePickerDefaultsM2(context);
    final Orientation orientation =
        _orientation.value ?? MediaQuery.orientationOf(context);
    final HourFormat timeOfDayHour = hourFormat(of: timeOfDayFormat);
    final _HourDialType hourMode;
    switch (timeOfDayHour) {
      case HourFormat.HH:
      case HourFormat.H: // coverage:ignore-line
        hourMode = _HourDialType.twentyFourHour;
        break;
      // coverage:ignore-start
      case HourFormat.h:
        hourMode = _HourDialType.twelveHour;
        break;
      // coverage:ignore-end
    }

    final String helpText;
    final Widget picker;
    switch (widget.entryMode) {
      case TimePickerEntryMode.dial:
      case TimePickerEntryMode.dialOnly:
        helpText = widget.helpText ?? localizations.timePickerDialHelpText;

        final EdgeInsetsGeometry dialPadding;
        switch (orientation) {
          case Orientation.portrait:
            dialPadding = const EdgeInsets.only(left: 12, right: 12);
            break;
          case Orientation.landscape:
            switch (theme.materialTapTargetSize) {
              case MaterialTapTargetSize.padded:
                dialPadding = const EdgeInsetsDirectional.only(start: 64);
                break;
              // coverage:ignore-start
              case MaterialTapTargetSize.shrinkWrap:
                dialPadding = const EdgeInsetsDirectional.only(start: 64);
                break;
              // coverage:ignore-end
            }
            break;
        }
        final Widget dial = Padding(
          padding: dialPadding,
          child: ExcludeSemantics(
            child: SizedBox.fromSize(
              size: defaultTheme.dialSize,
              child: AspectRatio(
                aspectRatio: 1,
                child: _Dial(
                  hourMinuteMode: _hourMinuteMode.value,
                  hourDialType: hourMode,
                  selectedTime: _selectedTime.value,
                  onChanged: _handleTimeChanged,
                  onHourSelected: _handleHourSelected,
                ),
              ),
            ),
          ),
        );

        switch (orientation) {
          case Orientation.portrait:
            // coverage:ignore-start
            picker = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _TimePickerHeader(helpText: helpText),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Dial grows and shrinks with the available space.
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: dial,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
            break;
          // coverage:ignore-end
          case Orientation.landscape:
            picker = Column(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _TimePickerHeader(helpText: helpText),
                        Expanded(child: dial),
                      ],
                    ),
                  ),
                ),
              ],
            );
            break;
        }
        break;
      case TimePickerEntryMode.input:
      case TimePickerEntryMode.inputOnly: // coverage:ignore-line
        final String helpText =
            widget.helpText ?? localizations.timePickerInputHelpText;

        picker = Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(alwaysUse24HourFormat: true),
              child: _TimePickerInput(
                initialSelectedTime: _selectedTime.value,
                errorInvalidText: widget.errorInvalidText,
                hourLabelText: widget.hourLabelText,
                minuteLabelText: widget.minuteLabelText,
                helpText: helpText,
                autofocusHour: _autofocusHour.value,
                autofocusMinute: _autofocusMinute.value,
                restorationId: 'time_picker_input',
              ),
            ),
          ],
        );
        break;
    }
    return _TimePickerModel(
      entryMode: widget.entryMode,
      selectedTime: _selectedTime.value,
      hourMinuteMode: _hourMinuteMode.value,
      orientation: orientation,
      onHourMinuteModeChanged: _handleHourMinuteModeChanged,
      onHourDoubleTapped: _handleHourDoubleTapped,
      onMinuteDoubleTapped: _handleMinuteDoubleTapped,
      hourDialType: hourMode,
      onSelectedTimeChanged: _handleTimeChanged,
      use24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
      theme: TimePickerTheme.of(context),
      defaultTheme: defaultTheme,
      child: picker,
    );
  }
}

/// Shows a dialog containing a Material Design time picker.
///
/// The returned Future resolves to the time selected by the user when the user
/// closes the dialog. If the user cancels the dialog, null is returned.
///
/// {@tool snippet} Show a dialog with [initialTime] equal to the current time.
///
/// ```dart
/// Future<TimeOfDay?> selectedTime = showCustomTimePicker(
///   initialTime: TimeOfDay.now(),
///   context: context,
/// );
/// ```
/// {@end-tool}
///
/// The [context], [useRootNavigator] and [routeSettings] arguments are passed
/// to [showDialog], the documentation for which discusses how it is used.
///
/// The [builder] parameter can be used to wrap the dialog widget to add
/// inherited widgets like [Localizations.override], [Directionality], or
/// [MediaQuery].
///
/// The `initialEntryMode` parameter can be used to determine the initial time
/// entry selection of the picker (either a clock dial or text input).
///
/// Optional strings for the [helpText], [cancelText], [errorInvalidText],
/// [hourLabelText], [minuteLabelText] and [confirmText] can be provided to
/// override the default values.
///
/// The optional [orientation] parameter sets the [Orientation] to use when
/// displaying the dialog. By default, the orientation is derived from the
/// [MediaQueryData.size] of the ambient [MediaQuery]: wide sizes use the
/// landscape orientation, and tall sizes use the portrait orientation. Use this
/// parameter to override the default and force the dialog to appear in either
/// portrait or landscape mode.
///
/// {@macro flutter.widgets.RawDialogRoute}
///
/// By default, the time picker gets its colors from the overall theme's
/// [ColorScheme]. The time picker can be further customized by providing a
/// [TimePickerThemeData] to the overall theme.
///
/// {@tool snippet} Show a dialog with the text direction overridden to be
/// [TextDirection.rtl].
///
/// ```dart
/// Future<TimeOfDay?> selectedTimeRTL = showCustomTimePicker(
///   context: context,
///   initialTime: TimeOfDay.now(),
///   builder: (BuildContext context, Widget? child) {
///     return Directionality(
///       textDirection: TextDirection.rtl,
///       child: child!,
///     );
///   },
/// );
/// ```
/// {@end-tool}
///
/// {@tool snippet} Show a dialog with time unconditionally displayed in 24 hour
/// format.
///
/// ```dart
/// Future<TimeOfDay?> selectedTime24Hour = showCustomTimePicker(
///   context: context,
///   initialTime: const TimeOfDay(hour: 10, minute: 47),
///   builder: (BuildContext context, Widget? child) {
///     return MediaQuery(
///       data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
///       child: child!,
///     );
///   },
/// );
/// ```
/// {@end-tool}
///
/// {@tool dartpad}
/// This example illustrates how to open a time picker, and allows exploring
/// some of the variations in the types of time pickers that may be shown.
///
/// ** See code in examples/api/lib/material/time_picker/show_time_picker.0.dart **
/// {@end-tool}
///
/// See also:
///
/// * [showDatePicker], which shows a dialog that contains a Material Design
///   date picker.
/// * [TimePickerThemeData], which allows you to customize the colors,
///   typography, and shape of the time picker.
/// * [DisplayFeatureSubScreen], which documents the specifics of how
///   [DisplayFeature]s can split the screen into sub-screens.
Future<TimeOfDay?> showCustomTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  TransitionBuilder? builder,
  bool useRootNavigator = true,
  TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial,
  String? cancelText,
  String? confirmText,
  String? helpText,
  String? errorInvalidText,
  String? hourLabelText,
  String? minuteLabelText,
  RouteSettings? routeSettings,
  EntryModeChangeCallback? onEntryModeChanged,
  Offset? anchorPoint,
  Orientation? orientation,
}) async {
  assert(debugCheckHasMaterialLocalizations(context));

  final Widget dialog = CustomTimePickerDialog(
    initialTime: initialTime,
    initialEntryMode: initialEntryMode,
    cancelText: cancelText,
    confirmText: confirmText,
    helpText: helpText,
    errorInvalidText: errorInvalidText,
    hourLabelText: hourLabelText,
    minuteLabelText: minuteLabelText,
    orientation: orientation,
    onEntryModeChanged: onEntryModeChanged,
  );
  return showDialog<TimeOfDay>(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (BuildContext context) {
      // coverage:ignore-start
      return builder == null ? dialog : builder(context, dialog);
      // coverage:ignore-end
    },
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
  );
}

void _announceToAccessibility(BuildContext context, String message) {
  SemanticsService.announce(message, Directionality.of(context));
}

// An abstract base class for the M2 and M3 defaults below, so that their return
// types can be non-nullable.
abstract class _TimePickerDefaults extends TimePickerThemeData {
  @override
  Color get backgroundColor;

  @override
  ButtonStyle get cancelButtonStyle;

  @override
  ButtonStyle get confirmButtonStyle;

  @override
  BorderSide get dayPeriodBorderSide;

  @override
  Color get dayPeriodColor;

  @override
  OutlinedBorder get dayPeriodShape;

  Size get dayPeriodInputSize;
  Size get dayPeriodLandscapeSize;
  Size get dayPeriodPortraitSize;

  @override
  Color get dayPeriodTextColor;

  @override
  TextStyle get dayPeriodTextStyle;

  @override
  Color get dialBackgroundColor;

  @override
  Color get dialHandColor;

  // Sizes that are generated from the tokens, but these aren't ones we're ready
  // to expose in the theme.
  Size get dialSize;
  double get handWidth;
  double get dotRadius;
  double get centerRadius;

  @override
  Color get dialTextColor;

  @override
  TextStyle get dialTextStyle;

  @override
  double get elevation;

  @override
  Color get entryModeIconColor;

  @override
  TextStyle get helpTextStyle;

  @override
  Color get hourMinuteColor;

  @override
  ShapeBorder get hourMinuteShape;

  Size get hourMinuteSize;
  Size get hourMinuteSize24Hour;
  Size get hourMinuteInputSize;
  Size get hourMinuteInputSize24Hour;

  @override
  Color get hourMinuteTextColor;

  @override
  TextStyle get hourMinuteTextStyle;

  @override
  InputDecorationTheme get inputDecorationTheme;

  @override
  EdgeInsetsGeometry get padding;

  @override
  ShapeBorder get shape;
}

// These theme defaults are not auto-generated: they match the values for the
// Material 2 spec, which are not expected to change.
class _TimePickerDefaultsM2 extends _TimePickerDefaults {
  _TimePickerDefaultsM2(this.context) : super();

  final BuildContext context;

  late final ColorScheme _colors = Theme.of(context).colorScheme;
  late final TextTheme _textTheme = Theme.of(context).textTheme;
  static const OutlinedBorder _kDefaultShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(4)),
  );

  @override
  Color get backgroundColor {
    return _colors.surface;
  }

  @override
  ButtonStyle get cancelButtonStyle {
    return TextButton.styleFrom();
  }

  // coverage:ignore-start
  @override
  ButtonStyle get confirmButtonStyle {
    return TextButton.styleFrom();
  }
  // coverage:ignore-end

  // coverage:ignore-start
  @override
  BorderSide get dayPeriodBorderSide {
    return BorderSide(
      color: Color.alphaBlend(
        _colors.onSurface.withValues(alpha: 0.38),
        _colors.surface,
      ),
    );
  }
  // coverage:ignore-end

  // coverage:ignore-start
  @override
  Color get dayPeriodColor {
    return WidgetStateColor.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return _colors.primary.withValues(
          alpha: _colors.brightness == Brightness.dark ? 0.24 : 0.12,
        );
      }
      // The unselected day period should match the overall picker dialog color.
      // Making it transparent enables that without being redundant and allows
      // the optional elevation overlay for dark mode to be visible.
      return Colors.transparent;
    });
  }
  // coverage:ignore-end

  // coverage:ignore-start
  @override
  OutlinedBorder get dayPeriodShape {
    return _kDefaultShape;
  }
  // coverage:ignore-end

  @override
  Size get dayPeriodPortraitSize {
    return const Size(52, 80);
  }

  // coverage:ignore-start
  @override
  Size get dayPeriodLandscapeSize {
    return const Size(0, 40);
  }
  // coverage:ignore-end

  // coverage:ignore-start
  @override
  Size get dayPeriodInputSize {
    return const Size(52, 70);
  }
  // coverage:ignore-end

  // coverage:ignore-start
  @override
  Color get dayPeriodTextColor {
    return WidgetStateColor.resolveWith((Set<WidgetState> states) {
      return states.contains(WidgetState.selected)
          ? _colors.primary
          : _colors.onSurface.withValues(alpha: 0.60);
    });
  }
  // coverage:ignore-end

  // coverage:ignore-start
  @override
  TextStyle get dayPeriodTextStyle {
    return _textTheme.titleMedium!.copyWith(color: dayPeriodTextColor);
  }
  // coverage:ignore-end

  @override
  Color get dialBackgroundColor {
    return _colors.onSurface.withValues(
      alpha: _colors.brightness == Brightness.dark ? 0.12 : 0.08,
    );
  }

  @override
  Color get dialHandColor {
    return _colors.primary;
  }

  @override
  Size get dialSize {
    return const Size.square(280);
  }

  @override
  double get handWidth {
    return 2;
  }

  @override
  double get dotRadius {
    return 22;
  }

  @override
  double get centerRadius {
    return 4;
  }

  @override
  Color get dialTextColor {
    return WidgetStateColor.resolveWith((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return _colors.surface;
      }
      return _colors.onSurface;
    });
  }

  @override
  TextStyle get dialTextStyle {
    return _textTheme.bodyLarge!;
  }

  @override
  double get elevation {
    return 6;
  }

  @override
  Color get entryModeIconColor {
    return _colors.onSurface.withValues(
      alpha: _colors.brightness == Brightness.dark ? 1.0 : 0.6,
    );
  }

  // coverage:ignore-start
  @override
  TextStyle get helpTextStyle {
    return _textTheme.labelSmall!;
  }
  // coverage:ignore-end

  @override
  Color get hourMinuteColor {
    return WidgetStateColor.resolveWith((Set<WidgetState> states) {
      return states.contains(WidgetState.selected)
          ? _colors.primary.withValues(
            alpha: _colors.brightness == Brightness.dark ? 0.24 : 0.12,
          )
          : _colors.onSurface.withValues(alpha: 0.12);
    });
  }

  @override
  ShapeBorder get hourMinuteShape {
    return _kDefaultShape;
  }

  @override
  Size get hourMinuteSize {
    return const Size(96, 80);
  }

  // coverage:ignore-start
  @override
  Size get hourMinuteSize24Hour {
    return const Size(114, 80);
  }
  // coverage:ignore-end

  @override
  Size get hourMinuteInputSize {
    return const Size(96, 70);
  }

  @override
  Size get hourMinuteInputSize24Hour {
    return const Size(114, 70);
  }

  @override
  Color get hourMinuteTextColor {
    return WidgetStateColor.resolveWith((Set<WidgetState> states) {
      return states.contains(WidgetState.selected)
          ? _colors.primary
          : _colors.onSurface;
    });
  }

  @override
  TextStyle get hourMinuteTextStyle {
    return _textTheme.displayMedium!;
  }

  Color get _hourMinuteInputColor {
    return WidgetStateColor.resolveWith((Set<WidgetState> states) {
      return states.contains(WidgetState.selected)
          ? Colors.transparent
          : _colors.onSurface.withValues(alpha: 0.12);
    });
  }

  @override
  InputDecorationTheme get inputDecorationTheme {
    return InputDecorationTheme(
      contentPadding: EdgeInsets.zero,
      filled: true,
      fillColor: _hourMinuteInputColor,
      focusColor: Colors.transparent,
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _colors.error, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _colors.primary, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _colors.error, width: 2),
      ),
      hintStyle: hourMinuteTextStyle.copyWith(
        color: _colors.onSurface.withValues(alpha: 0.36),
      ),
      // Prevent the error text from appearing.
      // https://github.com/flutter/flutter/issues/54104
      // is fixed.
      errorStyle: const TextStyle(fontSize: 0, height: 0),
    );
  }

  @override
  EdgeInsetsGeometry get padding {
    return const EdgeInsets.fromLTRB(8, 18, 8, 8);
  }

  @override
  ShapeBorder get shape {
    return _kDefaultShape;
  }
}
