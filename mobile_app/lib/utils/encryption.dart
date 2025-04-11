import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:quickpass/config/app_config.dart';

class EncryptionUtil {
  static final _key = Key.fromUtf8(AppConfig.encryptionKey);
  static final _iv = IV.fromLength(16);
  static final _encrypter = Encrypter(AES(_key));

  static String encrypt(String plainText) {
    try {
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64;
    } catch (e) {
      throw Exception('Encryption failed: $e');
    }
  }

  static String decrypt(String encryptedText) {
    try {
      final encrypted = Encrypted.fromBase64(encryptedText);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  static String encryptJson(Map<String, dynamic> json) {
    return encrypt(jsonEncode(json));
  }

  static Map<String, dynamic> decryptJson(String encrypted) {
    return jsonDecode(decrypt(encrypted));
  }
}