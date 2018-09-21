// Constants.m
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - Test Constants

// If we go to the test screen or not. (NO for production)
BOOL const TESTING = YES;
BOOL const TESTING_GEOFENCING = NO;

// Flag for if we are using sso.
BOOL const USE_SSO = YES;

// Flag for if we are logging request response information.
BOOL const LOG_REQUEST_RESPONSE = YES;

// The total amount of recent mdns to display
NSInteger const TOTAL_RECENT_MDNS = 10;

// The indices for each request type in the override url array.
NSInteger const PREPAY_URL_INDEX = 0;
NSInteger const POSTPAY_URL_INDEX = 1;
NSInteger const ALIAS_URL_INDEX = 2;
NSInteger const SSF_BASE_URL_INDEX = 3;
NSInteger const COOKIE_INDEX = 4;

#pragma mark - Splash Constants

// Show only the splash screen. For Testing. (NO for production)
BOOL const SPLASH_ONLY = NO;

// The default messages for the splash screen.
NSString * const DEFAULT_SPLASH_MESSAGE_1_KEY = @"DEFAULT_SPLASH_MESSAGE_1_KEY";
NSString * const DEFAULT_SPLASH_MESSAGE_2_KEY = @"DEFAULT_SPLASH_MESSAGE_2_KEY";
NSString * const DEFAULT_SPLASH_MESSAGE_3_KEY = @"DEFAULT_SPLASH_MESSAGE_3_KEY";
NSString * const DEFAULT_SPLASH_MESSAGE_4_KEY = @"DEFAULT_SPLASH_MESSAGE_4_KEY";
NSString * const DEFAULT_SPLASH_MESSAGE_5_KEY = @"DEFAULT_SPLASH_MESSAGE_5_KEY";
NSString * const DEFAULT_SPLASH_MESSAGE_6_KEY = @"DEFAULT_SPLASH_MESSAGE_6_KEY";

#pragma mark - URL Constants

// Server URLs
NSString * const BASE_PRODUCTION_URL = @"https://mobile.vzw.com";

NSString * const URL_MVM_COMPONENT = @"mvm";

NSString * const URL_NATIVE_SERVER_PATH_COMPONENT = @"mvmrc";
//mvmrc
//MVMRCClient
//NSString * const URL_NATIVE_SERVER_PATH_COMPONENT = @"hybridRCClient";
NSString * const URL_HYBRID_SERVER_PATH_COMPONENT = @"hybridClient";
NSString * const URL_HYBRID_LAST_COMPONENT = @"index.html";
NSString * const URL_HYBRID_LAST_COMPONENT_SPANISH = @"es/index.html";

NSString * const URL_PREPAY = @"https://mobile.vzw.com/MVMPrepayHybrid/myaccprepaid";

NSString * const URL_REGISTER_ALIAS = @"https://mobile.vzw.com/mvmrc/mvm/registerAlias";

NSString * const BASE_SSF_URL_STRING = @"https://mobileapps.vzw.com/";
NSString * const URL_DM_CACHE_COMPONENT = @"SSFGateway/WidgetUtils/getDataUsage";
NSString * const URL_DM_RECEIPT_COMPONENT = @"SSFGateway/WidgetUtils/deliveryReceipt";
NSString * const URL_DM_DEREGISTRATION_COMPONENT = @"SSFGateway/WidgetUtils/dmDeregistration";

NSString * const PING_URL_COMPONENT = @"isAlive.jsp";

#pragma mark - Other Constants

CGFloat const CORNER_RADIUS_TEXT_FEILD = 3.0f;

// Time before Timeout in seconds.
NSTimeInterval const TIME_OUT_TIME = 30.0;

NSTimeInterval const TIME_OUT_TIME_TEST = 60.0; // diff timeout since lower env backend can be real bad ex: CallFwd

// A constant for the button index when an alert is dismissed
NSInteger const ALERT_DISMISSED_INDEX_CONSTANT = -10;

// The width of the accessory view for cells.
CGFloat const ACCESSORY_WIDTH = 40;

CGFloat const RELATED_LINKS_HEIGHT = 44;

// MVD
NSString * const MVD_CLEANER_SCHEME = @"vzt://";

// Analytics
NSString * const MVM_WATCH_ANALYTICS = @"Data Meter";

#pragma mark - Static Cache Keys

NSString * const ERROR_TITLE_KEY = @"error";
NSString * const EMAIL_ADDRESS_KEY = @"emailAddressKey";
NSString * const CANCEL_CONFIRM_KEY = @"cancelConfirmKey";
NSString * const CONFIRM_KEY = @"confirm";
NSString * const FORGOT_PASSWORD_KEY = @"forgotPassword";
NSString * const EMPTY_FIELD_KEY = @"inputInformation";
NSString * const SAVE_CHANGES_KEY = @"saveChanges";
NSString * const SUBMIT_KEY = @"submit";
NSString * const UPDATE_KEY = @"updateKey";
NSString * const ENTER_SECRET_ANSWER_KEY = @"enterSecretAnswerKey";
NSString * const REQUIRED_KEY = @"required";
NSString * const ALT_PHONE_NUMBER_KEY = @"altPhoneNumberKey";
NSString * const BILLING_ADDRESS_1 = @"billingAddress1Key";
NSString * const BILLING_ADDRESS_2 = @"billingAddress2Key";
NSString * const CITY_KEY = @"cityKey";
NSString * const STATE_KEY = @"stateKey";
NSString * const ZIP_KEY = @"zipKey";
NSString * const ACCEPT_TNC_KEY = @"acceptTnCKey";
NSString * const SELECT_FEATURE = @"selectFeature";
NSString * const YES_KEY = @"yesKey";
NSString * const NO_KEY = @"noKey";
NSString * const CANCEL_KEY = @"cancel";
NSString * const ENTER_SEARCH_TEXT = @"enterSearchText";
NSString * const CALL_KEY = @"callKey";
NSString * const DIAL_KEY = @"dialKey";
NSString * const ALERT_TITLE_KEY = @"alert";
NSString * const SELECT_COUNTRY = @"selectCountry";
NSString * const EDIT_KEY = @"editKey";
NSString * const WARNING_TITLE_KEY = @"Warning";
NSString * const NO_SELECTION_MADE_KEY = @"noSelectionMade";
NSString * const SIGN_OUT_KEY = @"signOutKey";
NSString * const SPANISH_KEY = @"spanishKey";
NSString * const SIGN_OUT_CONFIRMATION_KEY = @"signOutConfirmationKey";
NSString * const ERROR_PASSWORD_MISMATCH_KEY = @"passwordMismatchKey";
NSString * const ERROR_PASSWORD_KEY = @"passwordErrorKey";
NSString * const ERROR_REQUIRED_FIELDS_KEY = @"enterAllRequired";
NSString * const INFORMATION_KEY = @"informationKey";
NSString * const LEAVING_MY_VERIZON_KEY = @"leaveMyVerizonKey";
NSString * const LEAVE_WITHOUT_SAVING_KEY = @"cancelNotSaveKey";
NSString * const NO_CHANGE_MADE_KEY = @"noChangesMade";
NSString * const SUCCESS_KEY = @"successKey";
NSString * const PROFILE_SETTINGS_KEY = @"profileSettingsKey";
NSString * const NOTIFICATION_FAIL_KEY = @"notificationFailKey";
NSString * const BACK_KEY = @"back";
NSString * const AGREE_BUTTON_TITLE_KEY = @"agreeKey";
NSString * const DECLINE_BUTTON_TITLE_KEY = @"declineKey";
NSString * const DISCLAIMER_KEY = @"disclaimerKey";
NSString * const REMEMBER_ME_MESSAGE_KEY = @"rememberMeKey";
NSString * const OR_CAPS_KEY = @"orKeyCaps";
NSString * const REVIEW_PAYMENT_KEY = @"reviewPaymentKey";
NSString * const TOTAL_PER_MONTH_CAPS = @"totalPerMonthKeyCaps";
NSString * const MY_VERIZON_REGISTRATION = @"myVerizonRegistration";
NSString * const ACCEPT_AND_CONTINUE_KEY = @"acceptAndContinue";
NSString * const ERROR_CHANGEUSERID_INVALID_KEY = @"changeUserIdInvalid";
NSString * const ERROR_GREETING_NAME_KEY = @"greetingNameInvalid";
NSString * const ERROR_CONFIRM_EMAIL_KEY = @"emailMismatch";
NSString * const ERROR_INVALID_ZIP_KEY = @"zipInvalid";
NSString * const ERROR_INVALID_SOCIAL_KEY = @"ssnInvalid";
NSString * const WORKSHOP_CAPS_KEY = @"workshopKeyCaps";
NSString * const APPOINTMENT_CAPS_KEY = @"appointmentKeyCaps";
NSString * const LOCATION_CAPS_KEY = @"locationKeyCaps";
NSString * const DATA_METER_AWARENESS_KEY = @"dataMeterAwarenessPopup";
NSString * const DATA_METER_ALLOW_NOTIFICATIONS_KEY = @"allowNotificationsPopup";
NSString * const DATA_METER_ACTIVATION_FAILED_KEY = @"dmActivationFailed";
NSString * const NO_THANKS_KEY = @"noThanks";
NSString * const GO_TO_SETTINGS_KEY = @"goToSettings";
NSString * const ERROR_PWD_SAMEAS_USERID_KEY = @"pwdUserIdSame";
NSString * const TUTORIAL_MENU_HDG = @"tutorialMenuHdg";
NSString * const TUTORIAL_MENU_MSG = @"tutorialMenuMsg";
NSString * const TUTORIAL_SWIPE = @"tutorialSwipe";
NSString * const TUTORIAL_NOTIFICATION_HDG = @"tutorialNotificationHdg";
NSString * const TUTORIAL_NOTIFICATION_MSG = @"tutorialNotificationMsg";
NSString * const TUTORIAL_CLOSE = @"tutorialClose";
NSString * const TUTORIAL_CONTINUE = @"tutorialContinue";
NSString * const USERNAME_INPUT = @"usernameInput";
NSString * const MY_FIOS = @"myFios";
NSString * const INPUT_MDN = @"inputMDN";
NSString * const SAVE_KEY = @"save";
NSString * const HOME_KEY = @"homeKey";
NSString * const REVIEW_KEY = @"reviewKey";
NSString * const AUTO_PAY_POST_FIX = @"autoPayPostFix";
NSString * const SELECT_ANOTHER_DEVICE_KEY = @"selectAnotherDeviceCaps";
NSString * const ERROR_CSQ_MISMATCH_ERROR_KEY = @"answerMismatch";
NSString * const ERROR_CSQ_ENTER_QUESTION_KEY = @"enterQuestion";
NSString * const ERROR_CSQ_ENTER_ANSWER_KEY = @"enterAnswer";
NSString * const ERROR_CSQ_ENTER_CONFIRM_ANSWER_KEY = @"enterConfirmAnswer";
NSString * const ERROR_CSQ_INCORRECT_LENGTH_ERROR_KEY = @"answerIncorrectLength";
NSString * const ERROR_CSQ_USER_MESSAGE_SPECIAL_CHARACTER_KEY = @"answerSpecialCharacters";
NSString * const SELECT_SECRET_QUESTION = @"selectSecretQuestion";
NSString * const SELECT_ONE = @"selectOne";
NSString * const ADD_MANAGER = @"addManager";
NSString * const FIRST_NAME_KEY = @"firstName";
NSString * const LAST_NAME_KEY = @"lastName";
NSString * const SELECT_A_LINE = @"selectALine";
NSString * const YES_CAPS = @"yesCaps";
NSString * const NO_CAPS = @"noCaps";
NSString * const EMPTY_FIRST_NAME = @"enterFirstName";
NSString * const EMPTY_LAST_NAME = @"enterLastName";
NSString * const INVALID_FIRST_NAME = @"firstNameNoSpecial";
NSString * const INVALID_LAST_NAME = @"lastNameNoSpecial";
NSString * const DELETE_PHONE_NUMBER_MESSAGE = @"deleteSelectedNumber";
NSString * const ERROR_NO_PHONE_NUMBER = @"emptyMobileNumber";
NSString * const ERROR_INVALID_PHONE_NUMBER_LENGTH = @"invalidMobileNumberLength";
NSString * const ERROR_INVALID_DESCRIPTION = @"specialsNotAllowed";
NSString * const ERROR_900_AREA_CODE = @"areaCode900";
NSString * const ERROR_SELF_MDN = @"enterSelfMDN";
NSString * const ERROR_DIRECTORY_ASSISTANCE_NO = @"directoryAssistance";
NSString * const ERROR_DUPLICATE_NUMBER = @"removeDuplicate";
NSString * const ERROR_NO_SELECTION = @"makeAnEntry";
NSString * const ERROR_ENTER_DIFFERENT_NUM = @"differentNumber";
NSString * const PASSWORD_TIPS = @"PasswordTips";
NSString * const AUTH_SUCCESS_FEATURE_FAIL = @"authSuccessFeatFail";
NSString * const CONFIRM_PASSWORD_KEY = @"confirmPassword";
NSString * const STATIC_PASSWORD_KEY = @"password";

//GRC
NSString * const VERIZONS_GLOBAL_TRAVEL_PROGRAM = @"VerizonsGlobalTravelProgram";
NSString * const GRC_CHECKING = @"checking";
NSString * const GRC_ACCOUNT_FEATURES = @"accountFeatures";
NSString * const GRC_DEVICE_SETTINGS = @"deviceSettings";
NSString * const GRC_ABROAD_NOTE = @"grcAbroadNote";
NSString * const COUNTRY_VO     =  @"countryVO";
NSString * const GRC_COMPATIBILITY_SCRNHDG     =  @"compatibilityScrnHdg";
NSString * const GRC_COMPATIBILITY_SCRNMSG     =  @"compatibilityScrnMsg";
NSString * const GRC_DESTINATION_NAME       =   @"destinationName";
NSString * const GRC_COMPATIBLE_DVC         =   @"compatibleDvc";
NSString * const GRC_INCOMPATIBLE_DVC       =   @"incompatibleDvc";
NSString * const GRC_INCOMPATIBLE_NTRK      =   @"incompatibleNtrk";
NSString * const GRC_SELECT_COUNTRY_MSG     =   @"selectCountryMsg";
NSString * const GRC_DVC_HWD_ELIGIBLE     =   @"dvcHwdEligible";

NSString * const LOCAL_USER_MESSAGE_INVALID_INPUT = @"messageInvalidInput";
NSString * const LOCAL_USER_MESSAGE_EMPTY_INPUT = @"messageEmptyInput";
NSString * const LOCAL_USER_MESSAGE_NOT_MATCH = @"messageNotMatch";
NSString * const MESSAGE_FAVORITE_STORE_SAVED = @"messageFavoriteStoreSaved";
NSString * const MESSAGE_FAVORITE_STORE_REMOVED = @"messageFavoriteStoreRemoved";
NSString * const SELECT_DEVICE = @"selectDevice";
NSString * const TOTAL_USED_KEY = @"TotalUsed";
NSString * const UNLIMITED_KEY = @"unlimited";
NSString * const FOOTER_NOTE = @"footerNote";
NSString * const DEVICE_SUMMARY_HEADING = @"dvcSmhdg";

NSString * const CAMERA_SETTINGS_MSG = @"Turn on camera to allow “My Verizon” to scan check or credit card. \n\n(Setting -> My Verizon -> Camera)";
#pragma mark - Request Parameters

// Client Params Keys
NSString * const OS_NAME_KEY = @"os_name";
NSString * const OS_VERSION_KEY = @"os_version";
NSString * const CURRENT_APP_VERSION_KEY = @"current_app_version";
NSString * const MODEL_NAME_KEY = @"model";
NSString * const BRAND_KEY = @"brand";
NSString * const FORM_FACTOR_KEY = @"formfactor";
NSString * const DEVICE_NAME_KEY = @"device_name";
NSString * const SOURCE_ID_KEY = @"sourceID";
NSString * const NETWORK_MODE_KEY = @"network_mode";
NSString * const DEVICE_MODE = @"deviceMode";
NSString * const WIFI_ENABLED_KEY = @"wifi_enabled";
NSString * const ERROR_LOGS_KEY = @"errorLogs";
NSString * const REMEMBER_ME_U_KEY = @"u";
NSString * const REMEMBER_ME_M_KEY = @"m";
NSString * const REMEMBER_ME_H_KEY = @"h";
NSString * const SOURCE_SERVER_KEY = @"source_server";
NSString * const MDN_KEY = @"mdn";
NSString * const NICKNAME_KEY = @"nickName";
NSString * const DEVICENAME_KEY = @"deviceName";
NSString * const PRODUCTNAME_KEY = @"productName";
NSString * const UPGRADE_ELIGIBILITY_TEXT = @"upgradeEligibtyTxt";
NSString * const VIEW_EDGE_AGREEMENT_TEXT = @"viewEdgeAgreementTxt";
NSString * const DEVICE_IS_UO = @"deviceIsUO";
NSString * const SUSPENDED_TEXT = @"lineStatus";
NSString * const SCREEN_WIDTH_KEY = @"sw";
NSString * const SCREEN_HEIGHT_KEY = @"sh";
NSString * const CURRENT_HYBRID_VERSION_KEY = @"current_hybrid_version";
NSString * const VZW_ID_KEY = @"x_vzw_id";
NSString * const IS_TABLET_KEY = @"isTablet";
NSString * const SUPPORT_LOCATION_SERVICES_KEY = @"support_location_services";
NSString * const SSO_TOKEN_KEY = @"SSOToken";
NSString * const SSF_SSO_TOKEN = @"ssoToken";
NSString * const PUSH_TOKEN_KEY = @"mottoken";
NSString * const MVM_REGISTER_REQUEST_KEY = @"mvmRegisterInd";
NSString * const MOT_KEY = @"mot";
NSString * const APP_NAME_KEY = @"appName";
NSString * const DM_REGISTER_REQUEST_KEY = @"dMRegisterInd";
NSString * const IS_WIDGET_INSTALLED_KEY = @"isWidgetInstalled";
NSString * const DATA_METER_AWARENESS_POPUP_SHOW_KEY = @"showDataMeterAwarenessPopup";
NSString * const PROFILE_OPTIONS_KEY = @"profileOptions";
NSString * const LOGIN_TYPE = @"loginType";
NSString * const DONT_SHOW_ROLE_INTERCEPT_AGAIN_KEY = @"doNotShow";
NSString * const SELECTED_LOGIN_TYPE = @"selectedLoginType";
NSString * const REGISTER_DEVICE_OAAM = @"registerDevice";
NSString * const TIME_ZONE = @"timeZone";
NSString * const REGISTERED_CLIENT_VERSION_KEY = @"registeredClientVersion";
NSString * const CAMERA_ALERT_MESSAGE_KEY = @"cameraAlertMessage";
NSString * const CAMERA_ALERT_TITLE_KEY = @"cameraAlertTitle";
NSString * const DEVICE_IDENTIFIER_KEY = @"deviceIdentifier";
NSString * const UNIQUE_ID_KEY = @"uniqueId";
NSString * const FROM_NON_VERIZON_USER = @"fromNonVerizonUser";
NSString * const HIDE_FOOTER = @"hideFooter";

