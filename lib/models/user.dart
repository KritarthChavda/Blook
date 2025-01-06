import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String username;
  final String bio;
  final String? photoUrl; // Added photoUrl as an optional field

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.username,
    required this.bio,
    this.photoUrl, // Initialize photoUrl
  });

  // Convert Firestore doc to a UserProfile (Firebase to App)
  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return UserProfile(
      uid: doc['uid'],
      name: doc['name'],
      email: doc['email'],
      username: doc['username'],
      bio: doc['bio'],
      photoUrl: data?['photoUrl'] ?? '', // Fetch photoUrl from Firestore
    );
  }

  // Convert a UserProfile to a Map (App to Firebase)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'username': username,
      'bio': bio,
      'photoUrl': photoUrl, // Include photoUrl in the Map
    };
  }
}
