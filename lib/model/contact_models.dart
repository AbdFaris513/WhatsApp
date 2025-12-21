class ContactData {
  final String id; // unique contact id
  final String contactFirstName;
  final String? contactSecondName;
  final String? contactBusinessName;
  String contactNumber;
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
    required this.id,
    required this.contactFirstName,
    this.contactSecondName,
    this.contactBusinessName,
    required this.contactNumber,
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
      id: id ?? this.id,
      contactFirstName: contactFirstName ?? this.contactFirstName,
      contactSecondName: contactSecondName ?? this.contactSecondName,
      contactBusinessName: contactBusinessName ?? this.contactBusinessName,
      contactNumber: contactNumber ?? this.contactNumber,
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
}
