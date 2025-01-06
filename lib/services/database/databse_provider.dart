//This provider is used to seperate firestore data handling and the UI of our app

import 'package:flutter/material.dart';

import 'package:blook/models/comment.dart';
import 'package:blook/models/post.dart';
import 'package:blook/models/user.dart';
import 'package:blook/services/auth/auth_service.dart';
import 'package:blook/services/database/database_service.dart';

class DatabaseProvider extends ChangeNotifier {
  final _db = DatabaseService();
  final _auth = AuthService();
  Future<UserProfile?> userProfile(String uid) => _db.getUserFromFirebase(uid);
  Future<void> updateBio(String bio) => _db.updateUserBioFirebase(bio);
  //local list of posts
  List<Post> _allPosts = [];
  //get all posts
  List<Post> get allPosts => _allPosts;
  //post message
  Future<void> postMessage(String message, String? photoUrl) async {
    //post message in firebase
    await _db.postMessageInFireBase(message, photoUrl);
  }

  //fetch all posts
  Future<void> loadAllPosts() async {
    final allPosts = await _db.getAllPostsFromFirebase();
    _allPosts = allPosts;
    initializeLikeMap();
    notifyListeners();
  }

  //filter and return the posts
  List<Post> filterUserPosts(String uid) {
    return _allPosts.where((post) => post.uid == uid).toList();
  }

  //delete post
  Future<void> deletePost(String postId) async {
    await _db.deletePostFromFirebase(postId);
    await loadAllPosts();
  }

  //Likes
  //local map to track like counts for each post
  Map<String, int> _likeCounts = {};

  List<String> _likedPosts = [];

  bool isPostLikedByCurrentUser(String postId) => _likedPosts.contains(postId);

  int getLikeCount(String postId) => _likeCounts[postId] ?? 0;
  void initializeLikeMap() {
    _likeCounts.clear();
    _likedPosts.clear();
    final currentUserID = _auth.getCurrentUid();

    for (var post in _allPosts) {
      _likeCounts[post.id] = post.likeCount;
      if (post.likedBy.contains(currentUserID)) {
        _likedPosts.add(post.id);
      }
    }
    notifyListeners();
  }

  Future<void> toggleLike(String postId) async {
    final likedPostsOrignnal = _likedPosts;
    final likeCountOrignnal = _likeCounts;

    if (_likedPosts.contains(postId)) {
      _likedPosts.remove(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) - 1;
    } else {
      _likedPosts.add(postId);
      _likeCounts[postId] = (_likeCounts[postId] ?? 0) + 1;
    }
    notifyListeners();
    try {
      await _db.toggelLikeInFirebase(postId);
    } catch (e) {
      _likedPosts = likedPostsOrignnal;
      _likeCounts = likeCountOrignnal;
      notifyListeners();
    }
  }

  //local list of comments
  final Map<String, List<Comment>> _comments = {};
  //get comments locally
  List<Comment> getComments(String postId) => _comments[postId] ?? [];
  //fetch comments from a database for a post
  Future<void> loadComments(String postId) async {
    try {
      final allComments =
          await _db.getCommentsFromFirebase(postId) as List<Comment>;
      _comments[postId] = allComments;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
  //add a comment
}