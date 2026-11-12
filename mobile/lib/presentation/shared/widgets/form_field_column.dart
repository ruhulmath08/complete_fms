import 'package:flutter/material.dart';

/// Vertical stack for form controls with a consistent **8px** gap between fields.
class FormFieldColumn extends StatelessWidget {
  const FormFieldColumn({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  static const double gap = 16;

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      spacing: gap,
      children: children,
    );
  }
}
