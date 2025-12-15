import 'package:flutter/material.dart';
import 'package:flutterquiz/features/wallet/models/payout_method.dart';
import 'package:google_fonts/google_fonts.dart';

export 'colors.dart';

/// === Config ===
const appName = 'Elite Quiz';
const packageName = 'com.togafrica.mquiz';

/// Add your panel url here
// NOTE: make sure to not add '/' at the end of url
// NOTE: make sure to check if admin panel is http or https
const panelUrl = 'https://app.mquiz.uk/';

/// === Branding ===
///

/// Default App Theme : light or dark
const Brightness defaultTheme = Brightness.light;

// Phone Login, default country code AND max length of phone number allowed
const defaultCountryCodeForPhoneLogin = 'NG';
const maxPhoneNumberLength = 16;

final TextStyle kFonts = GoogleFonts.nunito();
final TextTheme kTextTheme = GoogleFonts.nunitoTextTheme();

/// === Assets ===

// if you want to change the logo format like png, jpg, etc.
const kAppLogo = 'app_logo.svg';
const kSplashLogo = 'splash_logo.svg';
const kOrgLogo = 'org_logo.svg';
const kPlaceholder = 'placeholder.png';
// make it false, if you don't want to show org logo in the splash screen
const kShowOrgLogo = true;

// Sounds
const kSoundClickEvent = 'click.mp3';
const kSoundRightAnswer = 'right.mp3';
const kSoundWrongAnswer = 'wrong.mp3';

// Predefined messages for 1v1 and group battle
const predefinedMessages = [
  'Hello..!!',
  'How are you..?',
  'Fine..!!',
  'Have a nice day..',
  'Well played',
  'What a performance..!!',
  'Thanks..',
  'Welcome..',
  'Merry Christmas',
  'Happy new year',
  'Happy Diwali',
  'Good night',
  'Hurry Up',
  'Dudeeee',
];

// Exam Rules are shown before starting any exam
const examRules = [
  'I will not copy; I will take this exam honestly.',
  'If you lock your phone, the exam will end automatically.',
  "If you minimize the app or open another app and don't return within 5 seconds, the exam will end automatically.",
  'Screen recording is prohibited.',
  'On Android, taking screenshots is prohibited.',
  'On iOS, if you take a screenshot, you will violate the rules and the examiner will be notified.',
];

// Wallet - shown in wallet screen, before redeeming coins
List<String> payoutRequestNote(
  String payoutRequestCurrency,
  String amount,
  String coins,
) {
  /// Change this texts as per your requirement
  return [
    'Minimum Redeemable amount is $payoutRequestCurrency $amount ($coins Coins).',
    'Payout will take 3 - 5 working days',
  ];
}

/// Wallet - Payout Methods for redeeming coins. you can add any Payment method you want,
/// like, Paypal, UPI, Bank Transfer, Crypto, Paytm, etc.
const _paymentPath = 'assets/config/payment_methods';
const payoutMethods = [
  //Paypal
  PayoutMethod(
    image: '$_paymentPath/paypal.svg',
    type: 'Paypal',
    inputs: [
      (
        name: 'Enter paypal id', // Name for the field
        isNumber: false, // If input is number or not
        maxLength: 0, // Leave 0 for no limit for input.
      ),
    ],
  ),

  //Paytm
  PayoutMethod(
    image: '$_paymentPath/paytm.svg',
    type: 'Paytm',
    inputs: [(name: 'Enter mobile number', isNumber: true, maxLength: 10)],
  ),

  //UPI
  PayoutMethod(
    image: '$_paymentPath/upi.svg',
    type: 'UPI',
    inputs: [
      (
        name: 'Enter UPI id',
        isNumber: false,
        maxLength: 0, // Leave 0 for no limit for input.
      ),
    ],
  ),

  // Example: Bank Transfer
  PayoutMethod(
    inputs: [
      (
        name: 'Enter Bank Name',
        isNumber: false,
        maxLength: 0,
      ),
      (
        name: 'Enter Account Number',
        isNumber: false,
        maxLength: 0,
      ),
      (
        name: 'Enter Account Name',
        isNumber: false,
        maxLength: 0,
      ),
    ],
    image: '$_paymentPath/bank.svg',
    type: 'Bank Transfer',
  ),
];
