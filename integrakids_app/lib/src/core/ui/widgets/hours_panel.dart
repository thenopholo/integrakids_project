import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_font.dart';

class HoursPanel extends StatefulWidget {
  final List<int>? enableHours;
  final int startTime;
  final int endTime;
  final ValueChanged<int> onTimePressed;
  final bool singleSelection;

  const HoursPanel({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onTimePressed,
    this.enableHours,
  }) : singleSelection = false;

  const HoursPanel.singleSelection({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onTimePressed,
    this.enableHours,
  }) : singleSelection = true;

  @override
  State<HoursPanel> createState() => _HoursPanelState();
}

class _HoursPanelState extends State<HoursPanel> {
  int? lastSelection;

  @override
  Widget build(BuildContext context) {
    final HoursPanel(:singleSelection) = widget;
    // ignore: prefer_const_constructors
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecione os horários de atendimento',
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
          Wrap(
            spacing: 26,
            runSpacing: 12,
            children: [
              for (int i = widget.startTime; i <= widget.endTime; i++)
                TimeButton(
                  enableHours: widget.enableHours,
                  time: '${i.toString().padLeft(2, '0')}:00',
                  value: i,
                  singleSelection: singleSelection,
                  timeSelected: lastSelection,
                  onTimePressed: (timeSelected) {
                    setState(() {
                      if (singleSelection) {
                        if (lastSelection == timeSelected) {
                          lastSelection = null;
                        } else {
                          lastSelection = timeSelected;
                        }
                      }
                    });

                    widget.onTimePressed(timeSelected);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class TimeButton extends StatefulWidget {
  final List<int>? enableHours;
  final String time;
  final int value;
  final ValueChanged<int> onTimePressed;
  final bool singleSelection;
  final int? timeSelected;

  const TimeButton({
    super.key,
    required this.time,
    required this.value,
    required this.onTimePressed,
    this.enableHours,
    required this.singleSelection,
    required this.timeSelected,
  });

  @override
  State<TimeButton> createState() => _TimeButtonState();
}

class _TimeButtonState extends State<TimeButton> {
  var selected = false;
  @override
  Widget build(BuildContext context) {
    final TimeButton(
      :value,
      :time,
      :enableHours,
      :onTimePressed,
      :singleSelection,
      :timeSelected
    ) = widget;

    if (singleSelection) {
      if (timeSelected != null) {
        if (timeSelected == value) {
          selected = true;
        } else {
          selected = false;
        }
      }
    }

    final textColor = selected ? Colors.white : AppColors.integraBrown;
    var btnColor = selected ? AppColors.integraBrown : Colors.white;

    final disableHours = enableHours != null && !enableHours.contains(value);
    if (disableHours) {
      btnColor = Colors.grey[400]!;
    }

    return InkWell(
      onTap: disableHours
          ? null
          : () {
              setState(() {
                onTimePressed(value);
                selected = !selected;
              });
            },
      child: Container(
        width: 64,
        height: 36,
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
            time,
            style: TextStyle(
              fontFamily: AppFont.primaryFont,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
