import 'package:mobile_boilerplate/common_dependencies.dart';

class CollectionShelf extends Equatable {
  const CollectionShelf({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
