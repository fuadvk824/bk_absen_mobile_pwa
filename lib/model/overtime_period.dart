import 'package:bk_absen/model/overtime_model.dart';

class OvertimeResponse {
  final List<OvertimeModel> data;
  final int totalOvertimeMinutes;

  OvertimeResponse({
    required this.data,
    required this.totalOvertimeMinutes,
  });
}

class OvertimePeriod {
  final int value;
  final String label;

  const OvertimePeriod({required this.value, required this.label});
}

const overtimePeriods = [
  OvertimePeriod(value: 12, label: '26 Des - 25 Jan'),
  OvertimePeriod(value: 1, label: '26 Jan - 25 Feb'),
  OvertimePeriod(value: 2, label: '26 Feb - 25 Mar'),
  OvertimePeriod(value: 3, label: '26 Mar - 25 Apr'),
  OvertimePeriod(value: 4, label: '26 Apr - 25 Mei'),
  OvertimePeriod(value: 5, label: '26 Mei - 25 Jun'),
  OvertimePeriod(value: 6, label: '26 Jun - 25 Jul'),
  OvertimePeriod(value: 7, label: '26 Jul - 25 Ags'),
  OvertimePeriod(value: 8, label: '26 Ags - 25 Sep'),
  OvertimePeriod(value: 9, label: '26 Sep - 25 Okt'),
  OvertimePeriod(value: 10, label: '26 Okt - 25 Nov'),
  OvertimePeriod(value: 11, label: '26 Nov - 25 Des'),
];

int getCurrentOvertimePeriod() {
  final now = DateTime.now();

  if (now.day >= 26) {
    return now.month;
  }

  return now.month == 1 ? 12 : now.month - 1;
}