// Client Params Values
NSString * const OS_NAME_VALUE = @"IOS";
NSString * const FORM_FACTOR_HANDSET_VALUE = @"handset";
NSString * const FORM_FACTOR_TABLET_VALUE = @"tablet";
NSString * const DEVICE_NAME_IPAD_VALUE = @"IPAD";
NSString * const DEVICE_NAME_IPHONE_VALUE = @"IPHONE";
NSString * const DEVICE_NAME_IPOD_VALUE = @"IPOD";
NSString * const SOURCE_ID_VALUE = @"mvmrc";
NSString * const SOURCE_ID_URL_VALUE = @"mvmrcdl";
NSString * const SOURCE_ID_DM_VALUE = @"mvmrcdm";
NSString * const SOURCE_ID_CORE_SPOTLIGHT = @"mvmrcsl";
NSString * const SOURCE_ID_APP_SHORTCUT = @"mvmrcasc";
NSString * const NETWORK_MODE_WIFI_VALUE = @"WIFI";
NSString * const NETWORK_MODE_3G_VALUE = @"3G";
NSString * const NETWORK_MODE_4G_VALUE = @"4G";
NSString * const SOURCE_SERVER_PREPAY_VALUE = @"PrePay";
NSString * const SOURCE_SERVER_POSTPAY_VALUE = @"PostPay";
NSString * const SOURCE_SERVER_NONE_VALUE = @"None";
NSString * const MOT_APNS_VALUE = @"APNS";
NSString * const APP_NAME_MVM_VALUE = @"MVM";
NSString * const PROFILE_OPTIONS_VALUE = @"myReceipts:validateLogin,addressChange:ssnAuth,accessManager:editPassword,profile:editEmail,accessManager:chgUsrIDMsg,accessManager:changeSecretQuestion,chngContact:auth,privacyMgr:auth,mcm:auth";
NSString * const LOGIN_TYPE_VALUE_AM = @"AM";
NSString * const SELECTED_LOGIN_TYPE_SSO_VALUE = @"SSOTOKEN";
NSString * const SELECTED_LOGIN_TYPE_HASH_VALUE = @"HASH";
NSString * const USE_TOUCH_ID = @"useTouchID";
NSString * const SIMPLE_OPTIONS_KEY = @"simpleOptions";

// Launch App Keys
NSString * const INITIAL_LAUNCH_KEY = @"Initial_Launch";
NSString * const USER_ID_KEY = @"userId";
NSString * const PASSWORD_KEY = @"password";

#pragma mark - Other Dictionary Keys and Values

// Request Parameters
NSString * const REQUEST_PARAMETERS_KEY = @"RequestParameters";

// The session key for getting the session cookie.
NSString * const SESSION_KEY = @"JSESSIONID";

// value for keychain service.
NSString * const SERVICE_REMEMBER_ME_KEY = @"mvm uhm";
NSString * const SERVICE_SSO_KEY = @"mvm sso";
NSString * const SERVICE_TOUCH_ID_KEY = @"mvm touch";
NSString * const SERVICE_DEVICE_ID = @"mvm device id";
NSString * const SERVICE_MMG_ID = @"mmg id";
NSString * const SERVICE_MMG_LOGIN_TOKEN = @"mmg login token";

// Key for the view controller to pop the stack to.
NSString * const VC_TO_POP_TO_KEY = @"vcToPopTo";

// Used to determine which flow a page may be in by which value is present for this key.
NSString * const FLOW_KEY = @"flow";

// Flow Values
NSString * const FLOW_FORGOT_PASSWORD_VALUE = @"forgotPassword";
NSString * const FLOW_RESET_PASSWORD_VALUE = @"resetPassword";
NSString * const FLOW_SETUP_PASSWORD_VALUE = @"setupSetPwd";
NSString * const FLOW_FORGOT_SECRET_QUESTION_ANSWER = @"forgotAnswer";

#pragma mark - Error Constants

// Error Strings
NSString * const ERROR_MESSAGE_TIMEOUT_KEY = @"Error Message Timeout Key";

// My Profile Error Messages
NSUInteger const NICKNAME_MAX_CHARACTER_LENGTH = 20;
NSUInteger const PASSWORD_MAX_CHARACTER_LENGTH = 20;
NSUInteger const PIN_MAX_CHARACTER_LENGTH = 4;
NSUInteger const ZIP_PAY_BILL_MAX_CHARACTER_LENGTH = 9;
NSUInteger const USER_ID_MAX_CHARACTER_LENGTH = 60;
NSUInteger const EMAIL_MAX_CHARACTER_LENGTH = 60;
NSUInteger const SECRET_ANSWER_MAX_CHARACTER_LENGTH = 40;
NSUInteger const ZIP_MAX_CHARACTER_LENGTH = 5;
NSUInteger const CONTACT_NUMBER_MAX_CHARACTER_LENGTH = 10;
NSUInteger const INTERNATIONAL_NUMBER_MAX_CHARACTER_LENGTH = 48;
NSUInteger const ADDRESS_LINE1_NUMBER_MAX_CHARACTER_LENGTH = 30;
NSUInteger const VOICE_MAIL_PASSWORD_MAX_CHARACTER_LENGTH = 7;

// Try again later message for user with *611. For critical erros that shouldn't happen, so the user should have an option to call in.
NSString * const ERROR_MESSAGE_CRITICAL_KEY = @"Error Message Critical Key";

// Unable to process your request error message.
NSString * const ERROR_MESSAGE_UNABLE_PROCESS_REQUEST_KEY = @"Error Message Unable To Process Request Key";

// Maximum number of errors to keep logged.
NSUInteger const MAX_ERRORS_LOGGED = 15;

// Name of the error log
NSString * const ERROR_LOG_NAME = @"\ErrorLog.txt";
NSString * const CRASH_LOG_NAME = @"CrashLog.txt";

// Key for error saving errors
NSString * const ERROR_SAVING_ERRORS_KEY = @"errorSavingErrors";

// Error Domains
NSString * const SYSTEM = @"SYSTEM";
NSString * const NATIVE = @"NATIVE";
NSString * const SERVER = @"SERVER";

// Error Codes
NSString * const ERROR_CODE_DEFAULT = @"1N";
NSString * const ERROR_CODE_PARSING_JSON = @"2N";
NSString * const ERROR_CODE_NO_ERROR_INFO = @"3N";
NSString * const ERROR_CODE_NO_PAGE_TYPE = @"4N";
NSString * const ERROR_CODE_INIT_CONTROLLER = @"5N";
NSString * const ERROR_CODE_POST_PROCESS_JSON = @"6N";
NSString * const ERROR_CODE_NATIVE_TIMEOUT = @"7N";
NSString * const ERROR_CODE_SHOWING_ALERT = @"8N";

NSString * const ERROR_CODE_LINKAWAY_FAILED = @"9N";
NSString * const ERROR_CODE_UNKNOWN_ACTION_TYPE = @"10N";

NSString * const ERROR_CODE_EMPTY_FIELD = @"11N";
NSString * const ERROR_CODE_INPUT_VALIDATION_FAILURE = @"12N";

NSString * const ERROR_CODE_TAB_SELECT = @"13N";

NSString * const ERROR_CODE_EMPTY_RESPONSE = @"14N";

NSString * const ERROR_CODE_STATIC_CACHE_FAIL = @"15N";

NSString * const ERROR_CODE_SERVER_FAIL_SEND_TOUCH_HASH = @"16N";

NSString * const ERROR_CODE_NO_MDN_FOR_ACCOUNT_SUMMARY = @"17N";

NSString * const ERROR_CODE_JSON_NOT_A_DICTIONARY = @"18N";

NSString * const ERROR_CODE_NO_LINK_AWAY_AFTER_SSO = @"19N";

NSString * const ERROR_CODE_NO_STORYBOARD = @"22N";
NSString * const ERROR_CODE_NO_VIEW_CONTROLLER_IDENTIFIER = @"23N";
NSString * const ERROR_CODE_NO_VIEW_CONTROLLER_NIB_NAME = @"24N";

// Server Error Codes
NSString * const ERROR_CODE_SERVER_AAA_FAILURE = @"12002";
NSString * const ERROR_CODE_ACCOUNT_LOCKED = @"12003";
NSString * const ERROR_CODE_SERVER_SSO_TOKEN_INVALID = @"12005";
NSString * const ERROR_CODE_SERVER_SSO_FAILURE_1 = @"12008";
NSString * const ERROR_CODE_SERVER_SSO_FAILURE_2 = @"12010";
NSString * const ERROR_CODE_SERVER_VALIDATE_MDN_FAILURE = @"12011";
NSString * const ERROR_CODE_PREPAID_MDN = @"13015";
NSString * const ERROR_CODE_HASH_FAILED = @"13023";
NSString * const ERROR_CODE_FIOS_POPUP = @"14000";
NSString * const ERROR_CODE_FRAUD = @"2154";
NSString * const ERROR_CODE_TIMEOUT = @"11003";
NSString * const ERROR_CODE_INTERCEPT = @"i9999";
NSString * const ERROR_CODE_SILENT_REDIRECT = @"20001";
NSString * const ERROR_CODE_REDIRECT = @"20002";

#pragma mark - String Formats

NSString * const STRING_FORMAT_STRING_WITH_PARAN_STRING = @"%@ (%@)";
NSString * const STRING_FORMAT_2STRINGS_WITH_SPACE = @"%@ %@";
NSString * const STRING_FORMAT_2STRINGS_WITH_SPACE_SLASH = @"%@ / %@";
NSString * const STRING_FORMAT_2STRINGS_EQUAL = @"%@=%@";
NSString * const STRING_FORMAT_PRICE_PER_UNIT = @"$%@/%@";
NSString * const STRING_FORMAT_PREPEND_SPACE = @" %@";
NSString * const STRING_FORMAT_SEARCH_QUERY = @"%@?Ntt=%@";


#pragma mark- Regular Expressions

// Zip Code valid character regular expression
NSString * const REGULAR_EXPRESSION_ZIP_CODE = @"[A-Za-z0-9]*";

// Password valid character regular expression
NSString * const REGULAR_EXPRESSION_PASSWORD = @"(?=.*[0-9])(?=.*[a-zA-Z])([a-zA-Z0-9`~!@#$%^&*\\(\\)\\-_=\\+\\[\\]\\{\\}\\|;:'\",.<>\\/\\?\\\\]){8,20}";

// Secret Answer valid character regular expression
NSString * const REGULAR_EXPRESSION_SECRET_ANSWER = @"[A-Za-z0-9. ]+";

// Valid MDN input digits (allowing * for delete)
NSString * const REGULAR_EXPRESSION_DIGIT_ONLY = @"[0-9]*";

// any possitive decimal value
NSString * const REGULAR_EXPRESSION_DECIMAL = @"[0-9.]*";

// Valid Email (also not restricting length of top level domain for future compat)
NSString * const REGULAR_EXPRESSION_EMAIL = @"[0-9a-zA-Z._%+-]+@[0-9a-zA-Z._-]+[.]+[0-9a-zA-Z]+";

//all characters except !, %, #
NSString * const REGULAR_EXPRESSION_NICKNAME = @"[^!@#]+";

//share name id
NSString * const REGULAR_EXPRESSION_SHARE_NAME = @"[A-Za-z0-9 ]+";

#pragma mark - JSON Keys

NSString * const JSON_ARRAY = @"JsonArray";
NSString * const JSON_DICTIONARY = @"JsonDictionary";

NSString * const ERROR_INFO = @"ErrInfo";
NSString * const ERROR_CODE = @"errCd";
NSString * const ERROR_MESSAGE = @"errMsg";
NSString * const ERROR_USER_MESSAGE = @"errUsrMsg";
NSString * const ERROR_LEVEL = @"errLvl";
NSString * const ERROR_HDG = @"errHdg";

NSString * const PAGE_INFO = @"PageInfo";
NSString * const PAGE_INFO_LOWER_CASE = @"pageInfo";
NSString * const PAGE_INFO_VO = @"pageInfoVO";
NSString * const PAGE_INFO_RESP = @"PageInfoResp";
NSString * const PAGE_TYPE = @"pageType";
NSString * const PAGE_SUB_TYPE = @"pageSubType";
NSString * const SCREEN_HEADING = @"scrnHdg";
NSString * const SCRN_MSG_INFO = @"ScrnMsgInfo";
NSString * const SCRN_MSGS_INFO = @"scrnMsgsInfo";
NSString * const SCRN_MSG_INFO_LOWER = @"scrnMsgInfo";
NSString * const SCRN_MSG = @"scrnMsg";
NSString * const SCRN_MSG_MAP = @"scrnMsgMap";
NSString * const SCRN_MSG_MAP_CAMEL_CASE = @"ScrnMsgMap";

NSString * const SCRN_MSG_OBJ_MAP = @"scrnMsgObjMap";
NSString * const SCRN_MSG_CONTENT_TEXT1 = @"scrnContentTxt1";
NSString * const SCRN_MSG_CONTENT_TEXT2 = @"scrnContentTxt2";
NSString * const SCRN_MSG_CONTENT_TEXT3 = @"scrnContentTxt3";
NSString * const SCRN_MSG_CONTENT_BOX_TEXT = @"scrnContentBoxTxt";
NSString * const SCRN_MSG_TNC_TEXT = @"tncTxt";
NSString * const SCRN_MSG_TNC_LINK_TEXT = @"tncLinkLabel";
NSString * const LINK_MAP = @"linkMap";
NSString * const NAME = @"name";
NSString * const MDN_INFO = @"MdnInfo";
NSString * const VALUE = @"value";
NSString * const KEY = @"key";
NSString * const TOOL_TIP_MSG_MAP = @"toolTipMsgMap";
NSString * const TOOLTIP_MSG = @"tooltipMsg";
NSString * const TOOLTIP_HDG = @"tooltipHdg";
NSString * const TOUCH_ID_CLEAR_MSG = @"touchIdCleared";
NSString * const TOUCH_ID_HASH = @"touchIDHash";
NSString * const TOUCH_ID_REASON = @"touchIDReason";
NSString * const LOCATION_LIST = @"locationList";
NSString * const FAILED_REASON = @"failedReason";

NSString * const LINKS_INFO = @"LinksInfo";
NSString * const LINKS_ARRAY_LIST = @"linkInfoArrayList";
NSString * const SECTION_TITLE = @"sectionTitle";
NSString * const ITEMS = @"items";
NSString * const IMAGE_NAME = @"imageName";
NSString * const TITLE = @"title";
NSString * const ACTION_TYPE = @"actionType";
NSString * const ACTION_TYPE_TRADE_IN = @"openTradeIn";
NSString * const ACTION_TYPE_CONTENT_TRANSFER = @"openContentTransfer";
NSString * const ACTION_TYPE_LINK_AWAY = @"openURL";
NSString * const ACTION_TYPE_SSO = @"openSSOURL";
NSString * const ACTION_TYPE_OPEN_PAGE = @"openPage";
NSString * const ACTION_TYPE_RESTART_FORCE_LOGIN = @"restartLogin";
NSString * const ACTION_TYPE_FRAUD = @"FRAUD";
NSString * const ACTION_TYPE_STORE_LOCATOR = @"storeLocator";
NSString * const ACTION_INFORMATION = @"actionInformation";
NSString * const LINK_AWAY_APP_URL = @"appURL";
NSString * const LINK_AWAY_URL = @"browserURL";
NSString * const LINK_REDIRECT = @"redirect";

NSString * const USER_INFO = @"userInfo";
NSString * const MDN = @"mdn";
NSString * const SORTID = @"sortId";
NSString * const URL = @"url";
NSString * const DEVICE_DETAIL_LIST = @"deviceDetailLst";
NSString * const FULL_GRIDWALL = @"fullGridWall";
NSString * const DEVICE_PRODID = @"deviceProdId";
NSString * const DEVICE_SKUID = @"deviceSkuId";

NSString * const FWDMDN = @"fwdMdn";

NSString * const BILLING_INFO = @"billingInfo";
NSString * const DAYS_LEFT_IN_CYCLE = @"daysLeftInCycle";
NSString * const BALANCE = @"balance";
NSString * const DUE_DATE = @"dueDate";


NSString * const TOOL_TIP = @"tool_tip";
NSString * const CONTINUE_BUTTON = @"continue_button";
NSString * const CANCEL_BUTTON = @"cancel_button";
NSString * const SAVE_CHANGES_BUTTON = @"save_changes_button";
NSString * const UNSAVED_WARNING = @"unsaved_warning";
NSString * const ALERTON = @"alertOn";
NSString * const ALERT_MESSAGE = @"alertMessage";
NSString * const EMAIL_ALERT_LIST_VO = @"emailAlertRecipientsVO";
NSString * const TEXT_ALERT_LIST_VO = @"textAlertRecipientsVO";
NSString * const ACCOUNT_OWNER_EMAIL = @"accountOwnerEmail";
NSString * const ACCOUNT_OWNER_MDN = @"accountOwnerMdn";
NSString * const EMAILADDRESS = @"emailAddress";
NSString * const SMSNOTIFICATION = @"smsNotification";
NSString * const OVERAGE_ALERT_VO = @"usageOveargeInfoVO";
NSString * const OVERAGE_ALERT_INFO = @"thrsholdInfoVO";
NSString * const THRESHOLD_INFO = @"thrsholdList";
NSString * const ALERTTHRESHOLDVO = @"alrtThrsholdVO";
NSString * const ALLOWANCE = @"allowance";


NSString * const PLAN = @"plan";
NSString * const HEIGHT_IN_BARS = @"heightInBars";
NSString * const MINUTES_INFO = @"minutesInfo";
NSString * const MESSAGES_INFO = @"messagesInfo";
NSString * const DATA_INFO = @"dataInfo";
NSString * const USAGE_TYPE = @"usageType";
NSString * const USAGE = @"usage";
NSString * const USAGE_SUB_TEXT = @"usageSubText";
NSString * const ELIGIBLE_FOR_UPGRADE = @"eligbleForUpgrade";
NSString * const MINUTES = @"minutes";
NSString * const MESSAGES = @"messages";
NSString * const DATA = @"data";
NSString * const HOTSPOT = @"hotspot";
NSString * const COLOR = @"color";
NSString * const TYPE = @"type";
NSString * const ROLE = @"role";

NSString * const TXT_BOX_MSG = @"textBoxMsg";
NSString * const SIGN_IN_DIFF_USER = @"signInDiffUser";
NSString * const ANSWER = @"answer";
NSString * const SCRN_CONFIRM_PWD_TXT = @"scrnConfirmPwdTxt";
NSString * const MSG_CONTENT = @"msgContent";

NSString * const DEVICE_INFO = @"DeviceInfo";
NSString * const USAGE_INFO = @"UsageInfo";
NSString * const PLAN_MDN = @"PlanMdn";
NSString * const LINK_LIST = @"LinkList";
NSString * const LINK_LIST_LOWER = @"linkList";
NSString * const LINK_LIST_VO = @"linkListVO";
NSString * const LINK = @"Link";
NSString * const LINK_LOWER = @"link";
NSString * const FORMATTED_MDN = @"FormatedMdn";
NSString * const DESC = @"desc";
NSString * const DESCRIPTION = @"description";
NSString * const RATE = @"rate";
NSString * const CURRENT_PLAN = @"currentPlan";
NSString * const IS_MY_PLAN = @"isMyPlan";

