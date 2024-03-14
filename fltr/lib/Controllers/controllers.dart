import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fltr/models/task.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DatabaseController {
  late Database _database;
  final _storage = FlutterSecureStorage();

  DatabaseController() {
    initialize();
  }

  Future<void> initialize() async {
    String Email = (await _storage.read(key: 'user_email')).toString();

    final String path = await getDatabasesPath();
    String EmailIdDB = Email.replaceAll('.', '').replaceAll('@', '');
    final String databasePath = join(path, 'Tasks${EmailIdDB}.db');
    print('\n ВХОД В БД ПОД  ${Email} путь ${databasePath}');
    // Проверяем существование базы данных

    Future<bool> databaseExists(String path) =>
        databaseFactory.databaseExists(path);
    bool databaseDoesNotExist = !(await databaseExists(databasePath));
    if (databaseDoesNotExist) {
      _database = await openDatabase(
        databasePath,
        version: 1,
        onCreate: (db, version) {
          db.execute('''
          CREATE TABLE tasks (
             id INTEGER PRIMARY KEY AUTOINCREMENT,
            sid TEXT,
            title TEXT,
            text TEXT,
            finish TEXT,
            isDone INTEGER,
            priority INTEGER,
            tag_name TEXT,
            tag_sid TEXT,
            created TEXT
          )
        ''');
          db.execute('''
          CREATE TABLE tags (
            name TEXT,
            sid TEXT PRIMARY KEY
          )
        ''');
        },
      );
    } else {
      // База данных уже существует, инициализация не требуется
      _database = await openDatabase(databasePath);
      print(' \nDatabase already exists\n ');
    }
  }

//  возвращает все задачи из бд
  Future<List<Task>> getListOfTasks() async {
    final List<Map<String, dynamic>> tasks = await _database.rawQuery('SELECT * FROM tasks');
    List<Task> t = tasks.map((task) => Task.fromMap(task)).toList();
    return tasks.map((task) => Task.fromMap(task)).toList();
  }

// вставка списка задач в бд
  Future<void> insertListOfTask(List<Task> tasks) async{
    for (Task task in tasks){
      insertTask(task);
    }
  }
// добовляет одну задачу в бд
  Future<void> insertTask(Task task) async {
    List<Map<String, dynamic>> existingTasks = await _database.query(
      'tasks',
      where: 'sid = ?',
      whereArgs: [task.sid],
    );
    print(" alooooooooo ${task}");

    if (existingTasks.isNotEmpty && task.sid.isNotEmpty) {
      print('Task with the same sid already exists, not inserting new task');

    }else{
      try {
        await _database.insert(
          'tasks',
          {
            'sid': task.sid,
            'title': task.title,
            'text': task.text,
            'finish': task.finish,
            'isDone': task.isDone ? 1 : 0,
            'priority': task.priority,
            'tag_name': task.tag.name,
            'tag_sid': task.tag.sid,
            'created': task.created,
          },
        );
      } catch (e) {
        print('Error inserting task: $e');
      }
    }



  }

// обновляет задачу в бд
  Future<void> updateTask(Task task) async {
    print(task);
    await _database.update(
      'tasks',
      {
        'sid': task.sid,
        'title': task.title,
        'text': task.text,
        'finish': task.finish,
        'isDone': task.isDone ? 1 : 0,
        'priority': task.priority,
        'tag_name': task.tag.name,
        'tag_sid': task.tag.sid,
        'created': task.created,
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }


// удаляет задачу из бд
  Future<void> deleteTask(Task task) async {
    await _database.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
//добавляет категорию в бд
  Future<void> insertTag(Tag tag) async {
    try {
      await _database.insert(
        'tags',
        tag.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace, // Обновляем существующую запись
      );
    } catch (e) {
      // Обработка ошибок при вставке
      print('Error inserting tag: $e');
    }
  }
//возвращает все категории из бд
  Future<List<Tag>> getListOfTag() async {
    final List<Map<String, dynamic>> tasks = await _database.query('tags');
    return tasks.map((task) => Tag.fromMap(task)).toList();
  }
// вставка списка категорий в бд
  Future<void> insertListOfTag(List<Tag> tags) async{
    for (Tag tag in tags){
      insertTag(tag);
    }
  }
//закрывает соединение с бд
  Future<void> close() async {
    await _database.close();
  }
}
