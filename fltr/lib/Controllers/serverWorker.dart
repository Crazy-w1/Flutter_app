import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fltr/models/task.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ServerWorker {
  final _storage = FlutterSecureStorage();

  ServerWorker();
// _savetoken и _savename сохраняют данные пользователя и токен в защищённое хранилище
  Future<void> _savetoken(String access_token, String refresh_token) async{

    await _storage.write(key: 'access_token', value: access_token);
    await _storage.write(key: 'refresh_token', value: refresh_token);

  }

  Future<void> _savename(String name,String email) async{
    print(" сохранение имён ${name} ${email}");

    await _storage.write(key: 'user_name', value: name);
    await _storage.write(key: 'user_email', value: email);

  }
  Future<void> cleardata() async{
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_name');
    await _storage.delete(key: 'user_email');
  }

  Future<bool> logout() async {
    final String url = 'https://test-mobile.estesis.tech/api/v1/logout?everywhere=false';
    final String accessToken = (await _storage.read(key: 'access_token')).toString();
    print('accessToken ${accessToken}');
    if(accessToken == null){
      return true;
    }

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': accessToken,
      },
    );
    if (response.statusCode == 200) {
      await cleardata();
      return true;
    } else if (response.statusCode == 401) {
      await cleardata();
      return true;
    }
    return false;
  }

  //Вход

  Future<bool> userVerification(String email, String password) async {
    const String url = 'https://test-mobile.estesis.tech/api/v1/login';

    final body = {
      'username': email,
      'password': password,
    };
    final encodedBody = Uri(queryParameters: body).query;

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: encodedBody,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      _savetoken(responseData["access_token"], responseData["refresh_token"]);

      await getUserInfo();
      return true;
    }
    return false;

  }

  //Регистрация

  Future<bool> UserRegister(String name, String email, String password) async {
    // URL сервера
    const String url = 'https://test-mobile.estesis.tech/api/v1/register';

    // Создание тела запроса в формате JSON
    Map<String, dynamic> body = {
      'name': name,
      'email': email,
      'password': password,
    };
    String jsonBody = jsonEncode(body);

    // Отправка POST-запроса на сервер
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonBody,
    );

    // Проверка статуса ответа
    if (response.statusCode == 200 ) {
      // Если успешно, обработайте успешный ответ
      if (await userVerification(email,password)){
        _savename(name, email);
        return true;
      }
    }
    return false;
  }

  //Получение данных пользователя

  Future<void> getUserInfo() async {
    final String url = 'https://test-mobile.estesis.tech/api/v1/users/me';
    final String accessToken = (await _storage.read(key: 'access_token')).toString();

    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    print(" получение имя ${response.statusCode}");
    if (response.statusCode == 200) {

      Map<String, dynamic> responseData = jsonDecode(response.body);
      print('object ${responseData["name"]} ${responseData["email"]}');
      await _savename(responseData["name"].toString(),responseData["email"].toString());
    } else { }
  }


//получение всех категорий
  Future<void> getAllTags(List<Tag> tags) async {
    final String url = 'https://test-mobile.estesis.tech/api/v1/tags?limit=50&offset=0';
    final String? accessToken = await _storage.read(key: 'access_token');

    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    print(response.statusCode);

    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes); // Декодирование с помощью UTF-8
      Map<String, dynamic> responseData = jsonDecode(responseBody); // Используем декодированные данные из responseBody
      final List<dynamic> tagData = responseData['items'];
      List<Tag> newTags = tagData.map((tag) => Tag(name: tag['name'].toString(), sid: tag['sid'])).toList();
      tags.clear();
      tags.addAll(newTags);
    } else {
      throw Exception('Failed to load tags');
    }
  }
  //получение всех задач
  Future<void> getAllOwnTasks(List<Task> tasks) async {
    final String url = 'https://test-mobile.estesis.tech/api/v1/tasks?limit=50&offset=0';
    final String? accessToken = await _storage.read(key: 'access_token');

    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final String responseBody = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> responseData = jsonDecode(responseBody);
      final List<dynamic> taskData = responseData['items'];

      tasks.clear();
      for (var task in taskData) {
        tasks.add(Task(
          sid: task['sid'],
          isDone: task['isDone'],
          title: task['title'],
          text: task['text'],
          finish: task['finishAt'],
          priority: task['priority'],
          tag: Tag(
            name: task['tag']['name'],
            sid: task['tag']['sid'],
          ),
          created: task['createdAt'], id: '',
        ));
      }
    } else {
      throw Exception('Failed to load tasks');
    }
  }


// создание задачи
  Future<String> createTask(Task task) async {
    final String url = 'https://test-mobile.estesis.tech/api/v1/tasks';
    final String accessToken = (await _storage.read(key: 'access_token')).toString();


    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'tagSid': task.tag.sid,
        'title': task.title,
        'text': task.text,
        'finishAt': task.finish,
        'priority': task.priority,
      }),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData['sid'];
    } else {
      throw Exception('Failed to create task');
    }
  }
// обновления
  Future<bool> updateTask(Task task) async {
    final String url = 'https://test-mobile.estesis.tech/api/v1/tasks';
    final String accessToken = (await _storage.read(key: 'access_token')).toString();

    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': task.title,
        'text': task.text,
        'finishAt': task.finish,
        'priority': task.priority,
        'tagSid': task.tag.sid,
        'isDone': task.isDone,
        'sid': task.sid,
      }),
    );
    print('update status ${response.statusCode} tag sid ${task.tag.sid}');
    if (response.statusCode == 200) {
      return true;
    } else {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print ('up eror ${responseData['detail']}');
      return false;
    }
    }
  //удаление
  Future<bool> deleteTask(Task task) async {
    final String url = 'https://test-mobile.estesis.tech/api/v1/tasks?taskSid=${task.sid}';
    final String accessToken = (await _storage.read(key: 'access_token')).toString();

    final response = await http.delete(
      Uri.parse(url),
      headers: <String, String>{
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print('delete ${response.statusCode}');


    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete task');
    }
  }
//Обновления токена
  Future<bool> LoginToken() async {
    String refreshToken = (await _storage.read(key: 'refresh_token')).toString();
    if (refreshToken == null){
      return false;
    }
    try {
      final url = Uri.parse('https://test-mobile.estesis.tech/api/v1/refresh_token?refresh_token=$refreshToken');

      var response = await http.post(
        url,
        headers: <String, String>{
          'accept': 'application/json',
        },
      );

      print ('kod : ${response.statusCode}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        await _storage.write(key: 'access_token', value: responseData["access_token"]);
        await _storage.write(key: 'refresh_token', value: responseData["refresh_token"]);
        return true;
      } else if (response.statusCode == 401) {
        cleardata();
      }
      return false;
    } catch(e) {
      final String accessToken = (await _storage.read(key: 'access_token')).toString();
      bool re = false;
      if (refreshToken != accessToken) {
        print('re ${refreshToken}');
        re = true;
      }
      return re;
    }
  }

}

