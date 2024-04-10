import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nafp/models/pocketbase/blogpost.dart';

class BlogPostCard extends ConsumerWidget {
  final BlogPost blogPost;
  bool expanded = false;

  BlogPostCard({super.key, required this.blogPost, this.expanded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CachedNetworkImage(
            imageUrl: blogPost.image.toString(),
            fit: BoxFit.fitWidth,
            errorWidget: (context, url, error) => const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  blogPost.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  blogPost.created,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                if (expanded)
                  MarkdownBody(
                    data: blogPost.content,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Post extends ConsumerWidget {
  final BlogPost post;
  const Post({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
          title: Text(post.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          )),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 75.0),
          child: Column(
            children: [
              Hero(
                tag: post.id,
                child: BlogPostCard(blogPost: post, expanded: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
