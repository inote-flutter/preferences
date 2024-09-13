import 'package:flutter/material.dart';
import 'package:preferences/preference_service.dart';

class RadioPreference<T> extends StatefulWidget {
  final String title;
  final String? desc;
  final T val;
  final String localGroupKey;
  final bool selected;
  final bool isDefault;

  final Function? onSelect;
  final bool ignoreTileTap;

  final bool disabled;

  final Widget? leading;

  final Color activeColor;

  final Color inactiveColor;

  RadioPreference(
    this.title,
    this.val,
    this.localGroupKey, {
    this.desc,
    this.selected = false,
    this.ignoreTileTap = false,
    this.isDefault = false,
    this.onSelect,
    this.disabled = false,
    this.leading,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.blue,
  });

  @override
  _RadioPreferenceState createState() => _RadioPreferenceState();
}

class _RadioPreferenceState<T> extends State<RadioPreference<T>> {
  @override
  late BuildContext context;

  @override
  void initState() {
    super.initState();
    // PrefService.onNotify(widget.localGroupKey, () {
    //   try {
    //     setState(() {});
    //   } catch (e) {
    //     print(e);
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
    PrefService.onNotifyRemove(widget.localGroupKey);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDefault && PrefService.get(widget.localGroupKey) == null) {
      onChange(widget.val);
    }

    this.context = context;
    return ListTile(
      title: Text(widget.title),
      leading: widget.leading,
      subtitle: widget.desc == null ? null : Text(widget.desc!),
      trailing: Radio<T>(
        value: widget.val,
        groupValue: PrefService.get(widget.localGroupKey),
        // activeColor: widget.activeColor,
        fillColor:
            WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return widget.activeColor;
          }
          return widget.inactiveColor;
        }),
        onChanged: widget.disabled ? null : (var val) => onChange(widget.val),
      ),
      onTap: (widget.ignoreTileTap || widget.disabled)
          ? null
          : () => onChange(widget.val),
    );
  }

  void onChange(T val) {
    if (val is String) {
      PrefService.setString(widget.localGroupKey, val);
    } else if (val is int) {
      PrefService.setInt(widget.localGroupKey, val);
    } else if (val is double) {
      PrefService.setDouble(widget.localGroupKey, val);
    } else if (val is bool) {
      PrefService.setBool(widget.localGroupKey, val);
    }

    if (widget.onSelect != null) widget.onSelect!();

    // PrefService.notify(widget.localGroupKey);
    if (mounted) setState(() {});
  }
}
