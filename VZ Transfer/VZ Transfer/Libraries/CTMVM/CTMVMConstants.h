// Constants.h
// Holds any constants that should be easily changeable or may be used throughout the app. Page specific constants may not be listed here.

// For disabling NSLog during release. (debug only)
#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif

#define LINE_LOCATION_STRING(string) [NSString stringWithFormat:@"%s [Line %d] %@", __PRETTY_FUNCTION__, __LINE__,string];

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// remove to disable geofence features
#define GEOFENCE

#pragma mark - Test Constants

#define TEST_SSO_TOKEN (TESTING ? @"MTQ0MjI1NzcxMzk0MUBDNDZBMDVERjRDN0REMjY0MTJBNTczNzQ2NkNDMkYxOEQwNERGQUIy" : nil)


// If we go to the test screen or not. (NO for production)
extern BOOL const TESTING;
extern BOOL const TESTING_GEOFENCING;

// Flag for if we are using sso.
extern BOOL const USE_SSO;

// Flag for if we are logging request response information.
extern BOOL const LOG_REQUEST_RESPONSE;

// The total amount of recent mdns to display on the test screen
extern NSInteger const TOTAL_RECENT_MDNS;

// The indices for each request type in the override url array.
extern NSInteger const PREPAY_URL_INDEX;
extern NSInteger const POSTPAY_URL_INDEX;
extern NSInteger const ALIAS_URL_INDEX;
extern NSInteger const SSF_BASE_URL_INDEX;
extern NSInteger const COOKIE_INDEX;

#pragma mark - Splash Constants

// Show only the splash screen. For Testing. (NO for production)
extern BOOL const SPLASH_ONLY;

// The default messages for the splash screen.
extern NSString * const DEFAULT_SPLASH_MESSAGE_1_KEY;
extern NSString * const DEFAULT_SPLASH_MESSAGE_2_KEY;
extern NSString * const DEFAULT_SPLASH_MESSAGE_3_KEY;
extern NSString * const DEFAULT_SPLASH_MESSAGE_4_KEY;
extern NSString * const DEFAULT_SPLASH_MESSAGE_5_KEY;
extern NSString * const DEFAULT_SPLASH_MESSAGE_6_KEY;

#pragma mark - URL Constants

// Server URLs
extern NSString * const BASE_PRODUCTION_URL;
extern NSString * const URL_MVM_COMPONENT;
extern NSString * const URL_NATIVE_SERVER_PATH_COMPONENT;
extern NSString * const URL_HYBRID_SERVER_PATH_COMPONENT;
extern NSString * const URL_HYBRID_LAST_COMPONENT;
extern NSString * const URL_HYBRID_LAST_COMPONENT_SPANISH;

extern NSString * const URL_PREPAY;

extern NSString * const URL_REGISTER_ALIAS;

extern NSString * const BASE_SSF_URL_STRING;
extern NSString * const URL_DM_CACHE_COMPONENT;
extern NSString * const URL_DM_RECEIPT_COMPONENT;
extern NSString * const URL_DM_DEREGISTRATION_COMPONENT;

extern NSString * const PING_URL_COMPONENT;

#pragma mark - Other Constants

extern CGFloat const CORNER_RADIUS_TEXT_FEILD;

// Time before Timeout in seconds.
extern NSTimeInterval const TIME_OUT_TIME;

extern NSTimeInterval const TIME_OUT_TIME_TEST;

// A constant for the button index when an alert is dismissed
extern NSInteger const ALERT_DISMISSED_INDEX_CONSTANT;

// The accessory width for table view cells.
extern CGFloat const ACCESSORY_WIDTH;

extern CGFloat const RELATED_LINKS_HEIGHT;

// MVD
extern NSString * const MVD_CLEANER_SCHEME;

// Analytics
extern NSString * const MVM_WATCH_ANALYTICS;

#pragma mark - Static Cache Keys

extern NSString * const ERROR_TITLE_KEY;
extern NSString * const EMAIL_ADDRESS_KEY;
extern NSString * const CANCEL_CONFIRM_KEY;
extern NSString * const CONFIRM_KEY;
extern NSString * const FORGOT_PASSWORD_KEY;
extern NSString * const EMPTY_FIELD_KEY;
extern NSString * const SAVE_CHANGES_KEY;
extern NSString * const SUBMIT_KEY;
extern NSString * const UPDATE_KEY;
extern NSString * const ENTER_SECRET_ANSWER_KEY;
extern NSString * const REQUIRED_KEY;
extern NSString * const ALT_PHONE_NUMBER_KEY;
extern NSString * const BILLING_ADDRESS_1;
extern NSString * const BILLING_ADDRESS_2;
extern NSString * const CITY_KEY;
extern NSString * const STATE_KEY;
extern NSString * const ZIP_KEY;
extern NSString * const ACCEPT_TNC_KEY;
extern NSString * const SELECT_FEATURE;
extern NSString * const YES_KEY;
extern NSString * const NO_KEY;
extern NSString * const CANCEL_KEY;
extern NSString * const ENTER_SEARCH_TEXT;
extern NSString * const CALL_KEY;
extern NSString * const DIAL_KEY;
extern NSString * const ALERT_TITLE_KEY;
extern NSString * const SELECT_COUNTRY;
extern NSString * const EDIT_KEY;
extern NSString * const WARNING_TITLE_KEY;
extern NSString * const NO_SELECTION_MADE_KEY;
extern NSString * const SIGN_OUT_KEY;
extern NSString * const SPANISH_KEY;
extern NSString * const SIGN_OUT_CONFIRMATION_KEY;
extern NSString * const ERROR_PASSWORD_MISMATCH_KEY;
extern NSString * const ERROR_PASSWORD_KEY;
extern NSString * const ERROR_REQUIRED_FIELDS_KEY;
extern NSString * const INFORMATION_KEY;
extern NSString * const LEAVING_MY_VERIZON_KEY;
extern NSString * const LEAVE_WITHOUT_SAVING_KEY;
extern NSString * const NO_CHANGE_MADE_KEY;
extern NSString * const SUCCESS_KEY;
extern NSString * const PROFILE_SETTINGS_KEY;
extern NSString * const NOTIFICATION_FAIL_KEY;
extern NSString * const BACK_KEY;
extern NSString * const AGREE_BUTTON_TITLE_KEY;
extern NSString * const DECLINE_BUTTON_TITLE_KEY;
extern NSString * const DISCLAIMER_KEY;
extern NSString * const REMEMBER_ME_MESSAGE_KEY;
extern NSString * const OR_CAPS_KEY;
extern NSString * const REVIEW_PAYMENT_KEY;
extern NSString * const TOTAL_PER_MONTH_CAPS;
extern NSString * const MY_VERIZON_REGISTRATION;
extern NSString * const ACCEPT_AND_CONTINUE_KEY;
extern NSString * const ERROR_CHANGEUSERID_INVALID_KEY;
extern NSString * const ERROR_GREETING_NAME_KEY;
extern NSString * const ERROR_CONFIRM_EMAIL_KEY;
extern NSString * const ERROR_INVALID_ZIP_KEY;
extern NSString * const ERROR_INVALID_SOCIAL_KEY;
extern NSString * const WORKSHOP_CAPS_KEY;
extern NSString * const APPOINTMENT_CAPS_KEY;
extern NSString * const LOCATION_CAPS_KEY;
extern NSString * const DATA_METER_AWARENESS_KEY;
extern NSString * const DATA_METER_ALLOW_NOTIFICATIONS_KEY;
extern NSString * const DATA_METER_ACTIVATION_FAILED_KEY;
extern NSString * const NO_THANKS_KEY;
extern NSString * const GO_TO_SETTINGS_KEY;
extern NSString * const ERROR_PWD_SAMEAS_USERID_KEY;
extern NSString * const TUTORIAL_MENU_HDG;
extern NSString * const TUTORIAL_MENU_MSG;
extern NSString * const TUTORIAL_SWIPE;
extern NSString * const TUTORIAL_NOTIFICATION_HDG;
extern NSString * const TUTORIAL_NOTIFICATION_MSG;
extern NSString * const TUTORIAL_CLOSE;
extern NSString * const TUTORIAL_CONTINUE;
extern NSString * const USERNAME_INPUT;
extern NSString * const MY_FIOS;
extern NSString * const INPUT_MDN;
extern NSString * const SAVE_KEY;
extern NSString * const HOME_KEY;
extern NSString * const REVIEW_KEY;
extern NSString * const AUTO_PAY_POST_FIX;
extern NSString * const SELECT_ANOTHER_DEVICE_KEY;
extern NSString * const ERROR_CSQ_MISMATCH_ERROR_KEY;
extern NSString * const ERROR_CSQ_ENTER_QUESTION_KEY;
extern NSString * const ERROR_CSQ_ENTER_ANSWER_KEY;
extern NSString * const ERROR_CSQ_ENTER_CONFIRM_ANSWER_KEY;
extern NSString * const ERROR_CSQ_INCORRECT_LENGTH_ERROR_KEY;
extern NSString * const ERROR_CSQ_USER_MESSAGE_SPECIAL_CHARACTER_KEY;
extern NSString * const SELECT_SECRET_QUESTION;
extern NSString * const SELECT_ONE;
extern NSString * const ADD_MANAGER;
extern NSString * const FIRST_NAME_KEY;
extern NSString * const LAST_NAME_KEY;
extern NSString * const SELECT_A_LINE;
extern NSString * const YES_CAPS;
extern NSString * const NO_CAPS;
extern NSString * const EMPTY_FIRST_NAME;
extern NSString * const EMPTY_LAST_NAME;
extern NSString * const INVALID_FIRST_NAME;
extern NSString * const INVALID_LAST_NAME;
extern NSString * const DELETE_PHONE_NUMBER_MESSAGE;
extern NSString * const ERROR_NO_PHONE_NUMBER;
extern NSString * const ERROR_INVALID_PHONE_NUMBER_LENGTH;
extern NSString * const ERROR_INVALID_DESCRIPTION;
extern NSString * const ERROR_900_AREA_CODE;
extern NSString * const ERROR_SELF_MDN;
extern NSString * const ERROR_DIRECTORY_ASSISTANCE_NO;
extern NSString * const ERROR_DUPLICATE_NUMBER;
extern NSString * const ERROR_NO_SELECTION;
extern NSString * const ERROR_ENTER_DIFFERENT_NUM;
extern NSString * const PASSWORD_TIPS;
extern NSString * const AUTH_SUCCESS_FEATURE_FAIL;
extern NSString * const CONFIRM_PASSWORD_KEY;
extern NSString * const STATIC_PASSWORD_KEY;

//GRC
extern NSString * const VERIZONS_GLOBAL_TRAVEL_PROGRAM;
extern NSString * const GRC_CHECKING;
extern NSString * const GRC_ACCOUNT_FEATURES;
extern NSString * const GRC_DEVICE_SETTINGS;
extern NSString * const GRC_ABROAD_NOTE;
extern NSString * const COUNTRY_VO;
extern NSString * const GRC_COMPATIBILITY_SCRNHDG;
extern NSString * const GRC_COMPATIBILITY_SCRNMSG;
extern NSString * const GRC_DESTINATION_NAME;
extern NSString * const GRC_COMPATIBLE_DVC;
extern NSString * const GRC_INCOMPATIBLE_DVC;
extern NSString * const GRC_INCOMPATIBLE_NTRK;
extern NSString * const GRC_SELECT_COUNTRY_MSG;
extern NSString * const GRC_DVC_HWD_ELIGIBLE;
extern NSString * const LOCAL_USER_MESSAGE_INVALID_INPUT;
extern NSString * const LOCAL_USER_MESSAGE_EMPTY_INPUT;
extern NSString * const LOCAL_USER_MESSAGE_NOT_MATCH;
extern NSString * const MESSAGE_FAVORITE_STORE_SAVED;
extern NSString * const MESSAGE_FAVORITE_STORE_REMOVED;
extern NSString * const SELECT_DEVICE;
extern NSString * const TOTAL_USED_KEY;
extern NSString * const UNLIMITED_KEY;

#pragma mark - Request Parameters

// Client Params Keys
extern NSString * const OS_NAME_KEY;
extern NSString * const OS_VERSION_KEY;
extern NSString * const CURRENT_APP_VERSION_KEY;
extern NSString * const MODEL_NAME_KEY;
extern NSString * const BRAND_KEY;
extern NSString * const FORM_FACTOR_KEY;
extern NSString * const DEVICE_NAME_KEY;
extern NSString * const SOURCE_ID_KEY;
extern NSString * const NETWORK_MODE_KEY;
extern NSString * const DEVICE_MODE;
extern NSString * const WIFI_ENABLED_KEY;
extern NSString * const ERROR_LOGS_KEY;
extern NSString * const REMEMBER_ME_U_KEY;
extern NSString * const REMEMBER_ME_M_KEY;
extern NSString * const REMEMBER_ME_H_KEY;
extern NSString * const SOURCE_SERVER_KEY;
extern NSString * const MDN_KEY;
extern NSString * const NICKNAME_KEY;
extern NSString * const DEVICENAME_KEY;
extern NSString * const PRODUCTNAME_KEY;
extern NSString * const UPGRADE_ELIGIBILITY_TEXT;
extern NSString * const VIEW_EDGE_AGREEMENT_TEXT;
extern NSString * const DEVICE_IS_UO;
extern NSString * const SUSPENDED_TEXT;
extern NSString * const SCREEN_WIDTH_KEY;
extern NSString * const SCREEN_HEIGHT_KEY;
extern NSString * const CURRENT_HYBRID_VERSION_KEY;
extern NSString * const VZW_ID_KEY;
extern NSString * const IS_TABLET_KEY;
extern NSString * const SUPPORT_LOCATION_SERVICES_KEY;
extern NSString * const SSO_TOKEN_KEY;
extern NSString * const SSF_SSO_TOKEN;
extern NSString * const PUSH_TOKEN_KEY;
extern NSString * const MVM_REGISTER_REQUEST_KEY;
extern NSString * const MOT_KEY;
extern NSString * const APP_NAME_KEY;
extern NSString * const DM_REGISTER_REQUEST_KEY;
extern NSString * const IS_WIDGET_INSTALLED_KEY;
extern NSString * const DATA_METER_AWARENESS_POPUP_SHOW_KEY;
extern NSString * const PROFILE_OPTIONS_KEY;
extern NSString * const LOGIN_TYPE;
extern NSString * const DONT_SHOW_ROLE_INTERCEPT_AGAIN_KEY;
extern NSString * const SELECTED_LOGIN_TYPE;
extern NSString * const REGISTER_DEVICE_OAAM;
extern NSString * const TIME_ZONE;
extern NSString * const REGISTERED_CLIENT_VERSION_KEY;
extern NSString * const SIMPLE_OPTIONS_KEY;
extern NSString * const DEVICE_IDENTIFIER_KEY;
extern NSString * const UNIQUE_ID_KEY;
extern NSString * const FROM_NON_VERIZON_USER;
extern NSString * const HIDE_FOOTER;

