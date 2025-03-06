import 'package:flutter/material.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';

class CompressConfigure extends StatefulWidget {
  const CompressConfigure({super.key});

  @override
  CompressConfigureState createState() => CompressConfigureState();
}

class CompressConfigureState extends State<CompressConfigure> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText(
          '压缩选项',
        ),
      ),
      body: ListView(
        children: [
          ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                textAlign: TextAlign.center,
                initialValue: Global.minWidth.toString(),
                decoration: const InputDecoration(
                  label: Center(child: Text('最小宽度')),
                ),
                onChanged: (String value) async {
                  int width;
                  try {
                    width = int.parse(value);
                  } catch (e) {
                    showToast('格式错误');
                    return;
                  }
                  await Global.setminWidth(width);
                },
              ),
            ],
          ),
          ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                textAlign: TextAlign.center,
                initialValue: Global.minHeight.toString(),
                decoration: const InputDecoration(
                  label: Center(child: Text('最小高度')),
                ),
                onChanged: (String value) async {
                  int height;
                  try {
                    height = int.parse(value);
                  } catch (e) {
                    showToast('格式错误');
                    return;
                  }
                  await Global.setminHeight(height);
                },
              ),
            ],
          ),
          //quality
          ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                textAlign: TextAlign.center,
                initialValue: Global.quality.toString(),
                decoration: const InputDecoration(
                  label: Center(child: Text('压缩后质量')),
                ),
                onChanged: (String value) async {
                  int quality;
                  try {
                    quality = int.parse(value);
                  } catch (e) {
                    showToast('格式错误');
                    return;
                  }
                  if (quality < 0 || quality > 100) {
                    showToast('范围为0-100');
                    return;
                  }
                  await Global.setQuality(quality);
                },
              ),
              ListTile(
                title: const Text('压缩后格式'),
                trailing: DropdownButton<String>(
                  value: Global.defaultCompressFormat,
                  items: <String>[
                    'png',
                    'jpeg',
                    'webp',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) async {
                    await Global.setDefaultCompressFormat(value!);
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
