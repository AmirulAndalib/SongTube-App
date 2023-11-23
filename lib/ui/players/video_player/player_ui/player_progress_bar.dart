import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:newpipeextractor_dart/models/streamSegment.dart';
import 'package:provider/provider.dart';
import 'package:songtube/languages/languages.dart';
import 'package:songtube/providers/media_provider.dart';
import 'package:songtube/ui/text_styles.dart';

class VideoPlayerProgressBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final Function(double) onSeek;
  final Function() onFullScreenTap;
  final List<StreamSegment>? segments;
  final Function() onSeekStart;
  final bool audioOnly;
  final Function() onPresetTap;
  final Function() onShowSegments;
  const VideoPlayerProgressBar({
    required this.position,
    required this.duration,
    required this.onSeek,
    required this.segments,
    required this.audioOnly,
    required this.onPresetTap,
    required this.onFullScreenTap,
    required this.onSeekStart,
    required this.onShowSegments,
    Key? key
  }) : super(key: key);

  @override
  State<VideoPlayerProgressBar> createState() => _VideoPlayerProgressBarState();
}

class _VideoPlayerProgressBarState extends State<VideoPlayerProgressBar> with TickerProviderStateMixin {

  // Current label, modified if segmets are available
  String? currentLabel;
  bool isDragging = false;
  double seekValue = 0;

  StreamSegment? currentSegment(double value) {
    if (widget.segments == null) return null;
    int position = value.round();
    if (value < widget.segments![1].startTimeSeconds) {
      return widget.segments!.first;
    } else if (value >= widget.segments!.last.startTimeSeconds) {
      return widget.segments!.last;
    } else {
      List<int> startTimes = List.generate(widget.segments!.length, (index)
        => widget.segments![index].startTimeSeconds).toList();
      int closestStartTime = (startTimes.where((e) => e >= position).toList()..sort()).first;
      int nearIndex = (widget.segments!.indexWhere((element) =>
        element.startTimeSeconds == closestStartTime))-1;
      return widget.segments![nearIndex];
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaProvider mediaProvider = Provider.of(context);
    return Container(
      padding: EdgeInsets.only(top: 0, left: 16, bottom: MediaQuery.of(context).orientation == Orientation.landscape ? 32 : 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Builder(
                    builder: (context) {
                      final duration = isDragging ? Duration(seconds: widget.duration.inSeconds-seekValue.round()) : Duration(seconds: widget.duration.inSeconds-widget.position.inSeconds);
                      return SizedBox(
                        width: 40,
                        child: Text(
                          " ${duration.inMinutes.toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                          style: tinyTextStyle(context).copyWith(letterSpacing: 0.6)
                        ),
                      );
                    }
                  ),
                  if (widget.segments != null && widget.segments!.isNotEmpty)
                  Flexible(
                    child: Builder(
                      builder: (context) {
                        final currentSegmentText = isDragging && currentLabel != null ? currentLabel : currentSegment(widget.position.inSeconds.roundToDouble())!.title ?? '';
                        return GestureDetector(
                          onTap: () {
                            widget.onShowSegments();
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 100),
                              child: Text(
                                '>   $currentSegmentText',
                                key: ValueKey(currentSegmentText),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tinyTextStyle(context).copyWith(),
                              ),
                            ),
                          ),
                        );
                      }
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 20,
                      child: SliderTheme(
                        data: SliderThemeData(
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 4,
                            disabledThumbRadius: 2
                          ),
                          trackHeight: 2,
                          overlayShape: SliderComponentShape.noOverlay
                        ),
                        child: Slider(
                          activeColor: mediaProvider.currentColors.vibrant,
                          inactiveColor: mediaProvider.currentColors.vibrant?.withOpacity(0.2),
                          thumbColor: mediaProvider.currentColors.vibrant,
                          label: '${Duration(seconds: widget.position.inSeconds).inMinutes.toString().padLeft(2, '0')}:${Duration(seconds: widget.position.inSeconds).inSeconds.remainder(60).toString().padLeft(2, '0')}',
                          value: isDragging ? seekValue : widget.position.inSeconds.toDouble(),
                          onChangeEnd: (newPosition) {
                            double seekPosition = newPosition;
                            if (widget.segments != null && widget.segments!.length >= 2) {
                              StreamSegment segment = currentSegment(newPosition)!;
                              if (segment.startTimeSeconds < newPosition) {
                                if (newPosition - segment.startTimeSeconds <= 10) {
                                  seekPosition = segment.startTimeSeconds.toDouble();
                                }
                              }
                              if (segment.startTimeSeconds >= newPosition) {
                                if (segment.startTimeSeconds - newPosition <= 10) {
                                  seekPosition = segment.startTimeSeconds.toDouble();
                                }
                              }
                            }
                            widget.onSeek(seekPosition);
                            setState(() => isDragging = false);
                          },
                          max: widget.duration.inSeconds.toDouble() == 0
                            ? 1 : widget.duration.inSeconds.toDouble(),
                          min: 0,
                          onChangeStart: (_) {
                            widget.onSeekStart();
                            setState(() { isDragging = true; currentLabel = null; seekValue = widget.position.inSeconds.toDouble(); });
                          },
                          onChanged: (value) {
                            setState(() {
                              seekValue = value;
                            });
                            if (widget.segments != null && widget.segments!.length >= 2) {
                              if (currentLabel != currentSegment(value)!.title) {
                                setState(() => currentLabel = currentSegment(value)!.title);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  // Quality Button
                  Semantics(
                    label: Languages.of(context)!.labelQuality,
                    child: GestureDetector(
                      onTap: widget.onPresetTap,
                      child: Container(
                        padding: const EdgeInsets.only(left: 12, bottom: 4, right: 8, top: 4),
                        color: Colors.transparent,
                        child: const Icon(
                          EvaIcons.settingsOutline,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  // FullScreen Button
                  Semantics(
                    label: 'Fullscreen',
                    child: GestureDetector(
                      onTap: widget.onFullScreenTap,
                      child: Container(
                        padding: const EdgeInsets.only(left: 8, bottom: 4, right: 16, top: 4),
                        color: Colors.transparent,
                        child: Icon(
                          MediaQuery.of(context).orientation == Orientation.portrait
                            ? Icons.fullscreen_rounded : Icons.fullscreen_exit_rounded,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4)
        ],
      ),
    );
  }
}