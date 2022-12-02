import 'package:flutter/material.dart';

import 'package:horopic/picture_host_manage/manage_api/github_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/pages/loading.dart';

class GithubNewRepoConfig extends StatefulWidget {
  const GithubNewRepoConfig({
    Key? key,
  }) : super(key: key);

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

  // ignore: non_constant_identifier_names
  List<String> gitignore_templateList = [
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

  // ignore: non_constant_identifier_names
  Map<String, String> license_template = {
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('新建仓库'),
      ),
      body: ListView(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              label: Center(child: Text('仓库名称')),
              hintText: '设定仓库名称',
            ),
            controller: repoNameController,
            textAlign: TextAlign.center,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入仓库名称';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              label: Center(child: Text('可选：仓库描述')),
              hintText: '设定仓库描述',
            ),
            controller: descriptionController,
            textAlign: TextAlign.center,
          ),
          TextFormField(
            decoration: const InputDecoration(
              label: Center(child: Text('可选：仓库主页')),
              hintText: '主页网址',
            ),
            controller: homepageController,
            textAlign: TextAlign.center,
          ),
          ListTile(
            title: const Text('gitignore模板'),
            trailing: DropdownButton(
              alignment: Alignment.centerRight,
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, size: 30),
              autofocus: true,
              value: githubManageConfigMap['gitignore_template'],
              items: createFromList(gitignore_templateList, 15),
              onChanged: (value) {
                githubManageConfigMap['gitignore_template'] = value;
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('许可证'),
            trailing: DropdownButton(
              alignment: Alignment.centerRight,
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, size: 30),
              autofocus: true,
              value: githubManageConfigMap['license_template'],
              items: createFromMap(license_template, 14),
              onChanged: (value) {
                githubManageConfigMap['license_template'] = value;
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('是否私有'),
            trailing: Switch(
              value: githubManageConfigMap['private'],
              onChanged: (value) {
                githubManageConfigMap['private'] = value;
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('是否初始化README'),
            trailing: Switch(
              value: githubManageConfigMap['auto_init'],
              onChanged: (value) {
                githubManageConfigMap['auto_init'] = value;
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('是否启用issues'),
            trailing: Switch(
              value: githubManageConfigMap['has_issues'],
              onChanged: (value) {
                githubManageConfigMap['has_issues'] = value;
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('是否启用wiki'),
            trailing: Switch(
              value: githubManageConfigMap['has_wiki'],
              onChanged: (value) {
                githubManageConfigMap['has_wiki'] = value;
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('是否启用projects'),
            trailing: Switch(
              value: githubManageConfigMap['has_projects'],
              onChanged: (value) {
                githubManageConfigMap['has_projects'] = value;
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('是否作为模板'),
            trailing: Switch(
              value: githubManageConfigMap['is_template'],
              onChanged: (value) {
                githubManageConfigMap['is_template'] = value;
                setState(() {});
              },
            ),
          ),
          ListTile(
            subtitle: ElevatedButton(
              onPressed: () async {
                if (descriptionController.text.isNotEmpty) {
                  githubManageConfigMap['description'] =
                      descriptionController.text;
                }
                if (homepageController.text.isNotEmpty) {
                  githubManageConfigMap['homepage'] = homepageController.text;
                }
                if (repoNameController.text.isEmpty) {
                  showToast('请输入仓库名称');
                  return;
                } else {
                  githubManageConfigMap['name'] = repoNameController.text;
                }
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
                        requestCallBack: GithubManageAPI.createRepo(
                          githubManageConfigMap,
                        ),
                      );
                    });
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('创建'),
            ),
          ),
        ],
      ),
    );
  }
}
