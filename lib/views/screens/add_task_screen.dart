import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/constants/colors.dart';
import 'package:flutter_todo_app/constants/theme.dart';
import 'package:flutter_todo_app/controllers/add_task_controller.dart';
import 'package:flutter_todo_app/controllers/theme_controller.dart';
import 'package:flutter_todo_app/models/task.dart';
import 'package:flutter_todo_app/views/widgets/button.dart';
import 'package:flutter_todo_app/views/widgets/input_field.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// The add tasks screen allows the user to create a new todo with all the input fields to do so
class AddTaskScreen extends StatelessWidget {
  AddTaskScreen({Key? key}) : super(key: key);

  final AddTaskController _addTaskController = Get.put(AddTaskController());

  final ThemeController _themeController = Get.find();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // types of repetition
  final List<String> repeatList = [
    'None',
    'Daily',
    'Weekly',
    'Monthly',
  ];

  // intervals of reminders
  final List<int> reminderList = [
    5,
    10,
    15,
    20,
  ];

  // Render the inputs
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: _appBar(),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Task Details',
                style: Themes().headingTextStyle,
              ),
              // title
              InputField(
                hint: 'Enter title here',
                title: 'Title',
                controller: _titleController,
              ),
              // note
              InputField(
                hint: 'Enter your note',
                title: 'Note',
                controller: _noteController,
              ),
              // date picker
              InputField(
                hint: DateFormat.yMd().format(_addTaskController.selectedDate),
                title: 'Date',
                widget: IconButton(
                  onPressed: () => _getDateFromUser(context),
                  icon: Icon(
                    Icons.calendar_month_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),
              // start and end times
              Row(
                children: [
                  Expanded(
                    child: InputField(
                      hint: _addTaskController.selectedStartTime,
                      title: 'Start Date',
                      widget: IconButton(
                        onPressed: () => _getTimeFromUser(context, true),
                        icon: Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Expanded(
                    child: InputField(
                      hint: _addTaskController.selectedEndTime,
                      title: 'End Date',
                      widget: IconButton(
                        onPressed: () => _getTimeFromUser(context, false),
                        icon: Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              // let the user choose how many minutes before an event to remind them with a notification
              InputField(
                hint: '${_addTaskController.selectedReminder} minutes early',
                title: 'Reminder',
                widget: SizedBox(
                  width: 50.w,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2(
                      customButton: Icon(
                        Icons.keyboard_arrow_down_sharp,
                        color: Colors.grey,
                      ),
                      customItemsIndexes: reminderList,
                      customItemsHeight: 8.h,
                      items: [
                        ...reminderList.map(
                          (item) => DropdownMenuItem<String>(
                            value: item.toString(),
                            child: Text(
                              item.toString(),
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) => _addTaskController
                          .updateSelectedReminder(int.parse(val.toString())),
                      itemHeight: 30.h,
                      dropdownPadding: EdgeInsets.all(
                        8,
                      ),
                      dropdownWidth: 80.w,
                      dropdownDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          10.r,
                        ),
                      ),
                      dropdownElevation: 1,
                    ),
                  ),
                ),
              ),
              // allow the user to select reptitiveness
              InputField(
                hint: _addTaskController.selectedRepeat,
                title: 'Repeat',
                widget: SizedBox(
                  width: 50.w,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2(
                      customButton: Icon(
                        Icons.keyboard_arrow_down_sharp,
                        color: Colors.grey,
                      ),
                      customItemsHeight: 8.h,
                      items: [
                        ...repeatList.map(
                          (item) => DropdownMenuItem<String>(
                            value: item.toString(),
                            child: Text(
                              item.toString(),
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) => _addTaskController
                          .updateSelectedRepeat(val.toString()),
                      itemHeight: 30.h,
                      dropdownPadding: EdgeInsets.all(
                        8,
                      ),
                      dropdownWidth: 110.w,
                      dropdownDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          10.r,
                        ),
                      ),
                      dropdownElevation: 1,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _colorPallete(),
                  Button(label: 'Create Task', onTap: () => _validateTask())
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Make sure that the task has all the required fields
  _validateTask() async {
    // if theres a title and a note, then create a task with the given info and add the task to the database
    if (_titleController.text.isNotEmpty || _noteController.text.isNotEmpty) {
      Task task = Task(
        note: _noteController.text,
        title: _titleController.text,
        date: DateFormat.yMd().format(
          _addTaskController.selectedDate,
        ),
        startTime: _addTaskController.selectedStartTime,
        endTime: _addTaskController.selectedEndTime,
        remind: _addTaskController.selectedReminder,
        color: _addTaskController.selectedColorIndex,
        repeat: _addTaskController.selectedRepeat,
        isCompleted: 0,
      );
      await _addTaskController.addTaskToDB(task);
      Get.back();
    } else {
      // otherwise prompt the user to add more info
      Get.snackbar(
        'Required',
        'All fields are required',
        backgroundColor:
            Get.isDarkMode ? Color(0xFF212121) : Colors.grey.shade100,
        colorText: pinkClr,
      );
    }
  }

  // Allow the user to select a color for the task
  Widget _colorPallete() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Color',
            style: Themes().titleStyle,
          ),
          SizedBox(
            height: 3.h,
          ),
          Wrap(
            children: List<Widget>.generate(
              4,
              (i) => Padding(
                padding: EdgeInsets.only(
                  right: 6,
                ),
                child: GestureDetector(
                  onTap: () => _addTaskController.updateSelectedColorIndex(i),
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                    child: CircleAvatar(
                      radius: 12.r,
                      backgroundColor: i == 0
                          ? primaryColor
                          : i == 1
                              ? pinkClr
                              : i == 2
                                  ? yellowClr
                                  : greenClr,
                      child: _addTaskController.selectedColorIndex == i
                          ? Icon(
                              Icons.done,
                              color: Colors.white,
                              size: 18.sp,
                            )
                          : Container(),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      );

  // the header bar has a back arrow along with a title for the page (Add Title)
  _appBar() {
    return AppBar(
      toolbarHeight: 60.h,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(
          Icons.arrow_back_ios,
          color: _themeController.color,
        ),
      ),
      title: Text(
        'Add Task',
        style: GoogleFonts.lato(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: _themeController.color),
      ),
    );
  }

  // When one of the date fields are tapped, this function displays a date picker to actually pick the date
  _getDateFromUser(BuildContext context) async {
    DateTime? pickerDate = await showDatePicker(
        context: context,
        firstDate: DateTime(2012),
        initialDate: DateTime.now(),
        lastDate: DateTime(2122));

    if (pickerDate != null) {
      _addTaskController.updateSelectedDate(pickerDate);
    }
  }

  // When one of the time fields are tapped, this function displays a time picker to actually pick the time
  _getTimeFromUser(BuildContext context, bool isStartTime) async {
    String? formatedTime;
    await showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: TimeOfDay(
        hour: DateTime.now().hour,
        minute: DateTime.now().minute,
      ),
    ).then((value) => formatedTime = value!.format(context));

    if (isStartTime) {
      _addTaskController.updateSelectedStartTime(formatedTime!);
    } else {
      _addTaskController.updateSelectedEndTime(formatedTime!);
    }
  }
}
