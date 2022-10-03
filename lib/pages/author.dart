import 'package:flutter/material.dart';

class AuthorInformation extends StatelessWidget {
  const AuthorInformation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('作者信息'),
        ),
        body: ListView(
          children: [
            Center(
              child: Image.asset(
                'assets/wechat_author.jpg',
                width: 200,
                height: 200,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/qq_author.jpg',
                width: 200,
                height: 200,
              ),
            ),
          ],
        ));
  }
}
