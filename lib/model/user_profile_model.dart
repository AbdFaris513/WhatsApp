class UserProfile {
  final String about;
  final List<Contact> contactList;
  final String name;
  final String phone;
  final String profilePicture;
  final bool isOnline;
  final String lastSeen;
  final DateTime createdAt;

  UserProfile({
    required this.about,
    required this.contactList,
    required this.name,
    required this.phone,
    required this.profilePicture,
    required this.isOnline,
    required this.lastSeen,
    required this.createdAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      about: map['about'] ?? '',
      contactList: (map['contactList'] as List<dynamic>? ?? [])
          .map((e) => Contact.fromMap(e as Map<String, dynamic>))
          .toList(),
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] ?? '',
      createdAt: map['createdAt'] is DateTime ? map['createdAt'] : (map['createdAt']?.toDate()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'about': about,
      'contactList': contactList.map((e) => e.toMap()).toList(),
      'name': name,
      'phone': phone,
      'profilePicture': profilePicture,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'createdAt': createdAt,
    };
  }

  /// EMPTY CONSTRUCTOR
  factory UserProfile.empty() {
    return UserProfile(
      about: '',
      contactList: [],
      name: '',
      phone: '',
      profilePicture: '',
      isOnline: false,
      lastSeen: '',
      createdAt: DateTime.now(),
    );
  }
}

// *-*-*-*-*-*-*-*-*-*- Contact List *-*-*-*-*-*-*-*-*-*- //
class Contact {
  final String contactName;
  final String phoneNumber;

  Contact({required this.contactName, required this.phoneNumber});

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(contactName: map['contactName'] ?? '', phoneNumber: map['phoneNumber'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'contactName': contactName, 'phoneNumber': phoneNumber};
  }
}
