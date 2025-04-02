import 'package:flutter/material.dart';

import 'package:horopic/picture_host_manage/manage_api/github_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:horopic/widgets/net_loading_dialog.dart';

class GithubNewRepoConfig extends StatefulWidget {
  const GithubNewRepoConfig({
    super.key,
  });

  @override
  GithubNewRepoConfigState createState() => GithubNewRepoConfigState();
}

class GithubNewRepoConfigState extends State<GithubNewRepoConfig> {
  Map githubManageConfigMap = {
    'private': false,
    'has_issues': true,
    'has_projects': true,
    'has_wiki': true,
    'auto_init': true,
    'gitignore_template': 'None',
    'license_template': 'None',
    'is_template': false,
  };

  resetgithubManageConfigMap() {
    githubManageConfigMap = {
      'private': false,
      'has_issues': true,
      'has_projects': true,
      'has_wiki': true,
      'auto_init': true,
      'gitignore_template': 'None',
      'license_template': 'None',
      'is_template': false,
    };
  }

  @override
  initState() {
    super.initState();
    resetgithubManageConfigMap();
  }

  List<String> gitignoreTemplates = [
    'None',
    'Actionscript',
    'Ada',
    'Agda',
    'Android',
    'AppEngine',
    'AppceleratorTitanium',
    'ArchLinuxPackages',
    'Autotools',
    'C',
    'C++',
    'CFWheels',
    'CMake',
    'CUDA',
    'CakePHP',
    'ChefCookbook',
    'Clojure',
    'CodeIgniter',
    'CommonLisp',
    'Composer',
    'Concrete5',
    'Coq',
    'CraftCMS',
    'D',
    'DM',
    'Dart',
    'Delphi',
    'Drupal',
    'EPiServer',
    'Eagle',
    'Elisp',
    'Elixir',
    'Elm',
    'Erlang',
    'ExpressionEngine',
    'ExtJS',
    'Fancy',
    'Finale',
    'ForceDotCom',
    'Fortran',
    'FuelPHP',
    'GWT',
    'GitBook',
    'Go',
    'Godot',
    'Gradle',
    'Grails',
    'Haskell',
    'IGORPro',
    'Idris',
    'JENKINS_HOME',
    'Java',
    'Jboss',
    'Jekyll',
    'Joomla',
    'Julia',
    'KiCAD',
    'Kohana',
    'Kotlin',
    'LabVIEW',
    'Laravel',
    'Leiningen',
    'LemonStand',
    'Lilypond',
    'Lithium',
    'Lua',
    'Magento',
    'Maven',
    'Mercury',
    'MetaprogrammingSystem',
    'Nim',
    'Node',
    'OCaml',
    'Objective-C',
    'Opa',
    'OracleForms',
    'Packer',
    'Perl',
    'Perl6',
    'Phalcon',
    'PlayFramework',
    'Plone',
    'Prestashop',
    'Processing',
    'PureScript',
    'Python',
    'Qooxdoo',
    'Qt',
    'R',
    'ROS',
    'Rails',
    'RhodesRhomobile',
    'Ruby',
    'Rust',
    'SCons',
    'Sass',
    'Scala',
    'Scheme',
    'Scrivener',
    'Sdcc',
    'SeamGen',
    'SketchUp',
    'Smalltalk',
    'SugarCRM',
    'Swift',
    'Symfony',
    'SymphonyCMS',
    'TeX',
    'Terraform',
    'Textpattern',
    'TurboGears2',
    'Typo3',
    'Umbraco',
    'Unity',
    'UnrealEngine',
    'VVVV',
    'VisualStudio',
    'Waf',
    'WordPress',
    'Xojo',
    'Yeoman',
    'Yii',
    'ZendFramework',
    'Zephir',
    'gcov',
    'nanoc',
    'opencart',
    'stella',
  ];

  Map<String, String> licenseTemplate = {
    'None': 'None',
    'Apache License 2.0': 'apache-2.0',
    'GNU General Public License v3.0': 'gpl-3.0',
    'MIT License': 'mit',
    'BSD 2-Clause "Simplified" License': 'bsd-2-clause',
    'BSD 3-Clause "New" or "Revised" License': 'bsd-3-clause',
    'Boost Software License 1.0': 'bsl-1.0',
    'Creative Commons Zero v1.0 Universal': 'cc0-1.0',
    'Eclipse Public License 2.0': 'epl-2.0',
    'GNU Affero General Public License v3.0': 'agpl-3.0',
    'GNU General Public License v2.0': 'gpl-2.0',
    'GNU Lesser General Public License v2.1': 'lgpl-2.1',
    'Mozilla Public License 2.0': 'mpl-2.0',
    'The Unlicense': 'unlicense',
  };

  TextEditingController repoNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController homepageController = TextEditingController();

