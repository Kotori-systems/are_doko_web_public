import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {Notification, getMessaging} from "firebase-admin/messaging";

const topic = "notice";

admin.initializeApp();

export const subscribeToNotice = functions.firestore
  .document("notification/{notificationId}")
  .onCreate(async (snapshot: admin.firestore.DocumentSnapshot) => {
    const data = snapshot.data();
    if (data) {
      const token = snapshot.id;
      await getMessaging().subscribeToTopic(token, topic)
        .then((response: admin.messaging.MessagingTopicManagementResponse) => {
          console.log("Successfully subscribed to topic:", response);
        })
        .catch((error) => {
          console.log("Error subscribing to topic:", error);
        });
    }
  });

export const unsubscribeToNotice = functions.firestore
  .document("notification/{notificationId}")
  .onDelete(async (snapshot: admin.firestore.DocumentSnapshot) => {
    // Unsubscribe the devices corresponding to the registration tokens from
    // the topic.
    const data = snapshot.data();
    if (data) {
      const token = snapshot.id;
      getMessaging().unsubscribeFromTopic(token, topic)
        .then((response) => {
          // See the MessagingTopicManagementResponse reference documentation
          // for the contents of response.
          console.log("Successfully unsubscribed from topic:", response);
        })
        .catch((error) => {
          console.log("Error unsubscribing from topic:", error);
        });
    }
  });

export const onAddItem = functions.firestore
  .document("items/{itemId}")
  .onCreate(async (snapshot: admin.firestore.DocumentSnapshot) => {
    const data = snapshot.data();
    if (data) {
      const document = {
        name: data.name,
        category: data.category,
        location_category: data.location_category,
      };
      const serializedDocument = JSON.stringify(document);
      const notification: Notification = {
        title: "ドキュメントが追加されました。",
        body: serializedDocument,
      };

      // 通知するユーザーのトークン一覧を取得します。
      const notificationSnapshot = await admin.firestore()
        .collection("notification").get();
      const tokens = notificationSnapshot.docs.map((doc) => doc.id);
      for (const token of tokens) {
        // 通知を送信します。
        await sendNotification(token, notification);
      }
    }
  });

// Define a function that triggers on document update events.
export const onUpdateItem = functions.firestore
  .document("items/{itemId}")
  .onUpdate(async (change) => {
    const data = change.after.data();
    const document = {
      name: data.name,
      category: data.category,
      location_category: data.location_category,
    };
    const serializedDocument = JSON.stringify(document);
    const notification: Notification = {
      title: "ドキュメントが更新されました。",
      body: serializedDocument,
    };

    // 通知するユーザーのトークン一覧を取得します。
    const notificationSnapshot = await admin.firestore()
      .collection("notification").get();
    const tokens = notificationSnapshot.docs.map((doc) => doc.id);

    for (const token of tokens) {
      // 通知を送信します。
      await sendNotification(token, notification);
    }
  });

// 通知を送信する関数を定義します。
export const sendNotification = async function(
  token: string,
  notification: Notification,
): Promise<void> {
  // FCMのクライアントを生成します。
  const fcm = admin.messaging();

  // 通知を送信します。
  await fcm.send({
    token: token,
    notification: notification,
  }).then((response) => {
    // Response is a message ID string.
    console.log("Successfully sent message:", response);
  })
    .catch((error) => {
      console.log("Error sending message:", error);
    });
};
