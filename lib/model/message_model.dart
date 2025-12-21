import 'dart:convert';

enum MessageType { text, image, video, audio, file }

enum MessageStatus { sending, sent, delivered, seen, failed }

class MessageModel {
  final String id; // unique message id
  final String msg;
  final String msgSender;
  final String msgReceiver;

  final MessageType type;
  final MessageStatus status;

  final DateTime sendTime;
  final DateTime? receiveTime;
  final DateTime? viewTime;

  final bool isForward;
  final String? originalSender; // if forwarded
  final bool isReplied;
  final String? replyMsgId;

  final bool isStarred;
  final bool isEdited;

  // optional media fields
  final String? mediaUrl;
  final String? thumbnailUrl;
  final Duration? duration; // for audio/video

  const MessageModel({
    required this.id,
    required this.msg,
    required this.msgSender,
    required this.msgReceiver,
    required this.type,
    required this.status,
    required this.sendTime,
    this.receiveTime,
    this.viewTime,
    this.isForward = false,
    this.originalSender,
    this.isReplied = false,
    this.replyMsgId,
    this.isStarred = false,
    this.isEdited = false,
    this.mediaUrl,
    this.thumbnailUrl,
    this.duration,
  });

  /// ✅ Message time (formatted HH:mm)
  String get messageTime =>
      "${sendTime.hour.toString().padLeft(2, '0')}:${sendTime.minute.toString().padLeft(2, '0')}";

  /// ✅ CopyWith for immutability
  MessageModel copyWith({
    String? id,
    String? msg,
    String? msgSender,
    String? msgReceiver,
    MessageType? type,
    MessageStatus? status,
    DateTime? sendTime,
    DateTime? receiveTime,
    DateTime? viewTime,
    bool? isForward,
    String? originalSender,
    bool? isReplied,
    String? replyMsgId,
    bool? isStarred,
    bool? isEdited,
    String? mediaUrl,
    String? thumbnailUrl,
    Duration? duration,
  }) {
    return MessageModel(
      id: id ?? this.id,
      msg: msg ?? this.msg,
      msgSender: msgSender ?? this.msgSender,
      msgReceiver: msgReceiver ?? this.msgReceiver,
      type: type ?? this.type,
      status: status ?? this.status,
      sendTime: sendTime ?? this.sendTime,
      receiveTime: receiveTime ?? this.receiveTime,
      viewTime: viewTime ?? this.viewTime,
      isForward: isForward ?? this.isForward,
      originalSender: originalSender ?? this.originalSender,
      isReplied: isReplied ?? this.isReplied,
      replyMsgId: replyMsgId ?? this.replyMsgId,
      isStarred: isStarred ?? this.isStarred,
      isEdited: isEdited ?? this.isEdited,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
    );
  }

  /// ✅ Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "msg": msg,
      "msgSender": msgSender,
      "msgReceiver": msgReceiver,
      "type": type.name,
      "status": status.name,
      "sendTime": sendTime.toIso8601String(),
      "receiveTime": receiveTime?.toIso8601String(),
      "viewTime": viewTime?.toIso8601String(),
      "isForward": isForward,
      "originalSender": originalSender,
      "isReplied": isReplied,
      "replyMsgId": replyMsgId,
      "isStarred": isStarred,
      "isEdited": isEdited,
      "mediaUrl": mediaUrl,
      "thumbnailUrl": thumbnailUrl,
      "duration": duration?.inMilliseconds,
    };
  }

  /// ✅ Create from JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json["id"],
      msg: json["msg"],
      msgSender: json["msgSender"],
      msgReceiver: json["msgReceiver"],
      type: MessageType.values.firstWhere(
        (e) => e.name == json["type"],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json["status"],
        orElse: () => MessageStatus.sending,
      ),
      sendTime: DateTime.parse(json["sendTime"]),
      receiveTime: json["receiveTime"] != null ? DateTime.parse(json["receiveTime"]) : null,
      viewTime: json["viewTime"] != null ? DateTime.parse(json["viewTime"]) : null,
      isForward: json["isForward"] ?? false,
      originalSender: json["originalSender"],
      isReplied: json["isReplied"] ?? false,
      replyMsgId: json["replyMsgId"],
      isStarred: json["isStarred"] ?? false,
      isEdited: json["isEdited"] ?? false,
      mediaUrl: json["mediaUrl"],
      thumbnailUrl: json["thumbnailUrl"],
      duration: json["duration"] != null ? Duration(milliseconds: json["duration"]) : null,
    );
  }

  /// ✅ Encode to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// ✅ Decode from JSON string
  factory MessageModel.fromJsonString(String str) => MessageModel.fromJson(jsonDecode(str));
}
