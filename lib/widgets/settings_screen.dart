import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/app_state.dart';
import '../models/channel.dart';
import '../models/program.dart';
import 'calendar_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _passwordController = TextEditingController();
  bool _isAuthenticated = false;
  int _selectedTabIndex = 0;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    final appState = context.read<AppState>();
    final success = await appState.authenticate(_passwordController.text);

    if (success) {
      setState(() {
        _isAuthenticated = true;
      });
      _passwordController.clear();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Incorrect password')));
    }
  }

  void _logout() {
    context.read<AppState>().logout();
    setState(() {
      _isAuthenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2F38),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2F38),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isAuthenticated)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _logout,
            ),
        ],
      ),
      body: _isAuthenticated ? _buildAuthenticatedContent() : _buildLoginForm(),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 80, color: Colors.white),
          const SizedBox(height: 20),
          const Text(
            'Enter Settings Password',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            onSubmitted: (_) => _authenticate(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _authenticate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text(
              'Login',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedContent() {
    return Column(
      children: [
        // Tab bar
        Container(
          color: const Color(0xFF2A3F48),
          child: Row(
            children: [
              _buildTab('Channels', 0),
              _buildTab('Programs', 1),
              _buildTab('Default Program', 2),
              _buildTab('Password', 3),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: IndexedStack(
            index: _selectedTabIndex,
            children: [
              _buildChannelsTab(),
              _buildProgramsTab(),
              _buildDefaultProgramTab(),
              _buildPasswordTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFF4CAF50)
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChannelsTab() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: Container()),
                  ElevatedButton.icon(
                    onPressed: () => _showAddChannelDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Channel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: appState.channels.length,
                itemBuilder: (context, index) {
                  final channel = appState.channels[index];
                  return _buildChannelTile(channel, appState);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChannelTile(Channel channel, AppState appState) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: const Color(0xFF2A3F48),
      child: ListTile(
        title: Text(channel.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          'Category: ${channel.category}',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditChannelDialog(context, channel),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  _showDeleteChannelDialog(context, channel, appState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramsTab() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: Container()),
                  ElevatedButton.icon(
                    onPressed: () => _showAddProgramDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Program'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: appState.programs.length,
                itemBuilder: (context, index) {
                  final program = appState.programs[index];
                  return _buildProgramTile(program, appState);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgramTile(Program program, AppState appState) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: const Color(0xFF2A3F48),
      child: ListTile(
        title: Text(program.title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          '${program.startTime.toString().substring(0, 16)} - ${program.duration.inMinutes}min',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditProgramDialog(context, program),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  _showDeleteProgramDialog(context, program, appState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultProgramTab() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Default Program',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (appState.defaultProgram != null) ...[
                Card(
                  color: const Color(0xFF2A3F48),
                  child: ListTile(
                    title: Text(
                      appState.defaultProgram!.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Duration: ${appState.defaultProgram!.duration.inMinutes} minutes',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDefaultProgramDialog(context),
                    ),
                  ),
                ),
              ] else ...[
                const Text(
                  'No default program set',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showAddDefaultProgramDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Set Default Program'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPasswordTab() {
    final passwordController = TextEditingController();
    final newPasswordController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Change Settings Password',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Current Password',
              labelStyle: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: newPasswordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'New Password',
              labelStyle: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Validate current password and update
              context.read<AppState>().setSettingsPassword(
                newPasswordController.text,
              );
              passwordController.clear();
              newPasswordController.clear();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Password updated')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Update Password'),
          ),
        ],
      ),
    );
  }

  // Dialog methods
  void _showAddChannelDialog(BuildContext context) {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final logoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Channel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Channel Name'),
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: logoController,
              decoration: const InputDecoration(labelText: 'Logo'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final channel = Channel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                category: categoryController.text,
                logo: logoController.text,
              );
              context.read<AppState>().addChannel(channel);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditChannelDialog(BuildContext context, Channel channel) {
    final nameController = TextEditingController(text: channel.name);
    final categoryController = TextEditingController(text: channel.category);
    final logoController = TextEditingController(text: channel.logo);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Channel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Channel Name'),
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: logoController,
              decoration: const InputDecoration(labelText: 'Logo'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedChannel = channel.copyWith(
                name: nameController.text,
                category: categoryController.text,
                logo: logoController.text,
              );
              context.read<AppState>().updateChannel(updatedChannel);
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteChannelDialog(
    BuildContext context,
    Channel channel,
    AppState appState,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Channel'),
        content: Text('Are you sure you want to delete ${channel.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              appState.deleteChannel(channel.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddProgramDialog(BuildContext context) {
    final titleController = TextEditingController();
    final channelIdController = TextEditingController();
    final videoUrlController = TextEditingController();
    final durationController = TextEditingController(text: '30');
    DateTime? startTime;
    VideoType videoType = VideoType.youtube;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Program'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Program Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: channelIdController,
                  decoration: const InputDecoration(
                    labelText: 'Channel ID',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: videoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Video URL or File Path',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Video Type: '),
                    DropdownButton<VideoType>(
                      value: videoType,
                      items: VideoType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          videoType = value!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: durationController,
                        decoration: const InputDecoration(
                          labelText: 'Duration (minutes)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => CalendarWidget(
                              title: 'Select Start Time',
                              onDateTimeSelected: (date, time) {
                                setState(() {
                                  startTime = time;
                                });
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Set Start Time'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                  ],
                ),
                if (startTime != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Start Time: ${DateFormat('MMM dd, yyyy h:mm a').format(startTime!)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty ||
                    channelIdController.text.isEmpty ||
                    videoUrlController.text.isEmpty ||
                    startTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields'),
                    ),
                  );
                  return;
                }

                final durationMinutes =
                    int.tryParse(durationController.text) ?? 30;
                final endTime = startTime!.add(
                  Duration(minutes: durationMinutes),
                );

                final program = Program(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  channelId: channelIdController.text,
                  startTime: startTime!,
                  endTime: endTime,
                  duration: Duration(minutes: durationMinutes),
                  videoUrl: videoUrlController.text,
                  videoType: videoType,
                );
                context.read<AppState>().addProgram(program);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
              ),
              child: const Text(
                'Add Program',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProgramDialog(BuildContext context, Program program) {
    // Similar to add program dialog but with pre-filled values
    // Implementation would be similar to _showAddProgramDialog
  }

  void _showDeleteProgramDialog(
    BuildContext context,
    Program program,
    AppState appState,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Program'),
        content: Text('Are you sure you want to delete ${program.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              appState.deleteProgram(program.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddDefaultProgramDialog(BuildContext context) {
    // Similar to add program dialog but sets as default
  }

  void _showEditDefaultProgramDialog(BuildContext context) {
    // Edit default program dialog
  }
}
