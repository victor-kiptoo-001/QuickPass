import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:intl/intl.dart';
import 'package:quickpass/features/loyalty/data/loyalty_repository.dart';
import 'package:quickpass/features/loyalty/data/models/loyalty_model.dart';
import 'package:quickpass/l10n/app_localizations.dart';

class LoyaltyScreen extends StatefulWidget {
  final String userId; // Assume passed from auth context

  const LoyaltyScreen({super.key, required this.userId});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  final _loyaltyRepository = LoyaltyRepository();
  LoyaltyModel? _loyaltyData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLoyaltyData();
  }

  Future<void> _fetchLoyaltyData() async {
    setState(() => _isLoading = true);
    try {
      _loyaltyData = await _loyaltyRepository.fetchLoyaltyData(widget.userId);
      if (await Vibrate.canVibrate) {
        Vibrate.feedback(FeedbackType.light);
      }
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.errorFetchingLoyalty;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.loyaltyPoints),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLoyaltyData,
            tooltip: AppLocalizations.of(context)!.refresh,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Points Balance
              Text(
                AppLocalizations.of(context)!.yourPoints,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E88E5),
                    ),
              ).animate().fadeIn(),
              const SizedBox(height: 16),
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFFD700),
                            size: 40,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.pointsBalance,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : Text(
                                      '${_loyaltyData?.balance ?? 0}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            color: const Color(0xFF1E88E5),
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ).animate().count(
                                          begin: 0,
                                          end: _loyaltyData?.balance.toDouble() ?? 0,
                                          duration: const Duration(seconds: 1),
                                        ),
                            ],
                          ),
                        ],
                      ),
                      // Redeem Button
                      ElevatedButton(
                        onPressed: _isLoading || _loyaltyData == null || _loyaltyData!.balance == 0
                            ? null
                            : () {
                                // Navigate to payment screen with points pre-selected
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .usePointsInPayment),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF42A5F5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(AppLocalizations.of(context)!.redeem),
                      ),
                    ],
                  ),
                ),
              ).animate().slideY(
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 300),
                  ),
              const SizedBox(height: 24),
              // Points History
              Text(
                AppLocalizations.of(context)!.pointsHistory,
                style: Theme.of(context).textTheme.titleLarge,
              ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red, fontSize: 16),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _fetchLoyaltyData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E88E5),
                                  ),
                                  child: Text(AppLocalizations.of(context)!.retry),
                                ),
                              ],
                            ),
                          )
                        : _loyaltyData == null || _loyaltyData!.history.isEmpty
                            ? Center(
                                child: Text(
                                  AppLocalizations.of(context)!.noHistory,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              )
                            : ListView.builder(
                                itemCount: _loyaltyData!.history.length,
                                itemBuilder: (context, index) {
                                  final transaction = _loyaltyData!.history[index];
                                  return Card(
                                    elevation: 5,
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      leading: Icon(
                                        transaction.type == LoyaltyTransactionType.earned
                                            ? Icons.add_circle
                                            : Icons.remove_circle,
                                        color: transaction.type == LoyaltyTransactionType.earned
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      title: Text(
                                        transaction.type == LoyaltyTransactionType.earned
                                            ? AppLocalizations.of(context)!.pointsEarned
                                            : AppLocalizations.of(context)!.pointsRedeemed,
                                      ),
                                      subtitle: Text(
                                        DateFormat.yMMMd().add_jm().format(transaction.date),
                                      ),
                                      trailing: Text(
                                        '${transaction.points}',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: transaction.type ==
                                                      LoyaltyTransactionType.earned
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ).animate().slideX(
                                        delay: Duration(milliseconds: 100 * index),
                                        duration: const Duration(milliseconds: 300),
                                      );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}