const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });


exports.onCreateFollower = functions.firestore
.document("/followers/{userId}/usersFollowers/{followerId}")
.onCreate(async (snapshot,context) => {
    console.log("Follower Created",snapshot.id);
    const userId = context.params.userId;
    const followerId = context.params.followerId;
    // get posts
    const followedUserRef = admin
    .firestore()
    .collection("posts")
    .doc(userId)
    .collection("posts");

    const timelinePostsRef = admin
    .firestore()
    .collection("timeline")
    .doc(followerId)
    .collection("timelinePosts");
    
        const querySnapshot = await followedUserPostsRef.get();

        querySnapshot.forEach(doc => {
            if(doc.exists){
                const postId = doc.id;
                const postData = doc.data();
                timelinePostsRef.doc(postId).set(postData);
            }
        });
    }
);