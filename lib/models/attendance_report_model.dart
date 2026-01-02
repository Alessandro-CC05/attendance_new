class AttendanceReportRow {
  final String studentId;
  final String studentName;
  final int totalSessions;
  final int attendedSessions;

  AttendanceReportRow({
    required this.studentId,
    required this.studentName,
    required this.totalSessions,
    required this.attendedSessions,
  });

  double get percentage =>
      totalSessions == 0
          ? 0
          : (attendedSessions / totalSessions) * 100;
}
