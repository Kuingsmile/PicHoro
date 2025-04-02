import 'package:flutter/material.dart';
import 'package:horopic/picture_host_manage/common/info_page_utils.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:horopic/widgets/custom_speed_dial.dart';

class GithubRepoInformation extends StatefulWidget {
  final Map repoMap;
  const GithubRepoInformation({super.key, required this.repoMap});

  @override
  GithubRepoInformationState createState() => GithubRepoInformationState();
}

class GithubRepoInformationState extends State<GithubRepoInformation> {
  @override
  initState() {
    super.initState();
  }

  List<Widget> _buildBasicInfoSection() {
    return [
      buildInfoSection(
        '基本信息',
        [
          buildInfoItem(
            context: context,
            title: '仓库名称',
            value: widget.repoMap['name'],
            icon: Icons.folder,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '仓库ID',
            value: widget.repoMap['id'].toString(),
            icon: Icons.perm_identity,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '节点ID',
            value: widget.repoMap['node_id'] ?? '无',
            icon: Icons.code,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '仓库描述',
            value: widget.repoMap['description'] ?? '无',
            icon: Icons.description,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '仓库是否私有',
            value: widget.repoMap['private'] == null
                ? '无'
                : widget.repoMap['private']
                    ? '是'
                    : '否',
            icon: Icons.lock,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '来自fork',
            value: widget.repoMap['fork'] == null
                ? '无'
                : widget.repoMap['fork']
                    ? '是'
                    : '否',
            icon: Icons.fork_right,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildRepoDetailsSection() {
    return [
      buildInfoSection(
        '仓库详情',
        [
          buildInfoItem(
            context: context,
            title: '仓库默认分支',
            value: widget.repoMap['default_branch'] ?? '无',
            icon: Icons.account_tree,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '仓库语言',
            value: widget.repoMap['language'] ?? '无',
            icon: Icons.code,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '仓库大小',
            value: widget.repoMap['size'] == null ? '无' : getFileSize(widget.repoMap['size'] * 1024),
            icon: Icons.storage,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '仓库协议',
            value: widget.repoMap['license'] == null ? '无' : widget.repoMap['license']['name'],
            icon: Icons.gavel,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '仓库主页',
            value: widget.repoMap['homepage'] ?? '无',
            icon: Icons.home,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '仓库topics',
            value: widget.repoMap['topics'] == null || widget.repoMap['topics'].isEmpty
                ? '无'
                : widget.repoMap['topics'].toString(),
            icon: Icons.tag,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildStatsSection() {
    return [
      buildInfoSection(
        '仓库统计',
        [
          buildInfoItem(
            context: context,
            title: '仓库star数量',
            value: widget.repoMap['stargazers_count']?.toString() ?? '无',
            icon: Icons.star,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '仓库fork数量',
            value: widget.repoMap['forks_count']?.toString() ?? '无',
            icon: Icons.fork_right,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '仓库open issue数量',
            value: widget.repoMap['open_issues_count']?.toString() ?? '无',
            icon: Icons.error_outline,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildTimestampsSection() {
    return [
      buildInfoSection(
        '时间信息',
        [
          buildInfoItem(
            context: context,
            title: '创建时间',
            value: widget.repoMap['created_at'] == null
                ? '无'
                : widget.repoMap['created_at'].toString().replaceAll('T', ' ').replaceAll('Z', ''),
            icon: Icons.create,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '更新时间',
            value: widget.repoMap['updated_at'] == null
                ? '无'
                : widget.repoMap['updated_at'].toString().replaceAll('T', ' ').replaceAll('Z', ''),
            icon: Icons.update,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '推送时间',
            value: widget.repoMap['pushed_at'] == null
                ? '无'
                : widget.repoMap['pushed_at'].toString().replaceAll('T', ' ').replaceAll('Z', ''),
            icon: Icons.upload,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildUrlsSection() {
    return [
      buildInfoSection(
        '仓库链接',
        [
          buildInfoItem(
            context: context,
            title: '仓库网页地址',
            value: widget.repoMap['html_url'] ?? '无',
            icon: Icons.web,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '仓库git地址',
            value: widget.repoMap['git_url'] ?? '无',
            icon: Icons.link,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '仓库ssh地址',
            value: widget.repoMap['ssh_url'] ?? '无',
            icon: Icons.vpn_key,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '仓库clone地址',
            value: widget.repoMap['clone_url'] ?? '无',
            icon: Icons.file_copy,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '仓库svn地址',
            value: widget.repoMap['svn_url'] ?? '无',
            icon: Icons.source,
            copyable: true,
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: getLeadingIcon(context),
        title: titleText('仓库信息'),
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          ..._buildBasicInfoSection(),
          ..._buildRepoDetailsSection(),
          ..._buildStatsSection(),
          ..._buildTimestampsSection(),
          ..._buildUrlsSection(),
          const SizedBox(height: 16),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.more_vert,
        activeIcon: Icons.close,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.content_copy),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            label: '复制仓库名称',
            onTap: () => copyToClipboard(context, widget.repoMap['name']),
          ),
          SpeedDialChild(
            child: const Icon(Icons.link),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: '复制仓库地址',
            onTap: () => copyToClipboard(context, widget.repoMap['html_url'] ?? ''),
          ),
          SpeedDialChild(
            child: const Icon(Icons.code),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            label: '复制Clone地址',
            onTap: () => copyToClipboard(context, widget.repoMap['clone_url'] ?? ''),
          ),
          SpeedDialChild(
            child: const Icon(Icons.share),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            label: '分享仓库信息',
            onTap: () {
              final shareText = '${widget.repoMap['name']} - ${widget.repoMap['description'] ?? ''}\n'
                  '${widget.repoMap['html_url']}';
              copyToClipboard(context, shareText);
            },
          ),
        ],
      ),
    );
  }
}
