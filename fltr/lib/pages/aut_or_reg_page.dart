import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'package:fltr/Controllers/serverWorker.dart';
import 'package:fltr/models/task.dart';
import 'package:fltr/Controllers/mainControler.dart';

class AutOrReg extends StatefulWidget {
  @override
  _AutOrRegState createState() => _AutOrRegState();
}

class _AutOrRegState extends State<AutOrReg> {
  bool isLoginMode = true;
  String UserName = '', Email = '', password = '';
  bool _isLoading = false;
  late ServerWorker sr = ServerWorker();
  final _scrollController = ScrollController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _scrollController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_scrollToTop);
    _passwordFocusNode.addListener(_scrollToTop);
  }

  void _scrollToTop() {
    if (_emailFocusNode.hasFocus || _passwordFocusNode.hasFocus) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> AutOrRegFunction () async{
    setState(() {
      _isLoading = true;
    });
    List<String> tagNames = [];
    List<Task> Tasks = [];
    List<Task> completedTasks = [];
    List<Tag> inputTags = [];
    DataControler Datal = DataControler();


    try {
      // Проверяем, если мы в режиме входа (логина)
      if (isLoginMode) {
        bool loginSuccessful = await sr.userVerification(Email, password);
        if(loginSuccessful){
          await Datal.initialize();
          await Datal.loadData(tagNames, Tasks, inputTags, completedTasks);
          String userName = await Datal.getUserName();
          setState(() {
            _isLoading = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DashBoard(tasks: Tasks, tagsList: inputTags, tagsNameList: tagNames,completedTasks: completedTasks,userName: userName,),
            ),
          );
        }else{
          setState(() {
            _isLoading = false;
          });
          _showSnackbar(context, 'Неправильный email или пароль');
        }
      } else {
        // Регистрируем нового пользователя
        bool registrationSuccessful = await sr.UserRegister(UserName, Email, password);
        if (registrationSuccessful) {
          await Datal.initialize();
          await Datal.loadData(tagNames, Tasks, inputTags, completedTasks);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DashBoard(tasks: Tasks, tagsList: inputTags, tagsNameList: tagNames,completedTasks: completedTasks,userName: UserName,),
            ),
          );
        } else {
          // Если регистрация неуспешна, выводим сообщение об ошибке
          _showSnackbar(context, 'Пользователь с данным email уже существует');
        }
      }
    } catch (e) {
      _showSnackbar(context, 'Нет доступа к интернету или сервер не отвечает');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: isLoginMode ? Text('Вход') : Text('Регистрация'),
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 24, color: Colors.black),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
              isLoginMode
                  ?
              Column(children: [
                SizedBox(height: 140,),
                Text(
                    "Добро пожаловать",
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.black,
                    )),
                SizedBox(height: 16,),
                Text(
                    "Введите E-mail и пароль для входа",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black26,
                    ))
              ],):Column(children: [
                SizedBox(height: 140,),
                Text(
                    "Создание аккаунта ",
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.black,
                    )),
                SizedBox(height: 16,),
                Text(
                  "Заполните поля для регистрации",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black26,
                  ),

                ),
              ],),

              SizedBox(height: 40),
              Container(
                  padding: EdgeInsets.all(20),
                  child: Column(children: [
                    if (isLoginMode) // смена содержимого в зависимости от состояния
                      Column(
                        children: [
                          TextFormField(
                            focusNode: _emailFocusNode,
                            enabled: !_isLoading,
                            onTap: () {
                              _scrollToTextField(_emailFocusNode);
                            },
                            onChanged: (value) {
                              setState(() {
                                Email = value;
                                Email = Email.replaceAll( ' ', '');

                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Введите E-mail',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            focusNode: _passwordFocusNode,
                            enabled: !_isLoading,
                            onTap: () {
                              _scrollToTextField(_passwordFocusNode);
                            },
                            onChanged: (value) {
                              setState(() {
                                password = value;
                                password = password.replaceAll(' ', '');
                              });
                            },
                            obscureText: true, // Скрыть вводимые символы
                            decoration: InputDecoration(
                              labelText: 'Введите пароль',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (!isLoginMode)
                      Column(
                        children: [
                          TextFormField(
                            focusNode: _emailFocusNode,
                            enabled: !_isLoading,
                            onTap: () {
                              _scrollToTextField(_emailFocusNode);
                            },
                            onChanged: (value) {
                              setState(() {
                                UserName = value;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Введите Имя',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            enabled: !_isLoading,
                            onTap: () {
                              _scrollToTextField(_passwordFocusNode);
                            },
                            onChanged: (value) {
                              setState(() {
                                Email = value;
                                Email = Email.replaceAll( ' ', '');
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Введите E-mail',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),SizedBox(height: 10),
                          TextFormField(
                            focusNode: _passwordFocusNode,
                            enabled: !_isLoading,
                            onTap: () {
                              _scrollToTextField(_passwordFocusNode);
                            },
                            onChanged: (value) {
                              setState(() {
                                password = value;
                                password = password.replaceAll( ' ', '');
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Введите пароль',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],)
              ),

              SizedBox(height: 20),
              ElevatedButton(

                onPressed: _isLoading ? null : () async {
                  AutOrRegFunction();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF756EF3)),
                ),


                child:  isLoginMode ? Text('Войти',style: TextStyle(fontSize: 20,color: Colors.white,),) : Text('Зарегистрироваться',style: TextStyle(fontSize: 20,color: Colors.white,),),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isLoginMode ? Text('Еще нет аккаунта? ',style: TextStyle(color : Colors.black, fontSize: 14)) : Text('Уже есть аккаунт? ',style: TextStyle(color : Colors.black, fontSize: 14)),
                  GestureDetector(

                    onTap: _isLoading ? null : () {
                      setState(() {
                        isLoginMode = !isLoginMode;
                        Email = ''; // Обнуляем значение Email при смене режима
                        password = ''; // Обнуляем значение пароля при смене режима
                      });
                    },

                    child: Text(
                      isLoginMode ? 'Зарегистрироваться' : 'Войти',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,


                      ),
                    ),
                  ),


                ],),

            ],
          ),
        ),
      ),
    );
  }

  void _scrollToTextField(FocusNode focusNode) {
    final context = focusNode.context;
    if (context != null) {
      final renderObject = context.findRenderObject();
      if (renderObject != null && renderObject is RenderBox) {
        final offset = renderObject.localToGlobal(Offset.zero);
        _scrollController.animateTo(
          offset.dy,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }
}