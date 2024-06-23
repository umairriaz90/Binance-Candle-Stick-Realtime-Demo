import 'package:flutter/foundation.dart';

enum BetType { up, down }

class Bet {
  final String id;
  final String cryptocurrency;
  final BetType type;
  final int amount;
  final Duration duration;
  final DateTime createdAt;

  Bet({
    required this.id,
    required this.cryptocurrency,
    required this.type,
    required this.amount,
    required this.duration,
    required this.createdAt,
  });
}
