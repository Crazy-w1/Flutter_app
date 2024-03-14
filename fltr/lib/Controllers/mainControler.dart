import 'package:fltr/models/task.dart';
import 'package:fltr/Controllers/serverWorker.dart';
import 'package:fltr/Controllers/controllers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';



class DataControler {
  late ServerWorker _SerwWork = ServerWorker();
  late final DatabaseController _BDdata;

  DataControler();

  Future<void> initialize() async {
    _BDdata = DatabaseController();
    await _BDdata.initialize();
  }

  Future<String> getUserName() async {
    final _storage = FlutterSecureStorage();
    return await _storage.read(key: 'user_name') ?? '';
  }

  Future<void> getUserEmail() async {

  }

  Future<bool> loginToken()async{
    bool temp = false;
    try{
      for(int i = 0; i < 2;i++){
        temp = await _SerwWork.LoginToken();
        print(temp);
      }
    }catch(e){}

    return temp;
  }

  Future<bool> logOut() async{
    try{bool res = await _SerwWork.logout();

    _SerwWork.cleardata();
      return res;
    }catch(e){
      _SerwWork.cleardata();
      return true;
    }
  }

  Future<void> inserDataInBD(List<Tag> inputTags, List<Task> inputTasks)async{
    try{
      await _BDdata.insertListOfTag(inputTags);
      await _BDdata.insertListOfTask(inputTasks);
      print('\n[Log][DataControler][inserDataInBD][Status] : Seccess');
    }catch(e){
      print('\n[Log][DataControler][inserDataInBD][Error] : $e');
    }
  }

  Future<void> synchronization() async{
    initialize();


  }
//загружаем данные с сервера или бд при этом синхронезируем
  Future<void> loadData(List<String> tagNames,List<Task> inputTasks, List<Tag> inputTags, List<Task> completedTasks) async {
    try{
      List<Task> localTasks =[], serverTasks =[];
      await _SerwWork.getAllOwnTasks(serverTasks);
      localTasks.addAll(await _BDdata.getListOfTasks());

      for (Task taskL in localTasks){
        if(taskL.sid.isEmpty){
          Task temp = taskL.copyWith(sid: await _SerwWork.createTask(taskL));
          await _BDdata.updateTask(temp);
        }
      }

      for (Task taskS in serverTasks){
        print('ffffffffffffffff ${taskS}');
        bool isDeletOnLocal = true;
        for(Task taskL in localTasks){
          if (taskS.sid == taskL.sid){
            isDeletOnLocal = false;
            break;
          }
        }
        if (isDeletOnLocal){
          await _SerwWork.deleteTask(taskS);
        }
      }

      print('\n[Log][DataControler][synchronization][Online][Status] Seccess');
    }catch(e){
      print('\n[Log][DataControler][synchronization][Online][Error][Status] Ofline : $e');
    }
    try {

      inputTags.clear();
      await _SerwWork.getAllTags(inputTags);
      inputTasks.clear();
      tagNames.clear();
      await _SerwWork.getAllOwnTasks(inputTasks);
      tagNames.addAll(inputTags.map((tag) => tag.name));
      await inserDataInBD(inputTags,inputTasks);

      inputTasks.clear();
      inputTasks.addAll(await _BDdata.getListOfTasks());

      completedTasks.clear();
      if(inputTasks.length == 1){
        if(inputTasks[0].isDone){
          completedTasks.add(inputTasks[0]);
          inputTasks.clear();
        }
      }else{
      completedTasks = inputTasks.where((task) => task.isDone).toList();
      inputTasks.removeWhere((task) => task.isDone);}

      print('\n[Log][DataControler][loadData][Online][Ststus] : Success');
    } catch (e) {
      print('\n[Log][DataControler][loadData][Online][Error] : $e');
      // Если произошла ошибка то мы офлайн, а значит возвращаем список из бд
      tagNames.clear();
      inputTags.clear();
      inputTags.addAll(await _BDdata.getListOfTag());
      tagNames.addAll(inputTags.map((tag) => tag.name));
      inputTasks.clear();
      inputTasks.addAll(await _BDdata.getListOfTasks());
      completedTasks.clear();
      completedTasks.addAll(inputTasks.where((task) => task.isDone).toList());
      inputTasks.removeWhere((task) => task.isDone);
      print('\n[Log][DataControler][loadData][Ofline][Status] : Success');
    }
  }
  Future<bool> deleteTask(Task task) async {
    try {
      await _SerwWork.deleteTask(task);
      await _BDdata.deleteTask(task);

      print('\n[Log][DataControler][deleteTask][Online][Status] : Seccess');
      return true;

    } catch (e) { // Здесь указываем тип исключения
      print('\n[Log][DataControler][deleteTask][Online][Error] : $e');


      try{
        await _BDdata.deleteTask(task);
        print('\n[Log][DataControler][deleteTask][Ofline][Status] : Seccess');
        return true;

      }catch(ee){
        print('\n[Log][DataControler][deleteTask][Ofline][Error] ${ee}');
        return false;
      }



    }
  }
  Future<void> upDateTask(Task task) async{

    try {
      print('тест обновы 1 ${task.sid}');
      bool temp = await _SerwWork.updateTask(task);
      await _BDdata.updateTask(task);
      print('\n[Log][DataControler][upDateTask][Online][Status] : Seccess');

    } catch (e) {
      print('\n[Log][DataControler][upDateTask][Online][Error] ${e}');

      try{
        await _BDdata.updateTask(task);
        print('\n[Log][DataControler][upDateTask][Ofline][Status] : Seccess');
      }catch(ee){
        print('\n[Log][DataControler][upDateTask][Ofline][Error] ${ee}');
      }
    }
  }


  Future<void> creatTask(Task task) async{
    try{
      String sid = await _SerwWork.createTask(task);
      Task temp = task.copyWith(sid: sid);
      await _BDdata.insertTask(temp);
      print('\n[Log][DataControler][creatTask][DB][Online][Status] : Success');
    }catch(e){
      print('\n[Log][DataControler][creatTask][DB][Online][Error] : ${e}');
      try{
        await _BDdata.insertTask(task);
        print("\n[Log][DataControler][creatTask][Ofline][Status] : Success ");
      }catch(ee){
        print('\n[Log][DataControler][creatTask][Ofline][Error] ${ee}');
      }
    }
  }
}
