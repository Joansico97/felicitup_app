import 'package:either_dart/either.dart';
import 'package:felicitup_app/core/constants/constants.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/repositories/auth_repository.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthFirebaseResource implements AuthRepository {
  AuthFirebaseResource({
    required DatabaseHelper client,
  }) : _client = client;

  final _ref = FirebaseAuth.instance;
  final DatabaseHelper _client;

  @override
  Future<Either<ApiException, void>> logout() async {
    try {
      await _ref.signOut();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      // final message = _ref.read(appEventsProvider.notifier).mapFirebaseAuthError(e);
      return Left(ApiException(400, e.message ?? ''));
    } catch (e) {
      return Left(ApiException(400, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, String>> login({required String email, required String password}) async {
    try {
      await _ref.signInWithEmailAndPassword(email: email, password: password);
      return const Right('');
    } on FirebaseAuthException catch (e) {
      // final message = _ref.read(appEventsProvider.notifier).mapFirebaseAuthError(e);
      return Left(ApiException(400, e.message ?? ''));
    } catch (e) {
      return Left(ApiException(400, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, UserCredential>> register({required String email, required String password}) async {
    try {
      final userCredential = await _ref.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(userCredential);
    } on FirebaseAuthException catch (e) {
      // final message = _ref.read(appEventsProvider.notifier).mapFirebaseAuthError(e);
      return Left(ApiException(400, e.message ?? ''));
    } catch (e) {
      return Left(ApiException(400, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, UserCredential>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final response = await _ref.signInWithCredential(credential);

      return Right(response);
    } on FirebaseAuthException catch (e) {
      // final message = _ref.read(appEventsProvider.notifier).mapFirebaseAuthError(e);
      return Left(ApiException(400, e.message ?? ''));
    } catch (e) {
      return Left(ApiException(400, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, String>> setFCMToken({required String token}) async {
    try {
      final userId = _ref.currentUser?.uid;
      if (userId == null) {
        return Left(ApiException(400, 'User not logged in'));
      }
      _client.update(
        AppConstants.appTitle,
        {
          'fcmToken': token,
        },
        document: userId,
      );

      return const Right('');
    } catch (e) {
      return Left(ApiException(400, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, String>> updateCurrentChat({required String chatId}) async {
    try {
      final userId = _ref.currentUser?.uid;
      if (userId == null) {
        return Left(ApiException(400, 'User not logged in'));
      }
      _client.update(
        AppConstants.appTitle,
        {
          'currentChat': chatId,
        },
        document: userId,
      );

      return const Right('');
    } catch (e) {
      return Left(ApiException(400, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, UserCredential>> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          //Solicita los datos que necesites
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final OAuthProvider oAuthProvider = OAuthProvider("apple.com"); //Importante, el providerId
      final AuthCredential credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      final response = await _ref.signInWithCredential(credential);

      return Right(response);
    } on FirebaseAuthException catch (e) {
      // final message = _ref.read(appEventsProvider.notifier).mapFirebaseAuthError(e);
      return Left(ApiException(400, e.message ?? ''));
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return Left(ApiException(400, e.toString()));
    }
  }
}
