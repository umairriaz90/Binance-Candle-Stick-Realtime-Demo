import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'wallet_provider.dart';

class WalletScreen extends StatelessWidget {
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet'),
      ),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Address: ${walletProvider.address ?? 'Loading...'}'),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy),
                      onPressed: () {
                        final address = walletProvider.address ?? 'No address available';
                        Clipboard.setData(ClipboardData(text: address));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Address copied to clipboard')),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Text('ETH Balance: ${walletProvider.ethBalance}'),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: walletProvider.isLoading ? null : walletProvider.fetchBalances,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('USDT Balance: ${walletProvider.usdtBalance}'),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: walletProvider.isLoading ? null : walletProvider.fetchBalances,
                    ),
                  ],
                ),
                if (walletProvider.isLoading) CircularProgressIndicator(),
                SizedBox(height: 32.0),
                TextField(
                  controller: _recipientController,
                  decoration: InputDecoration(
                    labelText: 'Recipient Address',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount of USDT',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: walletProvider.isLoading
                      ? null
                      : () async {
                          final recipient = web3.EthereumAddress.fromHex(_recipientController.text);
                          final amount = BigInt.parse(_amountController.text);
                          await walletProvider.sendUSDT(recipient, amount);
                        },
                  child: Text('Send USDT'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
