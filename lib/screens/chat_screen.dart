import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController(); //Controller for the text input field
  final FirebaseAuth _auth = FirebaseAuth.instance; //Firebase Authentication instance
  User? _user; // Holds the current authenticated user
  
  //Default email and password for testing (login doesn't work)
  //Will be removed if login is fixed
  final String _defaultEmail = 'testuser@example.com';
  final String _defaultPassword = 'password123';

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((user) {
      setState(() {
        _user = user; // Set the current user when auth state changes
      });

      //Will be removed if login is fixed
      if (_user == null) {
        _loginWithDefaults(); // Proper function call
      }
    });
  }

  //Will remove
  Future<void> _loginWithDefaults() async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: _defaultEmail, password: _defaultPassword);
    } catch (error) {
      //Handle any errors during sign-in
      print('Error signing in: $error');
    }
  }

  void _sendMessage() async {

String avatarUrl = 'lib/assets/mickeymouse.png'; //Mickey Mouse png

    if (_controller.text.trim().isEmpty) return; //Ensure text isn't empty
    FocusScope.of(context).unfocus(); //Close the keyboard after sending a message

    //Add a new message to Firestore collection
    FirebaseFirestore.instance.collection('chats').add({
      'text': _controller.text,
      'createdAt': Timestamp.now(),
      'userId': _user?.uid, // Associate message with current user
      'username': _user?.email ?? 'Mickey Mouse', // Add username for display purposes
      'avatarUrl': avatarUrl,
    });

    _controller.clear(); // Clear the text input after sending the message
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Extremely Simple Chat App'), //Title for the app bar
        actions: [
          IconButton(
            icon: Icon(Icons.logout), //Logout button icon
            onPressed: () {
              _auth.signOut(); //Signs the user out of Firebase
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(

              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .orderBy('createdAt', descending: true)
                  .snapshots(), //Stream of messages ordered by timestamp

              builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {

                if (chatSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); //Show loading spinner while fetching messages
                }

                final chatDocs = chatSnapshot.data!.docs; //List of chat documents

                return ListView.builder(
                  reverse: true, //Start from the latest message
                  itemCount: chatDocs.length,
                  itemBuilder: (ctx, index) => MessageBubble(
                    chatDocs[index]['text'],
                    chatDocs[index]['username'],
                    chatDocs[index]['userId'] == _user?.uid, //Check if the message is from the current user
                    chatDocs[index]['avatarUrl'] ?? 'https://img.pokemondb.net/sprites/silver/normal/pikachu.png',
                    key: ValueKey(chatDocs[index].id),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller, // Controller for the input text
                    decoration: const InputDecoration(labelText: 'Send a message...'), // Placeholder text for the input
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send), //Send message button icon
                  onPressed: _sendMessage, //Function to send the message
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {

  final String message;
  final String username;
  final bool isMe;
  final String avatarUrl; //Adding an avatar URL

  MessageBubble(this.message, this.username, this.isMe, this.avatarUrl, {required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start, //Align messages based on sender
      children: [
         CircleAvatar(
        backgroundImage: AssetImage(avatarUrl), // Load avatar from assets
        radius: 20,
        ),
        Container(
          decoration: BoxDecoration(
            color: isMe ? Colors.grey[300] : Colors.blue[300], //Different background color for messages from the user
            borderRadius: BorderRadius.circular(12),
          ),
          width: 140,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16), //Padding inside the message bubble
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8), //Margin outside the message bubble
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, //Align text within the bubble
            children: [
              Text(
                username,
                style: const TextStyle(fontWeight: FontWeight.bold), //Bold text for username
              ),
              Text(
                message,
                style: const TextStyle(color: Colors.black), //Message text color
              ),
            ],
          ),
        ),
      ],
    );
  }
}