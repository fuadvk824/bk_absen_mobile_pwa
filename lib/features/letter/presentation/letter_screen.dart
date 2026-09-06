import 'package:bk_absen/features/letter/presentation/widgets/letter_item.dart';
import 'package:bk_absen/features/letter/provider/letter_provider.dart';
import 'package:bk_absen/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 250,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mail_outline,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Belum ada surat',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
                    // return LetterItem(letter: state.data[index]);
                    return LetterItem(
                      letter: state.data[index],
                      onRead: () async {
                        await notifier.markAsRead(state.data[index].id);
                      },
                    );
                  },
                ),
              ),
            ),
    );
  }
}
