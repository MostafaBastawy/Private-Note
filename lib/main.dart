import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:privatenote/cubit/bloc_observing.dart';
import 'package:privatenote/cubit/cubit.dart';
import 'package:privatenote/cubit/states.dart';
import 'package:privatenote/screens/note_layout_screen.dart';

void main() {
  Bloc.observer = MyBlocObserver();
  runApp(NoteApp());
}

class NoteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => NoteAppCubit()..creatDatabase(),
      child: BlocConsumer<NoteAppCubit, NoteAppStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return MaterialApp(
            themeMode: ThemeMode.light,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                backgroundColor: Colors.blue[700],
                selectedItemColor: Colors.white,
              ),
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.blue[700],
              ),
            ),
            home: NoteLayoutScreen(),
          );
        },
      ),
    );
  }
}
