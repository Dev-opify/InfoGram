import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Subscribe to avail the premium features',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Benefits
            const ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.green),
              title: Text('Handwritten and teacher-verified solutions of assignments and tutorials'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.green),
              title: Text('24/7 Support'),
            ),
            const SizedBox(height: 30),

            // Subscribe Button
            ElevatedButton(
              onPressed: () {
                // TODO: Implement subscription logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Subscription process to be implemented')),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Subscribe Now',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
