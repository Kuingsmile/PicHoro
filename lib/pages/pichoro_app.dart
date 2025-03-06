import 'package:flutter/material.dart';
import 'package:horopic/pages/home_page.dart';
import 'package:horopic/album/album_page.dart';
import 'package:horopic/configure_page/configure_page.dart';
import 'package:horopic/picture_host_manage/common_page/picture_host_manage_entry.dart';

class PicHoroAPP extends StatefulWidget {
  final int selectedIndex;

  const PicHoroAPP({super.key, this.selectedIndex = 0});

  @override
  // ignore: no_logic_in_create_state
  TabsPageState createState() => TabsPageState(selectedIndex);
}

class TabsPageState extends State<PicHoroAPP> {
  int _selectedIndex;

  TabsPageState(this._selectedIndex);
  late PageController _pageController;

  final List<Widget> _pageList = [
    const HomePage(),
    const UploadedImages(),
    const PsHostHomePage(),
    const ConfigurePage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pageList,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
            _pageController.jumpToPage(value);
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
          BottomNavigationBarItem(
            icon: Icon(Icons.storage),
            label: '仓库',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }
}
