import 'package:flutter/material.dart';
import 'package:fltr/models/task.dart';
import 'package:fltr/pages/editTask_pages.dart';
import 'package:intl/intl.dart';

class TaskView extends StatefulWidget {
  final List<Tag> tagsList;
  final List<String> tagsNameList;
  final List<Task> Tasks;
  final List<Task> completedTasks;
  late final Task task;

  TaskView({required this.tagsList, required this.tagsNameList, required this.Tasks, required this.task, required this.completedTasks});

  @override
  _TaskViewState createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {

  void reloadPage(Task newtask) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext context) => TaskView(tagsList: widget.tagsList, tagsNameList: widget.tagsNameList, Tasks: widget.Tasks, task: newtask, completedTasks: widget.completedTasks),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Задача'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              print('dddddd ${widget.task}');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTaskPage(tagsList: widget.tagsList, tagsNameList: widget.tagsNameList, Tasks: widget.Tasks, task: widget.task,completedTasks: widget.completedTasks),
                ),

              ).then((value) {
                reloadPage(value);
              });

            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Название вверху по середине
            Center(
              child: Text(
                '${widget.task.title}',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            // Блок текста для описания
            Text(
              'Описание: \n${widget.task.text}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            // Разделительная черта
            Divider(),
            SizedBox(height: 16),
            Text(
              'Дата создания: ${_formatDateTime(widget.task.created)}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            if (widget.task.finish != null)
              Text(
                'Дата завершения: ${_formatDateTime(widget.task.finish!)}',
                style: TextStyle(fontSize: 18),
              ),
            SizedBox(height: 8),
            Text(
              'Приоритет: ${ _getPriorityText(widget.task.priority)}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Статус: ${widget.task.isDone ? 'Завершено' : 'Не завершено'}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
  }


  String _getPriorityText(int priority) {
    switch (priority) {
      case 0:
        return 'Высокий';
      case 1:
        return 'Средний';
      case 2:
        return 'Низкий';
      default:
        return '';
    }
  }
}