// Client Request Values
extern NSString * const OS_NAME_VALUE;
extern NSString * const FORM_FACTOR_HANDSET_VALUE;
extern NSString * const FORM_FACTOR_TABLET_VALUE;
extern NSString * const DEVICE_NAME_IPAD_VALUE;
extern NSString * const DEVICE_NAME_IPHONE_VALUE;
extern NSString * const DEVICE_NAME_IPOD_VALUE;
extern NSString * const SOURCE_ID_VALUE;
extern NSString * const SOURCE_ID_URL_VALUE;
extern NSString * const SOURCE_ID_DM_VALUE;
extern NSString * const SOURCE_ID_CORE_SPOTLIGHT;
extern NSString * const SOURCE_ID_APP_SHORTCUT;
extern NSString * const NETWORK_MODE_WIFI_VALUE;
extern NSString * const NETWORK_MODE_3G_VALUE;
extern NSString * const NETWORK_MODE_4G_VALUE;
extern NSString * const SOURCE_SERVER_PREPAY_VALUE;
extern NSString * const SOURCE_SERVER_POSTPAY_VALUE;
extern NSString * const SOURCE_SERVER_NONE_VALUE;
extern NSString * const MOT_APNS_VALUE;
extern NSString * const APP_NAME_MVM_VALUE;
extern NSString * const PROFILE_OPTIONS_VALUE;
extern NSString * const LOGIN_TYPE_VALUE_AM;
extern NSString * const SELECTED_LOGIN_TYPE_SSO_VALUE;
extern NSString * const SELECTED_LOGIN_TYPE_HASH_VALUE;
extern NSString * const USE_TOUCH_ID;

// Launch App Keys
extern NSString * const INITIAL_LAUNCH_KEY;
extern NSString * const USER_ID_KEY;
extern NSString * const PASSWORD_KEY;

#pragma mark - Other Dictionary Keys and Values

// Request parameters
extern NSString * const REQUEST_PARAMETERS_KEY;

// The session key for getting the session cookie.
extern NSString * const SESSION_KEY;

// value for keychain service.
extern NSString * const SERVICE_REMEMBER_ME_KEY;
extern NSString * const SERVICE_SSO_KEY;
extern NSString * const SERVICE_TOUCH_ID_KEY;
extern NSString * const SERVICE_DEVICE_ID;
extern NSString * const SERVICE_MMG_ID;
extern NSString * const SERVICE_MMG_LOGIN_TOKEN;

// Key for the view controller to pop the stack to.
extern NSString * const VC_TO_POP_TO_KEY;

// Used to determine which flow a page may be in by which value is present for this key.
extern NSString * const FLOW_KEY;

// Flow Values
extern NSString * const FLOW_FORGOT_PASSWORD_VALUE;
extern NSString * const FLOW_RESET_PASSWORD_VALUE;
extern NSString * const FLOW_SETUP_PASSWORD_VALUE;
extern NSString * const FLOW_FORGOT_SECRET_QUESTION_ANSWER;

#pragma mark - Error Constants

// Timeout message to display to user.
extern NSString * const ERROR_MESSAGE_TIMEOUT_KEY;

// My Profile Error Messages
extern NSUInteger const NICKNAME_MAX_CHARACTER_LENGTH;
extern NSUInteger const PASSWORD_MAX_CHARACTER_LENGTH;
extern NSUInteger const PIN_MAX_CHARACTER_LENGTH;
extern NSUInteger const USER_ID_MAX_CHARACTER_LENGTH;
extern NSUInteger const EMAIL_MAX_CHARACTER_LENGTH;
extern NSUInteger const SECRET_ANSWER_MAX_CHARACTER_LENGTH;
extern NSUInteger const ZIP_MAX_CHARACTER_LENGTH;
extern NSUInteger const ZIP_PAY_BILL_MAX_CHARACTER_LENGTH;
extern NSUInteger const CONTACT_NUMBER_MAX_CHARACTER_LENGTH;
extern NSUInteger const INTERNATIONAL_NUMBER_MAX_CHARACTER_LENGTH;
extern NSUInteger const ADDRESS_LINE1_NUMBER_MAX_CHARACTER_LENGTH;
extern NSUInteger const VOICE_MAIL_PASSWORD_MAX_CHARACTER_LENGTH;

// Try again later message for user with *611. For critical erros that shouldn't happen, so the user should have an option to call in.
extern NSString * const ERROR_MESSAGE_CRITICAL_KEY;

// Unable to process your request error message.
extern NSString * const ERROR_MESSAGE_UNABLE_PROCESS_REQUEST_KEY;

// Maximum number of errors to keep logged.
extern NSUInteger const MAX_ERRORS_LOGGED;

// Name of the error log
extern NSString * const ERROR_LOG_NAME;
extern NSString * const CRASH_LOG_NAME;

// Key for error saving errors
extern NSString * const ERROR_SAVING_ERRORS_KEY;

// Error Domains
extern NSString * const SYSTEM;
extern NSString * const NATIVE;
extern NSString * const SERVER;

// Error Codes
extern NSString * const ERROR_CODE_DEFAULT;
extern NSString * const ERROR_CODE_PARSING_JSON;
extern NSString * const ERROR_CODE_NO_ERROR_INFO;
extern NSString * const ERROR_CODE_NO_PAGE_TYPE;
extern NSString * const ERROR_CODE_INIT_CONTROLLER;
extern NSString * const ERROR_CODE_POST_PROCESS_JSON;
extern NSString * const ERROR_CODE_NATIVE_TIMEOUT;
extern NSString * const ERROR_CODE_SHOWING_ALERT;

extern NSString * const ERROR_CODE_LINKAWAY_FAILED;
extern NSString * const ERROR_CODE_UNKNOWN_ACTION_TYPE;

extern NSString * const ERROR_CODE_EMPTY_FIELD;
extern NSString * const ERROR_CODE_INPUT_VALIDATION_FAILURE;

extern NSString * const ERROR_CODE_TAB_SELECT;

extern NSString * const ERROR_CODE_EMPTY_RESPONSE;

extern NSString * const ERROR_CODE_STATIC_CACHE_FAIL;

extern NSString * const ERROR_CODE_SERVER_FAIL_SEND_TOUCH_HASH;

extern NSString * const ERROR_CODE_NO_MDN_FOR_ACCOUNT_SUMMARY;

extern NSString * const ERROR_CODE_JSON_NOT_A_DICTIONARY;

extern NSString * const ERROR_CODE_NO_LINK_AWAY_AFTER_SSO;

extern NSString * const ERROR_CODE_NO_STORYBOARD;
extern NSString * const ERROR_CODE_NO_VIEW_CONTROLLER_IDENTIFIER;
extern NSString * const ERROR_CODE_NO_VIEW_CONTROLLER_NIB_NAME;

// Server Error Codes
extern NSString * const ERROR_CODE_SERVER_AAA_FAILURE;
extern NSString * const ERROR_CODE_ACCOUNT_LOCKED;
extern NSString * const ERROR_CODE_SERVER_SSO_TOKEN_INVALID;
extern NSString * const ERROR_CODE_SERVER_SSO_FAILURE_1;
extern NSString * const ERROR_CODE_SERVER_SSO_FAILURE_2;
extern NSString * const ERROR_CODE_SERVER_VALIDATE_MDN_FAILURE;
extern NSString * const ERROR_CODE_PREPAID_MDN;
extern NSString * const ERROR_CODE_HASH_FAILED;
extern NSString * const ERROR_CODE_FIOS_POPUP;
extern NSString * const ERROR_CODE_FRAUD;
extern NSString * const ERROR_CODE_TIMEOUT;
extern NSString * const ERROR_CODE_INTERCEPT;
extern NSString * const ERROR_CODE_SILENT_REDIRECT;
extern NSString * const ERROR_CODE_REDIRECT;

#pragma mark - String Formats

extern NSString * const STRING_FORMAT_STRING_WITH_PARAN_STRING;
extern NSString * const STRING_FORMAT_2STRINGS_WITH_SPACE;
extern NSString * const STRING_FORMAT_2STRINGS_WITH_SPACE_SLASH;
extern NSString * const STRING_FORMAT_2STRINGS_EQUAL;
extern NSString * const STRING_FORMAT_PRICE_PER_UNIT;
extern NSString * const STRING_FORMAT_PREPEND_SPACE;
extern NSString * const STRING_FORMAT_SEARCH_QUERY;

#pragma mark- Regular Expressions

// Zip Code valid character regular expression
extern NSString * const REGULAR_EXPRESSION_ZIP_CODE;

// Password valid character regular expression
extern NSString * const REGULAR_EXPRESSION_PASSWORD;

// Secret Answer valid character regular expression
extern NSString * const REGULAR_EXPRESSION_SECRET_ANSWER;

extern NSString * const REGULAR_EXPRESSION_DIGIT_ONLY;
extern NSString * const REGULAR_EXPRESSION_DECIMAL;
extern NSString * const REGULAR_EXPRESSION_EMAIL;
extern NSString * const REGULAR_EXPRESSION_NICKNAME;
extern NSString * const REGULAR_EXPRESSION_SHARE_NAME;

#pragma mark - Payment Constants

extern NSString * const ACCOUNT_TYPE_APO;
extern NSString * const ACCOUNT_TYPE_ACH;
extern NSString * const ACCOUNT_TYPE_PTP;
extern NSString * const ACCOUNT_TYPE_NEW_CC;
extern NSString * const ACCOUNT_TYPE_GIFT_CARD;
extern NSString * const ACCOUNT_TYPE_CC;
extern NSString * const ACCOUNT_CATEGORY_CHILD;
extern NSString * const ACCOUNT_CATEGORY_SAVED;
extern NSString * const ACCOUNT_CATEGORY_SAVED_AUTO;

extern NSString * const ACCOUNT_NAME;
extern NSString * const LAST_FOUR_DIGITS;

extern NSString * const CATEGORY_KEY;
extern NSString * const DRACTION_ACH;
extern NSString * const DRACTION_CARD;
extern NSString * const DRACTION_KEY;

extern NSString * const PMT_INFO;
extern NSString * const SCRN_TXT_MAP;
extern NSString * const PMT_MAP;

extern NSString * const AmountToPayKey;
extern NSString * const AccountLast4Key;
extern NSString * const CardNumberKey;
extern NSString * const UndefinedValue;
extern NSString * const SaveCheckIndicatorKey;
extern NSString * const ValidationMap;
extern NSString * const CCIDKey;

#pragma mark - JSON Keys

extern NSString * const JSON_ARRAY;
extern NSString * const JSON_DICTIONARY;

extern NSString * const ERROR_INFO;
extern NSString * const ERROR_CODE;
extern NSString * const ERROR_MESSAGE;
extern NSString * const ERROR_USER_MESSAGE;
extern NSString * const ERROR_LEVEL;
extern NSString * const ERROR_HDG;

extern NSString * const PAGE_INFO;
extern NSString * const PAGE_INFO_LOWER_CASE;
extern NSString * const PAGE_INFO_VO;
extern NSString * const PAGE_INFO_RESP;
extern NSString * const PAGE_TYPE;
extern NSString * const PAGE_SUB_TYPE;
extern NSString * const SCREEN_HEADING;
extern NSString * const SCRN_MSG_INFO;
extern NSString * const SCRN_MSGS_INFO;
extern NSString * const SCRN_MSG_INFO_LOWER;
extern NSString * const SCRN_MSG;
extern NSString * const SCRN_MSG_MAP;
extern NSString * const SCRN_MSG_MAP_CAMEL_CASE;
extern NSString * const SCRN_MSG_OBJ_MAP;
extern NSString * const SCRN_MSG_CONTENT_TEXT1;
extern NSString * const SCRN_MSG_CONTENT_TEXT2;
extern NSString * const SCRN_MSG_CONTENT_TEXT3;
extern NSString * const SCRN_MSG_CONTENT_BOX_TEXT;
extern NSString * const SCRN_MSG_TNC_TEXT;
extern NSString * const SCRN_MSG_TNC_LINK_TEXT;
extern NSString * const LINK_MAP;
extern NSString * const NAME;
extern NSString * const MDN_INFO;
extern NSString * const VALUE;
extern NSString * const KEY;
extern NSString * const TOOL_TIP_MSG_MAP;
extern NSString * const TOOLTIP_MSG ;
extern NSString * const TOOLTIP_HDG ;
extern NSString * const TOUCH_ID_CLEAR_MSG;
extern NSString * const TOUCH_ID_HASH;
extern NSString * const TOUCH_ID_REASON;
extern NSString * const LOCATION_LIST;
extern NSString * const FAILED_REASON;

extern NSString * const LINKS_INFO;
extern NSString * const LINKS_ARRAY_LIST;
extern NSString * const SECTION_TITLE;
extern NSString * const ITEMS;
extern NSString * const IMAGE_NAME;
extern NSString * const TITLE;
extern NSString * const ACTION_TYPE;
extern NSString * const ACTION_TYPE_TRADE_IN;
extern NSString * const ACTION_TYPE_CONTENT_TRANSFER;
extern NSString * const ACTION_TYPE_LINK_AWAY;
extern NSString * const ACTION_TYPE_SSO;
extern NSString * const ACTION_TYPE_OPEN_PAGE;
extern NSString * const ACTION_TYPE_RESTART_FORCE_LOGIN;
extern NSString * const ACTION_TYPE_FRAUD;
extern NSString * const ACTION_TYPE_STORE_LOCATOR;
extern NSString * const ACTION_INFORMATION;
extern NSString * const LINK_AWAY_APP_URL;
extern NSString * const LINK_AWAY_URL;
extern NSString * const LINK_REDIRECT;

extern NSString * const USER_INFO;
extern NSString * const MDN;
extern NSString * const SORTID;
extern NSString * const URL;
extern NSString * const DEVICE_DETAIL_LIST ;
extern NSString * const FULL_GRIDWALL;
extern NSString * const DEVICE_PRODID;

extern NSString * const FWDMDN;

extern NSString * const BILLING_INFO;
extern NSString * const DAYS_LEFT_IN_CYCLE;
extern NSString * const BALANCE;
extern NSString * const DUE_DATE;

extern NSString * const TOOL_TIP;
extern NSString * const CONTINUE_BUTTON;
extern NSString * const CANCEL_BUTTON;
extern NSString * const SAVE_CHANGES_BUTTON;
extern NSString * const UNSAVED_WARNING;
extern NSString * const ALERTON;
extern NSString * const ALERT_MESSAGE;
extern NSString * const EMAIL_ALERT_LIST_VO;
extern NSString * const TEXT_ALERT_LIST_VO;
extern NSString * const ACCOUNT_OWNER_EMAIL;
extern NSString * const ACCOUNT_OWNER_MDN;
extern NSString * const EMAILADDRESS;
extern NSString * const SMSNOTIFICATION;
extern NSString * const OVERAGE_ALERT_VO;
extern NSString * const OVERAGE_ALERT_INFO;
extern NSString * const THRESHOLD_INFO;
extern NSString * const ALERTTHRESHOLDVO;
extern NSString * const ALLOWANCE;

