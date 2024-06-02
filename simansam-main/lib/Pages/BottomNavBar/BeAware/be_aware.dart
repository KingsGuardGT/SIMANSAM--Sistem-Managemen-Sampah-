import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:simansam/Pages//consts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:simansam/Models/articles_model.dart';

class BeAware extends StatefulWidget {
  const BeAware({super.key});

  @override
  State<BeAware> createState() => _BeAwareState();
}

class _BeAwareState extends State<BeAware> {
  final Dio dio = Dio();

  List<Article> articles = [];

  @override
  void initState() {
    super.initState();
    _getNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "News",
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return ListTile(
          onTap: () {
            _launchUrl(
              Uri.parse(article.url ?? ""),
            );
          },
          leading: Image.network(
            article.urlToImage ?? PLACEHOLDER_IMAGE_LINK,
            height: 250,
            width: 100,
            fit: BoxFit.cover,
          ),
          title: Text(
            article.title ?? "",
          ),
          subtitle: Text(
            article.publishedAt ?? "",
          ),
        );
      },
    );
  }

  Future<void> _getNews() async {
    final response = await dio.get(
      'https://newsapi.org/v2/everything?country=id&q=sampah&apiKey=${"789a9c334e794ac9ad5bf5d5f003398a"}',
    );
    final articlesJson = response.data["articles"] as List;
    setState(() {
      List<Article> newsArticle =
      articlesJson.map((a) => Article.fromJson(a)).toList();
      newsArticle = newsArticle.where((a) => a.title != "[Removed]").toList();
      articles = newsArticle;
    });
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
