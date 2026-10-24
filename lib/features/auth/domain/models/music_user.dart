import 'package:mobile_boilerplate/common_dependencies.dart';
import 'package:mobile_boilerplate/domain/auth/purchaser.dart';
import 'package:mobile_boilerplate/domain/auth/user.dart';
import 'package:mobile_boilerplate/domain/purchases/subscription.dart';

class MusicUser extends User {
  const MusicUser({
    required super.userId,
    required super.purchaser,
    super.subscription,
    this.name,
    this.firebaseToken,
  });

  factory MusicUser.fromMap(Map<String, dynamic> map) => MusicUser(
    userId: map['user_id'] as String,
    purchaser: Purchaser(
      id: map['revenuecat_id'] as String? ?? map['user_id'] as String,
      offerings: const PurchaseOfferings(
        subscriptionOfferingIds: KtMap.empty(),
      ),
    ),
    subscription: map['premium_info'] == null
        ? null
        : Subscription.fromMap(
            Map<String, dynamic>.from(map['premium_info'] as Map),
          ),
    name: map['name'] as String?,
    firebaseToken: map['firebase_token'] as String?,
  );

  final String? name;
  final String? firebaseToken;

  MusicUser copyWith({
    String? name,
    String? firebaseToken,
    Subscription? subscription,
  }) => MusicUser(
    userId: userId,
    purchaser: purchaser,
    subscription: subscription ?? this.subscription,
    name: name ?? this.name,
    firebaseToken: firebaseToken ?? this.firebaseToken,
  );

  @override
  MusicUser withSubscription(Subscription subscription) =>
      copyWith(subscription: subscription);

  @override
  List<Object?> get props => [...super.props, name, firebaseToken];
}
