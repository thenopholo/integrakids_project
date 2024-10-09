import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_font.dart';

class WeekdaysPanel extends StatelessWidget {
  final List<String>? enableDays;
  final ValueChanged<String> onDayPressed;
  const WeekdaysPanel({
    super.key,
    required this.onDayPressed,
    this.enableDays,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecione os dias da semana',
            style: TextStyle(
              fontFamily: AppFont.primaryFont,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.integraBrown,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonDay(
                  label: 'Seg',
                  onDaySelected: onDayPressed,
                  enableDays: enableDays,
                ),
                ButtonDay(
                  label: 'Ter',
                  onDaySelected: onDayPressed,
                  enableDays: enableDays,
                ),
                ButtonDay(
                  label: 'Qua',
                  onDaySelected: onDayPressed,
                  enableDays: enableDays,
                ),
                ButtonDay(
                  label: 'Qui',
                  onDaySelected: onDayPressed,
                  enableDays: enableDays,
                ),
                ButtonDay(
                  label: 'Sex',
                  onDaySelected: onDayPressed,
                  enableDays: enableDays,
                ),
                ButtonDay(
                  label: 'Sab',
                  onDaySelected: onDayPressed,
                  enableDays: enableDays,
                ),
                ButtonDay(
                  label: 'Dom',
                  onDaySelected: onDayPressed,
                  enableDays: enableDays,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ButtonDay extends StatefulWidget {
  final List<String>? enableDays;
  final String label;
  final ValueChanged<String> onDaySelected;

  const ButtonDay({
    super.key,
    required this.label,
    required this.onDaySelected,
    this.enableDays,
  });

  @override
  State<ButtonDay> createState() => _ButtonDayState();
}

class _ButtonDayState extends State<ButtonDay> {
  var selected = false;

  @override
  Widget build(BuildContext context) {
    final textColor = selected ? Colors.white : AppColors.integraBrown;
    var btnColor = selected ? AppColors.integraBrown : Colors.white;

    final ButtonDay(:enableDays, :label) = widget;

    final disableDay = enableDays != null && !enableDays.contains(label);
    if (disableDay) {
      btnColor = Colors.grey[400]!;
    }

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: disableDay
            ? null
            : () {
                widget.onDaySelected(label);
                setState(() {
                  selected = !selected;
                });
              },
        child: Container(
          width: 40,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: btnColor,
            border: Border.all(
              color: AppColors.integraBrown,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(5, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: AppFont.primaryFont,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
