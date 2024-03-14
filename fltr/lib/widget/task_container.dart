import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fltr/models/task.dart';
import 'dart:async';

class TaskContainer extends StatelessWidget {

  final Task task;
  final Function(Task, bool) onTaskCompleted;
  final Function(Task) onEditTask;
  final Function(Task) onDeleteTask;

  const TaskContainer({
    required this.task,
    required this.onTaskCompleted,
    required this.onEditTask,
    required this.onDeleteTask,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(8),
        child: Dismissible(
          key: Key(task.id),
          background:
          task.isDone ? Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.blue,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.clear, color: Colors.white),
                ),
              ],
            ),
          ):Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color(0xFFB1D199),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.check, color: Colors.white),
                ),
              ],
            ),
          ),
          secondaryBackground: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color(0xFFFEB5BD),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
              ],
            ),
          ),
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd && !task.isDone) {
              onTaskCompleted(task, true);
            } else if (direction == DismissDirection.endToStart) {
              _Delete(context, task);
            }
          },
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd && !task.isDone) {
              onTaskCompleted(task, true);
              return false;
            } else if (direction == DismissDirection.endToStart) {
              final delete = await _showDeleteSnackBar(context);
              if (delete) {
                _Delete(context, task);
              }
              return delete;
            }
            return false;
          },
          child: Row(
            children: [
              Checkbox(
                value: task.isDone,
                onChanged: (newValue) {
                  onTaskCompleted(task, !task.isDone);
                },
              ),
              SizedBox(width: 8), // Добавлено для создания отступа между радиобаттоном и текстом
              Expanded( // Добавлен Expanded для размещения текстового содержимого слева
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                    ),
                    Row(
                      children: [
                        Transform.rotate(
                          angle: 3.925,
                          child: Icon(Icons.label_outline_rounded, color: Colors.lightBlue, size: 15,),
                        ),
                        SizedBox(width: 3),
                        Text(
                          '${task.tag.name}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 8),
                        if (task.finish != null && task.finish!.isNotEmpty) // Проверка на наличие и непустоту значения
                          Text(
                            ' ${_formatDate(task.finish!)}',
                            style: TextStyle(
                              color: _getPriorityColor(task.priority),
                            ),
                          ),
                      ],
                    ),

                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  onEditTask(task);
                  print('object');
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Transform.rotate(
                    angle: 3.14, // угол поворота в радианах (pi радианов равно 180 градусам)
                    child: Icon(Icons.error_outline, color: Colors.lightGreen, ),
                  ),
                ),
              ),
            ],
          ),
        ),

      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      default:
        return Colors.black;
    }
  }
  String _formatDate(String stringdate) {
    DateTime dateTime = DateTime.parse(stringdate);
    final russianMonths = [
      '', 'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    final day = dateTime.day;
    final month = russianMonths[dateTime.month];
    return '$day $month';
  }

  Future<bool> _showDeleteSnackBar(BuildContext context) async {
    bool delete = true;
    final snackBarController = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Вы уверены, что хотите удалить задачу?'),
        action: SnackBarAction(
          label: 'Отмена',
          onPressed: () {
            delete = false;
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
    await snackBarController.closed;
    return delete;
  }

  Future<void> _Delete(BuildContext context, Task task) async {
    onDeleteTask(task);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Задача "${task.title}" удалена'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
