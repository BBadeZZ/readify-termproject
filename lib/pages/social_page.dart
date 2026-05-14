import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/social_service.dart';
import '../widgets/app_drawer.dart';
import 'friend_library_page.dart';

// Returns a deterministic color from a string (for avatars)
Color _avatarColor(String name, ColorScheme cs) {
  if (name.isEmpty) return cs.primaryContainer;
  final colors = [
    cs.primaryContainer,
    cs.secondaryContainer,
    cs.tertiaryContainer,
    cs.errorContainer,
  ];
  return colors[name.codeUnitAt(0) % colors.length];
}

Color _avatarFg(String name, ColorScheme cs) {
  if (name.isEmpty) return cs.primary;
  final colors = [cs.primary, cs.secondary, cs.tertiary, cs.error];
  return colors[name.codeUnitAt(0) % colors.length];
}

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _searching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    socialService.ensureProfile();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabs.dispose();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search(_searchCtrl.text);
    });
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      if (mounted) setState(() => _searchResults = []);
      return;
    }
    if (mounted) setState(() => _searching = true);
    final results = await socialService.searchUsers(q);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _searching = false;
      });
    }
  }

  void _goToSearch() {
    _tabs.animateTo(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const AppDrawer(currentPage: 'Social'),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            floating: true,
            snap: true,
            title: Text(l10n.socialTitle),
            actions: [
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: socialService.getIncomingBorrowRequests(),
                builder: (context, snap) {
                  final count = snap.data?.length ?? 0;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.swap_horiz_rounded),
                        tooltip: l10n.socialBorrowRequests,
                        onPressed: () =>
                            Navigator.pushNamed(context, '/borrow-requests'),
                      ),
                      if (count > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: cs.error,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$count',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: cs.onError,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: socialService.getIncomingFriendRequests(),
                builder: (context, snap) {
                  final pending = snap.data?.length ?? 0;
                  return TabBar(
                    controller: _tabs,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people_rounded, size: 18),
                            const SizedBox(width: 6),
                            Text(l10n.socialFriends),
                            if (pending > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: cs.error,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$pending',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: cs.onError,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_search_rounded, size: 18),
                            const SizedBox(width: 6),
                            Text(l10n.socialSearch),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _FriendsTab(cs: cs, l10n: l10n, onFindFriends: _goToSearch),
            _SearchTab(
              controller: _searchCtrl,
              results: _searchResults,
              searching: _searching,
              cs: cs,
              l10n: l10n,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Friends Tab ─────────────────────────────────────────────────────────────

class _FriendsTab extends StatelessWidget {
  final ColorScheme cs;
  final AppLocalizations l10n;
  final VoidCallback onFindFriends;
  const _FriendsTab(
      {required this.cs, required this.l10n, required this.onFindFriends});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: socialService.getFriends(),
      builder: (context, friendsSnap) {
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: socialService.getIncomingFriendRequests(),
          builder: (context, reqSnap) {
            final friends = friendsSnap.data ?? [];
            final requests = reqSnap.data ?? [];

            return RefreshIndicator(
              onRefresh: () async {
                // Re-ensure the local user's profile is up-to-date on Firestore.
                // The Firestore streams automatically push any resulting changes.
                await socialService.ensureProfile();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Stats header
                  SliverToBoxAdapter(
                    child: _StatsHeader(
                        friendCount: friends.length, cs: cs, l10n: l10n),
                  ),

                  // Pending requests
                  if (requests.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                        child: _SectionHeader(
                          icon: Icons.notifications_active_rounded,
                          label: l10n.socialFriendRequests,
                          badge: requests.length,
                          cs: cs,
                        ),
                      ),
                    ),
                  if (requests.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _RequestCard(
                              req: requests[i], cs: cs, l10n: l10n),
                          childCount: requests.length,
                        ),
                      ),
                    ),
                  if (requests.isNotEmpty)
                    const SliverToBoxAdapter(
                        child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 24),
                    )),

                  // Friends list or empty state
                  if (friends.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyFriends(
                          cs: cs,
                          l10n: l10n,
                          onFindFriends: onFindFriends),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                        child: _SectionHeader(
                          icon: Icons.people_rounded,
                          label:
                              '${l10n.socialFriends} (${friends.length})',
                          cs: cs,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _FriendCard(
                              friend: friends[i], cs: cs, l10n: l10n),
                          childCount: friends.length,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatsHeader extends StatelessWidget {
  final int friendCount;
  final ColorScheme cs;
  final AppLocalizations l10n;
  const _StatsHeader(
      {required this.friendCount, required this.cs, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people_rounded, color: cs.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$friendCount',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: cs.onPrimaryContainer,
                ),
              ),
              Text(
                l10n.socialFriends,
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onPrimaryContainer.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
          const Spacer(),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: socialService.getOutgoingBorrowRequests(),
            builder: (context, snap) {
              final outgoing = snap.data?.length ?? 0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$outgoing',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    l10n.socialOutgoing,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? badge;
  final ColorScheme cs;
  const _SectionHeader(
      {required this.icon,
      required this.label,
      this.badge,
      required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                  fontSize: 14)),
          if (badge != null && badge! > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: cs.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$badge',
                style: TextStyle(
                    fontSize: 11,
                    color: cs.onError,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyFriends extends StatelessWidget {
  final ColorScheme cs;
  final AppLocalizations l10n;
  final VoidCallback onFindFriends;
  const _EmptyFriends(
      {required this.cs, required this.l10n, required this.onFindFriends});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.people_outline_rounded,
                  size: 56, color: cs.primary),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.socialNoFriends,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: cs.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onFindFriends,
              icon: const Icon(Icons.person_search_rounded),
              label: Text(l10n.socialSearch),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> req;
  final ColorScheme cs;
  final AppLocalizations l10n;
  const _RequestCard(
      {required this.req, required this.cs, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final name = req['fromName'] as String? ?? '';
    final email = req['fromEmail'] as String? ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: _avatarColor(name, cs),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                    color: _avatarFg(name, cs),
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(email,
                      style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.55))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                SizedBox(
                  height: 32,
                  child: FilledButton(
                    onPressed: () async {
                      try {
                        await socialService.acceptFriendRequest(req['id'], req);
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.librarySomethingWrong),
                              backgroundColor: cs.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      minimumSize: Size.zero,
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                    child: Text(l10n.socialAccept),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 28,
                  child: TextButton(
                    onPressed: () async {
                      try {
                        await socialService.declineFriendRequest(req['id']);
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.librarySomethingWrong),
                              backgroundColor: cs.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      minimumSize: Size.zero,
                      foregroundColor: cs.error,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: Text(l10n.socialDecline),
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

class _FriendCard extends StatelessWidget {
  final Map<String, dynamic> friend;
  final ColorScheme cs;
  final AppLocalizations l10n;
  const _FriendCard(
      {required this.friend, required this.cs, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final name = friend['displayName'] as String? ?? '';
    final email = friend['email'] as String? ?? '';
    final uid = friend['uid'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: _avatarColor(name, cs),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                    color: _avatarFg(name, cs),
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  Text(email,
                      style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.55))),
                ],
              ),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      FriendLibraryPage(friendUid: uid, friendName: name),
                ),
              ),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.library_books_rounded, size: 16),
                  const SizedBox(width: 4),
                  Text(l10n.socialViewLibrary,
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded,
                  color: cs.onSurface.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (v) {
                if (v == 'remove') _confirmRemove(context, uid, name);
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove_rounded,
                          color: cs.error, size: 18),
                      const SizedBox(width: 8),
                      Text(l10n.socialRemove,
                          style: TextStyle(color: cs.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemove(
      BuildContext context, String uid, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.socialRemove),
        content: Text('$name?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.libraryDeleteConfirmNo)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style:
                  FilledButton.styleFrom(backgroundColor: ctx.cs.error),
              child: Text(l10n.socialRemove)),
        ],
      ),
    );
    if (confirmed == true) await socialService.removeFriend(uid);
  }
}

// ─── Search Tab ──────────────────────────────────────────────────────────────

class _SearchTab extends StatelessWidget {
  final TextEditingController controller;
  final List<Map<String, dynamic>> results;
  final bool searching;
  final ColorScheme cs;
  final AppLocalizations l10n;

  const _SearchTab({
    required this.controller,
    required this.results,
    required this.searching,
    required this.cs,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = controller.text.trim().isEmpty;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SearchBar(
            controller: controller,
            hintText: l10n.socialSearchHint,
            leading: const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.search_rounded),
            ),
            trailing: [
              if (!isEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () => controller.clear(),
                ),
            ],
            elevation: const WidgetStatePropertyAll(2),
          ),
        ),
        if (searching)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text('${l10n.socialSearch}...',
                      style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.5))),
                ],
              ),
            ),
          )
        else if (isEmpty)
          Expanded(child: _SearchHint(cs: cs, l10n: l10n))
        else if (results.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_off_rounded,
                      size: 48, color: cs.outlineVariant),
                  const SizedBox(height: 12),
                  Text(l10n.searchNoResults,
                      style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.5))),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: results.length,
              itemBuilder: (context, i) => _SearchResultCard(
                  user: results[i], cs: cs, l10n: l10n),
            ),
          ),
      ],
    );
  }
}

