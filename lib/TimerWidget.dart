import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TimerWidget extends StatefulWidget {
  TimerWidget({Key key, this.duration, this.tick, this.onTick})
      : super(key: key);
  final Duration duration;
  final Duration tick;
  final Function onTick;
  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  static final TextStyle _timeTextStyle =
      TextStyle(color: Colors.white, fontSize: 30);
  static final SnackBar _breakMessage =
      SnackBar(content: Text('It\'s time to take a break!'));

  Timer _timer;
  Duration _duration;
  Duration _tick;
  Function _onTick;
  Duration _countdown;
  DateTime _endTime;
  String _buttonText;
  String _displayTime;
  VideoPlayerController _playerController;

  @override
  void initState() {
    setState(() {
      _duration = widget.duration ?? Duration(minutes: 25);
      _tick = widget.tick ?? Duration(milliseconds: 100);
      _onTick = widget.onTick ?? (String displayTime) => {};
      _playerController = VideoPlayerController.asset('assets/audio/ring.ogg')
        ..setLooping(false)
        ..initialize();
      resetTimer();
    });
    super.initState();
  }

  String getDisplayTime(Duration time) {
    int minutes = time.inMinutes;
    int seconds = (time.inSeconds - (time.inMinutes * 60));
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void startTimer(BuildContext context) {
    setState(() {
      _endTime = DateTime.now().add(_duration);
      _displayTime = getDisplayTime(_duration - _tick);
      _onTick(_displayTime);
      _buttonText = 'Stop';
      _timer = Timer.periodic(_tick, (Timer timer) {
        setState(() {
          _countdown = _endTime.difference(DateTime.now());
          _displayTime = getDisplayTime(_countdown);
          _onTick(_displayTime);
          if (DateTime.now().isAfter(_endTime)) {
            stopTimer();
            alarmRing();
            Scaffold.of(context).showSnackBar(_breakMessage);
          }
        });
      });
    });
  }

  void stopTimer() => setState(() {
        _buttonText = 'Reset';
        _timer.cancel();
      });

  void resetTimer() => setState(() {
        _countdown = _duration;
        _displayTime = getDisplayTime(_countdown);
        _buttonText = 'Start';
      });

  void alarmRing() => _playerController
      .seekTo(Duration.zero)
      .then((_) => _playerController.play());

  void buttonPress(BuildContext context) {
    if (_timer?.isActive ?? false) {
      stopTimer();
    } else {
      if (_countdown == _duration) {
        startTimer(context);
      } else {
        resetTimer();
        _onTick(_displayTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        SizedBox(
          height: 300,
          width: 300,
          child: CircularProgressIndicator(
            value: _countdown.inMilliseconds / _duration.inMilliseconds,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.lime),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  _displayTime,
                  style: _timeTextStyle,
                ),
              ],
            ),
            FlatButton(
              color: Colors.green,
              textColor: Colors.white,
              child: Text(_buttonText),
              shape: StadiumBorder(),
              onPressed: () => buttonPress(context),
            ),
          ],
        ),
      ],
    );
  }
}
