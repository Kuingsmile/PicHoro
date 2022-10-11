import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';

class UpdateLog extends StatefulWidget {
  const UpdateLog({Key? key}) : super(key: key);

  @override
  _UpdateLogState createState() => _UpdateLogState();
}

class _UpdateLogState extends State<UpdateLog> {
  late Future<String> _future;

  @override
  void initState() {
    super.initState();
    _future = rootBundle.loadString('assets/files/UpdateLog.md');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('更新日志'),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Markdown(
              data: snapshot.data!,
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

