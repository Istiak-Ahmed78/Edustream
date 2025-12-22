import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'video_call_screen.dart';
import 'audio_call_screen.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> _startVideoCall(String channelName) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoCallScreen(channelName: channelName),
      ),
    );
  }

  Future<void> _startAudioCall(String channelName) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AudioCallScreen(channelName: channelName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService().signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Firestore users stream error: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error loading users: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          // Filter out current user from the results
          final filtered = docs.where((d) => d.id != currentUser?.uid).toList();

          if (filtered.isEmpty) {
            return const Center(child: Text('No other users found'));
          }

          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final data = filtered[index].data() as Map<String, dynamic>;
              final uid = filtered[index].id;
              final name = data['name'] ?? 'No name';
              final email = data['email'] ?? '';

              final channelName =
                  // 'call_${currentUser?.uid}_$uid'; // unique channel per pair
                  'Ghost123'; // unique channel per pair

              return ListTile(
                title: Text(name),
                subtitle: Text(email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _startAudioCall(channelName),
                      icon: const Icon(Icons.call),
                    ),
                    IconButton(
                      onPressed: () => _startVideoCall(channelName),
                      icon: const Icon(Icons.videocam),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
