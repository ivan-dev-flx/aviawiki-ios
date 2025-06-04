// Добавьте этот класс новостей в ваш проект
import 'package:flutter/material.dart';

class NewsItem {
  final int id;
  final String title;
  final String summary;
  final String content;
  final String category;
  final String publishedDate;
  final String source;
  final List<String> tags;

  NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.publishedDate,
    required this.source,
    required this.tags,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'],
      title: json['title'],
      summary: json['summary'],
      content: json['content'],
      category: json['category'],
      publishedDate: json['publishedDate'],
      source: json['source'],
      tags: List<String>.from(json['tags']),
    );
  }
}

// Виджет для карточки новости
class NewsCard extends StatelessWidget {
  final NewsItem news;
  final VoidCallback onTap;

  const NewsCard({
    Key? key,
    required this.news,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFF3A3A3A), width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category and Date Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      news.category.toUpperCase(),
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto Mono',
                      ),
                    ),
                  ),
                  Text(
                    news.publishedDate,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontFamily: 'Roboto Mono',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // Title
              Text(
                news.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto Mono',
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              // Summary
              Text(
                news.summary,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                  fontFamily: 'Roboto Mono',
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              // Tags and Source Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      children: news.tags
                          .take(2)
                          .map((tag) => Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Color(0xFF3A3A3A),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 10,
                                    fontFamily: 'Roboto Mono',
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  Text(
                    news.source,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontFamily: 'Roboto Mono',
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewsDetailScreen extends StatelessWidget {
  final NewsItem news;

  const NewsDetailScreen({Key? key, required this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'NEWS DETAILS',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto Mono',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    news.category.toUpperCase(),
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto Mono',
                    ),
                  ),
                ),
                Text(
                  news.publishedDate,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: 'Roboto Mono',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Title
            Text(
              news.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto Mono',
                height: 1.3,
              ),
            ),
            SizedBox(height: 16),
            // Source
            Text(
              'Source: ${news.source}',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontFamily: 'Roboto Mono',
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 24),
            // Content
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFF3A3A3A)),
              ),
              child: Text(
                news.content,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Roboto Mono',
                  height: 1.6,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Tags
            Text(
              'TAGS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto Mono',
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: news.tags
                  .map((tag) => Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF3A3A3A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[600]!),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 12,
                            fontFamily: 'Roboto Mono',
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// Добавьте эти переменные в _HomeScreenState:
