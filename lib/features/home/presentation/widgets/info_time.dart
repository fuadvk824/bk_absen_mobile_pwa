// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class InfoItem extends StatelessWidget {
//   final String time;
//   final String label;

//   const InfoItem({super.key, required this.time, required this.label});

//   @override
//   Widget build(BuildContext context) {
//      String time = DateFormat('HH:mm:ss').format(_now);
//     String date = DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(_now);
//     return Positioned(
//       top: MediaQuery.of(context).padding.top + 20,
//       left: 0,
//       right: 0,
//       child: Center(
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//           decoration: BoxDecoration(
//             color: Colors.white.withValues(alpha: .9),
//             borderRadius: BorderRadius.circular(100),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(date, style: const TextStyle(fontSize: 10)),
//               Text(
//                 time,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
