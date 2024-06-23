import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'bet_provider.dart';

class BetsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final betProvider = Provider.of<BetProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Bets'),
      ),
      body: FutureBuilder<List<Bet>>(
        future: betProvider.getBets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading bets: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No bets placed yet'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final bet = snapshot.data![index];
                return ListTile(
                  title: Text('Bet ID: ${bet.id}'),
                  subtitle: Text(
                    'Amount: ${bet.amount} USDT\n'
                    'Cryptocurrency: ${bet.cryptocurrency}\n'
                    'Type: ${bet.isUp ? 'Up' : 'Down'}\n'
                    'Date: ${DateFormat.yMd().format(bet.createdAt)}',
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
