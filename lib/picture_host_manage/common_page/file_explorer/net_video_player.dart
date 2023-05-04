import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:horopic/picture_host_manage/common_page/file_explorer/vlc_palyer/video_data.dart';
import 'package:video_player/video_player.dart';

import 'package:auto_orientation/auto_orientation.dart';

import 'package:flutter/services.dart';

class NetVideoPlayer extends StatefulWidget {
  final List videoList;
  final int index;
  final String type;
  final Map<String, String> headers;

  const NetVideoPlayer({
    Key? key,
    required this.videoList,
    required this.index,
    required this.type,
    required this.headers,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NetVideoPlayerState();
  }
}

class _NetVideoPlayerState extends State<NetVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  late VlcPlayerController _controller;
  int _currActiveIdx = 0;
  late VideoData _videoData;
  final double initSnapshotRightPosition = 10;
  final double initSnapshotBottomPosition = 10;

  //
  double sliderValue = 0.0;
  double volumeValue = 50;
  String position = '';
  String duration = '';
  int numberOfCaptions = 0;
  int numberOfAudioTracks = 0;
  bool validPosition = false;
  bool isfullscreen = false;

  double recordingTextOpacity = 0;
  DateTime lastRecordingShowTime = DateTime.now();
  bool isRecording = false;
  bool showSoundSlider = false;

  //
  List<double> playbackSpeeds = [0.5, 1.0, 2.0];
  int playbackSpeedIndex = 1;

  bool showControls = false;

  final double _playButtonIconSize = 69;
  final double _seekButtonIconSize = 48;
  final Duration _seekStepForward = const Duration(seconds: 10);
  final Duration _seekStepBackward = const Duration(seconds: -10);
  final Color _iconColor = Colors.white;

  final ValueNotifier<bool> showControlNotifier = ValueNotifier(true);
  final ValueNotifier<Orientation> orientationNotifier = ValueNotifier(Orientation.portrait);

