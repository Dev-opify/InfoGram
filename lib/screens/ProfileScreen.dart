// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // Controllers
  final _nameController = TextEditingController();
  final _sectionController = TextEditingController();
  final _emailController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectSearchController = TextEditingController();

  // State variables
  bool _isLoading = false;
  DateTime? _selectedDate;
  List<Map<String, String>> _selectedSubjects = [];
  List<Map<String, String>> _filteredSubjects = [];
  bool _showSubjectDropdown = false;

  // Available subjects with codes
  final List<Map<String, String>> _availableSubjects = [
    {'name': 'Data Structures and Algorithms', 'code': 'DSA101'},
    {'name': 'Object Oriented Programming', 'code': 'OOP201'},
    {'name': 'Database Management System', 'code': 'DBMS301'},
    {'name': 'Computer Networks', 'code': 'CN401'},
    {'name': 'Operating Systems', 'code': 'OS501'},
    {'name': 'Software Engineering', 'code': 'SE601'},
    {'name': 'Mathematics', 'code': 'MATH101'},
    {'name': 'Physics', 'code': 'PHY101'},
    {'name': 'Chemistry', 'code': 'CHEM101'},
    {'name': 'Digital Electronics', 'code': 'DECO201'},
    {'name': 'Microprocessors', 'code': 'MP301'},
    {'name': 'Computer Architecture', 'code': 'CA401'},
    {'name': 'Artificial Intelligence', 'code': 'AI501'},
    {'name': 'Machine Learning', 'code': 'ML601'},
    {'name': 'Web Development', 'code': 'WD701'},
    {'name': 'Mobile App Development', 'code': 'MAD801'},
    {'name': 'Python Programming', 'code': 'PY101'},
    {'name': 'Java Programming', 'code': 'JAVA201'},
    {'name': 'C++ Programming', 'code': 'CPP301'},
    {'name': 'Data Science', 'code': 'DS401'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _filteredSubjects = _availableSubjects;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sectionController.dispose();
    _emailController.dispose();
    _rollNumberController.dispose();
    _phoneController.dispose();
    _subjectSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data()!;
          setState(() {
            _nameController.text = data['fullName'] ?? '';
            _emailController.text = data['email'] ?? '';
            _sectionController.text = data['section'] ?? '';
            _rollNumberController.text = data['rollNumber'] ?? '';
            _phoneController.text = data['phoneNumber'] ?? '';
            if (data['dateOfBirth'] != null) {
              _selectedDate = (data['dateOfBirth'] as Timestamp).toDate();
            }
            if (data['subjects'] != null) {
              _selectedSubjects = List<Map<String, String>>.from(
                  data['subjects'].map((subject) => Map<String, String>.from(subject))
              );
            }
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fullName': _nameController.text.trim(),
          'section': _sectionController.text.trim(),
          'rollNumber': _rollNumberController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'dateOfBirth': _selectedDate,
          'subjects': _selectedSubjects,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterSubjects(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSubjects = _availableSubjects;
        _showSubjectDropdown = true;
      } else {
        _filteredSubjects = _availableSubjects.where((subject) {
          final name = subject['name']!.toLowerCase();
          final code = subject['code']!.toLowerCase();
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) || code.contains(searchQuery);
        }).toList();
        _showSubjectDropdown = true;
      }
    });
  }

  void _addSubject(Map<String, String> subject) {
    if (!_selectedSubjects.any((s) => s['code'] == subject['code'])) {
      setState(() {
        _selectedSubjects.add(subject);
        _subjectSearchController.clear();
        _showSubjectDropdown = false;
        _filteredSubjects = _availableSubjects;
      });
    }
  }

  void _removeSubject(int index) {
    setState(() {
      _selectedSubjects.removeAt(index);
    });
  }

  void _closeSubjectDropdown() {
    setState(() {
      _showSubjectDropdown = false;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Close dropdown when tapping outside
        if (_showSubjectDropdown) {
          _closeSubjectDropdown();
        }
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [Color(0xFF4DD0E1), Color(0xFF7B1FA2)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                // Profile Avatar
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 60, color: Colors.grey),
                ),

                const SizedBox(height: 16),

                // Name Display
                Text(
                  _nameController.text.isEmpty ? 'User' : _nameController.text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                // Form Container
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name Field
                            _buildTextField(
                              controller: _nameController,
                              label: 'Name',
                              hintText: 'Enter name',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Section Field
                            _buildTextField(
                              controller: _sectionController,
                              label: 'Section',
                              hintText: 'Enter section',
                            ),

                            const SizedBox(height: 16),

                            // Email Field
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              hintText: 'Enter email',
                              enabled: false,
                            ),

                            const SizedBox(height: 16),

                            // Roll Number Field
                            _buildTextField(
                              controller: _rollNumberController,
                              label: 'Roll Number',
                              hintText: 'Enter roll number',
                            ),

                            const SizedBox(height: 16),

                            // Subjects Section
                            const Text(
                              'Subjects',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Subject Search Field with Dropdown
                            Container(
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _subjectSearchController,
                                    decoration: InputDecoration(
                                      hintText: 'Enter subject name',
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _showSubjectDropdown = !_showSubjectDropdown;
                                            if (_showSubjectDropdown) {
                                              _filteredSubjects = _availableSubjects;
                                            }
                                          });
                                        },
                                        icon: Icon(
                                          _showSubjectDropdown ? Icons.keyboard_arrow_up : Icons.add,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Colors.grey),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 16,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      _filterSubjects(value);
                                      if (value.isNotEmpty) {
                                        setState(() {
                                          _showSubjectDropdown = true;
                                        });
                                      }
                                    },
                                    onTap: () {
                                      setState(() {
                                        _showSubjectDropdown = true;
                                        _filteredSubjects = _availableSubjects;
                                      });
                                    },
                                  ),

                                  // Subject Dropdown
                                  if (_showSubjectDropdown && _filteredSubjects.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      constraints: const BoxConstraints(maxHeight: 200),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.shade300),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: _filteredSubjects.length,
                                        itemBuilder: (context, index) {
                                          final subject = _filteredSubjects[index];
                                          final isAlreadySelected = _selectedSubjects.any((s) => s['code'] == subject['code']);

                                          return ListTile(
                                            title: Text(
                                              '${subject['name']} (${subject['code']})',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isAlreadySelected ? Colors.grey : Colors.black,
                                              ),
                                            ),
                                            onTap: isAlreadySelected ? null : () => _addSubject(subject),
                                            dense: true,
                                            enabled: !isAlreadySelected,
                                            trailing: isAlreadySelected
                                                ? const Icon(Icons.check, color: Colors.green, size: 20)
                                                : const Icon(Icons.add, color: Colors.blue, size: 20),
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Selected Subjects Display
                            if (_selectedSubjects.isNotEmpty) ...[
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _selectedSubjects.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  Map<String, String> subject = entry.value;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: index == 0 ? Colors.orange : Colors.blue,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          subject['code']!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () => _removeSubject(index),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Phone Number Field
                            _buildTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              hintText: 'Enter phone number',
                              keyboardType: TextInputType.phone,
                            ),

                            const SizedBox(height: 16),

                            // Date of Birth Field
                            const Text(
                              'Date of Birth',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _selectDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _selectedDate != null
                                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                            : 'Select date',
                                        style: TextStyle(
                                          color: _selectedDate != null
                                              ? Colors.black
                                              : Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.calendar_today, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Save Changes Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4DD0E1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Logout Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: _logout,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            fillColor: enabled ? Colors.white : Colors.grey.shade100,
            filled: true,
          ),
        ),
      ],
    );
  }
}