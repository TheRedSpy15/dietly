import 'package:nafp/constants.dart';
import 'package:nafp/log.dart';
import 'package:pocketbase/pocketbase.dart';

class BlogPost {
  String id;
  String title;
  String content;
  String author;
  String created;
  String updated;
  Uri? image;
  String? refUrl;

  BlogPost(
      {required this.id,
      required this.title,
      required this.content,
      required this.author,
      required this.created,
      required this.updated,
      this.image,
      this.refUrl});

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      author: json['author'],
      created: json['created'],
      updated: json['updated'],
      refUrl: json['refUrl'],
    );
  }

  factory BlogPost.fromRecord(RecordModel rec) {
    return BlogPost(
      id: rec.id,
      title: rec.getStringValue('title'),
      content: rec.getStringValue('content'),
      author: rec.getStringValue('author'),
      created: rec.getStringValue('created'),
      updated: rec.getStringValue('updated'),
      image: pb.getFileUrl(rec, rec.getStringValue("image")),
      refUrl: rec.getStringValue('refUrl'),
    );
  }

  Future<List<BlogPost>> getBlogPosts() async {
    final posts = await pb.collection('blog').getList(
          page: 1,
          perPage: 20,
          sort: '-created',
        );
    logger.i(posts);
    return posts.items.map((e) => BlogPost.fromRecord(e)).toList();
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'author': author,
        'created': created,
        'updated': updated,
        'image': image,
        'refUrl': refUrl,
      };
}
