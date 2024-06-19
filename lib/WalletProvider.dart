import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart' as web3;
import 'package:web3dart/crypto.dart' as crypto;
import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WalletProvider extends ChangeNotifier {
  final _storage = FlutterSecureStorage();
  final _client = web3.Web3Client(
    'https://polygon-amoy.infura.io/v3/${dotenv.env['INFURA_PROJECT_ID']}',
    http.Client(),
  );
  String? _privateKey;
  String? _address;
  String _ethBalance = '0';
  String _usdtBalance = '0';
  bool _isLoading = false;

  String? get address => _address;
  String get ethBalance => _ethBalance;
  String get usdtBalance => _usdtBalance;
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

    final storageRef = FirebaseStorage.instance.ref().child('wallets/${user.uid}');
    try {
      final userDoc = await storageRef.getData();
      if (userDoc != null) {
        final data = jsonDecode(utf8.decode(userDoc!));
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
    await fetchBalances();
  }

  Future<void> _createNewWallet(User user, Reference storageRef) async {
    final rng = Random.secure();
    final credentials = web3.EthPrivateKey.createRandom(rng);
    _privateKey = crypto.bytesToHex(credentials.privateKey);
    _address = (await credentials.extractAddress()).hex;

    final data = jsonEncode({'privateKey': _privateKey, 'address': _address});
    await storageRef.putData(utf8.encode(data));

    notifyListeners();
  }

  Future<void> fetchBalances() async {
    await _getETHBalance();
    await _getUSDTBalance();
  }

  Future<void> _getETHBalance() async {
    if (_address == null) return;

    try {
      setLoading(true);
      final balance = await _client.getBalance(web3.EthereumAddress.fromHex(_address!));
      _ethBalance = balance.getValueInUnit(web3.EtherUnit.ether).toString();
    } catch (e) {
      print('Error getting ETH balance: $e');
    } finally {
      setLoading(false);
    }

    notifyListeners();
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

      _usdtBalance = balance.first.toString();
    } catch (e) {
      print('Error getting USDT balance: $e');
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
        chainId: 80002, // Polygon Amoy Testnet
      );

      await _getUSDTBalance(); // Update balance after sending
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
