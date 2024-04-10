import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nafp/log.dart';
import 'package:nafp/screens/feed/post.dart';

import '../../providers/providers.dart';

class Feed extends ConsumerWidget {
  const Feed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedProvider);

    return Scaffold(
        appBar: AppBar(title: const Text('Health Updates')),
        body: Center(
            child: feed.when(
                data: (data) {
                  if (data.isNotEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        return ref.invalidate(feedProvider);
                      },
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final e = data[index];
                          return InkWell(
                            onTap: () {
                              context.pushNamed("post", extra: e);
                            },
                            child: Hero(
                              tag: e.id,
                              child: BlogPostCard(blogPost: e, expanded: false),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return const Text('No posts found');
                  }
                },
                error: (o, e) {
                  logger.e("Error: $o");
                  logger.e("Error: $e");
                  return const Text('some error here');
                },
                loading: () => const CircularProgressIndicator())));
  }
}
