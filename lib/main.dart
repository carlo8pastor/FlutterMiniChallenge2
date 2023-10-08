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

class MyAppState extends ChangeNotifier {
  int selectedIndex = 0;

  void selectPage(int index) {
    selectedIndex = index;
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
          // TODO: loggic for adding new task
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PendingTasks extends StatelessWidget {
  const PendingTasks({Key? key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement pending tasks
    return const Center(
      child: Text('Pending Tasks Page'),
    );
  }
}

class CompletedPage extends StatelessWidget {
  const CompletedPage({Key? key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement completed tasks
    return const Center(
      child: Text('Completed Tasks Page'),
    );
  }
}
