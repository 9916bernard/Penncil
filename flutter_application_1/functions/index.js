const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Scheduled function to delete expired groups every 5 minutes
exports.deleteExpiredGroups = functions.pubsub.schedule('every 5 minutes').onRun(async (context) => {
  const now = admin.firestore.Timestamp.now();
  const expiredGroupsQuery = await admin.firestore().collection('groups').where('expiryTime', '<=', now).get();

  const deletePromises = [];
  expiredGroupsQuery.forEach(doc => {
    deletePromises.push(deleteGroupAndChatroom(doc.id));
  });

  await Promise.all(deletePromises);
  console.log('Deleted expired groups and their chatrooms');
});

async function deleteGroupAndChatroom(groupId) {
  const chatRoomQuery = await admin.firestore().collection('groupChats').where('name', '==', groupId).get();

  const deletePromises = [];
  chatRoomQuery.forEach(chatRoomDoc => {
    deletePromises.push(chatRoomDoc.ref.delete());
  });

  deletePromises.push(admin.firestore().collection('groups').doc(groupId).delete());
  await Promise.all(deletePromises);
}
