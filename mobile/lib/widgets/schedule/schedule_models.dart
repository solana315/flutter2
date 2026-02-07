enum SlotStatus { available, unavailable }

class Doctor {
  final String id;
  final String name;
  const Doctor({required this.id, required this.name});
}

class Specialty {
  final String id;
  final String name;
  const Specialty({required this.id, required this.name});
}

class DayOption {
  final DateTime date;
  final String labelWeekday;
  final int dayNumber;
  const DayOption({
    required this.date,
    required this.labelWeekday,
    required this.dayNumber,
  });
}

class TimeSlot {
  final String timeLabel;
  final SlotStatus status;
  const TimeSlot({required this.timeLabel, required this.status});
}
