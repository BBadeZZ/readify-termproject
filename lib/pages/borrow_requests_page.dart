import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/social_service.dart';

class BorrowRequestsPage extends StatelessWidget {
  const BorrowRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.socialBorrowRequests),
          bottom: TabBar(
            tabs: [
              Tab(icon: const Icon(Icons.call_received_rounded), text: l10n.socialIncoming),
              Tab(icon: const Icon(Icons.call_made_rounded), text: l10n.socialOutgoing),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _IncomingBorrowTab(l10n: l10n),
            _OutgoingBorrowTab(l10n: l10n),
          ],
        ),
      ),
    );
  }
}

// ─── Incoming ────────────────────────────────────────────────────────────────

class _IncomingBorrowTab extends StatelessWidget {
  final AppLocalizations l10n;
  const _IncomingBorrowTab({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: socialService.getIncomingBorrowRequests(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snap.data ?? [];
        if (requests.isEmpty) {
          return _EmptyState(label: l10n.socialNoBorrows, cs: cs);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, i) => _IncomingCard(req: requests[i], l10n: l10n, cs: cs),
        );
      },
    );
  }
}

class _IncomingCard extends StatelessWidget {
  final Map<String, dynamic> req;
  final AppLocalizations l10n;
  final ColorScheme cs;
  const _IncomingCard({required this.req, required this.l10n, required this.cs});

  @override
  Widget build(BuildContext context) {
    final status = req['status'] as String? ?? 'pending';
    final fromName = req['fromName'] as String? ?? '';
    final bookTitle = req['bookTitle'] as String? ?? '';
    final bookAuthor = req['bookAuthor'] as String? ?? '';
    final id = req['id'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: cs.primaryContainer,
                  child: Text(
                    fromName.isNotEmpty ? fromName[0].toUpperCase() : '?',
                    style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.socialRequestFrom(fromName),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                _StatusBadge(status: status, l10n: l10n, cs: cs),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.menu_book_rounded, size: 18, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bookTitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text(bookAuthor, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (status == 'pending') ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () => socialService.acceptBorrowRequest(id),
                      child: Text(l10n.socialAccept),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => socialService.declineBorrowRequest(id),
                      child: Text(l10n.socialDecline),
                    ),
                  ),
                ],
              ),
            ] else if (status == 'accepted') ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: Text(l10n.socialMarkReturned),
                  onPressed: () => socialService.markBorrowReturned(id),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Outgoing ────────────────────────────────────────────────────────────────

class _OutgoingBorrowTab extends StatelessWidget {
  final AppLocalizations l10n;
  const _OutgoingBorrowTab({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: socialService.getOutgoingBorrowRequests(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snap.data ?? [];
        if (requests.isEmpty) {
          return _EmptyState(label: l10n.socialNoBorrows, cs: cs);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, i) => _OutgoingCard(req: requests[i], l10n: l10n, cs: cs),
        );
      },
    );
  }
}

class _OutgoingCard extends StatelessWidget {
  final Map<String, dynamic> req;
  final AppLocalizations l10n;
  final ColorScheme cs;
  const _OutgoingCard({required this.req, required this.l10n, required this.cs});

  @override
  Widget build(BuildContext context) {
    final status = req['status'] as String? ?? 'pending';
    final toName = req['toName'] as String? ?? '';
    final bookTitle = req['bookTitle'] as String? ?? '';
    final bookAuthor = req['bookAuthor'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: cs.secondaryContainer,
                  child: Text(
                    toName.isNotEmpty ? toName[0].toUpperCase() : '?',
                    style: TextStyle(color: cs.secondary, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.socialBorrowFrom(toName),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                _StatusBadge(status: status, l10n: l10n, cs: cs),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.menu_book_rounded, size: 18, color: cs.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bookTitle, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text(bookAuthor, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared ──────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  final AppLocalizations l10n;
  final ColorScheme cs;
  const _StatusBadge({required this.status, required this.l10n, required this.cs});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bg;
    Color fg;
    switch (status) {
      case 'accepted':
        label = l10n.socialAccepted;
        bg = cs.primaryContainer;
        fg = cs.primary;
      case 'declined':
        label = l10n.socialDeclined;
        bg = cs.errorContainer;
        fg = cs.error;
      case 'returned':
        label = l10n.socialReturned;
        bg = cs.secondaryContainer;
        fg = cs.secondary;
      default:
        label = l10n.socialPending;
        bg = cs.tertiaryContainer;
        fg = cs.tertiary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  const _EmptyState({required this.label, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.swap_horiz_rounded, size: 56, color: cs.outlineVariant),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}