NSString * const LINE_INFO = @"LineInfo";
NSString * const LINE_INFO_LOWER = @"lineInfo";
NSString * const LINE_INFO_LIST = @"LineInfoList";
NSString * const LINE_INFO_VO_LIST = @"lineInfoVOList";
NSString * const LINE = @"Line";
NSString * const DEVICE = @"device";
NSString * const DEVICE_LIST = @"deviceList";
NSString * const SORT_LIST = @"sortOptions";
NSString * const PRC = @"prc";
NSString * const PRC_RT = @"prcRt";
NSString * const PRICE = @"price";
NSString * const PRCRATE = @"prcRate";
NSString * const BUTTON_TITLE = @"buttonTitle";

NSString * const PROFILE_INFO = @"profileInfo";

NSString * const USG_INFO = @"UsgInfo";
NSString * const USG_INFOS = @"UsgInfos";
NSString * const HDG = @"hdg";
NSString * const MSG = @"msg";
NSString * const CYC_END_DT = @"cycEndDt";
NSString * const ELIGIBLE_DATE = @"eligibleDt";
NSString * const IMAGE_PATH = @"imagePath";
NSString * const IMAGE_PATHVO = @"imagePathVO";
NSString * const IMAGE_PATH_LARGE = @"imagePathLarge";
NSString * const IMAGE_PATH_MINI = @"imagePathMini";
NSString * const IMAGE_PATH_MEDIUM = @"imagePathMedium";
NSString * const IMAGE_PATH_SMALL = @"imagePathSmall";
NSString * const LIST_TYPE = @"listType";
NSString * const USG_DTL = @"UsgDtl";
NSString * const TEXT = @"text";
NSString * const TOTALUSAGE = @"totalUsage";
NSString * const INDEX = @"index";
NSString * const USED = @"used";
NSString * const SHARED_USED = @"shrUsed";
//NSString * const MAX = @"max";
NSString * const PROGRESS_COLOR = @"progressColor";
NSString * const SHARED_PROGRESS_COLOR = @"shrProgressColor";
NSString * const PERCENTAGE = @"percentage";
NSString * const SHARED_PERCENTAGE = @"shrPercentage";
NSString * const ESTIMATE_MESSAGE = @"estMsg";
NSString * const OPTION_TYPE = @"optionType";
NSString * const LINE_MSG = @"lineMsg";
NSString * const SHR_MSG = @"shrMsg";
NSString * const OVERVIEW_INFO = @"OverviewInfo";
NSString * const LBL = @"lbl";
NSString * const EST_DT_TIME = @"estDtTime";
NSString * const DTL = @"Dtl";
NSString * const SHR_DATA = @"shrData";
NSString * const PIC_NM = @"pic_nm";
NSString * const INDIVIDUAL_DISPLAYS = @"individualDisplays";
NSString * const USG_OVERVIEW_MAP = @"UsgOverviewMap";
NSString * const LEFT_HEADER = @"leftHeader";
NSString * const RIGHT_HEADER = @"rightHeader";

NSString * const GET_ACC_INFO = @"getAccInfo";
NSString * const ACCT_INFO_VO = @"acctInfoVO";

NSString * const SPLASH_MESSAGES = @"SplashMessages";
NSString * const UHM_SECTION_NAME_KEY = @"Store_Info";
NSString * const SYSTEM_FLAGS_VO = @"systemFlagsVO";
NSString * const SSO_SECTION_NAME_KEY = @"deviceMdnHashMap";
NSString * const TOUCH_ID_SUPPORTED = @"touchIdSupport";
NSString * const SEND_SMS_FOR_TOUCH_ID = @"sendSMSForTouchId";
NSString * const DATA_CHARGES_MESSAGE = @"dataChargesMessage";
NSString * const ENABLE_ANALYTICS = @"enableAnalytics";

NSString * const LOAD_ACCT_DETAILS = @"loadAcctDetails";

NSString * const PLAN_INFO_LIST = @"PlanInfoList";
NSString * const PLAN_INFO_LIST_LOWER = @"planInfoList";
NSString * const PLAN_INFO = @"PlanInfo";
NSString * const PLAN_INFO_LOWER = @"planInfo";
NSString * const IS_MY_CURRENT_PLAN = @"isMyCurrPlan";
NSString * const LINE_ACCESS_FEE_DETAILS = @"LAFDetails";
NSString * const AMOUNT = @"amount";
NSString * const PLAN_MDNS = @"planMDNs";
NSString * const LINE_INFO_LST = @"LineInfoLst";
NSString * const PLAN_MAP = @"planMap";
NSString * const PLAN_INFO_MSG = @"planInfoMsg";
NSString * const PLAN_INFO_TYPE = @"planInfoType";
NSString * const MDN_NICK_NAME = @"MDNNickName";
NSString * const DEVICE_NAME = @"DeviceName";
NSString * const MONTH_TEXT = @"monthText";
NSString * const PLAN_MSG = @"planMsg";
NSString * const PRICE_PLAN_FULL_DESC = @"prcPlanFullDesc";
NSString * const HEADER_DISCLAIMER = @"headerDisclaimer";
NSString * const RIGHT_SEGMENT = @"rightSegment";
NSString * const LEFT_SEGMENT = @"leftSegment";
NSString * const CURRENT_PLAN_TOTAL = @"currentPlanTotal";
NSString * const OLD_PLAN_TOTAL = @"currentPlanNoPromoTotal";
NSString * const NEW_PLAN_TOTAL = @"newPlanTotal";
NSString * const FOOTER_BUTTON = @"footerButton";
NSString * const SECONDARY_BUTTON = @"secondaryButton";
NSString * const PRIMARY_BUTTON = @"primaryButton";
NSString * const FOOTER_DISCLAIMER = @"footerDisclaimer";
NSString * const HIDE_LINES = @"hideLines";
NSString * const SHOW_LINES = @"showLines";
NSString * const LINE_LEVEL_SETTINGS = @"LineLevelSettings";
NSString * const TXT = @"txt";
NSString * const AVAILABLE_PLANS = @"availablePlans";
NSString * const YOU_ARE_CURRENTLY = @"youAreCurrently";
NSString * const PLAN_DESC = @"planDesc";
NSString * const TOTAL_MONTHLY_ACCESS = @"totalMonthlyAccess";
NSString * const EFFECTIVE_DATE = @"effectiveDate";
NSString * const PromosInfo = @"promosInfo";

NSString * const PAYMENT_MAP = @"PaymentMap";
NSString * const CURRENT_BAL_AMT = @"currentBalAmt";
NSString * const CURRENT_BAL_AMT_COLOR = @"currentBalAmtColor";
NSString * const CURRENT_BAL_HDG = @"currentBalHdg";
NSString * const DATE_MAP = @"dateMap";
NSString * const DATE_MESSAGE = @"dateMessage";
NSString * const DATE = @"date";
NSString * const DATE_COLOR = @"dateColor";
NSString * const TOP_LINK = @"topLink";
NSString * const LEFT_LINK = @"leftLink";
NSString * const RIGHT_LINK = @"rightLink";
NSString * const HOME_PAGE_USG_HDG = @"homePageUsgHdg";

// For iPad
int const MMG_EXPIRY_INTERVAL = 86400; // 1 day
NSString * const MMG_ID = @"id";
NSString * const MMG_ID_KEY = @"mmgId";
NSString * const MMG_LOGIN_TOKEN = @"mmgLoginToken";
NSString * const MMG_LOGIN_TOKEN_HASH = @"token";

// For Data Meter
NSString * const DM_DATA = @"DataMeterData";
NSString * const DM_DATA_UNITS = @"DataUnits";
NSString * const DM_USAGE_DATA = @"UsageData";
NSString * const DM_MAXIMUM_ALLOWANCE = @"MaximumAllowance";
NSString * const DM_TIMESTAMP = @"Timestamp";
NSString * const DM_PLAN_TYPE = @"text";
NSString * const DM_REAL_EST_DT = @"realEstDt";

//My Profile Keys:
NSString * const IS_SECURE = @"isSecure";
NSString * const EMAIL_LABEL_TXT = @"emailLabelTxt";
NSString * const ALT_PHONE_LABEL_TXT = @"altPhoneLabelTxt";
NSString * const BIL_ADDR_LINE1_TXT = @"bilAddrLine1Txt";
NSString * const BIL_ADDR_LINE2_TXT = @"bilAddrLine2Txt";
NSString * const CITY_LABEL_TXT = @"cityLabelTxt";
NSString * const STATE_LABEL_TXT = @"stateLabelTxt";
NSString * const ZIP_LABEL_TXT = @"zipLabelTxt";
NSString * const SCRN_CONTENT_TXT = @"scrnContentTxt";
NSString * const EMAIL_ADDRESS = @"emailAddress";
NSString * const SCREEN_SUB_HEADING = @"scrnSubHdg";
NSString * const SHOW_GRAPH_FILTERS = @"showGraphFilters";
NSString * const SHOW_TABLE_FILTERS = @"showTableFilters";
NSString * const GRAPH_FILTERS = @"graphFilters";
NSString * const TABLE_FILTERS = @"tableFilters";
NSString * const SUB_HEADING = @"subHeader";
NSString * const SMALL_HEADING = @"header";
NSString * const ACCOUNT_NUMBER = @"acctNo";
NSString * const BILLING_ADDRESS = @"BillAddr";
NSString * const BILLING_ADDRESS_VO = @"billAddressVO";
NSString * const ACCOUNT_DETAIL = @"accountDetail";
NSString * const SUPPORT_PRIVACY = @"Support&Privacy";
NSString * const COMMON_MSG_INFO_VO = @"CommonMsgInfoVO";
NSString * const OPT_IN = @"optIn";
NSString * const OPTION_ID = @"optionId";
NSString * const CURR_PASSWORD = @"currPassword";
NSString * const NEW_PASSWORD = @"newPassword";
NSString * const CONFIRM_PASSWORD = @"confirmPassword";
NSString * const EMAIL_INFO = @"EmailInfo";
NSString * const MESSAGE = @"message";
NSString * const OVERAGE = @"Overage";
NSString * const OVERAGE_COST = @"overageCost";
NSString * const TIP_MESSAGE = @"tipMessage";
NSString * const TIP_HEADING = @"tipHeading";
NSString * const EMAIL = @"email";
NSString * const PROFILE_LIST_VO = @"profileListVO";
NSString * const PROFILE_LIST = @"ProfileList";
NSString * const STREET = @"addressLine1";//@"street";
NSString * const ADDR_LN2 = @"addressLine2";
NSString * const CITY = @"city";
NSString * const ST = @"st";
NSString * const STATE = @"state";
NSString * const ZIP = @"zipCd";
NSString * const ST_LIST = @"stList";
NSString * const CONTACT_INFO_LIST = @"ContactInfoList";
NSString * const CONTACT_INFO_LIST_VO = @"contactInfoListVO";
NSString * const CONTACT_INFO_VO = @"contactInfoVO";
NSString * const CONTACT_NBR = @"contactNbr";
NSString * const ADDRESS = @"address";
NSString * const ZIP_CODE = @"zipCode";
NSString * const ADDRESS1 = @"address1";
NSString * const CHANGE_CONTACT = @"chngContact";
NSString * const CONTACT_NBR1 = @"contactNbr[1]";
NSString * const CONTACT_NBR2 = @"contactNbr[2]";
NSString * const QSTN_LST_INFO_VO = @"qstnLstInfoVO";
NSString * const QSTN_DTL_INFO_VO = @"qstnDtlInfoVO";
NSString * const QSTN_DTL_INFO = @"QstnDtlInfo";
NSString * const QSTN = @"qstn";
NSString * const IS_INTERCEPT = @"isIntercept";
NSString * const QSTN_ID = @"qstnID";
NSString * const SECRET_QUESTION_CONFIRM_ANSWER = @"secretQuestionConfirmAnswer";
NSString * const SECRET_QUESTION_ANSWER = @"secretQuestionAnswer";
NSString * const SELECT_SECRET_QUESTION_ID = @"selectSecretQuestionId";
NSString * const APP_PROFILE_LIST = @"AppProfileList";
NSString * const NPP_LIST_VO = @"nppListVO";
NSString * const IS_APPS_AVAILABLE = @"isAppsAvailable";
NSString * const DEVICE_JSON = @"deviceJson";
NSString * const APP_PRIVACY_PROFILE = @"appPrivacyProfiles";
NSString * const ACTION = @"action";
NSString * const APPLICATION_NAME = @"applicationName";
NSString * const ALLOW = @"allow";
NSString * const ID = @"id";
NSString * const PERMISSION_MSG = @"permissionMeg";
NSString * const SELECTED = @"selected";
NSString * const SELECTED_MDN = @"selectedMdn";
NSString * const SECONDARY_MDN = @"secondaryMdn";
NSString * const SELECTED_LINE = @"selectedLine";
NSString * const SELECTED_SAFEGUARD =  @"selectedSafeguard";
NSString * const ADDED_SAFEGUARD =  @"addedFeatures";
NSString * const DELETED_SAFEGUARD =  @"deletedFeatures";
NSString * const SAFEGUARD_STATUS = @"scrnMsgSafeGuardStatus";
NSString * const FB_FEATURE_LIST = @"fbBlockLimitTitleList";
NSString * const BLOCK_HEADING = @"blckHdg";
NSString * const ALERT_LIMIT = @"altLmt";
NSString * const FEAT_CODE = @"featCode";
NSString * const FEAT_CODE_FAMILYBASE = @"FS";
NSString * const FB_PRIMARY_PARENT = @"FPP";
NSString * const FB_SECONDARY_PARENT = @"FSP";
NSString * const FB_CHILD = @"FCH";
NSString * const FB_CURRENT_ROLE = @"currentFeatFSRole";
NSString * const TOOLTIP = @"ToolTip";
NSString * const TIP_MSG = @"tipMsg";
NSString * const MESSAGE_VO = @"MessageVO";
NSString * const MESSAGE_VO_LOWER = @"messageVO";
NSString * const SAVE_STORE = @"Save as Home Store";
NSString * const REMOVE_STORE = @"Remove as Home Store";
NSString * const STORE_COOKIE = @"storeCookie";
NSString * const PCID_MDN = @"pcIdMdn";
NSString * const SHARE_NAME_ID = @"seunValue";
NSString * const SUCCESS_MSG_INFO_VO = @"successMsgInfoVO";
NSString * const TNC_TOOLTIP_TEXT1 = @"tncToolTipTxt1";
NSString * const TNC_TOOLTIP_TEXT2 = @"tncToolTipTxt2";
NSString * const TNC_TOOLTIP_HDG = @"tncToolTipHdg";
NSString * const BTN_TEXT = @"btnTxt";
NSString * const SelectedMDN = @"selectedMdn";
NSString * const REQUESTED_PAGE_TYPE = @"requestedPageType";
NSString * const STATIC_CACHE_VERSION = @"static_cache_version";
NSString * const STATIC_CACHE_TIMESTAMP = @"static_cache_timestamp";
NSString * const IS_CURRENT_FEATURE = @"isCurFeat";

//My Device
NSString * const MY_DEVICES = @"My Devices";
NSString * const MANAGE_DEVICE_NICKNAMES = @"Manage Device Nickname(s)";
NSString * const LINEINFOLIST = @"lineInfoList";
NSString * const MDN1_KEY = @"mdn1";
NSString * const FIRSTNAME1_KEY = @"firstName1";
NSString * const LASTNAME1_KEY = @"lastName1";
NSString * const COUNT_KEY = @"count";
NSString * const FIRSTNAME_KEY = @"firstName";
NSString * const LASTNAME_KEY = @"lastName";
NSString * const UPDATED_KEY = @"updated";
NSString * const ELIGIBLE_UPGRADE_DATE = @"eligibleUpgradeDate";
NSString * const CONTRACT_EXPIRATION_DATE = @"mtnContractExpDate";
NSString * const DATA_CONTRACT_EXPIRATION_DATE = @"mtnDataContractExpDate";
NSString * const IS_UPGRADE_ELIGIBILITY = @"isUpgradeEligibility";
NSString * const ACCT_INFO = @"AcctInfo";
NSString * const AMINDICATOR = @"amIndic";
NSString * const ACCOUNT_HOLDER = @"accountHolder";
NSString * const ACCOUNT_MANAGER = @"accountManager";
NSString * const NOT_ELIGIBLE = @"noteligible";
NSString * const SCRN_MSG_LINK_MAP = @"scrnMsgLinkMap";
NSString * const UPGRADE_MSG1 = @"youRCurrentMsg";
NSString * const UPGRADE_MSG2 = @"deviceUpgrdCount";
NSString * const UPGRADE_MSG3 = @"discutUpgrdMsg";
NSString * const NOTIFICATION_UPDATE_DEVICE_NICKNAME_SUCCESS = @"notificationUpdateDeviceNickname";
NSString * const USAGE_INFO_VO = @"usageInfoVo";
NSString * const USAGE_OVERVIEW = @"usgOverview";
NSString * const USAGE_DETAIL_LIST = @"usgDtlLst";
NSString * const HOME_PAGE_USAGE_MULTILINE_LINK = @"homePageUsgMultiLineLnk";
NSString * const DEVICE_USAGE_SHARED_PLAN_LINK = @"deviceUsgSharedPlanLnk";
NSString * const SIM_NUMBER = @"mtnSimNo";
NSString * const IMEI_NUMBER = @"mntImeiNo";
NSString * const ESN_NUMBER = @"mtnEsnNo";
NSString * const MY_ACCOUNT_BILLING = @"My Account & Billing";
NSString * const MANAGE_USAGE_ALERTS = @"Manage Usage Alerts";
NSString * const MANAGE_CALL_FORWARDING = @"Manage Call Forwarding";
NSString * const UPGRADE = @"Upgrade";
NSString * const ELIGIBLE_UPGRADE_TOOLTIP_MSG = @"eligiUpdDtToolTMsg";
NSString * const CONTRACT_EXPIRATION_TOOLTIP_MSG = @"contrExpDtToolTMsg";
NSString * const ELIGIBLE_UPGRADE_TOOLTIP_MAP = @"eligiUpdDtToolTMap";
NSString * const ELIGIBLE_UPGRADE_TOOLTIP_MSG_KEY = @"eligiUpgradeToolMsg";
NSString * const ELIGIBLE_UPGRADE_TOOLTIP_BTNTITLE_KEY = @"eligiUpgradeToolHdMsg";
NSString * const ELIGIBLE_UPGRADE_TOOLTIP_TITLE_KEY = @"eligiUpgradeTitle";
NSString * const NONELIGIBLE_UPGRADE_TOOLTIP_MAP = @"nonEligUpdDtToolTMap";
NSString * const NONELIGIBLE_UPGRADE_TOOLTIP_MSG1_KEY = @"nonEligiUpgradeTTlMsg1";
NSString * const NONELIGIBLE_UPGRADE_TOOLTIP_MSG2_KEY = @"nonEligiUpgradeTYlMsg2";
NSString * const NONELIGIBLE_UPGRADE_TOOLTIP_MSG3_KEY = @"nonEligiUpgradeTYlMsg3";
NSString * const NONELIGIBLE_UPGRADE_TOOLTIP_TITLE_KEY = @"nonEligiUpgradeTitle";
NSString * const NONELIGIBLE_UPGRADE_TOOLTIP_BTNTITLE_KEY = @"nonEligiUpgradeBtnTitle";
NSString * const CONTRACT_EXPIRATION_TOOLTIP_MAP = @"contrExpDtToolTMap";
NSString * const CONTRACT_EXPIRATION_TOOLTIP_MSG_KEY = @"currContrExpMSG";
NSString * const CONTRACT_EXPIRATION_TOOLTIP_TITLE_KEY = @"currContrExpTitle";
NSString * const UPGRADE_BUTTON_MAP = @"upgradeBtnMap";
NSString * const NOTIFICATION_UPGRADE_ELIGIBILITY = @"notificationUpgradeEligibility";
NSString * const EDIT_BUTTON_MAP = @"editButtonMap";
NSString * const DEVICE_NICK_NAME = @"deviceNickName";
NSString * const LINK_INFO = @"linkInfo";
NSString * const SCRN_SUCCESS_HDG = @"scrnSuccessHdg";

