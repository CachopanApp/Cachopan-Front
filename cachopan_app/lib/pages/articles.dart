import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/create_update_article_modal.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_are_you_sure.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/custom_search_field.dart';
import '../api.dart';
import 'dart:convert';
import '../models/article.dart';

class ArticlesPage extends StatefulWidget {
  @override
  _ArticlesPageState createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  List<Article> articles = [];
  bool isLoading = true;
  String? _userId;
  String search = "";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _initKeyValues();
    await _fetchArticles();
  }

  Future<void> _initKeyValues() async {
    final storage = FlutterSecureStorage();
    _userId = await storage.read(key: 'user_id');
  }

  Future<void> _fetchArticles() async {
    if (_userId != null) {
      final response = await ArticleApi.getAllArticles(int.parse(_userId!), search);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            articles = data.map((json) => Article.fromJson(json)).toList();
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  void _onSearch(String query) {
    setState(() {
      search = query.trim();
    });
    _fetchArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Artículos', icon: Icons.article),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CustomSearchBar(onSearch: _onSearch),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 80, top: 10),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(article.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Lote: ${article.lot}', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 18)),
                      Text('Precio: ${article.price} ${article.unit}', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 18)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CreateUpdateArticleModal(article: article);
                                },
                              );
                            },
                            icon: Icon(Icons.update, size: 18),
                            label: Text('Actualizar', style: TextStyle(fontSize: 18)),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AreYouSureModal(
                                    title: 'Eliminar artículo',
                                    content: '¿Estás seguro de que deseas eliminar ${article.name}?',
                                    onConfirm: () async {
                                      final response = await ArticleApi.deleteArticle(article.id);
                                      if (response.statusCode == 204) {
                                        _fetchArticles();
                                      } else {
                                        print('Error');
                                      }
                                    },
                                  );
                                },
                              );
                            },
                            icon: Icon(Icons.delete, size: 18, color: Colors.red),
                            label: Text('Eliminar', style: TextStyle(fontSize: 18, color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomNavigationBar(initialIndex: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return CreateUpdateArticleModal();
            },
          );

          if (result == true) {
            _fetchArticles();
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}