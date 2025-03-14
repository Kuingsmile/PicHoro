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

  Widget buildEmpty();
  Widget buildError();
  Widget buildLoading();
  Widget buildSuccess();
  AppBar get appBar;
}