extern NSString * const PLAN;
extern NSString * const HEIGHT_IN_BARS;
extern NSString * const MINUTES_INFO;
extern NSString * const MESSAGES_INFO;
extern NSString * const DATA_INFO;
extern NSString * const USAGE_TYPE;
extern NSString * const USAGE;
extern NSString * const USAGE_SUB_TEXT;
extern NSString * const ELIGIBLE_FOR_UPGRADE;
extern NSString * const MINUTES;
extern NSString * const MESSAGES;
extern NSString * const OVERAGE;
extern NSString * const OVERAGE_COST;
extern NSString * const INDEX;
extern NSString * const DATA;
extern NSString * const HOTSPOT;
extern NSString * const COLOR;
extern NSString * const TYPE;
extern NSString * const ROLE;

extern NSString * const TXT_BOX_MSG;
extern NSString * const SIGN_IN_DIFF_USER;
extern NSString * const ANSWER;
extern NSString * const SCRN_CONFIRM_PWD_TXT;
extern NSString * const MSG_CONTENT;

extern NSString * const DEVICE_INFO;
extern NSString * const USAGE_INFO;
extern NSString * const PLAN_MDN;
extern NSString * const LINK_LIST;
extern NSString * const LINK_LIST_LOWER;
extern NSString * const LINK_LIST_VO;
extern NSString * const LINK;
extern NSString * const LINK_LOWER;
extern NSString * const FORMATTED_MDN;
extern NSString * const DESC;
extern NSString * const DESCRIPTION;
extern NSString * const RATE;
extern NSString * const CURRENT_PLAN;
extern NSString * const IS_MY_PLAN;

extern NSString * const LINE_INFO;
extern NSString * const LINE_INFO_LOWER;
extern NSString * const LINE_INFO_LIST;
extern NSString * const LINE_INFO_VO_LIST;
extern NSString * const LINE;
extern NSString * const DEVICE;
extern NSString * const DEVICE_LIST;
extern NSString * const SORT_LIST;
extern NSString * const PRC;
extern NSString * const PRC_RT;
extern NSString * const PRICE ;
extern NSString * const PRCRATE;
extern NSString * const BUTTON_TITLE;

extern NSString * const PROFILE_INFO;

extern NSString * const USG_INFO;
extern NSString * const USG_INFOS;
extern NSString * const HDG;
extern NSString * const MSG;
extern NSString * const CYC_END_DT;
extern NSString * const ELIGIBLE_DATE;
extern NSString * const IMAGE_PATH;
extern NSString * const IMAGE_PATHVO;
extern NSString * const IMAGE_PATH_LARGE;
extern NSString * const IMAGE_PATH_MINI;
extern NSString * const IMAGE_PATH_MEDIUM;
extern NSString * const IMAGE_PATH_SMALL;
extern NSString * const LIST_TYPE;
extern NSString * const USG_DTL;
extern NSString * const TEXT;
extern NSString * const TOTALUSAGE;
extern NSString * const USED;
extern NSString * const SHARED_USED;
//extern NSString * const MAX;
extern NSString * const PROGRESS_COLOR;
extern NSString * const SHARED_PROGRESS_COLOR;
extern NSString * const PERCENTAGE;
extern NSString * const SHARED_PERCENTAGE;
extern NSString * const ESTIMATE_MESSAGE;
extern NSString * const OPTION_TYPE;
extern NSString * const LINE_MSG;
extern NSString * const SHR_MSG;
extern NSString * const OVERVIEW_INFO;
extern NSString * const LBL;
extern NSString * const EST_DT_TIME;
extern NSString * const DTL;
extern NSString * const SHR_DATA;
extern NSString * const PIC_NM;
extern NSString * const INDIVIDUAL_DISPLAYS;
extern NSString * const USG_OVERVIEW_MAP;
extern NSString * const LEFT_HEADER;
extern NSString * const RIGHT_HEADER;

extern NSString * const GET_ACC_INFO;
extern NSString * const ACCT_INFO_VO;

extern NSString * const SPLASH_MESSAGES;
extern NSString * const UHM_SECTION_NAME_KEY;
extern NSString * const SYSTEM_FLAGS_VO;
extern NSString * const SSO_SECTION_NAME_KEY;
extern NSString * const TOUCH_ID_SUPPORTED;
extern NSString * const SEND_SMS_FOR_TOUCH_ID;
extern NSString * const DATA_CHARGES_MESSAGE;
extern NSString * const ENABLE_ANALYTICS;

extern NSString * const LOAD_ACCT_DETAILS;

extern NSString * const PLAN_INFO_LIST;
extern NSString * const PLAN_INFO_LIST_LOWER;
extern NSString * const PLAN_INFO;
extern NSString * const PLAN_INFO_LOWER;
extern NSString * const IS_MY_CURRENT_PLAN;
extern NSString * const LINE_ACCESS_FEE_DETAILS;
extern NSString * const AMOUNT;
extern NSString * const PLAN_MDNS;
extern NSString * const LINE_INFO_LST;
extern NSString * const PLAN_MAP;
extern NSString * const PLAN_INFO_MSG;
extern NSString * const PLAN_INFO_TYPE;
extern NSString * const MDN_NICK_NAME;
extern NSString * const DEVICE_NAME;
extern NSString * const MONTH_TEXT;
extern NSString * const PLAN_MSG;
extern NSString * const PRICE_PLAN_FULL_DESC;
extern NSString * const HEADER_DISCLAIMER;
extern NSString * const RIGHT_SEGMENT;
extern NSString * const LEFT_SEGMENT;
extern NSString * const CURRENT_PLAN_TOTAL;
extern NSString * const OLD_PLAN_TOTAL;
extern NSString * const NEW_PLAN_TOTAL;
extern NSString * const FOOTER_BUTTON;
extern NSString * const SECONDARY_BUTTON;
extern NSString * const PRIMARY_BUTTON;
extern NSString * const FOOTER_DISCLAIMER;
extern NSString * const HIDE_LINES;
extern NSString * const SHOW_LINES;
extern NSString * const LINE_LEVEL_SETTINGS;
extern NSString * const TXT;
extern NSString * const AVAILABLE_PLANS;
extern NSString * const YOU_ARE_CURRENTLY;
extern NSString * const PLAN_DESC;
extern NSString * const TOTAL_MONTHLY_ACCESS;
extern NSString * const EFFECTIVE_DATE;

extern NSString * const PAYMENT_MAP;
extern NSString * const CURRENT_BAL_AMT;
extern NSString * const CURRENT_BAL_AMT_COLOR;
extern NSString * const CURRENT_BAL_HDG;
extern NSString * const DATE_MAP;
extern NSString * const DATE_MESSAGE;
extern NSString * const DATE;
extern NSString * const DATE_COLOR;
extern NSString * const TOP_LINK;
extern NSString * const LEFT_LINK;
extern NSString * const RIGHT_LINK;
extern NSString * const HOME_PAGE_USG_HDG;

// For iPad
extern int const MMG_EXPIRY_INTERVAL;
extern NSString * const MMG_ID;
extern NSString * const MMG_ID_KEY;
extern NSString * const MMG_LOGIN_TOKEN;
extern NSString * const MMG_LOGIN_TOKEN_HASH;

// For Data Meter
extern NSString * const DM_DATA;
extern NSString * const DM_DATA_UNITS;
extern NSString * const DM_USAGE_DATA;
extern NSString * const DM_MAXIMUM_ALLOWANCE;
extern NSString * const DM_TIMESTAMP;
extern NSString * const DM_PLAN_TYPE;
extern NSString * const DM_REAL_EST_DT;

//My Profile keys
extern NSString * const IS_SECURE;
extern NSString * const EMAIL_LABEL_TXT;
extern NSString * const ALT_PHONE_LABEL_TXT;
extern NSString * const BIL_ADDR_LINE1_TXT;
extern NSString * const BIL_ADDR_LINE2_TXT;
extern NSString * const CITY_LABEL_TXT;
extern NSString * const STATE_LABEL_TXT;
extern NSString * const ZIP_LABEL_TXT;
extern NSString * const SCRN_CONTENT_TXT;
extern NSString * const EMAIL_ADDRESS;
extern NSString * const SCREEN_SUB_HEADING;
extern NSString * const SHOW_GRAPH_FILTERS;
extern NSString * const SHOW_TABLE_FILTERS;
extern NSString * const GRAPH_FILTERS;
extern NSString * const TABLE_FILTERS;
extern NSString * const SUB_HEADING;
extern NSString * const SMALL_HEADING;
extern NSString * const ACCOUNT_NUMBER;
extern NSString * const BILLING_ADDRESS;
extern NSString * const BILLING_ADDRESS_VO;
extern NSString * const ACCOUNT_DETAIL;
extern NSString * const SUPPORT_PRIVACY;
extern NSString * const COMMON_MSG_INFO_VO;
extern NSString * const OPT_IN;
extern NSString * const OPTION_ID;
extern NSString * const CURR_PASSWORD;
extern NSString * const NEW_PASSWORD;
extern NSString * const CONFIRM_PASSWORD;
extern NSString * const EMAIL_INFO;
extern NSString * const MESSAGE;
extern NSString * const TIP_MESSAGE;
extern NSString * const TIP_HEADING;
extern NSString * const EMAIL;
extern NSString * const PROFILE_LIST_VO;
extern NSString * const PROFILE_LIST;
extern NSString * const STREET;
extern NSString * const ADDR_LN2;
extern NSString * const CITY;
extern NSString * const ST;
extern NSString * const STATE;
extern NSString * const ZIP;
extern NSString * const ST_LIST;
extern NSString * const CONTACT_INFO_LIST;
extern NSString * const CONTACT_INFO_LIST_VO;
extern NSString * const CONTACT_INFO_VO;
extern NSString * const CONTACT_NBR;
extern NSString * const ADDRESS;
extern NSString * const ZIP_CODE;
extern NSString * const ADDRESS1;
extern NSString * const CHANGE_CONTACT;
extern NSString * const CONTACT_NBR1;
extern NSString * const CONTACT_NBR2;
extern NSString * const QSTN_LST_INFO_VO;
extern NSString * const QSTN_DTL_INFO;
extern NSString * const QSTN_DTL_INFO_VO;
extern NSString * const QSTN;
extern NSString * const IS_INTERCEPT;
extern NSString * const QSTN_ID;
extern NSString * const SECRET_QUESTION_CONFIRM_ANSWER;
extern NSString * const SECRET_QUESTION_ANSWER;
extern NSString * const SELECT_SECRET_QUESTION_ID;
extern NSString * const APP_PROFILE_LIST;
extern NSString * const NPP_LIST_VO;
extern NSString * const IS_APPS_AVAILABLE;
extern NSString * const DEVICE_JSON;
extern NSString * const APP_PRIVACY_PROFILE;
extern NSString * const ACTION;
extern NSString * const APPLICATION_NAME;
extern NSString * const ALLOW;
extern NSString * const ID;
extern NSString * const PERMISSION_MSG;
extern NSString * const SELECTED;
extern NSString * const SELECTED_MDN;
extern NSString * const SECONDARY_MDN;
extern NSString * const SELECTED_LINE;
extern NSString * const SELECTED_SAFEGUARD;
extern NSString * const ADDED_SAFEGUARD;
extern NSString * const DELETED_SAFEGUARD;
extern NSString * const SAFEGUARD_STATUS;
extern NSString * const FB_FEATURE_LIST;
extern NSString * const BLOCK_HEADING;
extern NSString * const ALERT_LIMIT;
extern NSString * const FEAT_CODE;
extern NSString * const FEAT_CODE_FAMILYBASE;
extern NSString * const FB_PRIMARY_PARENT ;
extern NSString * const FB_SECONDARY_PARENT ;
extern NSString * const FB_CHILD ;
extern NSString * const FB_CURRENT_ROLE;
extern NSString * const TOOLTIP;
extern NSString * const TIP_MSG;
extern NSString * const MESSAGE_VO;
extern NSString * const MESSAGE_VO_LOWER;
extern NSString * const SAVE_STORE __attribute__((deprecated));
extern NSString * const REMOVE_STORE __attribute__((deprecated));
extern NSString * const STORE_COOKIE;
extern NSString * const PCID_MDN;
extern NSString * const SHARE_NAME_ID;
extern NSString * const SUCCESS_MSG_INFO_VO;
extern NSString * const TNC_TOOLTIP_TEXT1;
extern NSString * const TNC_TOOLTIP_TEXT2;
extern NSString * const TNC_TOOLTIP_HDG;
extern NSString * const BTN_TEXT;
extern NSString * const SelectedMDN;
extern NSString * const REQUESTED_PAGE_TYPE;
extern NSString * const STATIC_CACHE_VERSION;
extern NSString * const STATIC_CACHE_TIMESTAMP;
extern NSString * const IS_CURRENT_FEATURE;

//My Device
extern NSString * const MY_DEVICES;
extern NSString * const MANAGE_DEVICE_NICKNAMES;
extern NSString * const LINEINFOLIST;
extern NSString * const MDN1_KEY;
extern NSString * const FIRSTNAME1_KEY;
extern NSString * const LASTNAME1_KEY;
extern NSString * const COUNT_KEY;
extern NSString * const FIRSTNAME_KEY;
extern NSString * const LASTNAME_KEY;
extern NSString * const UPDATED_KEY;
extern NSString * const ELIGIBLE_UPGRADE_DATE;
extern NSString * const CONTRACT_EXPIRATION_DATE;
extern NSString * const DATA_CONTRACT_EXPIRATION_DATE;
extern NSString * const IS_UPGRADE_ELIGIBILITY;
extern NSString * const ACCT_INFO;
extern NSString * const AMINDICATOR;
extern NSString * const ACCOUNT_HOLDER;
extern NSString * const ACCOUNT_MANAGER;
extern NSString * const NOT_ELIGIBLE;
extern NSString * const SCRN_MSG_LINK_MAP;
extern NSString * const UPGRADE_MSG1;
extern NSString * const UPGRADE_MSG2;
extern NSString * const UPGRADE_MSG3;
extern NSString * const NOTIFICATION_UPDATE_DEVICE_NICKNAME_SUCCESS;
extern NSString * const USAGE_INFO_VO;
extern NSString * const USAGE_OVERVIEW;
extern NSString * const USAGE_DETAIL_LIST;
extern NSString * const HOME_PAGE_USAGE_MULTILINE_LINK;
extern NSString * const DEVICE_USAGE_SHARED_PLAN_LINK;
extern NSString * const SIM_NUMBER;
extern NSString * const IMEI_NUMBER;
extern NSString * const ESN_NUMBER;
extern NSString * const MY_ACCOUNT_BILLING;
extern NSString * const MANAGE_USAGE_ALERTS;
extern NSString * const MANAGE_CALL_FORWARDING;
extern NSString * const UPGRADE;
extern NSString * const ELIGIBLE_UPGRADE_TOOLTIP_MSG;
extern NSString * const CONTRACT_EXPIRATION_TOOLTIP_MSG;
extern NSString * const ELIGIBLE_UPGRADE_TOOLTIP_MAP;
extern NSString * const ELIGIBLE_UPGRADE_TOOLTIP_MSG_KEY;
extern NSString * const ELIGIBLE_UPGRADE_TOOLTIP_TITLE_KEY;
extern NSString * const ELIGIBLE_UPGRADE_TOOLTIP_BTNTITLE_KEY;
extern NSString * const NONELIGIBLE_UPGRADE_TOOLTIP_MAP;
extern NSString * const NONELIGIBLE_UPGRADE_TOOLTIP_MSG1_KEY;
extern NSString * const NONELIGIBLE_UPGRADE_TOOLTIP_MSG2_KEY;
extern NSString * const NONELIGIBLE_UPGRADE_TOOLTIP_MSG3_KEY;
extern NSString * const NONELIGIBLE_UPGRADE_TOOLTIP_TITLE_KEY;
extern NSString * const NONELIGIBLE_UPGRADE_TOOLTIP_BTNTITLE_KEY;
extern NSString * const CONTRACT_EXPIRATION_TOOLTIP_MAP;
extern NSString * const CONTRACT_EXPIRATION_TOOLTIP_MSG_KEY;
extern NSString * const CONTRACT_EXPIRATION_TOOLTIP_TITLE_KEY;
extern NSString * const UPGRADE_BUTTON_MAP;
extern NSString * const NOTIFICATION_UPGRADE_ELIGIBILITY;
extern NSString * const EDIT_BUTTON_MAP;
extern NSString * const DEVICE_NICK_NAME;
extern NSString * const LINK_INFO;
extern NSString * const SCRN_SUCCESS_HDG;
extern NSString * const CAMERA_ALERT_MESSAGE_KEY;
extern NSString * const CAMERA_ALERT_TITLE_KEY;
extern NSString * const CAMERA_SETTINGS_MSG;

