// lib/models/recording.dart
import 'package:intl/intl.dart';

class Recording {
  final String id;
  final String fileName;
  String? title;
  final String filePath;
  final DateTime createdAt;
  final Duration duration;
  bool isFavorite;
  bool isPinned;
  final List<String> tags;
  final String? folderId;
  String? transcript;
  bool isTranscribing;

  Recording({
    required this.id,
    required this.fileName,
    this.title,
    required this.filePath,
    required this.createdAt,
    required this.duration,
    this.isFavorite = false,
    this.isPinned = false,
    this.tags = const [],
    this.folderId,
    this.transcript,
    this.isTranscribing = false,
  });

  String get displayTitle => title ?? 'Memo ${DateFormat('MMM d, h:mm a').format(createdAt)}';

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedDate => DateFormat('MMM d, yyyy').format(createdAt);

  String get formattedTime => DateFormat('h:mm a').format(createdAt);

  Map<String, dynamic> toJson() => {
    'id': id,
    'fileName': fileName,
    'title': title,
    'filePath': filePath,
    'createdAt': createdAt.toIso8601String(),
    'durationMs': duration.inMilliseconds,
    'isFavorite': isFavorite,
    'isPinned': isPinned,
    'tags': tags,
    'folderId': folderId,
    'transcript': transcript,
    'isTranscribing': isTranscribing,
  };

  factory Recording.fromJson(Map<String, dynamic> json) => Recording(
    id: json['id'] as String,
    fileName: json['fileName'] as String,
    title: json['title'] as String?,
    filePath: json['filePath'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    duration: Duration(milliseconds: json['durationMs'] as int),
    isFavorite: json['isFavorite'] as bool? ?? false,
    isPinned: json['isPinned'] as bool? ?? false,
    tags: List<String>.from(json['tags'] as List? ?? []),
    folderId: json['folderId'] as String?,
    transcript: json['transcript'] as String?,
    isTranscribing: json['isTranscribing'] as bool? ?? false,
  );

  Recording copyWith({
    String? id,
    String? fileName,
    String? title,
    String? filePath,
    DateTime? createdAt,
    Duration? duration,
    bool? isFavorite,
    bool? isPinned,
    List<String>? tags,
    String? folderId,
    String? transcript,
    bool? isTranscribing,
  }) =>
      Recording(
        id: id ?? this.id,
        fileName: fileName ?? this.fileName,
        title: title ?? this.title,
        filePath: filePath ?? this.filePath,
        createdAt: createdAt ?? this.createdAt,
        duration: duration ?? this.duration,
        isFavorite: isFavorite ?? this.isFavorite,
        isPinned: isPinned ?? this.isPinned,
        tags: tags ?? this.tags,
        folderId: folderId ?? this.folderId,
        transcript: transcript ?? this.transcript,
        isTranscribing: isTranscribing ?? this.isTranscribing,
      );
}
