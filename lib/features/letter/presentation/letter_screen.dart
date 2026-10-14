import 'package:bk_absen/features/letter/presentation/widgets/letter_item.dart';
import 'package:bk_absen/features/letter/provider/letter_provider.dart';
import 'package:bk_absen/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LetterScreen extends ConsumerStatefulWidget {
  final String title;

  const LetterScreen({super.key, required this.title});

  @override
  ConsumerState<LetterScreen> createState() => _LetterScreenState();
}

class _LetterScreenState extends ConsumerState<LetterScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(letterProvider);
    final notifier = ref.read(letterProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Surat Peringatan',
          style: TextStyle(
            color: AppColors.light,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.data.isEmpty
          ? RefreshIndicator(
              onRefresh: () async {
                await notifier.load();
              },
              child: _buildEmptyState(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await notifier.load();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.data.length,
                  itemBuilder: (context, index) {
                    return LetterItem(
                      letter: state.data[index],

                      onRead: () => notifier.markAsRead(state.data[index].id),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bottomInset = MediaQuery.of(context).padding.bottom;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            width: double.infinity,
            height: constraints.maxHeight,
            child: Center(
              child: Transform.translate(
                offset: Offset(0, -bottomInset / 2),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF016E0A,
                          ).withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.mailWarning,
                          size: 44,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Belum Ada Surat',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Belum ada surat peringatan yang tercatat.',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
