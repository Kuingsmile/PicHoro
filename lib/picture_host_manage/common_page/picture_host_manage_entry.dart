import 'package:flutter/material.dart';

import 'package:fluro/fluro.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/common_functions.dart';

class PsHostHomePage extends StatefulWidget {
  const PsHostHomePage({super.key});

  @override
  PsHostHomePageState createState() => PsHostHomePageState();
}

class PsHostHomePageState extends State<PsHostHomePage>
    with AutomaticKeepAliveClientMixin<PsHostHomePage> {
  List psHostHomePageOrder = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    initOrder();
  }

  initOrder() {
    List temppsHostHomePageOrder = Global.psHostHomePageOrder;
    setState(() {
      for (var i = 0; i < temppsHostHomePageOrder.length; i++) {
        psHostHomePageOrder.add(int.parse(temppsHostHomePageOrder[i]));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<DraggableGridItem> listOfDraggableGridItem = [
      DraggableGridItem(
        child: Card(
          borderOnForeground: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    Application.router.navigateTo(
                      context,
                      Routes.tencentBucketList,
                      transition: TransitionType.inFromRight,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/tcyun.png',
                        width: 80,
                        height: 80,
                      ),
                      const Text('腾讯云'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    Application.router.navigateTo(
                      context,
                      Routes.smmsManageHomePage,
                      transition: TransitionType.inFromRight,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/smms.png',
                        width: 80,
                        height: 80,
                      ),
                      const Text('SM.MS'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    showToastWithContext(context, '暂未开放');
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/aliyun.png',
                        width: 80,
                        height: 80,
                      ),
                      const Text('阿里云'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(
                      '',
                      style: TextStyle(
                        color: Color.fromARGB(255, 128, 125, 125),
                        fontSize: 12,
                      ),
                    ),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    showToastWithContext(context, '暂未开放');
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/qiniu.png',
                        width: 80,
                        height: 80,
                      ),
                      const Text('七牛云'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(
                      '',
                      style: TextStyle(
                        color: Color.fromARGB(255, 128, 125, 125),
                        fontSize: 12,
                      ),
                    ),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                  child: InkWell(
                onTap: () {
                  showToastWithContext(context, '暂未开放');
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/icons/upyun.png',
                      width: 80,
                      height: 80,
                    ),
                    const Text('又拍云'),
                  ],
                ),
              )),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(
                      '',
                      style: TextStyle(
                        color: Color.fromARGB(255, 128, 125, 125),
                        fontSize: 12,
                      ),
                    ),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    showToastWithContext(context, '暂未开放');
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/lskypro.png',
                        width: 80,
                        height: 80,
                      ),
                      const Text('兰空图床'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(
                      '',
                      style: TextStyle(
                        color: Color.fromARGB(255, 128, 125, 125),
                        fontSize: 12,
                      ),
                    ),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    showToastWithContext(context, '暂未开放');
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/github.png',
                        width: 80,
                        height: 80,
                      ),
                      const Text('Github'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(
                      '',
                      style: TextStyle(
                        color: Color.fromARGB(255, 128, 125, 125),
                        fontSize: 12,
                      ),
                    ),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    showToastWithContext(context, '暂未开放');
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/Imgur.png',
                        width: 70,
                        height: 80,
                      ),
                      const Text('Imgur'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(
                      '',
                      style: TextStyle(
                        color: Color.fromARGB(255, 128, 125, 125),
                        fontSize: 12,
                      ),
                    ),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
    ];
    List<DraggableGridItem> newItems = [];
    for (int i = 0; i < listOfDraggableGridItem.length; i++) {
      newItems.add(listOfDraggableGridItem[psHostHomePageOrder[i]]);
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '图床管理-拖动排序',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: DraggableGridViewBuilder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
        ),
        children: newItems,
        dragCompletion: (List<DraggableGridItem> list, int beforeIndex,
            int afterIndex) async {
          List<String> newOrder = [];
          for (int i = 0; i < list.length; i++) {
            newOrder.add(listOfDraggableGridItem.indexOf(list[i]).toString());
          }
          await Global.setpsHostHomePageOrder(newOrder);
        },
        dragFeedback: (List<DraggableGridItem> list, int index) {
          return SizedBox(
            width: 200,
            height: 150,
            child: list[index].child,
          );
        },
        dragPlaceHolder: (List<DraggableGridItem> list, int index) {
          return PlaceHolderWidget(
            child: Container(
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}