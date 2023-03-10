import 'package:flutter/material.dart';

class DisplayField extends StatelessWidget {
  final String label;
  final String value;

  const DisplayField(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: label,
        children: <TextSpan>[
          TextSpan(
              text: value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