//DEVICE_IS_UO TOOL_TIP
NSString * const TOOL_T_MAP_UO = @"toolTMapUO";
NSString * const NON_ELIGI_UPGRADE_UO_TT_MSG1 = @"nonEligiUpgradeUOTT1Msg1";
NSString * const NON_ELIGI_UPGRADE_UO_TY_MSG2 = @"nonEligiUpgradeUOTY1Msg2";
NSString * const NON_ELIGI_UPGRADE_UO_TITLE = @"nonEligiUpgradeUOTitle";
NSString * const NON_ELIGI_UPGRADE_UO_BTN_TITLE = @"nonEligiUpgradeUOBtnTitle";
NSString * const ELIGI_UPGRADE_TOOL_MSG_UO = @"eligiUpgradeToolMsgUO";
NSString * const ELIGI_UPGRADE_TOOL_HD_MSG_UO_TITLE = @"eligiUpgradeToolHdMsgUOTitle";
NSString * const ELIGI_UPD_DT_TOOL_MAP_UO_BTN_TITLE = @"eligiUpdDtToolTMapUOBtnTitle";

//PaperFree Billing
NSString * const AUTO_ENROLL_DATE_MESSAGE       = @"autoEnrollDateMessage";
NSString * const PAPERFREE_STATIC_TEXT          = @"paperFreeStaticText";
NSString * const CLICK_HERE                     = @"clickHere";
NSString * const MY_VERIZON_HOMEPAGE            = @"myVerizonHomepage";
NSString * const MY_VERIZON_HOMEPAGE_CAMELCASE  = @"myVerizonHomePage";
NSString * const OPT_OUTOF_PAPER_FREE_BILLING   = @"opOutOfPaperFreeBilling";


NSString * const PAPER_BILL_OPTOUT_STATICTEXT       = @"optOutStaticText";
NSString * const PAPER_BILL_OPTOUT_STATICTEXT2      = @"optOutStaticText2";
NSString * const PAPER_BILL_FIRSTNAME_LASTNAME      = @"firstNameLastName";
NSString * const PAPER_BILL_ADDRESS                 = @"address";
NSString * const PAPER_BILL_CITYSTATEZIP            = @"cityStateZip";

//Customer Support
NSString * const FIND_HELP_NOW_STR = @"findHelpNowStr";
NSString * const FIND_HELP_GHOST_TEXT = @"findHelpGhostTxt";
NSString * const SEARCH_SUPPORT = @"Search Support";
NSString * const TOP_SUPPORT_QUESTION_STR = @"topSupptQuestStr";
NSString * const VIEW_ALL = @"View All>";
NSString * const VERIZON_COMMUNITY_TEXT = @"veriCommunityTxt";
NSString * const VERIZON_COMMUNITY_SUB_TEXT = @"veriCommunitySubTxt";
NSString * const VISIT_THE_COMMUNITY = @"Visit The Community";
NSString * const CUSTOMER_SERVICE_VO = @"custServiceVO";
NSString * const TALK_SOMEONE_MSG = @"talkSomeOneMsg";
NSString * const TALK_SOMEONE_SUB_MSG = @"talkSomeOneSubMsg";
NSString * const CUSTOMER_SERVICE_MSG = @"custServMsg";
NSString * const MOBILE_NUMBER_VO = @"mobileNoVO";
NSString * const NUMBER = @"number";
NSString * const CUSTOMER_SERVICE_DIAL_MSG = @"custServDialMsg";
NSString * const CUSTOMER_SERVICE_NUMBER_MSG = @"custServeNoMeg";
NSString * const CUSTOMER_SERVICE_FROM_MSG = @"custServFrmMsg";
NSString * const CUSTOMER_SERVICE_TIME_MSG = @"custServTimMsg";
NSString * const CUSTOMER_SERVICE_EMERGENCY_SERVICE_MSG = @"custServEServMsg";
NSString * const CUSTOMER_SERVICE_EMERGENCY_SERVICE_TIME_MSG = @"custServEServTimMsg";
NSString * const SUPPORT_BUTTON_MAP = @"supportBtnMap";
NSString * const SEARCH_SUPPORT_KEY = @"searchSupport";
NSString * const VIEW_ALL_KEY = @"viewAll";
NSString * const VISIT_THE_COMMUNITY_KEY = @"visitTheCommunity";
NSString * const SUPPORT_QUESTIONS_MAP = @"supportQuestionsMap";

//Shop
NSString * const SHOP_DEVICE_TEXT_MSG = @"shopDeviceTxtMsgs";
NSString * const UPGRADE_YOUR_DEVICES = @"Upgrade Now";
NSString * const ADD_A_DEVICE = @"Add a Device";
NSString * const PURCHASE_ACCESSORIES = @"Purchase Accessories";
NSString * const WORKSHOPS_APPOINTMENTS = @"Workshops & Appointments";
NSString * const APPOINTMENT_WORKSHOP_VO = @"appoWorkVO";
NSString * const APPOINTMENT_WORKSHOP_MSG = @"appWorkMsg";
NSString * const APPOINTMENT_WORKSHOP_SUB_MSG = @"appWorkSubMsg";
NSString * const APPOINTMENT_FIRST_MSG = @"appoFirstMsg";
NSString * const APPOINTMENT_SECOND_MSG = @"appoSecondMsg";
NSString * const APPOINTMENT_THIRD_MSG = @"appoThirdMsg";
NSString * const WORKSHOP_FIRST_MSG = @"workFirstMsg";
NSString * const WORKSHOP_SECOND_MSG = @"workSecondMsg";
NSString * const WORKSHOP_THIRD_MSG = @"workThirdMsg";
NSString * const MORE_MSG = @"moreMsg";
NSString * const MORE_SUB_MSG = @"moreSubMsg";
NSString * const SHOP_BUTTON_MAP = @"shopButtonMap";
NSString * const UPGRADE_NOW_KEY = @"upgradeNow";
NSString * const ADD_A_DEVICE_KEY = @"addADevice";
NSString * const PURCHASE_ACCESSORIES_KEY = @"purchaseAccessories";
NSString * const SHOP_WORK_APP_MAP = @"shopWorkAppMap";
NSString * const SHOP_WORK_KEY = @"workAppotnt";
NSString * const STORE_LOCATOR_MAP = @"storeLocatorMap";
NSString * const STORE_LOCATOR_KEY = @"shopLocatorMap";
NSString * const STORE_VISIT_HISTORY_MAP_KEY = @"storeVisitHistMap";
NSString * const MVM_STORE_VISIT_HISTORY = @"mvmStoreVisitHistory";

//ShopFlow
NSString * const FLOW_EUP = @"EUP";
NSString * const MTN_DETAILS_LIST = @"mtnDetailsList";
NSString * const UPGRADE_MESSAGE = @"upgradeMessage";
NSString * const UPGRADE_MESSAGE_HTML = @"upgradeMessageHtml";
NSString * const UPGRADE_ELIGIBLE = @"upgradeEligibile";
NSString * const PAYMENT_AGREEMENT_TEXT = @"paymentAgreementTxt";
NSString * const UPGRADE_AVAILABLE_PERCENTAGE = @"upgradeAvailablePercentage";
NSString * const LOAN_INFO = @"loanInfo";
NSString * const DEVICE_AGREEMENT_TEXT = @"deviceAgreementTxt";
NSString * const PAID_AMOUNT_PERCENTAGE = @"paidAmountPercentage";
NSString * const AGREEMENT_ID = @"agreementId";
NSString * const ORIG_DATE = @"origDt";
NSString * const AMOUNT_FINANCED = @"amtFinanced";
NSString * const REMAINING_PAYMENTS = @"remainingPayments";
NSString * const DEVICE_PAY_BALANCE = @"devicePayBalance";
NSString * const LEGAL_DISCLAIMER = @"legalDisclaimer";
NSString * const LOAN_NUMBER = @"loanNumber";
NSString * const START_DATE = @"startDate";
NSString * const LOAN_AMOUNT = @"loanAmount";
NSString * const PENDING_NO_OF_INSTALLMENTS = @"pendingNoOfInstallments";
NSString * const PENDING_LOAN_AMOUNT = @"pendingLoanAmount";
NSString * const PAGE_TITLE = @"pageTitle";
NSString * const SELECTED_DEVICE = @"selectedDevice";
NSString * const CHANGE_DEVICE = @"change";
NSString * const KEY_DISPLAY_NAME = @"displayName";
NSString * const KEY_MANUFACTURER_DISPLAY_NAME = @"manufacturerDisplayName";
NSString * const MTN = @"mtn";
NSString * const DEVICE_IMAGE = @"image";
NSString * const TRADE_IN_QUESTION = @"question";
NSString * const TRADE_IN_QUESTION_ID = @"questionId";
NSString * const TRADE_IN_QUESTIONNAIRE = @"tradeInQuestionnaire";
NSString * const SELECTED_TEXT = @"selectedTxt";
NSString * const DEVICE_CONDITION = @"deviceCondition";
NSString * const ACTIVE_DEVICES_TITLE = @"activeDevicesTitle";
NSString * const TRADE_IN_DEVICES = @"tradeInDevices";
NSString * const DISCONNECTED_DATE = @"disconnectedDate";
NSString * const GET_DEVICE_DETAILS = @"shop/getDeviceDetails";
NSString * const GRIDWALL_DEVICE_LIST = @"gridWallResponse";
NSString * const OUTPUT = @"output";
NSString * const RESULT_LIST = @"resultList";
NSString * const REFINEMENT_BOX_LIST = @"refinementBreadBoxes";
NSString * const NUMBER_OF_REVIEWS = @"numOfReviews";
NSString * const STARTS_AT = @"startsAt";
NSString * const DISPLAY_TEXT = @"displayText";
NSString * const CATALOG_HEADER = @"catalogHeader";
NSString * const TRADE_IN_LOWERCASE = @"tradein";
NSString * const REFINEMENT_BREAD_BOX = @"refinementBreadBox";
NSString * const REFINEMENT_BREAD_BOX_DISPLAY = @"refinementBreadBoxDisplay";
NSString * const DEVICES = @"devices";
NSString * const DEVICE_ID = @"deviceId";
NSString * const INACTIVE_DEVICES_TITLE = @"inactiveDevicesTitle";
NSString * const SELECT_THIS_DEVICE = @"Select This Device";
NSString * const ACTIVE_DEVICE = @"activeDevice";
NSString * const ACTIVE_DEVICES = @"activeDevices";
NSString * const INACTIVE_DEVICES = @"inActiveDevices";
NSString * const LAST_USED = @"lastUsed";
NSString * const CHOOSE_ANOTHER_DEVICE = @"CHOOSE ANOTHER DEVICE";
NSString * const GET_YOUR_TRADE_IN_VALUE = @"Get Your Trade-In Value";
NSString * const PROMO_TITLE = @"promoTitle";
NSString * const DEVICE_TO_TRADE_IN = @"deviceTrdIn";
NSString * const QUESTION_ANSWER = @"questionAns";
NSString * const QUESTION_YES = @"YES";
NSString * const QUESTION_NO = @"NO";
NSString * const SEE_ALL_SMARTPHONES = @"See All Smartphones";
NSString * const SORT_BY = @"Sort by - ";
NSString * const LABEL = @"label";
NSString * const SORT_BYTEXT = @"sortByText";
NSString * const SELECTION_FLAG = @"selectionFlag";
NSString * const TRADEIN_CREDIT_TEXT = @"tradeInCreditText";
NSString * const TRADEIN_CREDIT = @"tradeInCredit";
NSString * const NAVIGATION_STATE = @"navigationState";
NSString * const APPLY_FILTERS = @"Apply Filters";
NSString * const SELECTED_MTN = @"selectedMTN";
NSString * const CANCEL_KEY_UPPERCASE = @"CANCEL";
NSString * const THIS_DEVICE = @"thisDevice";
NSString * const OFFERED_DEVICES = @"offeredDevices";
NSString * const PROMOS = @"promos";
NSString * const GET_IT_NOW = @"Get it now";
NSString * const APPRAISAL_VALUE = @"aprValue";
NSString * const ACCEPT_COMPLETE_TRADE_IN = @"Accept & Complete Trade-In";
NSString * const NO_THANKS_SKIP_TRADE_IN = @"NO THANKS, SKIP TRADE-IN >";
NSString * const PLEASE_NOTE_TEXT_1 = @"plsNoteTxt1";
NSString * const PLEASE_NOTE_TEXT_2 = @"plsNoteTxt2";
NSString * const TRADE_IN_PRICE = @"tradeInPrice";
NSString * const MODEL_ID = @"modelId";
NSString * const SELECTED_TRADE_IN_MTN = @"selectedTradeInMTN";
NSString * const SELECTED_DEVICE_ID = @"selectedDeviceId";
NSString * const REFINEMENTS = @"refinements";
NSString * const REFINEMENT_NAME = @"refinementName";
NSString * const COLOR_UPPERCASE = @"Color";
NSString * const COLOR_STYLE = @"colorStyle";
NSString * const REFINEMENT_OPTIONS = @"refinementOptions";
NSString * const DIMENSION_NAME = @"dimensionName";
NSString * const DIMENSION_COLOR = @"d_Color";
NSString * const REFINEMENT_COUNT = @"refinementCount";
NSString * const KEY_DEVICE_DETAILS_RESPONSE = @"deviceDetailsResponse";
NSString * const KEY_PRODUCT_DETAILS = @"productDetails";
NSString * const KEY_SKU_DETAILS = @"skuDetails";
NSString * const KEY_CTA_DISABLED = @"ctaDisabled";
NSString * const KEY_CTA_CONTINUE_TITLE = @"ctaContinueLabel";
NSString * const KEY_SHIPPING_MESSAGE = @"shippingMessage";
NSString * const KEY_SHIPPING_DATE = @"shippingDate";
NSString * const KEY_OUT_OF_ORDER = @"outOfOrder";
NSString * const KEY_COLOR_CODE = @"colorCode";
NSString * const KEY_COLOR_NAME = @"colorName";
NSString * const KEY_CAPACITY = @"capacity";
NSString * const KEY_TECHNICAL_SPECIFICATIONS = @"technicalSpecifications";
NSString * const KEY_TECH_SPECS_DETAILS = @"techSpecsDetails";
NSString * const KEY_DEVICE_CONTRACT_PRICE = @"deviceContractPrice";
NSString * const KEY_CONTRACT_PRICE = @"contractPrice";
NSString * const KEY_CONTRACT_TERM = @"contractTerm";
NSString * const KEY_CONTRACT_DETAILS = @"contractDetails";
NSString * const KEY_CONTRACT_DESCRIPTION = @"contractDescription";
NSString * const KEY_DISCOUNT_TEXT = @"discountText";
NSString * const KEY_BADGE_EDGE_DISPLAY_NAME = @"badgeEdgeDisplayName";
NSString * const KEY_CONTRACT_NAME = @"contractName";
NSString * const KEY_DEVICE_SKU_ID = @"deviceSkuId";
NSString * const KEY_IMAGE_URL = @"imageUrl";
NSString * const UPPERCASE_IMAGE_URL = @"imageURL";
NSString * const KEY_IMAGE_URL_SET = @"imageUrlSet";
NSString * const KEY_DETAILED_TEXT = @"detailedText";
NSString * const KEY_IMAGE_OR_VIDEO_URL = @"imageOrVideoURL";
NSString * const KEY_REVIEWS = @"reviews";
NSString * const KEY_AVERAGE_RATING = @"averageRating";
NSString * const KEY_NUMBER_OF_REVIEWS = @"numberOfReviews";
NSString * const KEY_TRADE_IN_CREDIT = @"tradeInCredit";
NSString * const KEY_TRADE_IN_TEXT = @"tradeInText";
NSString * const KEY_FEATURES = @"features";
NSString * const KEY_CONTRACT_TERM_SELECTED = @"contractTermSelected";
NSString * const KEY_REVIEWS_ONLY = @"reviewsOnly";
NSString * const KEY_REVIEWS_PAGE = @"reviewPage";
NSString * const SELECTION_QUERY_LIST = @"selectionQueryList";
NSString * const CLEAR_FILTER = @"clearFilter";
NSString * const FILTER_HEADER_TEXT = @"filterHeaderText";
NSString * const KEY_REQ_DEVICE_SOR_ID = @"deviceSORId";
NSString * const KEY_DEVICE_SOR_ID = @"deviceSorId";
NSString * const KEY_DEVICE_PROTECTION_FEATURES = @"deviceProtectionFeatures";
NSString * const KEY_FEATURE_PRODUCTS = @"featureProducts";
NSString * const KEY_FEATURE_LIST = @"featuresList";
NSString * const KEY_FEATURE_SECTION_TITLE = @"featureProductSectionTitle";
NSString * const KEY_FEATURE_SECTION_SUBTITLE = @"featureProductSectionSubTitle";
NSString * const KEY_PRESELECTED = @"preSelected";
NSString * const KEY_PRICE_TERM = @"priceTerm";
NSString * const KEY_PRICE = @"priceStr";
NSString * const KEY_DESC_TEXT = @"introText";
NSString * const KEY_DECLINED_ALERT_TEXT = @"declinedAlertText";
NSString * const KEY_PAYMENT_OPTION_TITLE = @"paymentOptionTitle";
NSString * const KEY_QUANTITY = @"quantity";
NSString * const KEY_FEATURE_SOR_ID = @"sfoSORId";
NSString * const KEY_REQ_FEATURE_SOR_ID = @"featureSorId";
NSString * const KEY_FEATURE_SKU_ID = @"sfoSkuId";
NSString * const KEY_REQ_FEATURE_SKU_ID = @"featureSkuId";
NSString * const KEY_FEATURE_TYPE = @"featureType";
NSString * const KEY_EXISTING_FEATURE = @"existingFeature";
NSString * const REMOVE_ALL_FILTERS_TEXT = @"removeAllFiltersText";
NSString * const KEY_CART_DETAILS = @"cartDetails";
NSString * const KEY_COST_DETAILS = @"costDetails";
NSString * const KEY_TOTAL_DUE_TODAY = @"totalDueToday";
NSString * const KEY_TOTAL_DUE_MONTHLY = @"totalDueMonthly";
NSString * const KEY_CREDIT = @"credit";
NSString * const KEY_COST_DETAIL_BREAKUP = @"costDetailBreakup";
NSString * const KEY_COST_SUBTOTAL = @"costSubTotal";
NSString * const KEY_COST_TOTAL = @"costTotal";
NSString * const KEY_TAXES = @"taxes";
NSString * const KEY_TAXES_BREAKUP = @"taxesBreakup";
NSString * const KEY_DEVICE_DISPLAY_NAME = @"deviceDisplayName";
NSString * const KEY_SHOP_CART_EMPTY = @"cartEmpty";
NSString * const KEY_CART_ITEM_ACTION = @"cartItemAction";
NSString * const KEY_DISCLAIMERS = @"disclaimers";
NSString * const KEY_ADDITIONAL_DISCLAIMERS = @"additionalDisclaimers";
NSString * const KEY_PROMOTION_TEXT = @"promotionText";
NSString * const KEY_PREFIX_TERM = @"term";
NSString * const KEY_BADGES_FOR_CONTRACT_TERM = @"badgesForContractTerm";
NSString * const KEY_BADGE_DISPLAY = @"badgeDisplay";
NSString * const KEY_BADGE_CLICKABLE = @"badgeClickable";
NSString * const KEY_BADGE_TOOL_TIP = @"badgeToolTip";
NSString * const ORDER_DETAILS = @"orderDetails";
NSString * const SHIPPING_INFO = @"shippingInfo";
NSString * const DEVICE_CONFIG_INFO = @"deviceConfigInfo";
NSString * const TERMS_AND_CONDITIONS_INFO = @"termsAndConditionsInfo";
NSString * const SHIPPING_INFO_HT = @"SHIPPING_INFO_HT";
NSString * const PAYMENT_INFO_LBL = @"PAYMENT_INFO_LBL";
NSString * const ADDITIONAL_DEVICE_INFO_LBL = @"ADDITIONAL_DEVICE_INFO_LBL";
NSString * const ACCEPT_TC_INFO_LBL = @"ACCEPT_TC_CONTINUE_BTN";
NSString * const COMPLETE_YOUR_ORDER_LBL = @"COMPLETE_YOUR_ORDER_LBL";
NSString * const SHIPPING_ADDRESS_CAPS_LBL = @"SHIPPING_ADDRESS_CAPS_LBL";
NSString * const CONTACT_INFO_LBL = @"CONTACT_INFO_LBL";
NSString * const BILLING_DETAILS_INFO = @"billingDetailsInfo";
NSString * const BILLING_ADDRESS_KEY = @"billingAddress";
NSString * const PAYMENT_INFO_CAPS_LBL = @"PAYMENT_INFO_CAPS_LBL";
NSString * const CHOOSE_SHIPPING_OPTIONS_HT = @"CHOOSE_SHIPPING_OPTIONS_HT";
NSString * const DELIVERY_DESC_LBL = @"DELIVERY_DESC_LBL";
NSString * const TWO_BUSSINESS_DAYS_DESC = @"TWO_BUSSINESS_DAYS_DESC";
NSString * const SERVICE_ADDRESS = @"serviceAddress";
NSString * const DEVICE_E911_SERV_ADDR = @"DEVICE_E911_SERV_ADDR";
NSString * const TNC_TEXTS = @"tncTexts";
NSString * const ACCEPT_REVIEW_YOUR_ORDER = @"Accept & Review Your Order";
NSString * const READ_OUR_FULL_PRIVACY_POLICY = @"Read our full privacy policy.";
NSString * const PRIVACY_POLICY_DESC = @"PRIVACY_POLICY_DESC";
NSString * const THANKS_FOR_YOUR_PURCHASE_LBL = @"THANKS_FOR_YOUR_PURCHASE_LBL";
NSString * const DEVICECHANGE_VARIFY_ORDER_LBL = @"DEVICECHANGE_VARIFY_ORDER_LBL";
NSString * const TRACK_YOUR_ORDER = @"TRACK YOUR ORDER >";
NSString * const YOUR_NEXT_STEPS_LBL = @"YOUR_NEXT_STEPS_LBL";
NSString * const TRANSFER_PHONE_NR_LGL = @"TRANSFER_PHONE_NR_LGL";
NSString * const KEY_DEVICE_IMAGE_URL = @"deviceImageUrl";
NSString * const DUE_TODAY_LBL = @"DUE_TODAY_LBL";
NSString * const DUE_MONTHLY = @"DUE_MONTHLY";
NSString * const SHIPPING_TAX_FEE_LBL = @"SHIPPING_TAX_FEE_LBL";
NSString * const ITEMS_LBL = @"ITEMS_LBL";
NSString * const PLACE_YOUR_ORDER = @"Place Your Order";
NSString * const ACCEPT_TC_CONTINUE_WARN_LBL = @"ACCEPT_TC_CONTINUE_WARN_LBL";
NSString * const RETAIL_INSTALLMENT_SALES_AGREEMENT = @"Retail Installment Sales Agreement";
NSString * const BACK_TO_CART = @"BACK TO CART";
NSString * const REVIEW_YOUR_ORDER_HT = @"REVIEW_YOUR_ORDER_HT";
NSString * const SHIPPING_COSTS = @"shippingCosts";
NSString * const TOTAL_LBL = @"TOTAL_LBL";
NSString * const SHIPPING_ADDRESS = @"shippingAddress";
NSString * const CONTACT_INFORMATION = @"conTactInformation";
NSString * const PAYMENT_INFORMATION = @"paymentInformation";
NSString * const LINE_ITEMS = @"lineItems";
NSString * const SELECTED_MTN_LOWERCASE_TN = @"selectedMtn";
NSString * const TRADE_IN_CR_DESC = @"TRADE_IN_CR_DESC";
NSString * const EXPIRATION_MONTHS = @"expirationMonths";
NSString * const EXPIRATION_YEARS = @"expirationYears";
NSString * const NICKNAME_LOWERCASE = @"nickname";
NSString * const RETURN_PRIVACY_POLICY_DESC_LBL = @"RETURN_PRIVACY_POLICY_DESC";
NSString * const UPGRADE_PLAN_DESC = @"UPGRADE_PLAN_DESC";
NSString * const CONTENTS_TRANSFER_DESC = @"CONTENTS_TRANSFER_DESC";
NSString * const NEXT_BILL_DESC = @"NEXT_BILL_DESC";
NSString * const EMAIL_CONFIRMATION_DESC = @"EMAIL_CONFIRMATION_DESC";
NSString * const CREDIT_CARD_TYPE = @"creditCardType";
NSString * const CHECKOUT_ORDER_DETAILS = @"checkoutOrderDetails";
NSString * const CLIENT_ORDER_REFERENCE_NUMBER = @"clientOrderRefernceNumber";
NSString * const UPGRADE_YOUR_PLAN_NOW = @"UPGRADE YOUR PLAN NOW >";
NSString * const LEARN_HOW = @"LEARN HOW >";
NSString * const READ_THE_FAQ = @"READ THE FAQ >";
NSString * const CHECKOUT_PAYMENT_INFORMATION = @"checkoutPaymentInformation";
NSString * const CHECKOUT_BILLING_ADDRESS = @"checkoutBillingAddr";
NSString * const SUB_LABEL = @"subLabel";
NSString * const UPGRADE_ELIGIBILITY = @"upgradeEligibility";

