import 'package:flutter/material.dart';
import 'package:mydb_todo/constants/image_constant.dart';
import 'dart:async';
import '../helper/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../Note.dart';

import 'note_details.dart';

class NoteList extends StatefulWidget {
  const NoteList({super.key});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note>? noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("LCO Todo"),
        backgroundColor: Colors.purple,
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateTodetails(Note('first', 'first', 2), "add note");
        },
        backgroundColor: Colors.purple,
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    return ListView.builder(
      itemBuilder: (context, position) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Colors.deepOrange,
          elevation: 4,
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(ImageUrls.imageUrls[0]),
            ),
            title: Text(
              noteList![position].title!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25.0,
              ),
            ),
            subtitle: Text(
              noteList![position].date!,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: GestureDetector(
              onTap: () {
                navigateTodetails(noteList![position], "Edit Todo");
              },
              child: const Icon(
                Icons.open_in_new,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
      itemCount: count,
    );
  }

  void navigateTodetails(Note note, String title) async {
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return NoteDetail(note, title);
      }),
    );
    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initalizeDatabase();
    dbFuture.then((databse) {
      Future<List<Note>> noteListFutre = databaseHelper.getNoteList();
      noteListFutre.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
