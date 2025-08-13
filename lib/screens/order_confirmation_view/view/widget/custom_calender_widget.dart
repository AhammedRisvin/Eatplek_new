import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomCalendarWidget extends StatelessWidget {
  final Function(DateTime) onDateSelected;
  final Color? primaryColor;
  final Color? backgroundColor;
  final TextStyle? headerTextStyle;
  final TextStyle? dayTextStyle;
  final TextStyle? selectedDayTextStyle;

  const CustomCalendarWidget({
    super.key,
    required this.onDateSelected,
    this.primaryColor,
    this.backgroundColor,
    this.headerTextStyle,
    this.dayTextStyle,
    this.selectedDayTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CalendarController>(
      id: 'calendar',
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCalendarHeader(controller),
              const SizedBox(height: 20),
              _buildWeekDays(),
              const SizedBox(height: 10),
              _buildCalendarGrid(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarHeader(CalendarController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => controller.navigateMonth(false),
          icon: const Icon(Icons.chevron_left, size: 24, color: Colors.grey),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Text(
            controller.getFormattedMonth(),
            style: headerTextStyle ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ),
        IconButton(
          onPressed: () => controller.navigateMonth(true),
          icon: const Icon(Icons.chevron_right, size: 24, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildWeekDays() {
    List<String> weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children:
          weekdays
              .map(
                (day) => SizedBox(
                  width: 35,
                  child: Center(
                    child: Text(
                      day,
                      style:
                          dayTextStyle ??
                          const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildCalendarGrid(CalendarController controller) {
    List<Widget> dayWidgets = [];

    // Get first day of month and calculate starting day of week
    DateTime firstDay = DateTime(controller.currentMonth.year, controller.currentMonth.month, 1);
    int startingDayOfWeek = (firstDay.weekday - 1) % 7; // Monday = 0

    // Get days in current month
    int daysInMonth = DateTime(controller.currentMonth.year, controller.currentMonth.month + 1, 0).day;

    // Get days in previous month for padding
    DateTime prevMonth = DateTime(controller.currentMonth.year, controller.currentMonth.month - 1);
    int daysInPrevMonth = DateTime(prevMonth.year, prevMonth.month + 1, 0).day;

    // Add previous month days
    for (int i = startingDayOfWeek - 1; i >= 0; i--) {
      dayWidgets.add(
        _buildDayWidget(
          controller,
          daysInPrevMonth - i,
          isCurrentMonth: false,
          date: DateTime(prevMonth.year, prevMonth.month, daysInPrevMonth - i),
        ),
      );
    }

    // Add current month days
    for (int day = 1; day <= daysInMonth; day++) {
      dayWidgets.add(
        _buildDayWidget(
          controller,
          day,
          isCurrentMonth: true,
          date: DateTime(controller.currentMonth.year, controller.currentMonth.month, day),
        ),
      );
    }

    // Add next month days to fill the grid
    DateTime nextMonth = DateTime(controller.currentMonth.year, controller.currentMonth.month + 1);
    int remainingCells = 42 - dayWidgets.length; // 6 rows * 7 days
    for (int day = 1; day <= remainingCells && dayWidgets.length < 42; day++) {
      dayWidgets.add(
        _buildDayWidget(controller, day, isCurrentMonth: false, date: DateTime(nextMonth.year, nextMonth.month, day)),
      );
    }

    return GridView.count(shrinkWrap: true, crossAxisCount: 7, children: dayWidgets);
  }

  Widget _buildDayWidget(
    CalendarController controller,
    int day, {
    required bool isCurrentMonth,
    required DateTime date,
  }) {
    bool isSelected = controller.isDateSelected(date);
    bool isToday = controller.isToday(date);
    bool isSelectable = controller.isDateSelectable(date);

    // Only show containers for current month selectable dates and today
    bool showContainer = isCurrentMonth && (isSelectable || isToday);

    Color? backgroundColor;
    Color? borderColor;
    Color textColor = Colors.grey[400]!;

    if (showContainer) {
      if (isSelected) {
        backgroundColor = primaryColor ?? Colors.blue[600];
        textColor = Colors.white;
      } else if (isToday) {
        backgroundColor = Colors.white;
        borderColor = primaryColor ?? Colors.blue[600];
        textColor = Colors.black87;
      } else if (isSelectable) {
        backgroundColor = Colors.white;
        textColor = Colors.grey[600]!;
      }
    } else if (isCurrentMonth && !isSelectable) {
      // Unselectable dates in current month - no container, grey text
      textColor = Colors.grey[300]!;
    }

    return GestureDetector(
      onTap:
          (isCurrentMonth && isSelectable)
              ? () {
                controller.selectDate(date);
                onDateSelected(date);
              }
              : null,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration:
            showContainer
                ? BoxDecoration(
                  color: backgroundColor,
                  border: borderColor != null ? Border.all(color: borderColor, width: 2) : null,
                  borderRadius: BorderRadius.circular(8),
                )
                : null,
        child: Center(
          child: Text(
            day.toString(),
            style:
                isSelected && selectedDayTextStyle != null
                    ? selectedDayTextStyle!
                    : TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class CalendarController extends GetxController {
  DateTime? selectedDate;
  DateTime currentMonth = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    currentMonth = DateTime.now();
  }

  void navigateMonth(bool isNext) {
    if (isNext) {
      // Only allow navigation up to 2 months from today
      DateTime twoMonthsFromNow = DateTime(DateTime.now().year, DateTime.now().month + 2);
      if (currentMonth.isBefore(twoMonthsFromNow)) {
        currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
      }
    } else {
      // Only allow navigation back to current month
      DateTime today = DateTime.now();
      DateTime currentMonthOnly = DateTime(today.year, today.month);
      if (currentMonth.isAfter(currentMonthOnly)) {
        currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
      }
    }
    update(['calendar']);
  }

  void selectDate(DateTime date) {
    selectedDate = date;
    update(['calendar']);
  }

  String getFormattedMonth() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[currentMonth.month - 1]} ${currentMonth.year}';
  }

  bool isDateSelectable(DateTime date) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final twoMonthsFromToday = DateTime(today.year, today.month + 2, today.day);

    // Allow selection from today up to 2 months from today
    return (dateOnly.isAfter(todayOnly) || dateOnly.isAtSameMomentAs(todayOnly)) &&
        dateOnly.isBefore(twoMonthsFromToday);
  }

  bool isDateSelected(DateTime date) {
    if (selectedDate == null) return false;
    return selectedDate!.year == date.year && selectedDate!.month == date.month && selectedDate!.day == date.day;
  }

  bool isToday(DateTime date) {
    final today = DateTime.now();
    return today.year == date.year && today.month == date.month && today.day == date.day;
  }
}