//Purchase History
NSString * const PURCHASE_HIST_RES_VO = @"purchaseHistoryResVO";
NSString * const CONTACT_INFO_KEY = @"contactInfo";
NSString * const PURCHASE_DATE_LIST_KEY = @"purchaseDateList";
NSString * const CONTACT_INFO_MDN_KEY = @"mdn";
NSString * const CONTACT_INFO_MAILID_KEY = @"mailId";
NSString * const PURCHASE_DATE_TIME_KEY = @"purchaseDateTime";
NSString * const PURCHASE_DATE_KEY = @"purchaseDate";
NSString * const ORDER_NUMBER_KEY = @"orderNumber";
NSString * const ITEM_LIST_KEY = @"itemLists";
NSString * const STORE_ADDRESS_KEY = @"storeAddress";

// My Account

NSString * const LAST_PMT_MAP = @"lastPmtMap";
NSString * const PAST_DUE_AMT = @"pastDueAmt";
NSString * const PMT_MSG_OR_NAME_HDG = @"pmtMsgOrNameHdg";
NSString * const LAST_PMT_MADE_MSG = @"lastPmtMadeMsg";
NSString * const LAST_PMT_DATE = @"lastPmtDate";
NSString * const LAST_PMT_AMT_OF_MSG = @"lastPmtAmtOfMsg";
NSString * const LAST_PMT_AMT = @"lastPmtAmt";
NSString * const PAST_DUE_AMT_MSG = @"pastDueAmtMsg";
NSString * const PAST_DUE_MSG_AMT = @"pastDueMsgAmt";
NSString * const PAST_DUE_AMT_DUE_MSG = @"pastDueAmtDueMsg";

//Product Scan History
NSString * const PRODUCT_SCAN_HIST_RES_VO = @"productScanHistoryResVO";
NSString * const SCAN_PRODUCT_LIST_KEY = @"scanProductList";
NSString * const SCAN_PROD_LIST = @"scanProdList";
#pragma mark - Checkout JSON Keys

//Device Trade-In Quote
NSString * const DEVICE_TRADE_IN_QUOTES_RES_VO = @"deviceInTradeQuotesResVO";
NSString * const QUOTE_PRODUCT_LIST = @"quoteProductList";
NSString * const QUOTE_PROD_LIST = @"quoteProdList";
/* Start Of Constants added by Ishwar for Lower Funnel */

// Lower Funnel
NSString *const AGREEMENT_TEXTS_ARRAY = @"AGREEMENT_TEXTS";
NSString * const SCREEN_HEADING_TEXT = @"scrnHdgText";
NSString * const HIP_BLOCK_HEADER_TEXT = @"shipBlockHdgText";
NSString * const SHIP_ADDRESS_HEADER_TEXT = @"shipAdrText";

NSString * const CONTACT_INFO_HEADER_TEXT = @"contactInfoText";

// Shipping options info
NSString * const EDIT_CHECKOUT_ALERT_WARNING_MSG = @"ALERT_WARNING_MSG";
NSString * const EDIT_CHECKOUT_ALERT_ERROR_MSG = @"ALERT_ERROR_MSG";
NSString * const EDIT_SHIPPING_ADDRESS_FLAG = @"checkoutIsShippingAddressEditable";
NSString * const CTA_ENABLE_FLAG = @"ctaEnable";
NSString * const SHIPPING_TYPES_INFO = @"shippingTypesInfo";
NSString * const ACTIVE = @"active";
NSString * const SHORT_DESCRIPTION = @"shortDescription";
NSString * const SHIPPING_DESCRIPTION = @"shippingDescription";
NSString * const SHIPPING_COST_DISP = @"shippingCostDisp";
NSString * const SHIPPING_OPTION_ID = @"shippingOptionId";
NSString * const ADDED_SHIPPINGOPTION_ID = @"addedShippingOptionId";
NSString * const ESTIMATED_DELIVERY_DATE = @"estimatedDeliveryDate";

// Shipping --> Payment Information
NSString * const EDIT_BILLING_ADDRESS_FLAG = @"checkoutIsBillingAddressEditable";
NSString * const EDIT_PAYMENT_INFO_FLAG = @"checkoutIsPaymentInfoEditable";
NSString * const PAYMENT_BLOCK_HEADER_TEXT = @"paymentBlockHdgText";
NSString * const PAYMENT_INFO = @"paymentInfo";
NSString * const SAVED_CARD_INFO = @"savedCardInfo";

NSString * const SELECTED_PAYMENT_MODE = @"selectedPaymentMode";
NSString * const SELECTED_PAYMENT_TYPE = @"selectedpaymentType";
NSString * const SAVE_CARD_TO_ACCOUNT = @"savedCard";
NSString * const BTA_LOWERCASE = @"bta";
NSString * const BTA = @"BTA";
NSString * const BILL_TO_ACCOUNT_NUMBER = @"billToAccountNumber";

NSString * const SAVED_CARD = @"savedCard";
NSString * const SAVED_CARD_NUMBER = @"savedCardNumber";

NSString * const NEW_CARD = @"newCard";
NSString * const NEW_CARD_NUMBER = @"newCardNumber";

NSString * const BILLING_INFO_TEXT = @"billingInfoText";
NSString * const BILLING_ADDRESSS_TEXT = @"billingAdrText";

// Shipping -->  Additional Device Information
NSString * const EDIT_DEVICE_ADDRESS_FLAG = @"checkoutIsDeviceE911AddressEditable";
NSString * const ADDITIONAL_INFO_BLOCK_HEADER_TEXT = @"AddionalInfoBlockHdgText";
NSString * const DEVICE_SERVICE_ADDRESS = @"dvcSvcAdr";
NSString * const FLOW = @"flow";
NSString * const MTN_NUMBER = @"mtnNumber";
NSString * const E911_SERVICE_ADDRESS = @"e911ServiceAdr";

// Shipping -->  Terms & Conditions Section
NSString * const TERMS_CONDITIONS_HEADER_TEXT = @"tncHdgText";

// Accept & Review Your Order Screen
NSString * const ACCEPT_AND_REVIEW =  @"acceptAndReview";

/* End Of Constants added by Ishwar for Lower Funnel */

//Smart Rewards
NSString * const REWARDS_BALANCE_MSG1 = @"rewardsBalanceMsg1";
NSString * const REWARDS_BALANCE_MSG2 = @"rewardsBalanceMsg2";
NSString * const FEATURE_BENEFITS1 = @"featBenefits1";
NSString * const FEATURE_BENEFITS1_DESCRIPTION = @"featBenefits1Desc";
NSString * const FEATURE_BENEFITS2 = @"featBenefits2";
NSString * const FEATURE_BENEFITS2_DESCRIPTION = @"featBenefits2Desc";
NSString * const EARN_POINTS_HDG = @"earnPointsAutoHdg";
NSString * const EARN_POINTS_MSG = @"earnPointsAutoMsg";
NSString * const REDEEM_POINTS_HDG = @"redeemPointsRewardHdg";
NSString * const REDEEM_POINTS_MSG = @"redeemPointsRewardMsg";

//Manage Privacy
NSString * const PRIVACY_SCRN_MSG_HDG = @"prvcScrnMsgHdg";
NSString * const PRIVACY_WHAT_MEANS_MSG = @"prvcWhatMeansMsg";
NSString * const PRIVACY_CAN_SHARE_MSG = @"prvcCanShareMsg";
NSString * const CUSTOMER_PROP_NTWK_INFO = @"getCustPropNtwkInfo";
NSString * const CUSTOMER_BUSINESS_MRKT_INFO = @"getBusinessMrktInfo";
NSString * const RMA_PRIVACY_INFO = @"getRMAPrvcInfo";
NSString * const PRIVACY_MDN_INFO = @"prvcMdnInfo";
NSString * const PRIVACY_CPNI_INDICATOR = @"prvcCpniIndic";
NSString * const PRIVACY_BUSINESS_INDICATOR = @"prvcBuinessIndic";
NSString * const PRIVACY_RMA_INDICATOR = @"prvcRMAIndic";
NSString * const PRIVACY_SETTING = @"privacySetting";
NSString * const PRIVACY_SUCCESS_MSG1 = @"prvcSuccessMsg1";
NSString * const PRIVACY_SUCCESS_MSG2 = @"prvcSuccessMsg2";
NSString * const PRIVACY_TRANS_ERROR1 = @"prvcTransError1";
NSString * const PRIVACY_TRANS_ERROR2 = @"prvcTransError2";

//Verizon Select Preferences
NSString * const VSP_PARTICIPATION_STATUS = @"participationStatus";
NSString * const VSP_PARTICIPATION_AGREEMENT = @"participationAgreement";
NSString * const VSP_BLOCKING_LINES_FROM_PARTICIPATION = @"blockingLinesFromParticipation";
NSString * const VSP_DELETE_PAST_MOBILE_USAGE_DATA = @"deletePastMobileUsageData";
NSString * const VSP_MCM_SETTINGS_VO = @"mcmSettingsVO";
NSString * const VSP_MCM_SETTING_LIST = @"mcmSettingList";
NSString * const VSP_MCM_SELECT_MSG = @"mcmSelectMsg";
NSString * const VSP_MCM_DESCRIPTION_MSG = @"mcmDescMsg";
NSString * const VSP_DELETE_WEB_BROWSER_BTN_MSG = @"delWebBrowBtnMsg";
NSString * const VSP_PARTICIPATION_AGREEMENT_MSG1 = @"prtAgrMsg1";
NSString * const VSP_PARTICIPATION_AGREEMENT_MSG2 = @"prtAgrMsg2";
NSString * const VSP_POPUP_HDG = @"popupHdg";
NSString * const VSP_POPUP_SCRN_CONTENT = @"popupScnContent";
NSString * const VSP_BLOCK_MSG = @"blckMsg";
NSString * const VSP_DELETE_WEB_BROWSER_MSG = @"delWebBrowMsg";


//Data gift
NSString * const DATAGIFT_RETRIEVE_KEY = @"DataGiftRetrieve";
NSString * const DATAGIFT_REDEEM_KEY = @"DataGiftRedeem";
NSString * const DATAGIFT_SENDERTAG_KEY = @"senderTxt";
NSString * const DATAGIFT_AMOUNTTAG_KEY = @"amountTxt";
NSString * const DATAGIFT_RECEIVEDTAG_KEY = @"receivedTxt";
NSString * const DATAGIFT_STATUSTAG_KEY = @"statusTxt";
NSString * const DATAGIFT_STATUS_REDEEM_KEY = @"statusRedeemTxt";
NSString * const DATAGIFT_STATUS_REDEEMED_KEY = @"statusRedeemedTxt";
NSString * const DATAGIFT_ALL_TXT_KEY = @"allTxt";
NSString * const DATAGIFT_REDEEMED_TXT_KEY = @"redeemTxt";
NSString * const DATAGIFT_UNREDEEMED_TXT_KEY = @"unRedeemTxt";
NSString * const DATAGIFT_TOTALDATA_TXT_KEY = @"totalDataTxt";
NSString * const DATAGIFT_CONFIRM_TXT_KEY = @"confirmTxt";
NSString * const DATAGIFT_TOTAL_GIFTDATA = @"totalGiftData";
NSString * const DATAGIFT_SCRN_MSG_MAP = @"scrnMsgMap";
NSString * const DATAGIFTS = @"dataGifts";
NSString * const DATAGIFT_STATUS_KEY = @"status";
NSString * const DATAGIFT_SENDER_KEY = @"sender";
NSString * const DATAGIFT_UNIT_KEY = @"unit";
NSString * const DATAGIFT_RECEIVEDDATE_KEY = @"receivedDate";
NSString * const DATAGIFT_BALANCE_KEY = @"balance";
NSString * const DATAGIFT_REDEEMED_KEY = @"Redeemed";
NSString * const DATAGIFT_UNREDEEMED_KEY = @"Unredeemed";
NSString * const DATAGIFT_TERMS = @"dataGiftTerms";
NSString * const DATAGIFT_FULFILLMENTID_KEY = @"fulfillmentId";
NSString * const DATAGIFT_AMOUNT_KEY = @"amount";
NSString * const DATAGIFT_RECEIPIENTMDN_KEY = @"recipientMdn";
NSString * const DATAGIFT_SUCCESS_REDEEMED_TXT_KEY = @"successRedeemedTxt";



// The flag for if we finished tutorials
NSString * const TUTORIAL_FINISHED = @"tutorialFinished";

#pragma mark - JSON Values

NSString * const HOME_PAGE_USG_DAYS_MSG = @"homePageUsgDaysMsg";
NSString * const HOME_PAGE_USG_REMINING_DAYS = @"homePageUsgReminingDays";
NSString * const HOME_PAGE_USG_DAY_LFT_MSG = @"homePageUsgDayLftMsg";
NSString * const HOME_PAGE_USG_DAY_ENDS_ON_MSG = @"homePageUsgDayEndsOnMsg";
NSString * const HOME_PAGE_USG_BILL_CYCLE_END_DATE = @"homePageUsgBillCycleEndDate";

