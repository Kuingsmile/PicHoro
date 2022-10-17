import 'package:flutter/material.dart';

import 'package:horopic/pages/homePage.dart';
import 'package:horopic/album/albumPage.dart';
import 'package:horopic/configurePage/configurePage.dart';

class PicHoroAPP extends StatefulWidget {
  final int selectedIndex;

  const PicHoroAPP({super.key, this.selectedIndex = 0});

  @override
  _TabsPageState createState() => _TabsPageState(this.selectedIndex);
}

class _TabsPageState extends State<PicHoroAPP> {
  int _selectedIndex;

  _TabsPageState(this._selectedIndex);

  final List<Widget> _pageList = [
    HomePage(),
    UploadedImages(),
    ConfigurePage()
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageList[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.file_upload),
            label: '上传',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_outlined),
            label: '相册',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }
}
