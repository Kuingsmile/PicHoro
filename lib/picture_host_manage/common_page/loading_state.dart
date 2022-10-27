// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

enum LoadState { LOADING, EMPTY, ERROR, SUCCESS }

abstract class BaseLoadingPageState<T extends StatefulWidget> extends State<T> {
  LoadState? state;

  @override
  void initState() {
    super.initState();
    state = LoadState.LOADING;
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
      case LoadState.EMPTY:
        return buildEmpty();
      case LoadState.ERROR:
        return buildError();
      case LoadState.LOADING:
        return buildLoading();
      case LoadState.SUCCESS:
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