NSString * const OPTION_TYPE_MINUTES = @"Minutes";
NSString * const OPTION_TYPE_MESSEGAS = @"Messages";
NSString * const OPTION_TYPE_DATA = @"Data";
NSString * const OPTION_TYPE_HOTSPOT = @"Hotspot";

NSString * const STR_BLOCK = @"block";
NSString * const STR_TRUE = @"true";
NSString * const STR_FALSE = @"false";
NSString * const STR_T = @"T";
NSString * const STR_F = @"F";
NSString * const STR_Y = @"Y";
NSString * const STR_N = @"N";
NSString * const STR_1 = @"1";
NSString * const STR_0 = @"0";
NSString * const STR_ = @"";
NSString * const STR_ON = @"on";
NSString * const STR_OFF = @"off";

NSString * const STR_UNLMTD = @"UNLMTD";

NSString * const STR_S = @"S";
NSString * const STR_B = @"B";

NSString * const REGISTER = @"REGISTER";

NSString * const EDIT = @"EDIT";

#pragma mark - Payment Constants

NSString * const ACCOUNT_TYPE_APO = @"APO";
NSString * const ACCOUNT_TYPE_ACH = @"ACH";
NSString * const ACCOUNT_TYPE_PTP = @"PTP";
NSString * const ACCOUNT_TYPE_NEW_CC = @"newcc";
NSString * const ACCOUNT_TYPE_GIFT_CARD = @"giftcard";
NSString * const ACCOUNT_TYPE_CC = @"CC";
NSString * const ACCOUNT_CATEGORY_CHILD = @"children";
NSString * const ACCOUNT_CATEGORY_SAVED = @"saved";
NSString * const ACCOUNT_CATEGORY_SAVED_AUTO = @"savedauto";

NSString * const ACCOUNT_NAME = @"accountName";
NSString * const LAST_FOUR_DIGITS = @"lastFourDigits";

NSString * const CATEGORY_KEY = @"category";
NSString * const DRACTION_ACH = @"achPayConfirmed";
NSString * const DRACTION_CARD = @"cardPayConfirmed";
NSString * const DRACTION_KEY = @"draction";

NSString * const PMT_INFO = @"pmtInfo";
NSString * const SCRN_TXT_MAP = @"scrnTxtMap";
NSString * const PMT_MAP = @"paymentMap";

NSString * const AmountToPayKey = @"amountToPay";
NSString * const AccountLast4Key = @"acctLast4";
NSString * const CardNumberKey = @"cardNumber";
NSString * const UndefinedValue = @"undefined";
NSString * const SaveCheckIndicatorKey = @"saveCheckInd";
NSString * const ValidationMap = @"validationMap";
NSString * const CCIDKey = @"CCID";

#pragma mark - pageTypes

NSString * const PAGE_TYPE_LAUNCHAPP = @"launchRCApp";
NSString * const PAGE_TYPE_ACCOUNTSUMMARY = @"rcaccountsummary";
NSString * const PAGE_TYPE_DEVICE_LANDING = @"deviceDetailsList";
NSString * const PAGE_TYPE_DEVICE_DISMISSED_NOTIFICATIONS = @"dismissedNotifications";
NSString * const PAGE_TYPE_PROFILE_LANDING = @"profileDetailSuccess";
NSString * const PAGE_TYPE_SUPPORT_LANDING = @"custSupport";
NSString * const PAGE_TYPE_SHOP_LANDING = @"shopVerizon";
NSString * const PAGE_TYPE_MAIN_TABLE = @"MainTable";
NSString * const PAGE_TYPE_DATA_METER = @"getDataMeterUsageInfo";
NSString * const PAGE_TYPE_ACCOUNTOVERVIEW = @"accountoverview";
NSString * const PAGE_TYPE_USAGESELECTION = @"UsageSelection";
NSString * const PAGE_TYPE_USAGEOVERVIEW = @"UsageOverview";
NSString * const PAGE_TYPE_USAGEOVERVIEW_LOWER = @"usageOverview";
NSString * const PAGE_TYPE_USAGEDETAILS = @"UsageDetails";
NSString * const PAGE_TYPE_BILL_INFO = @"getBillInfoResp";
NSString * const PAGE_TYPE_PLAN_INFO = @"getAccountPlanInfo";
NSString * const PAGE_TYPE_PROFILE_INFO_SUCCESS = @"profileInfoSuccess";
NSString * const PAGE_TYPE_ALL_USAGE_DETAILS = @"allUsageDetails";
NSString * const PAGE_TYPE_MINUTE_DETAILS = @"Minute Details";
NSString * const PAGE_TYPE_MESSAGE_DETAILS = @"Message Details";
NSString * const PAGE_TYPE_DATA_DETAILS = @"Data Details";
NSString * const PAGE_TYPE_HOTSPOT_DETAILS = @"HotSpot Details";
NSString * const PAGE_TYPE_USAGE_DETAILS_SUMMARY = @"usageDetailsSummary";
NSString * const PAGE_TYPE_VALIDATE_USER_NAME = @"validateUserName";
NSString * const PAGE_TYPE_VALIDATE_MDN_INFO = @"validateMdnInfo";
NSString * const PAGE_TYPE_WIFI_ENTER_MDN = @"wifi-enterMdn";
NSString * const PAGE_TYPE_WIFI_SIGN_IN = @"wifiSignIn";
NSString * const PAGE_TYPE_OAAM_CHALLENGE_QUESTION = @"OAAMchallengeQuestion";
NSString * const PAGE_TYPE_WIFI_CHALLENGE_QUESTION = @"wifi-challengeQuestion";
NSString * const PAGE_TYPE_OAAM_ENTER_PASSWORD = @"OAAMenterPW";
NSString * const PAGE_TYPE_WIFI_ENTER_PASSWORD = @"wifi-enterPW";
NSString * const PAGE_TYPE_BILLING_PASSWORD = @"BPW";
NSString * const PAGE_TYPE_BILLING_ZIP = @"ZIP";
NSString * const PAGE_TYPE_SSN = @"SSN";
NSString * const PAGE_TYPE_LAUNCH_ROLE_INTERCEPT = @"launchRoleIntcpt";
NSString * const PAGE_TYPE_LOGIN = @"Login";
NSString * const PAGE_TYPE_EXTRA_OPT = @"extraOpt";
NSString * const PAGE_TYPE_PROFILE_PILLAR_OPTS = @"profilePillarOpts";
NSString * const PAGE_TYPE_MY_PROFILE_DETAILS = @"My Profile";
NSString * const PAGE_TYPE_PROFILE_PILLER_DETAILS = @"profilePillerDetails";
NSString * const PAGE_TYPE_GET_CUST_PROP_NTW_INFO = @"getCustPropNtwkInfo";
NSString * const PAGE_TYPE_GET_BUSINESS_MRKT_INFO = @"getBusinessMrktInfo";
NSString * const PAGE_TYPE_GET_RMA_PRVC_INFO = @"getRMAPrvcInfo";
NSString * const PAGE_TYPE_PRIVACY_NETWORK_SETTING_SAVE_CHANGE = @"privacyNetworkSettingSaveChange";
NSString * const PAGE_TYPE_PRIVACY_SETTING_SAVE_CHANGE = @"privacySettingSaveChange";
NSString * const PAGE_TYPE_PRIVACY_RMA_SETTING_SAVE_CHANGE = @"privacyRMASettingSaveChange";
NSString * const PAGE_TYPE_VERIZON_SELECTS_PREFERENCES = @"verizonSelectsPreferences";
NSString * const PAGE_TYPE_MULTI_CHANNEL_MARKETING = @"MultiChannelMarketing";
NSString * const PAGE_TYPE_PARTICIPATION_AGREEMENT = @"participationAgreement";
NSString * const PAGE_TYPE_PARTICIPATION_AGREEMENT_YES = @"participationAgreementYes";
NSString * const PAGE_TYPE_PARTICIPATION_STATUS = @"participationStatus";
NSString * const PAGE_TYPE_OPT_IN_SETTINGS = @"optInSettings";
NSString * const PAGE_TYPE_VERIZON_SELECTS_CONFIRM = @"verizonSelectsConfirm";
NSString * const PAGE_TYPE_BLOCKING_LINES_FROM_PARTICIPATION = @"blockingLinesFromParticipation";
NSString * const PAGE_TYPE_BLOCK_SETTINGS = @"blockSettings";
NSString * const PAGE_TYPE_BLOCK_SETTING_SAVE_CHANGE = @"blockSettingSaveChange";
NSString * const PAGE_TYPE_SELECTS_PREFERENCES = @"selectsPreferences";
NSString * const PAGE_TYPE_DELETE_PAST_MOBILE_USAGE_DATA = @"deletePastMobileUsageData";
NSString * const PAGE_TYPE_DELETE_DATA = @"deleteData";
NSString * const PAGE_TYPE_DELETE_DATA_SAVE_CHANGE = @"DeleteDataSaveChange";
NSString * const PAGE_TYPE_MARKETING_CONTACTS = @"marketingContacts";
NSString * const PAGE_TYPE_MARKETING_CONTACTS_SAVE_CHANGE = @"marketingContactsSaveChange";
NSString * const PAGE_TYPE_MODIFY_PASSWORD = @"modify_Password";
NSString * const PAGE_TYPE_MODIFY_PASSWORD_CONFIRMATION = @"passwordConfirmation";
NSString * const PAGE_TYPE_EDIT_EMAIL_ADDRESS = @"EditEmailAddress";
NSString * const PAGE_TYPE_PROFILE_EDIT_EMAIL = @"profileEditEmail";
NSString * const PAGE_TYPE_PROFILE_EDIT_EMAIL_SUCCESS = @"profileEditEmailSuccess";
NSString * const PAGE_TYPE_SAVE_EMAIL_ADDRESS = @"SaveEmailAddress";
NSString * const PAGE_TYPE_CHANGE_USER_ID = @"ChangeUserID";
NSString * const PAGE_TYPE_PROFILE_EDIT_USER_ID = @"profilEditUserID";
NSString * const PAGE_TYPE_SAVE_USER_ID = @"SaveUserID";
NSString * const PAGE_TYPE_PROFILE_EDIT_USER_ID_SUCCESS = @"profileEditUserIDSuccess";
NSString * const PAGE_TYPE_PROFILE_EDIT_USER_ID_ERROR = @"profileEditUserIDError";
NSString * const PAGE_TYPE_CHANGE_SECRET_Q = @"ChangeSecretQ";
NSString * const PAGE_TYPE_SECRET_QUESTION = @"secretQuestion";
NSString * const PAGE_TYPE_PROFILE_CHANGE_SECRET_Q = @"profileChangeSecretQ";
NSString * const PAGE_TYPE_PROFILE_CHANGE_SECRET_QUESTION_SUBMIT = @"profileChangeSecretQuestionSubmit";
NSString * const PAGE_TYPE_PROFILE_CHANGE_SECRET_Q_SUCCESS = @"profileChangeSecretQSuccess";
NSString * const PAGE_TYPE_AM_INTERCEPT_SET_SECRET_QUESTION = @"amInterceptSetSectQuestion";
NSString * const PAGE_TYPE_CHANGE_ADDR = @"change addr";
NSString * const PAGE_TYPE_CHANGEADDR = @"changeAddr";
NSString * const PAGE_TYPE_CHANGE_FEATURE = @"changeFeatures";
NSString * const PAGE_TYPE_CHANGE_FEATURE_OPTION = @"changeFeatureOption";
NSString * const PAGE_TYPE_PROFILE_ADDR_DISPLAY = @"prfl_addr_display";
NSString * const PAGE_TYPE_SUBMIT_ADDRESS_CHANGE = @"submit_address_change";
NSString * const PAGE_TYPE_PROFILE_ADDR_UPDATE = @"prfl_addr_update";
NSString * const PAGE_TYPE_MANAGE_PWD = @"manage pwd";
NSString * const PAGE_TYPE_MANAGEPWD = @"managePwd";
NSString * const PAGE_TYPE_EDIT_PASSWORD = @"editPassword";
NSString * const PAGE_TYPE_NETWORK_PROGRAMS_PERMISSIONS = @"networkProgramsPermissions";
NSString * const PAGE_TYPE_UPDATE_NETWORK_PROGRAMS_PERMISSIONS = @"updateNetworkProgramsPermissions";
NSString * const PAGE_TYPE_RETRIEVE_APP_PRIVACY_PROFILE = @"retrieveAppPrivacyProfile";
NSString * const PAGE_TYPE_PRIVACY_MANAGER = @"privacyManager";
NSString * const PAGE_TYPE_MNG_PRIVACY_SETTING = @"mngPrivacySetting";
NSString * const PAGE_TYPE_MNG_PRIVACY_SETTING_INFO_PAGE = @"mngPrivacySettingInfoPage";
NSString * const PAGE_TYPE_STORE_LOCATOR = @"storeLocator";
NSString * const PAGE_TYPE_FIND_STORE = @"findStore";
NSString * const PAGE_TYPE_ZIP_STR_SRCH = @"zipStrSrch";
NSString * const PAGE_TYPE_STORE_DETAILS = @"storeDetails";
NSString * const PAGE_TYPE_MAP_URL = @"mapUrl";
NSString * const PAGE_TYPE_NEAREST_STORE = @"nearestStore";
NSString * const PAGE_TYPE_WS_AP_PAGE = @"wsApPage";
NSString * const PAGE_TYPE_ST_VISIT_HISTORY_AP_PAGE = @"StVisitHist";
NSString * const PAGE_TYPE_PURCHASE_HISTORY_PAGE = @"purchaseHist";
NSString * const PAGE_TYPE_PRODUCT_SCAN_HISTORY_PAGE = @"prodScanHist";
NSString * const PAGE_TYPE_DEVICE_TRADE_IN_QUOTE_PAGE = @"devTradQuotes";
NSString * const PAGE_TYPE_SEARCH_OPTION = @"searchOption";
NSString * const PAGE_TYPE_WS_APP_SEARCH = @"wsApSearch";
NSString * const PAGE_TYPE_WS_AP_FULL = @"wsApFull";
NSString * const PAGE_TYPE_WS_AP_SEARCH_LOC = @"wsApSearchLoc";
NSString * const PAGE_TYPE_WS_APP_REGISTRATION = @"wsAppRegistration";
NSString * const PAGE_TYPE_FRIEND_LEVEL_ACTIVATION_SUCCESS = @"friendLevelActivationSuccess";
NSString * const PAGE_TYPE_ELIGIBLE_LINES = @"eligibleLines";
NSString * const PAGE_TYPE_FRIENDS_FAMILY_HISTORY = @"friendsFamilyHistory";
NSString * const PAGE_TYPE_TOPIC = @"topic";
NSString * const PAGE_TYPE_SUB_TOPIC = @"subtopic";
NSString * const PAGE_TYPE_QUESTION = @"question";
NSString * const PAGE_TYPE_ANSWERS = @"answers";
NSString * const PAGE_TYPE_USAGE_ALERTS_REQUEST = @"usageAlerts";
NSString * const PAGE_TYPE_USAGE_ALERTS_RESPONSE = @"UsageAlerts";
NSString * const PAGE_TYPE_RECOMMENDED = @"myOffers";
NSString * const PAGE_TYPE_POPUP = @"Popup";
NSString * const PAGE_TYPE_SAVE_THRESHOLD = @"saveThreshold";
NSString * const PAGE_TYPE_USAGE_SEND_ALERT = @"sendAlert";
NSString * const PAGE_TYPE_ACCOUNT_DETAIL = @"accountdetail";
NSString * const PAGE_TYPE_PROFILE_DETAIL = @"profileDetail";
NSString * const PAGE_TYPE_BILLING_ZIPCODE = @"billingZipcode";
NSString * const PAGE_TYPE_WIFI_SEND_TEMP_PW = @"wifi-sendTempPW";
NSString * const PAGE_TYPE_OAAM_SEND_TEMP_PW = @"OAAMSendTempPW";
NSString * const PAGE_TYPE_TEMPORARY_PASSWORD_SENT = @"resetPassword";
NSString * const PAGE_TYPE_TEMPORARY_PASSWORD_SELECT_RESET_OPTION = @"wifi-selectResetOption";
NSString * const PAGE_TYPE_TEMPORARY_PASSWORD_SELECT_RESET_OPTION_2 = @"resetPwdComm";
NSString * const PAGE_TYPE_INTERCEPT_CHANGE_SECRET_QUESTION = @"interceptChangeSecretQ";
NSString * const PAGE_TYPE_WIFI_FORGOT_PASSWORD = @"wifiForgotPassword";
NSString * const PAGE_TYPE_FORGOT_PASSWORD = @"forgotPassword";
NSString * const PAGE_TYPE_FORGOT_PASSWORD_SECRET_QUESTION = @"forgotPswdSecretQuetion";
NSString * const PAGE_TYPE_FORGOT_PASSWORD_RESET_PASSWORD = @"forgotPasswordResetPassword";
NSString * const PAGE_TYPE_NEW_PASSWORD = @"newPassword";
NSString * const PAGE_TYPE_SETUP_SET_PASSWORD = @"setupSetPwd";
NSString * const PAGE_TYPE_SIGN_OUT = @"signOut";
NSString * const PAGE_TYPE_ENTER_USER_NAME = @"enterUserName";
NSString * const PAGE_TYPE_DEVICE_PILLAR = @"deviceOpt";
NSString * const PAGE_TYPE_VM_PWD = @"vmailPwd";
NSString * const PAGE_TYPE_VM_PWD_NEW = @"vmailChangePassSbmt";
NSString * const PAGE_TYPE_VM_PWD_GENERATE = @"chooseMeVMPwd";//@"Pick a Password for Me";
NSString * const PAGE_TYPE_CALL_FORWARD = @"CallForwarding";
NSString * const PAGE_TYPE_CALL_FORWARD_SPACE = @"Call Forwarding";
NSString * const PAGE_TYPE_CALL_FORWARD_SAVE = @"callfwdSave";
NSString * const PAGE_TYPE_SUSPEND_RECONNECT = @"suspendReconnect";
NSString * const PAGE_TYPE_SUSPEND_OPTIONS = @"suspendOptions";
NSString * const PAGE_TYPE_SUSPEND_BILL_OPTIONS = @"sr_billoption";
NSString * const PAGE_TYPE_MANAGE_ACCOUNTS_ACH = @"newACHPayment";
NSString * const PAGE_TYPE_MANAGE_ACCOUNTS_CARD = @"newCardPayment";
NSString * const PAGE_TYPE_MANAGE_ACCOUNTS_ACH_NEW = @"saveNewCheckAcct";
NSString * const PAGE_TYPE_DELETE_ACH = @"deleteACH";
NSString * const PAGE_TYPE_SUBMIT_PTP = @"submitPtp";

NSString * const PAGE_TYPE_SUSPEND_MILITARY = @"suspendOptionsMiltary";
//NSString * const PAGE_TYPE_SUSPEND_MILITARY = @"suspendMilitaryCustomerInfo";
//NSString * const PAGE_TYPE_SUSPEND_MILITARY = @"selectSuspendOption";


