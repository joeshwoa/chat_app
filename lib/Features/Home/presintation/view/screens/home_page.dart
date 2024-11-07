import 'package:chat_app/Features/Auth/presintation/view/screens/sign_in_page.dart';
import 'package:chat_app/Features/Chat/presintation/view/screens/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  final bool isAnonymous;

  HomePage({super.key, this.isAnonymous = false});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white,),
            onPressed: () async {
              await _auth.signOut();
              while(Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignInPage()));
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('isAnonymous', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!.docs;
          final currentUserId = _auth.currentUser!.uid;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              // Skip the currently logged-in user
              if (user['uid'] == currentUserId) return const SizedBox.shrink();

              return ListTile(
                title: Text(user['name'], style: const TextStyle(color: Colors.black)),
                onTap: isAnonymous
                    ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Anonymous users CAN NOT chat.')),
                  );
                }
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(userId: user['uid'], userName: user['name']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
