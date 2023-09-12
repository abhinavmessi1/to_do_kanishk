import 'package:flutter/material.dart';
import '../helper/database_helper.dart';
import 'package:intl/intl.dart';
import '../Note.dart';

class NoteDetail extends StatefulWidget {
  final String appbarTitle;
  final Note note;
  const NoteDetail(this.note, this.appbarTitle, {super.key});

  @override
  State<NoteDetail> createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  static var _priorities = ["High", "Low"];
  DatabaseHelper helper = DatabaseHelper();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = Theme.of(context).textTheme.titleMedium;
    titleController.text = widget.note.title ?? "";
    descriptionController.text = widget.note.description ?? "";
    return WillPopScope(
        child: Scaffold(
          backgroundColor: Colors.cyanAccent,
          appBar: AppBar(
            title: Text("TODO"),
            backgroundColor: Colors.pink,
            leading: IconButton(
                onPressed: () {
                  movetoLastScreen();
                },
                icon: const Icon(Icons.arrow_back)),
          ),
          body: Padding(
            padding: EdgeInsets.all(10.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 5.0),
                    //dropdown menu
                    child: ListTile(
                      leading: const Icon(Icons.low_priority),
                      title: DropdownButton(
                          items: _priorities.map((String dropDownStringItem) {
                            return DropdownMenuItem<String>(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem,
                                  style: const TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red)),
                            );
                          }).toList(),
                          value: getPriorityAsString(widget.note.priority!),
                          onChanged: (valueSelectedByUser) {
                            setState(() {
                              updatepriorityAsInt(valueSelectedByUser!);
                            });
                          }),
                    ),
                  ),
                  // Second Element
                  Padding(
                    padding:
                        EdgeInsets.only(top: 15.0, bottom: 15.0, left: 15.0),
                    child: TextField(
                      controller: titleController,
                      style: textStyle,
                      onChanged: (value) {
                        updateTitle();
                      },
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: textStyle,
                        icon: Icon(Icons.title),
                      ),
                    ),
                  ),

                  // Third Element
                  Padding(
                    padding:
                        EdgeInsets.only(top: 15.0, bottom: 15.0, left: 15.0),
                    child: TextField(
                      controller: descriptionController,
                      style: textStyle,
                      onChanged: (value) {
                        updateDescription();
                      },
                      decoration: InputDecoration(
                        labelText: 'Details',
                        icon: Icon(Icons.details),
                      ),
                    ),
                  ),

                  // Fourth Element
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: ElevatedButton(
                            // textColor: Colors.white,
                            // color: Colors.green,
                            // padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Save',
                              textScaleFactor: 1.5,
                            ),
                            onPressed: () {
                              setState(() {
                                debugPrint("Save button clicked");
                                _save();
                              });
                            },
                          ),
                        ),
                        Container(
                          width: 5.0,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ButtonStyle(),
                            child: Text(
                              'Delete',
                              textScaleFactor: 1.5,
                            ),
                            onPressed: () {
                              setState(() {
                                _delete();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        onWillPop: () async {
          movetoLastScreen();
          return true;
        });
  }

  void updateTitle() {
    widget.note.title = titleController.text;
  }

  void updateDescription() {
    widget.note.description = descriptionController.text;
  }

  void _save() async {
    movetoLastScreen();
    widget.note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (widget.note.id != null) {
      result = await helper.updateNote(widget.note);
    } else {
      result = await helper.insertNote(widget.note);
    }

    if (result != 0) {
      _showAlertDialogue("Status", "Note Saved Successfully");
      return;
    } else {
      _showAlertDialogue("status", "Problem saving Note");
      return;
    }
  }

  void _delete() async {
    movetoLastScreen();

    if (widget.note.id == null) {
      _showAlertDialogue("Status", "First add a note");
      return;
    }
    int result = await helper.deleteNote(widget.note.id!);
    if (result != 0) {
      _showAlertDialogue("Status", "Note deleted Successfully");
      return;
    } else {
      _showAlertDialogue("status", "Error");
      return;
    }
  }

  //convert to int to save into database
  void updatepriorityAsInt(String value) {
    switch (value) {
      case "High":
        widget.note.priority = 1;
        break;
      case "Low":
        widget.note.priority = 2;
        break;
      default:
    }
  }

  //convert int to String to show user
  String getPriorityAsString(int value) {
    String? priority;
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
      default:
    }
    return priority!;
  }

  void movetoLastScreen() {
    Navigator.pop(context, true);
  }

  void _showAlertDialogue(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
