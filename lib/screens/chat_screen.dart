import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;

  FirebaseUser loggedUser;
  String message;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  //Get method
  void getMessages() async {
    var messages = await _firestore.collection('messages').getDocuments();
    for (var message in messages.documents) {
      print(message.data);
    }
  }

  //Get QuerySnapshotstream
  void getSnapshotStream() async {
    await for (var snapshots in _firestore.collection('messages').snapshots()) {
      for (var message in snapshots.documents) {
        print(message.data);
      }
    }
  }

  // Get currentUser
  void getCurrentUser() async {
    final user = await _auth.currentUser();
    try {
      if (user != null) {
        loggedUser = user;
        print(user);
      }
    } catch (e) {
      print('error in chat screen $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //logout functionality
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // StreamBuilder<QuerySnapshot>(
            //     stream: _firestore.collection('messages').snapshots(),
            //     builder: (context, snapshot) {
            //       if (snapshot.hasData) {
            //         final messages = snapshot.data.documents;
            //         List<Text> messageWidgets = [];
            //         for (var message in messages) {
            //           final messageText = message.data['text'];
            //           final sender = message.data['sender'];
            //           final messageWidget = Text('$messageText from $sender');
            //           messageWidgets.add(messageWidget);
            //         }
            //         return Column(
            //           children: messageWidgets,
            //         );
            //       }
            //     }),
            //re written
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('messages').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                    backgroundColor: Colors.deepPurple,
                  ));
                }
                final messages = snapshot.data.documents;
                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  final sender = message.data['sender'];
                  final messageText = message.data['text'];
                  final messageWidget =
                      BubbleMessage(sender: sender, text: messageText);
                  messageWidgets.add(messageWidget);
                }
                return Expanded(
                    child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 20.0,
                  ),
                  children: messageWidgets,
                ));
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        //User message
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //send functionality
                      _firestore
                          .collection('messages')
                          .add({'Text': message, 'Sender': loggedUser.email});
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BubbleMessage extends StatelessWidget {
  BubbleMessage({this.text, this.sender});
  final String text, sender;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(fontSize: 10.0, color: Colors.black38),
          ),
          Material(
              borderRadius: BorderRadius.circular(30.0),
              elevation: 5.0,
              color: Colors.blueAccent,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.white,
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
