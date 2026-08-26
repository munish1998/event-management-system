import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../widgets/loading_widget.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String? videoUrl;
  final File? videoFile;

  const VideoPlayerWidget({
    super.key,
    this.videoUrl,
    this.videoFile,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  final ValueNotifier<bool> isInitializedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> hasErrorNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      if (widget.videoFile != null) {
        _controller = VideoPlayerController.file(widget.videoFile!);
      } else if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
        final trimmed = widget.videoUrl!.trim();
        if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
          _controller = VideoPlayerController.networkUrl(Uri.parse(trimmed));
        } else {
          _controller = VideoPlayerController.file(File(trimmed));
        }
      }

      if (_controller != null) {
        await _controller!.initialize();
        isInitializedNotifier.value = true;
        _controller!.addListener(() {
          if (mounted) {
            isPlayingNotifier.value = _controller!.value.isPlaying;
          }
        });
      }
    } catch (e) {
      debugPrint("Video initialization failed: $e");
      if (mounted) {
        hasErrorNotifier.value = true;
      }
    }
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl || oldWidget.videoFile != widget.videoFile) {
      _controller?.dispose();
      isInitializedNotifier.value = false;
      hasErrorNotifier.value = false;
      _initPlayer();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    isInitializedNotifier.dispose();
    hasErrorNotifier.dispose();
    isPlayingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xffF2AF34);

    return ValueListenableBuilder<bool>(
      valueListenable: hasErrorNotifier,
      builder: (context, hasError, _) {
        if (hasError) {
          return Container(
            height: 190,
            decoration: BoxDecoration(
              color: const Color(0xff1A1A1A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_library_outlined, color: Colors.white38, size: 40),
                  SizedBox(height: 8),
                  Text(
                    "Video preview unavailable",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }

        return ValueListenableBuilder<bool>(
          valueListenable: isInitializedNotifier,
          builder: (context, isInitialized, _) {
            if (!isInitialized || _controller == null) {
              return Container(
                height: 190,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: LoadingWidget(
                    color: goldColor,
                    size: 32,
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x44F2AF34)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio > 0 ? _controller!.value.aspectRatio : 16 / 9,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_controller!),
                      ValueListenableBuilder<bool>(
                        valueListenable: isPlayingNotifier,
                        builder: (context, isPlaying, _) {
                          return GestureDetector(
                            onTap: () {
                              if (_controller!.value.isPlaying) {
                                _controller!.pause();
                              } else {
                                _controller!.play();
                              }
                            },
                            child: Container(
                              color: Colors.black26,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: goldColor,
                                    size: 38,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 8,
                        left: 12,
                        right: 12,
                        child: VideoProgressIndicator(
                          _controller!,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: goldColor,
                            bufferedColor: Colors.white24,
                            backgroundColor: Colors.black38,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
