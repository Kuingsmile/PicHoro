import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_manage/manage_api/github_manage_api.dart';
import 'package:horopic/widgets/common_widgets.dart';

class GithubFileInformation extends StatefulWidget {
  final Map fileMap;
  const GithubFileInformation({super.key, required this.fileMap});

  @override
  GithubFileInformationState createState() => GithubFileInformationState();
}

class GithubFileInformationState extends State<GithubFileInformation> {
  @override
  initState() {
    super.initState();
  }

  getGithubFileInformation() async {
    var githubFileInformation = await GithubManageAPI()
        .getRepoFileContent(widget.fileMap['showedUsername'], widget.fileMap['name'], widget.fileMap['path']);
    if (githubFileInformation[0] == 'success') {
      return githubFileInformation[1]['download_url'];
    }
    return 'error';
  }

  Widget _buildInfoCard({required String title, required String content, IconData? icon}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) Icon(icon, size: 20, color: Colors.blue),
                if (icon != null) const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    content,
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                ),
                if (content != '获取中,请稍候···' && content != '获取失败' && content != '根目录')
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: content));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('已复制到剪贴板'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
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
        title: titleText('文件基本信息'),
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildInfoCard(
            title: '文件名称',
            content: widget.fileMap['path'].split('/').last,
            icon: Icons.insert_drive_file,
          ),
          _buildInfoCard(
            title: '文件大小',
            content: getFileSize(widget.fileMap['size']),
            icon: Icons.data_usage,
          ),
          _buildInfoCard(
            title: '所在目录',
            content: widget.fileMap['dir'] == '' ? '根目录' : widget.fileMap['dir'],
            icon: Icons.folder,
          ),
          _buildInfoCard(
            title: '文件SHA',
            content: widget.fileMap['sha'],
            icon: Icons.fingerprint,
          ),
          widget.fileMap['private'] == false
              ? _buildInfoCard(
                  title: '文件下载地址',
                  content: widget.fileMap['downloadurl'],
                  icon: Icons.download,
                )
              : FutureBuilder(
                  future: getGithubFileInformation(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    String content;
                    bool isLoading = !snapshot.hasData;

                    if (isLoading) {
                      content = '获取中,请稍候···';
                    } else if (snapshot.data == 'error') {
                      content = '获取失败';
                    } else {
                      content = Uri.decodeFull(snapshot.data);
                    }

                    return Column(
                      children: [
                        _buildInfoCard(
                          title: '文件下载地址',
                          content: content,
                          icon: Icons.download,
                        ),
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    );
                  },
                )
        ],
      ),
    );
  }
}
