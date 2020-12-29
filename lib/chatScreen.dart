import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text("Ram",style: TextStyle(color:Color(0xff4ACFAC)),),backgroundColor: Color(0xff262833),),
      body:Container(
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
              Text("hello",style: TextStyle(color:Colors.white),),
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
              // controller: commentTextEditingController,
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
                    onPressed: (){},
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