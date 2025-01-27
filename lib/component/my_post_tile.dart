import 'package:blook/component/my_input_alert_box.dart';
import 'package:blook/models/post.dart';
import 'package:blook/services/auth/auth_service.dart';
import 'package:blook/services/database/databse_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyPostTile extends StatefulWidget {
  final Post post;
  final void Function()? onUserTap;
  final void Function()? onPostTap;

  const MyPostTile({
    super.key,
    required this.post,
    required this.onUserTap,
    required this.onPostTap,
  });

  @override
  State<MyPostTile> createState() => _MyPostTileState();
}

class _MyPostTileState extends State<MyPostTile> {
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _toggleLikePost() async {
    try {
      await databaseProvider.toggleLike(widget.post.id);
    } catch (e) {
      print(e);
    }
  }

  final _commentController = TextEditingController();

  void _openNewCommentBox() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
        textController: _commentController,
        hintText: "Type a comment..",
        onPressed: () async {
          await _addComment();
        },
        onPressedText: "Post",
      ),
    );
  }

  Future<void> _addComment() async {
    //does nothing if there is nothing in the textfield
    if (_commentController.text.trim().isEmpty) return;
    try {
      await databaseProvider.addComment(
          widget.post.id, _commentController.text.trim());
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadComments() async {
    await databaseProvider.loadComments(widget.post.id);
  }

  void _showOptions() {
    String currenUid = AuthService().getCurrentUid();
    final bool isOwnPost = widget.post.uid == currenUid;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              if (isOwnPost)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text("Delete"),
                  onTap: () async {
                    Navigator.pop(context);
                    await databaseProvider.deletePost(widget.post.id);
                  },
                )
              else ...[
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text("Report"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block),
                  title: const Text("Block"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static const int maxMessageLength = 140;

  @override
  Widget build(BuildContext context) {
    bool likedByCurrentUser =
        listeningProvider.isPostLikedByCurrentUser(widget.post.id);

    int likeCount = listeningProvider.getLikeCount(widget.post.id);

    int commentCount = listeningProvider.getComments(widget.post.id).length;
    final isLongMessage = widget.post.message.length > maxMessageLength;
    final truncatedMessage = isLongMessage
        ? widget.post.message.substring(0, maxMessageLength) + '... '
        : widget.post.message;

    return GestureDetector(
      onTap: widget.onPostTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: widget.onUserTap,
              child: Row(
                children: [
                  Icon(Icons.person,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    widget.post.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '@${widget.post.username}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    child: Icon(
                      Icons.more_horiz_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onTap: () => _showOptions(),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                text: truncatedMessage,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 14,
                ),
                children: isLongMessage
                    ? [
                        TextSpan(
                          text: " Read More",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = widget.onPostTap,
                        ),
                      ]
                    : [],
              ),
            ),
            const SizedBox(height: 10),
            // Display the photo if available
            if (widget.post.photoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  cacheHeight: 600,
                  cacheWidth: 500,
                  widget.post.photoUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                //like button
                SizedBox(
                  width: 60,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _toggleLikePost,
                        child: likedByCurrentUser
                            ? const Icon(
                                Icons.favorite,
                                color: Colors.red,
                              )
                            : Icon(
                                Icons.favorite_border,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        likeCount > 0 ? likeCount.toString() : '',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                //comment button
                Row(
                  children: [
                    GestureDetector(
                      onTap: _openNewCommentBox,
                      child: Icon(
                        Icons.comment,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      commentCount != 0 ? commentCount.toString() : '',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
