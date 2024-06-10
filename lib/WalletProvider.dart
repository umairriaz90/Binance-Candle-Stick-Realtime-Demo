import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:web3dart/crypto.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WalletProvider extends ChangeNotifier {
  final _storage = FlutterSecureStorage();
  final _client = web3.Web3Client(
    'https://polygon-amoy.infura.io/v3/${dotenv.env['INFURA_PROJECT_ID']}',
    Client(),
  );
  String? _privateKey;
  String? _address;
  String _balance = '0';
  bool _isLoading = false;

  String? get address => _address;
  String get balance => _balance;
  bool get isLoading => _isLoading;

  WalletProvider() {
    _loadOrCreateWallet();
  }

  Future<void> _loadOrCreateWallet() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle user not logged in
      return;
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (userDoc.exists && userDoc['address'] != null) {
      _privateKey = await _storage.read(key: userDoc['address']);
      _address = userDoc['address'];
    } else {
      final rng = Random.secure();
      web3.EthPrivateKey credentials = web3.EthPrivateKey.createRandom(rng);
      _privateKey = bytesToHex(credentials.privateKey);
      _address = (await credentials.extractAddress()).hex;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'address': _address,
      });
      await _storage.write(key: _address!, value: _privateKey);
    }

    notifyListeners();
    _getUSDTBalance();
  }

  Future<void> _getUSDTBalance() async {
    if (_address == null) return;

    try {
      setLoading(true);
      final contract = web3.DeployedContract(
        web3.ContractAbi.fromJson(erc20Abi, 'USDT'),
        web3.EthereumAddress.fromHex(dotenv.env['USDT_CONTRACT_ADDRESS']!),
      );
      final function = contract.function('balanceOf');

      final balance = await _client.call(
        contract: contract,
        function: function,
        params: [web3.EthereumAddress.fromHex(_address!)],
      );

      _balance = balance.first.toString();
    } catch (e) {
      print('Error getting balance: $e');
    } finally {
      setLoading(false);
    }

    notifyListeners();
  }

  Future<void> sendUSDT(web3.EthereumAddress recipient, BigInt amount) async {
    if (_privateKey == null) return;

    try {
      setLoading(true);
      final contract = web3.DeployedContract(
        web3.ContractAbi.fromJson(erc20Abi, 'USDT'),
        web3.EthereumAddress.fromHex(dotenv.env['USDT_CONTRACT_ADDRESS']!),
      );
      final function = contract.function('transfer');

      final credentials = web3.EthPrivateKey.fromHex(_privateKey!);
      await _client.sendTransaction(
        credentials,
        web3.Transaction.callContract(
          contract: contract,
          function: function,
          parameters: [recipient, amount],
        ),
        chainId: 80001, // Polygon Mumbai Testnet
      );

      _getUSDTBalance(); // Update balance after sending
    } catch (e) {
      print('Error sending USDT: $e');
    } finally {
      setLoading(false);
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

const erc20Abi = '''
[
  {
    "constant": true,
    "inputs": [{"name": "_owner", "type": "address"}],
    "name": "balanceOf",
    "outputs": [{"name": "balance", "type": "uint256"}],
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [{"name": "_to", "type": "address"}, {"name": "_value", "type": "uint256"}],
    "name": "transfer",
    "outputs": [{"name": "success", "type": "bool"}],
    "type": "function"
  }
]
''';
