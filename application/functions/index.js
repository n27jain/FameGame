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
    .onCreate(async (snapshot, context) => {
        console.log("Follower Created", snapshot.id);
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

        const querySnapshot = await followedUserRef.get();

        querySnapshot.forEach(doc => {
            if (doc.exists) {
                const postId = doc.id;
                const postData = doc.data();
                timelinePostsRef.doc(postId).set(postData);
            }
        });
    }
    );

exports.onUnFollow = functions.firestore
    .document("/followers/{userId}/usersFollowers/{followerId}")
    .onDelete(async (snapshot, context) => {
        console.log("Follower deleted!", snapshot.id);
        const userId = context.params.userId;
        const followerId = context.params.followerId;

        const timelinePostsRef = admin
            .firestore()
            .collection("timeline")
            .doc(followerId)
            .collection("timelinePosts")
            .where("ownerId", "==", userId);

        const querySnapshot = await timelinePostsRef.get();

        querySnapshot.forEach(doc => {
            if (doc.exists) {
                doc.ref.delete();
            }
        });

    }
    );

// when a post is created, add post to timeline of each follower (of post owner)
exports.onCreatePost = functions.firestore
    .document("/posts/{userId}/posts/{postId}")
    .onCreate(async (snapshot, context) => {
        const postCreated = snapshot.data();
        const userId = context.params.userId;
        const postId = context.params.postId;

        // 1) Get all the followers of the user who made the post
        const userFollowersRef = admin
            .firestore()
            .collection("followers")
            .doc(userId)
            .collection("usersFollowers");

        const querySnapshot = await userFollowersRef.get();
        // 2) Add new post to each follower's timeline
        querySnapshot.forEach(doc => {
            const followerId = doc.id;
            admin
                .firestore()
                .collection("timeline")
                .doc(followerId)
                .collection("timelinePosts")
                .doc(postId)
                .set(postCreated);
        });
    });

exports.onUpdatePost = functions.firestore
    .document("/posts/{userId}/posts/{postId}")
    .onUpdate(async (change, context) => {
        const postUpdated = change.after.data();
        const userId = context.params.userId;
        const postId = context.params.postId;

        // 1) Get all the followers of the user who made the post
        const userFollowersRef = admin
            .firestore()
            .collection("followers")
            .doc(userId)
            .collection("usersFollowers");

        const querySnapshot = await userFollowersRef.get();
        // 2) Update each post in each follower's timeline
        querySnapshot.forEach(doc => {
            const followerId = doc.id;

            admin
                .firestore()
                .collection("timeline")
                .doc(followerId)
                .collection("timelinePosts")
                .doc(postId)
                .get()
                .then(doc => {
                    if (doc.exists) {
                        return doc.ref.update(postUpdated);
                    }
                    else {
                        throw new Error("No docment found when updating the userpost and trying to find it in the timeline");
                    }
                })
                .catch(error => { return error; });
        });
    });

exports.onDeletePost = functions.firestore
    .document("/posts/{userId}/posts/{postId}")
    .onDelete(async (snapshot, context) => {
        const userId = context.params.userId;
        const postId = context.params.postId;

        // 1) Get all the followers of the user who made the post
        const userFollowersRef = admin
            .firestore()
            .collection("followers")
            .doc(userId)
            .collection("usersFollowers");

        const querySnapshot = await userFollowersRef.get();
        // 2) Delete each post in each follower's timeline
        querySnapshot.forEach(doc => {
            const followerId = doc.id;

            admin
                .firestore()
                .collection("timeline")
                .doc(followerId)
                .collection("timelinePosts")
                .doc(postId)
                .get()
                .then(doc => {
                    if (doc.exists) {
                        return doc.ref.delete();
                    }
                    else {
                        throw new Error("No docment found when deleteing the userpost and trying to find it in the timeline")
                    }
                })
                .catch(error => { return error; });
        });
    });

    exports.onCreateActivityFeedItem = functions.firestore.document("/feed/{userId}/feedItems/{activityFeedItem}")
    .onCreate(async (snapshot, context) => {
        console.log("FeedItemCreated", snapshot.data());

        //connect user to feed
        const userId = context.params.userId;
        const userRef = admin.firestore().doc(`users/${userId}`);
        const doc = await userRef.get();

        //check for notification token
        const androidNotificationToken = doc.data().androidNotificationToken; 

        if(androidNotificationToken){
            sendNotification(androidNotificationToken, snapshot.data());
        }
        else{
            console.log("No token for user, cannot send notification");
        }

        function sendNotification(androidNotificationToken,
            activityFeedItem){
                let body;
                switch (activityFeedItem.type) {
                    case "comment":
                        body = `${activityFeedItem.username} replied: ${activityFeedItem.commentData}`;
                        break;
                    case "like":
                        body = `${activityFeedItem.username} liked your post!`;
                        break;
                    case "follow":
                        body = `${activityFeedItem.username} started following you!`;
                        break;
                    default:
                        break;
                }
                const message = {
                    notification: { body },
                    token: androidNotificationToken,
                    data: { recipient: userId },
                };
                admin
                .messaging
                .send(message)
                .then(response => 
                    {
                        return console.log("SUCCESS: Message Sent!", response);
                    }
                )
                .catch(error => {
                    return console.log("FAILURE: Error found in sending message!", error);
                });
        }

    });
