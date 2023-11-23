
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:songtube/internal/global.dart';
import 'package:songtube/languages/languages.dart';
import 'package:songtube/providers/media_provider.dart';
import 'package:songtube/ui/sheet_phill.dart';
import 'package:songtube/ui/text_styles.dart';


class MusicEqualizerSheet extends StatefulWidget {
  
  const MusicEqualizerSheet({
    required this.equalizerMap,
    required this.loudnessMap,
    Key? key }) : super(key: key);
  final dynamic equalizerMap;
  final dynamic loudnessMap;
  @override
  _MusicEqualizerSheetState createState() => _MusicEqualizerSheetState();
}

class _MusicEqualizerSheetState extends State<MusicEqualizerSheet> {

  late _EqualizationData equalizer = _EqualizationData.fromMap(Map<String, dynamic>.from(widget.equalizerMap));
  late _LoudnessEqualizationData loudnessEqualization = _LoudnessEqualizationData.fromMap(Map<String, dynamic>.from(widget.loudnessMap));

  void sendEqualizer() {
    audioHandler.customAction('updateEqualizer', equalizer.toMap());
  }

  void sendLoudnessGain() {
    audioHandler.customAction('updateLoudnessGain', loudnessEqualization.toMap());
  }

  SliderThemeData sliderTheme(MediaProvider mediaProvider) {
    return SliderThemeData(
      thumbColor: mediaProvider.currentColors.vibrant,
      activeTrackColor: mediaProvider.currentColors.vibrant,
      trackHeight: 3,
      thumbShape: const RoundSliderThumbShape(
        disabledThumbRadius: 5,
        enabledThumbRadius: 5
      ),
      inactiveTrackColor: Theme.of(context).scaffoldBackgroundColor
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.center,
            child: BottomSheetPhill()),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Ionicons.arrow_back_outline),
                  )
                ),
                Expanded(child: Text(Languages.of(context)!.labelEqualizer, style: textStyle(context))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Loudness Equalization Slider
          _loudnessEqualizationWidget(),
          // Equalizer Sliders
          _equalizerWidget(),
        ],
      ),
    );
  }

  Widget _loudnessEqualizationWidget() {
    MediaProvider mediaProvider = Provider.of(context);
    return Column(
      children: [
        CheckboxListTile(
          activeColor: Colors.transparent,
          checkColor: mediaProvider.currentColors.vibrant,
          checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          title: Text(Languages.of(context)!.labelLoudnessEqualizationGain,
            style: subtitleTextStyle(context)),
          value: loudnessEqualization.enabled,
          onChanged: (value) {
            setState(() => loudnessEqualization.enabled = value ?? false);
            sendLoudnessGain();
          }
        ),
        SliderTheme(
          data: sliderTheme(mediaProvider),
          child: Slider(
            min: -1,
            max: 1,
            value: loudnessEqualization.gain,
            onChanged: (gain) {
              setState(() => loudnessEqualization.gain = gain);
              sendLoudnessGain();
            },
          ),
        )
      ],
    );
  }

  Widget _equalizerWidget() {
    MediaProvider mediaProvider = Provider.of(context);
    return Column(
      children: [
        CheckboxListTile(
          activeColor: Colors.transparent,
          checkColor: mediaProvider.currentColors.vibrant,
          checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          title: Text(Languages.of(context)!.labelSliders,
            style: subtitleTextStyle(context)),
          value: equalizer.enabled,
          onChanged: (value) {
            setState(() => equalizer.enabled = value ?? false);
            sendEqualizer();
          }
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(equalizer.bands.length, (index) {
            return _bandSlider(index);
          })
        ),
      ],
    );
  }

  Widget _bandSlider(int bandIndex) {
    MediaProvider mediaProvider = Provider.of(context);
    final band = equalizer.bands[bandIndex];
    return Column(
      children: [
        RotatedBox(
          quarterTurns: 3,
          child: SliderTheme(
            data: sliderTheme(mediaProvider),
            child: Slider(
              min: band.minFreq,
              max: band.maxFreq,
              value: band.gain,
              onChanged: (value) {
                setState(() => equalizer.bands[bandIndex].gain = value);
                sendEqualizer();
              }
            ),
          ),
        ),
        Text('${band.centerFrequency.round()}Hz', style: tinyTextStyle(context).copyWith(letterSpacing: 0.6)),
      ],
    );
  }

}

class _LoudnessEqualizationData {

  _LoudnessEqualizationData({
    required this.enabled,
    required this.gain
  });

  bool enabled;
  double gain;

  static _LoudnessEqualizationData fromMap(Map<String, dynamic> map) {
    return _LoudnessEqualizationData(
      enabled: map['enabled'] == 'true' ? true : false,
      gain: map['gain'] as double
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled ? 'true' : false,
      'gain': gain
    };
  }

}

class _EqualizationData {

  _EqualizationData({
    required this.enabled,
    required this.bands
  });

  bool enabled;
  List<_EqualizationBand> bands;
  

  static _EqualizationData fromMap(Map<String, dynamic> map) {
    final enabled = map['enabled'] == 'true' ? true : false;
    final bands = List.from(map['bands']);
    return _EqualizationData(
      enabled: enabled,
      bands: List.generate(bands.length, (index) {
        final band = bands[index];
        return _EqualizationBand.fromMap(Map<String, dynamic>.from(band));
      })
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled ? 'true' : 'false',
      'bands': List.generate(bands.length, (index) {
        final band = bands[index];
        return {
          'centerFrequency': band.centerFrequency,
          'minFreq': band.minFreq,
          'maxFreq': band.maxFreq,
          'gain': band.gain
        };
      })
    };
  }

}

class _EqualizationBand {

  _EqualizationBand({
    required this.centerFrequency,
    required this.minFreq,
    required this.maxFreq,
    required this.gain,
  });

  final double centerFrequency;
  final double minFreq;
  final double maxFreq;
  double gain;
  
  static _EqualizationBand fromMap(Map<String, dynamic> map) {
    return _EqualizationBand(
      centerFrequency: map['centerFrequency'],
      minFreq: map['minFreq'],
      maxFreq: map['maxFreq'],
      gain: map['gain']
    );
  }

  Map<String, dynamic> toMap(_EqualizationBand band) {
    return {
      'centerFrequency': band.centerFrequency,
      'minFreq': band.minFreq,
      'maxFreq': band.maxFreq,
      'gain': band.gain
    };
  }

}