class _SearchHint extends StatelessWidget {
  final ColorScheme cs;
  final AppLocalizations l10n;
  const _SearchHint({required this.cs, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.secondaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_search_rounded,
                  size: 48, color: cs.secondary),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.socialSearchHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurface.withValues(alpha: 0.55),
                  height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatefulWidget {
  final Map<String, dynamic> user;
  final ColorScheme cs;
  final AppLocalizations l10n;
  const _SearchResultCard(
      {required this.user, required this.cs, required this.l10n});

  @override
  State<_SearchResultCard> createState() => _SearchResultCardState();
}

class _SearchResultCardState extends State<_SearchResultCard> {
  Map<String, dynamic>? _status;
  bool _loading = true;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final uid = _uid;
    final s = await socialService.getFriendStatus(uid);
    if (mounted) setState(() { _status = s; _loading = false; });
  }

  String get _uid =>
      widget.user['uid'] as String? ?? widget.user['id'] as String? ?? '';

  Future<void> _act(Future<void> Function() action) async {
    setState(() => _acting = true);
    await action();
    await _loadStatus();
    if (mounted) setState(() => _acting = false);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.user['displayName'] as String? ?? '';
    final email = widget.user['email'] as String? ?? '';
    final cs = widget.cs;
    final l10n = widget.l10n;
    final status = _status?['status'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: _avatarColor(name, cs),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                    color: _avatarFg(name, cs),
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(email,
                      style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.55))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (_loading || _acting)
              const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2))
            else if (status == 'accepted')
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded, size: 14, color: cs.primary),
                    const SizedBox(width: 4),
                    Text(l10n.socialAlreadyFriends,
                        style: TextStyle(
                            fontSize: 11,
                            color: cs.primary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              )
            else if (status == 'pending_sent')
              OutlinedButton(
                onPressed: () => _act(() => socialService
                    .cancelFriendRequest(_status!['requestId'])),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: Text(l10n.socialCancelRequest),
              )
            else if (status == 'pending_received')
              FilledButton.tonal(
                onPressed: () => _act(() => socialService.acceptFriendRequest(
                    _status!['requestId'],
                    {'from': _uid, 'fromName': name, 'fromEmail': email})),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: Text(l10n.socialAccept),
              )
            else
              FilledButton(
                onPressed: () => _act(
                    () => socialService.sendFriendRequest(_uid, name)),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: Text(l10n.socialAddFriend),
              ),
          ],
        ),
      ),
    );
  }
}

// Helper extension
extension on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;
}
