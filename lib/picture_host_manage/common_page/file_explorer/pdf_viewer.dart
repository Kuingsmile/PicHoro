import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/material.dart';

import 'package:horopic/utils/common_functions.dart';

class PdfViewer extends StatefulWidget {
  final String url;
  final String fileName;

  const PdfViewer({
    Key? key,
    required this.url,
    required this.fileName,
  }) : super(key: key);

  @override
  PdfViewerState createState() => PdfViewerState();
}

class PdfViewerState extends State<PdfViewer> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late PdfViewerController _pdfViewerController;
  TextEditingController pageJumpController = TextEditingController();
  late OverlayEntry? _overlayEntry;
  late PdfTextSearchResult _searchResult;
  TextEditingController searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _overlayEntry = null;
    _searchResult = PdfTextSearchResult();
  }

  @override
  void dispose() {
    if (mounted && _pdfViewerKey.currentState != null) {
      _pdfViewerKey.currentState!.dispose();
    }
    pageJumpController.dispose();
    _pdfViewerController.dispose();
    _searchResult.dispose();
    searchTextController.dispose();
    super.dispose();
  }

  void _showContextMenu(
      BuildContext context, PdfTextSelectionChangedDetails details) {
    final OverlayState? overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: details.globalSelectedRegion!.center.dy - 55,
        left: details.globalSelectedRegion!.bottomLeft.dx,
        child: ElevatedButton(
          child: const Text('复制', style: TextStyle(fontSize: 17)),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: details.selectedText));
            _pdfViewerController.clearSelection();
          },
        ),
      ),
    );
    overlayState!.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('预览'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              showSearchDialog(context);
            },
          ),
          Visibility(
            visible: _searchResult.hasResult,
            child: IconButton(
              icon: const Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _searchResult.clear();
                });
              },
            ),
          ),
          Visibility(
            visible: _searchResult.hasResult,
            child: IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_up,
                color: Colors.white,
              ),
              onPressed: () {
                _searchResult.previousInstance();
              },
            ),
          ),
          Visibility(
            visible: _searchResult.hasResult,
            child: IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
              onPressed: () {
                _searchResult.nextInstance();
              },
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.navigation_sharp,
              color: Colors.white,
            ),
            onPressed: () {
              showJumpPageDialog(context);
            },
          ),
        ],
      ),
      body: SfPdfViewer.network(
        widget.url,
        key: _pdfViewerKey,
        controller: _pdfViewerController,
        onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
          if (details.selectedText == null && _overlayEntry != null) {
            _overlayEntry!.remove();
            _overlayEntry = null;
          } else if (details.selectedText != null && _overlayEntry == null) {
            _showContextMenu(context, details);
          }
        },
      ),
    );
  }

  void showJumpPageDialog(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('跳转到指定页'),
            content: TextField(
              textAlign: TextAlign.center,
              controller: pageJumpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '请输入页码',
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('取消',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('确定',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  _pdfViewerController
                      .jumpToPage(int.parse(pageJumpController.text));
                  setState(() {});
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void showSearchDialog(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('搜索'),
            content: TextField(
              textAlign: TextAlign.center,
              controller: searchTextController,
              decoration: const InputDecoration(
                hintText: '请输入关键字',
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('取消',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('确定',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  showToast('开始搜索');
                  Navigator.of(context).pop();
                  _searchResult = _pdfViewerController.searchText(
                      searchTextController.text,
                      searchOption: TextSearchOption.caseSensitive);
                  if (!_searchResult.hasResult) {
                    showToast('未找到');
                  }
                  _searchResult.addListener(() {
                    if (_searchResult.hasResult) {
                      setState(() {});
                    }
                  });
                },
              ),
            ],
          );
        });
  }
}
