import 'dart:convert';
import 'dart:typed_data';
import 'dart:math'; // Import dart:math for Random class

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';

class Bet {
  final String id;
  final int amount;
  final int duration;
  final bool isUp;
  final String bettor;
  final String cryptocurrency;
  final DateTime createdAt;

  Bet({
    required this.id,
    required this.amount,
    required this.duration,
    required this.isUp,
    required this.bettor,
    required this.cryptocurrency,
    required this.createdAt,
  });

  BetType get type => isUp ? BetType.up : BetType.down;

  factory Bet.fromMap(Map<String, dynamic> map) {
    return Bet(
      id: map['id'] as String,
      amount: map['amount'] as int,
      duration: map['duration'] as int,
      isUp: map['isUp'] as bool,
      bettor: map['bettor'] as String,
      cryptocurrency: map['cryptocurrency'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}

enum BetType { up, down }

class BetProvider extends ChangeNotifier {
  late Web3Client _client;
  String? _privateKey;
  String? _address;
  bool _isLoading = false;
  DeployedContract? _betContract;

  bool get isLoading => _isLoading;

  BetProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _client = Web3Client(
      'https://polygon-amoy.infura.io/v3/${dotenv.env['INFURA_PROJECT_ID']}',
      Client(),
    );
    await _loadOrCreateWallet();
    await _loadBetContract();
  }

  Future<void> _loadOrCreateWallet() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final storageRef = FirebaseStorage.instance.ref().child('wallets/${user.uid}');
    try {
      final userDoc = await storageRef.getData();
      if (userDoc != null) {
        final data = jsonDecode(utf8.decode(userDoc));
        _privateKey = data['privateKey'];
        _address = data['address'];
      } else {
        await _createNewWallet(user, storageRef);
      }
    } catch (e) {
      print('Error loading wallet: $e');
      await _createNewWallet(user, storageRef);
    }

    notifyListeners();
  }

  Future<void> _createNewWallet(User user, Reference storageRef) async {
    final rng = Random.secure(); // Using Random.secure() to create secure random numbers
    final credentials = EthPrivateKey.createRandom(rng);
    _privateKey = bytesToHex(credentials.privateKey);
    _address = (await credentials.extractAddress()).hex;

    final data = jsonEncode({'privateKey': _privateKey, 'address': _address});
    await storageRef.putData(utf8.encode(data));

    notifyListeners();
  }

  Future<void> _loadBetContract() async {
    String abiString = await rootBundle.loadString('BetContractABI.json');
    final abi = ContractAbi.fromJson(abiString, 'BetContract');
    final contractAddress = EthereumAddress.fromHex(dotenv.env['BET_CONTRACT_ADDRESS']!);
    _betContract = DeployedContract(abi, contractAddress);
  }

  Future<void> placeBet(BigInt amount, int duration, bool isUp, String cryptocurrency) async {
    try {
      setLoading(true);
      if (_privateKey == null) {
        throw Exception('Private key is null');
      }
      if (_betContract == null) {
        throw Exception('Bet contract is null');
      }

      final function = _betContract!.function('placeBet');
      final credentials = EthPrivateKey.fromHex(_privateKey!);

      final result = await _client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: _betContract!,
          function: function,
          parameters: [
            cryptocurrency,
            BigInt.from(duration),
            isUp ? BigInt.one : BigInt.zero,
          ],
          value: EtherAmount.inWei(amount),
        ),
        chainId: 80002,
      );

      print('Transaction hash: $result');
    } catch (e) {
      print('Error placing bet: $e');
    } finally {
      setLoading(false);
    }

    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<List<Bet>> getBets() async {
    if (_betContract == null) {
      throw Exception('Bet contract is null');
    }

    final function = _betContract!.function('getBets');
    final result = await _client.call(
      contract: _betContract!,
      function: function,
      params: [],
    );

    final List<Bet> bets = [];
    for (var bet in result[0]) {
      bets.add(Bet.fromMap({
        'id': bet[0].toString(),
        'amount': (bet[1] as BigInt).toInt(),
        'duration': (bet[2] as BigInt).toInt(),
        'isUp': (bet[3] as BigInt) == BigInt.one,
        'bettor': bet[4].toString(),
        'cryptocurrency': bet[5].toString(),
        'createdAt': (bet[6] as BigInt).toInt() * 1000,
      }));
    }

    return bets;
  }
}

String bytesToHex(Uint8List bytes, {bool include0x = true}) {
  final buffer = StringBuffer();
  if (include0x) {
    buffer.write('0x');
  }
  for (var part in bytes) {
    buffer.write(part.toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}
