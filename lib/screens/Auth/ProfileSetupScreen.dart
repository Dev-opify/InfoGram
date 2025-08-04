// screens/profile_setup_screen.dart
import 'package:flutter/material.dart';
import '/services/auth_service.dart';
import 'dart:developer' as developer;

class ProfileSetupScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String college;
  final String password;

  const ProfileSetupScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.college,
    required this.password,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  String? _selectedBranch;
  int? _selectedSemester;
  bool _isLoading = false;

  final List<String> _branches = [
    'Computer Science and Engineering',
    'Information Technology',
    'Electronics and Communication Engineering',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Chemical Engineering',
    'Aerospace Engineering',
    'Biotechnology',
    'Mathematics and Computing',
    'Other',
  ];

  final List<int> _semesters = [1, 2, 3, 4, 5, 6, 7, 8];

  Future<void> _completeRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user account with Firebase Auth and Firestore
      await _authService.createUserWithEmailAndPassword(
        widget.email,
        widget.password,
        widget.fullName,
        _selectedBranch!,
        _selectedSemester!,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // No need to navigate manually - AuthWrapper will handle it
        // The authentication state change will automatically navigate to HomeScreen

        // Pop all screens and let AuthWrapper handle navigation
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Complete Profile',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Welcome text
                Text(
                  'Welcome, ${widget.fullName}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                const Text(
                  'Complete your profile to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Profile summary card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.person, 'Name', widget.fullName),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.email, 'Email', widget.email),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.school, 'College', widget.college),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Branch selection
                const Text(
                  'Select Your Branch',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedBranch,
                  decoration: InputDecoration(
                    hintText: 'Choose your branch',
                    prefixIcon: const Icon(Icons.account_tree_outlined, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: _branches.map((String branch) {
                    return DropdownMenuItem<String>(
                      value: branch,
                      child: Text(
                        branch,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBranch = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your branch';
                    }
                    return null;
                  },
                  isExpanded: true,
                  menuMaxHeight: 200,
                ),

                const SizedBox(height: 20),

                // Semester selection
                const Text(
                  'Select Your Current Semester',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _selectedSemester,
                  decoration: InputDecoration(
                    hintText: 'Choose your semester',
                    prefixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: _semesters.map((int semester) {
                    return DropdownMenuItem<int>(
                      value: semester,
                      child: Text(
                        'Semester $semester',
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedSemester = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your semester';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 40),

                // Complete registration button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _completeRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      'Complete Registration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}