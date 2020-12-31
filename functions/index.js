const functions = require('firebase-functions')
const admin = require('firebase-admin')
// const {chatContact} = require('../lib/homeScreen.dart')
admin.initializeApp()

exports.sendNotification = functions.firestore
  .document('messages/{groupId1}/msgs/{message}')
  .onCreate(async(snap, context)=>{
    console.log('----------------start function--------------------')

    const doc = snap.data()
    console.log(doc)

    const idFrom = doc.author
    const contentMessage = doc.message
    userDoc = await admin
      .firestore()
      .collection('messages')
      .doc(context.params.groupId1)
      .get()
    const idTo = userDoc.data().user1==idFrom?userDoc.data().user2:userDoc.data().user1

    
    // Get push token user to (receive)
    admin
      .firestore()
      .collection('Users')
      .doc(idTo)
      .get()
      .then(userTo => {
          console.log(`Found user to: ${userTo.data().nickname}`)
          if (userTo.data().pushToken && userTo.data().chattingWith !== idFrom) {
            // Get info user from (sent)
                  console.log(`Found user from: ${idFrom}`)
                  const payload = {
                    notification: {
                      title: `You have a message from "${idFrom}"`,
                      body: contentMessage,
                      badge: '1',
                      sound: 'default'
                    }
                  }
                  // Let push to the target device
                  admin
                    .messaging()
                    .sendToDevice(userTo.data().pushToken, payload)
                    .then(response => {
                      console.log('Successfully sent message:', response)
                    })
                    .catch(error => {
                      console.log('Error sending message:', error)
                    })
          } else {
            console.log('Can not find pushToken target user')
          }
      })
    return null
  })