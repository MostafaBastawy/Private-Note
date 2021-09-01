import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:privatenote/screens/archived_tasks_screen.dart';
import 'package:privatenote/cubit/states.dart';
import 'package:privatenote/screens/done_tasks_screen.dart';
import 'package:privatenote/screens/new_tasks_screen.dart';
import 'package:sqflite/sqflite.dart';

class NoteAppCubit extends Cubit<NoteAppStates> {
  NoteAppCubit() : super(NoteAppInitialStates());

  static NoteAppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;

  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];

  void changeNavBar(int index) {
    currentIndex = index;
    emit(NoteAppChangeNavBarIconStates());
  }

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetState({
    required bool isShow,
    required IconData icon,
  }) {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    emit(NoteAppChangeBottomSheetStates());
  }

  Database? database;

  void creatDatabase() {
    openDatabase(
      'privatenote.db',
      version: 1,
      onCreate: (Database database, int version) async {
        print('database created');
        await database
            .execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('Error when creating table ${error.toString()}');
        });
      },
      onOpen: (database) {
        getDataFromDatabase(database);
        print('database opened');
      },
    ).then((value) {
      database = value;
      emit(NoteAppCreatDatabaseStates());
    });
  }

  int? id;
  insertToDatabase({
    required String title,
    required String date,
    required String time,
  }) async {
    await database!.transaction((txn) async {
      id = await txn
          .rawInsert(
              'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")')
          .then((value) {
        print('$value inserted successfully');
        emit(NoteAppInsetToDatabaseStates());
        getDataFromDatabase(database);
      }).catchError((error) {
        print('Error when inserting to table $id .. ${error.toString()}');
      });
    });
  }

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  void getDataFromDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(NoteAppGetDataFromDatabaseLoadingStates());
    database!.rawQuery('SELECT * FROM tasks').then((value) {
      emit(NoteAppGetDataFromDatabaseStates());
      print(value);
      value.forEach((element) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else if (element['status'] == 'archived') {
          archivedTasks.add(element);
        }
      });
    });
  }

  void updateDatabase({
    required String status,
    required int id,
  }) {
    database!.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      ['$status', id],
    ).then((value) {
      getDataFromDatabase(database);

      emit(NoteAppUpdateDataFromDatabaseStates());
    });
  }

  void deleteData({required String id}) async {
    database!.rawDelete('DELETE FROM tasks WHERE id = ? ', [id]).then((value) {
      getDataFromDatabase(database);
      emit(NoteAppDeleteDataFromDatabaseStates());
    });
  }
}
