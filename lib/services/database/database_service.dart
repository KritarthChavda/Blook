// this class handles all the data from and to firebase
import 'package:blook/models/post.dart';
import 'package:blook/models/user.dart';
import 'package:blook/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:blook/models/comment.dart';

class DatabaseService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  //User Profile
  Future<void> saveUserInfoFirebase({required String name, email}) async {
    //get current uid
    String uid = _auth.currentUser!.uid;
    //extract username from email
    String username = email.split('@')[0];
    //create user profile
    UserProfile user = UserProfile(
      uid: uid,
      name: name,
      email: email,
      username: username,
      bio: '',
      photoUrl: '',
    );
    //convert user into map to store it into firebase
    final userMap = user.toMap();
    //save user info to firebase
    await _db.collection("Users").doc(uid).set(userMap);
  }

  //get user info
  Future<UserProfile?> getUserFromFirebase(String uid) async {
    try {
      //retrieve user doc from firebase
      DocumentSnapshot userDoc = await _db.collection("Users").doc(uid).get();
      //convert doc to user profile
      return UserProfile.fromDocument(userDoc);
    } catch (e) {
      print(e);
      return null;
    }
  }

  //update user bio
  Future<void> updateUserBioFirebase(String bio) async {
    //get current uid
    String uid = AuthService().getCurrentUid();
    //update in firebase
    try {
      await _db.collection("Users").doc(uid).update({'bio': bio});
    } catch (e) {
      print(e);
    }
  }

  //Delete user info
  Future<void> deleteUserInfoFromFirebase(String uid) async {
    WriteBatch batch = _db.batch();
    DocumentReference userDoc = _db.collection("Users").doc(uid);
    batch.delete(userDoc);
    QuerySnapshot userPosts =
        await _db.collection("Posts").where('uid', isEqualTo: uid).get();
    for (var post in userPosts.docs) {
      batch.delete(post.reference);
    }
    QuerySnapshot userComments =
        await _db.collection("Comments").where('uid', isEqualTo: uid).get();
    for (var comment in userComments.docs) {
      batch.delete(comment.reference);
    }
    QuerySnapshot allPosts = await _db.collection("Posts").get();
    for (QueryDocumentSnapshot post in allPosts.docs) {
      Map<String, dynamic> postData = post.data() as Map<String, dynamic>;
      var likedBy = postData['likeBy'] as List<dynamic>? ?? [];

      if (likedBy.contains(uid)) {
        batch.update(
          post.reference,
          {
            'likedBy': FieldValue.arrayRemove([uid]),
            'liked': FieldValue.increment(
              -1,
            )
          },
        );
      }
    }

    await batch.commit();
  }

  //Post Message
  Future<void> postMessageInFireBase(String message, String? photoUrl) async {
    try {
      String uid = _auth.currentUser!.uid;
      UserProfile? user = await getUserFromFirebase(uid);

      // Create the Post object with photoUrl
      Post newPost = Post(
        id: '',
        uid: uid,
        name: user!.name,
        username: user.username,
        message: message,
        timestamp: Timestamp.now(),
        likeCount: 0,
        likedBy: [],
        photoUrl: photoUrl, // Include the photoUrl here
      );

      // Convert to map and add to Firestore
      Map<String, dynamic> newPostMap = newPost.toMap();
      await _db.collection("Posts").add(newPostMap);
    } catch (e) {}
  }

  Future<List<Post>> getAllPostsFromFirebase() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection("Posts")
          .orderBy('timestamp', descending: true)
          .get();
      return snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deletePostFromFirebase(String postId) async {
    try {
      await _db.collection("Posts").doc(postId).delete();
    } catch (e) {
      print(e);
    }
  }

  //Likes
  Future<void> toggelLikeInFirebase(String postId) async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentReference postDoc = _db.collection("Posts").doc(postId);
      await _db.runTransaction(
        (transaction) async {
          //get post data
          DocumentSnapshot postSnapShot = await transaction.get(postDoc);
          //get like of users who like this post
          List<String> likedBy =
              List<String>.from(postSnapShot['likedBy'] ?? []);

          //get like count
          int currentLikeCount = postSnapShot['likes'];
          //if user has not liked this post yet -> then like

          if (!likedBy.contains(uid)) {
            likedBy.add(uid);
            currentLikeCount++;
          } else {
            likedBy.remove(uid);
            currentLikeCount--;
          }
          //update in firebase
          transaction.update(
            postDoc,
            {
              'likes': currentLikeCount,
              'likedBy': likedBy,
            },
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  //Comment
  //add a comment to a post
  Future<void> addCommentInFirebase(String postId, message) async {
    try {
      String uid = _auth.currentUser!.uid;
      UserProfile? user = await getUserFromFirebase(uid);

      Comment newComment = Comment(
        id: '',
        postId: postId,
        name: user!.name,
        uid: uid,
        username: user.username,
        message: message,
        timestamp: Timestamp.now(),
        photoUrl: user.photoUrl,
      );

      Map<String, dynamic> newCommentMap = newComment.toMap();
      await _db.collection("Comments").add(newCommentMap);
    } catch (e) {
      print(e);
    }
  }

  //delete a comment from a post
  Future<void> deleteCommentInFirabase(String commentId) async {
    try {
      await _db.collection("Comments").doc(commentId).delete();
    } catch (e) {
      print(e);
    }
  }

  //fetch comments for a post
  Future<List<Comment>> getCommentsFromFirebase(String postId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection("Comments")
          .where("postId", isEqualTo: postId)
          .get();
      return snapshot.docs.map((doc) => Comment.fromDocument(doc)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  //report user
  Future<void> reportUserInFirebase(String postId, userId) async {
    final currentUserId = _auth.currentUser!.uid;
    final report = {
      'reportedBy': currentUserId,
      'messageId': postId,
      'messageOwnerId': userId,
      'timeStamp': FieldValue.serverTimestamp(),
    };
    await _db.collection("Reports").add(report);
  }

  //Block User
  Future<void> blockUserInFirebase(String userId) async {
    final currentUserId = _auth.currentUser!.uid;

    await _db
        .collection("Users")
        .doc(currentUserId)
        .collection("BlockedUsers")
        .doc(userId)
        .set({});
  }

  //Unblock user
  Future<void> unblockUserInFirebase(String blockedUserId) async {
    final currentUserId = _auth.currentUser!.uid;
    await _db
        .collection("Users")
        .doc(currentUserId)
        .collection("BlockedUsers")
        .doc(blockedUserId)
        .delete();
  }

  //Get list of blocked user ids
  Future<List<String>> getBlockedUidsFromFirebase() async {
    final currentUserId = _auth.currentUser!.uid;
    final snapshot = await _db
        .collection("Users")
        .doc(currentUserId)
        .collection("BlockedUsers")
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  //Account stuff

  // report user & post

  //Follow
  //Search
}
