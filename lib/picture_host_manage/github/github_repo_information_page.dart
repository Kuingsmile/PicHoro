import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';

class GithubRepoInformation extends StatefulWidget {
  final Map repoMap;
  const GithubRepoInformation({Key? key, required this.repoMap})
      : super(key: key);

  @override
  GithubRepoInformationState createState() => GithubRepoInformationState();
}

class GithubRepoInformationState extends State<GithubRepoInformation> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('仓库信息'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('仓库名称',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(widget.repoMap['name']),
          ),
          ListTile(
            title: const Text('仓库ID',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['id'].toString(),
            ),
          ),
          ListTile(
            title: const Text('节点ID',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['node_id'] == null
                  ? '无'
                  : widget.repoMap['node_id'].toString(),
            ),
          ),
          ListTile(
            isThreeLine: true,
            title: const Text('仓库描述',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['description'] == null
                  ? '无'
                  : widget.repoMap['description'].toString(),
            ),
          ),
          ListTile(
            title: const Text('仓库网页地址',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['html_url'] == null
                  ? '无'
                  : widget.repoMap['html_url'].toString(),
            ),
          ),
          ListTile(
            title: const Text('仓库git地址',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['git_url'] == null
                  ? '无'
                  : widget.repoMap['git_url'].toString(),
            ),
          ),
          ListTile(
            title: const Text('仓库ssh地址',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['ssh_url'] == null
                  ? '无'
                  : widget.repoMap['ssh_url'].toString(),
            ),
          ),
          ListTile(
            title: const Text('仓库svn地址',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['svn_url'] == null
                  ? '无'
                  : widget.repoMap['svn_url'].toString(),
            ),
          ),
          ListTile(
            title: const Text('仓库clone地址',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['clone_url'] == null
                  ? '无'
                  : widget.repoMap['clone_url'].toString(),
            ),
          ),
          ListTile(
            title: const Text('来自fork',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['fork'] == null
                  ? '无'
                  : widget.repoMap['fork'].toString(),
            ),
          ),
          ListTile(
            title: const Text('创建时间',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['created_at'] == null
                  ? '无'
                  : widget.repoMap['created_at']
                      .toString()
                      .replaceAll('T', ' ')
                      .replaceAll('Z', ''),
            ),
          ),
          ListTile(
            title: const Text('更新时间',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['updated_at'] == null
                  ? '无'
                  : widget.repoMap['updated_at']
                      .toString()
                      .replaceAll('T', ' ')
                      .replaceAll('Z', ''),
            ),
          ),
          ListTile(
            title: const Text('推送时间',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['pushed_at'] == null
                  ? '无'
                  : widget.repoMap['pushed_at']
                      .toString()
                      .replaceAll('T', ' ')
                      .replaceAll('Z', ''),
            ),
          ),
          ListTile(
            title: const Text('仓库大小',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['size'] == null
                  ? '无'
                  : getFileSize(widget.repoMap['size'] * 1024),
            ),
          ),
          ListTile(
            title: const Text('仓库主页',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['homepage'] == null
                  ? '无'
                  : widget.repoMap['homepage'].toString(),
            ),
          ),
          ListTile(
            title: const Text('仓库语言',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['language'] == null
                  ? '无'
                  : widget.repoMap['language'].toString(),
            ),
          ),
          ListTile(
            title: const Text('仓库是否私有',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['private'] == null
                  ? '无'
                  : widget.repoMap['private'].toString(),
            ),
          ),
          ListTile(
            title: const Text('仓库star数量',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['stargazers_count'] == null
                  ? '无'
                  : widget.repoMap['stargazers_count'].toString(),
            ),
          ),
          ListTile(
            title: const Text('仓库fork数量',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['forks_count'] == null
                  ? '无'
                  : widget.repoMap['forks_count'].toString(),
            ),
          ),
          ListTile(
            title: const Text('仓库open issue数量',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['open_issues_count'] == null
                  ? '无'
                  : widget.repoMap['open_issues_count'].toString(),
            ),
          ),
          ListTile(
            title: const Text('仓库默认分支',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['default_branch'] == null
                  ? '无'
                  : widget.repoMap['default_branch'].toString(),
            ),
          ),
          ListTile(
            title: const Text('仓库协议',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['license'] == null
                  ? '无'
                  : widget.repoMap['license']['name'].toString(),
            ),
          ),
          ListTile(
            title: const Text('仓库topics',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            subtitle: SelectableText(
              widget.repoMap['topics'] == null ||
                      widget.repoMap['topics'].length == 0
                  ? '无'
                  : widget.repoMap['topics'].toString(),
            ),
          ),
        ],
      ),
    );
  }
}
