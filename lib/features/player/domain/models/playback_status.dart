enum PlaybackStatus {
  idle,
  cued,
  buffering,
  playing,
  paused,
  ended,
  error;

  bool get isActive => this == playing || this == buffering;
}
