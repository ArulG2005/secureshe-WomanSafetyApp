import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  final List<Map<String, String>> people = [
    {'name': 'Arul G', 'place': 'Trichy'},
    {'name': 'Gobiha JS', 'place': 'Erode'},
    {'name': 'Deva prasath PS', 'place': 'Salem'},
    {'name': 'Bala', 'place': 'Tiruchengode'},
    {'name': 'Anisa', 'place': 'Salem'},
    {'name': 'Sai Shree', 'place': 'Ayothiyapattinam'},
    {'name': 'Dhanush Shankar', 'place': 'kumarapalayam'},
    {'name': 'Aakash', 'place': 'chennai'},
    {'name': 'Devika', 'place': 'Rasipuram'},
    {'name': 'Karthik', 'place': 'Erode'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView.builder(
            itemCount: people.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(people[index]['name']!),
                subtitle: Text(people[index]['place']!),
                leading: Icon(Icons.person),
              );
            },
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Coming Soon"),
                ));
              },
              child: Icon(Icons.help),
            ),
          ),
        ],
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: CommunityScreen(),
    ));
