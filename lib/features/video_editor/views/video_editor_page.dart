import 'dart:async';
import 'dart:io';

import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
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
    required this.felicitup,
  });

  final FelicitupModel felicitup;

  @override
  State<VideoEditorPage> createState() => _VideoEditorPageState();
}

class _VideoEditorPageState extends State<VideoEditorPage> with WidgetsBindingObserver, TickerProviderStateMixin {
  File? selectedVideo;
  late VideoPlayerController? _controller;
  String? videoUrl;
  final Duration _duration = Duration.zero;
  final Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    logger.info(widget.felicitup.id);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _startHideControlsTimer();
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
    selectedVideo?.delete();
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

  Future<void> initializeController(String url) async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await _controller!.initialize();
    _controller!.play();
  }

  Future<void> _initializeVideoPlayerFromUrl(String videoUrl) async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        setState(() {});
        _controller!.play();
        setState(() {
          _isPlaying = true;
        });
      });

    _controller!.addListener(() {
      if (mounted) {
        setState(() {});
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
              child: PrimaryButton(
                onTap: () async {
                  File? response = await pickVideoFromCamera(context);

                  if (response != null) {
                    context
                        .read<VideoEditorBloc>()
                        .add(VideoEditorEvent.uploadUserVideo(widget.felicitup.id, response));
                    setState(() {});
                  }
                },
                label: 'Grabar Vídeo',
                isActive: true,
              ),
            ),
          ],
          extendBody: true,
          body: SafeArea(
            child: Column(
              children: [
                CollapsedHeader(
                  title: '${widget.felicitup.reason} de ${widget.felicitup.owner[0].name.split(' ')[0]}',
                  onPressed: () async {
                    if (context.mounted) {
                      context.go(
                        RouterPaths.videoFelicitup,
                        extra: {
                          'felicitupId': widget.felicitup.id,
                          'fromNotification': false,
                        },
                      );
                    }
                  },
                ),
                SizedBox(height: context.sp(12)),
                BlocBuilder<VideoEditorBloc, VideoEditorState>(
                  builder: (_, state) {
                    return Expanded(
                      child: state.currentSelectedVideo.isEmpty
                          ? Column(
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
                            )
                          : _buildVideoPlayer(),
                    );
                  },
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
                Container(
                  height: context.sp(100),
                  width: context.sp(300),
                  color: context.colors.grey,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.felicitup.invitedUserDetails.length,
                    itemBuilder: (_, index) {
                      final data = widget.felicitup.invitedUserDetails[index];
                      return VideoSpace(
                        label: data.videoData!.videoUrl!.isNotEmpty ? 'Espacio ya tomado' : '${index + 1}',
                        screenshotImage: data.videoData!.videoThumbnail,
                        name: data.name,
                        id: data.id ?? '',
                        hasVideo: data.videoData!.videoUrl!.isNotEmpty,
                        setVideo: () {
                          if (data.videoData!.videoUrl!.isEmpty) {
                            context.read<VideoEditorBloc>().add(VideoEditorEvent.setUrlVideo(''));
                          } else {
                            context
                                .read<VideoEditorBloc>()
                                .add(VideoEditorEvent.setUrlVideo(data.videoData!.videoUrl!));
                            _initializeVideoPlayerFromUrl(data.videoData!.videoUrl!);
                          }
                        },
                      );
                    },
                  ),
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
          AspectRatio(
            aspectRatio: 9 / 16,
            child: VideoPlayer(_controller!),
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
                logger.debug('hola mundo');
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