NSString * const PAGE_TYPE_RECONNECT_DEVICE = @"srReconnectConfirm";
NSString * const PAGE_TYPE_CHANGE_PLAN_REQUEST = @"chgplan";
NSString * const PAGE_TYPE_CHANGE_PLAN_MORE_EVERYTHING = @"planChgPlaid";
NSString * const PAGE_TYPE_SIMPLE_CHANGE_PLAN = @"planChgSimple";
NSString * const PAGE_TYPE_CHANGE_PLAN_LEGACY_ACCOUNT_LEVEL = @"planChgMainSingle";
NSString * const PAGE_TYPE_CHANGE_PLAN_LEGACY_LINE_LEVEL = @"changePlanLineLevel";
NSString * const PAGE_TYPE_CHANGE_PLAN_LEGACY_REVIEW = @"ChangePlanReview";
NSString * const PAGE_TYPE_PLAN_SELECTION = @"planChgMainMulti";
NSString * const PAGE_TYPE_LEARN_ABOUT_MORE_EVERYTHING = @"ChangePlanPositioning";
NSString * const PAGE_TYPE_LAC_OPTIONS = @"lacOptions";
NSString * const PAGE_TYPE_CHANGE_PLAN_REVIEW = @"changeplan_review";
NSString * const PAGE_TYPE_MORE_EVERYTHING_REVIEW = @"ChangePlanReviewPlaid";
NSString * const PAGE_TYPE_MORE_EVERYTHING_REVIEW_PROMO = @"ChangePlanReviewPlaidPromos";
NSString * const PAGE_TYPE_CHANGE_PLAN_CONFIRM = @"changeplan_confirm";
NSString * const PAGE_TYPE_PLAN_CHANGE_SUCCESS = @"planChangeSuccess";
NSString * const PAGE_TYPE_ONE_CLICK_UPGRADE = @"UpgradePlan";
NSString * const PAGE_TYPE_CHANGE_PLAN_INTL_GLOBAL_REQUEST = @"intlGlobPageInfo";
NSString * const PAGE_TYPE_CHANGE_PLAN_INTL_GLOBAL = @"intlGlobPlanChg";
NSString * const PAGE_TYPE_CHANGE_PLAN_INTL_GLOBAL_EFFECTIVE_DATE_REQUEST = @"intlGlobChangeEffDate";
NSString * const PAGE_TYPE_CHANGE_PLAN_INTL_GLOBAL_EFFECTIVE_DATE = @"intlGlobPageEffDate";
NSString * const PAGE_TYPE_CHANGE_PLAN_EFFECTIVE_DATE = @"planChgSelEffDt";
NSString * const PAGE_TYPE_CHANGE_PLAN_INTL_GLOBAL_REVIEW_REQUEST = @"intlGlobChangeReview";
NSString * const PAGE_TYPE_CHANGE_PLAN_INTL_GLOBAL_REVIEW = @"intlGlobPageReview";
NSString * const PAGE_TYPE_CHANGE_PLAN_INTL_GLOBAL_CONFIRM_REQUEST = @"intlGlobChangeConfirm";
NSString * const PAGE_TYPE_CHANGE_PLAN_INTL_GLOBAL_CONFIRM = @"intlGlobPageConfirm";
NSString * const PAGE_TYPE_ACCOUNT_LOCKED = @"authenticationLock";
NSString * const PAGE_TYPE_LOGIN_LOCK = @"loginLock";
NSString * const PAGE_TYPE_FRAUD = @"fraud";
NSString * const PAGE_TYPE_REGISTER_NOW_REQUEST = @"register_now_wifi";
NSString * const PAGE_TYPE_REGISTER_NOW_RESPONSE = @"registerNowWifi";
NSString * const PAGE_TYPE_REGISTER_ENTER_MDN = @"regNowWifi_enterMdn";
NSString * const PAGE_TYPE_REGISTER_NOT_REGISTERED = @"notRegister";
NSString * const PAGE_TYPE_REGISTER_SETUP_REQUEST = @"setupInit";
NSString * const PAGE_TYPE_REGISTER_SETUP_RESPONSE = @"profileStp";
NSString * const PAGE_TYPE_REGISTER_ACCEPT_TERMS = @"acceptTermsAndCondition";
NSString * const PAGE_TYPE_REGISTER_TEMP_PASSWORD_SUCCESS = @"tempPasswordSuccess";
NSString * const PAGE_TYPE_PROMOTIONS = @"promotions";
NSString * const PAGE_TYPE_SW_SET_PASSWORD = @"swSetPassword";
NSString * const PAGE_TYPE_EMPLOYEE_VALIDATION = @"empValidation";
NSString * const PAGE_TYPE_DEVICE_NICKNAME = @"deviceNickname";
NSString * const PAGE_TYPE_CALL_MSG_BLOCK = @"callMessageBlock";
NSString * const PAGE_TYPE_CALL_MSG_BLOCK_SUCCESSFULL = @"CallMessageBlockSuccess";
NSString * const PAGE_TYPE_UPDATE_DEVICE_NICKNAME = @"updteNickNameDevice";
NSString * const PAGE_TYPE_UPGRADE_DEVICE_ELIGIBILITY = @"upgrade";
NSString * const PAGE_TYPE_SAFEGUARG_SELECT_CALL_MSG_BLCK = @"safeguardsSelectCallMsgBlock";
NSString * const PAGE_TYPE_SAFEGUARG_SUBMIT_CALL_MSG_BLCK = @"safeguardsSubmitCallMsgBlock";
NSString * const PAGE_TYPE_MANAGE_SAFEGUARD_SINGLES = @"safeguardsSingle";
NSString * const PAGE_TYPE_SAFEGUARDS_SELECT = @"safeguardsSelect";
NSString * const PAGE_TYPE_SAFEGUARDS_REVIEW = @"safeguardsReview";
NSString * const PAGE_TYPE_SAFEGUARDS_CONFIRM = @"safeguardsConfirm";
NSString * const PAGE_TYPE_SAFEGUARDS_MOREINFO = @"safeguardsMoreInfo";
NSString * const PAGE_TYPE_SAFEGUARDS_MANAGE_ROLE = @"safeguardsManageRole";
NSString * const PAGE_TYPE_UPDATE_FAMILYBASE_ROLES = @"updateFBRoles";
NSString * const PAGE_TYPE_USAGE_LIMIT = @"ucUsgLmtsView";
NSString * const PAGE_TYPE_USAGE_LIMIT_REVIEW = @"ucUsageLimitsReview";
NSString * const PAGE_TYPE_USAGE_LIMIT_CONFIRM = @"ucUsgLmtsConfirm";
NSString * const PAGE_TYPE_BLOCK_CONTACTS = @"ucBlckContactsView";
NSString * const PAGE_TYPE_BLOCK_CONTACTS_CONFIRM = @"ucBlckContactsCnfm";
NSString * const PAGE_TYPE_BLOCK_CONTACTS_REVIEW = @"ucBlckContactsReview";
NSString * const PAGE_TYPE_TIME_RESTRICTION = @"ucTimeRangeView";
NSString * const PAGE_TYPE_TIME_RESTRICTION_CONFIRM = @"ucTimeRangeCnfm";
NSString * const PAGE_TYPE_DISPLAY_AM_INFO = @"displayAMInfo";
NSString * const PAGE_TYPE_REMOVE_AM_INFO = @"removeAMInfo";
NSString * const PAGE_TYPE_SUBMIT_ADD_AM_INFO = @"submitAddAMInfo";
NSString * const PAGE_TYPE_SETUP_BSP = @"setupBSP";
NSString * const PAGE_TYPE_CONFIRM_BSP_SETUP = @"confirmBSPSetup";
NSString * const PAGE_TYPE_ORDER_NFC_SIM = @"orderNfcSim";
NSString * const PAGE_TYPE_VALIDATE_PROFILE_SETUP = @"validateProfileSetup";
NSString * const PAGE_TYPE_CREATE_USER_ID = @"createUserId";
NSString * const PAGE_TYPE_MANAGE_SHARE_NAME = @"customNm";
NSString * const PAGE_TYPE_SUBMIT_SHARE_NAME = @"pcidCustomNameSbmt";
NSString * const PAGE_TYPE_SMART_REWARDS = @"balanceStatus";
NSString * const PAGE_TYPE_FEATURE_REVIEW = @"featureReview";

NSString * const PAGE_TYPE_DATA_USAGE_HISTORY = @"dataUsageHistory";
NSString * const PAGE_TYPE_MINUTES_USAGE_HISTORY = @"minutesUsageHistory";
NSString * const PAGE_TYPE_MESSAGE_USAGE_HISTORY = @"messageUsageHistory";


NSString * const PAGE_TYPE_RETRIEVE_GLOBAL_READY_LOCATIONS = @"retrieveGlobalReadyLocations";
NSString * const PAGE_TYPE_MANAGE_PRIVACY = @"mngPrivacySetting";
NSString * const PAGE_TYPE_UPDATE_PRIVACY = @"updatePrivacySettings";
NSString * const PAGE_TYPE_GRC_VERIFY_HARDWARE = @"grcVerifyHardware";
NSString * const PAGE_TYPE_VERIFY_GLOBAL_READY_DEVICE = @"verifyGlobalReadyDvc";
NSString * const PAGE_TYPE_GLOBAL_READY_CHECK = @"retrieveGlobalReadyLocations";
NSString * const PAGE_TYPE_SHOW_GRC_OPTIONS     = @"showGRCOptions";
NSString * const PAGE_TYPE_GRC_VERIFY_ACC_FEATURE = @"grcVerifyAccFeature";
NSString * const PAGE_TYPE_VERIFY_GLOBAL_READY_DEVICE_FEATURE = @"verifyGlobalReadyDvcFeat";
NSString * const PAGE_TYPE_VERIFY_GLOBAL_READY_INTL_OPTION = @"IntlOptionsForWhileInsideUSA";
NSString * const PAGE_TYPE_INTL_GLOBAL_PAGE_INTL_ALC = @"intlGlobPageInfo_INTL_ALC";
NSString * const PAGE_TYPE_CHG_PLAN_CURRENT =  @"chgplanCurrent";
NSString * const PAGE_TYPE_INTL_GLOBAL_PAGE_INTL_LLC = @"intlGlobPageInfo_INTL_LLC";
NSString * const PAGE_TYPE_RETRIEVE_LOCATION = @"retrieveLocation";
NSString * const PAGE_TYPE_TRIP_PLANNER = @"intlGlobPageInfo_frm_tripPlanner";
NSString * const PAGE_TYPE_INTL_GLOB_PAGE_GLOB_LLC = @"intlGlobPageInfo_GLOB_LLC";

NSString * const PAGE_TYPE_BEST = @"BEST";
NSString * const PAGE_TYPE_CREATE_OC_SESSION = @"createOCSession";
NSString * const PAGE_TYPE_PAY_BILL = @"pmtSecMsg";
NSString * const PAGE_TYPE_PAYMENT_PTP = @"ptpSecMsg";
NSString * const PAGE_TYPE_PAYMENT_HISTORY = @"paymentHistorySuccess";
NSString * const PAGE_TYPE_DISPLAYE_BILL_COPY = @"dispBillCopy";
NSString * const PAGE_TYPE_VALIDATE_SIM_NUMBER_REQUEST = @"validateSimNumber";
NSString * const PAGE_TYPE_VALIDATE_SIM_NUMBER = @"noSimFound";
NSString * const PAGE_TYPE_VIEW_RECEIPT = @"receiptsDisplay";
NSString * const PAGE_TYPE_VIEW_RECEIPT_PDF = @"pdfDisplay";
NSString * const PAGE_TYPE_VIEW_BILL = @"viewBill";
NSString * const PAGE_TYPE_VIEW_BILL_REQUEST = @"bill";
NSString * const PAGE_TYPE_VIEW_BILL_PDF = @"getBillDetail";
NSString * const PAGE_TYPE_VIEW_BILL_TIP = @"viewBillTip";
NSString * const PAGE_TYPE_GET_STATEMENT_DATES = @"getStatementDates";
NSString * const PAGE_TYPE_MANAGE_PAY_ACCOUNT = @"getPaymentAccount";
NSString * const PAGE_TYPE_NOTIFICATIONS = @"notifications";
NSString * const PAGE_TYPE_HOME_STORE_MAP_URL = @"homeStoreMapUrl";
NSString * const PAGE_TYPE_ADD_NEW_PAYMENT_ACCOUNT = @"addNewPaymentAccount";
NSString * const PAGE_TYPE_MANAGE_AUTO_PAY = @"manageAutoPay";
NSString * const PAGE_TYPE_M2M = @"m2m";
NSString * const PAGE_TYPE_M2M_SUBMIT = @"m2mSubmit";
NSString * const PAGE_TYPE_MANDATORY_UPGRADE = @"mandatoryUpgrade";
NSString * const PAGE_TYPE_MANAGE_PAPERLESS_BILL = @"paperlessBilling";
NSString * const PAGE_TYPE_MANAGE_PAPERFREE_BILL = @"viewPaperFreeBillingInformation";
NSString * const PAGE_TYPE_MANAGE_PAPER_BILL_CONFIRMATION = @"viewOptOutPaperFreeBillingLandingPage";
NSString * const PAGE_TYPE_PENDING_ORDERS = @"PendingOrderDetail";
NSString * const PAGE_TYPE_LOG_CRASH = @"logCrashReport";
NSString * const PAGE_TYPE_LOG_ERRORS = @"logJsonErrors";
NSString * const PAGE_TYPE_LOG_DATA = @"logData";
NSString * const PAGE_TYPE_IN_STORE = @"inStore";
NSString * const PAGE_TYPE_TERMS_CONDITION = @"termsnConditions";
NSString * const PAGE_TYPE_DATA_UTILIZATION = @"DataUtilization";
NSString * const PAGE_TYPE_LOGIN_SELECTION = @"loginSelection";
NSString * const PAGE_TYPE_EDGE_AGREEMENT = @"ViewEdgeAgreement";
NSString * const PAGE_TYPE_EDGE_BUYOUT = @"edgeBuyOut";
NSString * const PAGE_TYPE_EDGE_BUYOUT_PAYMENT_OPTION = @"edgeBuyoutPaymentOption";
NSString * const PAGE_TYPE_EDGE_BUY_AMOUNT = @"edgeBuyAmount";
NSString * const PAGE_TYPE_EDGE_BUYOUT_SAVED_PAYMENT = @"savedPayment";
NSString * const PAGE_TYPE_EDGE_BUYOUT_NEW_CARD_PAYMENT = @"newCardPayment";
NSString * const PAGE_TYPE_EDGE_BUYOUT_NEW_ACH_PAYMENT = @"newACHPayment";
NSString * const PAGE_TYPE_EDGE_BUYOUT_NEW_GIFT_CARD_PAYMENT = @"newGiftCardPayment";
NSString * const PAGE_TYPE_EDGE_BUYOUT_CONFIRM = @"edgeBuyoutConfirm";
NSString * const PAGE_TYPE_DISCOUNT_STATUS_DETAILS = @"discountStatusDetails";
NSString * const PAGE_TYPE_VALIDATE_TOUCH_ID_AUTH = @"validateTouchIdAuth";
NSString * const PAGE_TYPE_TOUCH_ID_AUTH = @"touchIdAuth";
NSString * const PAGE_TYPE_PRICING_OVERLAY = @"planOptions";
NSString * const PAGE_TYPE_SEND_SMS = @"sendSMS";
NSString * const PAGE_TYPE_PLAN_FEATURE_CHANGE = @"FeatureReviewPage";
NSString * const PAGE_TYPE_SIMPLE_PLAN_POSITIONING = @"SimplePlanPositioning";
NSString * const PAGE_TYPE_FEATURE_CHG_CONFIRM = @"featureChgConfirm";
NSString * const PAGE_TYPE_VICE_CONNECTED_DEVICES = @"connectedDevices";
NSString * const PAGE_TYPE_VICE_REMOVE_CONNECTED_DEVICES = @"removeConnectedDevice";
NSString * const PAGE_TYPE_VICE_EDIT_ADDRESS = @"editAddress";
NSString * const PAGE_TYPE_OPEN_SSO = @"openSSOPageName";
NSString * const PAGE_TYPE_VOICE_ASSIST = @"voiceAssist";
//chris:datagifting
NSString * const PAGE_TYPE_DATA_GIFTING = @"DataGiftRetrieve";
NSString * const PAGE_TYPE_ORDER_STATUS = @"orderStatus";
NSString * const PAGE_TYPE_ORDER_TRACKING = @"orderTracking";
NSString * const PAGE_TYPE_CONNECTION_DAY = @"connectionDayEnroll";
NSString * const PAGE_TYPE_VIEW_NBS_PDF = @"getNBSPdf";


NSString * const PAGE_TYPE_PAYMENT_CC_ACH = @"paymentCC_ACH";
NSString * const PAGE_TYPE_PAYMENT_CONFIRMATION = @"confirm_payment";
NSString * const PAGE_TYPE_PAYMENT_RE_ENTER_CARD_VALIDATION = @"reenter_card_validation";
NSString * const PAGE_TYPE_PAYMENT_RE_ENTER_CCID = @"reenter_ccid";
NSString * const PAGE_TYPE_PAYMENT_REENTER_CCID_ZIP = @"reenter_ccid_zip";
NSString * const PAGE_TYPE_PAYMENT_REENTER_ZIP = @"reenter_zip";
NSString * const PAGE_TYPE_PAYMENT_SET_NEW_CARD_ADD = @"setNewcardAddtl";
NSString * const PAGE_TYPE_PAYMENT_VALIDATE_CARD = @"validateCard";
NSString * const PAGE_TYPE_PAYMENT_VALIDATE_CHECK = @"validateCheck";
NSString * const PAGE_TYPE_PAYMENT_NEW_CHECK = @"newCheckPayment";
NSString * const PAGE_TYPE_PAYMENT_VALIDATE_GIFTCARD = @"validateGiftCard";
NSString * const PAGE_TYPE_PAYMENT_CONFIRM_GIFTCARD_PAYMENT = @"confirm_giftcard_payment";
NSString * const PAGE_TYPE_ADD_ACH_ACCOUNT = @"saveNewCheckAcct";
NSString * const PAGE_TYPE_ADD_CARD_ACCOUNT = @"saveNewCardAcct";
NSString * const PAGE_TYPE_DELETE_ACCOUNT = @"deleteAccountRequest";
NSString * const PAGE_TYPE_UPDATE_ACCOUNT_ACH = @"updateSavedCheck";
NSString * const PAGE_TYPE_UPDATE_ACCOUNT_CARD = @"updateSavedCard";
NSString * const PAGE_TYPE_DELETE_CARD_UPDATE = @"deleteCard";
NSString * const PAGE_TYPE_NON_VERIZON_USER = @"nonVerizonUser";

//ShopFlow
NSString * const PAGE_TYPE_UPGRADE_ELIGIBLE_DEVICES = @"shopUpgradeEligibleDvs";
NSString * const PAGE_TYPE_SHOP_TRADE_IN_QUESTIONNAIRE = @"shopTradeInQuestionnaire";
NSString * const PAGE_TYPE_GET_GRIDWALL_CONTENT = @"getGridWallContent";
NSString * const PAGE_TYPE_PRODUCT_DETAILS = @"productDetails";
NSString * const PAGE_TYPE_PRODUCT_REVIEWS = @"productReviews";
NSString * const PAGE_TYPE_PRODUCT_PROTECTION = @"productProtection";
NSString * const PAGE_TYPE_SHOP_TRADE_IN_DEVICES = @"shopTradeInDevices";
NSString * const PAGE_TYPE_MINI_GRIDWALL = @"miniGridWall";
NSString * const PAGE_TYPE_FULL_GRIDWALL = @"fullGridWall";
NSString * const PAGE_TYPE_SHOP_TRADE_APPRAISAL = @"shopTradeInAppraisal";
NSString * const PAGE_TYPE_SHOP_CART = @"shoppingCart";
NSString * const PAGE_TYPE_SHOP_CHECKOUT = @"shopCheckOut";
NSString * const PAGE_TYPE_SHOP_PURCHASE_COMPLETE = @"purchaseComplete";
NSString * const PAGE_TYPE_COMPLETE_ORDER_DETAILS = @"completeOrderDetails";
NSString * const PAGE_TYPE_NON_VERIZON = @"nonVerizonUser";

