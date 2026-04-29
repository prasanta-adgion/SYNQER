// class DateTimeUtils{


//   static  parseChatDateTime(String isoDate) {
//   try {
//     final dateTime = DateTime.parse(isoDate).toLocal();

//     final date = DateFormat('dd MMM yyyy').format(dateTime);
//     final time = DateFormat('h:mm a').format(dateTime);

//     return ChatDateTime(date: date, time: time);
//   } catch (e) {
//     return ChatDateTime(date: '', time: '');
//   }
// }
// }