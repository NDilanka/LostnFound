import 'package:cloud_firestore/cloud_firestore.dart';

String formatShortDate(Timestamp? timestamp) {
  if (timestamp == null) return 'Date unknown';
  final date = timestamp.toDate();
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String formatFullDate(Timestamp? timestamp) {
  if (timestamp == null) return 'Date unknown';
  final date = timestamp.toDate();
  final months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
  final amPm = date.hour >= 12 ? 'PM' : 'AM';
  final minute = date.minute.toString().padLeft(2, '0');
  return '${months[date.month - 1]} ${date.day}, ${date.year} at $hour:$minute $amPm';
}
