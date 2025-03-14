import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as my_path;
import 'package:fluro/fluro.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:msh_checkbox/msh_checkbox.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/common_functions.dart';

class FileExplorer extends StatefulWidget {
  const FileExplorer({super.key, required this.currentDirPath, required this.rootPath});

  final String currentDirPath;
  final String rootPath;

  @override
  FileExplorerState createState() => FileExplorerState();
}

class FileExplorerState extends State<FileExplorer> {
  List<FileSystemEntity> currentFiles = [];
  String rootPath = '';
  List selectedFilesBool = [];
  bool sorted = true;

  // Predefined constants
  final List<String> _imageExtensions = [
    '.avif',
    '.jpg',
    '.jpeg',
    '.png',
    '.bmp',
    '.webp',
    '.svg',
    '.tiff',
    '.ico',
    '.gif',
  ];

  RefreshController refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    getCurrentPathFiles(widget.currentDirPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: currentFiles.isEmpty
          ? _buildEmptyState()
          : SmartRefresher(
              controller: refreshController,
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
                itemBuilder: _buildFileItem,
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Text(
        my_path.basename(widget.currentDirPath),
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        _buildSortButton(),
        _buildDeleteButton(),
      ],
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton(
        icon: const Icon(Icons.sort, color: Colors.white, size: 30),
        position: PopupMenuPosition.under,
        itemBuilder: (BuildContext context) {
          return [
            _buildSortMenuItem('修改时间排序', _sortByModifiedTime),
            _buildSortMenuItem('文件名称排序', _sortByFileName),
            _buildSortMenuItem('文件大小排序', _sortByFileSize),
            _buildSortMenuItem('文件类型排序', _sortByFileType),
          ];
        });
  }

  PopupMenuItem _buildSortMenuItem(String title, VoidCallback onTap) {
    return PopupMenuItem(
      onTap: onTap,
      child: Center(
          child: Text(
        title,
        style: const TextStyle(color: Colors.black, fontSize: 15),
      )),
    );
  }

  void _sortByModifiedTime() {
    setState(() {
      if (sorted) {
        currentFiles.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      } else {
        currentFiles.sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));
      }
      sorted = !sorted;
    });
  }

  void _sortByFileName() {
    setState(() {
      if (sorted) {
        currentFiles.sort((a, b) => b.path.toLowerCase().compareTo(a.path.toLowerCase()));
      } else {
        currentFiles.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
      }
      sorted = !sorted;
    });
  }

  void _sortByFileSize() {
    setState(() {
      if (sorted) {
        currentFiles.sort((a, b) => b.statSync().size.compareTo(a.statSync().size));
      } else {
        currentFiles.sort((a, b) => a.statSync().size.compareTo(b.statSync().size));
      }
      sorted = !sorted;
    });
  }

  void _sortByFileType() {
    setState(() {
      if (sorted) {
        currentFiles.sort((a, b) {
          String aType = a.path.split('.').last;
          String bType = b.path.split('.').last;
          return aType.isEmpty
              ? 1
              : bType.isEmpty
                  ? -1
                  : aType.toLowerCase().compareTo(bType.toLowerCase());
        });
      } else {
        currentFiles.sort((a, b) {
          String aType = a.path.split('.').last;
          String bType = b.path.split('.').last;
          return aType.isEmpty
              ? -1
              : bType.isEmpty
                  ? 1
                  : bType.toLowerCase().compareTo(aType.toLowerCase());
        });
      }
      sorted = !sorted;
    });
  }

  Widget _buildDeleteButton() {
    bool hasSelection = selectedFilesBool.contains(true);
    return IconButton(
      icon: Icon(hasSelection ? Icons.delete : Icons.delete_outline,
          color: hasSelection ? const Color.fromARGB(255, 236, 127, 120) : Colors.white, size: 30.0),
      onPressed: _handleDeleteSelected,
    );
  }

  void _handleDeleteSelected() async {
    if (!selectedFilesBool.contains(true) || selectedFilesBool.isEmpty) {
      showToastWithContext(context, '没有选择文件');
      return;
    }

    showCupertinoAlertDialogWithConfirmFunc(
      title: '删除全部文件',
      content: '是否删除全部选择的文件？\n请谨慎选择!',
      context: context,
      onConfirm: () async {
        try {
          List<int> toDelete = [];
          for (int i = 0; i < selectedFilesBool.length; i++) {
            if (selectedFilesBool[i]) toDelete.add(i);
          }
          Navigator.pop(context);
          await deleteAll(toDelete);
          showToast('删除完成');
        } catch (e) {
          flogErr(e, {}, 'FileListPage', 'deleteAll');
          showToast('删除失败');
        }
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/empty.png', width: 120, height: 120),
          const SizedBox(height: 20),
          const Text(
            '没有文件哦',
            style: TextStyle(
              fontSize: 18,
              color: Color.fromARGB(136, 121, 118, 118),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _onrefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('刷新'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(BuildContext context, int index) {
    final file = currentFiles[index];
    bool isDirectory = !FileSystemEntity.isFileSync(file.path);
    bool isSelected = selectedFilesBool[index];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Slidable(
        direction: Axis.horizontal,
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _handleDeleteFile(file),
              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: '删除',
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
          ],
        ),
        child: Card(
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.5) : Colors.transparent,
              width: 1.5,
            ),
          ),
          color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Theme.of(context).cardColor,
          child: Stack(
            fit: StackFit.loose,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minLeadingWidth: 0,
                minVerticalPadding: 0,
                leading: _buildFileIcon(file, isDirectory),
                title: Text(
                  my_path.basename(file.path),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                subtitle: isDirectory ? null : _buildFileDetails(file),
                trailing: isDirectory ? const Icon(Icons.chevron_right, color: Colors.grey) : _buildMoreButton(file),
                onTap: () => _handleFileTap(file, isDirectory, index),
                onLongPress: () => setState(() {
                  selectedFilesBool[index] = !isSelected;
                }),
              ),
              _buildCheckbox(index),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileIcon(FileSystemEntity file, bool isDirectory) {
    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: isDirectory ? Image.asset('assets/icons/folder.png', width: 40, height: 40) : imageIcon(file.path),
      ),
    );
  }

  Widget _buildFileDetails(FileSystemEntity file) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        _buildDetailRow(Icons.access_time_outlined, fileDateFormat(file)),
        const SizedBox(height: 2),
        _buildDetailRow(Icons.file_copy_outlined, getFileSize(file.statSync().size)),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildMoreButton(FileSystemEntity file) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.more_horiz, color: Colors.blueGrey),
        onPressed: () => showModalBottomSheet(
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          context: context,
          builder: (context) => buildBottomSheetWidget(context, file),
        ),
      ),
    );
  }

  Widget _buildCheckbox(int index) {
    return Positioned(
      left: 2,
      top: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(55),
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 2)],
        ),
        child: MSHCheckbox(
          colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
            checkedColor: Theme.of(context).primaryColor,
            uncheckedColor: Colors.grey,
            disabledColor: Colors.grey.withValues(alpha: 0.5),
          ),
          size: 18,
          value: selectedFilesBool[index],
          style: MSHCheckboxStyle.fillScaleCheck,
          onChanged: (selected) => setState(() {
            selectedFilesBool[index] = selected;
          }),
        ),
      ),
    );
  }

  void _handleFileTap(FileSystemEntity file, bool isDirectory, int index) {
    if (isDirectory) {
      _navigateToFolder(file);
    } else {
      _openFile(file, index);
    }
  }

  void _navigateToFolder(FileSystemEntity file) {
    Application.router.navigateTo(context,
        '${Routes.fileExplorer}?currentDirPath=${Uri.encodeComponent(file.path)}&rootPath=${Uri.encodeComponent(widget.rootPath)}',
        transition: TransitionType.inFromRight);
  }

  void _openFile(FileSystemEntity file, int index) {
    String extension = my_path.extension(file.path).toLowerCase();
    if (_imageExtensions.contains(extension)) {
      _openImagePreview(file, index);
    } else {
      OpenFilex.open(file.path);
    }
  }

  void _openImagePreview(FileSystemEntity file, int index) {
    // Collect all image paths
    List<String> imgList = currentFiles
        .where((e) => _imageExtensions.contains(my_path.extension(e.path).toLowerCase()))
        .map((e) => e.path)
        .toList();

    int newIndex = imgList.indexOf(file.path);
    String imgListStr = imgList.join(',');

    Application.router.navigateTo(
        context, '${Routes.localImagePreview}?index=$newIndex&images=${Uri.encodeComponent(imgListStr)}',
        transition: TransitionType.none);
  }

  void _handleDeleteFile(FileSystemEntity file) {
    try {
      deleteFile(context, file);
    } catch (e) {
      bool isDirectory = !FileSystemEntity.isFileSync(file.path);
      flogErr(e, {}, 'FileListPage', isDirectory ? 'deleteFile_folder' : 'deleteFile_file');
      showToast('删除失败');
    }
  }

  Widget buildBottomSheetWidget(BuildContext context, FileSystemEntity file) {
    bool isDirectory = !FileSystemEntity.isFileSync(file.path);
    String fileName = my_path.basename(file.path);
    String displayName =
        fileName.length > 25 ? '${fileName.substring(0, 12)}...${fileName.substring(fileName.length - 12)}' : fileName;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            height: 6,
            width: 40,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // File info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: isDirectory
                        ? Image.asset('assets/icons/folder.png', width: 55, height: 55)
                        : imageIcon(file.path),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fileDateFormat(file),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      if (!isDirectory) ...[
                        const SizedBox(height: 2),
                        Text(
                          getFileSize(file.statSync().size),
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action buttons
          _buildActionTile(
            icon: Icons.edit_note_rounded,
            iconColor: const Color.fromARGB(255, 97, 141, 236),
            title: '重命名',
            onTap: () {
              Navigator.pop(context);
              renameFile(context, file);
            },
          ),
          _buildActionTile(
            icon: Icons.delete_outline,
            iconColor: const Color.fromARGB(255, 240, 85, 131),
            title: '删除',
            onTap: () {
              Navigator.pop(context);
              deleteFile(context, file);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildFloatingActionButton() {
    return SizedBox(
      height: 40,
      width: 40,
      child: FloatingActionButton(
        heroTag: 'select',
        backgroundColor: const Color.fromARGB(255, 248, 196, 237),
        elevation: 5,
        onPressed: _toggleSelectAll,
        child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 25),
      ),
    );
  }

  void _toggleSelectAll() {
    if (currentFiles.isEmpty) {
      showToastWithContext(context, '目录为空');
      return;
    }

    bool hasSelection = selectedFilesBool.contains(true);
    setState(() {
      for (int i = 0; i < selectedFilesBool.length; i++) {
        selectedFilesBool[i] = !hasSelection;
      }
    });
  }

  Future<void> deleteAll(List toDelete) async {
    try {
      for (int i = 0; i < toDelete.length; i++) {
        FileSystemEntity file = currentFiles[toDelete[i] - i];
        bool isDirectory = file.statSync().type == FileSystemEntityType.directory;

        if (isDirectory) {
          Directory(file.path).deleteSync(recursive: true);
        } else {
          file.deleteSync();
        }

        setState(() {
          currentFiles.removeAt(toDelete[i] - i);
          selectedFilesBool.removeAt(toDelete[i] - i);
        });
      }
    } catch (e) {
      flogErr(e, {'toDelete': toDelete}, 'LocalFilePage', 'deleteAll');
      rethrow;
    }
  }

  Future<void> _onrefresh() async {
    getCurrentPathFiles(widget.currentDirPath);
    refreshController.refreshCompleted();
  }

  String fileDateFormat(FileSystemEntity file) {
    DateTime now = file.statSync().modified.toLocal();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  Widget imageIcon(String path) {
    List imageList = [
      '.avif',
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

    String fileExtension = my_path.extension(path.toLowerCase());
    if (imageList.contains(fileExtension)) {
      return Image.file(File(path),
          width: 40.0,
          height: 40.0,
          cacheHeight: 90,
          cacheWidth: 90,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.medium);
    } else {
      return Image.asset(selectIcon(fileExtension), width: 40.0, height: 40.0);
    }
  }

  void getCurrentPathFiles(String path) {
    Directory currentDir = Directory(path);
    if (!currentDir.existsSync()) {
      currentDir.createSync(recursive: true);
    }

    List<FileSystemEntity> files = [];
    List<FileSystemEntity> folders = [];

    for (var entity in currentDir.listSync()) {
      String basename = my_path.basename(entity.path);
      if (basename.startsWith('.')) continue;

      if (FileSystemEntity.isFileSync(entity.path)) {
        files.add(entity);
      } else {
        folders.add(entity);
      }
    }

    // Sort alphabetically (case insensitive)
    files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    folders.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

    setState(() {
      currentFiles = [...folders, ...files];
      selectedFilesBool = List.generate(currentFiles.length, (_) => false);
    });
  }

  void deleteFile(BuildContext context, FileSystemEntity file) {
    showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('通知'),
        content: Text('是否确定删除${my_path.basename(file.path)}?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消', style: TextStyle(color: Colors.blue)),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            child: const Text('确定', style: TextStyle(color: Colors.blue)),
            onPressed: () {
              try {
                if (file.statSync().type == FileSystemEntityType.directory) {
                  Directory(file.path).deleteSync(recursive: true);
                } else {
                  file.deleteSync();
                }
                getCurrentPathFiles(file.parent.path);
              } catch (e) {
                flogErr(e, {}, 'FilePage', 'deleteFile');
                showToastWithContext(context, '删除失败');
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void renameFile(BuildContext context, FileSystemEntity file) {
    TextEditingController controller = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CupertinoAlertDialog(
            title: const Text('重命名'),
            content: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2.0)),
                  hintText: '请输入新名称 不含扩展名',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(2.0)),
                  contentPadding: const EdgeInsets.all(10.0),
                ),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('取消', style: TextStyle(color: Colors.blue)),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                child: const Text('确定', style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  String newName = controller.text;
                  if (newName.trim().isEmpty) {
                    showToastWithContext(context, '名称不能为空');
                    return;
                  }

                  String extension = my_path.extension(file.path);
                  if (newName.endsWith(extension)) {
                    newName = newName.substring(0, newName.length - extension.length);
                  }

                  String newPath = '${file.parent.path}/$newName$extension';
                  file.renameSync(newPath);
                  getCurrentPathFiles(file.parent.path);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
