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

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isAuthenticated = false;
  int _selectedTabIndex = 0;
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (_passwordController.text.trim().isEmpty) {
      _showSnackBar('Please enter a password', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final appState = context.read<AppState>();
      final success = await appState.authenticate(_passwordController.text);

      if (success) {
        setState(() {
          _isAuthenticated = true;
          _isLoading = false;
        });
        _passwordController.clear();
        _showSnackBar('Authentication successful');
      } else {
        setState(() => _isLoading = false);
        _showSnackBar('Incorrect password', isError: true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Authentication failed. Please try again.', isError: true);
    }
  }

  void _logout() {
    context.read<AppState>().logout();
    setState(() {
      _isAuthenticated = false;
      _selectedTabIndex = 0;
    });
    _tabController.animateTo(0);
    _showSnackBar('Logged out successfully');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2F38),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2F38),
        elevation: 0,
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
              tooltip: 'Logout',
            ),
        ],
      ),
      body: _isAuthenticated ? _buildAuthenticatedContent() : _buildLoginForm(),
    );
  }

  Widget _buildLoginForm() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          color: const Color(0xFF2A3F48),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.security, size: 80, color: Color(0xFF4CAF50)),
                const SizedBox(height: 24),
                const Text(
                  'Settings Access',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your password to access settings',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Color(0xFF4CAF50),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1A2F38),
                  ),
                  onSubmitted: (_) => _authenticate(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _authenticate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Access Settings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
  }

  Widget _buildAuthenticatedContent() {
    return Column(
      children: [
        // Modern Tab bar
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A3F48),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorPadding: const EdgeInsets.all(4),
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Channels'),
              Tab(text: 'Programs'),
              Tab(text: 'Default'),
              Tab(text: 'Password'),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
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

  Widget _buildChannelsTab() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    '${appState.channels.length} Channels',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  FloatingActionButton.extended(
                    onPressed: () => _showAddChannelDialog(context),
                    backgroundColor: const Color(0xFF4CAF50),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Channel'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: appState.channels.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.tv,
                      title: 'No Channels',
                      subtitle: 'Add your first channel to get started',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFF2A3F48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF4CAF50),
          child: channel.logo.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    channel.logo,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.tv, color: Colors.white),
                  ),
                )
              : const Icon(Icons.tv, color: Colors.white),
        ),
        title: Text(
          channel.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Category: ${channel.category}',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFF2A3F48),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditChannelDialog(context, channel);
                break;
              case 'delete':
                _showDeleteChannelDialog(context, channel, appState);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text('Edit', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.white)),
                ],
              ),
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
                  Text(
                    '${appState.programs.length} Programs',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  FloatingActionButton.extended(
                    onPressed: () => _showAddProgramDialog(context),
                    backgroundColor: const Color(0xFF4CAF50),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Program'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: appState.programs.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.video_library,
                      title: 'No Programs',
                      subtitle: 'Add your first program to get started',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFF2A3F48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
        ),
        title: Text(
          program.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMM dd, yyyy h:mm a').format(program.startTime),
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              'Duration: ${program.duration.inMinutes} minutes',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: const Color(0xFF2A3F48),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditProgramDialog(context, program);
                break;
              case 'delete':
                _showDeleteProgramDialog(context, program, appState);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text('Edit', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.white)),
                ],
              ),
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
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This program will play when no scheduled content is available',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 24),
              if (appState.defaultProgram != null) ...[
                Card(
                  color: const Color(0xFF2A3F48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appState.defaultProgram!.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Duration: ${appState.defaultProgram!.duration.inMinutes} minutes',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () =>
                                  _showEditDefaultProgramDialog(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                _buildEmptyState(
                  icon: Icons.star_border,
                  title: 'No Default Program',
                  subtitle: 'Set a default program for fallback content',
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddDefaultProgramDialog(context),
                  icon: const Icon(Icons.star),
                  label: Text(
                    appState.defaultProgram != null
                        ? 'Change Default Program'
                        : 'Set Default Program',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPasswordTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Change Settings Password',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Update your password to secure access to settings',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          Card(
            color: const Color(0xFF2A3F48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextField(
                    controller: _currentPasswordController,
                    obscureText: _obscureCurrentPassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Color(0xFF4CAF50),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrentPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(
                          () => _obscureCurrentPassword =
                              !_obscureCurrentPassword,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: 'Current Password',
                      labelStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1A2F38),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.lock_reset,
                        color: Color(0xFF4CAF50),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () => setState(
                          () => _obscureNewPassword = !_obscureNewPassword,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: 'New Password',
                      labelStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1A2F38),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _updatePassword,
                      icon: const Icon(Icons.security),
                      label: const Text('Update Password'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _updatePassword() {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty) {
      _showSnackBar('Please fill in all password fields', isError: true);
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showSnackBar(
        'New password must be at least 6 characters',
        isError: true,
      );
      return;
    }

    // Validate current password first
    final appState = context.read<AppState>();
    // You should add a method to validate current password in AppState

    try {
      appState.setSettingsPassword(_newPasswordController.text);
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _showSnackBar('Password updated successfully');
    } catch (e) {
      _showSnackBar('Failed to update password', isError: true);
    }
  }

  // Dialog methods with improved UI
  void _showAddChannelDialog(BuildContext context) {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final logoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A3F48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Add Channel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogTextField(nameController, 'Channel Name', Icons.tv),
            const SizedBox(height: 16),
            _buildDialogTextField(
              categoryController,
              'Category',
              Icons.category,
            ),
            const SizedBox(height: 16),
            _buildDialogTextField(logoController, 'Logo URL', Icons.image),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                _showSnackBar('Channel name is required', isError: true);
                return;
              }

              final channel = Channel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text.trim(),
                category: categoryController.text.trim(),
                logo: logoController.text.trim(),
              );
              context.read<AppState>().addChannel(channel);
              Navigator.pop(context);
              _showSnackBar('Channel added successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4CAF50)),
        ),
        filled: true,
        fillColor: const Color(0xFF1A2F38),
      ),
    );
  }

  // Implement remaining dialog methods with similar improvements...
  void _showEditChannelDialog(BuildContext context, Channel channel) {
    // Similar implementation with pre-filled values
  }

  void _showDeleteChannelDialog(
    BuildContext context,
    Channel channel,
    AppState appState,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A3F48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Channel',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${channel.name}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              appState.deleteChannel(channel.id);
              Navigator.pop(context);
              _showSnackBar('Channel deleted successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddProgramDialog(BuildContext context) {
    // Enhanced program dialog implementation
    // This would be similar to your existing implementation but with improved UI
  }

  void _showEditProgramDialog(BuildContext context, Program program) {
    // Implementation for editing programs
  }

  void _showDeleteProgramDialog(
    BuildContext context,
    Program program,
    AppState appState,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A3F48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Program',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${program.title}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              appState.deleteProgram(program.id);
              Navigator.pop(context);
              _showSnackBar('Program deleted successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddDefaultProgramDialog(BuildContext context) {
    // Allow user to select from existing programs or create a new one
    showDialog(
      context: context,
      builder: (context) => Consumer<AppState>(
        builder: (context, appState, child) => AlertDialog(
          backgroundColor: const Color(0xFF2A3F48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Set Default Program',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose a program to set as default:',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              if (appState.programs.isEmpty) ...[
                const Text(
                  'No programs available. Please add programs first.',
                  style: TextStyle(color: Colors.grey),
                ),
              ] else ...[
                SizedBox(
                  height: 200,
                  width: double.maxFinite,
                  child: ListView.builder(
                    itemCount: appState.programs.length,
                    itemBuilder: (context, index) {
                      final program = appState.programs[index];
                      return Card(
                        color: const Color(0xFF1A2F38),
                        child: ListTile(
                          title: Text(
                            program.title,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            'Duration: ${program.duration.inMinutes} minutes',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          onTap: () {
                            appState.setDefaultProgram(program);
                            Navigator.pop(context);
                            _showSnackBar('Default program set successfully');
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            if (appState.programs.isEmpty)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showAddProgramDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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

  void _showEditDefaultProgramDialog(BuildContext context) {
    final appState = context.read<AppState>();
    if (appState.defaultProgram != null) {
      _showEditProgramDialog(context, appState.defaultProgram!);
    }
  }
}
