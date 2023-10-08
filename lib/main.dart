import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
            backgroundColor: Colors.white,
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
  List<Task> pendingTasks = [];
  List<Task> completedTasks = [];

  void selectPage(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void addTask(String title) {
    pendingTasks.add(Task(title, false));
    notifyListeners();
  }

  void completeTask(int index) {
    completedTasks.add(pendingTasks[index]);
    pendingTasks.removeAt(index);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    Widget page;
    String appBarText;

    switch (appState.selectedIndex) {
      case 0:
        page = const PendingTasks();
        appBarText = 'Pending Tasks';
        break;
      case 1:
        page = const CompletedPage();
        appBarText = 'Completed Tasks';
        break;
      default:
        throw UnimplementedError("No page for index ${appState.selectedIndex}");
    }

    return Scaffold(
      body: Row(
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
            onDestinationSelected: (value) {
              appState.selectPage(value);
            },
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
                      appBarText,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SliverFillRemaining(
                  child: page,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context, appState);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddTaskDialog(BuildContext context, MyAppState appState) async {
    final TextEditingController taskController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: TextField(
            controller: taskController,
            decoration: InputDecoration(hintText: 'Enter task'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                String taskTitle = taskController.text.trim();
                if (taskTitle.isNotEmpty) {
                  appState.addTask(taskTitle);
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

class PendingTasks extends StatelessWidget {
  const PendingTasks({Key? key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    return ListView.builder(
      itemCount: appState.pendingTasks.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(appState.pendingTasks[index].title),
          leading: Checkbox(
            value: appState.pendingTasks[index].completed,
            onChanged: (value) {
              appState.completeTask(index);
            },
          ),
        );
      },
    );
  }
}

class CompletedPage extends StatelessWidget {
  const CompletedPage({Key? key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    return ListView.builder(
      itemCount: appState.completedTasks.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(appState.completedTasks[index].title),
          leading: Icon(Icons.check),
        );
      },
    );
  }
}
