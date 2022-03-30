import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _todoList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LISTA DE TAREFAS'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(17, 1, 7, 7),
        ),
        Row(
          children: [
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Nova tarefa",
                  labelStyle: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text("ADD"),
              style: ElevatedButton.styleFrom(primary: Colors.blueAccent),
            ),
          ],
        ),
      ]),
    );
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