  @override
  void initState() {
    super.initState();
    _currActiveIdx = widget.index;
    if (widget.type == 'normal') {
      _videoPlayerController =
          VideoPlayerController.network(widget.videoList[_currActiveIdx]['url'], httpHeaders: widget.headers);
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: 16 / 9,
        autoPlay: true,
        looping: true,
        placeholder: const Center(
          child: CircularProgressIndicator(),
        ),
        isLive: false,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
            ),
          );
        },
      );
    } else {
      _videoData = VideoData(
        name: widget.videoList[_currActiveIdx]['name'],
        path: Uri.parse(widget.videoList[_currActiveIdx]['url']).toString(),
        type: VideoType.network,
        subtitlePath: widget.videoList[_currActiveIdx]['subtitlePath'],
      );
      _controller = VlcPlayerController.network(
        _videoData.path,
        hwAcc: HwAcc.full,
        options: VlcPlayerOptions(
          advanced: VlcAdvancedOptions([
            VlcAdvancedOptions.networkCaching(2000),
          ]),
          subtitle: VlcSubtitleOptions([
            VlcSubtitleOptions.boldStyle(true),
            VlcSubtitleOptions.fontSize(30),
            VlcSubtitleOptions.outlineColor(VlcSubtitleColor.yellow),
            VlcSubtitleOptions.outlineThickness(VlcSubtitleThickness.normal),
            VlcSubtitleOptions.color(VlcSubtitleColor.navy),
          ]),
          http: VlcHttpOptions([
            VlcHttpOptions.httpReconnect(true),
          ]),
          rtp: VlcRtpOptions([
            VlcRtpOptions.rtpOverRtsp(true),
          ]),
        ),
      );
      _controller.addOnInitListener(() async {
        await _controller.startRendererScanning();
        if (_videoData.subtitlePath != '') {
          await _controller.addSubtitleFromNetwork(Uri.parse(_videoData.subtitlePath).toString());
        }
      });
      _controller.addOnRendererEventListener((type, id, name) {});
      _controller.addListener(listener);
      setState(() {});
    }
  }

  void listener() async {
    if (!mounted) return;
    if (_controller.value.isInitialized) {
      var oPosition = _controller.value.position;
      var oDuration = _controller.value.duration;
      if (oDuration.inHours == 0) {
        var strPosition = oPosition.toString().split('.')[0];
        var strDuration = oDuration.toString().split('.')[0];
        position = "${strPosition.split(':')[1]}:${strPosition.split(':')[2]}";
        duration = "${strDuration.split(':')[1]}:${strDuration.split(':')[2]}";
      } else {
        position = oPosition.toString().split('.')[0];
        duration = oDuration.toString().split('.')[0];
      }
      validPosition = oDuration.compareTo(oPosition) >= 0;
      sliderValue = validPosition ? oPosition.inSeconds.toDouble() : 0;
      numberOfCaptions = _controller.value.spuTracksCount;
      numberOfAudioTracks = _controller.value.audioTracksCount;
      if (_controller.value.isRecording && _controller.value.isPlaying) {
        if (DateTime.now().difference(lastRecordingShowTime).inSeconds >= 1) {
          lastRecordingShowTime = DateTime.now();
          recordingTextOpacity = 1 - recordingTextOpacity;
        }
      } else {
        recordingTextOpacity = 0;
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSizes = MediaQuery.of(context).size;
    if (widget.type == 'normal') {
      return Column(children: [
        SizedBox(
          height: screenSizes.height * 0.6,
          width: screenSizes.width,
          child: Chewie(
            controller: _chewieController,
          ),
        ),
        SizedBox(
          height: screenSizes.height * 0.4,
          width: screenSizes.width,
          child: buildPlayDrawer(),
        ),
      ]);
    } else {
      return WillPopScope(
        onWillPop: () async {
          AutoOrientation.portraitUpMode();
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
          return true;
        },
        child: Center(
          child: centerBuild(),
        ),
      );
    }
  }

  Widget centerBuild() {
    return Stack(children: [
      Container(
          alignment: Alignment.center,
          color: Colors.black,
          child: VlcPlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
            placeholder: const Center(child: CircularProgressIndicator()),
          )),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 50),
        reverseDuration: const Duration(milliseconds: 200),
        child: Builder(
          builder: (ctx) {
            switch (_controller.value.playingState) {
              case PlayingState.initialized:

              case PlayingState.paused:
                return SizedBox.expand(
                  child: Container(
                    color: Colors.black45,
                    child: FittedBox(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            onPressed: () => _seekRelative(_seekStepBackward),
                            color: _iconColor,
                            iconSize: _seekButtonIconSize,
                            icon: const Icon(Icons.replay_10),
                          ),
                          IconButton(
                            onPressed: _play,
                            color: _iconColor,
                            iconSize: _playButtonIconSize,
                            icon: const Icon(Icons.play_arrow),
                          ),
                          IconButton(
                            onPressed: () => _seekRelative(_seekStepForward),
                            color: _iconColor,
                            iconSize: _seekButtonIconSize,
                            icon: const Icon(Icons.forward_10),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

              case PlayingState.buffering:
              case PlayingState.playing:
                return SizedBox.expand(
                    child: ValueListenableBuilder(
                        valueListenable: showControlNotifier,
                        builder: (ctx, show, _) {
                          if (showControlNotifier.value) {
                            return GestureDetector(
                                onTap: (() {
                                  showControlNotifier.value = !showControlNotifier.value;
                                }),
                                onDoubleTap: _pause,
                                child: Container(
                                  color: Colors.transparent,
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        color: Colors.white,
                                        icon: _controller.value.isPlaying
                                            ? const Icon(Icons.pause_circle_outline)
                                            : const Icon(Icons.play_circle_outline),
                                        onPressed: _togglePlaying,
                                      ),
                                      IconButton(
                                        color: Colors.white,
                                        icon: volumeValue == 0
                                            ? const Icon(Icons.volume_off)
                                            : const Icon(Icons.volume_up),
                                        onPressed: () {
                                          setState(() {
                                            if (volumeValue > 0) {
                                              volumeValue = 0;
                                            } else {
                                              volumeValue = 50;
                                            }
                                            _controller.setVolume(volumeValue.toInt());
                                          });
                                        },
                                      ),
                                      Expanded(
                                          child: SizedBox(
                                        height: 50,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Text(
                                              position,
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                            Expanded(
                                              child: Slider(
                                                activeColor: Colors.redAccent,
                                                inactiveColor: Colors.white70,
                                                value: sliderValue,
                                                min: 0.0,
                                                max: (!validPosition && _controller.value.duration == null)
                                                    ? 1.0
                                                    : _controller.value.duration.inSeconds.toDouble(),
                                                onChanged: validPosition ? _onSliderPositionChanged : null,
                                              ),
                                            ),
                                            Text(
                                              duration,
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      )),
                                      IconButton(
                                        icon: const Icon(Icons.fullscreen),
                                        color: Colors.white,
                                        onPressed: () {
                                          Orientation orientation = MediaQuery.of(context).orientation;
                                          if (orientation == Orientation.landscape) {
                                            orientationNotifier.value = Orientation.portrait;
                                            AutoOrientation.portraitAutoMode();
                                          } else {
                                            orientationNotifier.value = Orientation.landscape;
                                            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

                                            AutoOrientation.landscapeAutoMode();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ));
                          } else {
                            return GestureDetector(
                                onTap: (() {
                                  showControlNotifier.value = !showControlNotifier.value;
                                }),
                                onDoubleTap: _pause,
                                child: Container(
                                  color: Colors.transparent,
                                ));
                          }
                        }));

              case PlayingState.ended:
              case PlayingState.stopped:
              case PlayingState.error:
                return Center(
                    child: Container(
                        color: Colors.black45,
                        child: (FittedBox(
                          child: IconButton(
                            onPressed: _replay,
                            color: _iconColor,
                            iconSize: _playButtonIconSize,
                            icon: const Icon(Icons.replay),
                          ),
                        ))));

              default:
                return const SizedBox.shrink();
            }
          },
        ),
      ),
    ]);
  }

  Future<void> _play() {
    return _controller.play();
  }

  Future<void> _replay() async {
    await _controller.stop();
    await _controller.play();
  }

  Future<void> _pause() async {
    if (_controller.value.isPlaying) {
      await _controller.pause();
    }
  }

  Future<void> _seekRelative(Duration seekStep) async {
    await _controller.seekTo(_controller.value.position + seekStep);
  }

  void _togglePlaying() async {
    _controller.value.isPlaying ? await _controller.pause() : await _controller.play();
  }

  void _onSliderPositionChanged(double progress) {
    setState(() {
      sliderValue = progress.floor().toDouble();
    });
    _controller.setTime(sliderValue.toInt() * 1000);
  }

  buildPlayDrawer() {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        color: Colors.black87,
        child: createTabContentList(),
      ),
    );
  }

  createTabContentList() {
    List<Widget> playListButtons = widget.videoList.asMap().keys.map((int activeIndex) {
      return Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: ElevatedButton(
          style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
              elevation: MaterialStateProperty.all(0),
              backgroundColor: MaterialStateProperty.all(activeIndex == _currActiveIdx ? Colors.red : Colors.blue)),
          onPressed: () async {
            setState(() {
              _currActiveIdx = activeIndex;
            });
            String nextVideoUrl = widget.videoList[activeIndex]['url'];
            if (widget.type == 'normal') {
              _videoPlayerController = VideoPlayerController.network(nextVideoUrl, httpHeaders: widget.headers);
              _chewieController = ChewieController(
                videoPlayerController: _videoPlayerController,
                aspectRatio: 16 / 9,
                autoPlay: true,
                looping: true,
                placeholder: const Center(
                  child: CircularProgressIndicator(),
                ),
                isLive: false,
                errorBuilder: (context, errorMessage) {
                  return Center(
                    child: Text(
                      errorMessage,
                    ),
                  );
                },
              );
              setState(() {});
            }
          },
          child: Text(
            widget.videoList[activeIndex]['name'],
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }).toList();
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Wrap(
          direction: Axis.horizontal,
          children: playListButtons,
        ),
      ),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    if (widget.type == 'normal') {
      showControlNotifier.dispose();
      orientationNotifier.dispose();
      _chewieController.dispose();
      await _videoPlayerController.dispose();
    } else {
      try {
        await _controller.stop();
        await _controller.stopRecording();
        await _controller.stopRendererScanning();
        _controller.removeListener(listener);
        await _controller.dispose();
      } catch (e) {
        return;
      }
    }
  }
}
