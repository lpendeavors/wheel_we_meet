import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

import '../models/chat/conversation_result.dart';
import '../models/chat/message_entity.dart';
import '../models/chat/conversation_entity.dart';
import '../models/user_entity.dart';
import '../utils.dart';

abstract class ConversationRepository {
  Future<ConversationEntity> createConversation(
    String userId,
    String otherUserId,
  );

  Future<void> deleteConversation(String conversationId);

  Stream<ConversationListResult> getConversations();

  Stream<ConversationResult> getConversation(
    String? conversationId,
    String? friendId,
  );

  Future<void> sendMessage(
    String conversationId,
    String message,
    File? image,
  );

  Future<void> editMessage(
    String conversationId,
    String messageId,
    String message,
    File? image,
  );

  Future<void> deleteMessage(String conversationId, String messageId);

  Future<void> likeMessage(String conversationId, String messageId);

  Future<void> unlikeMessage(String conversationId, String messageId);

  Future<void> archiveConversation(String conversationId);

  Future<void> unarchiveConversation(String conversationId);

  Future<void> muteConversation(String conversationId);

  Future<void> unmuteConversation(String conversationId);

  Future<void> addParticipants(String conversationId, List<String> userIds);

  Future<void> removeParticipants(String conversationId, List<String> userIds);

  Future<void> leaveConversation(String conversationId);

  Future<void> markConversationRead(String conversationId);

  Future<void> joinConversation(String conversationId);

  Stream<List<ConversationEntity>> getPublicConversations();

  Future<String> createGroup(
    String name,
    String description,
    bool isPrivate,
    List<String> participants,
  );
}

