import 'package:fltr/pages/viewTask_page.dart';
import 'package:flutter/material.dart';
import 'package:fltr/models/task.dart';
import 'package:fltr/widget/task_container.dart';
import 'package:fltr/pages/newtask_page.dart';
import 'package:fltr/Controllers/mainControler.dart';
import 'package:fltr/pages/splash_page.dart';

class DashBoard extends StatefulWidget {
  final List<Task> tasks;
  final List<Tag> tagsList;
  final List<Task> completedTasks;
  final List<String> tagsNameList;
  final String userName;

  DashBoard({required this.tasks, required this.tagsList, required this.tagsNameList, required this.completedTasks,required this.userName});

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  late DateTime _selectedDate;
  late ScrollController _scrollController;

  bool _isLoading = false;

  late  bool _normalmode = true, _completedTasksNull = true;
  late String _userName ='';


  late String _searchText = '';
  late List<String> _selectedTags = [];
  var _controller = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }



  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _scrollController = ScrollController();
    print(widget.completedTasks);
    if(widget.completedTasks.isNotEmpty){
      setState(() {
        _completedTasksNull = false;
      });
    }
  }


  List<Widget> _getTasksForSelectedDate(List<Task> tasks) {

    if (_normalmode){
      List<Task> tasksForSelectedDate = tasks.where((task) =>
      task.created != null &&
          DateTime.parse(task.created!).year == _selectedDate.year &&
          DateTime.parse(task.created!).month == _selectedDate.month &&
          DateTime.parse(task.created!).day == _selectedDate.day).toList();
      return tasksForSelectedDate.map((task) {
        return TaskContainer(
          task: task,
          onTaskCompleted: _handleTaskCompleted,
          onEditTask: _handleEditTask,
          onDeleteTask: _handleDeleteTask,

        );
      }).toList();
    }else{
      List<Task> filteredTasks = tasks.where((task) {
        if (_selectedTags.isNotEmpty) {
          return _selectedTags.contains(task.tag.name) &&
              (task.title.toLowerCase().contains(_searchText.toLowerCase()) ||
                  task.text.toLowerCase().contains(_searchText.toLowerCase()));
        } else {
          return task.title.toLowerCase().contains(_searchText.toLowerCase()) ||
              task.text.toLowerCase().contains(_searchText.toLowerCase());
        }
      }).toList();
      return filteredTasks.map((task) {
        return TaskContainer(
          task: task,
          onTaskCompleted: _handleTaskCompleted,
          onEditTask: _handleEditTask,
          onDeleteTask: _handleDeleteTask,
        );
      }).toList();
    }
  }


  Future<void> _refreshData() async {
    //обновляем данные
    if (!_isLoading){
      setState(() {
        _isLoading = true;
      });

      DataControler _DataUp = DataControler();
      _DataUp.initialize();
      widget.completedTasks.clear();
      widget.tasks.clear();
      setState(() {
        _completedTasksNull = true;
      });

      // Загружаем данные
      await _DataUp.loadData(widget.tagsNameList, widget.tasks, widget.tagsList,widget.completedTasks);
     if(widget.completedTasks.isNotEmpty){
       setState(() {
         _completedTasksNull = false;
       });
     }
     print(' страница  ${widget.tasks} : ${widget.completedTasks}');

      setState(() {
        _isLoading = false;
      });
    }

  }


  Future<void> _handleTaskCompleted(Task task, bool isChecked) async {
    late DataControler _DataUp = DataControler();
    Task temp ;
    if (isChecked) {
      widget.tasks.remove(task);
      temp = task.copyWith(isDone: true);
      widget.completedTasks.add(task.copyWith(isDone: true));
      _completedTasksNull = widget.completedTasks.isEmpty;
    } else {
      temp = task.copyWith(isDone: false);
      widget.tasks.add(task.copyWith(isDone: false));
      widget.completedTasks.remove(task);
      _completedTasksNull = widget.completedTasks.isEmpty;
    }

    setState(() {});
    await _DataUp.initialize();
    await _DataUp.upDateTask(temp);
  }


  void _handleEditTask(Task task) {
    //При редактировании передается экземпляр задачи, текущие списки задач, список имен категорий и категории.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskView(tagsList: widget.tagsList, tagsNameList: widget.tagsNameList, Tasks: widget.tasks, task: task, completedTasks: widget.completedTasks),
      ),
    ).then((value) {
      _refreshData();
    });
  }

  void _handleDeleteTask(Task task) {
    setState(() async {
      _isLoading = true;
      if(task.isDone){
        widget.completedTasks.remove(task);
      }else{
        widget.tasks.remove(task);
      }
      late DataControler _DataDell = DataControler();
      await _DataDell.initialize();
      bool temp = await _DataDell.deleteTask(task);
      _isLoading = false;
    });

  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async => false,

      child:
      Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title:
            Column(children: [
              Row(
                children: [
                  IconButton(
                    onPressed:  _isLoading ? null : ()  {
                      //Scaffold.of(context).openDrawer();
                    },
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Мои задачи',
                    style: TextStyle(fontSize: 24),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.add_box_outlined),
                    onPressed:  _isLoading ? null : ()  {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskPage(tagsList: widget.tagsList, tagsNameList: widget.tagsNameList, Tasks: widget.tasks,completedTasks: widget.completedTasks),
                        )
                      ).then((value) {
                        _refreshData();
                      });
                    },
                    iconSize: 30,
                  ),
                ],
              ),
            ],)

        ),
        drawer: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF756EF3),
                ),
                child: Center(
                  child: Text(
                    '${widget.userName}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      title: Text('Настройки',),
                      onTap: () {
                        // Действие при нажатии на первую настройку
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text('Выход'),
                leading: Icon(Icons.exit_to_app), // Иконка выхода
                onTap: () async {
                  DataControler _DataUp = DataControler();
                  bool logout = await _DataUp.logOut();
                  if (logout){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SplashPage()),
                    );
                  }
                },
              ),
            ],
          ),
        ),


        body: RefreshIndicator(
          onRefresh:  _refreshData,
          child: _normalmode ?
          Column( // страница задач
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  height: 60,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Color(0xFF756EF3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {

                              _searchText = value;
                              if (_searchText.isNotEmpty){
                                _normalmode = false;
                              }
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Что надо сделать?',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      _formatDate(DateTime.now()),
                      style: TextStyle(fontSize: 32),
                    ),
                    Spacer(),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap:  _isLoading ? null : ()  async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            _selectedDate = selectedDate;
                          });
                          _scrollToSelectedDate(selectedDate);
                        }
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.withOpacity(0.2),
                        ),
                        child: Icon(Icons.calendar_today),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      '${_getTasksForSelectedDate(widget.tasks).length} задачи на сегодня',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    30,
                        (index) {
                      final currentDate =
                      DateTime.now().subtract(Duration(days: 2)).add(Duration(days: index));
                      return buildCalendarDay(currentDate);
                    },
                  ),
                ),
              ),
              SizedBox(height: 40),if (_isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
              Expanded(
                child: _completedTasksNull ?

                ListView(
                  children: [
                    ..._getTasksForSelectedDate(widget.tasks),
                    ..._getTasksForSelectedDate(widget.completedTasks),
                  ],
                ):
                ListView(
                  children: [
                    ..._getTasksForSelectedDate(widget.tasks),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Выполненные',
                        style: TextStyle(fontSize: 24),
                      ),
                    )
                    ,
                    ..._getTasksForSelectedDate(widget.completedTasks),
                  ],
                ) ,
              ),
            ],
          ):
          Column( //страница поиска
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  height: 60,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Color(0xFF756EF3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search),
                      SizedBox(width: 10),
                      Expanded(
                          child:
                          TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchText = value;

                              });
                            },
                            controller: _controller,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Что надо сделать?',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _controller.clear();
                                    _searchText = '';
                                    _normalmode = true;
                                  });
                                },
                                icon: Icon(Icons.clear),
                              ),
                            ),
                          )

                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.tagsNameList.map((tag) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (_selectedTags.contains(tag)) {
                                _selectedTags.remove(tag);
                              } else {
                                _selectedTags.add(tag);
                              }
                            });
                          },
                          child: Text(tag,style: TextStyle(color: _selectedTags.contains(tag) ? Colors.white : Colors.black54,)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedTags.contains(tag)
                                ? Color(0xFF756EF3)
                                : Colors.grey,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
              Expanded(
                child: _completedTasksNull ?

                ListView(
                  children: [
                    ..._getTasksForSelectedDate(widget.tasks),
                    ..._getTasksForSelectedDate(widget.completedTasks),
                  ],
                ):
                ListView(
                  children: [
                    ..._getTasksForSelectedDate(widget.tasks),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Выполненные',
                        style: TextStyle(fontSize: 24),
                      ),
                    )
                    ,
                    ..._getTasksForSelectedDate(widget.completedTasks),
                  ],
                ) ,
              ),if (_isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),

      ),


       );
  }


  String _getWeekDay(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Пн';
      case DateTime.tuesday:
        return 'Вт';
      case DateTime.wednesday:
        return 'Ср';
      case DateTime.thursday:
        return 'Чт';
      case DateTime.friday:
        return 'Пт';
      case DateTime.saturday:
        return 'Сб';
      case DateTime.sunday:
        return 'Вс';
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    final russianMonths = [
      '', 'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    final day = date.day;
    final month = russianMonths[date.month];
    return '$day $month';
  }

  void _scrollToSelectedDate(DateTime date) {
    final double itemExtent = 80;
    final int index = date.difference(DateTime.now()).inHours;
    _scrollController.animateTo(
      itemExtent * index / 25,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget buildCalendarDay(DateTime date) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: date.day == _selectedDate.day ? Color(0xFF756EF3) : null,
        ),
        width: 60,
        height: 90,
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: date.day == _selectedDate.day ? Color(0xFF756EF3) : null,
              ),
              child: Center(
                child: Text(
                  date.day.toString(),
                  style: TextStyle(
                    fontSize: 32,
                    color:
                    date.day == _selectedDate.day ? Colors.white : null,
                  ),
                ),
              ),
            ),
            Text(
              _getWeekDay(date),
              style: TextStyle(
                color: date.day == _selectedDate.day ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
