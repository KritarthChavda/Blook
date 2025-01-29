import 'package:blook/models/post.dart';
import 'package:blook/pages/post_page.dart';
import 'package:blook/pages/profile_page.dart';
import 'package:flutter/material.dart';

import '../pages/account_settings_page.dart';
import '../pages/blocked_user_page.dart';

void goUserPage(BuildContext context, String uid) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ProfilePage(uid: uid),)
  );
}
void goPostPage(BuildContext context, Post post) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PostPage(post: post,),)
  );
}
void goToBlockedUserPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => BlockedUserPage(),)
  );
}

void goAccountSettingsPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => AccountSettingsPage(),)
  );
}
