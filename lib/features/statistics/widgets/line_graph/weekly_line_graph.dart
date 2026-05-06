// // 최초 작성자: 김채영
// import 'package:flutter/material.dart';
// import 'package:haenaem/core/theme/app_colors.dart';
// import 'package:haenaem/core/theme/app_typography.dart';

// // 주간 데이터 모델
// class DailyGraphData {
//   final List<int> thisWeek;
//   final List<int> lastWeek;
//   const DailyGraphData({required this.thisWeek, required this.lastWeek});
// }

// // 주간 라인 그래프 (7일 기준)
// class WeeklyLineGraph extends StatelessWidget {
//   final DailyGraphData data;
//   const WeeklyLineGraph({super.key, required this.data});

//   @override
//   Widget build(BuildContext context) {
//     final allValues = [...data.thisWeek, ...data.lastWeek];
//     final maxValue = allValues.isEmpty
//         ? 10
//         : ((allValues.reduce((a, b) => a > b ? a : b) / 5).ceil() * 5)
//               .toDouble();

//     final yLabels = [
//       maxValue.toInt(),
//       (maxValue * 2 ~/ 3),
//       (maxValue * 1 ~/ 3),
//       0,
//     ];
//     const xLabels = ['월', '화', '수', '목', '금', '토', '일'];

//     return Column(
//       children: [
//         Expanded(
//           child: Row(
//             children: [
//               _buildYAxis(yLabels),
//               Expanded(
//                 child: CustomPaint(
//                   painter: _LineGraphPainter(
//                     thisPeriod: data.thisWeek,
//                     lastPeriod: data.lastWeek,
//                     maxValue: maxValue,
//                     pointCount: 7, // ✅ 점 7개
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         _buildXAxis(xLabels),
//       ],
//     );
//   }

//   // Y축 레이블 빌더 (스타일 유지)
//   Widget _buildYAxis(List<int> labels) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 8),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: labels
//             .map(
//               (l) => Text(
//                 '$l',
//                 style: const TextStyle(color: Color(0xFF444444), fontSize: 12),
//               ),
//             )
//             .toList(),
//       ),
//     );
//   }

//   // X축 레이블 빌더 (스타일 유지)
//   Widget _buildXAxis(List<String> labels) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 24, top: 8),
//       child: Row(
//         children: labels
//             .map(
//               (l) => Expanded(
//                 child: Text(
//                   l,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     color: Color(0xFF444444),
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//             )
//             .toList(),
//       ),
//     );
//   }
// }
