import 'package:bk_absen/model/user_model.dart';
import 'package:bk_absen/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeaderSection extends ConsumerWidget {
  final UserModel? user;
  final VoidCallback? onRefresh;
  final bool isRefreshing;

  const HeaderSection({
    super.key,
    this.user,
    this.onRefresh,
    this.isRefreshing = false,
  });

  String _shortenName(String? name, double maxWidth) {
    if (name == null || name.trim().isEmpty) {
      return '-';
    }

    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.length <= 2) {
      return name.trim();
    }

    final fullName = parts.join(' ');

    final painter = TextPainter(
      text: TextSpan(
        text: fullName,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    if (!painter.didExceedMaxLines) {
      return fullName;
    }

    final result = <String>[parts[0], parts[1]];

    for (int i = 2; i < parts.length; i++) {
      final candidate = [...result, '${parts[i][0].toUpperCase()}.'].join(' ');

      final candidatePainter = TextPainter(
        text: TextSpan(
          text: candidate,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: maxWidth);

      if (candidatePainter.didExceedMaxLines) {
        break;
      }

      result.add('${parts[i][0].toUpperCase()}.');
    }

    return result.join(' ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundImage: AssetImage(
                    user?.jenisKelamin == 'L'
                        ? "assets/images/profile_L.png"
                        : "assets/images/profile_P.png",
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final displayName = _shortenName(
                        user?.name,
                        constraints.maxWidth,
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user?.department ?? "-",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          InkWell(
            onTap: isRefreshing ? null : onRefresh,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.muted),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isRefreshing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: Padding(
                        padding: EdgeInsets.all(11),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.refresh, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
