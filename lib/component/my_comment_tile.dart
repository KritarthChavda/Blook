import 'package:blook/models/comment.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth/auth_service.dart';
import '../services/database/database_provider.dart';

class MyCommentTile extends StatelessWidget {
  final Comment comment;

  final void Function()? onUserTap;

  const MyCommentTile({
    super.key,
    required this.comment, this.onUserTap,
  });

  void _showOptions(BuildContext context) {
    String currenUid = AuthService().getCurrentUid();
    final bool isOwnComment = comment.uid == currenUid;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              if (isOwnComment)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text("Delete"),
                  onTap: () async {
                    Navigator.pop(context);
                    await Provider.of<DatabaseProvider>(context, listen: false).deleteComment(comment.id, comment.postId);
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User details
          GestureDetector(
            onTap: onUserTap,
            child: Row(
              children: [
                Icon(Icons.person,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                    comment.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '@${comment.username}',
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
                    onTap: () => _showOptions(context),
                  )
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Comment message
          Text(
            comment.message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          // Timestamp
        ],
      ),
    );
  }
}
