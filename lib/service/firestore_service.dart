import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/contact_models.dart';
import 'package:whatsapp/model/message_model.dart';

class FirebaseHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create user in Firestore
  static Future<void> createUser({
    required String name,
    required String phone,
    required String profilePictureUrl,
  }) async {
    try {
      debugPrint('Creating user in Firestore...');
      debugPrint('Phone: $phone');
      debugPrint('Name: $name');

      await _firestore.collection('users').doc(phone).set({
        'name': name,
        'phone': phone,
        'profilePicture': profilePictureUrl,
        'about': '',
        'createdAt': FieldValue.serverTimestamp(),
        'isOnline': true,
        'lastSeen': '',
        'contactList': [],
      });

      debugPrint('User created successfully in Firestore');
    } catch (e) {
      debugPrint('Error creating user in Firestore: $e');
      debugPrint('Error details: ${e.toString()}');
      rethrow;
    }
  }

  static Future<bool> doesUserExistByPhone(String phoneNumber) async {
    final DocumentSnapshot userDoc = await _firestore.collection('users').doc(phoneNumber).get();

    return userDoc.exists;
  }

  static Future<void> upsertContact({
    required String userPhone,
    required ContactData contact,
  }) async {
    final docRef = _firestore.collection('users').doc(userPhone);
    final docSnap = await docRef.get();

    if (!docSnap.exists) return;

    final List<Map<String, dynamic>> contactList = List<Map<String, dynamic>>.from(
      docSnap.data()?['contactList'] ?? [],
    );

    final int existingIndex = contactList.indexWhere(
      (c) => c['contactNumber'] == contact.contactNumber,
    );

    if (existingIndex != -1) {
      // 🔁 Update existing contact name
      contactList[existingIndex]['contactName'] = contact.contactFirstName;
    } else {
      // ➕ Add new contact
      contactList.add(contact.toMapForContact());
    }

    await docRef.update({'contactList': contactList});
  }

  static Future<List<Map<String, dynamic>>> getContactList(String userNumber) async {
    try {
      // Get user's contact list
      final docSnap = await _firestore.collection('users').doc(userNumber).get();
      final List<Map<String, dynamic>> contactList = List<Map<String, dynamic>>.from(
        docSnap.data()?['contactList'] ?? [],
      );

      // Fetch profile picture for each contact
      for (final entry in contactList) {
        try {
          // ✅ Fixed: Properly await and get document data
          final contactDoc = await _firestore.collection('users').doc(entry['contactNumber']).get();

          // ✅ Add profile picture to contact entry
          if (contactDoc.exists) {
            entry['contactImage'] = contactDoc.data()?['profilePicture'] ?? '';
          } else {
            entry['contactImage'] = ''; // Contact doesn't exist in users collection
          }
        } catch (e) {
          debugPrint("Error fetching profile for ${entry['contactNumber']}: $e");
          entry['contactImage'] = ''; // Fallback on error
        }
      }

      return contactList;
    } catch (e) {
      debugPrint("Error on getContactList() : $e");
      return [];
    }
  }

  // Update user's about
  static Future<void> updateUserAbout({required String userPhone, required String about}) async {
    try {
      await _firestore.collection('users').doc(userPhone).update({'about': about});
      debugPrint('About updated successfully');
    } catch (e) {
      debugPrint('Error updating about: $e');
      rethrow;
    }
  }

  // Update user's online status
  static Future<void> updateOnlineStatus({
    required String userPhone,
    required bool isOnline,
  }) async {
    try {
      Map<String, dynamic> updateData = {'isOnline': isOnline};

      if (!isOnline) {
        updateData['lastSeen'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection('users').doc(userPhone).update(updateData);
      debugPrint('Online status updated');
    } catch (e) {
      debugPrint('Error updating online status: $e');
      rethrow;
    }
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData(String userPhone) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userPhone).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      rethrow;
    }
  }

  // Update profile picture
  static Future<void> updateProfilePicture({
    required String userPhone,
    required String profilePictureUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(userPhone).update({
        'profilePicture': profilePictureUrl,
      });
      debugPrint('Profile picture updated successfully');
    } catch (e) {
      debugPrint('Error updating profile picture: $e');
      rethrow;
    }
  }

  // Remove a contact from user's contact list
  static Future<void> removeContactFromUser({
    required String userPhone,
    required String contactPhone,
  }) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userPhone).get();
      if (doc.exists) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        List<dynamic> contactList = userData['contactList'] ?? [];

        contactList.removeWhere((contact) => contact['phoneNumber'] == contactPhone);

        await _firestore.collection('users').doc(userPhone).update({'contactList': contactList});
        debugPrint('Contact removed successfully');
      }
    } catch (e) {
      debugPrint('Error removing contact: $e');
      rethrow;
    }
  }

  // Get all contacts for a user
  static Future<List<Map<String, dynamic>>> getUserContacts(String userPhone) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userPhone).get();

      if (doc.exists) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        List<dynamic> contactList = userData['contactList'] ?? [];
        return contactList.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting user contacts: $e');
      rethrow;
    }
  }

  // *-*-*-*-*-*-*-*-*-**-*-*-* Chats -*-*-*-*-*-**-*-*-*-*-*-*-*-*-* //

  static Future<void> _ensureChatExists(String chatId, String user1, String user2) async {
    final chatDoc = _firestore.collection('chats').doc(chatId);
    final docSnapshot = await chatDoc.get();

    if (!docSnapshot.exists) {
      await chatDoc.set({
        'participants': {user1: true, user2: true},
        'participantIds': [user1, user2],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSender': '',
        'unreadCounts': {user1: 0, user2: 0},
      });
    }
  }

  // Send a message
  static Future<void> sendMessage({required MessageModel msg}) async {
    try {
      final chatId = generateChatId(msg.msgSender, msg.msgReceiver);

      // Ensure chat exists first
      await _ensureChatExists(chatId, msg.msgSender, msg.msgReceiver);

      // Prepare message data for Firestore
      final messageData = {
        'msg': msg.msg,
        'msgSender': msg.msgSender,
        'msgReceiver': msg.msgReceiver,
        'type': msg.type.name,
        'status': MessageStatus.sent.name,
        'sendTime': FieldValue.serverTimestamp(),
        'receiveTime': null,
        'viewTime': null,
        'isForward': msg.isForward,
        'originalSender': msg.originalSender,
        'isReplied': msg.isReplied,
        'replyMsgId': msg.replyMsgId,
        'isStarred': msg.isStarred,
        'isEdited': msg.isEdited,
        'mediaUrl': msg.mediaUrl,
        'thumbnailUrl': msg.thumbnailUrl,
        'duration': msg.duration?.inMilliseconds,
      };

      // Use batch write for atomic operations
      final batch = _firestore.batch();

      // Add message to subcollection
      final messageRef = _firestore.collection('chats').doc(chatId).collection('messages').doc();

      batch.set(messageRef, messageData);

      // Update chat document with last message info
      final chatRef = _firestore.collection('chats').doc(chatId);
      batch.update(chatRef, {
        'lastMessage': msg.msg,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSender': msg.msgSender,
        'lastMessageType': msg.type.name,
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadCounts.${msg.msgReceiver}': FieldValue.increment(1),
      });

      await batch.commit();
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  // ✅ FIXED: Returns a Stream instead of Future<List<dynamic>>
  static Stream<List<MessageModel>> listenToMessages(String user1, String user2) {
    final chatId = generateChatId(user1, user2);

    debugPrint("📡 Listening to messages for chat: $chatId");

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sendTime', descending: false)
        .snapshots()
        .map((snapshot) {
          debugPrint("📨 Received ${snapshot.docs.length} messages");

          return snapshot.docs.map((doc) {
            final data = doc.data();
            return MessageModel(
              id: doc.id,
              msg: data['msg'] ?? '',
              msgSender: data['msgSender'] ?? '',
              msgReceiver: data['msgReceiver'] ?? '',
              type: MessageType.values.firstWhere(
                (e) => e.name == data['type'],
                orElse: () => MessageType.text,
              ),
              status: MessageStatus.values.firstWhere(
                (e) => e.name == data['status'],
                orElse: () => MessageStatus.sent,
              ),
              sendTime: (data['sendTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
              receiveTime: (data['receiveTime'] as Timestamp?)?.toDate(),
              viewTime: (data['viewTime'] as Timestamp?)?.toDate(),
              isForward: data['isForward'] ?? false,
              originalSender: data['originalSender'],
              isReplied: data['isReplied'] ?? false,
              replyMsgId: data['replyMsgId'],
              isStarred: data['isStarred'] ?? false,
              isEdited: data['isEdited'] ?? false,
              mediaUrl: data['mediaUrl'],
              thumbnailUrl: data['thumbnailUrl'],
              duration: data['duration'] != null ? Duration(milliseconds: data['duration']) : null,
            );
          }).toList();
        })
        .handleError((error) {
          debugPrint('❌ Error listening to messages: $error');
          return <MessageModel>[];
        });
  }

  // Generate a consistent chat ID between two users
  static String generateChatId(String user1, String user2) {
    final sortedIds = [user1, user2]..sort();
    return 'chat_${sortedIds[0]}_${sortedIds[1]}';
  }
}
