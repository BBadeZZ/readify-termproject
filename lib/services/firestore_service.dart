import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';
import '../models/reading_session.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  CollectionReference get _booksRef =>
      _db.collection('users').doc(userId).collection('books');

  CollectionReference get _sessionsRef =>
      _db.collection('users').doc(userId).collection('sessions');

  // Books
  Stream<List<Book>> getBooks() {
    return _booksRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Book.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> addBook(Book book) async {
    await _booksRef.add(book.toMap());
  }

  Future<void> updateBook(Book book) async {
    await _booksRef.doc(book.id).update(book.toMap());
  }

  Future<void> deleteBook(String id) async {
    await _booksRef.doc(id).delete();
  }

  // Reading sessions
  Future<void> addSession(ReadingSession session) async {
    await _sessionsRef.add(session.toMap());
  }

  Stream<List<ReadingSession>> getSessions() {
    return _sessionsRef
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReadingSession.fromMap(
                doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }
}