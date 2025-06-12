import 'package:flutter/material.dart';

class SubjectScreen extends StatelessWidget {
  final String subjectName;
  const SubjectScreen({super.key, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(subjectName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Navigate to SubjectNotificationsScreen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification screen to be implemented')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Explore Resources',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1,
                children: [
                  _buildOptionTile(context, 'Assignments', Icons.assignment, Colors.indigo, Colors.indigoAccent),
                  _buildOptionTile(context, 'PYQ', Icons.description, Colors.teal, Colors.tealAccent),
                  _buildOptionTile(context, 'Notes', Icons.note, Colors.purple, Colors.purpleAccent),
                  _buildOptionTile(context, 'Tutorials', Icons.play_circle_fill, Colors.orange, Colors.deepOrangeAccent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, String title, IconData icon, Color startColor, Color endColor) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to corresponding PDF screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title screen to be implemented')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
