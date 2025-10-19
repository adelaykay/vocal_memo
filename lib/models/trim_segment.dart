class TrimSegment {
  final Duration start;
  final Duration end;

  TrimSegment({required this.start, required this.end});

  Duration get duration => end - start;

  Map<String, dynamic> toJson() => {
    'start': start.inMilliseconds,
    'end': end.inMilliseconds,
  };

  factory TrimSegment.fromJson(Map<String, dynamic> json) => TrimSegment(
    start: Duration(milliseconds: json['start'] as int),
    end: Duration(milliseconds: json['end'] as int),
  );

  TrimSegment copyWith({Duration? start, Duration? end}) => TrimSegment(
    start: start ?? this.start,
    end: end ?? this.end,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TrimSegment &&
              runtimeType == other.runtimeType &&
              start == other.start &&
              end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}