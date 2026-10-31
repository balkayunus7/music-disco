part of '../pages/session_page.dart';

class SessionPlayerCard extends StatelessWidget {
  const SessionPlayerCard({super.key, required this.track});
  final Track track;
  @override
  Widget build(BuildContext context) => TrackPlayerCard(track: track);
}
