import 'package:blook/component/my_comment_tile.dart';
import 'package:blook/component/my_input_alert_box.dart';
import 'package:blook/helper/navigation_pages.dart';
import 'package:blook/models/post.dart';
import 'package:blook/services/auth/auth_service.dart';
import 'package:blook/services/database/databse_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostPage extends StatefulWidget {
  final Post post;
  const PostPage({super.key, required this.post});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

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
            ));
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

  @override
  Widget build(BuildContext context) {
    bool likedByCurrentUser =
        listeningProvider.isPostLikedByCurrentUser(widget.post.id);
    int likeCount = listeningProvider.getLikeCount(widget.post.id);
    int commentCount = listeningProvider.getComments(widget.post.id).length;
    final allComments = listeningProvider.getComments(widget.post.id);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Post"),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                const SizedBox(height: 20),
                Text(
                  widget.post.message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                if (widget.post.photoUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
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
                                    color:
                                        Theme.of(context).colorScheme.primary,
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
          //comments on this Post
          allComments.isEmpty
              ? Center(
                  child: Text("No comments yet..."),
                )
              : ListView.builder(
                  itemCount: allComments.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final comment = allComments[index];

                    return MyCommentTile(
                      comment: comment,
                      onUserTap: () => goUserPage(context, comment.uid),
                    );
                  },
                )
        ],
      ),
    );
  }
}
