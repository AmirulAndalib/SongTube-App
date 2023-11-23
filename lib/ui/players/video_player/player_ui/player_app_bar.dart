import 'package:flutter/material.dart';
import 'package:songtube/ui/animations/animated_icon.dart';
import 'package:songtube/ui/text_styles.dart';

class VideoPlayerAppBar extends StatelessWidget {
  final String videoTitle;
  final Function() onMinimize;
  final bool interfaceLocked;
  final Function() onLockInterface;
  const VideoPlayerAppBar({
    required this.videoTitle,
    required this.onMinimize,
    required this.interfaceLocked,
    required this.onLockInterface,
    Key? key
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12).copyWith(left: 0, top: 0, right: 4),
      child: Row(
        children: [
          const SizedBox(width: 6),
          Semantics(
            label: 'Minimize player',
            child: IconButton(
              onPressed: () {
                onMinimize();
              },
              icon: const Icon(Icons.expand_more_rounded, size: 18, color: Colors.white)
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              MediaQuery.of(context).orientation == Orientation.landscape ? videoTitle : '',
              style: smallTextStyle(context, bold: true).copyWith(color: Colors.white, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ),
          const SizedBox(width: 4),
          Semantics(
            label: 'Lock player interface',
            child: IconButton(
              onPressed: () {
                onLockInterface();
              },
              icon: AppAnimatedIcon(interfaceLocked ? Icons.lock : Icons.lock_open, size: 20)
            ),
          ),
          // Switch(
          //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //   activeThumbImage: const AssetImage('assets/images/playArrow.png'),
          //   activeColor: Colors.white,
          //   activeTrackColor: Colors.white.withOpacity(0.6),
          //   inactiveThumbColor: Colors.white.withOpacity(0.6),
          //   inactiveTrackColor: Colors.white.withOpacity(0.2),
          //   value: prefs.youtubeAutoPlay,
          //   onChanged: (bool value) {
          //     prefs.youtubeAutoPlay = value;
          //   },
          // ),
        ],
      ),
    );
  }
}