//DEVICE_IS_UO
extern NSString * const TOOL_T_MAP_UO;
extern NSString * const NON_ELIGI_UPGRADE_UO_TT_MSG1;
extern NSString * const NON_ELIGI_UPGRADE_UO_TY_MSG2;
extern NSString * const NON_ELIGI_UPGRADE_UO_TITLE;
extern NSString * const NON_ELIGI_UPGRADE_UO_BTN_TITLE;
extern NSString * const ELIGI_UPGRADE_TOOL_MSG_UO;
extern NSString * const ELIGI_UPGRADE_TOOL_HD_MSG_UO_TITLE;
extern NSString * const ELIGI_UPD_DT_TOOL_MAP_UO_BTN_TITLE;

//PaperFree Billing
extern NSString * const AUTO_ENROLL_DATE_MESSAGE;
extern NSString * const PAPERFREE_STATIC_TEXT;
extern NSString * const CLICK_HERE;
extern NSString * const MY_VERIZON_HOMEPAGE;
extern NSString * const MY_VERIZON_HOMEPAGE_CAMELCASE;
extern NSString * const OPT_OUTOF_PAPER_FREE_BILLING;
extern NSString * const PAPER_BILL_OPTOUT_STATICTEXT;
extern NSString * const PAPER_BILL_OPTOUT_STATICTEXT2;
extern NSString * const PAPER_BILL_FIRSTNAME_LASTNAME;
extern NSString * const PAPER_BILL_ADDRESS;
extern NSString * const PAPER_BILL_CITYSTATEZIP;

//Customer Support
extern NSString * const FIND_HELP_NOW_STR;
extern NSString * const FIND_HELP_GHOST_TEXT;
extern NSString * const SEARCH_SUPPORT;
extern NSString * const TOP_SUPPORT_QUESTION_STR;
extern NSString * const VIEW_ALL;
extern NSString * const VERIZON_COMMUNITY_TEXT;
extern NSString * const VERIZON_COMMUNITY_SUB_TEXT;
extern NSString * const VISIT_THE_COMMUNITY;
extern NSString * const CUSTOMER_SERVICE_VO;
extern NSString * const TALK_SOMEONE_MSG;
extern NSString * const TALK_SOMEONE_SUB_MSG;
extern NSString * const CUSTOMER_SERVICE_MSG;
extern NSString * const MOBILE_NUMBER_VO;
extern NSString * const NUMBER;
extern NSString * const CUSTOMER_SERVICE_DIAL_MSG;
extern NSString * const CUSTOMER_SERVICE_NUMBER_MSG;
extern NSString * const CUSTOMER_SERVICE_FROM_MSG;
extern NSString * const CUSTOMER_SERVICE_TIME_MSG;
extern NSString * const CUSTOMER_SERVICE_EMERGENCY_SERVICE_MSG;
extern NSString * const CUSTOMER_SERVICE_EMERGENCY_SERVICE_TIME_MSG;
extern NSString * const SUPPORT_BUTTON_MAP;
extern NSString * const SEARCH_SUPPORT_KEY;
extern NSString * const VIEW_ALL_KEY;
extern NSString * const VISIT_THE_COMMUNITY_KEY;
extern NSString * const SUPPORT_QUESTIONS_MAP;

//Shop
extern NSString * const SHOP_DEVICE_TEXT_MSG;
extern NSString * const UPGRADE_YOUR_DEVICES;
extern NSString * const ADD_A_DEVICE;
extern NSString * const PURCHASE_ACCESSORIES;
extern NSString * const WORKSHOPS_APPOINTMENTS;
extern NSString * const APPOINTMENT_WORKSHOP_VO;
extern NSString * const APPOINTMENT_WORKSHOP_MSG;
extern NSString * const APPOINTMENT_WORKSHOP_SUB_MSG;
extern NSString * const APPOINTMENT_FIRST_MSG;
extern NSString * const APPOINTMENT_SECOND_MSG;
extern NSString * const APPOINTMENT_THIRD_MSG;
extern NSString * const WORKSHOP_FIRST_MSG;
extern NSString * const WORKSHOP_SECOND_MSG;
extern NSString * const WORKSHOP_THIRD_MSG;
extern NSString * const MORE_MSG;
extern NSString * const MORE_SUB_MSG;
extern NSString * const SHOP_BUTTON_MAP;
extern NSString * const UPGRADE_NOW_KEY;
extern NSString * const ADD_A_DEVICE_KEY;
extern NSString * const PURCHASE_ACCESSORIES_KEY;
extern NSString * const SHOP_WORK_APP_MAP;
extern NSString * const SHOP_WORK_KEY;
extern NSString * const STORE_LOCATOR_MAP;
extern NSString * const STORE_LOCATOR_KEY;
extern NSString * const STORE_VISIT_HISTORY_MAP_KEY;
extern NSString * const MVM_STORE_VISIT_HISTORY;

//ShopFlow
extern NSString * const FLOW_EUP;
extern NSString * const GRIDWALL_CONTENT;
extern NSString * const MTN_DETAILS_LIST;
extern NSString * const UPGRADE_MESSAGE;
extern NSString * const UPGRADE_MESSAGE_HTML;
extern NSString * const UPGRADE_ELIGIBLE;
extern NSString * const PAYMENT_AGREEMENT_TEXT;
extern NSString * const UPGRADE_AVAILABLE_PERCENTAGE;
extern NSString * const LOAN_INFO;
extern NSString * const DEVICE_AGREEMENT_TEXT;
extern NSString * const PAID_AMOUNT_PERCENTAGE;
extern NSString * const AGREEMENT_ID;
extern NSString * const ORIG_DATE;
extern NSString * const AMOUNT_FINANCED;
extern NSString * const REMAINING_PAYMENTS;
extern NSString * const DEVICE_PAY_BALANCE;
extern NSString * const LEGAL_DISCLAIMER;
extern NSString * const LOAN_NUMBER;
extern NSString * const START_DATE;
extern NSString * const LOAN_AMOUNT;
extern NSString * const PENDING_NO_OF_INSTALLMENTS;
extern NSString * const PENDING_LOAN_AMOUNT;
extern NSString * const PAGE_TITLE;
extern NSString * const SELECTED_DEVICE;
extern NSString * const CHANGE_DEVICE;
extern NSString * const KEY_DISPLAY_NAME;
extern NSString * const KEY_MANUFACTURER_DISPLAY_NAME;
extern NSString * const MTN;
extern NSString * const DEVICE_IMAGE;
extern NSString * const TRADE_IN_QUESTION;
extern NSString * const TRADE_IN_QUESTION_ID;
extern NSString * const TRADE_IN_QUESTIONNAIRE;
extern NSString * const SELECTED_TEXT;
extern NSString * const DEVICE_CONDITION;
extern NSString * const ACTIVE_DEVICES_TITLE;
extern NSString * const TRADE_IN_DEVICES;
extern NSString * const DISCONNECTED_DATE;
extern NSString * const GET_DEVICE_DETAILS;
extern NSString * const GRIDWALL_DEVICE_LIST;
extern NSString * const OUTPUT;
extern NSString * const RESULT_LIST;
extern NSString * const REFINEMENT_BOX_LIST;
extern NSString * const NUMBER_OF_REVIEWS;
extern NSString * const STARTS_AT;
extern NSString * const DISPLAY_TEXT;
extern NSString * const CATALOG_HEADER;
extern NSString * const TRADE_IN_LOWERCASE;
extern NSString * const REFINEMENT_BREAD_BOX;
extern NSString * const REFINEMENT_BREAD_BOX_DISPLAY;
extern NSString * const DEVICES;
extern NSString * const DEVICE_ID;
extern NSString * const INACTIVE_DEVICES_TITLE;
extern NSString * const SELECT_THIS_DEVICE;
extern NSString * const ACTIVE_DEVICE;
extern NSString * const ACTIVE_DEVICES;
extern NSString * const INACTIVE_DEVICES;
extern NSString * const LAST_USED;
extern NSString * const CHOOSE_ANOTHER_DEVICE;
extern NSString * const GET_YOUR_TRADE_IN_VALUE;
extern NSString * const PROMO_TITLE;
extern NSString * const DEVICE_TO_TRADE_IN;
extern NSString * const QUESTION_ANSWER;
extern NSString * const QUESTION_YES;
extern NSString * const QUESTION_NO;
extern NSString * const SEE_ALL_SMARTPHONES;
extern NSString * const SORT_BY;
extern NSString * const SORT_BYTEXT;
extern NSString * const SELECTION_FLAG;
extern NSString * const TRADEIN_CREDIT_TEXT;
extern NSString * const TRADEIN_CREDIT;
extern NSString * const APPLY_FILTERS;
extern NSString * const SELECTED_MTN;
extern NSString * const CANCEL_KEY_UPPERCASE;
extern NSString * const THIS_DEVICE;
extern NSString * const OFFERED_DEVICES;
extern NSString * const PROMOS;
extern NSString * const GET_IT_NOW;
extern NSString * const APPRAISAL_VALUE;
extern NSString * const ACCEPT_COMPLETE_TRADE_IN;
extern NSString * const NO_THANKS_SKIP_TRADE_IN;
extern NSString * const PLEASE_NOTE_TEXT_1;
extern NSString * const PLEASE_NOTE_TEXT_2;
extern NSString * const TRADE_IN_PRICE;
extern NSString * const MODEL_ID;
extern NSString * const SELECTED_TRADE_IN_MTN;
extern NSString * const SELECTED_DEVICE_ID;
extern NSString * const REFINEMENTS;
extern NSString * const REFINEMENT_NAME;
extern NSString * const COLOR_UPPERCASE;
extern NSString * const COLOR_STYLE;
extern NSString * const NAVIGATION_STATE;
extern NSString * const REFINEMENT_OPTIONS;
extern NSString * const DIMENSION_COLOR;
extern NSString * const DIMENSION_NAME;
extern NSString * const REFINEMENT_COUNT;
extern NSString * const LABEL;
extern NSString * const KEY_DEVICE_DETAILS_RESPONSE;
extern NSString * const KEY_PRODUCT_DETAILS;
extern NSString * const KEY_SKU_DETAILS;
extern NSString * const KEY_CTA_DISABLED;
extern NSString * const KEY_CTA_CONTINUE_TITLE;
extern NSString * const KEY_SHIPPING_MESSAGE;
extern NSString * const KEY_SHIPPING_DATE;
extern NSString * const KEY_OUT_OF_ORDER;
extern NSString * const KEY_COLOR_CODE;
extern NSString * const KEY_COLOR_NAME;
extern NSString * const KEY_CAPACITY;
extern NSString * const KEY_TECHNICAL_SPECIFICATIONS;
extern NSString * const KEY_TECH_SPECS_DETAILS;
extern NSString * const KEY_DEVICE_CONTRACT_PRICE;
extern NSString * const KEY_CONTRACT_PRICE;
extern NSString * const KEY_CONTRACT_TERM;
extern NSString * const KEY_CONTRACT_DETAILS;
extern NSString * const KEY_CONTRACT_DESCRIPTION;
extern NSString * const KEY_DISCOUNT_TEXT;
extern NSString * const KEY_BADGE_EDGE_DISPLAY_NAME;
extern NSString * const KEY_CONTRACT_NAME;
extern NSString * const KEY_DEVICE_SKU_ID;
extern NSString * const KEY_IMAGE_URL;
extern NSString * const UPPERCASE_IMAGE_URL;
extern NSString * const KEY_IMAGE_URL_SET;
extern NSString * const KEY_DETAILED_TEXT;
extern NSString * const KEY_IMAGE_OR_VIDEO_URL;
extern NSString * const KEY_AVERAGE_RATING;
extern NSString * const KEY_NUMBER_OF_REVIEWS;
extern NSString * const KEY_REVIEWS;
extern NSString * const KEY_TRADE_IN_CREDIT;
extern NSString * const KEY_TRADE_IN_TEXT;
extern NSString * const KEY_FEATURES;
extern NSString * const KEY_CONTRACT_TERM_SELECTED;
extern NSString * const KEY_REVIEWS_ONLY;
extern NSString * const KEY_REVIEWS_PAGE;
extern NSString * const SELECTION_QUERY_LIST;
extern NSString * const CLEAR_FILTER;
extern NSString * const FILTER_HEADER_TEXT;
extern NSString * const KEY_REQ_DEVICE_SOR_ID;
extern NSString * const KEY_DEVICE_SOR_ID;
extern NSString * const KEY_DEVICE_PROTECTION_FEATURES;
extern NSString * const KEY_FEATURE_PRODUCTS;
extern NSString * const KEY_FEATURE_LIST;
extern NSString * const KEY_FEATURE_SECTION_TITLE;
extern NSString * const KEY_FEATURE_SECTION_SUBTITLE;
extern NSString * const KEY_PRESELECTED;
extern NSString * const KEY_PRICE_TERM;
extern NSString * const KEY_PRICE;
extern NSString * const KEY_DESC_TEXT;
extern NSString * const KEY_DECLINED_ALERT_TEXT;
extern NSString * const KEY_PAYMENT_OPTION_TITLE;
extern NSString * const REMOVE_ALL_FILTERS_TEXT;
extern NSString * const ORDER_DETAILS;
extern NSString * const SHIPPING_INFO;
extern NSString * const DEVICE_CONFIG_INFO;
extern NSString * const TERMS_AND_CONDITIONS_INFO;
extern NSString * const SHIPPING_INFO_HT;
extern NSString * const PAYMENT_INFO_LBL;
extern NSString * const ADDITIONAL_DEVICE_INFO_LBL;
extern NSString * const ACCEPT_TC_INFO_LBL;
extern NSString * const COMPLETE_YOUR_ORDER_LBL;
extern NSString * const SHIPPING_ADDRESS_CAPS_LBL;
extern NSString * const CONTACT_INFO_LBL;
extern NSString * const BILLING_DETAILS_INFO;
extern NSString * const BILLING_ADDRESS_KEY;
extern NSString * const PAYMENT_INFO_CAPS_LBL;
extern NSString * const KEY_QUANTITY;
extern NSString * const KEY_FEATURE_SOR_ID;
extern NSString * const KEY_REQ_FEATURE_SOR_ID;
extern NSString * const KEY_FEATURE_SKU_ID;
extern NSString * const KEY_REQ_FEATURE_SKU_ID;
extern NSString * const KEY_FEATURE_TYPE;
extern NSString * const KEY_EXISTING_FEATURE;
extern NSString * const KEY_CART_DETAILS;
extern NSString * const KEY_COST_DETAILS;
extern NSString * const KEY_TOTAL_DUE_TODAY;
extern NSString * const KEY_TOTAL_DUE_MONTHLY;
extern NSString * const KEY_CREDIT;
extern NSString * const KEY_COST_DETAIL_BREAKUP;
extern NSString * const KEY_COST_SUBTOTAL;
extern NSString * const KEY_COST_TOTAL;
extern NSString * const KEY_TAXES;
extern NSString * const KEY_TAXES_BREAKUP;
extern NSString * const KEY_DEVICE_DISPLAY_NAME;
extern NSString * const KEY_SHOP_CART_EMPTY;
extern NSString * const KEY_CART_ITEM_ACTION;
extern NSString * const KEY_DISCLAIMERS;
extern NSString * const KEY_ADDITIONAL_DISCLAIMERS;
extern NSString * const KEY_PROMOTION_TEXT;
extern NSString * const KEY_PREFIX_TERM;
extern NSString * const KEY_BADGES_FOR_CONTRACT_TERM;
extern NSString * const KEY_BADGE_DISPLAY;
extern NSString * const KEY_BADGE_CLICKABLE;
extern NSString * const KEY_BADGE_TOOL_TIP;
extern NSString * const CHOOSE_SHIPPING_OPTIONS_HT;
extern NSString * const DELIVERY_DESC_LBL;
extern NSString * const TWO_BUSSINESS_DAYS_DESC;
extern NSString * const DEVICE_E911_SERV_ADDR;
extern NSString * const SERVICE_ADDRESS;
extern NSString * const TNC_TEXTS;
extern NSString * const ACCEPT_REVIEW_YOUR_ORDER;
extern NSString * const READ_OUR_FULL_PRIVACY_POLICY;
extern NSString * const PRIVACY_POLICY_DESC;
extern NSString * const THANKS_FOR_YOUR_PURCHASE_LBL;
extern NSString * const DEVICECHANGE_VARIFY_ORDER_LBL;
extern NSString * const TRACK_YOUR_ORDER;
extern NSString * const YOUR_NEXT_STEPS_LBL;
extern NSString * const TRANSFER_PHONE_NR_LGL;
extern NSString * const KEY_DEVICE_IMAGE_URL;
extern NSString * const DUE_TODAY_LBL;
extern NSString * const DUE_MONTHLY;
extern NSString * const ITEMS_LBL;
extern NSString * const SHIPPING_TAX_FEE_LBL;
extern NSString * const PLACE_YOUR_ORDER;
extern NSString * const ACCEPT_TC_CONTINUE_WARN_LBL;
extern NSString * const RETAIL_INSTALLMENT_SALES_AGREEMENT;
extern NSString * const BACK_TO_CART;
extern NSString * const REVIEW_YOUR_ORDER_HT;
extern NSString * const SHIPPING_COSTS;
extern NSString * const TOTAL_LBL;
extern NSString * const SHIPPING_ADDRESS;
extern NSString * const CONTACT_INFORMATION;
extern NSString * const PAYMENT_INFORMATION;
extern NSString * const LINE_ITEMS;
extern NSString * const SELECTED_MTN_LOWERCASE_TN;
extern NSString * const TRADE_IN_CR_DESC;
extern NSString * const EXPIRATION_MONTHS;
extern NSString * const EXPIRATION_YEARS;
extern NSString * const NICKNAME_LOWERCASE;
extern NSString * const RETURN_PRIVACY_POLICY_DESC_LBL;
extern NSString * const UPGRADE_PLAN_DESC;
extern NSString * const CONTENTS_TRANSFER_DESC;
extern NSString * const NEXT_BILL_DESC;
extern NSString * const EMAIL_CONFIRMATION_DESC;
extern NSString * const CREDIT_CARD_TYPE;
extern NSString * const CHECKOUT_ORDER_DETAILS;
extern NSString * const CLIENT_ORDER_REFERENCE_NUMBER;
extern NSString * const UPGRADE_YOUR_PLAN_NOW;
extern NSString * const LEARN_HOW;
extern NSString * const READ_THE_FAQ;
extern NSString * const CHECKOUT_PAYMENT_INFORMATION;
extern NSString * const CHECKOUT_BILLING_ADDRESS;
extern NSString * const SUB_LABEL;
extern NSString * const UPGRADE_ELIGIBILITY;

