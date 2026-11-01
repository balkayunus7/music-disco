extension PlaybackDuration on Duration {
  String get playbackLabel {
    final safe = isNegative ? Duration.zero : this;
    final minutes = safe.inMinutes;
    final seconds = safe.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
