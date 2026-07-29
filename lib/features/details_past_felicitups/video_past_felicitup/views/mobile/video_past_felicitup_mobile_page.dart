import 'dart:async';
import 'dart:io';

import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

class VideoPastFelicitupMobilePage extends StatefulWidget {
  const VideoPastFelicitupMobilePage({super.key});

  @override
  State<VideoPastFelicitupMobilePage> createState() =>
      _VideoPastFelicitupMobilePageState();
}

class _VideoPastFelicitupMobilePageState
    extends State<VideoPastFelicitupMobilePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  File? selectedVideo;
  late VideoPlayerController? _controller;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    final felicitup = context
        .read<DetailsPastFelicitupDashboardBloc>()
        .state
        .felicitup;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<DetailsPastFelicitupDashboardBloc>().add(
              const DetailsPastFelicitupDashboardEvent.changeCurrentIndex(3),
            );
        if (felicitup?.finalVideoUrl != null &&
            felicitup!.finalVideoUrl!.isNotEmpty) {
          initializeController(felicitup.finalVideoUrl!);
          _initializeVideoPlayerFromUrl(felicitup.finalVideoUrl!);
          context.read<VideoPastFelicitupBloc>().add(
                VideoPastFelicitupEvent.setUrlVideo(felicitup.finalVideoUrl!),
              );
        }
      }
    });
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _startHideControlsTimer();
    super.initState();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
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
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
    _controller!.play();
  }

  Future<void> _initializeVideoPlayerFromUrl(String videoUrl) async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _duration = _controller!.value.duration;
            _position = _controller!.value.position;
            _isPlaying = true;
          });
        }
        _controller!.play();
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
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          Expanded(
            child: _isInitialized
                ? _buildVideoPlayer()
                : const Center(child: CircularProgressIndicator()),
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
                    Text(" / ", style: context.styles.header2),
                    Text(
                      _formatDuration(_duration),
                      style: context.styles.smallText,
                    ),
                  ],
                ),
                SizedBox(height: context.sp(8)),
                GestureDetector(
                  onTap: _togglePlay,
                  child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
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
          AspectRatio(aspectRatio: 9 / 16, child: VideoPlayer(_controller!)),
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
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: context.sp(50),
                icon: Icon(
                  _isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  color: context.colors.white.valueOpacity(.8),
                ),
                onPressed: _togglePlay,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
