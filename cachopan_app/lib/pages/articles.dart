import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import '../utils.dart';
import '../widgets/create_update_article_modal.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_are_you_sure.dart';
import '../widgets/error_modal.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/custom_search_field.dart';
import '../api.dart';
import 'dart:convert';
import '../models/article.dart';
import '../date_provider.dart'; // Import the DateProvider class
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:printing/printing.dart';
import 'dart:async';

class ArticlesPage extends StatefulWidget {
  @override
  _ArticlesPageState createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
  final DateFormat _dateFormatSearch = DateFormat('yyyy-MM-dd');
  List<Article> articles = [];
  bool isLoading = true;
  String? _userId;
  String search = "";
  Timer? _debounce;

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
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    if (_userId != null) {
      final response = await ArticleApi.getAllArticles(int.parse(_userId!), search, _dateFormatSearch.format(dateProvider.selectedDate));
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
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        search = query.trim();
      });
      _fetchArticles();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('es', 'ES'),
      initialDate: dateProvider.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != dateProvider.selectedDate) {
      dateProvider.setDate(picked);
      _fetchArticles();
    }
  }

  Future<pw.ImageProvider> imageFromAssetBundle(String path) async {
    final byteData = await rootBundle.load(path);
    final image = img.decodeImage(byteData.buffer.asUint8List())!;
    final resizedImage = img.copyResize(image, width: 100, height: 100); // Resize the image
    return pw.MemoryImage(img.encodePng(resizedImage));
  }

  void _onConvertToPdf() async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final pdf = pw.Document();
    final image = await imageFromAssetBundle('assets/images/Cachopan_logo.webp');

    pdf.addPage(
      pw.MultiPage(
        header: (pw.Context context) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Cachopan App', style: pw.TextStyle(fontSize: 18)),
              pw.Image(image, width: 100, height: 100),
            ],
          );
        },
        build: (pw.Context context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 20),
              pw.Text('Pescado del día ${_dateFormat.format(dateProvider.selectedDate)}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.ListView.builder(
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(
                        '${index + 1}. ${article.name} ( ${article.price} euros / ${article.unit} )',
                        style: pw.TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(title: 'Artículos', icon: Icons.inventory),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ElevatedButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: Icon(Icons.calendar_today, color: Colors.white),
                    label: Text('Seleccionar Fecha', style: TextStyle(fontSize: 20, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      elevation: 5,
                      shadowColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(150, 60),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: principal_color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _dateFormat.format(dateProvider.selectedDate),
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: CustomSearchBar(
                  onSearch: _onSearch,
                  hintText: 'Buscar artículo ...',
                ),
              ),
              const SizedBox(width: 10), // Espaciado entre el buscador y el botón
              Padding(
                padding: const EdgeInsets.only(right: 40),
                child: ElevatedButton.icon(
                  onPressed: _onConvertToPdf,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20), // Increase the height of the button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.grey, // Ensure the background color is set
                  ),
                  icon: Icon(Icons.picture_as_pdf, color: Colors.white), // Add PDF icon
                  label: Text(
                    "Pasar a PDF",
                    style: TextStyle(fontSize: 16, color: Colors.white), // Ensure the text color is set to white
                  ),
                ),
              ),
            ],
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
                      Text( article.lot != '' ? 'Lote: ${article.lot}' : 'Lote: Pendiente', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20)),
                      Text('Precio: ${article.price} €/${article.unit}', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CreateUpdateArticleModal(article: article, formattedDate: _dateFormat.format(dateProvider.selectedDate));
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
                                        // Error modal
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ErrorModal(
                                              title: 'Error',
                                              message: 'Error al eliminar el artículo',
                                            );
                                          },
                                        );
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
              return CreateUpdateArticleModal(formattedDate: _dateFormat.format(dateProvider.selectedDate));
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