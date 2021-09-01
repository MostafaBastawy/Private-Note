import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:privatenote/shared/components.dart';
import 'package:privatenote/cubit/cubit.dart';
import 'package:privatenote/cubit/states.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';

class NoteLayoutScreen extends StatefulWidget {
  @override
  _NoteLayoutScreenState createState() => _NoteLayoutScreenState();
}

class _NoteLayoutScreenState extends State<NoteLayoutScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  var formKey = GlobalKey<FormState>();

  var titleController = TextEditingController();

  var timeController = TextEditingController();

  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    NoteAppCubit cubit = NoteAppCubit.get(context);

    return BlocConsumer<NoteAppCubit, NoteAppStates>(
      listener: (BuildContext context, state) {
        if (state is NoteAppInsetToDatabaseStates) {
          Navigator.pop(context);
        }
      },
      builder: (BuildContext context, state) {
        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            title: Text(
              cubit.titles[cubit.currentIndex],
            ),
          ),
          body: ConditionalBuilder(
            condition: state is! NoteAppGetDataFromDatabaseLoadingStates,
            builder: (context) => cubit.screens[cubit.currentIndex],
            fallback: (context) => Center(
              child: CircularProgressIndicator(),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: cubit.currentIndex,
            onTap: (value) {
              cubit.changeNavBar(value);
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.menu,
                ),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.check_circle_outline,
                ),
                label: 'Done',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.archive_outlined,
                ),
                label: 'Archived',
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
              child: Icon(
                cubit.fabIcon,
              ),
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (formKey.currentState!.validate()) {
                    cubit
                        .insertToDatabase(
                      title: titleController.text,
                      date: dateController.text,
                      time: timeController.text,
                    )
                        .then((value) {
                      cubit.isBottomSheetShown = false;
                      setState(() {
                        cubit.fabIcon = Icons.edit;
                      });
                    });
                  }
                } else {
                  scaffoldKey.currentState!
                      .showBottomSheet((context) {
                        return Container(
                          padding: EdgeInsets.all(20.0),
                          width: double.infinity,
                          color: Colors.grey[100],
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultFormField(
                                  controller: titleController,
                                  labelText: 'Task Title',
                                  validate: (String value) {
                                    if (value.isEmpty) {
                                      return 'Title cant be empty';
                                    }
                                  },
                                  prefixIcon: Icons.title,
                                  onChange: (value) {},
                                  onSubmit: (value) {},
                                  onTap: () {},
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                defaultFormField(
                                  controller: dateController,
                                  labelText: 'Task Date',
                                  validate: (String value) {
                                    if (value.isEmpty) {
                                      return 'Date cant be empty';
                                    }
                                  },
                                  prefixIcon: Icons.calendar_today,
                                  onChange: (value) {},
                                  onSubmit: (value) {},
                                  onTap: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.parse('2030-21-31'),
                                    ).then((value) {
                                      dateController.text =
                                          DateFormat.yMMMd().format(value!);
                                    });
                                  },
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                                defaultFormField(
                                  controller: timeController,
                                  labelText: 'Task Time',
                                  validate: (String value) {
                                    if (value.isEmpty) {
                                      return 'Time cant be empty';
                                    }
                                  },
                                  prefixIcon: Icons.watch_later_outlined,
                                  onChange: (value) {},
                                  onSubmit: (value) {},
                                  onTap: () {
                                    showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now())
                                        .then((value) {
                                      timeController.text =
                                          value!.format(context).toString();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      })
                      .closed
                      .then((value) {
                        cubit.isBottomSheetShown = false;
                        setState(() {
                          cubit.fabIcon = Icons.edit;
                        });
                      });
                  cubit.isBottomSheetShown = true;
                  setState(() {
                    cubit.fabIcon = Icons.add;
                  });
                }
              }),
        );
      },
    );
  }
}
