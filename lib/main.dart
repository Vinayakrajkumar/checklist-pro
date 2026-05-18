import 'package:flutter/material.dart';

void main() {
  runApp(const SwipeChecklistApp());
}

class SwipeChecklistApp extends StatelessWidget {
  const SwipeChecklistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Checklist Pro',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111827),
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class Task {
  String title;
  String status;

  Task({
    required this.title,
    required this.status,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [
    Task(title: 'Complete Mobile App UI', status: 'Pending'),
    Task(title: 'Finish Client Meeting', status: 'Pending'),
    Task(title: 'Update Marketing Plan', status: 'Pending'),
    Task(title: 'Prepare Presentation', status: 'Pending'),
    Task(title: 'Check Team Progress', status: 'Pending'),
  ];

  List<Task> finishedTasks = [];
  List<Task> pendingTasks = [];

  int streak = 12;

  void finishTask(Task task) {
    setState(() {
      task.status = 'Finished';
      finishedTasks.add(task);
      tasks.remove(task);
      streak++;
    });
  }

  void doLater(Task task) {
    setState(() {
      task.status = 'Pending';
      pendingTasks.add(task);
      tasks.remove(task);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: const Color(0xFF111827),
        child: Column(
          children: [
            const DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(
                      Icons.check,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Checklist Pro',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('Pending Tasks'),
              trailing: Text('${pendingTasks.length}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskScreen(
                      title: 'Pending Tasks',
                      tasks: pendingTasks,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.done_all),
              title: const Text('Finished Tasks'),
              trailing: Text('${finishedTasks.length}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskScreen(
                      title: 'Finished Tasks',
                      tasks: finishedTasks,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Checklist Pro',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // STREAK CARD
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF7C3AED),
                  Color(0xFF4F46E5),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Streak',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$streak Days 🔥',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.local_fire_department,
                  size: 60,
                  color: Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          Expanded(
            child: tasks.isEmpty
                ? const Center(
                    child: Text(
                      'All Tasks Completed',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : PageView.builder(
                    controller: PageController(
                      viewportFraction: 0.9,
                    ),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      return Dismissible(
                        key: Key(task.title),

                        // RIGHT SWIPE = FINISHED
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 30),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 55,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'FINISHED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // LEFT SWIPE = DO LATER
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 30),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.watch_later,
                                color: Colors.white,
                                size: 55,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'DO LATER',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),

                        onDismissed: (direction) {
                          if (direction ==
                              DismissDirection.startToEnd) {
                            finishTask(task);
                          } else {
                            doLater(task);
                          }
                        },

                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1E293B),
                                Color(0xFF0F172A),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 20,
                                spreadRadius: 3,
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white12,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'WORK',
                                          style: TextStyle(
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.more_vert,
                                        color: Colors.white70,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 40),

                                  const Center(
                                    child: Icon(
                                      Icons.assignment_turned_in,
                                      size: 90,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(height: 40),

                                  Text(
                                    task.title,
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  const Text(
                                    'Swipe Right → Finished',
                                    style: TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 18,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  const Text(
                                    'Swipe Left ← Do Later',
                                    style: TextStyle(
                                      color: Colors.orangeAccent,
                                      fontSize: 18,
                                    ),
                                  ),

                                  const SizedBox(height: 40),

                                  Container(
                                    width: double.infinity,
                                    padding:
                                        const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Priority : High',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        onPressed: () {
          TextEditingController controller =
              TextEditingController();

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                title: const Text('Add New Task'),
                content: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter task name',
                    hintStyle:
                        const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        setState(() {
                          tasks.add(
                            Task(
                              title: controller.text,
                              status: 'Pending',
                            ),
                          );
                        });
                      }

                      Navigator.pop(context);
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class TaskScreen extends StatelessWidget {
  final String title;
  final List<Task> tasks;

  const TaskScreen({
    super.key,
    required this.title,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: tasks.isEmpty
          ? Center(
              child: Text(
                'No $title',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            title.contains('Finished')
                                ? Colors.green
                                : Colors.orange,
                        child: Icon(
                          title.contains('Finished')
                              ? Icons.check
                              : Icons.watch_later,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              task.status,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}