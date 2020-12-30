import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/loginScreen.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final CollectionReference messageCollection = FirebaseFirestore.instance.collection("messages");

class ChatScreen extends StatefulWidget {
  String phone,name;

  ChatScreen({this.phone,this.name}){
    phone = phone.replaceAll(" ", "");
    phone = phone.replaceAll("+91", ""); 
  }

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String currNumber = user.phoneNumber.replaceAll("+91", "");
  String chatId;
  TextEditingController chatController = new TextEditingController();

  @override
  void initState(){
    super.initState();
    getChatId();
  }

  void getChatId()async{
    final doc = await userCollection.doc(currNumber).collection("friends").doc(widget.phone).get();
    if(doc.exists){
      setState(() {
        chatId = doc.data()["chatId"];
      });
    }else{
      final msgdoc = await messageCollection.add({
        "user1":currNumber,
        "user2":widget.phone
      });
      setState(() {
        chatId = msgdoc.id;
      });
      userCollection.doc(currNumber).collection("friends").doc(widget.phone).set({
        "chatId":msgdoc.id
      });
      userCollection.doc(widget.phone).collection("friends").doc(currNumber).set({
        "chatId":msgdoc.id
      });
    }
  }

  void sendMessage(){
    String chat = chatController.text.trim();
    if(chat.isNotEmpty){
      final DateTime now = DateTime.now();
      final DateFormat formatter = DateFormat('dd-MM-yyyy');
      final String formatted = formatter.format(now);
      messageCollection.doc(chatId).collection("msgs").add({
        "message":chat,
        "author":user.phoneNumber,
        "date":formatted,
        "timeStamp":now.microsecondsSinceEpoch
      });
      chatController.clear();
    }
  }

  showChat(){
    return StreamBuilder(
      stream: messageCollection.doc(chatId).collection("msgs").orderBy("timeStamp").snapshots(),
      builder: (context,snapshot){
          List<Bubble> msgs=[];
          if(snapshot.hasData){
            if(snapshot.data.docs.isEmpty){
              return Text("");
            }
            msgs.add(
              Bubble(
                margin: BubbleEdges.only(top: 10,left:50),
                alignment:(snapshot.data.docs[0].data()["author"]==user.phoneNumber)? Alignment.topRight:Alignment.topLeft,
                nip:(snapshot.data.docs[0].data()["author"]==user.phoneNumber)?  BubbleNip.rightTop:BubbleNip.leftTop,
                color: (snapshot.data.docs[0].data()["author"]==user.phoneNumber)?Color(0xff23836a): Color(0xff464a5e) ,
                child: 
                  Text(
                    snapshot.data.docs[0].data()["message"],
                    style:TextStyle(
                        fontSize: 16,
                        color:Colors.white,
                    )
                  ),
              ),
            );
            for(int i=1;i<snapshot.data.docs.length;i++){
                msgs.add(
                Bubble(
                  margin: (snapshot.data.docs[i].data()["author"]==snapshot.data.docs[i-1].data()["author"])?BubbleEdges.only(top: 2,left:50):BubbleEdges.only(top: 10,left:50),
                  alignment:(snapshot.data.docs[i].data()["author"]==user.phoneNumber)? Alignment.topRight:Alignment.topLeft,
                  nip:(snapshot.data.docs[i].data()["author"]==snapshot.data.docs[i-1].data()["author"])?BubbleNip.no: (snapshot.data.docs[i].data()["author"]==user.phoneNumber)?  BubbleNip.rightTop:BubbleNip.leftTop,
                  color: (snapshot.data.docs[i].data()["author"]==user.phoneNumber)?Color(0xff23836a): Color(0xff464a5e) ,
                  child: 
                    Text(
                      snapshot.data.docs[i].data()["message"], 
                      style:TextStyle(
                          fontSize: 16,
                          color:Colors.white,
                      )
                    ),
                ),
              );
            }
            return Column(
              children: msgs,
            );
          }else{
            return Text("Waiting");
          }
      },
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title:Text(widget.name,style: TextStyle(color:Color(0xff4ACFAC)),),backgroundColor: Color(0xff262833),),
      body:chatId==null?Loading():Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("./assets/bg.jpg"),
            fit: BoxFit.cover
          )
        ),
        child: Stack(
        children: [
          ListView(
            children: [
              showChat(),
              SizedBox(height:70)
            ],
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: TextFormField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              controller: chatController,
              autofocus: false,
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white,fontSize: 17),
              decoration: InputDecoration(
                isDense: true,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(40.0)),
                    borderSide: BorderSide(
                      color: Color(0xff262833)
                    )
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(35.0),
                    borderSide: BorderSide(
                      color: Color(0xff262833)
                    )
                ),
                hintText: "Type Something Here.",
                filled: true,
                fillColor: Color(0xff262833),
                focusColor: Color(0xff262833),
                hintStyle: TextStyle(color:Colors.white54),
                prefixIcon: IconButton(
                  onPressed:(){},
                  icon:Icon(
                    Icons.emoji_emotions,
                    color: Colors.white38,
                  )
                ),
                suffixIcon: IconButton(
                    onPressed: sendMessage,
                    icon: Icon(
                      Icons.send,
                      color: Color(0xff4ACFAC),
                    )),
              ),
            )
          )
        ],
    ),
      ));
  }
}