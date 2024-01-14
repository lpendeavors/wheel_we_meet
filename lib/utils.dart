import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

List<List<T>> splitList<T>(List<T> list, int chunkSize) {
  List<List<T>> chunks = [];
  for (int i = 0; i < list.length; i += chunkSize) {
    int end = (i + chunkSize < list.length) ? i + chunkSize : list.length;
    chunks.add(list.sublist(i, end));
  }
  return chunks;
}

Map<String, bool> mapToBoolMap(Map<dynamic, dynamic>? map) {
  if (map == null) return {};
  return map.map((key, value) => MapEntry(key as String, value as bool));
}

String formatTimestamp(DateTime timestamp) {
  final DateTime now = DateTime.now();
  final DateTime localTimestamp = timestamp.toLocal();

  if (now.difference(localTimestamp).inDays < 1 &&
      localTimestamp.day == now.day) {
    // If the timestamp is from today, show the time only
    return DateFormat('h:mm a').format(localTimestamp);
  } else {
    // Otherwise, use timeago for past dates
    return timeago.format(localTimestamp);
  }
}

Future<bool?> showConfirmation({
  required BuildContext context,
  required String title,
  required String content,
  required String confirmButtonText,
  Color confirmButtonTextColor = Colors.red,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmButtonText,
              style: TextStyle(color: confirmButtonTextColor),
            ),
          ),
        ],
      );
    },
  );
}

String first25Words(String sentence) {
  var words = sentence.split(' ');
  if (words.length <= 25) {
    return sentence;
  } else {
    return '${words.take(20).join(' ')}...';
  }
}
