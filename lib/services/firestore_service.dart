import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  CollectionReference get _booksRef {
    return _db.collection('users').doc(userId).collection('books');
  }

  Stream<List<Book>> getBooks() {
    return _booksRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Book.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
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
}