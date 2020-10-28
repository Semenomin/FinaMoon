import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:finamoonproject/widgets/chat_message.dart';
import 'package:finamoonproject/model/language.dart' as lang;

const languages = const [
  const lang.Language('Francais', 'fr_FR'),
  const lang.Language('English', 'en_US'),
  const lang.Language('Pусский', 'ru_RU'),
  const lang.Language('Italiano', 'it_IT'),
  const lang.Language('Español', 'es_ES'),
];

class HomePageDialogflow extends StatefulWidget {
  HomePageDialogflow({Key key}) : super(key: key);

  @override
  _HomePageDialogflow createState() => _HomePageDialogflow();
}

class _HomePageDialogflow extends State<HomePageDialogflow> {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = TextEditingController();
  Color col = Colors.white;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(51, 51, 51, 100),
      body: Column(children: <Widget>[
        Flexible(
            child: ListView.builder(
          padding: EdgeInsets.all(8.0),
          reverse: true,
          itemBuilder: (_, int index) => _messages[index],
          itemCount: _messages.length,
        )),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
                color: Color.fromRGBO(102, 171, 0, 100),
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: _buildTextComposer(),
          ),
        ),
      ]),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Colors.white),
      child: Container(
        margin: const EdgeInsets.only(left: 20.0, right: 10),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                style: TextStyle(color: Colors.white),
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration:
                    InputDecoration.collapsed(hintText: "Send a message"),
                cursorColor: Colors.white,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                children: [
                  buildSendMessageButton(),
                  buildMicrophoneButton(),
                  buildUploadFileButton()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconButton buildSendMessageButton() {
    return IconButton(
        icon: Icon(Icons.send),
        onPressed: () => _handleSubmitted(_textController.text));
  }

  IconButton buildUploadFileButton() {
    return IconButton(
      icon: Icon(Icons.file_upload),
      onPressed: () {}, //TODO UPLOADFILE
    );
  }

  GestureDetector buildMicrophoneButton() {
    return GestureDetector(
      child: Container(
        child: Icon(
          Icons.mic_sharp,
          color: col,
        ),
        padding: EdgeInsets.all(10),
      ),
      onLongPressStart: (_) {
        setState(() {
          col = Colors.black;
        });
      },
      onLongPress: () {}, //TODO STARTRECORD
      onLongPressEnd: (_) {
        setState(() {
          col = Colors.white;
          //TODO voice recognize
        });
      },
    );
  }

  void response(query) async {
    _textController.clear();
    AuthGoogle authGoogle =
        await AuthGoogle(fileJson: "assets/FinaMoon-7e886f3862f3.json").build();
    Dialogflow dialogflow =
        Dialogflow(authGoogle: authGoogle, language: Language.english);
    AIResponse response = await dialogflow.detectIntent(query);
    ChatMessage message = ChatMessage(
      text: response.getMessage() ??
          CardDialogflow(response.getListMessage()[0]).title,
      type: false,
    );
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    ChatMessage message = ChatMessage(
      text: text,
      type: true,
    );
    setState(() {
      _messages.insert(0, message);
    });
    response(text);
  }
}
