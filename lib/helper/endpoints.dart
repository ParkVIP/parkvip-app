class Endpoints{
  // final String host = "clients.parkvip.app:8061"; //use this host when using http
   final String host = "clients.parkvip.app:8060"; //Used for live
 // final String host = "devclient.parkvip.app:8060"; //used for staging
//    final String host = "develop.parkvip.app:8060"; //used for develop
   //final String host = "10.0.2.2:8061"; 
   //final String host = "192.168.185.47:8061"; 

  var endpoints = {
    'get_locations' : '/api/v1/get-data?screen_type=locations',
    'get_single_loc':'/api/v1/location',
    'get_sections' : '/api/v1/get-data?screen_type=sections',
    'get_languages' : '/api/v1/get-data?screen_type=languages',
    'get_notifications' : '/api/v1/notification-list',
    'get_section_spaces' : '/api/v1/get-data?screen_type=section_spaces',
    'post_payment_method': '/api/v1/payment',
    'feedback': '/api/v1/feedback',
    'update_user_notification': '/api/v1/notification-transactions',
    'get_current_activity':'/api/v1/parking-details/current/',
    'get_history_activity':'/api/v1/parking-details/history/',
    'get_current_reservations':'/api/v1/reserve/current/',
    'get_history_reservations':'/api/v1/reserve/history/',
    'post_reservations':'/api/v1/reserve',
    'get_reserveList':'/api/v1/reserveList',
    'get_payment' :'/api/v1/payment',
    'get_parking-details' :'/api/v1/parking-details',
    'post_parking_details' :'/api/v1/parking-details',
    'get_data' :'/api/v1/get-data',
    'post_favourite_locations' :'/api/v1/favourite_locations',
    'get_user_parking_details' : '/api/v1/parking-details/userlatestparking/',
    'user_login' :'/v1/user-login/app',
    'user_signup':'/v1/user-signup',
    'post_firebase_token':'/api/v1/registration-token',
    'reset_password' :'/v1/reset-password',
    'refresh_token' :'/v1/refresh_token',
    'verify_email_reset_pass':'/v1/verify-email',
    'verify_token_reset_pass' :'/v1/verify-token',
    'update_user':'/api/v1/users/',
    'update_timezone':'/api/v1/save-timezone',
    'charge_payment' :'/api/v1/charge-payment',
    'resend_verification_mail':'/v1/resend-verification-mail',
    'get_saved_cards' :'/api/v1/get-data?screen_type=saved_cards',
    'gpay_apay_payment': '/api/v1/payment_using_paymentApps',
    'get_asset':'/v1/single-asset/',
    'get_asset_type':'/api/v1/asset_type',
    'get_device':'/api/v1/device',
    'get_business':'/api/v1/business',
    'get_credit':'/api/v1/get-credits',
    'get_user_image':'/api/v1/user_image',
    'get_levels':'/api/v1/level',
    'get_twillio_token':'/api/v1/twilio-token',
    'get_twilio_admin' :'/api/v1/get-twilio-admin',
    'get_user_details' :'/api/v1/get_user_details',
    'get_parking_layout' : '/api/v1/section_layout',
    'get_floor_layout' :'/api/v1/floor_layout',
    'send_notification':'/api/v1/send-notification',
    'apple_auth':'/v1/auth/sign_in_with_apple',
    'google_auth':'/v1/auth/sign_in_with_google',
    'post_apple_res':'/api/v1/post_apple_data',
    'update_twilio_conversation' :'/api/v1/update_twilio_conversation',
    'fetch_twilio_conversation_list' :'/api/v1/twilio_conversations',
    'get_user_by_username' :'/api/v1/get-user-details',
    'send_twilio_message': '/api/v1/send_twilio_message',
    'delete_twilio_conversation':'/api/v1/delete_twilio_conversation',
    'get_twilio_token':'/api/v1/get_twilio_token',
    'get_user_notifications':'/api/v1/users_notification',
    'notification_read_update':'/api/v1/notification_read_update',
    'unreadCount':'/api/v1/users_notification_unreadCount',
    'update_failed_card':'/api/v1/update_failed_card',
    'get_payment_status':'/api/v1/get_payment_status',
    'refreshToken':'/v1/refresh_token'
  };
  
  callToUrl(requestedEndpoint){
    return "https://${host+endpoints[requestedEndpoint].toString()}";
  }

  callToUrlBase(requestedEndpoint){
    return endpoints[requestedEndpoint];
  }
}
