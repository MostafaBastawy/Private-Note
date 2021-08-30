import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:privatenote/cubit/cubit.dart';
import 'package:privatenote/cubit/states.dart';
import 'package:privatenote/shared/components.dart';

class NewTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    NoteAppCubit cubit = NoteAppCubit.get(context);

    return BlocConsumer<NoteAppCubit, NoteAppStates>(
      listener: (BuildContext context, state) {},
      builder: (BuildContext context, Object? state) {
        return tasksBuilder(tasks: cubit.newTasks);
      },
    );
  }
}
