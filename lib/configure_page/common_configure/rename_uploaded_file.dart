import 'package:flutter/material.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';

class RenameFile extends StatefulWidget {
  const RenameFile({super.key});

  @override
  RenameFileState createState() => RenameFileState();
}

class RenameFileState extends State<RenameFile> {
  Map placeholderMap = {
    '{Y}': "年份(2022)",
    '{y}': "两位数年份(22)",
    '{m}': "月份(01-12)",
    '{d}': "日期(01-31)",
    '{h}': "小时(00-23)",
    '{i}': "分钟(00-59)",
    '{s}': "秒(00-59)",
    '{ms}': "毫秒(000-999)",
    '{timestamp}': "时间戳(毫秒)",
    '{uuid}': "唯一字符串",
    '{md5}': "随机md5",
    '{md5-16}': "随机md5前16位",
    '{str-number}': "随机number位字符串",
    '{filename}': "原始文件名",
  };

  Widget _buildSettingCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 8), // Add bottom padding
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required Widget child,
    Color? iconColor,
    Widget? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor ??
                  Theme.of(context).primaryColor.withValues(
                        alpha: 0.15,
                      ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: iconColor ?? Theme.of(context).primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        )),
                    child,
                  ],
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      child: subtitle,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
            color: Colors.grey.withValues(
          alpha: 0.2,
        )),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(
                    alpha: 0.15,
                  ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      "占位符",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "说明",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...placeholderMap.entries.map((entry) {
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                      color: Colors.grey.withValues(
                    alpha: 0.2,
                  )),
                ),
                color: Colors.white.withValues(alpha: 0.4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Center(
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 48,
                    color: Colors.grey.withValues(
                      alpha: 0.2,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Center(child: Text(entry.value)),
                    ),
                  ),
                ],
              ),
            );
          }),
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
        title: titleText('文件重命名'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(
                      alpha: 0.7,
                    ),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 12),
            _buildSettingCard(
              title: '重命名设置',
              children: [
                _buildSettingItem(
                  icon: Icons.access_time,
                  label: '时间戳重命名',
                  subtitle: const Text('优先级:自定义>时间戳>随机字符串'),
                  child: Switch(
                    value: Global.isTimeStamp,
                    onChanged: (value) async {
                      await Global.setIsTimeStamp(value);
                      setState(() {});
                    },
                  ),
                ),
                const Divider(height: 1, indent: 56),
                _buildSettingItem(
                  icon: Icons.shuffle,
                  label: '随机字符串重命名',
                  subtitle: const Text('固定30位字符串'),
                  child: Switch(
                    value: Global.isRandomName,
                    onChanged: (value) async {
                      await Global.setIsRandomName(value);
                      setState(() {});
                    },
                  ),
                ),
                const Divider(height: 1, indent: 56),
                _buildSettingItem(
                  icon: Icons.edit,
                  label: '自定义重命名',
                  child: Switch(
                    value: Global.isCustomRename,
                    onChanged: (value) async {
                      await Global.setIsCustomeRename(value);
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            _buildSettingCard(
              title: '自定义格式',
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: TextFormField(
                    initialValue: Global.customRenameFormat,
                    decoration: InputDecoration(
                      labelText: '自定义重命名格式',
                      hintText: r'规则参考下方表格，可随意组合其它字符',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      filled: true,
                      fillColor: Colors.grey.withValues(
                        alpha: 0.08,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    ),
                    onChanged: (String value) async {
                      await Global.setCustomeRenameFormat(value);
                    },
                  ),
                ),
              ],
            ),
            _buildSettingCard(
              title: '占位符规则表',
              children: [
                _buildPlaceholderTable(),
                const SizedBox(height: 8),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
