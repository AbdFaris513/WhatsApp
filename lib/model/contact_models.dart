class ContactData {
  final String contactNumber; // unique contact id
  final String contactFirstName;
  final String? contactSecondName;
  final String? contactBusinessName;
  final String? contactStatus; // "Busy", "Available", etc.
  final String? contactImage;
  final DateTime? contactLastSeen;
  final DateTime? contactLastMsgTime;
  final String? contactLastMsg;
  final String? contactLastMsgType; // text, image, video, audio
  final int unreadMessages;
  final bool isContactPinned;
  final bool isContactMuted;
  final bool isContactBlocked;
  final bool isContactArchived;
  final bool isOnline; // live presence
  final String? about; // "Hey there! I am using WhatsApp"
  final String? lastMessageId; // for message referencing
  final DateTime? lastInteraction; // for sorting chats
  final List<String>? labels; // WhatsApp Business tags

  ContactData({
    required this.contactNumber,
    required this.contactFirstName,
    this.contactSecondName,
    this.contactBusinessName,
    this.contactStatus,
    this.contactImage,
    this.contactLastSeen,
    this.contactLastMsgTime,
    this.contactLastMsg,
    this.contactLastMsgType,
    this.unreadMessages = 0,
    this.isContactPinned = false,
    this.isContactMuted = false,
    this.isContactBlocked = false,
    this.isContactArchived = false,
    this.isOnline = false,
    this.about,
    this.lastMessageId,
    this.lastInteraction,
    this.labels,
  });

  factory ContactData.fromJson(Map<String, dynamic> json) {
    return ContactData(
      contactNumber: json['contactNumber'] ?? '',
      contactFirstName: json['contactFirstName'] ?? '',
      contactSecondName: json['contactSecondName'],
      contactBusinessName: json['contactBusinessName'],
      contactStatus: json['contactStatus'],
      contactImage: json['contactImage'],
      contactLastSeen: json['contactLastSeen'] != null
          ? DateTime.parse(json['contactLastSeen'])
          : null,
      contactLastMsgTime: json['contactLastMsgTime'] != null
          ? DateTime.parse(json['contactLastMsgTime'])
          : null,
      contactLastMsg: json['contactLastMsg'],
      contactLastMsgType: json['contactLastMsgType'],
      unreadMessages: json['unreadMessages'] ?? 0,
      isContactPinned: json['isContactPinned'] ?? false,
      isContactMuted: json['isContactMuted'] ?? false,
      isContactBlocked: json['isContactBlocked'] ?? false,
      isContactArchived: json['isContactArchived'] ?? false,
      isOnline: json['isOnline'] ?? false,
      about: json['about'],
      lastMessageId: json['lastMessageId'],
      lastInteraction: json['lastInteraction'] != null
          ? DateTime.parse(json['lastInteraction'])
          : null,
      labels: json['labels'] != null ? List<String>.from(json['labels']) : null,
    );
  }

  // Add this to your ContactModel class
  ContactData copyWith({
    String? id,
    String? contactFirstName,
    String? contactSecondName,
    String? contactBusinessName,
    String? contactNumber,
    String? contactStatus,
    String? contactImage,
    DateTime? contactLastSeen,
    DateTime? contactLastMsgTime,
    String? contactLastMsg,
    String? contactLastMsgType,
    int? unreadMessages,
    bool? isContactPinned,
    bool? isContactMuted,
    bool? isContactBlocked,
    bool? isContactArchived,
    bool? isOnline,
    String? about,
    String? lastMessageId,
    DateTime? lastInteraction,
    List<String>? labels,
  }) {
    return ContactData(
      contactNumber: contactNumber ?? this.contactNumber,
      contactFirstName: contactFirstName ?? this.contactFirstName,
      contactSecondName: contactSecondName ?? this.contactSecondName,
      contactBusinessName: contactBusinessName ?? this.contactBusinessName,
      contactStatus: contactStatus ?? this.contactStatus,
      contactImage: contactImage ?? this.contactImage,
      contactLastSeen: contactLastSeen ?? this.contactLastSeen,
      contactLastMsgTime: contactLastMsgTime ?? this.contactLastMsgTime,
      contactLastMsg: contactLastMsg ?? this.contactLastMsg,
      contactLastMsgType: contactLastMsgType ?? this.contactLastMsgType,
      unreadMessages: unreadMessages ?? this.unreadMessages,
      isContactPinned: isContactPinned ?? this.isContactPinned,
      isContactMuted: isContactMuted ?? this.isContactMuted,
      isContactBlocked: isContactBlocked ?? this.isContactBlocked,
      isContactArchived: isContactArchived ?? this.isContactArchived,
      isOnline: isOnline ?? this.isOnline,
      about: about ?? this.about,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      labels: labels ?? this.labels,
    );
  }

  factory ContactData.fromContactOnlyJson(Map<String, dynamic> json) {
    return ContactData(
      contactNumber: json['contactNumber'] ?? '',
      contactFirstName: json['contactName'] ?? '',
    );
  }

  Map<String, dynamic> toMapForContact() {
    return {'contactNumber': contactNumber, 'contactName': contactFirstName};
  }

  Map<String, dynamic> toMap() {
    return {
      'contactNumber': contactNumber,
      'contactFirstName': contactFirstName,
      'contactSecondName': contactSecondName,
      'contactBusinessName': contactBusinessName,
      'contactStatus': contactStatus,
      'contactImage': contactImage,
      'contactLastSeen': contactLastSeen,
      'contactLastMsgTime': contactLastMsgTime,
      'contactLastMsg': contactLastMsg,
      'contactLastMsgType': contactLastMsgType,
      'unreadMessages': unreadMessages,
      'isContactPinned': isContactPinned,
      'isContactMuted': isContactMuted,
      'isContactBlocked': isContactBlocked,
      'isContactArchived': isContactArchived,
      'isOnline': isOnline,
      'about': about,
      'lastMessageId': lastMessageId,
      'lastInteraction': lastInteraction,
      'labels': labels,
    };
  }
}
