import 'package:flutter/material.dart';

enum LoadState { loading, empty, error, success }

abstract class BaseLoadingPageState<T extends StatefulWidget> extends State<T> {
  LoadState? state;

  @override
  void initState() {
    super.initState();
    state = LoadState.loading;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: buildStateWidget,
    );
  }

  Widget get buildStateWidget {
    switch (state) {
      case LoadState.empty:
        return buildEmpty();
      case LoadState.error:
        return buildError();
      case LoadState.loading:
        return buildLoading();
      case LoadState.success:
        return buildSuccess();
      default:
        return buildError();
    }
  }

  String get emptyText => '没有数据哦，点击右上角添加吧';
  List<Widget> get extraEmptyWidgets => [];

  Widget buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty.png',
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 20),
          Text(emptyText,
              style: TextStyle(fontSize: 18, color: Color.fromARGB(136, 121, 118, 118), fontWeight: FontWeight.w500)),
          ...extraEmptyWidgets,
        ],
      ),
    );
  }

  String get errorText => '加载失败';
  String get errorButtonText => '重新加载';
  void onErrorRetry() {
    setState(() {
      state = LoadState.loading;
    });
    // Implement your retry logic here
  }

  Widget buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(errorText,
              style: TextStyle(fontSize: 18, color: Color.fromARGB(136, 121, 118, 118), fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: onErrorRetry,
            icon: const Icon(Icons.refresh),
            label: Text(errorButtonText),
          )
        ],
      ),
    );
  }

  Widget buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(Colors.blue),
            ),
          ),
          SizedBox(height: 16),
          Text('加载中...', style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget buildSuccess();
  AppBar get appBar;
}
