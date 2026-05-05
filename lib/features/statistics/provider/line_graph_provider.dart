// 최초 작성자: 김채영
import 'package:flutter_riverpod/flutter_riverpod.dart';

// true면 월간, false면 주간
final graphTypeProvider = StateProvider<bool>((ref) => true);
