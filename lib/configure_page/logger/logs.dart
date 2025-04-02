import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:f_logs/f_logs.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import 'package:horopic/widgets/net_loading_dialog.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_manage/common/loading_state.dart' as loading_state;

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  LogPageState createState() => LogPageState();
}

class LogPageState extends loading_state.BaseLoadingPageState<LogPage> {
  List<Log> logs = [];
  Map<String, dynamic> showedLogMap = {};
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAlllog();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String formatTimestamp(String timestamp) {
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    } catch (e) {
      return timestamp;
    }
  }

  Color getLogLevelColor(String logLevel) {
    const logColors = {
      'ERROR': Colors.red,
      'WARNING': Colors.orange,
      'INFO': Colors.blue,
      'DEBUG': Colors.green,
    };

    for (final level in logColors.keys) {
      if (logLevel.contains(level)) return logColors[level]!;
    }
    return Colors.grey;
  }

  getAlllog() async {
    try {
      logs = await FLog.getAllLogs();
      if (logs.isEmpty) {
        state = loading_state.LoadState.empty;
        setState(() {});
      } else {
        logs = logs.length > 150 ? logs.sublist(logs.length - 150, logs.length) : logs;
        showedLogMap.clear();
        for (var i = logs.length - 1; i >= 0; i--) {
          var id = logs[i].id.toString();
          showedLogMap[id] = {}
            ..['记录时间'] = logs[i].timestamp
            ..['类名'] = logs[i].className
            ..['方法名'] = logs[i].methodName
            ..['日志级别'] = logs[i].logLevel.toString()
            ..['日志内容'] = logs[i].text;
        }
        setState(() {
          state = loading_state.LoadState.success;
        });
      }
    } catch (e) {
      flogErr(e, {}, 'LogPageState', 'getAlllog');
      state = loading_state.LoadState.error;
      setState(() {});
    }
  }

  List<String> getFilteredLogIds() {
    if (searchQuery.isEmpty) {
      return showedLogMap.keys.toList();
    }

    return showedLogMap.keys.where((id) {
      final log = showedLogMap[id];
      return log['类名'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          log['方法名'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          log['日志内容'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          log['记录时间'].toString().toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  Widget buildLogList() {
    List<String> filteredIds = getFilteredLogIds();

    if (filteredIds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text('没有匹配的日志记录', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredIds.length,
      itemBuilder: (context, index) {
        return buildLogCard(filteredIds[index]);
      },
    );
  }

  Widget buildLogCard(String id) {
    final logData = showedLogMap[id];
    final logLevel = logData['日志级别'];
    final levelColor = getLogLevelColor(logLevel);
    final formattedTime = formatTimestamp(logData['记录时间']);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: levelColor.withValues(alpha: 0.3), width: 1),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: levelColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                logLevel.replaceAll('DataLogType.', ''),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    logData['类名'],
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    formattedTime,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Text(
          logData['方法名'],
          style: const TextStyle(fontSize: 12),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Row(
                  children: [
                    const Icon(Icons.notes, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text(
                      '日志内容:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      onPressed: () {
                        final detailedLog = '记录时间: ${logData['记录时间']}\n'
                            '类名: ${logData['类名']}\n'
                            '方法名: ${logData['方法名']}\n'
                            '日志级别: ${logData['日志级别']}\n'
                            '日志内容: ${logData['日志内容']}';
                        Clipboard.setData(ClipboardData(text: detailedLog));
                        showToast('日志已复制');
                      },
                      tooltip: '复制完整日志',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  constraints: const BoxConstraints(
                    maxHeight: 200,
                  ),
                  child: SelectableText(
                    logData['日志内容'],
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  exportLogToFile(BuildContext context) async {
    try {
      final logs = await FLog.getAllLogs();
      if (logs.isEmpty) {
        return showToast('暂无日志');
      }
      if (logs.length > 150) {
        logs.sublist(logs.length - 150, logs.length);
      }
      Map<String, dynamic> logMap = {};
      for (var i = logs.length - 1; i >= 0; i--) {
        var id = logs[i].id.toString();
        logMap[id] = {}
          ..['记录时间'] = logs[i].timestamp
          ..['类名'] = logs[i].className
          ..['方法名'] = logs[i].methodName
          ..['日志级别'] = logs[i].logLevel.toString()
          ..['日志内容'] = logs[i].text;
      }
      var buffer = StringBuffer();
      logMap.forEach((key, value) {
        buffer.write('ID: $key\n');
        buffer.write('记录时间: ${value['记录时间']}\n');
        buffer.write('类名: ${value['类名']}\n');
        buffer.write('方法名: ${value['方法名']}\n');
        buffer.write('日志级别: ${value['日志级别']}\n');
        buffer.write('日志内容: ${value['日志内容']}\n');
        buffer.write('-----------------------------------\n\n');
      });
      var path = (await getExternalStorageDirectory())!.path;
      String filePath = '$path/log';
      await Directory(filePath).create(recursive: true);
      String currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();
      File file = File('$filePath/PicHoro_Log_$currentTimestamp.txt');
      await file.writeAsString(buffer.toString());
      await Clipboard.setData(ClipboardData(text: buffer.toString()));
      if (context.mounted) {
        return showCupertinoAlertDialog(
            context: context, title: '导出成功', content: '导出成功，日志已复制到剪切板\n文件路径：\n${file.path}');
      }
    } catch (e) {
      flogErr(e, {}, 'LogPageState', 'exportLogToFile');
      if (context.mounted) {
        return showToastWithContext(context, '导出失败');
      }
    }
  }

  @override
  AppBar get appBar => AppBar(
        centerTitle: true,
        elevation: 0,
        title: titleText('软件日志'),
        leading: getLeadingIcon(context),
        flexibleSpace: getFlexibleSpace(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_sharp, color: Colors.white),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('清除日志'),
                  content: const Text('确定要清除所有日志吗？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        FLog.clearLogs();
                        setState(() {
                          logs.clear();
                          showedLogMap.clear();
                        });
                        showToast('日志已清空');
                        Navigator.of(context).pop();
                      },
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_present_outlined, color: Colors.white),
            onPressed: () async {
              await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return NetLoadingDialog(
                      outsideDismiss: false,
                      loading: true,
                      loadingText: "导出中...",
                      requestCallBack: exportLogToFile(context),
                    );
                  });
              setState(() {});
            },
          ),
        ],
      );

  @override
  String get emptyText => '暂无日志';

  @override
  void onErrorRetry() {
    setState(() {
      state = loading_state.LoadState.loading;
    });
    getAlllog();
  }

  @override
  Widget buildSuccess() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: '搜索日志...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          searchQuery = '';
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
        ),
        Expanded(
          child: showedLogMap.isEmpty ? buildEmpty() : buildLogList(),
        ),
      ],
    );
  }
}