// My Account

extern NSString * const LAST_PMT_MAP;
extern NSString * const PAST_DUE_AMT;
extern NSString * const PMT_MSG_OR_NAME_HDG;
extern NSString * const LAST_PMT_MADE_MSG;
extern NSString * const LAST_PMT_DATE;
extern NSString * const LAST_PMT_AMT_OF_MSG;
extern NSString * const LAST_PMT_AMT;
extern NSString * const PAST_DUE_AMT_MSG;
extern NSString * const PAST_DUE_MSG_AMT;
extern NSString * const PAST_DUE_AMT_DUE_MSG;

//Purchase History
extern NSString * const PURCHASE_HIST_RES_VO;
extern NSString * const CONTACT_INFO_KEY;
extern NSString * const PURCHASE_DATE_LIST_KEY;
extern NSString * const CONTACT_INFO_MDN_KEY;
extern NSString * const CONTACT_INFO_MAILID_KEY;
extern NSString * const PURCHASE_DATE_TIME_KEY;
extern NSString * const PURCHASE_DATE_KEY;
extern NSString * const ORDER_NUMBER_KEY;
extern NSString * const ITEM_LIST_KEY;
extern NSString * const STORE_ADDRESS_KEY;

//Product Scan History
extern NSString * const PRODUCT_SCAN_HIST_RES_VO;
extern NSString * const SCAN_PRODUCT_LIST_KEY;
extern NSString * const SCAN_PROD_LIST;
#pragma mark - Checkout JSON Keys

//Device Trade-In Quote
extern NSString * const DEVICE_TRADE_IN_QUOTES_RES_VO;
extern NSString * const QUOTE_PRODUCT_LIST;
extern NSString * const QUOTE_PROD_LIST;
/* Start Of Constants added by Ishwar for Lower Funnel */

// Lower Funnel
extern NSString * const AGREEMENT_TEXTS_ARRAY;
extern NSString * const SCREEN_HEADING_TEXT;
extern NSString * const HIP_BLOCK_HEADER_TEXT;
extern NSString * const SHIP_ADDRESS_HEADER_TEXT;

extern NSString * const CONTACT_INFO_HEADER_TEXT;

// Shipping options info
extern NSString * const EDIT_CHECKOUT_ALERT_WARNING_MSG;
extern NSString * const EDIT_CHECKOUT_ALERT_ERROR_MSG;
extern NSString * const EDIT_SHIPPING_ADDRESS_FLAG;
extern NSString * const CTA_ENABLE_FLAG;
extern NSString * const SHIPPING_TYPES_INFO;
extern NSString * const ACTIVE;
extern NSString * const SHORT_DESCRIPTION;
extern NSString * const SHIPPING_DESCRIPTION;
extern NSString * const SHIPPING_COST_DISP;
extern NSString * const SHIPPING_OPTION_ID;
extern NSString * const ADDED_SHIPPINGOPTION_ID;
extern NSString * const ESTIMATED_DELIVERY_DATE;

// Shipping --> Payment Information
extern NSString * const EDIT_BILLING_ADDRESS_FLAG;
extern NSString * const EDIT_PAYMENT_INFO_FLAG;
extern NSString * const PAYMENT_BLOCK_HEADER_TEXT;
extern NSString * const PAYMENT_INFO;
extern NSString * const SAVED_CARD_INFO;

extern NSString * const BTA;
extern NSString * const BILL_TO_ACCOUNT_NUMBER;

extern NSString * const SELECTED_PAYMENT_MODE;
extern NSString * const SELECTED_PAYMENT_TYPE;
extern NSString * const SAVE_CARD_TO_ACCOUNT;
extern NSString * const BTA_LOWERCASE;
extern NSString * const SAVED_CARD;
extern NSString * const SAVED_CARD_NUMBER;

extern NSString * const NEW_CARD;
extern NSString * const NEW_CARD_NUMBER;

extern NSString * const BILLING_INFO_TEXT;
extern NSString * const BILLING_ADDRESSS_TEXT;

// Shipping -->  Additional Device Information
extern NSString * const EDIT_DEVICE_ADDRESS_FLAG;
extern NSString * const ADDITIONAL_INFO_BLOCK_HEADER_TEXT;
extern NSString * const DEVICE_SERVICE_ADDRESS;
extern NSString * const FLOW;
extern NSString * const MTN_NUMBER;
extern NSString * const E911_SERVICE_ADDRESS;

// Shipping -->  Terms & Conditions Section
extern NSString * const TERMS_CONDITIONS_HEADER_TEXT;

// Accept & Review Your Order Screen
extern NSString * const ACCEPT_AND_REVIEW;

/* End Of Constants added by Ishwar for Lower Funnel */

//Smart Rewards
extern NSString * const REWARDS_BALANCE_MSG1;
extern NSString * const REWARDS_BALANCE_MSG2;
extern NSString * const FEATURE_BENEFITS1;
extern NSString * const FEATURE_BENEFITS1_DESCRIPTION;
extern NSString * const FEATURE_BENEFITS2;
extern NSString * const FEATURE_BENEFITS2_DESCRIPTION;
extern NSString * const EARN_POINTS_HDG;
extern NSString * const EARN_POINTS_MSG;
extern NSString * const REDEEM_POINTS_HDG;
extern NSString * const REDEEM_POINTS_MSG;

//Manage Privacy
extern NSString * const PRIVACY_SCRN_MSG_HDG;
extern NSString * const PRIVACY_WHAT_MEANS_MSG;
extern NSString * const PRIVACY_CAN_SHARE_MSG;
extern NSString * const CUSTOMER_PROP_NTWK_INFO;
extern NSString * const CUSTOMER_BUSINESS_MRKT_INFO;
extern NSString * const RMA_PRIVACY_INFO;
extern NSString * const PRIVACY_MDN_INFO;
extern NSString * const PRIVACY_CPNI_INDICATOR;
extern NSString * const PRIVACY_BUSINESS_INDICATOR;
extern NSString * const PRIVACY_RMA_INDICATOR;
extern NSString * const PRIVACY_SETTING;
extern NSString * const PRIVACY_SUCCESS_MSG1;
extern NSString * const PRIVACY_SUCCESS_MSG2;
extern NSString * const PRIVACY_TRANS_ERROR1;
extern NSString * const PRIVACY_TRANS_ERROR2;

//Verizon Select Preferneces
extern NSString * const VSP_PARTICIPATION_STATUS;
extern NSString * const VSP_PARTICIPATION_AGREEMENT;
extern NSString * const VSP_BLOCKING_LINES_FROM_PARTICIPATION;
extern NSString * const VSP_DELETE_PAST_MOBILE_USAGE_DATA;
extern NSString * const VSP_MCM_SETTINGS_VO;
extern NSString * const VSP_MCM_SETTING_LIST;
extern NSString * const VSP_MCM_SELECT_MSG;
extern NSString * const VSP_MCM_DESCRIPTION_MSG;
extern NSString * const VSP_DELETE_WEB_BROWSER_BTN_MSG;
extern NSString * const VSP_PARTICIPATION_AGREEMENT_MSG1;
extern NSString * const VSP_PARTICIPATION_AGREEMENT_MSG2;
extern NSString * const VSP_POPUP_HDG;
extern NSString * const VSP_POPUP_SCRN_CONTENT;
extern NSString * const VSP_BLOCK_MSG;
extern NSString * const VSP_DELETE_WEB_BROWSER_MSG;
extern NSString * const PromosInfo;

//Data Gifts
extern NSString * const DATAGIFT_RETRIEVE_KEY;
extern NSString * const DATAGIFT_REDEEM_KEY;
extern NSString * const DATAGIFT_SENDERTAG_KEY;
extern NSString * const DATAGIFT_AMOUNTTAG_KEY;
extern NSString * const DATAGIFT_RECEIVEDTAG_KEY;
extern NSString * const DATAGIFT_STATUSTAG_KEY;
extern NSString * const DATAGIFT_STATUS_REDEEM_KEY;
extern NSString * const DATAGIFT_STATUS_REDEEMED_KEY;
extern NSString * const DATAGIFT_ALL_TXT_KEY;
extern NSString * const DATAGIFT_REDEEMED_TXT_KEY;
extern NSString * const DATAGIFT_UNREDEEMED_TXT_KEY;
extern NSString * const DATAGIFT_TOTALDATA_TXT_KEY;
extern NSString * const DATAGIFT_PAGE_TITLE_KEY;
extern NSString * const DATAGIFT_CONFIRM_TXT_KEY;
extern NSString * const DATAGIFT_TOTAL_GIFTDATA;
extern NSString * const DATAGIFTS;
extern NSString * const DATAGIFT_SCRN_MSG_MAP;
extern NSString * const DATAGIFT_STATUS_KEY;
extern NSString * const DATAGIFT_SENDER_KEY;
extern NSString * const DATAGIFT_UNIT_KEY;
extern NSString * const DATAGIFT_RECEIVEDDATE_KEY;
extern NSString * const TUTORIAL_FINISHED;
extern NSString * const DATAGIFT_BALANCE_KEY;
extern NSString * const DATAGIFT_REDEEMED_KEY;
extern NSString * const DATAGIFT_UNREDEEMED_KEY;
extern NSString * const DATAGIFT_TERMS;
extern NSString * const DATAGIFT_FULFILLMENTID_KEY;
extern NSString * const DATAGIFT_AMOUNT_KEY;
extern NSString * const DATAGIFT_RECEIPIENTMDN_KEY;
extern NSString * const DATAGIFT_SUCCESS_REDEEMED_TXT_KEY;
#pragma mark - JSON Values

extern NSString * const HOME_PAGE_USG_DAYS_MSG;
extern NSString * const HOME_PAGE_USG_REMINING_DAYS;
extern NSString * const HOME_PAGE_USG_DAY_LFT_MSG;
extern NSString * const HOME_PAGE_USG_DAY_ENDS_ON_MSG;
extern NSString * const HOME_PAGE_USG_BILL_CYCLE_END_DATE;

