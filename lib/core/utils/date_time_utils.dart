import 'package:intl/intl.dart';
import 'package:synqer_io/core/model/iso_datetime_model.dart';

class DateTimeUtils {
  static IsoDatetimeModel parseChatDateTime(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate).toLocal();

      final date = DateFormat('dd MMM yyyy').format(dateTime);
      final time = DateFormat('h:mm a').format(dateTime);

      return IsoDatetimeModel(date: date, time: time);
    } catch (e) {
      return IsoDatetimeModel(date: '', time: '');
    }
  }
}
