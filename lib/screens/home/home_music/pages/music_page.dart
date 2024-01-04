import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/providers/media_provider.dart';
import 'package:songtube/providers/ui_provider.dart';
import 'package:songtube/ui/tiles/song_tile.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({
    Key? key }) : super(key: key);

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    MediaProvider mediaProvider = Provider.of(context);
    UiProvider uiProvider = Provider.of(context);
    return ListView.builder(
      key: const PageStorageKey('homeMusicPage'),
      itemExtent: 72,
      padding: EdgeInsets.only(
        top: appBarSize(context)-8,
        bottom: 16+(kToolbarHeight*1.5),
      ),
      itemCount: mediaProvider.songs.length,
      itemBuilder: (context, index) {
        final song = mediaProvider.songs[index];
        return SongTile(
          song: song,
          onPlay: () async {
            mediaProvider.currentPlaylistName = 'Music';
            final queue = List<MediaItem>.generate(mediaProvider.songs.length, (index) {
              return mediaProvider.songs[index].mediaItem;
            });
            uiProvider.currentPlayer = CurrentPlayer.music;
            mediaProvider.playSong(queue, index);
          }
        );
      },
    );
  }
}