import 'package:flutter/material.dart';
import 'package:flutter_todo_app/constants/colors.dart';
import 'package:flutter_todo_app/constants/theme.dart';
import 'package:flutter_todo_app/controllers/home_controller.dart';
import 'package:flutter_todo_app/controllers/theme_controller.dart';
import 'package:flutter_todo_app/models/task.dart';
import 'package:flutter_todo_app/providers/notification_provider.dart';
import 'package:flutter_todo_app/views/screens/add_task_screen.dart';
import 'package:flutter_todo_app/views/screens/all_tasks_screen.dart';
import 'package:flutter_todo_app/views/widgets/bottom_sheet_button.dart';
import 'package:flutter_todo_app/views/widgets/button.dart';
import 'package:flutter_todo_app/views/widgets/task_tile.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';

// The home screen is the landing page for users. It extends StatefulWidget because it must have state to initialize the notifications component asynchronously.
class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  // A stateful widget must create a state
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController _homeController = Get.put(HomeController());

  final _themeController = Get.find<ThemeController>();

  late final NotificationProvider notificationProvider;

  // Create the notification component (abstracts away handling notifications for tasks)
  @override
  void initState() {
    super.initState();
    notificationProvider = NotificationProvider();
    notificationProvider.initializeNotification();
  }

  // This defines the UI
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        // the Scaffold provides the characteristic Material UI header and drawers
        return Scaffold(
          // the header
          appBar: _appBar(),
          body: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              // CSS-equivalent: align-items: start (that's the cross axis specification)
              crossAxisAlignment: CrossAxisAlignment.start,
              // what to put inside this Column
              children: [
                // the Add Task component
                _addTask(),
                SizedBox(
                  height: 12.h,
                ),
                // the Date Bar
                _addDateBar(),
                // if no tasks, then display a message saying so
                _homeController.myTasks.isEmpty
                    ? Expanded(
                      // A centered column
                        child: Center(
                          child: SizedBox(
                            child: Column(
                              // CSS-equivalent: justify-content: center
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // with an image
                                Image.asset('assets/appicon.png'),
                                // and some text
                                Text('You do not have any tasks yet!',
                                    style: GoogleFonts.lato(
                                      fontSize: 14.sp,
                                    )),
                                Text(
                                    'Add new tasks to make your day productive',
                                    style: GoogleFonts.lato(
                                      fontSize: 14.sp,
                                    ))
                              ],
                            ),
                          ),
                        ),
                      )
                    // otherwise display the tasks
                    : _showTasks(context),
                // Finally, a button to show all tasks by diverting to the all tasks screen
                Container(
                  alignment: Alignment.center,
                  child: GestureDetector(
                      onTap: () => Get.to(() => AllTasksScreen()),
                      child: Text(
                        'Show all tasks',
                        style: Themes().headingTextStyle,
                      )),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // renders the tasks
  _showTasks(BuildContext context) {
    // returns a list. Expanded tells this component to take up as much space as possible along the main axis (like CSS flex-grow)
    return Expanded(
        child: ListView.builder(
      padding: EdgeInsets.only(
        top: 10.h,
      ),
      itemCount: _homeController.myTasks.length,
      itemBuilder: (_, i) {
        final data = _homeController.myTasks[i];
        // for daily tasks, display them along with a component to open more info about that task (_showBottomSheet)
        if (data.repeat == 'Daily') {
          DateTime date = DateFormat.jm().parse(data.startTime!);
          var myTime = DateFormat("HH:mm").format(date);

          notificationProvider.scheduledNotification(
            task: data,
            hour: int.parse(myTime.toString().split(':')[0]),
            minutes: int.parse(
                  myTime.toString().split(':')[1],
                ) -
                data.remind!,
          );
          return GestureDetector(
            onTap: () {
              _showBottomSheet(context, data);
            },
            child: TaskTile(task: data),
          );
        }
        // for all other tasks, if they're for the selected date, then display them with their date and also with a component to open more info about that task (_showBottomSheet)
        if (data.date ==
            DateFormat.yMd().format(_homeController.selectedDate)) {
          return GestureDetector(
            onTap: () {
              _showBottomSheet(context, data);
            },
            child: TaskTile(task: data),
          );
        } else {
          // otherwise don't show anything for a task that isn't for the selected date
          return Container();
        }
      },
    ));
  }

  // renders the bottom sheet that contains more info about a selected task
  _showBottomSheet(BuildContext context, Task task) {
    final double height = MediaQuery.of(context).size.height;
    Get.bottomSheet(
      Container(
        color: Get.isDarkMode ? darkGreyClr : Colors.white,
        padding: EdgeInsets.only(
          top: 8,
        ),
        height: task.isCompleted == 1 ? height * .3.h : height * .4.h,
        child: Column(
          children: [
            Container(
              height: 6.h,
              width: 120.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  15.r,
                ),
                color: Get.isDarkMode ? Colors.black : Colors.grey.shade300,
              ),
            ),
            Spacer(),
            // If a task is not complete yet, show a button to mark it as complete along
            task.isCompleted == 1
                ? Container()
                : BottomSheetButton(
                    label: 'Task Complete',
                    onTap: () {
                      _homeController.upDateTask(task.id.toString());
                      _homeController.getTasks();
                      Get.back();
                      Get.snackbar(
                        'Completed!',
                        'Task "${task.title}" completed!',
                        backgroundColor: Get.isDarkMode
                            ? Color(0xFF212121)
                            : Colors.grey.shade100,
                        colorText: Get.isDarkMode ? Colors.white : Colors.black,
                      );
                    },
                    color: primaryColor,
                  ),
            // A button for deleting the task
            BottomSheetButton(
              label: 'Delete Task',
              onTap: () {
                _homeController.deleteTask(task.id.toString());
                _homeController.getTasks();
                Get.back();
                Get.snackbar(
                  'Delete success',
                  'Task "${task.title}" deleted.',
                  backgroundColor:
                      Get.isDarkMode ? Color(0xFF212121) : Colors.grey.shade100,
                  colorText: Get.isDarkMode ? Colors.white : Colors.black,
                );
              },
              color: pinkClr,
            ),
            SizedBox(
              height: 20.h,
            ),
            // Button to close the Bottom Sheet
            BottomSheetButton(
              label: 'Close',
              onTap: () {
                Get.back();
              },
              color: pinkClr,
              isClosed: true,
            ),
            SizedBox(
              height: 10.h,
            ),
          ],
        ),
      ),
    );
  }

  // Renders the header bar, called the "App Bar" in Flutter
  _appBar() {
    return AppBar(
      toolbarHeight: 60.h,
      backgroundColor: Colors.transparent,
      elevation: 0,
      // A circular icon representing the app
      leading: Row(
        children: [
          SizedBox(
            width: 12.w,
          ),
          CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage('assets/appicon.png'),
          ),
        ],
      ),
      centerTitle: true,
      // a title on the header
      title: Text(
        'My Tasks',
        style: GoogleFonts.lato(
          color: _themeController.color,
          fontWeight: FontWeight.bold,
          fontSize: 20.sp,
        ),
      ),
      actions: [
        // and a dark/light mode toggle
        IconButton(
          onPressed: () async {
            _themeController.switchTheme();
            // await notificationProvider.displayNotification(
            //   title: 'Theme Changed',
            //   body: Get.isDarkMode
            //       ? 'Activated Light Theme'
            //       : 'Activated Dark Theme',
            // );
          },
          icon:
              Icon(Get.isDarkMode ? Icons.mode_night_outlined : Icons.wb_sunny),
          color: _themeController.color,
        ),
      ],
    );
  }

  // Date picker component
  Widget _addDateBar() => SizedBox(
        child: DatePicker(
          DateTime.now(),
          height: 84.h,
          width: 64.w,
          initialSelectedDate: DateTime.now(),
          selectionColor: primaryColor,
          selectedTextColor: Colors.white,
          dateTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          dayTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          monthTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          onDateChange: _homeController.updateSelectedDate,
        ),
      );

  // Button to add a task
  Widget _addTask() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMd().format(
                  DateTime.now(),
                ),
                style: Themes().subHeadingTextStyle,
              ),
              Text(
                'Today',
                style: Themes().headingTextStyle,
              ),
            ],
          ),
          // when the add task button is hit, it transitions the app to the Add Tasks screen
          Button(
            label: '+ Add Task',
            onTap: () async {
              await Get.to(
                () => AddTaskScreen(),
                transition: Transition.rightToLeft,
              );
              _homeController.getTasks();
            },
          ),
        ],
      );
}
