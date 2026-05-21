import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_watchlist/core/error/exceptions.dart';

class FirestoreUserDataSource {
  FirestoreUserDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  static const int _maxBatchOperations = 450;

  final FirebaseFirestore _firestore;

  Future<void> deleteUserData(String uid) async {
    try {
      final userRef = _firestore.collection('users').doc(uid);
      final references = <DocumentReference<Object?>>[];

      for (final collectionName in const <String>['watchlist', 'watched']) {
        final snapshot = await userRef.collection(collectionName).get();
        references.addAll(snapshot.docs.map((doc) => doc.reference));
      }

      references.add(userRef);

      for (var index = 0; index < references.length;) {
        final batch = _firestore.batch();
        final end = (index + _maxBatchOperations > references.length)
            ? references.length
            : index + _maxBatchOperations;

        for (final reference in references.sublist(index, end)) {
          batch.delete(reference);
        }

        await batch.commit();
        index = end;
      }
    } on FirebaseException catch (error) {
      throw CacheException(error.message ?? 'Failed to delete user data.');
    }
  }
}
