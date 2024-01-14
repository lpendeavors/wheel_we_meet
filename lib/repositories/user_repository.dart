import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/user_entity.dart';

abstract class UserRepository {
  Future<bool> isSignedIn();

  Future<void> signOut();

  Future<void> authenticate({
    required String username,
    required String password,
  });

  Future<void> register({
    required String email,
    required String password,
    required String name,
  });

  Future<void> sendFriendRequest({
    required String email,
  });

  Future<void> acceptFriendRequest({
    required String friendUserId,
  });

  Future<void> cancelFriendRequest({
    required String friendUserId,
  });

  Future<void> unfriend({
    required String friendUserId,
  });

  Future<void> updateProfile({
    required String name,
    File? image,
  });

  Stream<List<UserEntity>> getFriends();

  Stream<List<UserEntity>> getFriendRequests();
}

class UserRepositoryImpl implements UserRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  UserRepositoryImpl(
    this._auth,
    this._firestore,
    this._storage,
  );

  @override
  Future<void> authenticate({
    required String username,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: username,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isSignedIn() async {
    final currentUser = _auth.currentUser;
    return currentUser != null;
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.runTransaction((transaction) async {
        transaction.set(
          _firestore.collection('users').doc(_auth.currentUser!.uid),
          {
            'name': name,
            'email': email,
            'imageUrl': null,
            'friends': [],
            'sentRequests': [],
            'receivedRequests': [],
          },
        );

        await _firestore
            .collection('invitations')
            .where('email', isEqualTo: email)
            .get()
            .then((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            for (var doc in snapshot.docs) {
              final from = doc.data()['from'] as String;

              transaction.update(
                _firestore.collection('users').doc(from),
                {
                  'friends': FieldValue.arrayUnion([_auth.currentUser!.uid])
                },
              );

              transaction.update(
                _firestore.collection('users').doc(_auth.currentUser!.uid),
                {
                  'friends': FieldValue.arrayUnion([from])
                },
              );

              transaction.delete(doc.reference);
            }
          }
        });

        return Future.value();
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> sendFriendRequest({
    required String email,
  }) async {
    try {
      final currentUser = _auth.currentUser;

      if (currentUser!.email == email) {
        return;
      }

      final userRequested = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userRequested.docs.isEmpty) {
        await _firestore.collection('invitations').add({
          'from': currentUser.uid,
          'email': email,
        });
      } else {
        final requestedUserId = userRequested.docs.first.id;

        await _firestore.runTransaction((transaction) async {
          final currentUserData =
              await _firestore.collection('users').doc(currentUser.uid).get();

          final requestedUserData =
              await _firestore.collection('users').doc(requestedUserId).get();

          final currentUserSentRequests =
              currentUserData.data()!['sentRequests'] as List<dynamic>;
          final requestedUserReceivedRequests =
              requestedUserData.data()!['receivedRequests'] as List<dynamic>;

          if (currentUserSentRequests.contains(requestedUserId) ||
              requestedUserReceivedRequests.contains(currentUser.uid)) {
            return;
          }

          transaction.update(
            _firestore.collection('users').doc(currentUser.uid),
            {
              'sentRequests': FieldValue.arrayUnion([requestedUserId])
            },
          );

          transaction.update(
            _firestore.collection('users').doc(requestedUserId),
            {
              'receivedRequests': FieldValue.arrayUnion([currentUser.uid])
            },
          );
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> acceptFriendRequest({
    required String friendUserId,
  }) async {
    final currentUserId = _auth.currentUser!.uid;

    DocumentReference currentUserRef =
        _firestore.collection('users').doc(currentUserId);
    DocumentReference friendUserRef =
        _firestore.collection('users').doc(friendUserId);

    return _firestore.runTransaction((transaction) async {
      transaction.update(currentUserRef, {
        'friends': FieldValue.arrayUnion([friendUserId])
      });

      transaction.update(currentUserRef, {
        'receivedRequests': FieldValue.arrayRemove([friendUserId])
      });

      transaction.update(friendUserRef, {
        'friends': FieldValue.arrayUnion([currentUserId])
      });

      transaction.update(friendUserRef, {
        'sentRequests': FieldValue.arrayRemove([currentUserId])
      });
    });
  }

  @override
  Future<void> cancelFriendRequest({
    required String friendUserId,
  }) {
    final currentUserId = _auth.currentUser!.uid;

    DocumentReference currentUserRef =
        _firestore.collection('users').doc(currentUserId);
    DocumentReference friendUserRef =
        _firestore.collection('users').doc(friendUserId);

    return _firestore.runTransaction((transaction) async {
      transaction.update(currentUserRef, {
        'sentRequests': FieldValue.arrayRemove([friendUserId])
      });

      transaction.update(friendUserRef, {
        'receivedRequests': FieldValue.arrayRemove([currentUserId])
      });
    });
  }

  @override
  Future<void> unfriend({
    required String friendUserId,
  }) async {
    final currentUserId = _auth.currentUser!.uid;

    DocumentReference currentUserRef =
        _firestore.collection('users').doc(currentUserId);
    DocumentReference friendUserRef =
        _firestore.collection('users').doc(friendUserId);

    await _firestore.runTransaction((transaction) async {
      transaction.update(currentUserRef, {
        'friends': FieldValue.arrayRemove([friendUserId])
      });

      transaction.update(friendUserRef, {
        'friends': FieldValue.arrayRemove([currentUserId])
      });
    });
  }

  @override
  Future<void> updateProfile({
    required String name,
    File? image,
  }) async {
    final currentUserId = _auth.currentUser!.uid;

    DocumentReference currentUserRef =
        _firestore.collection('users').doc(currentUserId);

    final update = <String, dynamic>{
      'name': name,
    };

    if (image != null) {
      final ref = _storage.ref().child('user_images').child(currentUserId);
      await ref.putFile(image);
      final imageUrl = await ref.getDownloadURL();
      update['imageUrl'] = imageUrl;
    }

    await currentUserRef.update(update);
  }

  @override
  Stream<List<UserEntity>> getFriends() {
    final currentUserId = _auth.currentUser!.uid;

    return _firestore
        .collection('users')
        .where('friends', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(
              (doc) => UserEntity.fromJson(
                {
                  ...doc.data(),
                  'id': doc.id,
                },
              ),
            )
            .toList());
  }

  @override
  Stream<List<UserEntity>> getFriendRequests() {
    final currentUserId = _auth.currentUser!.uid;

    return _firestore
        .collection('users')
        .where('sentRequests', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(
              (doc) => UserEntity.fromJson(
                {
                  ...doc.data(),
                  'id': doc.id,
                },
              ),
            )
            .toList());
  }
}
