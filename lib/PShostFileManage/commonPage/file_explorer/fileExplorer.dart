import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:horopic/utils/common_func.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as mypath;
import 'package:fluro/fluro.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routes.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:msh_checkbox/msh_checkbox.dart';

class FileExplorer extends StatefulWidget {
  FileExplorer(
      {super.key, required this.currentDirPath, required this.rootPath});

  final String currentDirPath;
  final String rootPath;

  @override
  _FileExplorerState createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  List<FileSystemEntity> currentFiles = [];
  String rootPath = '';
  List selectedFilesBool = [];
  bool sorted = true;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    currentFiles.clear();
    getCurrentPathFiles(widget.currentDirPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Text(
          mypath.basename(widget.currentDirPath),
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        actions: [
          PopupMenuButton(
              icon: const Icon(
                Icons.sort,
                size: 30,
              ),
              position: PopupMenuPosition.under,
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                      child: const Center(
                          child: Text(
                        '修改时间排序',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      )),
                      onTap: () {
                        if (sorted == true) {
                          setState(() {
                            currentFiles.sort((a, b) => b
                                .statSync()
                                .modified
                                .compareTo(a.statSync().modified));
                            sorted = false;
                          });
                        } else {
                          setState(() {
                            currentFiles.sort((a, b) => a
                                .statSync()
                                .modified
                                .compareTo(b.statSync().modified));
                            sorted = true;
                          });
                        }
                      }),
                  PopupMenuItem(
                      child: const Center(
                          child: Text(
                        '文件名称排序',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      )),
                      onTap: () {
                        if (sorted == true) {
                          setState(() {
                            currentFiles.sort((a, b) => b.path
                                .toLowerCase()
                                .compareTo(a.path.toLowerCase()));
                            sorted = false;
                          });
                        } else {
                          setState(() {
                            currentFiles.sort((a, b) => a.path
                                .toLowerCase()
                                .compareTo(b.path.toLowerCase()));
                            sorted = true;
                          });
                        }
                      }),
                  PopupMenuItem(
                      child: const Center(
                          child: Text(
                        '文件大小排序',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      )),
                      onTap: () {
                        if (sorted == true) {
                          setState(() {
                            currentFiles.sort((a, b) =>
                                b.statSync().size.compareTo(a.statSync().size));
                            sorted = false;
                          });
                        } else {
                          setState(() {
                            currentFiles.sort((a, b) =>
                                a.statSync().size.compareTo(b.statSync().size));
                            sorted = true;
                          });
                        }
                      }),
                  PopupMenuItem(
                      child: const Center(
                          child: Text(
                        '文件类型排序',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      )),
                      onTap: () {
                        if (sorted == true) {
                          setState(() {
                            currentFiles.sort((a, b) {
                              sorted = false;
                              String aType = a.path.split('.').last;
                              String bType = b.path.split('.').last;
                              if (aType.isEmpty) {
                                return 1;
                              } else if (bType.isEmpty) {
                                return -1;
                              } else {
                                return aType
                                    .toLowerCase()
                                    .compareTo(bType.toLowerCase());
                              }
                            });
                          });
                        } else {
                          setState(() {
                            currentFiles.sort((a, b) {
                              sorted = true;
                              String aType = a.path.split('.').last;
                              String bType = b.path.split('.').last;
                              if (aType.isEmpty) {
                                return -1;
                              } else if (bType.isEmpty) {
                                return 1;
                              } else {
                                return bType
                                    .toLowerCase()
                                    .compareTo(aType.toLowerCase());
                              }
                            });
                          });
                        }
                      }),
                ];
              }),
          IconButton(
            icon: selectedFilesBool.contains(true)
                ? const Icon(Icons.delete,
                    color: Color.fromARGB(255, 236, 127, 120), size: 30.0)
                : const Icon(Icons.delete_outline,
                    color: Colors.white, size: 30.0),
            onPressed: () async {
              if (!selectedFilesBool.contains(true) ||
                  selectedFilesBool.isEmpty) {
                Fluttertoast.showToast(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                    textColor: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Colors.black,
                    msg: '没有选择文件');
                return;
              }
              return showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      '删除全部文件',
                      textAlign: TextAlign.center,
                    ),
                    content: const Text(
                      '是否删除全部选择的文件？\n请谨慎选择!',
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              child: const Text(
                                '确定',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () async {
                                try {
                                  List<int> toDelete = [];
                                  for (int i = 0;
                                      i < currentFiles.length;
                                      i++) {
                                    if (selectedFilesBool[i]) {
                                      toDelete.add(i);
                                    }
                                  }
                                  Navigator.pop(context);
                                  await deleteAll(toDelete);
                                  Fluttertoast.showToast(msg: '删除完成');
                                  return;
                                } catch (e) {
                                  Fluttertoast.showToast(msg: '删除失败');
                                }
                              },
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                alignment: Alignment.center,
                              ),
                              child: const Text(
                                '取消',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: currentFiles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/empty.png',
                    width: 100,
                    height: 100,
                  ),
                  const Text('没有文件哦',
                      style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(136, 121, 118, 118)))
                ],
              ),
            )
          : SmartRefresher(
              controller: _refreshController,
              onRefresh: _onrefresh,
              enablePullDown: true,
              enablePullUp: false,
              header: const ClassicHeader(
                refreshStyle: RefreshStyle.Follow,
                idleText: '下拉刷新',
                refreshingText: '正在刷新',
                completeText: '刷新完成',
                failedText: '刷新失败',
                releaseText: '释放刷新',
              ),
              footer: const ClassicFooter(
                loadStyle: LoadStyle.ShowWhenLoading,
                idleText: '上拉加载',
                loadingText: '正在加载',
                noDataText: '没有更多啦',
                failedText: '没有更多啦',
                canLoadingText: '释放加载',
              ),
              child: ListView.builder(
                itemCount: currentFiles.length,
                itemBuilder: (context, index) {
                  if (!FileSystemEntity.isFileSync(currentFiles[index].path)) {
                    return Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Column(
                        children: [
                          Slidable(
                            direction: Axis.horizontal,
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (BuildContext context) async {},
                                  backgroundColor: const Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: '删除',
                                ),
                              ],
                            ),
                            child: Stack(
                              fit: StackFit.loose,
                              children: [
                                Container(
                                  color: selectedFilesBool[index]
                                      ? const Color(0x311192F3)
                                      : Colors.transparent,
                                  child: ListTile(
                                    minLeadingWidth: 0,
                                    minVerticalPadding: 0,
                                    //dense: true,
                                    leading: Image.asset(
                                      'assets/icons/folder.png',
                                      width: 30,
                                      height: 32,
                                    ),
                                    title: Text(
                                        currentFiles[index].path.substring(
                                            currentFiles[index]
                                                    .parent
                                                    .path
                                                    .length +
                                                1),
                                        style: const TextStyle(fontSize: 15)),
                                    trailing: const Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                    ),
                                    onTap: () {
                                      Application.router.navigateTo(context,
                                          '${Routes.fileExplorer}?currentDirPath=${Uri.encodeComponent(currentFiles[index].path)}&rootPath=${Uri.encodeComponent(widget.rootPath)}',
                                          transition:
                                              TransitionType.inFromRight);
                                    },
                                  ),
                                ),
                                Positioned(
                                  // ignore: sort_child_properties_last
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(55)),
                                        color:
                                            Color.fromARGB(255, 235, 242, 248)),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: MSHCheckbox(
                                      uncheckedColor: Colors.blue,
                                      size: 17,
                                      checkedColor: Colors.blue,
                                      value: selectedFilesBool[index],
                                      style: MSHCheckboxStyle.fillScaleCheck,
                                      onChanged: (selected) {
                                        setState(() {
                                          if (selected) {
                                            selectedFilesBool[index] = true;
                                          } else {
                                            selectedFilesBool[index] = false;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  left: 0,
                                  top: 15,
                                )
                              ],
                            ),
                          ),
                          const Divider(
                            height: 1,
                          )
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Column(
                        children: [
                          Slidable(
                              direction: Axis.horizontal,
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (BuildContext context) async {},
                                    backgroundColor: const Color(0xFFFE4A49),
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: '删除',
                                  ),
                                ],
                              ),
                              child: Stack(fit: StackFit.loose, children: [
                                Container(
                                  color: selectedFilesBool[index]
                                      ? const Color(0x311192F3)
                                      : Colors.transparent,
                                  child: ListTile(
                                    minLeadingWidth: 0,
                                    minVerticalPadding: 0,
                                    //dense: true,
                                    leading:
                                        imageIcon(currentFiles[index].path),
                                    title: Text(
                                      currentFiles[index].path.substring(
                                          currentFiles[index]
                                                  .parent
                                                  .path
                                                  .length +
                                              1),
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    subtitle: Text(
                                        '${fileDateFormat(currentFiles[index])}  ${getFileSize(currentFiles[index].statSync().size)}',
                                        style: const TextStyle(fontSize: 12)),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.more_horiz),
                                      onPressed: () {
                                        showModalBottomSheet(
                                            isScrollControlled: true,
                                            context: context,
                                            builder: (context) {
                                              return buildBottomSheetWidget(
                                                  context, currentFiles[index]);
                                            });
                                      },
                                    ),
                                    onTap: () {
                                      List imageTypeList = [
                                        '.jpg',
                                        '.jpeg',
                                        '.png',
                                        '.bmp',
                                        '.webp',
                                        '.svg',
                                        '.tiff',
                                        '.ico',
                                        '.raw',
                                      ];
                                      if (imageTypeList.contains(mypath
                                          .extension(currentFiles[index].path)
                                          .toLowerCase())) {
                                        List<String> imgList = [];
                                        for (var element in currentFiles) {
                                          if (imageTypeList.contains(
                                              mypath.extension(element.path
                                                  .toLowerCase()))) {
                                            imgList.add(element.path);
                                          }
                                        }
                                        int newindex = imgList
                                            .indexOf(currentFiles[index].path);
                                        String imgListStr = '';
                                        for (var element in imgList) {
                                          imgListStr += '$element,';
                                        }
                                        Application.router.navigateTo(context,
                                            '${Routes.localImagePreview}?index=$newindex&images=${Uri.encodeComponent(imgListStr)}',
                                            transition: TransitionType.none);
                                      } else {
                                        OpenFilex.open(
                                            currentFiles[index].path);
                                      }
                                    },
                                  ),
                                ),
                                Positioned(
                                  // ignore: sort_child_properties_last
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(55)),
                                        color:
                                            Color.fromARGB(255, 235, 242, 248)),
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: MSHCheckbox(
                                      uncheckedColor: Colors.blue,
                                      size: 17,
                                      checkedColor: Colors.blue,
                                      value: selectedFilesBool[index],
                                      style: MSHCheckboxStyle.fillScaleCheck,
                                      onChanged: (selected) {
                                        setState(() {
                                          if (selected) {
                                            selectedFilesBool[index] = true;
                                          } else {
                                            selectedFilesBool[index] = false;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  left: 0,
                                  top: 22,
                                ),
                              ])),
                          const Divider(
                            height: 1,
                          )
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              height: 30,
              width: 30,
              child: FloatingActionButton(
                heroTag: 'select',
                backgroundColor: const Color.fromARGB(255, 233, 88, 202),
                elevation: 50,
                onPressed: () async {
                  if (currentFiles.isEmpty) {
                    Fluttertoast.showToast(
                        msg: "目录为空",
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 2,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.black
                                : Colors.white,
                        textColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.white
                                : Colors.black,
                        fontSize: 16.0);
                    return;
                  } else if (selectedFilesBool.contains(true)) {
                    setState(() {
                      for (int i = 0; i < selectedFilesBool.length; i++) {
                        selectedFilesBool[i] = false;
                      }
                    });
                  } else {
                    setState(() {
                      for (int i = 0; i < selectedFilesBool.length; i++) {
                        selectedFilesBool[i] = true;
                      }
                    });
                  }
                },
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 30,
                ),
              )),
        ],
      ),
    );
  }

  deleteAll(List toDelete) async {
    try {
      for (int i = 0; i < toDelete.length; i++) {
        FileSystemEntity file = currentFiles[toDelete[i] - i];
        if (file.statSync().type == FileSystemEntityType.directory) {
          Directory directory = Directory(file.path);
          directory.deleteSync(recursive: true);
        } else if (file.statSync().type == FileSystemEntityType.file) {
          file.deleteSync();
        }
        setState(() {
          currentFiles.removeAt(toDelete[i] - i);
          selectedFilesBool.removeAt(toDelete[i] - i);
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  _onrefresh() async {
    getCurrentPathFiles(widget.currentDirPath);
    _refreshController.refreshCompleted();
  }

  fileDateFormat(FileSystemEntity file) {
    DateTime now = file.statSync().modified.toLocal();
    String date =
        '${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return date;
  }

  Widget imageIcon(String path) {
    List imageList = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp',
      '.psd',
      '.svg',
      '.tiff',
      '.ico',
      '.raw',
    ];
    path = path.toLowerCase();
    String fileExtension = mypath.extension(path);
    if (imageList.contains(fileExtension)) {
      return Image.file(File(path),
          width: 40.0,
          height: 40.0,
          cacheHeight: 90,
          cacheWidth: 90,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium);
    } else {
      return Image.asset(selectIcon(mypath.extension(path)),
          width: 40.0, height: 40.0);
    }
  }

  Widget buildBottomSheetWidget(BuildContext context, FileSystemEntity file) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            //dense: true,
            leading: imageIcon(file.path),
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            minLeadingWidth: 0,
            title: Text(file.path.split('/').last,
                style: const TextStyle(fontSize: 15)),
            subtitle: Text(fileDateFormat(file),
                style: const TextStyle(fontSize: 12)),
          ),
          const Divider(
            height: 0.1,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
          ListTile(
              // dense: true,
              leading: const Icon(
                Icons.edit_note_rounded,
                color: Color.fromARGB(255, 97, 141, 236),
              ),
              //  visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              minLeadingWidth: 0,
              title: const Text('重命名'),
              onTap: () async {
                Navigator.pop(context);
                renameFile(context, file);
              }),
          const Divider(
            height: 0.1,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
          ListTile(
              //  dense: true,
              leading: const Icon(
                Icons.delete_outline,
                color: Color.fromARGB(255, 240, 85, 131),
              ),
              //   visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              minLeadingWidth: 0,
              title: const Text('删除'),
              onTap: () {
                Navigator.pop(context);
                deleteFile(context, file);
              }),
        ],
      ),
    );
  }

  void getCurrentPathFiles(String path) {
    Directory currentDir = Directory(path);
    if (!currentDir.existsSync()) {
      currentDir.createSync(recursive: true);
    }
    List<FileSystemEntity> files = [];
    List<FileSystemEntity> folder = [];
    for (var file in currentDir.listSync()) {
      if (mypath.basename(file.path).substring(0, 1) == '.') {
        continue;
      }
      if (FileSystemEntity.isFileSync(file.path)) {
        files.add(file);
      } else {
        folder.add(file);
      }
    }
    files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    folder.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

    currentFiles.clear();
    currentFiles.addAll(folder);
    currentFiles.addAll(files);
    setState(() {
      selectedFilesBool.clear();
      for (var i = 0; i < currentFiles.length; i++) {
        selectedFilesBool.add(false);
      }
    });
  }

  void deleteFile(BuildContext context, FileSystemEntity file) {
    showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('通知'),
          content: const Text('是否确定删除本地文件?'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('取消', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: const Text('确定', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                try {
                  if (file.statSync().type == FileSystemEntityType.directory) {
                    Directory directory = Directory(file.path);
                    directory.deleteSync(recursive: true);
                  } else if (file.statSync().type ==
                      FileSystemEntityType.file) {
                    file.deleteSync();
                  }
                  getCurrentPathFiles(file.parent.path);
                  setState(() {});
                } catch (e) {
                  Fluttertoast.showToast(
                      msg: '删除失败',
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 2,
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                      textColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.white
                              : Colors.black,
                      fontSize: 16.0);
                }
                Navigator.pop(context);
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  void renameFile(BuildContext context, FileSystemEntity file) {
    TextEditingController controller = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CupertinoAlertDialog(
              title: const Text('重命名'),
              content: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.0)),
                    hintText: '请输入新名称 不含扩展名',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.0)),
                    contentPadding: const EdgeInsets.all(10.0),
                  ),
                ),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: const Text('取消', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                CupertinoDialogAction(
                  child: const Text('确定', style: TextStyle(color: Colors.blue)),
                  onPressed: () async {
                    String newName = controller.text;
                    if (newName.trim().isEmpty) {
                      Fluttertoast.showToast(msg: '文件名不能为空');
                      return;
                    }
                    if (newName.endsWith(mypath.extension(file.path))) {
                      newName = newName.substring(0,
                          newName.length - mypath.extension(file.path).length);
                    }
                    String newPath =
                        '${file.parent.path}/$newName${mypath.extension(file.path)}';
                    file.renameSync(newPath);
                    getCurrentPathFiles(file.parent.path);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
