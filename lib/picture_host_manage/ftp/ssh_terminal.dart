import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:horopic/picture_host_manage/ftp/virtual_keyboard.dart';
import 'package:xterm/xterm.dart';

class SSHTermimal extends StatefulWidget {
  final Map configMap;
  const SSHTermimal({
    Key? key,
    required this.configMap,
  }) : super(key: key);

  @override
  SSHTermimalState createState() => SSHTermimalState();
}

class SSHTermimalState extends State<SSHTermimal> {
  late final terminal = Terminal(inputHandler: keyboard);

  final keyboard = VirtualKeyboard(defaultInputHandler);

  var title = '';

  @override
  void initState() {
    title = widget.configMap['ftpHost'];
    super.initState();
    initTerminal();
  }

  Future<void> initTerminal() async {
    terminal.write('连接中...\r\n');

    final client = SSHClient(
      await SSHSocket.connect(widget.configMap['ftpHost'], int.parse(widget.configMap['ftpPort'].toString())),
      username: widget.configMap['ftpUser'],
      onPasswordRequest: () => widget.configMap['ftpPassword'],
    );

    terminal.write('连接成功\r\n');

    final session = await client.shell(
      pty: SSHPtyConfig(
        width: terminal.viewWidth,
        height: terminal.viewHeight,
      ),
    );

    terminal.buffer.clear();
    terminal.buffer.setCursor(0, 0);

    terminal.onTitleChange = (title) {
      setState(() => this.title = title);
    };

    terminal.onResize = (width, height, pixelWidth, pixelHeight) {
      session.resizeTerminal(width, height, pixelWidth, pixelHeight);
    };

    terminal.onOutput = (data) {
      session.write(utf8.encode(data) as Uint8List);
    };

    session.stdout.cast<List<int>>().transform(const Utf8Decoder()).listen(terminal.write);

    session.stderr.cast<List<int>>().transform(const Utf8Decoder()).listen(terminal.write);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(widget.configMap['ftpHost'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: TerminalView(
              terminal,
              textStyle: const TerminalStyle(
                fontSize: 16,
                fontFamily: 'RobotoMono',
              ),
            ),
          ),
          VirtualKeyboardView(keyboard),
        ],
      ),
    );
  }
}
