import 'package:flutter/material.dart';
import 'package:notes_app/Utils/database_helper.dart';
import 'package:notes_app/models/note.dart';
import 'package:sqflite/sqflite.dart';

import 'note_details.dart';

class NotesList extends StatefulWidget {
  @override
  _NotesListState createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;
  Note lastDeleted;
  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Theme.of(context).accentColor,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'Add note',
        onPressed: () {
          print('FAB clciked');
          navigateToDetails(Note('', '', 2), 'Add note');
        },
      ),
    );
  }

  ListView getNoteListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).accentColor,
              child: getPriorityIcon(this.noteList[index].priority),
            ),
            title: Text(
              this.noteList[index].title,
              style: titleStyle,
            ),
            subtitle: Text(this.noteList[index].date),
            trailing: IconButton(
              icon: Icon(
                Icons.delete,
              ),
              onPressed: () {
                _delete(context, this.noteList[index]);
              },
            ),
            onTap: () {
              print('The tile has been pressed!');
              navigateToDetails(this.noteList[index], 'Edit Note');
            },
          ),
        );
      },
    );
  }

  Icon getPriorityIcon(int priority) {
    if (priority == 1) {
      return Icon(Icons.label_important);
    } else {
      return null;
    }
  }

  void _undo(BuildContext context) async {
    await databaseHelper.insertNote(lastDeleted);
    updateListView();
  }

  void _delete(BuildContext context, Note note) async {
    lastDeleted = note;
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: () {
          _undo(context);
        },
      ),
      content: Text(message),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetails(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetails(note, title);
    }));
    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
