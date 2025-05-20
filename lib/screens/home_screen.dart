import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../models/task.dart';
import '../models/note.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<Task> _tasks = [];
  List<Note> _notes = [];
  bool _isLoading = true;
  ParseUser? _currentUser;
  late TabController _tabController;
  final List<String> _categories = ['Personal', 'Work', 'Study', 'Other'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild when tab changes
    });
    _initializeUserAndLoadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeUserAndLoadData() async {
    ParseUser? user = await ParseUser.currentUser();
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return;
    }

    setState(() {
      _currentUser = user;
    });

    _loadTasks();
    _loadNotes();
  }

  Future<void> _loadTasks() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final QueryBuilder<Task> queryBuilder = QueryBuilder<Task>(Task())
        ..whereEqualTo('user', _currentUser)
        ..orderByDescending('updatedAt');

      final ParseResponse response = await queryBuilder.query();

      if (response.success && response.results != null) {
        setState(() {
          _tasks = response.results!.map((e) => e as Task).toList();
          _isLoading = false;
        });
      } else {
        _showErrorSnackBar(response.error?.message ?? 'Error loading tasks');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNotes() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final QueryBuilder<Note> queryBuilder = QueryBuilder<Note>(Note())
        ..whereEqualTo('user', _currentUser)
        ..orderByDescending('updatedAt');

      final ParseResponse response = await queryBuilder.query();

      if (response.success && response.results != null) {
        setState(() {
          _notes = response.results!.map((e) => e as Note).toList();
          _isLoading = false;
        });
      } else {
        _showErrorSnackBar(response.error?.message ?? 'Error loading notes');
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    if (_currentUser == null) return;

    try {
      final response = await _currentUser!.logout();
      if (response.success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
        );
      } else {
        _showErrorSnackBar(response.error!.message);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to logout: ${e.toString()}');
    }
  }

  Future<void> _showTaskDialog({Task? task}) async {
    final titleController = TextEditingController(text: task?.title ?? '');
    final descriptionController = TextEditingController(text: task?.description ?? '');
    bool isDone = task?.isDone ?? false;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                task == null ? 'Add Task' : 'Edit Task',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    if (task != null)
                      CheckboxListTile(
                        title: Text('Completed'),
                        value: isDone,
                        onChanged: (value) {
                          setState(() {
                            isDone = value ?? false;
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final description = descriptionController.text.trim();

                    if (title.isEmpty) {
                      _showErrorSnackBar('Title cannot be empty');
                      return;
                    }

                    if (task == null) {
                      // Create new task
                      final newTask = Task()
                        ..title = title
                        ..description = description
                        ..isDone = false
                        ..user = _currentUser;

                      try {
                        final response = await newTask.save();
                        if (response.success) {
                          Navigator.pop(context);
                          _loadTasks();
                        } else {
                          _showErrorSnackBar(response.error!.message);
                        }
                      } catch (e) {
                        _showErrorSnackBar('Error: ${e.toString()}');
                      }
                    } else {
                      // Update existing task
                      task.title = title;
                      task.description = description;
                      task.isDone = isDone;

                      try {
                        final response = await task.save();
                        if (response.success) {
                          Navigator.pop(context);
                          _loadTasks();
                        } else {
                          _showErrorSnackBar(response.error!.message);
                        }
                      } catch (e) {
                        _showErrorSnackBar('Error: ${e.toString()}');
                      }
                    }
                  },
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showNoteDialog({Note? note}) async {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    String selectedCategory = note?.category ?? _categories.first;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                note == null ? 'Add Note' : 'Edit Note',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: contentController,
                      decoration: InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 5,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final content = contentController.text.trim();

                    if (title.isEmpty) {
                      _showErrorSnackBar('Title cannot be empty');
                      return;
                    }

                    if (note == null) {
                      // Create new note
                      final newNote = Note()
                        ..title = title
                        ..content = content
                        ..category = selectedCategory
                        ..user = _currentUser;

                      try {
                        final response = await newNote.save();
                        if (response.success) {
                          Navigator.pop(context);
                          _loadNotes();
                        } else {
                          _showErrorSnackBar(response.error!.message);
                        }
                      } catch (e) {
                        _showErrorSnackBar('Error: ${e.toString()}');
                      }
                    } else {
                      // Update existing note
                      note.title = title;
                      note.content = content;
                      note.category = selectedCategory;

                      try {
                        final response = await note.save();
                        if (response.success) {
                          Navigator.pop(context);
                          _loadNotes();
                        } else {
                          _showErrorSnackBar(response.error!.message);
                        }
                      } catch (e) {
                        _showErrorSnackBar('Error: ${e.toString()}');
                      }
                    }
                  },
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteTask(Task task) async {
    try {
      final response = await task.delete();
      if (response.success) {
        _loadTasks();
      } else {
        _showErrorSnackBar(response.error!.message);
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> _deleteNote(Note note) async {
    try {
      final response = await note.delete();
      if (response.success) {
        _loadNotes();
      } else {
        _showErrorSnackBar(response.error!.message);
      }
    } catch (e) {
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6A11CB),
            Color(0xFF2575FC),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.1),
          elevation: 0,
          title: Text(
            'TaskyNote',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                if (_tabController.index == 0) {
                  _loadTasks();
                } else {
                  _loadNotes();
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: _logout,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: Icon(Icons.task, color: Colors.white),
                text: 'Tasks',
              ),
              Tab(
                icon: Icon(Icons.note, color: Colors.white),
                text: 'Notes',
              ),
            ],
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 3,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: Container(
          margin: EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tasks Tab
              _isLoading && _tabController.index == 0
                  ? _buildLoadingIndicator()
                  : _tasks.isEmpty
                  ? _buildEmptyState('No tasks found.', Icons.task_alt)
                  : _buildTasksList(),

              // Notes Tab
              _isLoading && _tabController.index == 1
                  ? _buildLoadingIndicator()
                  : _notes.isEmpty
                  ? _buildEmptyState('No notes found.', Icons.note_alt)
                  : _buildNotesList(),
            ],
          ),
        ),
        floatingActionButton: AnimatedScale(
          scale: 1.0,
          duration: Duration(milliseconds: 200),
          child: FloatingActionButton(
            onPressed: () {
              if (_tabController.index == 0) {
                _showTaskDialog();
              } else {
                _showNoteDialog();
              }
            },
            child: Icon(Icons.add),
            backgroundColor: Theme.of(context).primaryColorLight,
            elevation: 8,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.brown.shade600,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text(_tabController.index == 0 ? 'Add Task' : 'Add Note'),
            onPressed: () {
              if (_tabController.index == 0) {
                _showTaskDialog();
              } else {
                _showNoteDialog();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: ListView.builder(
        key: ValueKey<int>(_tasks.length),
        padding: EdgeInsets.all(16),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  task.description,
                  style: TextStyle(
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              leading: Checkbox(
                value: task.isDone,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (value) async {
                  task.isDone = value!;
                  try {
                    await task.save();
                    _loadTasks();
                  } catch (e) {
                    _showErrorSnackBar('Error: ${e.toString()}');
                  }
                },
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showTaskDialog(task: task),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTask(task),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotesList() {
    // Group notes by category
    Map<String, List<Note>> categorizedNotes = {};

    for (var note in _notes) {
      if (!categorizedNotes.containsKey(note.category)) {
        categorizedNotes[note.category] = [];
      }
      categorizedNotes[note.category]!.add(note);
    }

    List<String> categories = categorizedNotes.keys.toList();

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: categories.isEmpty
          ? _buildEmptyState('No notes found.', Icons.note_alt)
          : ListView.builder(
        key: ValueKey<int>(_notes.length),
        padding: EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          String category = categories[index];
          List<Note> notesInCategory = categorizedNotes[category]!;

          return Card(
            margin: EdgeInsets.only(bottom: 16),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ExpansionTile(
              key: Key(category),
              initiallyExpanded: true,
              title: Text(
                category,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: _getCategoryColor(category),
                ),
              ),
              leading: Icon(
                _getCategoryIcon(category),
                color: _getCategoryColor(category),
              ),
              children: notesInCategory.map((note) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      note.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text(note.content),
                        SizedBox(height: 8),
                        Text(
                          'Last updated: ${_formatDate(note.updatedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showNoteDialog(note: note),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNote(note),
                        ),
                      ],
                    ),
                    onTap: () => _showNoteDialog(note: note),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Personal':
        return Icons.person;
      case 'Work':
        return Icons.work;
      case 'Study':
        return Icons.school;
      default:
        return Icons.folder;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Personal':
        return Colors.purple;
      case 'Work':
        return Colors.blue;
      case 'Study':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }
}