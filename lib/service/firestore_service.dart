import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create user in Firestore
  static Future<void> createUser({
    required String name,
    required String phone,
    required String profilePictureUrl,
  }) async {
    try {
      print('Creating user in Firestore...');
      print('Phone: $phone');
      print('Name: $name');

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

      print('User created successfully in Firestore');
    } catch (e) {
      print('Error creating user in Firestore: $e');
      print('Error details: ${e.toString()}');
      rethrow;
    }
  }

  // Add a contact to user's contact list
  static Future<void> addContactToUser({
    required String userPhone,
    required String contactName,
    required String contactPhone,
  }) async {
    try {
      await _firestore.collection('users').doc(userPhone).update({
        'contactList': FieldValue.arrayUnion([
          {'contactName': contactName, 'phoneNumber': contactPhone},
        ]),
      });
      print('Contact added successfully');
    } catch (e) {
      print('Error adding contact: $e');
      rethrow;
    }
  }

  // Update user's about
  static Future<void> updateUserAbout({required String userPhone, required String about}) async {
    try {
      await _firestore.collection('users').doc(userPhone).update({'about': about});
      print('About updated successfully');
    } catch (e) {
      print('Error updating about: $e');
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
      print('Online status updated');
    } catch (e) {
      print('Error updating online status: $e');
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
      print('Error getting user data: $e');
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
      print('Profile picture updated successfully');
    } catch (e) {
      print('Error updating profile picture: $e');
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
        print('Contact removed successfully');
      }
    } catch (e) {
      print('Error removing contact: $e');
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
      print('Error getting user contacts: $e');
      rethrow;
    }
  }

  //
}
