import 'package:flutter/material.dart';
import 'package:horopic/pages/home_page.dart';
import 'package:horopic/album/album_page.dart';
import 'package:horopic/configure_page/configure_page.dart';
import 'package:horopic/picture_host_manage/picture_host_manage_entry.dart';

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
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = theme.primaryColor;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pageList,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 10,
          elevation: 15,
          backgroundColor: Colors.white,
          onTap: (value) {
            setState(() {
              _selectedIndex = value;
              _pageController.jumpToPage(value);
            });
          },
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.file_upload_outlined),
              activeIcon: Icon(Icons.file_upload),
              label: '上传',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_outlined),
              activeIcon: Icon(Icons.photo),
              label: '相册',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storage_outlined),
              activeIcon: Icon(Icons.storage),
              label: '仓库',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: '设置',
            ),
          ],
        ),
      ),
    );
  }
}
