import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:binance_demo/bet_provider.dart';  // Ensure this import is correct
import 'dart:math';  // Import for the pow function

class BetScreen extends StatefulWidget {
  @override
  _BetScreenState createState() => _BetScreenState();
}

class _BetScreenState extends State<BetScreen> {
  final _amountController = TextEditingController();
  final _cryptocurrencyController = TextEditingController();
  bool _isUp = true;
  double _duration = 30.0;

  @override
  void dispose() {
    _amountController.dispose();
    _cryptocurrencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final betProvider = Provider.of<BetProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ethereum Betting App'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.account_balance_wallet),
            onPressed: () {
              // Implement wallet screen navigation
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade900, Colors.blue.shade300],
              ),
            ),
          ),
          betProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20),
                      CircleAvatar(
                        backgroundImage: AssetImage('images/crypto_image.jfif'),
                        radius: 50,
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(labelText: 'Bet Amount (USDT)'),
                            ),
                            DropdownButtonFormField<String>(
                              value: 'ETH',
                              items: ['ETH', 'BTC', 'USDT'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _cryptocurrencyController.text = newValue!;
                                });
                              },
                              decoration: InputDecoration(labelText: 'Cryptocurrency'),
                            ),
                            Slider(
                              value: _duration,
                              min: 1,
                              max: 120,
                              divisions: 119,
                              label: _duration.round().toString(),
                              onChanged: (double value) {
                                setState(() {
                                  _duration = value;
                                });
                              },
                            ),
                            Text('Bet Duration: ${_duration.round()} minutes'),
                            SwitchListTile(
                              title: Text('Bet Type: ${_isUp ? 'Up' : 'Down'}'),
                              value: _isUp,
                              onChanged: (value) {
                                setState(() {
                                  _isUp = value;
                                });
                              },
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final amount = double.tryParse(_amountController.text);
                                final cryptocurrency = _cryptocurrencyController.text;
                                if (amount != null && cryptocurrency.isNotEmpty) {
                                  final amountInWei = BigInt.from(amount * pow(10, 18));
                                  await betProvider.placeBet(
                                    amountInWei,
                                    _duration.round(),
                                    _isUp,
                                    cryptocurrency,
                                  );
                                }
                              },
                              child: Text('Place Bet'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
