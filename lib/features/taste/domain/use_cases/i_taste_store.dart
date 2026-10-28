import 'package:music_disco/features/taste/domain/models/taste_profile.dart';

abstract interface class ITasteStore {
  TasteProfile read();
  Future<void> write(TasteProfile profile);
}
