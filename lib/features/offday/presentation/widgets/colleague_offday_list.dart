import 'package:bk_absen/model/colleague_offday_model.dart';
import 'package:bk_absen/model/colleague_schedule_model.dart';
import 'package:bk_absen/model/colleague_pending_request_model.dart';
import 'package:bk_absen/features/offday/provider/offday_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ColleagueOffdayList extends StatelessWidget {
  const ColleagueOffdayList({
    super.key,
    required this.state,
  });

  final OffdayState state;

  String _formatDate(String date) {
    try {
      return DateFormat('dd MMMM yyyy', 'id_ID')
          .format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colleagues = state.colleagueOffdays;
    final pendingColleagues = state.colleaguePendingRequests;

    if (colleagues.isEmpty && pendingColleagues.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.groups_outlined, color: Colors.grey),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Belum ada jadwal libur atau pengajuan '
                'libur rekan kerja.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    final sortedColleagues = [...colleagues]
      ..sort(
        (a, b) => a.employeeName
            .toLowerCase()
            .compareTo(b.employeeName.toLowerCase()),
      );

    final sortedPending = [...pendingColleagues]
      ..sort(
        (a, b) => a.employeeName
            .toLowerCase()
            .compareTo(b.employeeName.toLowerCase()),
      );

    final totalPending = pendingColleagues.fold<int>(
      0,
      (total, colleague) =>
          total + colleague.pendingRequests.length,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.red.withValues(alpha: .2),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 4,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            14,
            0,
            14,
            8,
          ),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: .1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.users,
              color: Colors.red,
            ),
          ),
          title: const Text(
            'Jadwal & Pengajuan Libur Rekan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${colleagues.length} rekan dengan jadwal libur • '
            '$totalPending pengajuan pending',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          children: [
             
            if (sortedColleagues.isNotEmpty) ...[
              const _SectionTitle(
                title: 'Jadwal Libur',
                icon: Icons.event_available,
                color: Colors.red,
              ),
              ...sortedColleagues.map((colleague) {
                final offdays = [...colleague.offdays]
                  ..sort(
                    (a, b) =>
                        a.workDate.compareTo(b.workDate),
                  );

                return _ColleagueCard(
                  colleague: colleague,
                  offdays: offdays,
                  formatDate: _formatDate,
                );
              }),
            ],

            if (sortedPending.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const _SectionTitle(
                title: 'Pengajuan Libur Pending',
                icon: Icons.hourglass_top_rounded,
                color: Colors.orange,
              ),
              ...sortedPending.map((colleague) {
                final requests = [
                  ...colleague.pendingRequests,
                ]..sort(
                    (a, b) => a.date.compareTo(b.date),
                  );

                return _PendingColleagueCard(
                  employeeName: colleague.employeeName,
                  requests: requests,
                  formatDate: _formatDate,
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColleagueCard extends StatelessWidget {
  const _ColleagueCard({
    required this.colleague,
    required this.offdays,
    required this.formatDate,
  });

  final ColleagueScheduleModel colleague;
  final List<ColleagueOffdayModel> offdays;
  final String Function(String) formatDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: .04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withValues(alpha: .18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            colleague.employeeName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${offdays.length} tanggal libur',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          if (offdays.isEmpty)
            const Text(
              'Belum ada tanggal libur.',
              style: TextStyle(color: Colors.grey),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: offdays.map((offday) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.calendarX,
                        size: 14,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formatDate(offday.workDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _PendingColleagueCard extends StatelessWidget {
  const _PendingColleagueCard({
    required this.employeeName,
    required this.requests,
    required this.formatDate,
  });

  final String employeeName;
  final List<ColleaguePendingRequestModel> requests;
  final String Function(String) formatDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: .25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 20,
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  employeeName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PENDING',
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${requests.length} pengajuan menunggu persetujuan',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          ...requests.map((request) {
            final isChangingToOff =
                request.statusEndDate == 'libur';

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        size: 17,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          formatDate(request.date),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatusChip(
                        label: request.statusStartDate,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: Colors.grey,
                        ),
                      ),
                      _StatusChip(
                        label: request.statusEndDate,
                        color: isChangingToOff
                            ? Colors.orange
                            : Colors.blueGrey,
                      ),
                    ],
                  ),
                   
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    this.color = Colors.blueGrey,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
