import 'package:flutter/material.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';

class RenameFile extends StatefulWidget {
  const RenameFile({Key? key}) : super(key: key);

  @override
  RenameFileState createState() => RenameFileState();
}

class RenameFileState extends State<RenameFile> {
  Map placeholderMap = {
    '{Y}': "年份(2022)",
    '{y}': "两位数年份(22)",
    '{m}': "月份(01-12)",
    '{d}': "日期(01-31)",
    '{timestamp}': "时间戳(秒)",
    '{uuid}': "唯一字符串",
    '{md5}': "随机md5",
    '{md5-16}': "随机md5前16位",
    '{str-10}': "随机10位字符串",
    '{str-20}': "随机20位字符串",
    '{filename}': "原文件名",
  };

  @override
  void initState() {
    super.initState();
  }

  TableRow _buildTableRow(String key, String value) {
    return TableRow(
      children: [
        TableCell(child: Center(child: Text(key))),
        TableCell(child: Center(child: Text(value))),
      ],
    );
  }

  List<TableRow> _buildTableRows() {
    List<TableRow> rows = [];
    placeholderMap.forEach((key, value) {
      rows.add(_buildTableRow(key, value));
    });
    return rows;
  }

  List<TableRow> _buildTable() {
    List<TableRow> temp = [
      const TableRow(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
            ),
          ),
          color: Colors.grey,
        ),
        children: [
          TableCell(child: Center(child: Text("占位符"))),
          TableCell(child: Center(child: Text("说明"))),
        ],
      )
    ];
    temp.addAll(_buildTableRows());
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText(
          '文件重命名',
        ),
      ),
      body: ListView(children: [
        ListTile(
          title: const Text('是否开启时间戳重命名'),
          subtitle: const Text('优先级:自定义>时间戳>随机字符串'),
          trailing: Switch(
            value: Global.isTimeStamp,
            onChanged: (value) async {
              await Global.setTimeStamp(value);
              setState(() {});
            },
          ),
        ),
        ListTile(
          title: const Text('是否开启随机字符串重命名'),
          subtitle: const Text('固定30位字符串'),
          trailing: Switch(
            value: Global.isRandomName,
            onChanged: (value) async {
              await Global.setRandomName(value);
              setState(() {});
            },
          ),
        ),
        ListTile(
          title: const Text('是否使用自定义重命名'),
          trailing: Switch(
            value: Global.iscustomRename,
            onChanged: (value) async {
              await Global.setCustomeRename(value);
              setState(() {});
            },
          ),
        ),
        ListView(
          shrinkWrap: true,
          children: [
            TextFormField(
              textAlign: TextAlign.center,
              initialValue: Global.customRenameFormat,
              decoration: const InputDecoration(
                label: Center(child: Text('自定义重命名格式')),
                hintText: r'规则参考表格，可随意组合其它字符',
              ),
              onChanged: (String value) async {
                await Global.setCustomeRenameFormat(value);
              },
            ),
          ],
        ),
        Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            child: Table(
              border: TableBorder.all(
                color: Colors.black,
                width: 1,
                style: BorderStyle.solid,
                borderRadius: BorderRadius.circular(5),
              ),
              children: _buildTable(),
            )),
      ]),
    );
  }
}
