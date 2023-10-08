import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
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

class Task {
  final String title;
  bool completed;

  Task(this.title, this.completed);
}

class MyAppState extends ChangeNotifier {
  int selectedIndex = 0;
  final List<Task> pendingTasks = [];
  final List<Task> completedTasks = [];

  void selectPage(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void addTask(Task task) {
    pendingTasks.add(task);
    notifyListeners();
  }

  void completeTask(int index) {
    completedTasks.add(pendingTasks.removeAt(index));
    notifyListeners();
  }

  void markTaskIncomplete(int index) {
    final task = completedTasks.removeAt(index);
    task.completed = false;
    pendingTasks.add(task);
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > 400) {
            // For web (large screens)
            return Row(
              children: <Widget>[
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
                Expanded(
                  child: CustomScrollView(
                    slivers: <Widget>[
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
                SliverFillRemaining(
                  child: TaskList(isPending: appState.selectedIndex == 0),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: appState.selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showAddTaskDialog(context, appState),
              child: const Icon(Icons.add),
            )
          : null,
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

  Future<void> _showAddTaskDialog(BuildContext context, MyAppState appState) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    DateTime? selectedDate;
    final TextEditingController dueDateController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Task Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Task Description'),
              ),
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
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                final taskTitle = titleController.text.trim();
                final taskDescription = descriptionController.text.trim();
                final taskDueDate = dueDateController.text.trim();

                if (taskTitle.isNotEmpty) {
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

class TaskList extends StatelessWidget {
  const TaskList({Key? key, required this.isPending}) : super(key: key);

  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final tasks = isPending ? appState.pendingTasks : appState.completedTasks;

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