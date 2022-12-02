import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_manage/manage_api/github_manage_api.dart';

class GithubFileInformation extends StatefulWidget {
  final Map fileMap;
  const GithubFileInformation({Key? key, required this.fileMap})
      : super(key: key);

  @override
 GithubFileInformationState createState() => GithubFileInformationState();
}

class GithubFileInformationState extends State<GithubFileInformation> {
  @override
  initState() {
    super.initState();
  }

  getGithubFileInformation() async {
    var githubFileInformation =
        await GithubManageAPI.getRepoFileContent(widget.fileMap['showedUsername'],
            widget.fileMap['name'], widget.fileMap['path']);
    if (githubFileInformation[0] == 'success') {
      return githubFileInformation[1]['download_url'];
    }else{
      return 'error';
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('文件基本信息'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('文件名称'),
            subtitle: SelectableText(widget.fileMap['path'].split('/').last),
          ),
          ListTile(
            title: const Text('文件大小'),
            subtitle: SelectableText(getFileSize(widget.fileMap['size'])),
          ),
          ListTile(
            title: const Text('所在目录'),
            subtitle: widget.fileMap['dir'] == ''
                ? const Text('根目录')
                : SelectableText(widget.fileMap['dir']),
          ),
          ListTile(
            title: const Text('文件sha'),
            subtitle: SelectableText(widget.fileMap['sha']),
          ),
          widget.fileMap['private'] == false?
          ListTile(
            title: const Text('文件下载地址'),
            subtitle: SelectableText(widget.fileMap['downloadurl']),
          )
              :FutureBuilder(
            future: getGithubFileInformation(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if(snapshot.data == 'error'){
                  return const ListTile(
                    title: Text('文件下载地址'),
                    subtitle: Text('获取失败'),
                  );
                }else{
                  return ListTile(
                    title: const Text('文件下载地址'),
                    subtitle: SelectableText(Uri.decodeFull(snapshot.data)),
                  );
                }
              } else {
                return const ListTile(
                  title: Text('文件下载地址'),
                  subtitle: Text('获取中,请稍候···',style: TextStyle(color: Colors.blue,
                    fontWeight: FontWeight.bold),),
                );
              }
            },
          )
        ],
      ),
    );
  }
}
