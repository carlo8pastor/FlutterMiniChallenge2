// Note: For now, Bottom Navigation Bar works on MacOS and Chrome but not iOS simulator.
//majd
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Starting the Flutter app
void main() {
  runApp(const MyApp());
}

// Defining MyApp class, responsible for the app's main structure
class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    // Creating a ChangeNotifierProvider to manage app state
    return ChangeNotifierProvider(
      create: (_) => MyAppState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.from(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
            backgroundColor: const Color(0xFFF6F6F6),
          ),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

// Defining a Task class to represent individual tasks
class Task {
  final String title;
  bool completed;
  //Majd
  Task(this.title, this.completed);
}

// Defining the app's state in MyAppState class
class MyAppState extends ChangeNotifier {
  int selectedIndex = 0;
  final List<Task> pendingTasks = [];
  final List<Task> completedTasks = [];

  // Method to select the active page
  void selectPage(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  // Method to add a new task
  //Majd
  void addTask(Task task) {
    pendingTasks.add(task);
    notifyListeners();
  }

  // Method to mark a task as completed
  void completeTask(int index) {
    completedTasks.add(pendingTasks.removeAt(index));
    notifyListeners();
  }

  // Method to mark a completed task as incomplete
  void markTaskIncomplete(int index) {
    final task = completedTasks.removeAt(index);
    task.completed = false;
    pendingTasks.add(task);
    notifyListeners();
  }
}

// Defining MyHomePage class, responsible for the main app UI
class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    // Accessing the app state using context.watch
    final appState = context.watch<MyAppState>();

    // Building the app's UI
    //Majd
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Checking screen width for responsive design
          if (constraints.maxWidth > 400) {
            // For web (large screens)
            return Row(
              children: <Widget>[
                // NavigationRail for selecting pages
                NavigationRail(
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.pending_actions),
                      label: Text('Pending Tasks'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.done),
                      label: Text('Completed'),
                    ),
                  ],
                  selectedIndex: appState.selectedIndex,
                  onDestinationSelected: appState.selectPage,
                ),
                // Expanded content for selected page
                Expanded(
                  child: CustomScrollView(
                    slivers: <Widget>[
                      // SliverAppBar with title
                      SliverAppBar(
                        expandedHeight: 80.0,
                        backgroundColor: Colors.blue,
                        floating: false,
                        pinned: true,
                        flexibleSpace: FlexibleSpaceBar(
                          title: Text(
                            appState.selectedIndex == 0 ? 'Pending Tasks' : 'Completed Tasks',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Task list based on selected page
                      SliverFillRemaining(
                        child: TaskList(isPending: appState.selectedIndex == 0),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // For mobile (small screens)
            return CustomScrollView(
              slivers: <Widget>[
                // SliverAppBar with title
                SliverAppBar(
                  expandedHeight: 80.0,
                  backgroundColor: Colors.blue,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      appState.selectedIndex == 0 ? 'Pending Tasks' : 'Completed Tasks',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Task list based on selected page
                SliverFillRemaining(
                  child: TaskList(isPending: appState.selectedIndex == 0),
                ),
              ],
            );
          }
        },
      ),
      // Floating action button for adding tasks (only on pending tasks page)
      floatingActionButton: appState.selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showAddTaskDialog(context, appState),
              child: const Icon(Icons.add),
            )
          : null,
      // Bottom navigation bar for mobile (small screens). Not working on iOS simulator, only when changing screen size for macOS or chrome.
      bottomNavigationBar: MediaQuery.of(context).size.width > 400
          ? null
          : BottomNavigationBar(
              currentIndex: appState.selectedIndex,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.pending_actions),
                  label: 'Pending Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.done),
                  label: 'Completed',
                ),
              ],
              onTap: appState.selectPage,
            ),
    );
  }

  // Method to show a dialog for adding a new task
  Future<void> _showAddTaskDialog(BuildContext context, MyAppState appState) async {
    // Controllers for input fields
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    DateTime? selectedDate;
    final TextEditingController dueDateController = TextEditingController();

    // Showing the add task dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Input field for task title
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Task Title'),
              ),
              // Input field for task description
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Task Description'),
              ),
              // Button to pick a due date
              TextButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    selectedDate = pickedDate;
                    dueDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
                  }
                },
                child: Text(selectedDate != null
                    ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                    : 'Select Due Date'),
              ),
              TextField(
                controller: dueDateController,
                enabled: false,
                decoration: const InputDecoration(labelText: 'Due Date'),
              ),
            ],
          ),
          actions: <Widget>[
            // Cancel button
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // Add button to add a new task
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                final taskTitle = titleController.text.trim();
                final taskDescription = descriptionController.text.trim();
                final taskDueDate = dueDateController.text.trim();
                //Majd
                if (taskTitle.isNotEmpty) {
                  //Majd
                  final task = Task('$taskTitle\n$taskDescription\nDue: $taskDueDate', false);
                  appState.addTask(task);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

// TaskList class, responsible for displaying the list of tasks
class TaskList extends StatelessWidget {
  const TaskList({Key? key, required this.isPending}) : super(key: key);

  final bool isPending;

  @override
  Widget build(BuildContext context) {
    // Accessing the app state using context.watch
    final appState = context.watch<MyAppState>();
    final tasks = isPending ? appState.pendingTasks : appState.completedTasks;

    // Building the task list
    //Majd
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return ListTile(
          title: Text(
            task.title.split('\n')[0],
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title.split('\n')[1],
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
              ),
              Text(
                task.title.split('\n')[2],
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          leading: isPending
              ? Checkbox(
                  value: task.completed,
                  onChanged: (value) {
                    appState.completeTask(index);
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    appState.markTaskIncomplete(index);
                  },
                ),
        );
      },
    );
  }
}
