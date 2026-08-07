// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

class EditArticleDialog extends StatefulWidget {
  final String initialContent;
  const EditArticleDialog({super.key, required this.initialContent});

  @override
  State<EditArticleDialog> createState() => _EditArticleDialogState();
}

class _EditArticleDialogState extends State<EditArticleDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Dialog(
      backgroundColor: appColors.whiteToBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('댓글 수정', style: AppTypography.h3),
            const SizedBox(height: 15),
            TextField(
              controller: _controller,
              autofocus: false, // 화면 리빌드될 때마다 키보드를 불러오지 않기!
              maxLines: 5,
              decoration: InputDecoration(
                filled: true,
                fillColor: appColors.gray5,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('취소', style: TextStyle(color: appColors.gray2)),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _controller.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColors.primaryAble,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      '수정완료',
                      style: TextStyle(color: appColors.whiteToBlack),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