  @override
  void dispose() {
    repoNameController.dispose();
    descriptionController.dispose();
    homepageController.dispose();
    super.dispose();
  }

  List<DropdownMenuItem> createFromList(List<String> list, int fontsize) {
    List<DropdownMenuItem> items = [];
    for (String item in list) {
      items.add(DropdownMenuItem(
        value: item,
        child: Text(item, style: TextStyle(fontSize: fontsize.toDouble())),
      ));
    }
    return items;
  }

  List<DropdownMenuItem> createFromMap(Map<String, String> map, int fontsize) {
    List<DropdownMenuItem> items = [];
    for (String key in map.keys) {
      items.add(DropdownMenuItem(
        value: map[key],
        child: Text(key, style: TextStyle(fontSize: fontsize.toDouble())),
      ));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: getLeadingIcon(context),
        title: titleText('新建仓库'),
        flexibleSpace: getFlexibleSpace(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: '重置设置',
            onPressed: () {
              setState(() {
                resetgithubManageConfigMap();
                repoNameController.clear();
                descriptionController.clear();
                homepageController.clear();
              });
              showToast('设置已重置');
            },
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Basic Info Card
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '基本信息',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: '仓库名称',
                        hintText: '设定仓库名称',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.folder),
                      ),
                      controller: repoNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入仓库名称';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: '仓库描述 (可选)',
                        hintText: '设定仓库描述',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      controller: descriptionController,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: '仓库主页 (可选)',
                        hintText: '主页网址',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.language),
                      ),
                      controller: homepageController,
                    ),
                  ],
                ),
              ),
            ),

            // Templates Card
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '模板选择',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField(
                      decoration: const InputDecoration(
                        labelText: 'gitignore模板',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.code),
                      ),
                      isExpanded: true,
                      value: githubManageConfigMap['gitignore_template'],
                      items: createFromList(gitignoreTemplates, 15),
                      onChanged: (value) {
                        githubManageConfigMap['gitignore_template'] = value;
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField(
                      decoration: const InputDecoration(
                        labelText: '许可证',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.gavel),
                      ),
                      isExpanded: true,
                      value: githubManageConfigMap['license_template'],
                      items: createFromMap(licenseTemplate, 14),
                      onChanged: (value) {
                        githubManageConfigMap['license_template'] = value;
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Settings Card
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '仓库设置',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SwitchListTile(
                      title: const Text('私有仓库'),
                      subtitle: const Text('仅对您和您选择的协作者可见'),
                      value: githubManageConfigMap['private'],
                      onChanged: (value) {
                        githubManageConfigMap['private'] = value;
                        setState(() {});
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('初始化README'),
                      subtitle: const Text('创建包含仓库名的README文件'),
                      value: githubManageConfigMap['auto_init'],
                      onChanged: (value) {
                        githubManageConfigMap['auto_init'] = value;
                        setState(() {});
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('启用Issues'),
                      subtitle: const Text('问题追踪和反馈功能'),
                      value: githubManageConfigMap['has_issues'],
                      onChanged: (value) {
                        githubManageConfigMap['has_issues'] = value;
                        setState(() {});
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('启用Wiki'),
                      subtitle: const Text('项目文档和知识库'),
                      value: githubManageConfigMap['has_wiki'],
                      onChanged: (value) {
                        githubManageConfigMap['has_wiki'] = value;
                        setState(() {});
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('启用Projects'),
                      subtitle: const Text('项目管理工具'),
                      value: githubManageConfigMap['has_projects'],
                      onChanged: (value) {
                        githubManageConfigMap['has_projects'] = value;
                        setState(() {});
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('作为模板'),
                      subtitle: const Text('允许其他用户将此仓库用作模板'),
                      value: githubManageConfigMap['is_template'],
                      onChanged: (value) {
                        githubManageConfigMap['is_template'] = value;
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Create Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }

                  if (descriptionController.text.isNotEmpty) {
                    githubManageConfigMap['description'] = descriptionController.text;
                  }
                  if (homepageController.text.isNotEmpty) {
                    githubManageConfigMap['homepage'] = homepageController.text;
                  }
                  githubManageConfigMap['name'] = repoNameController.text;

                  if (githubManageConfigMap['gitignore_template'] == 'None') {
                    githubManageConfigMap.remove('gitignore_template');
                  }
                  if (githubManageConfigMap['license_template'] == 'None') {
                    githubManageConfigMap.remove('license_template');
                  }

                  await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return NetLoadingDialog(
                          outsideDismiss: false,
                          loading: true,
                          loadingText: "创建中...",
                          requestCallBack: GithubManageAPI().createRepo(
                            githubManageConfigMap,
                          ),
                        );
                      });

                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.create_new_folder),
                label: const Text('创建仓库', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
