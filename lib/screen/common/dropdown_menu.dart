import 'package:flutter/material.dart';

/// DropdownButton の共通化
class DropdownButtonMenu extends StatefulWidget {
  final String? initialValue;
  final List<String> choices;
  final ValueChanged<String> onChanged;

  const DropdownButtonMenu({
    super.key,
    required this.initialValue,
    required this.choices,
    required this.onChanged,
  });

  @override
  State<DropdownButtonMenu> createState() => _DropdownButtonMenuState();
}

class _DropdownButtonMenuState extends State<DropdownButtonMenu> {
  late String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      items: widget.choices.map<DropdownMenuItem<String>>(
        (String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        },
      ).toList(),
      underline: Container(),
      style: const TextStyle(
        color: Color(0xFF888888),
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      value: selectedValue,
      onChanged: (String? value) {
        if (value != null) {
          setState(
            () {
              selectedValue = value;
              widget.onChanged(value);
            },
          );
        }
      },
    );
  }
}