extern NSString * const OPTION_TYPE_MINUTES;
extern NSString * const OPTION_TYPE_MESSEGAS;
extern NSString * const OPTION_TYPE_DATA;
extern NSString * const OPTION_TYPE_HOTSPOT;

extern  NSString * const STR_BLOCK;
extern NSString * const STR_TRUE ;
extern NSString * const STR_FALSE ;
extern NSString * const STR_T;
extern NSString * const STR_F ;
extern NSString * const STR_Y ;
extern NSString * const STR_N ;
extern NSString * const STR_1 ;
extern NSString * const STR_0 ;
extern NSString * const STR_ ;
extern NSString * const STR_ON ;
extern NSString * const STR_OFF ;

extern NSString * const STR_UNLMTD;

extern NSString * const STR_S;
extern NSString * const STR_B;

extern NSString * const REGISTER;

extern NSString * const EDIT;

#pragma mark - pageTypes

extern NSString * const PAGE_TYPE_LAUNCHAPP;
extern NSString * const PAGE_TYPE_ACCOUNTSUMMARY;
extern NSString * const PAGE_TYPE_DEVICE_LANDING;
extern NSString * const PAGE_TYPE_DEVICE_DISMISSED_NOTIFICATIONS;
extern NSString * const PAGE_TYPE_PROFILE_LANDING;
extern NSString * const PAGE_TYPE_SUPPORT_LANDING;
extern NSString * const PAGE_TYPE_SHOP_LANDING;
extern NSString * const PAGE_TYPE_MAIN_TABLE;
extern NSString * const PAGE_TYPE_DATA_METER;
extern NSString * const PAGE_TYPE_ACCOUNTOVERVIEW;
extern NSString * const PAGE_TYPE_USAGESELECTION;
extern NSString * const PAGE_TYPE_USAGEOVERVIEW;
extern NSString * const PAGE_TYPE_USAGEOVERVIEW_LOWER;
extern NSString * const PAGE_TYPE_USAGEDETAILS;
extern NSString * const PAGE_TYPE_BILL_INFO;
extern NSString * const PAGE_TYPE_PLAN_INFO;
extern NSString * const PAGE_TYPE_PROFILE_INFO_SUCCESS;
extern NSString * const PAGE_TYPE_ALL_USAGE_DETAILS;
extern NSString * const PAGE_TYPE_MINUTE_DETAILS;
extern NSString * const PAGE_TYPE_MESSAGE_DETAILS;
extern NSString * const PAGE_TYPE_DATA_DETAILS;
extern NSString * const PAGE_TYPE_HOTSPOT_DETAILS;
extern NSString * const PAGE_TYPE_USAGE_DETAILS_SUMMARY;
extern NSString * const PAGE_TYPE_VALIDATE_USER_NAME;
extern NSString * const PAGE_TYPE_VALIDATE_MDN_INFO;
extern NSString * const PAGE_TYPE_WIFI_ENTER_MDN;
extern NSString * const PAGE_TYPE_WIFI_SIGN_IN;
extern NSString * const PAGE_TYPE_OAAM_CHALLENGE_QUESTION;
extern NSString * const PAGE_TYPE_WIFI_CHALLENGE_QUESTION;
extern NSString * const PAGE_TYPE_OAAM_ENTER_PASSWORD;
extern NSString * const PAGE_TYPE_WIFI_ENTER_PASSWORD;
extern NSString * const PAGE_TYPE_BILLING_PASSWORD;
extern NSString * const PAGE_TYPE_BILLING_ZIP;
extern NSString * const PAGE_TYPE_SSN;
extern NSString * const PAGE_TYPE_LAUNCH_ROLE_INTERCEPT;
extern NSString * const PAGE_TYPE_LOGIN;
extern NSString * const PAGE_TYPE_EXTRA_OPT;
extern NSString * const PAGE_TYPE_PROFILE_PILLAR_OPTS;
extern NSString * const PAGE_TYPE_MY_PROFILE_DETAILS;
extern NSString * const PAGE_TYPE_PROFILE_PILLER_DETAILS;
extern NSString * const PAGE_TYPE_GET_CUST_PROP_NTW_INFO;
extern NSString * const PAGE_TYPE_GET_BUSINESS_MRKT_INFO;
extern NSString * const PAGE_TYPE_GET_RMA_PRVC_INFO;
extern NSString * const PAGE_TYPE_PRIVACY_NETWORK_SETTING_SAVE_CHANGE;
extern NSString * const PAGE_TYPE_PRIVACY_SETTING_SAVE_CHANGE;
extern NSString * const PAGE_TYPE_PRIVACY_RMA_SETTING_SAVE_CHANGE;
extern NSString * const PAGE_TYPE_MODIFY_PASSWORD;
extern NSString * const PAGE_TYPE_MODIFY_PASSWORD_CONFIRMATION;
extern NSString * const PAGE_TYPE_EDIT_EMAIL_ADDRESS;
extern NSString * const PAGE_TYPE_PROFILE_EDIT_EMAIL;
extern NSString * const PAGE_TYPE_PROFILE_EDIT_EMAIL_SUCCESS;
extern NSString * const PAGE_TYPE_SAVE_EMAIL_ADDRESS;
extern NSString * const PAGE_TYPE_CHANGE_USER_ID;
extern NSString * const PAGE_TYPE_SAVE_USER_ID;
extern NSString * const PAGE_TYPE_PROFILE_EDIT_USER_ID;
extern NSString * const PAGE_TYPE_PROFILE_EDIT_USER_ID_SUCCESS;
extern NSString * const PAGE_TYPE_PROFILE_EDIT_USER_ID_ERROR;
extern NSString * const PAGE_TYPE_PROFILE_CHANGE_SECRET_Q;
extern NSString * const PAGE_TYPE_CHANGE_SECRET_Q;
extern NSString * const PAGE_TYPE_SECRET_QUESTION;
extern NSString * const PAGE_TYPE_PROFILE_CHANGE_SECRET_QUESTION_SUBMIT;
extern NSString * const PAGE_TYPE_PROFILE_CHANGE_SECRET_Q_SUCCESS;
extern NSString * const PAGE_TYPE_AM_INTERCEPT_SET_SECRET_QUESTION;
extern NSString * const PAGE_TYPE_CHANGE_ADDR;
extern NSString * const PAGE_TYPE_CHANGEADDR;
extern NSString * const PAGE_TYPE_PROFILE_ADDR_DISPLAY;
extern NSString * const PAGE_TYPE_SUBMIT_ADDRESS_CHANGE;
extern NSString * const PAGE_TYPE_PROFILE_ADDR_UPDATE;
extern NSString * const PAGE_TYPE_MANAGE_PWD;
extern NSString * const PAGE_TYPE_MANAGEPWD;
extern NSString * const PAGE_TYPE_EDIT_PASSWORD;
extern NSString * const PAGE_TYPE_NETWORK_PROGRAMS_PERMISSIONS;
extern NSString * const PAGE_TYPE_UPDATE_NETWORK_PROGRAMS_PERMISSIONS;
extern NSString * const PAGE_TYPE_RETRIEVE_APP_PRIVACY_PROFILE;
extern NSString * const PAGE_TYPE_PRIVACY_MANAGER;
extern NSString * const PAGE_TYPE_MNG_PRIVACY_SETTING;
extern NSString * const PAGE_TYPE_MNG_PRIVACY_SETTING_INFO_PAGE;
extern NSString * const PAGE_TYPE_STORE_LOCATOR;
extern NSString * const PAGE_TYPE_FIND_STORE;
extern NSString * const PAGE_TYPE_ZIP_STR_SRCH;
extern NSString * const PAGE_TYPE_STORE_DETAILS;
extern NSString * const PAGE_TYPE_MAP_URL;
extern NSString * const PAGE_TYPE_NEAREST_STORE;
extern NSString * const PAGE_TYPE_WS_AP_PAGE;
extern NSString * const PAGE_TYPE_ST_VISIT_HISTORY_AP_PAGE;
extern NSString * const PAGE_TYPE_PURCHASE_HISTORY_PAGE;
extern NSString * const PAGE_TYPE_PRODUCT_SCAN_HISTORY_PAGE;
extern NSString * const PAGE_TYPE_DEVICE_TRADE_IN_QUOTE_PAGE;
extern NSString * const PAGE_TYPE_SEARCH_OPTION;
extern NSString * const PAGE_TYPE_WS_APP_SEARCH;
extern NSString * const PAGE_TYPE_WS_AP_FULL;
extern NSString * const PAGE_TYPE_WS_AP_SEARCH_LOC;
extern NSString * const PAGE_TYPE_WS_APP_REGISTRATION;
extern NSString * const PAGE_TYPE_FRIEND_LEVEL_ACTIVATION_SUCCESS;
extern NSString * const PAGE_TYPE_ELIGIBLE_LINES;
extern NSString * const PAGE_TYPE_FRIENDS_FAMILY_HISTORY;
extern NSString * const PAGE_TYPE_TOPIC;
extern NSString * const PAGE_TYPE_SUB_TOPIC;
extern NSString * const PAGE_TYPE_QUESTION;
extern NSString * const PAGE_TYPE_ANSWERS;
extern NSString * const PAGE_TYPE_VERIZON_SELECTS_PREFERENCES;
extern NSString * const PAGE_TYPE_MULTI_CHANNEL_MARKETING;
extern NSString * const PAGE_TYPE_PARTICIPATION_AGREEMENT;
extern NSString * const PAGE_TYPE_PARTICIPATION_AGREEMENT_YES;
extern NSString * const PAGE_TYPE_PARTICIPATION_STATUS;
extern NSString * const PAGE_TYPE_OPT_IN_SETTINGS;
extern NSString * const PAGE_TYPE_VERIZON_SELECTS_CONFIRM;
extern NSString * const PAGE_TYPE_BLOCKING_LINES_FROM_PARTICIPATION;
extern NSString * const PAGE_TYPE_BLOCK_SETTINGS;
extern NSString * const PAGE_TYPE_BLOCK_SETTING_SAVE_CHANGE;
extern NSString * const PAGE_TYPE_SELECTS_PREFERENCES;
extern NSString * const PAGE_TYPE_DELETE_PAST_MOBILE_USAGE_DATA;
extern NSString * const PAGE_TYPE_DELETE_DATA;
extern NSString * const PAGE_TYPE_DELETE_DATA_SAVE_CHANGE;
extern NSString * const PAGE_TYPE_MARKETING_CONTACTS;
extern NSString * const PAGE_TYPE_MARKETING_CONTACTS_SAVE_CHANGE;
extern NSString * const PAGE_TYPE_USAGE_ALERTS_REQUEST;
extern NSString * const PAGE_TYPE_USAGE_ALERTS_RESPONSE;
extern NSString * const PAGE_TYPE_RECOMMENDED;
extern NSString * const PAGE_TYPE_POPUP;
extern NSString * const PAGE_TYPE_SAVE_THRESHOLD;
extern NSString * const PAGE_TYPE_USAGE_SEND_ALERT;
extern NSString * const PAGE_TYPE_ACCOUNT_DETAIL;
extern NSString * const PAGE_TYPE_PROFILE_DETAIL;
extern NSString * const PAGE_TYPE_BILLING_ZIPCODE;
extern NSString * const PAGE_TYPE_WIFI_SEND_TEMP_PW;
extern NSString * const PAGE_TYPE_OAAM_SEND_TEMP_PW;
extern NSString * const PAGE_TYPE_TEMPORARY_PASSWORD_SENT;
extern NSString * const PAGE_TYPE_TEMPORARY_PASSWORD_SELECT_RESET_OPTION;
extern NSString * const PAGE_TYPE_TEMPORARY_PASSWORD_SELECT_RESET_OPTION_2;
extern NSString * const PAGE_TYPE_INTERCEPT_CHANGE_SECRET_QUESTION;
extern NSString * const PAGE_TYPE_WIFI_FORGOT_PASSWORD;
extern NSString * const PAGE_TYPE_FORGOT_PASSWORD;
extern NSString * const PAGE_TYPE_FORGOT_PASSWORD_SECRET_QUESTION;
extern NSString * const PAGE_TYPE_FORGOT_PASSWORD_RESET_PASSWORD;
extern NSString * const PAGE_TYPE_NEW_PASSWORD;
extern NSString * const PAGE_TYPE_SETUP_SET_PASSWORD;
extern NSString * const PAGE_TYPE_SIGN_OUT;
extern NSString * const PAGE_TYPE_ENTER_USER_NAME;
extern NSString * const PAGE_TYPE_DEVICE_PILLAR;
extern NSString * const PAGE_TYPE_VM_PWD;
extern NSString * const PAGE_TYPE_VM_PWD_NEW;
extern NSString * const PAGE_TYPE_VM_PWD_GENERATE;
extern NSString * const PAGE_TYPE_CALL_FORWARD;
extern NSString * const PAGE_TYPE_CALL_FORWARD_SPACE;
extern NSString * const PAGE_TYPE_CALL_FORWARD_SAVE;
extern NSString * const PAGE_TYPE_SUSPEND_RECONNECT;
extern NSString * const PAGE_TYPE_SUSPEND_OPTIONS;
extern NSString * const PAGE_TYPE_SUSPEND_BILL_OPTIONS;
extern NSString * const PAGE_TYPE_SUSPEND_MILITARY;
extern NSString * const PAGE_TYPE_RECONNECT_DEVICE;
extern NSString * const PAGE_TYPE_CHANGE_PLAN_REQUEST;
extern NSString * const PAGE_TYPE_CHANGE_PLAN_MORE_EVERYTHING;
extern NSString * const PAGE_TYPE_CHANGE_PLAN_LEGACY_ACCOUNT_LEVEL;
extern NSString * const PAGE_TYPE_CHANGE_PLAN_LEGACY_LINE_LEVEL;
extern NSString * const PAGE_TYPE_CHANGE_PLAN_LEGACY_REVIEW;
extern NSString * const PAGE_TYPE_PLAN_SELECTION;
extern NSString * const PAGE_TYPE_LEARN_ABOUT_MORE_EVERYTHING;
extern NSString * const PAGE_TYPE_LAC_OPTIONS;
extern NSString * const PAGE_TYPE_CHANGE_PLAN_REVIEW;
extern NSString * const PAGE_TYPE_MORE_EVERYTHING_REVIEW;
extern NSString * const PAGE_TYPE_CHANGE_PLAN_CONFIRM;
extern NSString * const PAGE_TYPE_PLAN_CHANGE_SUCCESS;
extern NSString * const PAGE_TYPE_ONE_CLICK_UPGRADE;
extern NSString * const PAGE_TYPE_CHANGE_PLAN_INTL_GLOBAL_REQUEST;
extern NSString * const PAGE_TYPE_CHANGE_PLAN_INTL_GLOBAL;
extern NSString * const PAGE_TYPE_CHANGE_PLAN_INTL_GLOBAL_EFFECTIVE_DATE_REQUEST;
extern NSString * const PAGE_TYPE_CHANGE_PLAN_INTL_GLOBAL_EFFECTIVE_DATE;
extern NSString * const PAGE_TYPE_CHANGE_PLAN_INTL_GLOBAL_REVIEW_REQUEST;
extern NSString * const PAGE_TYPE_CHANGE_PLAN_INTL_GLOBAL_REVIEW;
extern NSString * const PAGE_TYPE_CHANGE_PLAN_INTL_GLOBAL_CONFIRM_REQUEST;
extern NSString * const PAGE_TYPE_CHANGE_PLAN_INTL_GLOBAL_CONFIRM;
extern NSString * const PAGE_TYPE_ACCOUNT_LOCKED;
extern NSString * const PAGE_TYPE_LOGIN_LOCK;
extern NSString * const PAGE_TYPE_FRAUD;
extern NSString * const PAGE_TYPE_REGISTER_ENTER_MDN;
extern NSString * const PAGE_TYPE_REGISTER_NOW_RESPONSE;
extern NSString * const PAGE_TYPE_REGISTER_NOW_REQUEST;
extern NSString * const PAGE_TYPE_REGISTER_NOT_REGISTERED;
extern NSString * const PAGE_TYPE_REGISTER_SETUP_REQUEST;
extern NSString * const PAGE_TYPE_REGISTER_SETUP_RESPONSE;
extern NSString * const PAGE_TYPE_REGISTER_ACCEPT_TERMS;
extern NSString * const PAGE_TYPE_REGISTER_TEMP_PASSWORD_SUCCESS;
extern NSString * const PAGE_TYPE_PROMOTIONS;
extern NSString * const PAGE_TYPE_SW_SET_PASSWORD;
extern NSString * const PAGE_TYPE_EMPLOYEE_VALIDATION;
extern NSString * const PAGE_TYPE_DEVICE_NICKNAME;
extern NSString * const PAGE_TYPE_CALL_MSG_BLOCK;
extern NSString * const PAGE_TYPE_UPDATE_DEVICE_NICKNAME;
extern NSString * const PAGE_TYPE_UPGRADE_DEVICE_ELIGIBILITY;
extern NSString * const PAGE_TYPE_SAFEGUARG_SELECT_CALL_MSG_BLCK;
extern NSString * const PAGE_TYPE_SAFEGUARG_SUBMIT_CALL_MSG_BLCK;
extern NSString * const PAGE_TYPE_MANAGE_SAFEGUARD_SINGLES;
extern NSString * const PAGE_TYPE_SAFEGUARDS_SELECT;
extern NSString * const PAGE_TYPE_SAFEGUARDS_REVIEW;
extern NSString * const PAGE_TYPE_SAFEGUARDS_CONFIRM;
extern NSString * const PAGE_TYPE_SAFEGUARDS_MOREINFO;
extern NSString * const PAGE_TYPE_SAFEGUARDS_MANAGE_ROLE;
extern NSString * const PAGE_TYPE_UPDATE_FAMILYBASE_ROLES;
extern NSString * const PAGE_TYPE_USAGE_LIMIT;
extern NSString * const PAGE_TYPE_USAGE_LIMIT_REVIEW;
extern NSString * const PAGE_TYPE_USAGE_LIMIT_CONFIRM;
extern NSString * const PAGE_TYPE_BLOCK_CONTACTS;
extern NSString * const PAGE_TYPE_BLOCK_CONTACTS_CONFIRM;
extern NSString * const PAGE_TYPE_BLOCK_CONTACTS_REVIEW;
extern NSString * const PAGE_TYPE_TIME_RESTRICTION ;
extern NSString * const PAGE_TYPE_TIME_RESTRICTION_CONFIRM ;
extern NSString * const PAGE_TYPE_CALL_MSG_BLOCK_SUCCESSFULL;
extern NSString * const PAGE_TYPE_DISPLAY_AM_INFO;
extern NSString * const PAGE_TYPE_REMOVE_AM_INFO;
extern NSString * const PAGE_TYPE_SUBMIT_ADD_AM_INFO;
extern NSString * const PAGE_TYPE_CHANGE_FEATURE;
extern NSString * const PAGE_TYPE_CHANGE_FEATURE_OPTION;
extern NSString * const PAGE_TYPE_SETUP_BSP;
extern NSString * const PAGE_TYPE_CONFIRM_BSP_SETUP;
extern NSString * const PAGE_TYPE_ORDER_NFC_SIM;
extern NSString * const PAGE_TYPE_VALIDATE_PROFILE_SETUP;
extern NSString * const PAGE_TYPE_CREATE_USER_ID;
extern NSString * const PAGE_TYPE_MANAGE_SHARE_NAME;
extern NSString * const PAGE_TYPE_SUBMIT_SHARE_NAME;
extern NSString * const PAGE_TYPE_SMART_REWARDS;
extern NSString * const PAGE_TYPE_FEATURE_REVIEW;
extern NSString * const PAGE_TYPE_DATA_USAGE_HISTORY;
extern NSString * const PAGE_TYPE_MINUTES_USAGE_HISTORY;
extern NSString * const PAGE_TYPE_MESSAGE_USAGE_HISTORY;
extern NSString * const PAGE_TYPE_RETRIEVE_GLOBAL_READY_LOCATIONS;
extern NSString * const PAGE_TYPE_MANAGE_PRIVACY;
extern NSString * const PAGE_TYPE_UPDATE_PRIVACY;
extern NSString * const PAGE_TYPE_GRC_VERIFY_HARDWARE;
extern NSString * const PAGE_TYPE_VERIFY_GLOBAL_READY_DEVICE;
extern NSString * const PAGE_TYPE_GLOBAL_READY_CHECK;
extern NSString * const PAGE_TYPE_SHOW_GRC_OPTIONS;
extern NSString * const PAGE_TYPE_GRC_VERIFY_ACC_FEATURE;
extern NSString * const PAGE_TYPE_VERIFY_GLOBAL_READY_DEVICE_FEATURE;
extern NSString * const PAGE_TYPE_VERIFY_GLOBAL_READY_INTL_OPTION;
extern NSString * const PAGE_TYPE_INTL_GLOBAL_PAGE_INTL_ALC;
extern NSString * const PAGE_TYPE_CHG_PLAN_CURRENT;
extern NSString * const PAGE_TYPE_INTL_GLOBAL_PAGE_INTL_LLC;
extern NSString * const PAGE_TYPE_RETRIEVE_LOCATION;
extern NSString * const PAGE_TYPE_TRIP_PLANNER;
extern NSString * const PAGE_TYPE_INTL_GLOB_PAGE_GLOB_LLC;
extern NSString * const PAGE_TYPE_BEST;
extern NSString * const PAGE_TYPE_CREATE_OC_SESSION;
extern NSString * const PAGE_TYPE_PAY_BILL;
extern NSString * const PAGE_TYPE_PAYMENT_PTP;
extern NSString * const PAGE_TYPE_PAYMENT_HISTORY;
extern NSString * const PAGE_TYPE_DISPLAYE_BILL_COPY;
extern NSString * const PAGE_TYPE_VALIDATE_SIM_NUMBER_REQUEST;
extern NSString * const PAGE_TYPE_VALIDATE_SIM_NUMBER;
extern NSString * const PAGE_TYPE_VIEW_RECEIPT;
extern NSString * const PAGE_TYPE_VIEW_RECEIPT_PDF;
extern NSString * const PAGE_TYPE_VIEW_BILL;
extern NSString * const PAGE_TYPE_VIEW_BILL_REQUEST;
extern NSString * const PAGE_TYPE_VIEW_BILL_PDF;
extern NSString * const PAGE_TYPE_VIEW_BILL_TIP;
extern NSString * const PAGE_TYPE_GET_STATEMENT_DATES;
extern NSString * const PAGE_TYPE_MANAGE_PAY_ACCOUNT;
extern NSString * const PAGE_TYPE_NOTIFICATIONS;
extern NSString * const PAGE_TYPE_HOME_STORE_MAP_URL;
extern NSString * const PAGE_TYPE_ADD_NEW_PAYMENT_ACCOUNT;
extern NSString * const PAGE_TYPE_MANAGE_AUTO_PAY;
extern NSString * const PAGE_TYPE_M2M;
extern NSString * const PAGE_TYPE_M2M_SUBMIT;
extern NSString * const PAGE_TYPE_MANDATORY_UPGRADE;
extern NSString * const PAGE_TYPE_MANAGE_PAPERLESS_BILL;
extern NSString * const PAGE_TYPE_MANAGE_PAPERFREE_BILL;
extern NSString * const PAGE_TYPE_MANAGE_PAPER_BILL_CONFIRMATION;
extern NSString * const PAGE_TYPE_PENDING_ORDERS;
extern NSString * const PAGE_TYPE_LOG_CRASH;
extern NSString * const PAGE_TYPE_LOG_ERRORS;
extern NSString * const PAGE_TYPE_LOG_DATA;
extern NSString * const PAGE_TYPE_IN_STORE;
extern NSString * const PAGE_TYPE_TERMS_CONDITION;
extern NSString * const PAGE_TYPE_DATA_UTILIZATION;
extern NSString * const PAGE_TYPE_LOGIN_SELECTION;
extern NSString * const PAGE_TYPE_EDGE_AGREEMENT;
extern NSString * const PAGE_TYPE_EDGE_BUYOUT;
extern NSString * const PAGE_TYPE_EDGE_BUYOUT_PAYMENT_OPTION;
extern NSString * const PAGE_TYPE_EDGE_BUY_AMOUNT;
extern NSString * const PAGE_TYPE_EDGE_BUYOUT_SAVED_PAYMENT;
extern NSString * const PAGE_TYPE_EDGE_BUYOUT_NEW_CARD_PAYMENT;
extern NSString * const PAGE_TYPE_EDGE_BUYOUT_NEW_ACH_PAYMENT;
extern NSString * const PAGE_TYPE_EDGE_BUYOUT_NEW_GIFT_CARD_PAYMENT;
extern NSString * const PAGE_TYPE_EDGE_BUYOUT_CONFIRM;
extern NSString * const PAGE_TYPE_DISCOUNT_STATUS_DETAILS;
extern NSString * const PAGE_TYPE_VALIDATE_TOUCH_ID_AUTH;
extern NSString * const PAGE_TYPE_TOUCH_ID_AUTH;
extern NSString * const PAGE_TYPE_PRICING_OVERLAY;
extern NSString * const PAGE_TYPE_PLAN_FEATURE_CHANGE;
extern NSString * const PAGE_TYPE_SIMPLE_CHANGE_PLAN;
extern NSString * const PAGE_TYPE_SEND_SMS;
extern NSString * const PAGE_TYPE_SIMPLE_PLAN_POSITIONING;
extern NSString * const PAGE_TYPE_MORE_EVERYTHING_REVIEW_PROMO;
extern NSString * const PAGE_TYPE_FEATURE_CHG_CONFIRM;
extern NSString * const PAGE_TYPE_VICE_CONNECTED_DEVICES;
extern NSString * const PAGE_TYPE_VICE_REMOVE_CONNECTED_DEVICES;
extern NSString * const PAGE_TYPE_VICE_EDIT_ADDRESS;
extern NSString * const PAGE_TYPE_OPEN_SSO;
extern NSString * const PAGE_TYPE_DATA_GIFTING;
extern NSString * const PAGE_TYPE_ORDER_STATUS;
extern NSString * const PAGE_TYPE_ORDER_TRACKING;
extern NSString * const PAGE_TYPE_CONNECTION_DAY;
extern NSString * const PAGE_TYPE_VIEW_NBS_PDF;
extern NSString * const PAGE_TYPE_VOICE_ASSIST;

