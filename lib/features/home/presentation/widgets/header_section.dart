import 'package:bk_absen/features/auth/provider/auth_provider.dart';
import 'package:bk_absen/model/user_model.dart';
import 'package:bk_absen/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HeaderSection extends ConsumerWidget {
  final UserModel? user;

  const HeaderSection({super.key, this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage("assets/images/profile.png"),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? "-",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${user?.department ?? "-"} - STAFF",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          InkWell(
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.muted),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.mailCheck, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
