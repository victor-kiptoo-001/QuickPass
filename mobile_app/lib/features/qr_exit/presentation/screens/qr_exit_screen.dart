import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:quickpass/features/qr_exit/data/models/qr_model.dart';
import 'package:quickpass/features/qr_exit/data/qr_repository.dart';
import 'package:quickpass/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

class QrExitScreen extends StatefulWidget {
  final String paymentId;

  const QrExitScreen({super.key, required this.paymentId});

  @override
  State<QrExitScreen> createState() => _QrExitScreenState();
}

class _QrExitScreenState extends State<QrExitScreen> {
  final _qrRepository = QrRepository();
  QrModel? _qrCode;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _timer;
  Duration _timeLeft = const Duration(minutes: 10);

  @override
  void initState() {
    super.initState();
    _fetchQrCode();
    _startTimer();
  }

  Future<void> _fetchQrCode() async {
    setState(() => _isLoading = true);
    try {
      _qrCode = await _qrRepository.fetchQrCode(widget.paymentId);
      if (await Vibrate.canVibrate) {
        Vibrate.feedback(FeedbackType.success);
      }
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.errorFetchingQr;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_qrCode != null) {
        final timeLeft = _qrCode!.expiresAt.difference(DateTime.now());
        if (timeLeft.isNegative) {
          setState(() {
            _timeLeft = Duration.zero;
            _errorMessage = AppLocalizations.of(context)!.qrExpired;
          });
          timer.cancel();
        } else {
          setState(() => _timeLeft = timeLeft);
        }
      }
    });
  }

  void _shareReceipt() async {
    if (_qrCode == null) return;
    try {
      final shareUrl = await _qrRepository.shareReceipt(_qrCode!.receiptUrl);
      await Share.share(
        AppLocalizations.of(context)!.shareReceiptMessage(shareUrl),
        subject: AppLocalizations.of(context)!.receipt,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorSharingReceipt),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _downloadReceipt() async {
    if (_qrCode == null) return;
    try {
      final url = await _qrRepository.downloadReceipt(_qrCode!.receiptUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.receiptDownloaded(url)),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorDownloadingReceipt),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _contactSupport() {
    // TODO: Implement call/SMS integration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.contactSupport),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.exitVerification),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Text(
                AppLocalizations.of(context)!.showQrToExit,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E88E5),
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(),
              const SizedBox(height: 16),
              // QR Code or Loading/Error
              Expanded(
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : _errorMessage != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red, fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _fetchQrCode,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E88E5),
                                  ),
                                  child: Text(AppLocalizations.of(context)!.retry),
                                ),
                              ],
                            )
                          : _qrCode != null
                              ? Card(
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        QrImageView(
                                          data: _qrCode!.token,
                                          version: QrVersions.auto,
                                          size: 200.0,
                                          backgroundColor: Colors.white,
                                          errorCorrectionLevel: QrErrorCorrectLevel.H,
                                        ).animate().scale(
                                              duration: const Duration(milliseconds: 500),
                                            ),
                                        const SizedBox(height: 16),
                                        Text(
                                          _timeLeft.inMinutes > 0
                                              ? AppLocalizations.of(context)!
                                                  .timeLeft('${_timeLeft.inMinutes}:${_timeLeft.inSeconds % 60}')
                                              : AppLocalizations.of(context)!.qrExpired,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: _timeLeft.inMinutes > 0
                                                    ? Colors.black
                                                    : Colors.red,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ).animate().fadeIn(delay: const Duration(milliseconds: 200))
                              : const SizedBox(),
                ),
              ),
              // Receipt Actions
              if (_qrCode != null && _timeLeft.inMinutes > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _shareReceipt,
                      icon: const Icon(Icons.share),
                      label: Text(AppLocalizations.of(context)!.shareReceipt),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF42A5F5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _downloadReceipt,
                      icon: const Icon(Icons.download),
                      label: Text(AppLocalizations.of(context)!.downloadReceipt),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF42A5F5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ).animate().fadeIn(delay: const Duration(milliseconds: 600)),
                  ],
                ),
              const SizedBox(height: 24),
              // Support Button
              TextButton(
                onPressed: _contactSupport,
                child: Text(
                  AppLocalizations.of(context)!.needHelp,
                  style: const TextStyle(
                    color: Color(0xFF1E88E5),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ).animate().fadeIn(delay: const Duration(milliseconds: 800)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}