extern NSString * const PAGE_TYPE_PAYMENT_CC_ACH;
extern NSString * const PAGE_TYPE_PAYMENT_CONFIRMATION;
extern NSString * const PAGE_TYPE_PAYMENT_RE_ENTER_CARD_VALIDATION;
extern NSString * const PAGE_TYPE_PAYMENT_RE_ENTER_CCID;
extern NSString * const PAGE_TYPE_PAYMENT_REENTER_CCID_ZIP;
extern NSString * const PAGE_TYPE_PAYMENT_REENTER_ZIP;
extern NSString * const PAGE_TYPE_PAYMENT_SET_NEW_CARD_ADD;
extern NSString * const PAGE_TYPE_PAYMENT_VALIDATE_CARD;
extern NSString * const PAGE_TYPE_PAYMENT_VALIDATE_CHECK;
extern NSString * const PAGE_TYPE_PAYMENT_NEW_CHECK;
extern NSString * const PAGE_TYPE_PAYMENT_VALIDATE_GIFTCARD;
extern NSString * const PAGE_TYPE_PAYMENT_CONFIRM_GIFTCARD_PAYMENT;
extern NSString * const PAGE_TYPE_ADD_ACH_ACCOUNT;
extern NSString * const PAGE_TYPE_ADD_CARD_ACCOUNT;
extern NSString * const PAGE_TYPE_DELETE_ACCOUNT;
extern NSString * const PAGE_TYPE_UPDATE_ACCOUNT_ACH;
extern NSString * const PAGE_TYPE_UPDATE_ACCOUNT_CARD;
extern NSString * const PAGE_TYPE_MANAGE_ACCOUNTS_ACH;
extern NSString * const PAGE_TYPE_MANAGE_ACCOUNTS_ACH_NEW;
extern NSString * const PAGE_TYPE_DELETE_ACH;
extern NSString * const PAGE_TYPE_DELETE_CARD_UPDATE;
extern NSString * const PAGE_TYPE_CHANGE_PLAN_EFFECTIVE_DATE;
extern NSString * const PAGE_TYPE_SUBMIT_PTP;
extern NSString * const PAGE_TYPE_NON_VERIZON_USER;

//ShopFlow
extern NSString * const PAGE_TYPE_UPGRADE_ELIGIBLE_DEVICES;
extern NSString * const PAGE_TYPE_SHOP_TRADE_IN_QUESTIONNAIRE;
extern NSString * const PAGE_TYPE_GET_GRIDWALL_CONTENT;
extern NSString * const PAGE_TYPE_PRODUCT_DETAILS;
extern NSString * const PAGE_TYPE_PRODUCT_REVIEWS;
extern NSString * const PAGE_TYPE_PRODUCT_PROTECTION;
extern NSString * const PAGE_TYPE_SHOP_TRADE_IN_DEVICES;
extern NSString * const PAGE_TYPE_MINI_GRIDWALL;
extern NSString * const PAGE_TYPE_FULL_GRIDWALL;
extern NSString * const PAGE_TYPE_SHOP_TRADE_APPRAISAL;
extern NSString * const PAGE_TYPE_SHOP_CART;
extern NSString * const PAGE_TYPE_SHOP_CHECKOUT;
extern NSString * const PAGE_TYPE_SHOP_PURCHASE_COMPLETE;
extern NSString * const PAGE_TYPE_COMPLETE_ORDER_DETAILS;
extern NSString * const PAGE_TYPE_NON_VERIZON;

// Lower Funnel Page_Types
extern NSString * const PAGE_TYPE_GET_SHIPPING_INFORMATION;
extern NSString * const PAGE_TYPE_GET_BILLING_INFORMATION;
extern NSString * const PAGE_TYPE_GET_DEVICE_INFORMATION;
extern NSString * const PAGE_TYPE_GET_TERMS_AND_CONDITION;

