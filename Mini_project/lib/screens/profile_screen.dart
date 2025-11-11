import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/role_access.dart';
import '../services/role_router.dart'; // ✅ added import for RoleRouter
import '../services/ai_config.dart';

class ProfileScreen extends StatefulWidget {
  final Color themeColor;
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback? onRoleChanged;
  final bool isGuest;
  final VoidCallback? onLogoutRequested;

  const ProfileScreen({
    super.key,
    required this.themeColor,
    required this.isDark,
    required this.onToggleTheme,
    this.onRoleChanged,
    this.isGuest = false,
    this.onLogoutRequested,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String _userRole = 'guest';
  bool _loading = false;
  bool _hasApiKey = false;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _auth.userChanges().listen((user) {
      setState(() => _user = user);
      if (user != null) {
        _loadUserRole();
      } else {
        setState(() => _userRole = 'guest');
      }
    });
    if (_user != null) {
      _loadUserRole();
    } else {
      _userRole = 'guest';
    }
    _checkApiKey();
  }
  
  Future<void> _checkApiKey() async {
    final hasKey = await AIConfig.hasApiKey();
    setState(() {
      _hasApiKey = hasKey;
    });
  }
  
  Future<void> _showApiKeyDialog() async {
    final controller = TextEditingController();
    final hasKey = await AIConfig.hasApiKey();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('AI Chatbot API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasKey
                  ? 'Update your Google Gemini API key for the AI chatbot. Leave empty to remove.'
                  : 'Enter your Google Gemini API key to enable AI-powered chatbot responses.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Gemini API Key',
                hintText: 'AIza...',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Get your API key from aistudio.google.com/apikey',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Free tier available with generous quota',
              style: TextStyle(
                fontSize: 11,
                color: Colors.green[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          if (hasKey)
            TextButton(
              onPressed: () async {
                await AIConfig.removeApiKey();
                Navigator.pop(ctx);
                _checkApiKey();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('API key removed')),
                  );
                }
              },
              child: const Text('Remove'),
            ),
          ElevatedButton(
            onPressed: () async {
              final key = controller.text.trim();
              if (key.isNotEmpty) {
                await AIConfig.saveApiKey(key);
                Navigator.pop(ctx);
                _checkApiKey();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('API key saved successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                Navigator.pop(ctx);
              }
            },
            child: Text(hasKey ? 'Update' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserRole() async {
    if (_user == null) return;
    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists && doc.data()?['role'] != null) {
        setState(() => _userRole = doc.data()!['role']);
      }
    } catch (e) {
      print('Error loading role: $e');
    }
  }

  Future<void> _updateRole(String newRole) async {
    if (_user == null) return;
    setState(() => _loading = true);
    try {
      // Use update() instead of set() with merge for better error handling
      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .update({'role': newRole});
      
      setState(() {
        _userRole = newRole;
        _loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Role updated to ${RoleAccess.getRoleDisplayName(newRole)}'),
            backgroundColor: Colors.green,
          ),
        );
      }

      print('✅ SUCCESS updating role to: $newRole');

      // ✅ Notify parent widget to refresh (don't navigate away, allow user to go back)
      if (widget.onRoleChanged != null) {
        widget.onRoleChanged!();
      }
      
      // Show option to navigate to role dashboard
      if (mounted) {
        _showRoleNavigationDialog(newRole);
      }

    } catch (e) {
      print("❌ ERROR updating role: ${e.toString()}");
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating role: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showRoleSelector() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Guest'),
              leading: Radio<String>(
                value: 'guest',
                groupValue: _userRole,
                onChanged: (value) {
                  Navigator.pop(ctx);
                  if (value != null) _updateRole(value);
                },
              ),
            ),
            ListTile(
              title: const Text('User'),
              leading: Radio<String>(
                value: 'user',
                groupValue: _userRole,
                onChanged: (value) {
                  Navigator.pop(ctx);
                  if (value != null) _updateRole(value);
                },
              ),
            ),
            ListTile(
              title: const Text('VIP'),
              leading: Radio<String>(
                value: 'vip',
                groupValue: _userRole,
                onChanged: (value) {
                  Navigator.pop(ctx);
                  if (value != null) _updateRole(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleNavigationDialog(String newRole) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Role Updated'),
        content: Text('Your role has been updated to ${RoleAccess.getRoleDisplayName(newRole)}. Would you like to view the ${RoleAccess.getRoleDisplayName(newRole)} dashboard?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('Stay Here'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              RoleRouter().navigateToRoleDashboard(context, newRole);
            },
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      // Delegate to parent if provided (needed for exiting guest mode)
      if (widget.onLogoutRequested != null) {
        widget.onLogoutRequested!();
      } else {
        await _auth.signOut();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRole = (_user == null || widget.isGuest) ? 'guest' : _userRole;
    final isAdminRole = effectiveRole.startsWith('admin');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: widget.themeColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: widget.themeColor,
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                _user?.email ?? 'Not logged in',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Role: ${RoleAccess.getRoleDisplayName(effectiveRole)}',
                style: TextStyle(
                  color: widget.themeColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 48),
              if (!isAdminRole && _user != null) // Hide for admin roles and guests
                Card(
                  child: ListTile(
                    leading: Icon(Icons.admin_panel_settings, color: widget.themeColor),
                    title: const Text('Change Role'),
                    subtitle: Text('Current: ${RoleAccess.getRoleDisplayName(effectiveRole)}'),
                    trailing: _loading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.chevron_right),
                    onTap: _loading ? null : _showRoleSelector,
                  ),
                ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: widget.isDark,
                onChanged: (_) => widget.onToggleTheme(),
                secondary: Icon(widget.isDark ? Icons.dark_mode : Icons.light_mode),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: Icon(
                    _hasApiKey ? Icons.check_circle : Icons.info_outline,
                    color: _hasApiKey ? Colors.green : widget.themeColor,
                  ),
                  title: const Text('AI Chatbot Settings'),
                  subtitle: Text(_hasApiKey
                      ? 'API key configured'
                      : 'Configure API key for AI responses'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showApiKeyDialog,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: Text((_user == null || widget.isGuest) ? 'Exit Guest' : 'Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}










