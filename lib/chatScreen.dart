import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/loginScreen.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:linkable/linkable.dart';
import 'dart:async';


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
  bool onBottom = true;
  TextEditingController chatController = new TextEditingController();
  
  ScrollController _controller;
  @override
  void initState(){
    _controller = ScrollController();
    super.initState();
    getChatId();
  }

   @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void getChatId()async{
    userCollection
          .doc(currNumber)
          .update({'chattingWith': widget.phone});
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
        "author":currNumber,
        "date":formatted,
        "timeStamp":now.microsecondsSinceEpoch
      });
      chatController.clear();
      scrollDown();
    }
  }

  List<String> months = ["January","February","March","April","May","June","July","August","September","October","November","December"];

  String getAccDate(DateTime checkingDate){
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year,now.month,now.day);
    DateTime yesterday = DateTime(now.year,now.month,now.day-1);
    if(checkingDate==today){
      return "TODAY";
    }else if(checkingDate==yesterday){
      return "YESTERDAY";
    }else{
      return "${checkingDate.day} ${months[checkingDate.month-1].toUpperCase()}  ${checkingDate.year}";
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
            DateTime date= DateTime.fromMicrosecondsSinceEpoch(snapshot.data.docs[0].data()["timeStamp"]);
            msgs.add(
              Bubble(
                alignment: Alignment.center,
                color:  Color(0xff262833),
                child: Text(getAccDate(DateTime(date.year,date.month,date.day)), textAlign: TextAlign.center, style: TextStyle(fontSize: 11.0,color:Colors.white70)),
              ),
            );
            msgs.add(
              Bubble(
                margin: (snapshot.data.docs[0].data()["author"]==currNumber)?BubbleEdges.only(top: 10,left:50):BubbleEdges.only(top: 10,right:50),
                alignment:(snapshot.data.docs[0].data()["author"]==currNumber)? Alignment.topRight:Alignment.topLeft,
                nip:(snapshot.data.docs[0].data()["author"]==currNumber)?  BubbleNip.rightTop:BubbleNip.leftTop,
                color: (snapshot.data.docs[0].data()["author"]==currNumber)?Color(0xff23836a): Color(0xff464a5e) ,
                child: 
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children:[
                      Linkable(
                        text:snapshot.data.docs[0].data()["message"],
                        textColor:Colors.white,
                        style:TextStyle(
                            fontSize: 16,
                            color:Colors.white,
                        )
                      ),
                      SizedBox(width:5),
                      Padding(
                        padding: const EdgeInsets.only(top:8.0),
                        child: Text(
                          new DateFormat.jm().format(date),
                          style:TextStyle(fontSize:10,color:Colors.white70),
                        ),
                      )
                    ]
                  )
              ),
            );
            for(int i=1;i<snapshot.data.docs.length;i++){
              date= DateTime.fromMicrosecondsSinceEpoch(snapshot.data.docs[i-1].data()["timeStamp"]);
              DateTime premsgdate = new DateTime(date.year,date.month,date.day); 
              date= DateTime.fromMicrosecondsSinceEpoch(snapshot.data.docs[i].data()["timeStamp"]);
              DateTime thismsgdate = new DateTime(date.year,date.month,date.day);
              if(premsgdate!=thismsgdate){
                msgs.add(
                  Bubble(
                    alignment: Alignment.center,
                    color:  Color(0xff262833),
                    child: Text(getAccDate(thismsgdate), textAlign: TextAlign.center, style: TextStyle(fontSize: 11.0,color:Colors.white70)),
                  ),
                );
              }
                msgs.add(
                Bubble(
                  margin: (snapshot.data.docs[i].data()["author"]==snapshot.data.docs[i-1].data()["author"] && premsgdate==thismsgdate)?
                  (snapshot.data.docs[i].data()["author"]==currNumber)?BubbleEdges.only(top: 2,left:50):BubbleEdges.only(top: 2,right:50)
                  :
                   (snapshot.data.docs[i].data()["author"]==currNumber)?BubbleEdges.only(top: 10,left:50):BubbleEdges.only(top: 10,right:50),
                  alignment:(snapshot.data.docs[i].data()["author"]==currNumber )? Alignment.topRight:Alignment.topLeft,
                  nip:(snapshot.data.docs[i].data()["author"]==snapshot.data.docs[i-1].data()["author"]  && premsgdate==thismsgdate)?BubbleNip.no: (snapshot.data.docs[i].data()["author"]==currNumber)?  BubbleNip.rightTop:BubbleNip.leftTop,
                  color: (snapshot.data.docs[i].data()["author"]==currNumber)?Color(0xff23836a): Color(0xff464a5e) ,
                  child: 
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children:[
                        Linkable(
                          text:snapshot.data.docs[i].data()["message"],
                          textColor:Colors.white,
                          style:TextStyle(
                              fontSize: 16,
                              color:Colors.white,
                          )
                        ),
                        SizedBox(width:5),
                        Padding(
                          padding: const EdgeInsets.only(top:8.0),
                          child: Text(
                            new DateFormat.jm().format(date),
                            style:TextStyle(fontSize:10,color:Colors.white70),
                          ),
                        )
                      ]
                  )
                ),
              );
            }
            return Column(
              children: msgs,
            );
          }else{
            return Text("Waiting...");
          }
      },
    );
  }

  Future<bool> onBackPress() {
    
      userCollection
          .doc(currNumber)
          .update({'chattingWith': null});
      Navigator.pop(context);
    return Future.value(false);
  }

  void scrollDown(){
    _controller.animateTo(
      _controller.position.minScrollExtent, 
      duration:Duration(milliseconds: 250), 
      curve: Curves.easeInOut
    );
  }

  @override
  Widget build(BuildContext context){
    return WillPopScope(
      child: Scaffold(
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
            NotificationListener(
              child: ListView(
                children: [
                  SizedBox(height:70),
                  showChat(),
                ],
                reverse: true,
                controller: _controller,
              ),
              onNotification: (t){
                if (t is ScrollEndNotification) {
                  bool tem = _controller.position.pixels==_controller.position.minScrollExtent;
                  if(tem!=onBottom){
                    setState(() {
                      onBottom = tem;
                    });
                  }
                }
              },
            ),
            onBottom?Text(""):Positioned(
              child: GestureDetector(
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor:  Color(0xff262833),
                  backgroundImage: AssetImage("./assets/arrow.png"),
                  // child: Text("v",style:TextStyle(color:Colors.white)),
                ),
                onTap: scrollDown,
              ),
              right: 10,
              bottom: 80,
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
      ),),
      onWillPop: onBackPress,
    );
  }
}