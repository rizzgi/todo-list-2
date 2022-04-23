import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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
        title: const Text('AFAZERES RÁPIDOS'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: openModal,
            ),
          )
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _todoController,
                      decoration: const InputDecoration(
                        labelText: "Nova tarefa",
                        labelStyle: TextStyle(color: Colors.black38),
                      ),
                    ),
                  ),

                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _todoController,
                    builder: (context, value, child) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.blue),
                        onPressed: value.text.isNotEmpty
                            ? () {
                                _addTodo();
                              }
                            : null,
                        child: Text('Adicionar'),
                      );
                    },
                  ),

                  // ElevatedButton(
                  //   onPressed: _addTodo,
                  //   child: const Text("+"),
                  //   style: ElevatedButton.styleFrom(primary: Colors.green),
                  // ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                reverse: true,
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
            backgroundColor: Colors.black38,
            foregroundColor: Colors.white,
            child: Icon(
              _todoList[index]["ok"] ? Icons.check : Icons.error,
              color: _todoList[index]["ok"] ? Colors.white : Colors.red,
            ),
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
            if (_todoController.text != null) {}
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

  openModal() {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
          controller: ModalScrollController.of(context),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircleAvatar(
                    maxRadius: 20,
                    backgroundColor: Colors.black38,
                    foregroundColor: Colors.white,
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      "Tarefas concluídas",
                      style: TextStyle(color: Colors.black38),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircleAvatar(
                    maxRadius: 20,
                    backgroundColor: Colors.black38,
                    foregroundColor: Colors.white,
                    child: Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text(
                      "Tarefas para fazer",
                      style: TextStyle(color: Colors.black38),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                   Icon(Icons.arrow_forward),
                  Text("ARRASTE PARA DIREITA PARA DELETAR A TAREFA", style: TextStyle(fontSize: 12),)
                ],
              ),
            )
          ])),
    );
  }
}
