import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fltr/models/task.dart';
import 'package:fltr/Controllers/mainControler.dart';

class TaskPage extends StatefulWidget {
  final List<Tag> tagsList;
  final List<String> tagsNameList;
  final List<Task> Tasks;
  final List<Task> completedTasks;

  TaskPage({required this.tagsList, required this.tagsNameList, required this.Tasks, required this.completedTasks});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  String _taskName = '';
  String _taskNote = '';
  String _taskCategory = '';
  DateTime _taskDate = DateTime.now();
  TimeOfDay _taskTime = TimeOfDay.now();
  bool _hasDeadline = false;
  DateTime _deadlineDate = DateTime.now();
  TimeOfDay _deadlineTime = TimeOfDay.now();
  int _priority = 1;

  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late DataControler _DataUpl = DataControler();

  List<String> _priorityNames = ['Высокий', 'Средний', 'Низкий'];

  String _returnTagSid(String name) {
    for (Tag tag in widget.tagsList) {
      if (tag.name == name) {
        return tag.sid;
      }
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _taskCategory = widget.tagsNameList[0];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dateController = TextEditingController(
        text: DateFormat('dd.MM.yyyy').format(_taskDate));
    _timeController = TextEditingController(text: _taskTime.format(context));
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }


  Widget _buildPriorityContainer(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _priority = index;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width/3.5,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xFF756EF3),
            width: _priority == index ? 2 : 0,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            _priorityNames[index],
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _taskDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _taskDate) {
      setState(() {
        _taskDate = picked;
        _dateController.text = DateFormat('dd.MM.yyyy').format(_taskDate);
      });
    }
  }

  Future<void> _showTimePicker() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _taskTime,
    );
    if (picked != null && picked != _taskTime) {
      setState(() {
        _taskTime = picked;
        _timeController.text = _taskTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      WillPopScope(
        // Устанавливает обработчик onWillPop
        onWillPop: () async {
      // Если во время загрузки, предотвращаем навигацию назад
      if (_isLoading) {
        return false;
      } else {
        // Возвращаем true, чтобы разрешить навигацию назад
        return true;
      }
    },
    child:
    Scaffold(
      appBar: AppBar(
        title: Text('Создание задачи'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Наименование задачи',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),

                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите название задачи';
                  }
                  return null;
                },
                onSaved: (value) {
                  _taskName = value!;
                },
              ),
              SizedBox(height: 32),
              TextFormField(
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Примечание',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                maxLines: null,
                onSaved: (value) {
                  _taskNote = value!;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _taskCategory,
                items: widget.tagsNameList
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: _isLoading ? null : (String? newValue) {
                  setState(() {
                    _taskCategory = newValue!;
                  });
                },
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      enabled: !_isLoading,
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Дата',
                        hintText: 'дд.мм.гггг',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      readOnly: true,
                      onTap: _showDatePicker,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      enabled: !_isLoading,
                      controller: _timeController,
                      decoration: InputDecoration(
                        labelText: 'Время',
                        hintText: 'чч:мм',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      readOnly: true,
                      onTap: _showTimePicker,
                    ),
                  ),
                ],
              ),
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
              SizedBox(width: 16),
              CheckboxListTile(

                enabled: !_isLoading,
                value: _hasDeadline,
                title: Text('Есть срок?'),
                onChanged: (bool? value) {
                  setState(() {
                    _hasDeadline = value!;
                  });
                },
              ),
              if (_hasDeadline)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Выполнить до:'),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            enabled: !_isLoading,
                            controller: TextEditingController(
                                text: DateFormat('dd.MM.yyyy')
                                    .format(_deadlineDate)),
                            decoration: InputDecoration(
                              labelText: 'Дата',
                              hintText: 'дд.мм.гггг',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            readOnly: true,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _deadlineDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null && picked != _deadlineDate) {
                                setState(() {
                                  _deadlineDate = picked;
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            enabled: !_isLoading,
                            controller: TextEditingController(
                                text: _deadlineTime.format(context)),
                            decoration: InputDecoration(
                              labelText: 'Время',
                              hintText: 'чч:мм',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            readOnly: true,
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: _deadlineTime,
                              );
                              if (picked != null && picked != _deadlineTime) {
                                setState(() {
                                  _deadlineTime = picked;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List<Widget>.generate(3, (index) {
                  return _buildPriorityContainer(index);
                }),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Создаем новый таск на основе введенных данных
                    Task newTask = Task(
                      id: '',
                      sid: '',
                      title: _taskName,
                      text: _taskNote,
                      isDone: false, // По умолчанию новый таск не выполнен
                      priority: _priority,
                      tag: Tag(
                          name: _taskCategory,
                          sid: _returnTagSid(_taskCategory)),
                      created: DateFormat('yyyy-MM-ddTHH:mm:ss').format(_taskDate),
                    );
                    if (_hasDeadline) {
                      newTask.finish = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime(
                        _deadlineDate.year,
                        _deadlineDate.month,
                        _deadlineDate.day,
                        _deadlineTime.hour,
                        _deadlineTime.minute,
                      ));
                    } else {
                      newTask.finish = null;
                    }

                    setState(() {
                      _isLoading = true;
                    });
                    try{
                      await _DataUpl.initialize();
                      //widget.Tasks.add(newTask);
                      await _DataUpl.creatTask(newTask);
                      //await _DataUpl.loadData(widget.tagsNameList, widget.Tasks, widget.tagsList, widget.completedTasks);
                    }catch(e){}

                    setState(() {
                      _isLoading = false;
                    });



                    // Очищаем поля формы после добавления задачи
                    setState(() {
                      _formKey.currentState!.reset();
                      _hasDeadline = false;
                      _priority = 1;
                      _dateController.text =
                          DateFormat('dd.MM.yyyy').format(DateTime.now());
                      _timeController.text =
                          TimeOfDay.now().format(context);
                      _deadlineDate = DateTime.now();
                      _deadlineTime = TimeOfDay.now();
                    });

                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF756EF3)),
                ),
                child: Text('Добавить', style: TextStyle(fontSize: 16,color: Colors.white,),),

              ),

            ],
          ),
        ),
      ),
    ),
      );
  }
}
