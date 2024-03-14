import 'package:flutter/material.dart';
import 'package:fltr/pages/aut_or_reg_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fltr/pages/dashboard_page.dart';
import 'package:fltr/models/task.dart';
import 'package:fltr/Controllers/mainControler.dart';


class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  bool _isLoading = false;

  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _animation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadingin() async {
    ///*
    /// происходит проверка через сервер на авторизацию, если авторизован переход к странице с задачами
    /// если коды не подходят они удаляются и требуется произвести вход
    /// если нет подключения к интернету, проверяется наличие токена как такового
    ///
    List<String> tagNames = [];
    List<Task> Tasks = [];
    List<Task> completedTasks = [];
    List<Tag> inputTags = [];
    DataControler Datal = DataControler();

    setState(() {
      _isLoading = true;
    });

    bool islogin = false;
    islogin = await Datal.loginToken();
    print(islogin);

    if (islogin){

      await Datal.initialize();
        await Datal.loadData(tagNames, Tasks, inputTags,completedTasks);
        String userName = await Datal.getUserName();
      setState(() {
        _isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DashBoard(tasks: Tasks, tagsList: inputTags, tagsNameList: tagNames,completedTasks:completedTasks,userName: userName,),
        ),
      );
    }else{
      setState(() {
        _isLoading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AutOrReg()),
      );
    }

  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async => false,

        child:
      Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Фоновое изображение
          Positioned(
            top: MediaQuery.of(context).size.height / 10000,
            left: 0,
            right: 0,
            child: FractionallySizedBox( // Пропорциональное изменение размеров изображения
              widthFactor: 1,
              child: Image.asset(
                'assets/images/test.jpeg',
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          // Контейнер на переднем плане
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return SlideTransition(
                position: _animation,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Task",
                            style: TextStyle(
                              fontSize: 46,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "Персональный \n таск-трекер",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Порядок продолж - порядок в уме",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black26,
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed:  _isLoading ? null : () async {
                              setState(() {
                                _isLoading = true;
                              });

                              await _loadingin();

                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF756EF3)),
                            ),
                            child: Text("Продолжить",style: TextStyle(fontSize: 20,color: Colors.white,),),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    ));
  }
}
