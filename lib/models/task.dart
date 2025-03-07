// Defines a Task object
class Task {
  // fields
  int? id;
  String? title;
  String? note;
  int? isCompleted;
  String? date;
  String? startTime;
  String? endTime;
  int? color;
  int? remind;
  String? repeat;

  // constructor
  Task({
    this.id,
    this.color,
    this.date,
    this.endTime,
    this.isCompleted,
    this.note,
    this.remind,
    this.repeat,
    this.startTime,
    this.title,
  });

  // parse from a JSON string
  Task fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        note: json['note'],
        isCompleted: json['isCompleted'],
        remind: json['remind'],
        repeat: json['repeat'],
        startTime: json['startTime'],
        color: json['color'],
        endTime: json['endTime'],
        date: json['date'],
      );

  // convert to a Map
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'note': note,
        'isCompleted': isCompleted,
        'remind': remind,
        'repeat': repeat,
        'color': color,
        'endTime': endTime,
        'date': date,
        'startTime': startTime,
      };
}
