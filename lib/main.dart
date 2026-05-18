import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.deleteBoxFromDisk('tasks');

  runApp(const SwipeChecklistApp());
}

class SwipeChecklistApp extends StatelessWidget {
  const SwipeChecklistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.check_circle,
              size: 120,
              color: Colors.deepPurple,
            ),
            SizedBox(height: 20),
            Text(
              'CHECKLIST PRO',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
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
  late Box taskBox;

  int streak = 0;

  List<Task> tasks = [];
  List<Task> finishedTasks = [];
  List<Task> pendingTasks = [];

  final List<String> defaultTasks = [
    "Core Philosophy | Do NOT position as placement guarantee",
    "Core Philosophy | Position as capability + confidence + clarity",
    "Core Philosophy | Focus on transformation",
    "Core Philosophy | Build trust before promises",
    "Core Philosophy | Optimize long-term goodwill",
    "Student Needs | Help students feel smarter",
    "Student Needs | Help students understand technology practically",
    "Student Needs | Help students gain confidence",
    "Student Needs | Help students stop feeling behind",
    "Student Needs | Help students build self-belief",
    "Student Needs | Help students gain direction",
    "Product Design | Use real-world case studies",
    "Product Design | Teach through Swiggy systems",
    "Product Design | Teach through UPI systems",
    "Product Design | Teach through WhatsApp systems",
    "Product Design | Teach through Netflix systems",
    "Product Design | Teach through Instagram systems",
    "Product Design | Focus practical understanding",
    "Product Design | Reduce theory-heavy learning",
    "Product Design | Make students build early",
    "Avoid Becoming | NOT another coding academy",
    "Avoid Becoming | NOT another LMS",
    "Avoid Becoming | NOT fake-placement marketing",
    "Avoid Becoming | NOT tutorial dumping",
    "Become | A builder mindset platform",
    "Become | A capability acceleration system",
    "Become | A confidence-building ecosystem",
    "Become | A transformation-oriented community",
    "Emotional Outcomes | Students feel sharper",
    "Emotional Outcomes | Students feel capable",
    "Emotional Outcomes | Students feel direction",
    "Community Layer | Create peer groups",
    "Community Layer | Encourage student showcases",
    "Community Layer | Build public progress systems",
    "Community Layer | Celebrate student projects",
    "Community Layer | Create accountability systems",
    "Career Support | Resume guidance",
    "Career Support | Mock interviews",
    "Career Support | Project reviews",
    "Career Support | Internship exposure",
    "Career Support | Networking opportunities",
    "Career Support | Career direction sessions",
  ];

  @override
  void initState() {
    super.initState();

    initializeApp();
  }

  Future<void> initializeApp() async {
    taskBox = await Hive.openBox('tasks');

    await loadStreak();
    await loadTasks();

    showYesterdayReport();
  }

  Future<void> loadStreak() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    streak = prefs.getInt('streak') ?? 0;

    setState(() {});
  }

  Future<void> saveStreak() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setInt('streak', streak);
  }

  Future<void> loadTasks() async {
    List savedTasks = taskBox.get(
      'taskList',
      defaultValue: defaultTasks,
    );

    setState(() {
      tasks = savedTasks
          .map(
            (e) => Task(
              title: e,
              status: 'Pending',
            ),
          )
          .toList();
    });
  }

  void saveTasks() {
    List<String> taskTitles =
        tasks.map((e) => e.title).toList();

    taskBox.put('taskList', taskTitles);
  }

  Future<void> updateCounts() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setInt(
      'completed_count',
      finishedTasks.length,
    );

    await prefs.setInt(
      'pending_count',
      pendingTasks.length,
    );
  }

  void finishTask(Task task) async {
    setState(() {
      finishedTasks.add(task);

      tasks.remove(task);

      streak++;
    });

    await saveStreak();

    saveTasks();

    updateCounts();
  }

  void doLater(Task task) async {
    setState(() {
      pendingTasks.add(task);

      tasks.remove(task);
    });

    saveTasks();

    updateCounts();
  }

  Future<void> showYesterdayReport() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    int completed =
        prefs.getInt('completed_count') ?? 0;

    int pending =
        prefs.getInt('pending_count') ?? 0;

    Future.delayed(
      const Duration(seconds: 1),
      () {
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              title: const Text('Yesterday Report'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Completed : $completed'),
                  const SizedBox(height: 10),
                  Text('Pending : $pending'),
                  const SizedBox(height: 10),
                  Text('Current Streak : $streak 🔥'),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: const Color(0xFF111827),
        child: ListView(
          children: [
            const DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.check, size: 40),
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
                    builder: (_) => TaskPage(
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
                    builder: (_) => TaskPage(
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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.deepPurple,
                  Colors.indigo,
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Streak',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$streak 🔥',
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
          const SizedBox(height: 20),
          Expanded(
            child: tasks.isEmpty
                ? const Center(
                    child: Text(
                      'All Tasks Completed',
                      style: TextStyle(
                        fontSize: 28,
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
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 30),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: const Text(
                            'FINISHED',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 30),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: const Text(
                            'DO LATER',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
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
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1E293B),
                                Color(0xFF0F172A),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: const Text('WORK'),
                              ),
                              const Spacer(),
                              const Center(
                                child: Icon(
                                  Icons.assignment_turned_in,
                                  size: 90,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                task.title,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Swipe Right → Finished',
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Swipe Left ← Do Later',
                                style: TextStyle(
                                  color: Colors.orangeAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
        onPressed: () {
          TextEditingController controller =
              TextEditingController();

          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                backgroundColor: const Color(0xFF1E293B),
                title: const Text('Add Task'),
                content: TextField(
                  controller: controller,
                ),
                actions: [
                  ElevatedButton(
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

                        saveTasks();
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

class TaskPage extends StatelessWidget {
  final String title;
  final List<Task> tasks;

  const TaskPage({
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
              child: Text('No $title'),
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tasks[index].title),
                );
              },
            ),
    );
  }
}