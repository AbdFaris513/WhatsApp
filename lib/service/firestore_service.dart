import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/contact_models.dart';

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
      final docSnap = await _firestore.collection('users').doc(userNumber).get();
      final List<Map<String, dynamic>> contactList = List<Map<String, dynamic>>.from(
        docSnap.data()?['contactList'] ?? [],
      );
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

  //
}
