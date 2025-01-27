import 'package:blook/component/bottom_nav_bar.dart';
import 'package:blook/component/my_post_alert_box.dart';
import 'package:blook/component/my_post_tile.dart';
import 'package:blook/helper/navigation_pages.dart';
import 'package:blook/models/post.dart';
import 'package:blook/services/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> postMessage(String message, String? photoUrl) async {
    await databaseProvider.postMessage(message, photoUrl);
    await loadAllPosts();
  }

  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  //on Startup
  @override
  void initState() {
    super.initState();
    loadAllPosts();
  }

  //load all posts
  Future<void> loadAllPosts() async {
    await databaseProvider.loadAllPosts();
    setState(() {});
  }

  void _openPostMessageBox() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => MyPostAlertBox(
        textController: textController,
        onPost: (message, photoUrl) async {
          // Call the `postMessage` method
          await postMessage(message, photoUrl);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openPostMessageBox,
        child: Icon(Icons.add),
      ),
      body: _buildPostList(listeningProvider.allPosts),
      bottomNavigationBar: CustomBottomNav(),
    );
  }

  Widget _buildPostList(List<Post> posts) {
    return posts.isEmpty
        ? const Center(
            child: Text("Nothing here..."),
          )
        : ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return MyPostTile(
                post: post,
                onUserTap: () => goUserPage(context, post.uid),
                onPostTap: () => goPostPage(context, post),
              );
            },
          );
  }
}
