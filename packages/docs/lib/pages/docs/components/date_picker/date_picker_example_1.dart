import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:gap/gap.dart';

/// DatePicker in popover and dialog modes with disabled future dates.
///
/// Demonstrates single-date selection with two different prompt UIs:
/// - [PromptMode.popover]: inline, anchored overlay.
/// - [PromptMode.dialog]: modal dialog with a custom [dialogTitle].
class DatePickerExample1 extends StatefulWidget {
  const DatePickerExample1({super.key});

  @override
  State<DatePickerExample1> createState() => _DatePickerExample1State();
}

class _DatePickerExample1State extends State<DatePickerExample1> {
  DateTime? _value;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DatePicker(
          value: _value,
          // Disable selecting dates after "today".
          stateBuilder: (date) {
            if (date.isAfter(DateTime.now())) {
              return DateState.disabled;
            }
            return DateState.enabled;
          },
          onChanged: (value) {
            setState(() {
              _value = value;
            });
          },
          theme: DatePickerTheme(mode: PromptMode.popover),
        ),
        const Gap(16),
        DatePicker(
          value: _value,
          // Title shown at the top of the dialog variant.
          dialogTitle: const Text('Select Date'),
          stateBuilder: (date) {
            if (date.isAfter(DateTime.now())) {
              return DateState.disabled;
            }
            return DateState.enabled;
          },
          onChanged: (value) {
            setState(() {
              _value = value;
            });
          },
          theme: DatePickerTheme(mode: PromptMode.dialog),
        ),
      ],
    );
  }
}
