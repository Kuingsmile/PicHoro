import 'package:flutter/material.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';

class CompressConfigure extends StatefulWidget {
  const CompressConfigure({super.key});

  @override
  CompressConfigureState createState() => CompressConfigureState();
}

class CompressConfigureState extends State<CompressConfigure> {
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _qualityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _widthController.text = Global.minWidth.toString();
    _heightController.text = Global.minHeight.toString();
    _qualityController.text = Global.quality.toString();
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    _qualityController.dispose();
    super.dispose();
  }

  Widget _buildSettingCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required Widget child,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor ??
                  Theme.of(context).primaryColor.withValues(
                        alpha: 0.2,
                      ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: getLeadingIcon(context),
        title: titleText('压缩选项'),
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 8),
          _buildSettingCard(
            title: '图片尺寸设置',
            children: [
              _buildSettingItem(
                icon: Icons.width_full,
                label: '最小宽度',
                child: TextField(
                  controller: _widthController,
                  textAlign: TextAlign.start,
                  decoration: const InputDecoration(
                    hintText: '超过此宽度的图片会被压缩',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (String value) async {
                    int width;
                    try {
                      width = int.parse(value);
                      Global.setminWidth(width);
                    } catch (e) {
                      showToast('格式错误');
                    }
                  },
                ),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingItem(
                icon: Icons.height,
                label: '最小高度',
                child: TextField(
                  controller: _heightController,
                  textAlign: TextAlign.start,
                  decoration: const InputDecoration(
                    hintText: '超过此高度的图片会被压缩',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (String value) async {
                    try {
                      Global.setminHeight(int.parse(value));
                    } catch (e) {
                      showToast('格式错误');
                    }
                  },
                ),
              ),
            ],
          ),
          _buildSettingCard(
            title: '压缩质量设置',
            children: [
              _buildSettingItem(
                icon: Icons.high_quality,
                label: '压缩后质量',
                child: TextField(
                  controller: _qualityController,
                  textAlign: TextAlign.start,
                  decoration: const InputDecoration(
                    hintText: '请输入0-100之间的值',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (String value) async {
                    int quality;
                    try {
                      quality = int.parse(value);
                      if (quality < 0 || quality > 100) {
                        showToast('范围为0-100');
                        return;
                      }
                      Global.setQuality(quality);
                    } catch (e) {
                      showToast('格式错误');
                    }
                  },
                ),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingItem(
                icon: Icons.format_paint,
                label: '压缩后格式',
                child: DropdownButton<String>(
                  value: Global.defaultCompressFormat,
                  isExpanded: true,
                  underline: Container(),
                  items: <String>[
                    'png',
                    'jpeg',
                    'webp',
                    'avif',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value) async {
                    if (value != null) {
                      Global.setDefaultCompressFormat(value);
                      setState(() {});
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
