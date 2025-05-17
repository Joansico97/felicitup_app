import 'package:either_dart/either.dart';
import 'package:felicitup_app/data/exceptions/exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<Either<ApiException, String>> login({
    required String email,
    required String password,
  });
  Future<Either<ApiException, UserCredential>> register({
    required String email,
    required String password,
  });
  Future<Either<ApiException, void>> logout();
  Future<Either<ApiException, UserCredential>> signInWithGoogle();
  Future<Either<ApiException, UserCredential>> signInWithApple();
  Future<Either<ApiException, String>> setFCMToken({required String token});
  Future<Either<ApiException, String>> updateCurrentChat({
    required String chatId,
  });
  Future<Either<ApiException, String>> verifyPhone({
    required String phone,
    required Function(String) onCodeSent,
    required Function(String) onError,
  });
  Future<Either<ApiException, bool>> confirmVerification({
    required String verificationId,
    required String smsCode,
  });
  Future<Either<ApiException, String>> forgotPassword({required String email});
}
