abstract interface class IDiscoveryFeedbackRepository {
  Future<void> recordSaved(String trackId, {required bool isSaved});
}
