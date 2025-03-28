import 'dart:async';
import 'dart:io';

import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/video_editor/bloc/video_editor_bloc.dart';
import 'package:felicitup_app/features/video_editor/widgets/widgets.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class VideoEditorPage extends StatefulWidget {
  const VideoEditorPage({
    super.key,
    required this.felicitupId,
    required this.videoUrl,
  });

  final String felicitupId;
  final String videoUrl;

  @override
  State<VideoEditorPage> createState() => _VideoEditorPageState();
}

class _VideoEditorPageState extends State<VideoEditorPage> with WidgetsBindingObserver, TickerProviderStateMixin {
  VideoPlayerController? _controller;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    context.read<VideoEditorBloc>().add(VideoEditorEvent.getFelicitupInfo(widget.felicitupId));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _startHideControlsTimer();
    if (widget.videoUrl.isNotEmpty) {
      context.read<VideoEditorBloc>().add(VideoEditorEvent.setUrlVideo(widget.videoUrl));
      _initializeVideoPlayerFromUrl(widget.videoUrl);
    } else {
      context.read<VideoEditorBloc>().add(VideoEditorEvent.setUrlVideo(''));
    }
    super.initState();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller != null) {
      if (state == AppLifecycleState.paused) {
        _controller!.pause();
      } else if (state == AppLifecycleState.resumed) {
        _controller!.play();
      }
    }
  }

  Future<void> _initializeVideoPlayerFromUrl(String videoUrl) async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        setState(() {});
        _controller!.play();
        setState(() {
          _duration = _controller!.value.duration;
          _position = _controller!.value.position;
          _isPlaying = true;
        });
      });

    _controller!.addListener(() {
      if (mounted) {
        setState(() {
          _position = _controller!.value.position;
        });
      }
    });
  }

  void _togglePlay() {
    if (_controller != null) {
      setState(() {
        if (_controller!.value.isPlaying) {
          _controller!.pause();
          _isPlaying = false;
        } else {
          _controller!.play();
          _isPlaying = true;
        }
        _showControls = true;
        _startHideControlsTimer();
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoEditorBloc, VideoEditorState>(
      listenWhen: (previous, current) => previous.isLoading != current.isLoading,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }
      },
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            _controller?.dispose();
          }
        },
        child: Scaffold(
          backgroundColor: context.colors.background,
          persistentFooterAlignment: AlignmentDirectional.bottomCenter,
          persistentFooterButtons: [
            SizedBox(
              width: context.sp(300),
              child: BlocBuilder<VideoEditorBloc, VideoEditorState>(
                builder: (_, state) {
                  return PrimaryButton(
                    onTap: () async {
                      File? response = await pickVideoFromCamera(context);

                      if (response != null) {
                        context
                            .read<VideoEditorBloc>()
                            .add(VideoEditorEvent.uploadUserVideo(widget.felicitupId, response));
                      }
                    },
                    label: 'Grabar Vídeo',
                    isActive: true,
                  );
                },
              ),
            ),
          ],
          extendBody: true,
          body: SafeArea(
            child: Column(
              children: [
                BlocBuilder<VideoEditorBloc, VideoEditorState>(
                  builder: (_, state) {
                    return CollapsedHeader(
                      title:
                          '${state.currentFelicitup?.reason} de ${state.currentFelicitup?.owner[0].name.split(' ')[0]}',
                      onPressed: () async {
                        if (context.mounted) {
                          context.go(
                            RouterPaths.videoFelicitup,
                            extra: {
                              'felicitupId': widget.felicitupId,
                              'fromNotification': false,
                            },
                          );
                        }
                      },
                    );
                  },
                ),
                SizedBox(height: context.sp(12)),
                Expanded(
                  child: BlocBuilder<VideoEditorBloc, VideoEditorState>(
                    builder: (_, state) {
                      if (state.currentSelectedVideo.isNotEmpty) {
                        return _buildVideoPlayer();
                      } else {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: context.sp(80),
                              width: context.sp(80),
                              margin: EdgeInsets.only(bottom: context.sp(12)),
                              decoration: const BoxDecoration(
                                color: Color(0xFF313131),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.video_call_outlined,
                                size: context.sp(40),
                              ),
                            ),
                            Text(
                              'Añadir video',
                              style: context.styles.smallText.copyWith(
                                color: const Color(0xFF7A7A7A),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: context.sp(12)),
                SizedBox(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: context.styles.smallText,
                          ),
                          Text(
                            " / ",
                            style: context.styles.header2,
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: context.styles.smallText,
                          ),
                        ],
                      ),
                      SizedBox(height: context.sp(8)),
                      GestureDetector(
                        onTap: _togglePlay,
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.sp(12)),
                BlocBuilder<VideoEditorBloc, VideoEditorState>(
                  builder: (_, state) {
                    return Visibility(
                      visible: !state.isFullScreen,
                      child: Container(
                        height: context.sp(100),
                        width: context.sp(300),
                        color: context.colors.grey,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: state.currentFelicitup?.invitedUserDetails.length,
                          itemBuilder: (_, index) {
                            final data = state.currentFelicitup?.invitedUserDetails[index];
                            final videoData = data?.videoData;

                            return VideoSpace(
                              label: (data?.videoData?.videoUrl?.isNotEmpty ?? false)
                                  ? 'Espacio ya tomado'
                                  : '${index + 1}',
                              screenshotImage: data?.videoData?.videoThumbnail ?? '',
                              name: data?.name ?? '',
                              id: data?.id ?? '',
                              hasVideo: data?.videoData?.videoUrl?.isNotEmpty ?? false,
                              setVideo: () {
                                final url = videoData?.videoUrl;
                                if (url != null && url.isNotEmpty) {
                                  context.read<VideoEditorBloc>().add(VideoEditorEvent.setUrlVideo(url));
                                  if (_controller != null && _controller!.value.isInitialized) {
                                    _controller?.dispose();
                                  }
                                  _initializeVideoPlayerFromUrl(url);
                                } else {
                                  context.read<VideoEditorBloc>().add(VideoEditorEvent.setUrlVideo(''));
                                }
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: context.sp(12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
        if (_showControls) {
          _startHideControlsTimer();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (Platform.isIOS)
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          if (Platform.isAndroid)
            Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),
          Positioned(
            top: context.sp(10),
            left: 0,
            right: 0,
            child: SizedBox(
              height: context.sp(5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.sp(10)),
                child: VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  padding: EdgeInsets.symmetric(horizontal: context.sp(12)),
                  colors: VideoProgressColors(
                    playedColor: context.colors.orange,
                    bufferedColor: context.colors.lightGrey,
                    backgroundColor: context.colors.darkGrey,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: Duration(milliseconds: 200),
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: context.sp(50),
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  color: context.colors.white.valueOpacity(.8),
                ),
                onPressed: _togglePlay,
              ),
            ),
          ),
          Positioned(
            bottom: context.sp(20),
            right: context.sp(20),
            child: GestureDetector(
              onTap: () {
                context.read<VideoEditorBloc>().add(VideoEditorEvent.changeFullScreen());
              },
              child: Container(
                height: context.sp(30),
                width: context.sp(30),
                alignment: AlignmentDirectional.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.grey,
                ),
                child: Icon(
                  Icons.fullscreen,
                  color: context.colors.orange,
                  size: context.sp(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