/***** start screen 6.1b, 6.1c, 6.1d, 6.1e *******/

//start lower funnel EDIT SHIPPING INFORMATION

extern NSString * const USER_SHIP_INFO;
extern NSString * const CONTACT_INFO;

extern NSString * const PHONE_NUMBER;

extern NSString * const ADDRESS_INFO;
extern NSString * const ADDRESS2;
extern NSString * const ZIP_CODE_LOWERCASE;
extern NSString * const EDIT_SHIPPING_ADDRESS;
extern NSString * const EDIT_PAYMENT_INFORMATION;
extern NSString * const EDIT_DEVICE_INFORMATION;
extern NSString * const VERIZON_CUSTOMER_AGREEMENT;
extern NSString * const CREDIT_CARD_NUMBER;
extern NSString * const CREDIT_CARD_EXP_MONTH;
extern NSString * const CREDIT_CARD_EXP_YEAR;
extern NSString * const BILLING_ZIP_CODE;
extern NSString * const CREDIT_CARD_VERIFICATION_NO;
extern NSString * const SAVED_CARD_NICKNAME;
extern NSString * const CREDIT_CARD_INFO;

//Request Keys
extern NSString * const CUSTOMER_NAME_LOWERCASE;

//SHIPPING INFORMATION
extern NSString * const ALL_FIELDS_MUST_BE_COMPLETED;
extern NSString * const FIELDS_HIGHLIGHTED_MUST_BE_COMPLETED_LBL;
extern NSString * const CUSTOMER_NAME;
extern NSString * const SHIPPING_ADDRESS1;
extern NSString * const SHIPPING_ADDRESS2;
extern NSString * const CITY_LBL;
extern NSString * const STATE_LBL;
extern NSString * const STATE_ARRAY;
extern NSString * const ZIP_CODE_LBL;
extern NSString * const CONTACT_PHONE_NUMBER;
extern NSString * const CONTACT_EMAILADD;
extern NSString * const UPDATE_SHIPPING_INFORMATION;
extern NSString * const CANCEL_CAPS;
//BILLING INFORMATION
extern NSString * const SAVE_CARD_TOACCOUNT_LBL;
extern NSString * const SHOW_SAVE_CARD_OPTION;
extern NSString * const BILLING_ZIP_LBL;
extern NSString * const CVN_LBL;
extern NSString * const EXPIRATION_DATE_LBL;
extern NSString * const SCAN_YOUR_CARD;
extern NSString * const CREDIT_CARD_SCAN_LBL;
extern NSString * const SCAN_CARD_TITLE;
extern NSString * const SCAN_CARD_MESSAGE;
extern NSString * const SCAN_CARD_MANUAL_BTN;
extern NSString * const INVALID_CARD_LBL;
extern NSString * const SCAN_GUIDE_INFO_LBL;
extern NSString * const ENTER_MANUALLY_LBL;
extern NSString * const CARD_NUMBER_LBL;
extern NSString * const PAY_WITH_NEW_CARD_LBL;
extern NSString * const PAY_WITH_SAVED_CARD_LBL;
extern NSString * const BILLING_ADDRESS1;
extern NSString * const BILLING_ADDRESS2;
extern NSString * const BILL_TO_MY_ACC_LBL;
extern NSString * const UPDATE_BILLING_INFORMATION;
extern NSString * const SCAN_CARD_IMAGE;
extern NSString * const BILL_TO_ACCOUNT_ELIGIBLE;
extern NSString * const PAYMENT_SELECTION_WARN_LBL;

extern NSString * const VISA_CARD_IMAGE;
extern NSString * const MASTER_CARD_IMAGE;
extern NSString * const DISCOVER_CARD_IMAGE;
extern NSString * const AMEX_CARD_IMAGE;

extern NSString * const NORTON_IMAGE;
extern NSString * const NORTON_PREFIX_LBL;
extern NSString * const NORTON_POSTFIX_LBL;

//DEVICE INFORMATION
extern NSString * const PHONE_NUMBER_INFORMATION_SECTION_HEADING;
extern NSString * const SERVICE_ADDRESS1;
extern NSString * const SERVICE_ADDRESS2;
extern NSString * const UPDATE_DEVICE_INFORMATION;
extern NSString * const DEVICE_ADDRESS;
extern NSString * const PHONE_NUMBER_SECTION_CONTENT;
//TERMS AND CONDITION
extern NSString * const ACCEPT_TERMS_AND_CONDITION;
extern NSString * const TNC_AGREEMENT;
extern NSString * const TNC_AGREEMENT_TXT;
extern NSString * const ACCEPT_TC_CONTINUE_LBL;
//End lower funnel EDIT SHIPPING INFORMATION

/*********   END  ***************/

extern NSString * const PAGE_TYPE_CLEAR_SPOT;
extern NSString * const PAGE_TYPE_CLEAR_SPOT_ENABLE_PUSH;

#pragma mark - Story Board Names
extern NSString * const STORY_BOARD_NAME_MAIN;
extern NSString * const STORY_BOARD_NAME_USAGE_ALERTS;
extern NSString * const STORY_BOARD_NAME_AUTHENTICATION_FLOW;
extern NSString * const STORY_BOARD_NAME_MY_PROFILE_FLOW;
extern NSString * const STORY_BOARD_NAME_DEVICE_FLOW;
extern NSString * const STORY_BOARD_NAME_PLAN_FLOW;
extern NSString * const STORY_BOARD_NAME_REGISTER_FLOW;
extern NSString * const STORY_BOARD_NAME_MANAGE_SAFEGUARDS;
extern NSString * const STORY_BOARD_NAME_CHANGE_FEATURE;
extern NSString * const STORY_BOARD_NAME_VERIZON_SELECT;
extern NSString * const STORY_BOARD_NAME_PURCHASE_HISTORY;
extern NSString * const STORY_BOARD_NAME_GLOBAL_READY_CHECK;
extern NSString * const STORY_BOARD_NAME_VOICE_ASSIST;
extern NSString * const STORY_BOARD_NAME_STORE_VISIT_HISTORY;
extern NSString * const STORY_BOARD_NAME_SPLASH_SCREEN_NON_VERIZON_USERS;
extern NSString * const STORY_BOARD_NAME_USAGE_HISTORY;

#pragma mark - Notification Names
extern NSString * const NOTIFICATION_NAME_MDN_CAROUSEL_CHANGED;
extern NSString * const NOTIFICATION_NAME_FETURE_SELECTIONCHANGE;
extern NSString * const NOTIFICATION_NAME_CACHE_UPDATE;
extern NSString * const NOTIFICATION_DEVICE_IMAGE_DOWNLOAD_SUCCESS;
extern NSString * const NOTIFICATION_SIM_CARD_CHECK_SUCCESS;
extern NSString * const NOTIFICATION_DISMISS_MODAL_VIEWS;
extern NSString * const NOTIFICATION_MODAL_VIEW_DISMISSED;
extern NSString * const NOTIFICATION_DETAIL_WIDTH_CHANGED;
extern NSString * const NOTIFICATION_MVM_CACHED_IMAGE_DOWNLOADED;
extern NSString * const NotificationContentTransferActive;
extern NSString * const NotificationContentTransferInactive;
extern NSString * const NotificationPromosDownloaded;

#pragma mark - Notification Actions
extern NSString *const ACTION_LAUNCHURL;
extern NSString *const ACTION_DEEPLINK;
extern NSString *const ACTION_ONECLICK;
extern NSString *const ACTION_DISMISS;

#pragma mark - Image names
extern NSString * const ACCORDIAN_ARROW_CONTRACT;
extern NSString * const ACCORDIAN_ARROW_EXPAND;
extern NSString * const DROP_UP_ARROW;
extern NSString * const DROP_DOWN_ARROW;
extern NSString * const CHECKMARK;
extern NSString * const CHECKMARK_UNSELECTED;
extern NSString * const RADIO_ON;
extern NSString * const RADIO_OFF;
extern NSString * const IMG_DEVICE_PLACEHOLDER;
extern NSString * const IMG_DEFAULT_PHONE_PLACEHOLDER;

#pragma mark - Voice Search - VZAnalytics
extern NSString * const MVM_TYPEAHEAD_Q;
extern NSString * const MVM_TYPEAHEAD_R;
extern NSString * const MVM_VOICE_SEARCH_Q;
extern NSString * const MVM_VOICE_SEARCH_R;
extern NSString * const MVM_ICON_SEARCH_Q;
extern NSString * const MVM_ICON_SEARCH_R;

#pragma mark - Other Keys for String File

// Keys
extern NSString * const RESTART_KEY;
extern NSString * const RETRY_KEY;
extern NSString * const OKAY_KEY;
extern NSString * const CONTINUE_KEY;
extern NSString * const CLOSE_KEY;
extern NSString * const MDN_INVALID_FORMAT_KEY;
extern NSString * const SESSION_TIMEOUT_KEY;
extern NSString * const ERROR_INVALID_EMAIL_FORMAT_KEY;
extern NSString * const REPORT_A_PROBLEM_KEY;
extern NSString * const MY_CONTACTS_KEY ;

// Values
extern NSString * const LANGUAGE_SPANISH;

#pragma mark - Hybrid Constants

// No timeout. For Testing. (NO for production)
extern BOOL const NO_INITIAL_TIMEOUT;

// Time before Timeout in seconds.
extern NSTimeInterval const HYBRID_TIME_OUT_TIME;

// Arbitratry value for the timer being stopped (should be negative atleast)
extern NSTimeInterval const NO_TIMER;

// The cache version key
extern NSString * const CACHE_VERSION_KEY;

// Java script strings
extern NSString * const JSCRIPT_TASK;

// Constants for determining how to clear cache and reload
enum {
    RELOAD = 1 << 0,
    CLEAR_CACHE = 1 << 1,
    CLEAR_COOKIES = 1 << 2
};
typedef NSInteger ClearCacheAndReloadConstants;

//ServerAction Codes
typedef enum {
    OPEN_URL = 10001,
    CLEAR_CACHE_AND_RELOAD = 10010,
    HIDE_SPLASH_SCREEN = 10011,
    SHOW_DEVICE_HEALTH_CHECK = 10007,
    UPDATE_AVAILABLE = 10012,
    SET_USER_PROFILE = 10018,
    GET_USER_PROFILE = 10019,
    SYSTEM_INIT_COMPLETE = 10020,
    PREPAY_POSTPAY_SWITCH = 10025,
    DELETE_KEYCHAIN = 10040,
    DELETE_ERROR_LOGS = 10060,
    OPEN_APP_SETTINGS = 10090,
    DATA_METER_AWARENESS_POPUP_SHOWN = 10091
} ServerActionCodes;

// Prepay switch keys
extern NSString * const SWITCH_USERNAME_KEY;
extern NSString * const SWITCH_PASSWORD_KEY;

// Server response keys
extern NSString * const DATA_CLEAR_CACHE_KEY;
extern NSString * const DATA_CLEAR_COOKIES_KEY;
extern NSString * const DATA_LANGUAGE_KEY;
extern NSString * const DATA_URL_KEY;
extern NSString * const DATA_APP_URL_KEY;
extern NSString * const DATA_STORE_URL;
extern NSString * const DATA_MODIFIED_SEND_PARAMS;

extern NSString * const LANGUAGE_ENGLISH_VALUE;

extern NSString *const HTML_CONTENT;

#pragma mark - Other Bitmasks and Enums

// Enum for the tab names. Each tab name corresponds to the index of the corresponding tab.
typedef NS_ENUM(NSInteger, TabName) {
    CurrentTab = -1,
    MyAccountTab = 0,
    MyDevicesTab = 1,
    MyProfileTab = 2,
    SupportTab = 3,
    ShopNowTab = 4
};

// The loading style.
// LoadStyleDefault: standard push.
// LoadStyleReplaceCurrent: Replaces the current view controller if possible.
// LoadStyleOnTopOfRoot: Loads ontop of the root controller.
// LoadStyleBecomeRoot: Load as the root controller.
typedef NS_ENUM(NSInteger, LoadStyle) {
    LoadStyleDefault = 0,
    LoadStyleReplaceCurrent,
    LoadStyleOnTopOfRoot,
    LoadStyleBecomeRoot
};

// For the account overview section,
typedef NS_OPTIONS(NSInteger, AccountOverviewSection) {
    AccountOverviewSectionNone = 0,
    AccountOverviewSectionGreeting = 1 << 0,
    AccountOverviewSectionLastPayment = 1 << 1,
    AccountOverviewSectionBill = 1 << 2,
    AccountOverviewSectionUsage = 1 << 3,
    AccountOverviewSectionPlan = 1 << 4,
    AccountOverviewSectionRelatedLinks = 1 << 5,
    AccountOverviewSectionAll = 0xffff
};

// For the plan section,
typedef NS_OPTIONS(NSInteger, PlanSection) {
    PlanSectionNone = 0,
    PlanSectionHeaderPlanTitle = 1 << 0,
    PlanSectionHeaderInfoCard = 1 << 1,
    PlanSectionHeaderCompareView = 1 << 2,
    PlanSectionHeaderDisclaimer = 1 << 3,
    PlanSectionHeaderSegmentedControl = 1 << 4,
    PlanSectionFooterLinkButton = 1 << 5,
    PlanSectionFooterCompareView = 1 << 6,
    PlanSectionFooterButtonsView = 1 << 7,
    PlanSectionFooterDisclaimer = 1 << 8,
    PlanSectionAll = 0xffff
};

// Enum for the tab names. Each tab name corresponds to the index of the corresponding tab.
typedef NS_ENUM(NSInteger, LoadingOverlayStyle) {
    LoadingOverlayStyleNone = 0,
    LoadingOverlayStyleTransparentView = 1
};

// Usage types, don't mess with the ordering of this enum, they are also mapping keys
typedef NS_ENUM(NSInteger, UsageType) {
    UsageTypeData = 0,
    UsageTypeVoice,
    UsageTypeMessage,
    UsageTypeHotspot
};

// Enum for the button state.
typedef NS_ENUM(NSInteger, ButtonState) {
    CurrentState = -1,
    Add = 0,
    Remove = 1,
    Switch = 2,
    Keep = 3,
    Discard = 4
};

// Enum for the tooltip type for view bill
typedef NS_ENUM(NSInteger, TooltipType) {
    vzwSurcharge = 0,
    monthlyAccess = 1,
    data = 2,
    voice = 3,
    message = 4,
    usage = 5,
    govTax = 6,
    usagepurchase = 7,
    contactEndDate = 8,
    activationFee = 9,
    upgradeFee = 10,
    lateFee = 11,
    equipmentCharges =12,
    previousPlan = 13,
    newPlan = 14,
    monthAdvance = 15
};


// For Payment option type
typedef NS_ENUM(NSInteger, PaymentOptionType) {
    PaymentOptionTypeNoOption = 0,
    PaymentOptionTypeAddNewPayment,
    PaymentOptionTypeNew,
    PaymentOptionTypeChildren
};
