import 'package:flutter/material.dart';
import 'package:horopic/utils/global.dart';

class RenameFile extends StatefulWidget {
  const RenameFile({Key? key}) : super(key: key);

  @override
  RenameFileState createState() => RenameFileState();
}

class RenameFileState extends State<RenameFile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         elevation: 0,
        centerTitle: true,
        title: const Text('文件重命名'),
      ),
      body: ListView(children: [
        ListTile(
          title: const Text('是否开启时间戳重命名'),
          subtitle: const Text('优先级按照自定义>时间戳>随机字符串'),
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
          subtitle: const Text('字符串长度固定为30'),
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
              children: const [
                TableRow(
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
                ),
                TableRow(
                  children: [
                    TableCell(child: Center(child: Text("{Y}"))),
                    TableCell(child: Center(child: Text("年份(2022)"))),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(child: Center(child: Text("{y}"))),
                    TableCell(child: Center(child: Text("两位数年份(22)"))),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(child: Center(child: Text("{m}"))),
                    TableCell(child: Center(child: Text("月份(01-12)"))),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(child: Center(child: Text("{d}"))),
                    TableCell(child: Center(child: Text("日期(01-31)"))),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(child: Center(child: Text("{timestamp}"))),
                    TableCell(child: Center(child: Text("时间戳(秒)"))),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(child: Center(child: Text("{uuid}"))),
                    TableCell(child: Center(child: Text("唯一字符串"))),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(child: Center(child: Text("{md5}"))),
                    TableCell(child: Center(child: Text("随机md5"))),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(child: Center(child: Text("{md5-16}"))),
                    TableCell(child: Center(child: Text("随机md5前16位"))),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(child: Center(child: Text("{str-10}"))),
                    TableCell(child: Center(child: Text("10位随机字符串"))),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(child: Center(child: Text("{str-20}"))),
                    TableCell(child: Center(child: Text("20位随机字符串"))),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(child: Center(child: Text("{filename}"))),
                    TableCell(child: Center(child: Text("原始文件名"))),
                  ],
                ),
              ],
            )),
      ]),
    );
  }
}