// Lower Funnel Page_Types
NSString * const PAGE_TYPE_GET_SHIPPING_INFORMATION = @"shippingInformation";
NSString * const PAGE_TYPE_GET_BILLING_INFORMATION = @"billingInformation";
NSString * const PAGE_TYPE_GET_DEVICE_INFORMATION = @"deviceInformation";
NSString * const PAGE_TYPE_GET_TERMS_AND_CONDITION = @"getTermsAndConditions";


// Lower Funnel
NSString *const PAGE_TYPE_SHOP_CHECKOUT_TERMS_AGREEMENT_TEXT_ARRAY = @"AGREEMENT_TEXTS";

NSString * const PAGE_TYPE_SHOP_CHECKOUT_SHIPPING_SCREEN_HEADING_TEXT = @"scrnHdgText";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_SHIPPING_BLOCK_HEADER_TEXT = @"shipBlockHdgText";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_SHIPPING_ADDRESS_HEADER_TEXT = @"shipAdrText";

NSString * const PAGE_TYPE_SHOP_CHECKOUT_SHIPPING_ADDRESS_CONTACT_INFO_HEADER_TEXT = @"contactInfoText";

// Shipping options info
NSString * const PAGE_TYPE_SHOP_CHECKOUT_SHIPPING_TYPES_INFO = @"shippingTypesInfo";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_SHIPPING_TYPES_ACTIVE = @"active";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_SHIPPING_TYPES_SHORT_DESCRIPTION = @"shortDescription";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_SHIPPING_TYPES_SHIPPING_DESCRIPTION = @"shippingDescription";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_SHIPPING_TYPES_SHIPPING_COST = @"shippingCost";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_SHIPPING_TYPES_SHIPPING_OPTION_ID = @"shippingOptionId";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_SHIPPING_TYPES_ADDED_SHIPPINGOPTION_ID = @"addedShippingOptionId";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_SHIPPING_TYPES_ESTIMATED_DELIVERY_DATE = @"estimatedDeliveryDate";

/***** start screen 6.1b, 6.1c, 6.1d, 6.1e *******/

//start lower funnel EDIT INFORMATION

#pragma JSON values for shop flow

NSString * const USER_SHIP_INFO = @"userShipInfo";
NSString * const CONTACT_INFO = @"contactInfo";
NSString * const PHONE_NUMBER = @"phoneNumber";
NSString * const ADDRESS_INFO = @"addressInfo";
NSString * const ADDRESS2 = @"address2";
NSString * const ZIP_CODE_LOWERCASE = @"zipcode";
NSString * const EDIT_SHIPPING_ADDRESS = @"Edit Shipping Address";
NSString * const EDIT_PAYMENT_INFORMATION = @"Edit Payment Information";
NSString * const EDIT_DEVICE_INFORMATION = @"Edit Device Information";
NSString * const VERIZON_CUSTOMER_AGREEMENT = @"Verizon Wireless Customer Agreement";
NSString * const CREDIT_CARD_NUMBER = @"creditCardNumber";
NSString * const CREDIT_CARD_EXP_MONTH = @"creditCardExpMonth";
NSString * const CREDIT_CARD_EXP_YEAR = @"creditCardExpYear";
NSString * const BILLING_ZIP_CODE = @"billingZipCode";
NSString * const CREDIT_CARD_VERIFICATION_NO = @"creditCardVerificationNumber";
NSString * const SAVED_CARD_NICKNAME = @"savedCardNickName";
NSString * const CREDIT_CARD_INFO = @"creditCardInfo";


//Request Keys
NSString * const CUSTOMER_NAME_LOWERCASE = @"customerName";

//SHIPPING INFORMATION
NSString * const ALL_FIELDS_MUST_BE_COMPLETED = @"ALL_FIELDS_MUST_BE_COMPLETED_LBL";
NSString * const FIELDS_HIGHLIGHTED_MUST_BE_COMPLETED_LBL = @"FIELDS_HIGHLIGHTED_MUST_BE_COMPLETED_LBL";
NSString * const CUSTOMER_NAME = @"CUSTOMER_NAME_LBL";
NSString * const SHIPPING_ADDRESS1 = @"SHIPPING_ADDR_ONE";
NSString * const SHIPPING_ADDRESS2 = @"SHIPPING_ADDR_TWO";
NSString * const CITY_LBL = @"CITY_LBL";
NSString * const STATE_LBL = @"STATE_LBL";
NSString * const STATE_ARRAY = @"states";
NSString * const ZIP_CODE_LBL = @"ZIP_CODE_LBL";
NSString * const CONTACT_PHONE_NUMBER = @"ONE_CLICK_CONTACT_PHONE_NUM_LBL";
NSString * const CONTACT_EMAILADD = @"CONTACT_EMAIL_ADDR_LBL";
NSString * const UPDATE_SHIPPING_INFORMATION = @"Update Shipping Information";
NSString * const CANCEL_CAPS = @"CANCEL_CAPS_LNK";
//BILLING INFORMATION
NSString * const SAVE_CARD_TOACCOUNT_LBL = @"SAVE_CARD_TOACCOUNT_LBL";
NSString * const SHOW_SAVE_CARD_OPTION = @"showSaveCardOption";
NSString * const BILLING_ZIP_LBL = @"BILLING_ZIP_LBL";
NSString * const CVN_LBL = @"CVN_LBL";
NSString * const EXPIRATION_DATE_LBL = @"EXPIRATION_DATE_LBL";
NSString * const SCAN_YOUR_CARD = @"SCAN_YOUR_CARD";
NSString * const CREDIT_CARD_SCAN_LBL = @"CREDIT_CARD_SCAN_LBL";
NSString * const SCAN_CARD_TITLE = @"scanCardTitle";
NSString * const SCAN_CARD_MESSAGE = @"scanCardMessage";
NSString * const SCAN_CARD_MANUAL_BTN = @"scanCardEnterManBtn";
NSString * const INVALID_CARD_LBL = @"INVALID_CARD_LBL";
NSString * const SCAN_GUIDE_INFO_LBL = @"SCAN_GUIDE_INFO_LBL";
NSString * const ENTER_MANUALLY_LBL = @"ENTER_MANUALLY_LBL";
NSString * const CARD_NUMBER_LBL = @"CARD_NUMBER_LBL";
NSString * const PAY_WITH_NEW_CARD_LBL = @"PAY_WITH_NEW_CARD_LBL";
NSString * const PAY_WITH_SAVED_CARD_LBL = @"PAY_WITH_SAVED_CARD_LBL";
NSString * const BILLING_ADDRESS1 = @"BILLING_ADDR_ONE";
NSString * const BILLING_ADDRESS2 = @"BILLING_ADDR_TWO";
NSString * const BILL_TO_MY_ACC_LBL = @"BILL_TO_MY_ACC_LBL";
NSString * const UPDATE_BILLING_INFORMATION = @"Update Payment Information";
NSString * const SCAN_CARD_IMAGE = @"camera_40px";
NSString * const BILL_TO_ACCOUNT_ELIGIBLE = @"billToAccountEligible";
NSString * const PAYMENT_SELECTION_WARN_LBL = @"PAYMENT_SELECTION_WARN_LBL";

NSString * const VISA_CARD_IMAGE = @"visaCard";
NSString * const MASTER_CARD_IMAGE = @"masterCard";
NSString * const DISCOVER_CARD_IMAGE = @"discoverCard";
NSString * const AMEX_CARD_IMAGE = @"amexCard";

NSString * const NORTON_IMAGE = @"norton";
NSString * const NORTON_PREFIX_LBL = @"powered by ";
NSString * const NORTON_POSTFIX_LBL = @"VeriSign";

//DEVICE INFORMATION
NSString * const PHONE_NUMBER_INFORMATION_SECTION_HEADING = @"PHONE_NUMBER_LBL";
NSString * const SERVICE_ADDRESS1=@"SERVICE_ADDR_ONE";
NSString * const SERVICE_ADDRESS2=@"SERVICE_ADDR_TWO";
NSString * const UPDATE_DEVICE_INFORMATION=@"Update Device Information";
NSString * const DEVICE_ADDRESS = @"deviceServiceAddress";
NSString * const PHONE_NUMBER_SECTION_CONTENT=@"TRANSFER_FROM_OLD_TO_NEW_DEVICE_DESC";
//TERMS AND CONDITION INFORMATION
NSString * const ACCEPT_TERMS_AND_CONDITION=@"Accept Terms & Conditions to Continue";
NSString * const TNC_AGREEMENT=@"tncResponse";
NSString * const TNC_AGREEMENT_TXT=@"agreementText";
NSString * const ACCEPT_TC_CONTINUE_LBL = @"ACCEPT_TC_CONTINUE_LBL";
//End lower funnel EDIT INFORMATION

/*********   END  ***************/



// Shipping --> Payment Information
NSString * const PAGE_TYPE_SHOP_CHECKOUT_PAYMENT_BLOCK_HEADER_TEXT = @"paymentBlockHdgText";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_PAYMENT_INFO_TEXT = @"paymentInfoText";

NSString * const PAGE_TYPE_SHOP_CHECKOUT_PAYMENT_BILLING_INFO_TEXT = @"billingInfoText";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_PAYMENT_BILLING_ADDRESSS_TEXT = @"billingAdrText";

// Shipping -->  Additional Device Information
NSString * const PAGE_TYPE_SHOP_CHECKOUT_ADDITIONAL_DEVICE_INFO_BLOCK_HEADER_TEXT = @"AddionalInfoBlockHdgText";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_ADDITIONAL_DEVICE_SERVICE_ADDRESS = @"dvcSvcAdr";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_ADDITIONAL_DEVICES = @"devices";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_ADDITIONAL_DEVICE_ID = @"deviceId";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_ADDITIONAL_DEVICE_NAME = @"deviceName";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_ADDITIONAL_DEVICE_FLOW = @"flow";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_ADDITIONAL_DEVICE_MTN_NUMBER = @"mtnNumber";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_ADDITIONAL_DEVICE_E911_SERVICE_ADDRESS = @"e911ServiceAdr";

// Shipping -->  Terms & Conditions Section
NSString * const PAGE_TYPE_SHOP_CHECKOUT_TERMS_CONDITIONS_BLOCK_HEADER_TEXT = @"tncHdgText";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_TERMS_CONDITIONS_VZWCUSTAGREEMENT_TEXT = @"vzwCustAgreement";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_TERMS_CONDITIONS_VZWINSTSALESAGREEMENT_TEXT = @"vzwInstSalesAgreement";

// Accept & Review Your Order Screen
NSString * const PAGE_TYPE_SHOP_CHECKOUT_ACCEPT_AND_REVIEW =  @"acceptAndReview";

// Shipping Checkout Screen Options related
NSString * const PAGE_TYPE_SHOP_CHECKOUT_SELECTED_SHIPPING_INDEX = @"CheckedShippingOptionIndex";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_FIRST_VZW_POLICY_CHECKED = @"CheckedFirstVzWPolicy";
NSString * const PAGE_TYPE_SHOP_CHECKOUT_SECOND_VZW_POLICY_CHECKED = @"CheckedSecondVzWPolicy";


NSString * const PAGE_TYPE_CLEAR_SPOT = @"clearspotMain";
NSString * const PAGE_TYPE_CLEAR_SPOT_ENABLE_PUSH = @"clearspotEnablePush";

#pragma mark - Story Board Names
NSString * const STORY_BOARD_NAME_MAIN = @"Main";
NSString * const STORY_BOARD_NAME_AUTHENTICATION_FLOW = @"AuthenticationFlow";
NSString * const STORY_BOARD_NAME_MY_PROFILE_FLOW = @"MyProfileFlow";
NSString * const STORY_BOARD_NAME_DEVICE_FLOW = @"DeviceFlowScreens";
NSString * const STORY_BOARD_NAME_USAGE_ALERTS = @"ManageUsageAlerts";
NSString * const STORY_BOARD_NAME_REGISTER_FLOW = @"RegisterFlow";
NSString * const STORY_BOARD_NAME_PLAN_FLOW = @"PlanFlow";
NSString * const STORY_BOARD_NAME_MANAGE_SAFEGUARDS = @"ManageSafeguard";
NSString * const STORY_BOARD_NAME_CHANGE_FEATURE = @"ChangeFeature";
NSString * const STORY_BOARD_NAME_VERIZON_SELECT = @"ManageVerizonSelects";
NSString * const STORY_BOARD_NAME_PURCHASE_HISTORY = @"PurchaseHistory";
NSString * const STORY_BOARD_NAME_GLOBAL_READY_CHECK = @"GlobalReadyCheck";
NSString * const STORY_BOARD_NAME_VOICE_ASSIST = @"VoiceAssist";
NSString * const STORY_BOARD_NAME_STORE_VISIT_HISTORY = @"StoreVisitHistory";
NSString * const STORY_BOARD_NAME_SPLASH_SCREEN_NON_VERIZON_USERS = @"SplashScreen&Non-VerizonUsers";
NSString * const STORY_BOARD_NAME_USAGE_HISTORY = @"UsageHistory";


#pragma mark - Notification Names
NSString * const NOTIFICATION_NAME_MDN_CAROUSEL_CHANGED = @"notificationNameMdnCarouselChanged";
NSString * const NOTIFICATION_NAME_FETURE_SELECTIONCHANGE = @"NOTIFICATION_NAME_FETURE_SELECTIONCHANGE";
NSString * const NOTIFICATION_NAME_CACHE_UPDATE = @"cacheUpdate";
NSString * const NOTIFICATION_DEVICE_IMAGE_DOWNLOAD_SUCCESS = @"NOTIFICATION_DEVICE_IMAGE_DOWNLOAD_SUCCESS";
NSString * const NOTIFICATION_SIM_CARD_CHECK_SUCCESS = @"NOTIFICATION_SIM_CARD_CHECK_SUCCESS";
NSString * const NOTIFICATION_DISMISS_MODAL_VIEWS = @"NOTIFICATION_DISMISS_MODAL";
NSString * const NOTIFICATION_MODAL_VIEW_DISMISSED = @"NOTIFICATION_MODAL_DISMISSED";
NSString * const NOTIFICATION_DETAIL_WIDTH_CHANGED = @"NOTIFICATION_DETAIL_WIDTH_CHANGED";
NSString * const NOTIFICATION_MVM_CACHED_IMAGE_DOWNLOADED = @"NOTIFICATION_MVM_CACHED_IMAGE_DOWNLOADED";

NSString * const NotificationPromosDownloaded = @"NotificationPromosDownloaded";
NSString * const NotificationContentTransferActive = @"ContentTransferActive";
NSString * const NotificationContentTransferInactive = @"ContentTransferInactive";

#pragma mark - Notification Actions
NSString * const ACTION_LAUNCHURL = @"LAUNCHURL";
NSString * const ACTION_DEEPLINK = @"DEEPLINK";
NSString * const ACTION_ONECLICK = @"ONECLICK";
NSString * const ACTION_DISMISS = @"DISMISS";

#pragma mark - Image names
NSString * const ACCORDIAN_ARROW_CONTRACT = @"accordianArrow_contract";
NSString * const ACCORDIAN_ARROW_EXPAND = @"accordianArrow_expand";
NSString * const DROP_UP_ARROW = @"dropUpArrow_sm_8px";
NSString * const DROP_DOWN_ARROW = @"dropdownArrow_sm_8px";
NSString * const CHECKMARK = @"checkmark_20px";
NSString * const CHECKMARK_UNSELECTED = @"checkmark_unselected";
NSString * const RADIO_ON = @"radio_on";
NSString * const RADIO_OFF = @"radio_off";
NSString * const IMG_DEVICE_PLACEHOLDER = @"devicePlaceholder_42x70";
NSString * const IMG_DEFAULT_PHONE_PLACEHOLDER = @"default_phone_placeholder";

#pragma mark - Voice Search - VZAnalytics
NSString * const MVM_TYPEAHEAD_Q = @"TYPEAHEAD_SEARCH_Q";
NSString * const MVM_TYPEAHEAD_R = @"TYPEAHEAD_SEARCH_R";
NSString * const MVM_VOICE_SEARCH_Q = @"MVMVOICE_SEARCH_Q";
NSString * const MVM_VOICE_SEARCH_R = @"MVMVOICE_SEARCH_R";
NSString * const MVM_ICON_SEARCH_Q = @"ICON_SEARCH_Q";
NSString * const MVM_ICON_SEARCH_R = @"ICON_SEARCH_R";

#pragma mark - Other Keys for String File

// Keys
NSString * const RESTART_KEY = @"Restart Key";
NSString * const RETRY_KEY = @"Retry Key";
NSString * const OKAY_KEY = @"okCaps";
NSString * const CONTINUE_KEY = @"Continue";
NSString * const CLOSE_KEY = @"Close Key";
NSString * const MDN_INVALID_FORMAT_KEY = @"mdnInvalid";
NSString * const SESSION_TIMEOUT_KEY = @"Session Timeout Key";
NSString * const ERROR_INVALID_EMAIL_FORMAT_KEY = @"emailInvalid";
NSString * const REPORT_A_PROBLEM_KEY = @"Report Key";
NSString * const MY_CONTACTS_KEY = @"My Contacts";

// Values
NSString * const LANGUAGE_SPANISH = @"Spanish";

#pragma mark - Hybrid Constants

// No timeout. For Testing. (NO for production)
BOOL const NO_INITIAL_TIMEOUT = NO;

// Time before Timeout in seconds.
NSTimeInterval const HYBRID_TIME_OUT_TIME = 30.0;

// Arbitratry value for the timer being stopped (should be negative atleast)
NSTimeInterval const NO_TIMER = -100;

// The cache version key
NSString * const CACHE_VERSION_KEY = @"version";

// Java script strings
NSString * const JSCRIPT_TASK = @"function executeTask(param,jsonString) { window.location='http://jshandler/executeTask/'+param+'/'+jsonString; }";

// Prepay switch keys
NSString * const SWITCH_USERNAME_KEY = @"username";
NSString * const SWITCH_PASSWORD_KEY = @"password";

// Server response keys
NSString * const DATA_CLEAR_CACHE_KEY = @"clearcache";
NSString * const DATA_CLEAR_COOKIES_KEY = @"clearcookies";
NSString * const DATA_LANGUAGE_KEY = @"language";
NSString * const DATA_URL_KEY = @"url";
NSString * const DATA_APP_URL_KEY = @"packageName";
NSString * const DATA_STORE_URL = @"downloadURL";
NSString * const DATA_MODIFIED_SEND_PARAMS = @"modifiedSendParams";

NSString * const LANGUAGE_ENGLISH_VALUE = @"english";

//style="word-break:break-all"
NSString *const HTML_CONTENT = @"<html> <style type=\"text/css\">" \
"body { font-family:Verizon Apex; word-wrap: break-word;}" \
"</style> <body><p>%@</p><body> </html>";