class ConversationRepositoryImpl implements ConversationRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  const ConversationRepositoryImpl(
    this._firebaseAuth,
    this._firestore,
    this._storage,
  );

  @override
  Future<ConversationEntity> createConversation(
    String userId,
    String otherUserId,
  ) async {
    var docRef = await _firestore.collection('conversations').add({
      'name': '',
      'photo': null,
      'participantIds': <String>[userId, otherUserId],
      'lastMessage': '',
      'lastMessageTimestamp': null,
      'readStatus': {userId: true, otherUserId: false},
      'muteStatus': {userId: false, otherUserId: false},
      'archiveStatus': {userId: false, otherUserId: false},
      'isGroup': false,
      'isPrivate': true,
      'description': '',
    });
    var docSnapshot = await docRef.get();
    return ConversationEntity.fromJson(
      {
        'id': docSnapshot.id,
        ...docSnapshot.data()!,
      },
    );
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    await _firestore.collection('conversations').doc(conversationId).delete();
  }

  @override
  Future<void> deleteMessage(
    String conversationId,
    String messageId,
  ) async {
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  @override
  Future<void> editMessage(
    String conversationId,
    String messageId,
    String message,
    File? image,
  ) async {
    var data = {'text': message};
    if (image != null) {
      // Upload image and get URL, then add to data
    }
    await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .update(data);
  }

  @override
  Stream<ConversationResult> getConversation(
    String? conversationId,
    String? friendId,
  ) async* {
    Stream<ConversationEntity?> conversationStream = const Stream.empty();
    Stream<List<MessageEntity>?> messagesStream;

    if (conversationId == null && friendId == null) {
      throw Exception('Either conversationId or friendId must be provided');
    }

    final userId = _firebaseAuth.currentUser!.uid;
    final actualConversationId =
        await _getOrCreateConversationId(conversationId, friendId);

    conversationStream = _firestore
        .collection('conversations')
        .doc(actualConversationId)
        .snapshots()
        .map(
      (doc) {
        return ConversationEntity.fromJson(
          {
            'id': doc.id,
            ...?doc.data(),
            'participantIds': List<String>.from(
              doc.data()?['participantIds'] as List<dynamic>,
            ),
            'readStatus': mapToBoolMap(
              doc.data()?['readStatus'],
            ),
            'archiveStatus': mapToBoolMap(
              doc.data()?['archiveStatus'],
            ),
            'muteStatus': mapToBoolMap(
              doc.data()?['muteStatus'],
            ),
          },
        );
      },
    );

    messagesStream = _firestore
        .collection('conversations')
        .doc(actualConversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (query) => query.docs
              .map(
                (doc) => MessageEntity.fromJson(
                  {
                    'id': doc.id,
                    ...doc.data(),
                    'likeStatus': mapToBoolMap(
                      doc.data()['likeStatus'],
                    ),
                    'readStatus': mapToBoolMap(
                      doc.data()['readStatus'],
                    ),
                  },
                ),
              )
              .toList(),
        );

    yield* Rx.combineLatest2(
      conversationStream,
      messagesStream,
      (
        conversation,
        messages,
      ) async {
        var users = await _getUsers(
          conversation!.participantIds,
        );
        return ConversationResult(
          userId,
          conversation,
          messages ?? [],
          users,
        );
      },
    ).asyncMap((event) async => event);
  }

  @override
  Stream<ConversationListResult> getConversations() async* {
    final userId = _firebaseAuth.currentUser!.uid;

    await for (var snapshot in _firestore
        .collection('conversations')
        .where('participantIds', arrayContains: userId)
        .snapshots()) {
      List<ConversationEntity> conversations = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();
        var participantIds = List<String>.from(
          data['participantIds'] as List<dynamic>,
        );

        if (data['name'] == '') {
          String otherUserId = participantIds.firstWhere((id) => id != userId);
          var otherUserDoc =
              await _firestore.collection('users').doc(otherUserId).get();
          var otherUserData = otherUserDoc.data();

          data['name'] = otherUserData?['name'];
          data['photoUrl'] = otherUserData?['photoUrl'];
        }

        conversations.add(
          ConversationEntity.fromJson({
            'id': doc.id,
            ...data,
            'participantIds': participantIds,
            'readStatus': mapToBoolMap(data['readStatus']),
            'archiveStatus': mapToBoolMap(data['archiveStatus']),
            'muteStatus': mapToBoolMap(data['muteStatus']),
          }),
        );
      }

      yield ConversationListResult(userId, conversations);
    }
  }

  @override
  Future<void> sendMessage(
    String conversationId,
    String message,
    File? image,
  ) async {
    final userId = _firebaseAuth.currentUser!.uid;
    String? imageUrl;

    if (image != null) {
      imageUrl = await _uploadImage(image);
    }

    await _firestore.runTransaction((transaction) async {
      DocumentReference messageRef = _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc();

      var messageData = {
        'senderId': userId,
        'text': message,
        'timestamp': FieldValue.serverTimestamp(),
        'likeStatus': {userId: false},
        'readStatus': {userId: true},
        'isEdited': false,
        'isDeleted': false,
      };

      if (imageUrl != null) {
        messageData['imageUrl'] = imageUrl;
      }

      transaction.set(messageRef, messageData);

      transaction.update(
        _firestore.collection('conversations').doc(conversationId),
        {
          'lastMessage': message,
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
          'readStatus': {userId: true},
        },
      );
    });
  }

  @override
  Future<void> addParticipants(
    String conversationId,
    List<String> userIds,
  ) {
    return _firestore.collection('conversations').doc(conversationId).update({
      'participantIds': FieldValue.arrayUnion(userIds),
    });
  }

  @override
  Future<void> archiveConversation(String conversationId) {
    final userId = _firebaseAuth.currentUser!.uid;
    return _firestore.collection('conversations').doc(conversationId).update({
      'archiveStatus.$userId': true,
    });
  }

  @override
  Future<void> leaveConversation(String conversationId) {
    final userId = _firebaseAuth.currentUser!.uid;
    return _firestore.collection('conversations').doc(conversationId).update({
      'participantIds': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<void> markConversationRead(String conversationId) async {
    final userId = _firebaseAuth.currentUser!.uid;
    await _firestore.collection('conversations').doc(conversationId).update({
      'readStatus.$userId': true,
    });
  }

  @override
  Future<void> muteConversation(String conversationId) {
    final userId = _firebaseAuth.currentUser!.uid;
    return _firestore.collection('conversations').doc(conversationId).update({
      'muteStatus.$userId': true,
    });
  }

  @override
  Future<void> removeParticipants(
    String conversationId,
    List<String> userIds,
  ) {
    return _firestore.collection('conversations').doc(conversationId).update({
      'participantIds': FieldValue.arrayRemove(userIds),
    });
  }

  @override
  Future<void> unarchiveConversation(String conversationId) {
    final userId = _firebaseAuth.currentUser!.uid;
    return _firestore.collection('conversations').doc(conversationId).update({
      'muteStatus.$userId': false,
    });
  }

  @override
  Future<void> unmuteConversation(String conversationId) {
    final userId = _firebaseAuth.currentUser!.uid;
    return _firestore.collection('conversations').doc(conversationId).update({
      'muteStatus.$userId': false,
    });
  }

  @override
  Future<void> likeMessage(String conversationId, String messageId) {
    final userId = _firebaseAuth.currentUser!.uid;
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .update({'likeStatus.$userId': true});
  }

  @override
  Future<void> unlikeMessage(String conversationId, String messageId) {
    final userId = _firebaseAuth.currentUser!.uid;
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId)
        .update({'likeStatus.$userId': false});
  }

  @override
  Future<String> createGroup(
    String name,
    String description,
    bool isPrivate,
    List<String> participants,
  ) async {
    final userId = _firebaseAuth.currentUser!.uid;
    final doc = await _firestore.collection('conversations').add({
      'name': name,
      'photo': null,
      'participantIds': [...participants, userId],
      'lastMessage': '',
      'lastMessageTimestamp': null,
      'readStatus': {userId: true},
      'muteStatus': {userId: false},
      'archiveStatus': {userId: false},
      'isGroup': true,
      'isPrivate': isPrivate,
      'description': description,
    });

    return doc.id;
  }

  @override
  Stream<List<ConversationEntity>> getPublicConversations() {
    final userId = _firebaseAuth.currentUser!.uid;

    return _firestore
        .collection('conversations')
        .where('isPrivate', isEqualTo: false)
        .where('isGroup', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ConversationEntity.fromJson(
                  {
                    'id': doc.id,
                    ...doc.data(),
                    'participantIds': List<String>.from(
                      doc.data()['participantIds'] as List<dynamic>,
                    ),
                    'readStatus': mapToBoolMap(
                      doc.data()['readStatus'],
                    ),
                    'archiveStatus': mapToBoolMap(
                      doc.data()['archiveStatus'],
                    ),
                    'muteStatus': mapToBoolMap(
                      doc.data()['muteStatus'],
                    ),
                  },
                ),
              )
              .where(
                (conversation) => !conversation.participantIds.contains(userId),
              )
              .toList(),
        );
  }

  @override
  Future<void> joinConversation(String conversationId) {
    final userId = _firebaseAuth.currentUser!.uid;
    return _firestore.collection('conversations').doc(conversationId).update({
      'participantIds': FieldValue.arrayUnion([userId]),
    });
  }

  Future<List<UserEntity>> _getUsers(List<String> userIds) async {
    List<UserEntity> users = [];
    List<List<String>> chunks = splitList(userIds, 10);

    for (List<String> chunk in chunks) {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (var doc in querySnapshot.docs) {
        users.add(UserEntity.fromJson({
          'id': doc.id,
          ...doc.data(),
        }));
      }
    }

    return users;
  }

  Future<String> _uploadImage(File image) async {
    final userId = _firebaseAuth.currentUser!.uid;
    final imageRef = _storage.ref().child('images/$userId/${DateTime.now()}');
    final uploadTask = imageRef.putFile(image);
    final snapshot = await uploadTask.whenComplete(() => null);
    return snapshot.ref.getDownloadURL();
  }

  Future<String> _getOrCreateConversationId(
    String? conversationId,
    String? friendId,
  ) async {
    final userId = _firebaseAuth.currentUser!.uid;

    if (conversationId != null || friendId == null) {
      return conversationId!;
    } else {
      var querySnapshot = await _firestore
          .collection('conversations')
          .where('participantIds', arrayContains: friendId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        var newConversation = await createConversation(userId, friendId);
        return newConversation.id;
      } else {
        return querySnapshot.docs
            .firstWhere(
              (doc) =>
                  doc.data()['participantIds'].contains(userId) &&
                  doc.data()['participantIds'].length == 2,
              orElse: () => throw Exception('No valid conversation found'),
            )
            .id;
      }
    }
  }
}
