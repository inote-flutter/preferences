import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';

class SwitchPreference extends StatefulWidget {
  final String title;
  final String? desc;
  final String localKey;
  final bool defaultVal;
  final bool ignoreTileTap;

  final bool resetOnException;

  final Function? onEnable;
  final Function? onDisable;
  final Function? onChange;

  final bool disabled;

  final Color? activeColor;
  final Color? inactiveThumbColor;
  final Color? inactiveTrackColor;
  final Color? trackOutlineColor;
  final double? trackOutlineWidth;

  SwitchPreference(
    this.title,
    this.localKey, {
    this.desc,
    this.defaultVal = false,
    this.ignoreTileTap = false,
    this.resetOnException = true,
    this.onEnable,
    this.onDisable,
    this.onChange,
    this.disabled = false,
    this.activeColor = Colors.blue,
    this.inactiveThumbColor = Colors.blue,
    this.inactiveTrackColor = Colors.transparent,
    this.trackOutlineColor = Colors.grey,
    this.trackOutlineWidth = 1,
  });

  @override
  _SwitchPreferenceState createState() => _SwitchPreferenceState();
}

class _SwitchPreferenceState extends State<SwitchPreference> {
  @override
  void initState() {
    super.initState();
    if (PrefService.getBool(widget.localKey) == null) {
      PrefService.setBool(widget.localKey, widget.defaultVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.title),
      subtitle: widget.desc == null ? null : Text(widget.desc!),
      trailing: Switch.adaptive(
        value: PrefService.getBool(widget.localKey) ?? widget.defaultVal,
        activeColor: widget.activeColor,
        inactiveThumbColor: widget.inactiveThumbColor,
        inactiveTrackColor: widget.inactiveTrackColor,
        trackOutlineColor: widget.trackOutlineColor != null
            ? WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) => widget.trackOutlineColor!)
            : null,
        trackOutlineWidth: widget.trackOutlineWidth != null
            ? WidgetStateProperty.resolveWith<double>(
                (Set<WidgetState> states) => widget.trackOutlineWidth!)
            : null,
        onChanged:
            widget.disabled ? null : (val) => val ? onEnable() : onDisable(),
      ),
      onTap: (widget.disabled || widget.ignoreTileTap)
          ? null
          : () => (PrefService.getBool(widget.localKey) ?? widget.defaultVal)
              ? onDisable()
              : onEnable(),
    );
  }

  void onEnable() async {
    PrefService.setBool(widget.localKey, true);
    if (widget.onChange != null) widget.onChange!();
    if (widget.onEnable != null) {
      try {
        await widget.onEnable!();
      } catch (e) {
        if (widget.resetOnException) {
          PrefService.setBool(widget.localKey, false);
        }
        if (mounted) PrefService.showError(context, e.toString());
      }
    }
    if (mounted) setState(() {});
  }

  void onDisable() async {
    PrefService.setBool(widget.localKey, false);
    if (widget.onChange != null) widget.onChange!();
    if (widget.onDisable != null) {
      try {
        await widget.onDisable!();
      } catch (e) {
        if (widget.resetOnException) {
          PrefService.setBool(widget.localKey, true);
        }
        if (mounted) PrefService.showError(context, e.toString());
      }
    }
    if (mounted) setState(() {});
  }
}
