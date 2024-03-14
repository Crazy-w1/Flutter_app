class Task {

  final String id;
  late final String sid;
  final String title;
  final String text;
  String? finish;
  final bool isDone;
  final int priority;
  final Tag tag;
  final String created;

  Task({
    required this.id,
    required this.sid,
    required this.title,
    required this.text,
    required this.isDone,
    required this.priority,
    required this.tag,
    required this.created,
    this.finish,
  });

  @override
  String toString() {
    return 'Task{id: $id, sid: $sid, title: $title, text: $text, isDone: $isDone, priority: $priority, tag: $tag, created: $created,finish: $finish}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sid': sid,
      'title': title,
      'text': text,
      'finish': finish,
      'isDone': isDone ? 1 : 0, // SQLite не поддерживает тип boolean, поэтому используем 1 и 0
      'priority': priority,
      'tag_name': tag.name,
      'tag_sid': tag.sid,
      'created': created,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'].toString() ,
      sid: map['sid'],
      title: map['title'],
      text: map['text'],
      finish: map['finish'],
      isDone: map['isDone'] == 1 ? true : false,
      priority: map['priority'],
      tag: Tag(name: map['tag_name'], sid: map['tag_sid']),
      created: map['created'],
    );
  }


  Task copyWith({
    String? id,
    String? sid,
    String? title,
    String? text,
    String? finish,
    bool? isDone,
    int? priority,
    Tag? tag,
    String? created,
  }) {
    return Task(
      id: id ?? this.id,
      sid: sid ?? this.sid,
      title: title ?? this.title,
      text: text ?? this.text,
      finish: finish ?? this.finish,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      tag: tag ?? this.tag,
      created: created ?? this.created,
    );
  }

}

class Tag {
  final String name;
  final String sid;

  Tag({
    required this.name,
    required this.sid,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sid': sid,
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      name: map['name'] as String,
      sid: map['sid'] as String,
    );
  }
}