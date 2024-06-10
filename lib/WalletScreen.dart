import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'walletProvider.dart';

class WalletScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (walletProvider.isLoading)
              CircularProgressIndicator()
            else
              Column(
                children: [
                  Text(
                    'Address: ${walletProvider.address}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'USDT Balance: ${walletProvider.balance}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Example of sending USDT
                      // walletProvider.sendUSDT(EthereumAddress.fromHex("recipient_address"), BigInt.from(10));
                    },
                    child: Text('Send USDT'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
