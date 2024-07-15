import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:f_logs/f_logs.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_manage/common_page/loading_state.dart' as loading_state;

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  LogPageState createState() => LogPageState();
}

class LogPageState extends loading_state.BaseLoadingPageState<LogPage> {
  List<Log> logs = [];
  Map<String, dynamic> showedLogMap = {};

  @override
  void initState() {
    super.initState();
    getAlllog();
  }

  getAlllog() async {
    try {
      logs = await FLog.getAllLogs();
      if (logs.isEmpty) {
        state = loading_state.LoadState.EMPTY;
        setState(() {});
      } else {
        logs = logs.length > 150 ? logs.sublist(logs.length - 150, logs.length) : logs;
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
          state = loading_state.LoadState.SUCCESS;
        });
      }
    } catch (e) {
      FLog.error(
          className: 'LogPageState',
          methodName: 'getAlllog',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      state = loading_state.LoadState.ERROR;
      setState(() {});
    }
  }

  Widget buildLogList() {
    List<Widget> logWidgets = [];
    List ids = showedLogMap.keys.toList();
    for (var i = 0; i < ids.length; i++) {
      logWidgets.add(buildLog(ids[i]));
      logWidgets.add(const Divider(
        height: 4,
        color: Colors.black,
      ));
    }
    return ListView(
      children: logWidgets,
    );
  }

  buildLog(String id) {
    Widget table = Column(
      children: [
        DataTable(
          columns: <DataColumn>[
            const DataColumn(
              label: Center(
                child: SelectableText(
                  '记录时间',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            DataColumn(
              label: Center(
                child: SelectableText(
                  showedLogMap[id]['记录时间'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
          rows: <DataRow>[
            DataRow(
              cells: <DataCell>[
                const DataCell(
                  Center(
                    child: SelectableText(
                      '类名',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataCell(
                  Center(
                    child: SelectableText(
                      showedLogMap[id]['类名'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                const DataCell(
                  Center(
                    child: SelectableText(
                      '方法名',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataCell(
                  Center(
                    child: SelectableText(
                      showedLogMap[id]['方法名'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            DataRow(
              cells: <DataCell>[
                const DataCell(
                  Center(
                    child: SelectableText(
                      '日志级别',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                DataCell(
                  Center(
                    child: SelectableText(
                      showedLogMap[id]['日志级别'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(
            height: 130,
            width: 300,
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: SelectableText(
                      showedLogMap[id.toString()]['日志内容'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ))),
      ],
    );
    return table;
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
        buffer.write('$key\n');
        value.forEach((key, value) {
          buffer.write('$key: $value\n');
        });
        buffer.write('\n');
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
      FLog.error(
          className: 'LogPageState',
          methodName: 'exportLogToFile',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      if (context.mounted) {
        return showToastWithContext(context, '导出失败');
      }
    }
  }

  @override
  AppBar get appBar => AppBar(
        centerTitle: true,
        elevation: 0,
        title: titleText(
          '软件日志',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.cleaning_services_sharp,
              color: Colors.white,
            ),
            onPressed: () async {
              FLog.clearLogs();
              setState(() {
                logs.clear();
                showedLogMap.clear();
              });
              showToast('日志已清空');
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
  Widget buildLoading() {
    return const Center(
      child: SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation(Colors.blue),
        ),
      ),
    );
  }

  @override
  Widget buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty.png',
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 20),
          const Text('没有已记录的日志', style: TextStyle(fontSize: 20, color: Color.fromARGB(136, 121, 118, 118)))
        ],
      ),
    );
  }

  @override
  Widget buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('加载失败,请重试', style: TextStyle(fontSize: 20, color: Color.fromARGB(136, 121, 118, 118))),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            onPressed: () {
              setState(() {
                state = loading_state.LoadState.LOADING;
              });
              getAlllog();
            },
            child: const Text('重新加载'),
          )
        ],
      ),
    );
  }

  @override
  Widget buildSuccess() {
    return showedLogMap.isEmpty ? buildEmpty() : buildLogList();
  }
}
