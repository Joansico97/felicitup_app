part of 'router.dart';

class RouterPaths {
  static const String init = '/init';
  static const String home = '/home';
  static const String createFelicitup = '/createFelicitup';
  static const String felicitupsDashboard = '/felicitupsDashboard';
  static const String login = '/login';
  static const String register = '/register';
  static const String federatedRegister = '/federatedRegister';
  static const String forgotPassword = '/forgotPassword';
  static const String finishRegister = '/finishRegister';
  static const String termsConditions = '/termsConditions';
  static const String verification = '/verification';
  static const String notifications = '/notifications';
  static const String notificationsSettings = '/notificationsSettings';
  static const String inviteContacts = '/inviteContacts';
  static const String felicitupDetailsDashboard = '/felicitupDetailsDashboard';
  static const String infoFelicitup = '/infoFelicitup';
  static const String messageFelicitup = '/messageFelicitup';
  static const String peopleFelicitup = '/peopleFelicitup';
  static const String videoFelicitup = '/videoFelicitup';
  static const String boteFelicitup = '/boteFelicitup';
  static const String felicitupPastDetailsDashboard =
      '/felicitupPastDetailsDashboard';
  static const String mainPastFelicitup = '/mainPastFelicitup';
  static const String chatPastFelicitup = '/chatPastFelicitup';
  static const String peoplePastFelicitup = '/peoplePastFelicitup';
  static const String videoPastFelicitup = '/videoFelicPastitup';
  static const String payment = '/payment';
  static const String pastFelicitups = '/pastFelicitups';
  static const String confirmPayment = '/confirmPayment';
  static const String verifyPayment = '/verifyPayment';
  static const String profile = '/profile';
  static const String notificationInfo = '/notificationInfo';
  static const String videoEditor = '/videoEditor';
  static const String contacts = '/contacts';
  static const String detailsContact = '/detailsContact';
  static const String giftcard = '/giftcard';
  static const String giftcardItemDetail = '/giftcardItemDetail';
  static const String singleChat = '/singleChat';
  static const String listSingleChat = '/listSingleChat';
  static const String wishList = '/wishList';
  static const String wishListEdit = '/wishListEdit';
  static const String felicitupNotification = '/felicitupNotification';
  static const String termsPolicies = '/termsPolicies';
  static const String reminders = '/reminders';
  static const String phoneVerifyInt = '/phoneVerifyInt';

  List<String> get noAuthenticated => [
    init,
    login,
    register,
    termsConditions,
    verification,
    inviteContacts,
    forgotPassword,
    notificationInfo,
    termsPolicies,
  ];
}
