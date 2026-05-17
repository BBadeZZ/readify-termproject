import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';

class SocialService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> ensureProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db.collection('userProfiles').doc(user.uid).set({
      'uid': user.uid,
      'displayName': user.displayName ?? '',
      'displayNameLower': (user.displayName ?? '').toLowerCase(),
      'email': user.email ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    final q = query.trim().toLowerCase();

    final nameSnap = await _db
        .collection('userProfiles')
        .where('displayNameLower', isGreaterThanOrEqualTo: q)
        .where('displayNameLower', isLessThan: '${q}z')
        .limit(10)
        .get();

    final emailSnap = await _db
        .collection('userProfiles')
        .where('email', isEqualTo: q)
        .limit(5)
        .get();

    final results = <String, Map<String, dynamic>>{};

    for (final doc in [...nameSnap.docs, ...emailSnap.docs]) {
      if (doc.id != _uid) {
        results[doc.id] = {
          'id': doc.id,
          ...doc.data(),
        };
      }
    }

    return results.values.toList();
  }

  Future<Map<String, dynamic>?> getFriendStatus(String otherUid) async {
    final friendDoc = await _db
        .collection('users')
        .doc(_uid)
        .collection('friends')
        .doc(otherUid)
        .get();

    if (friendDoc.exists) {
      return {'status': 'accepted'};
    }

    final outSnap = await _db
        .collection('friendRequests')
        .where('from', isEqualTo: _uid)
        .where('to', isEqualTo: otherUid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (outSnap.docs.isNotEmpty) {
      return {
        'status': 'pending_sent',
        'requestId': outSnap.docs.first.id,
      };
    }

    final inSnap = await _db
        .collection('friendRequests')
        .where('from', isEqualTo: otherUid)
        .where('to', isEqualTo: _uid)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (inSnap.docs.isNotEmpty) {
      return {
        'status': 'pending_received',
        'requestId': inSnap.docs.first.id,
      };
    }

    return null;
  }

  Future<void> sendFriendRequest(String toUid, String toName) async {
    final user = FirebaseAuth.instance.currentUser;

    await _db.collection('friendRequests').add({
      'from': _uid,
      'fromName': user?.displayName ?? '',
      'fromEmail': user?.email ?? '',
      'to': toUid,
      'toName': toName,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelFriendRequest(String requestId) async {
    await _db.collection('friendRequests').doc(requestId).delete();
  }

  Future<void> acceptFriendRequest(
      String requestId,
      Map<String, dynamic> reqData,
      ) async {
    final batch = _db.batch();
    final user = FirebaseAuth.instance.currentUser;
    final now = FieldValue.serverTimestamp();

    batch.update(
      _db.collection('friendRequests').doc(requestId),
      {'status': 'accepted'},
    );

    batch.set(
      _db.collection('users').doc(_uid).collection('friends').doc(reqData['from']),
      {
        'uid': reqData['from'],
        'displayName': reqData['fromName'] ?? '',
        'email': reqData['fromEmail'] ?? '',
        'addedAt': now,
      },
    );

    batch.set(
      _db.collection('users').doc(reqData['from']).collection('friends').doc(_uid),
      {
        'uid': _uid,
        'displayName': user?.displayName ?? '',
        'email': user?.email ?? '',
        'addedAt': now,
      },
    );

    await batch.commit();
  }

  Future<void> declineFriendRequest(String requestId) async {
    await _db.collection('friendRequests').doc(requestId).update({
      'status': 'declined',
    });
  }

  Future<void> removeFriend(String friendUid) async {
    final batch = _db.batch();

    batch.delete(
      _db.collection('users').doc(_uid).collection('friends').doc(friendUid),
    );

    batch.delete(
      _db.collection('users').doc(friendUid).collection('friends').doc(_uid),
    );

    await batch.commit();
  }

  Stream<List<Map<String, dynamic>>> getFriends() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('friends')
        .snapshots()
        .map((s) {
      return s.docs.map((d) {
        return {
          'id': d.id,
          ...d.data(),
        };
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getIncomingFriendRequests() {
    return _db
        .collection('friendRequests')
        .where('to', isEqualTo: _uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((s) {
      return s.docs.map((d) {
        return {
          'id': d.id,
          ...d.data(),
        };
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getOutgoingFriendRequests() {
    return _db
        .collection('friendRequests')
        .where('from', isEqualTo: _uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((s) {
      return s.docs.map((d) {
        return {
          'id': d.id,
          ...d.data(),
        };
      }).toList();
    });
  }

  Stream<List<Book>> getFriendBooks(String friendUid) {
    return _db
        .collection('users')
        .doc(friendUid)
        .collection('books')
        .snapshots()
        .map((s) {
      return s.docs.map((d) {
        return Book.fromMap(d.id, d.data());
      }).toList();
    });
  }

  Future<void> sendBorrowRequest({
    required String toUid,
    required String toName,
    required String bookId,
    required String bookTitle,
    required String bookAuthor,
    String bookCoverUrl = '',
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    await _db.collection('borrowRequests').add({
      'fromUid': _uid,
      'fromName': user?.displayName ?? '',
      'toUid': toUid,
      'toName': toName,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'bookCoverUrl': bookCoverUrl,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> acceptBorrowRequest(String requestId) async {
    await _db.collection('borrowRequests').doc(requestId).update({
      'status': 'accepted',
    });
  }

  Future<void> declineBorrowRequest(String requestId) async {
    await _db.collection('borrowRequests').doc(requestId).update({
      'status': 'declined',
    });
  }

  Future<void> markBorrowReturned(String requestId) async {
    await _db.collection('borrowRequests').doc(requestId).update({
      'status': 'returned',
    });
  }

  Stream<List<Map<String, dynamic>>> getIncomingBorrowRequests() {
    return _db
        .collection('borrowRequests')
        .where('toUid', isEqualTo: _uid)
        .where('status', whereIn: ['pending', 'accepted'])
        .snapshots()
        .map((s) {
      return s.docs.map((d) {
        return {
          'id': d.id,
          ...d.data(),
        };
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getOutgoingBorrowRequests() {
    return _db
        .collection('borrowRequests')
        .where('fromUid', isEqualTo: _uid)
        .where('status', whereIn: ['pending', 'accepted'])
        .snapshots()
        .map((s) {
      return s.docs.map((d) {
        return {
          'id': d.id,
          ...d.data(),
        };
      }).toList();
    });
  }
}

final socialService = SocialService();