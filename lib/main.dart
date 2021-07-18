import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Friendly Chat", home: InsertName());
  }
}

class ChatScreen extends StatefulWidget {
  ChatScreen({required this.username});
  String username;
  @override
  _ChatScreenState createState() => _ChatScreenState(username: username);
}

class InsertName extends StatefulWidget {
  const InsertName({Key? key}) : super(key: key);

  @override
  _InsertNameState createState() => _InsertNameState();
}

class _InsertNameState extends State<InsertName> {
  final textController = TextEditingController();

  @override
  void _onPressed(String value) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return ChatScreen(username: value);
    }));
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("أقوى مسنجر في الكوكب"),
        ),
        body: Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: [
              Text("Name"),
              Flexible(
                  child: TextField(
                controller: textController,
                onSubmitted: _onPressed,
              )),
              ElevatedButton(
                  onPressed: () => _onPressed(textController.text),
                  child: Text("Enter"))
            ],
          ),
        ));
  }
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // ??

  String username;
  _ChatScreenState({required this.username});

  final IO.Socket socket = IO.io("http://localhost:3000", <String, dynamic>{
    "transports": ["websocket"],
    "autoConnect": false
  });

  @override
  Widget build(BuildContext context) {
    connect();
    return Scaffold(
      appBar: AppBar(
        title: Text("Messanger"),
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
              reverse: true,
              padding: EdgeInsets.all(20),
            ),
          ),
          Divider(
            height: 1,
          ),
          Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer()),
        ],
      ),
    );
  }

  void connect() {
    socket.connect();

    socket.onConnect((data) {
      print("Connected");
      socket.on("message", (data) {
        if (username != data["username"]) {
          _handleIncomingMesssage(data["message"], data["username"]);
        }
      });
    });
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration:
                    InputDecoration.collapsed(hintText: "Send a messsage"),
                focusNode: _focusNode,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 14.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String value) {
    if (value.isNotEmpty) {
      ChatMessage message = ChatMessage(
        text: value,
        animationController: AnimationController(
            duration: const Duration(milliseconds: 700), vsync: this),
        name: username,
        isForMe: true,
      );
      setState(() {
        _messages.insert(0, message);
      });
      _focusNode.requestFocus();
      _textController.clear();
      message.animationController.forward();

      socket
          .emit("sendMessage", {"message": message.text, "username": username});
    }
  }

  void _handleIncomingMesssage(String value, String username) {
    if (value.isNotEmpty) {
      ChatMessage message = ChatMessage(
        text: value,
        animationController: AnimationController(
            duration: const Duration(milliseconds: 700), vsync: this),
        name: username,
        isForMe: false,
      );
      setState(() {
        _messages.insert(0, message);
      });
      _focusNode.requestFocus();
      _textController.clear();
      message.animationController.forward();
    }
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final AnimationController animationController;
  bool isForMe;
  ChatMessage(
      {required this.text,
      required this.animationController,
      required this.name,
      required this.isForMe});

  String name;

  @override
  Widget build(BuildContext context) {
    if (!isForMe) {
      return SizeTransition(
        sizeFactor:
            CurvedAnimation(parent: animationController, curve: Curves.easeOut),
        axisAlignment: 0.0,
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(right: 16.0),
                child: CircleAvatar(
                  child: Text(name[0]),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name),
                  Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: Text(text),
                  )
                ],
              )
            ],
          ),
          margin: EdgeInsets.symmetric(vertical: 10),
        ),
      );
    } else {
      return SizeTransition(
        sizeFactor:
            CurvedAnimation(parent: animationController, curve: Curves.easeOut),
        axisAlignment: 0.0,
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(name),
                  Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: Text(text),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.only(left: 16.0),
                child: CircleAvatar(
                  child: Text(name[0]),
                  backgroundColor: Colors.deepPurple,
                ),
              ),
            ],
          ),
          margin: EdgeInsets.symmetric(vertical: 10),
        ),
      );
    }
  }
}
