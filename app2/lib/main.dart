import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _todoController = TextEditingController();

  late List _todoList = [];

  late Map<String, dynamic> _lastRemoved;
  late int _lastRemovedPos;

  @override
  void initState() {
    super.initState();

    _readData().then((value) {
      setState(() {
        _todoList = json.decode(value);
      });
    });
  }

  void _addTodo() {
    setState(() {
      Map<String, dynamic> newTodo = {};
      newTodo["title"] = _todoController.text;
      _todoController.text = "";
      newTodo["ok"] = false;
      _todoList.add(newTodo);
      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LISTA DE TAREFAS'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(children: [
        Container(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _todoController,
                  decoration: const InputDecoration(
                    labelText: "Nova tarefa",
                    labelStyle: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _addTodo,
                child: const Text("+"),
                style: ElevatedButton.styleFrom(primary: Colors.blueAccent),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 10),
                itemCount: _todoList.length,
                itemBuilder: buildItem),
            onRefresh: _refresh,
          ),
        ),
      ]),
    );
  }

  Future<Null> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _todoList.sort((a, b) {
        if (a["ok"])
          return 1;
        else if (!a["ok"] && b["ok"])
          return -1;
        else
          return 0;
      });

      _saveData();
    });

    return null;
  }

  Widget buildItem(context, index) {
    return Dismissible(
        key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
        child: CheckboxListTile(
          title: Text(_todoList[index]["title"]),
          value: _todoList[index]["ok"],
          secondary: CircleAvatar(
            child: Icon(_todoList[index]["ok"] ? Icons.check : Icons.error),
          ),
          onChanged: (bool? value) {
            setState(() {
              _todoList[index]["ok"] = value;
              _saveData();
            });
          },
        ),
        onDismissed: (direction) {
          setState(() {
            _lastRemoved = Map.from(_todoList[index]);
            _lastRemovedPos = index;
            _todoList.removeAt(index);

            _saveData();

            final snack = SnackBar(
              content: Text("Tarefa \"${_lastRemoved["title"]}\" removida"),
              action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _todoList.insert(_lastRemovedPos, _lastRemoved);
                    _saveData();
                  });
                },
              ),
              duration: const Duration(seconds: 2),
            );
            Scaffold.of(context).removeCurrentSnackBar();
            Scaffold.of(context).showSnackBar(snack);
          });
        },
        direction: DismissDirection.startToEnd,
        background: Container(
            color: Colors.red,
            child: const Align(
                alignment: Alignment(-0.9, 0.0),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ))));
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_todoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return e.toString();
    }
  }
}
