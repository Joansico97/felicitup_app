import 'package:either_dart/either.dart';
import 'package:felicitup_app/core/constants/constants.dart';
import 'package:felicitup_app/core/utils/logger.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/repositories/auth_repository.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:string_similarity/string_similarity.dart';

class AuthFirebaseResource implements AuthRepository {
  AuthFirebaseResource({
    required DatabaseHelper client,
    required FirebaseAuth firebaseAuth,
    required FirebaseFunctionsHelper firebaseFunctionsHelper,
  }) : _client = client,
       _firebaseAuth = firebaseAuth,
       _firebaseFunctionsHelper = firebaseFunctionsHelper;

  final FirebaseAuth _firebaseAuth;
  final DatabaseHelper _client;
  final FirebaseFunctionsHelper _firebaseFunctionsHelper;

  @override
  Future<Either<ApiException, void>> logout() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(ApiException(400, _mapFirebaseAuthErrors(e)));
    } catch (e) {
      return Left(ApiException(400, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, String>> login({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return const Right('');
    } on FirebaseAuthException catch (e) {
      return Left(ApiException(400, _mapFirebaseAuthErrors(e)));
    } catch (e) {
      return Left(ApiException(400, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, UserCredential>> register({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(userCredential);
    } on FirebaseAuthException catch (e) {
      return Left(ApiException(400, _mapFirebaseAuthErrors(e)));
    } catch (e) {
      return Left(ApiException(400, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, UserCredential>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final response = await _firebaseAuth.signInWithCredential(credential);

      return Right(response);
    } on FirebaseAuthException catch (e) {
      return Left(ApiException(400, _mapFirebaseAuthErrors(e)));
    } catch (e) {
      return Left(ApiException(400, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, String>> updateCurrentChat({
    required String chatId,
  }) async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null) {
        return Left(ApiException(400, 'User not logged in'));
      }
      _client.update(AppConstants.appTitle, {
        'currentChat': chatId,
      }, document: userId);

      return const Right('');
    } catch (e) {
      return Left(ApiException(400, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, Map<String, dynamic>>> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
          );
      final OAuthProvider oAuthProvider = OAuthProvider("apple.com");

      final AuthCredential credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      final response = await _firebaseAuth.signInWithCredential(credential);

      return Right({'credential': response, 'data': appleCredential});
    } on FirebaseAuthException catch (e) {
      return Left(ApiException(400, _mapFirebaseAuthErrors(e)));
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return Left(ApiException(400, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, String>> verifyPhone({
    required String phone,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (_) {},
        verificationFailed: (e) {
          logger.error('Error de verificación: ${e.message}');
          _firebaseFunctionsHelper.logErrors(
            error: 'Error de verificación: $e',
          );
          if (e.code == 'invalid-phone-number') {
            logger.error('Número de teléfono inválido');
          }
          onError(e.message ?? 'Error');
        },
        codeSent: (verificationId, _) => onCodeSent(verificationId),
        codeAutoRetrievalTimeout: (_) {},
      );
      return Right('response');
    } on FirebaseAuthException catch (e) {
      return Left(ApiException(400, _mapFirebaseAuthErrors(e)));
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return Left(ApiException(400, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, bool>> confirmVerification({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.linkWithCredential(credential);
      } else {
        await _firebaseAuth.signInWithCredential(credential);
        await _firebaseAuth.signOut();
      }

      return const Right(true);
    } on FirebaseAuthException catch (e) {
      return Left(ApiException(400, _mapFirebaseAuthErrors(e)));
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return Left(ApiException(400, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, String>> forgotPassword({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right('');
    } on FirebaseAuthException catch (e) {
      return Left(ApiException(400, _mapFirebaseAuthErrors(e)));
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      return Left(ApiException(400, e.toString()));
    }
  }

  @override
  Future<Either<ApiException, (bool, String?)>> validateEmailDomain({
    required String email,
  }) async {
    final cleanEmail = email.trim();

    if (!cleanEmail.contains('@')) {
      return const Right((false, null));
    }

    final domain = cleanEmail.split('@').last.toLowerCase();
    const commonDomains = [
      'gmail.com',
      'googlemail.com',
      'hotmail.com',
      'outlook.com',
      'live.com',
      'msn.com',
      'windowslive.com',
      'hotmail.es',
      'outlook.es',
      'live.com.mx',
      'hotmail.com.mx',
      'hotmail.com.ar',
      'outlook.com.ar',
      'hotmail.cl',
      'outlook.cl',
      'yahoo.com',
      'ymail.com',
      'yahoo.es',
      'yahoo.com.mx',
      'yahoo.com.ar',
      'yahoo.com.co',
      'rocketmail.com',
      'icloud.com',
      'me.com',
      'mac.com',
      'aol.com',
      'gmx.com',
      'gmx.es',
      'mail.com',
      'protonmail.com',
      'proton.me',
      'zoho.com',
      'yandex.com',
      'uol.com.br',
      'bol.com.br',
    ];

    try {
      final result = await _firebaseFunctionsHelper.validateEmailDomain(
        email: cleanEmail,
      );
      final bool isValid = result['valid'] as bool? ?? false;

      if (isValid) {
        return const Right((true, null));
      } else {
        final bestMatch = StringSimilarity.findBestMatch(domain, commonDomains);
        if ((bestMatch.bestMatch.rating ?? 0) > 0.8) {
          return Right((false, bestMatch.bestMatch.target));
        }
        return const Right((false, null));
      }
    } catch (e, s) {
      logger.error(
        'Error validating email domain via function $e, stack trace: $s',
      );

      if (commonDomains.contains(domain)) {
        return const Right((true, null));
      }

      final bestMatch = StringSimilarity.findBestMatch(domain, commonDomains);

      if ((bestMatch.bestMatch.rating ?? 0) > 0.8) {
        return Right((false, bestMatch.bestMatch.target));
      }
      return const Right((false, null));
    }
  }
}

String _mapFirebaseAuthErrors(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'El formato del correo electrónico no es válido';
    case 'user-disabled':
      return 'Esta cuenta ha sido deshabilitada';
    case 'user-not-found':
      return 'No existe una cuenta con este correo electrónico';
    case 'wrong-password':
      return 'Contraseña incorrecta';
    case 'email-already-in-use':
      return 'Este correo electrónico ya está registrado';
    case 'operation-not-allowed':
      return 'Este método de autenticación no está habilitado';
    case 'weak-password':
      return 'La contraseña es demasiado débil (mínimo 6 caracteres)';
    case 'requires-recent-login':
      return 'Debes iniciar sesión nuevamente para realizar esta acción';

    case 'account-exists-with-different-credential':
      return 'Esta cuenta ya existe con un método de autenticación diferente';
    case 'invalid-credential':
      return 'Credenciales de autenticación inválidas';
    case 'credential-already-in-use':
      return 'Estas credenciales ya están asociadas a otra cuenta';

    case 'invalid-verification-code':
      return 'El código de verificación es inválido o ha expirado';
    case 'invalid-verification-id':
      return 'El ID de verificación no es válido';
    case 'session-expired':
      return 'La sesión de verificación ha expirado. Solicita un nuevo código';
    case 'quota-exceeded':
      return 'Se ha excedido el límite de intentos. Intenta más tarde';
    case 'missing-verification-code':
      return 'No se proporcionó el código de verificación';
    case 'missing-verification-id':
      return 'No se proporcionó el ID de verificación';
    case 'invalid-phone-number':
      return 'El número de teléfono no es válido';
    case 'too-many-requests':
      return 'Demasiados intentos. Por favor, espera antes de intentar nuevamente';

    case 'popup-closed-by-user':
      return 'Cerraste la ventana de autenticación antes de completar el proceso';
    case 'network-request-failed':
      return 'Error de conexión a internet. Verifica tu red';

    case 'apple-auth-invalid-nonce':
      return 'Error en la autenticación con Apple (nonce inválido)';
    case 'apple-auth-invalid-id-token':
      return 'Error en la autenticación con Apple (token inválido)';

    case 'app-not-authorized':
      return 'La aplicación no está autorizada para usar Firebase Authentication';
    case 'expired-action-code':
      return 'El código de acción ha expirado';
    case 'invalid-action-code':
      return 'El código de acción no es válido';
    case 'missing-email':
      return 'No se proporcionó un correo electrónico';
    case 'missing-iframe-start':
      return 'Error interno de autenticación (iframe)';

    case 'auth-domain-config-required':
      return 'Configuración de dominio de autenticación requerida';
    case 'missing-client-type':
      return 'Falta el tipo de cliente en la configuración';
    case 'unauthorized-domain':
      return 'Dominio no autorizado para la autenticación';

    default:
      return 'Error desconocido: ${e.message ?? 'Por favor, intenta nuevamente'}';
  }
}
