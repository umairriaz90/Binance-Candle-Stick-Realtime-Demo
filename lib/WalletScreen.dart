import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // Import this for clipboard functionality
import 'package:web3dart/web3dart.dart'; // Import this for EthereumAddress
import 'walletProvider.dart';

class WalletScreen extends StatelessWidget {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'Address: ${walletProvider.address ?? 'No address available'}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (walletProvider.address != null)
                        IconButton(
                          icon: Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: walletProvider.address!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Address copied to clipboard')),
                            );
                          },
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'USDT Balance: ${walletProvider.balance}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _recipientController,
                    decoration: InputDecoration(labelText: 'Recipient Address'),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(labelText: 'Amount to Send'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final recipientAddress = _recipientController.text;
                      final amountText = _amountController.text;

                      if (recipientAddress.isNotEmpty && amountText.isNotEmpty) {
                        final amount = BigInt.tryParse(amountText);
                        if (amount != null) {
                          await walletProvider.sendUSDT(
                            EthereumAddress.fromHex(recipientAddress),
                            amount,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Invalid amount')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter recipient address and amount')),
                        );
                      }
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
