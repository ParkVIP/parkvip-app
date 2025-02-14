// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// This file contain sample payment configurations that can be used with the
/// payment providers in this library.
///
/// Although payment configurations can be hardcoded in your application source
/// (as displayed in this example), we recommend you to keep this information in
/// a remote location that can be accessed from your application (e.g.: a
/// backend server). That way, you benefit from being able to use multiple
/// payment configurations that can be modified without the need to update your
/// application.
/// Sample configuration for Apple Pay. Contains the same content as the file
/// under `assets/default_payment_profile_apple_pay.json`.
const String defaultApplePay = '''{
    "provider": "apple_pay",
    "data": {
      "merchantIdentifier": "merchant.com.devclients.parkvip",
      "displayName": "ParkVIP",
      "merchantCapabilities": ["3DS", "debit", "credit"],
      "supportedNetworks": ["amex", "visa", "discover", "masterCard"],
      "countryCode": "US",
      "currencyCode": "USD",
      "requiredBillingContactFields": ["emailAddress", "name", "phoneNumber", "postalAddress"],
      "requiredShippingContactFields": [],
      "shippingMethods": [
        {
          "amount": "0.00",
          "detail": "",
          "identifier": "",
          "label": ""
        }
      ]
    }
}''';

/// Sample configuration for Google Pay. Contains the same content as the file
/// under `assets/default_payment_profile_google_pay.json`.
const String defaultGooglePay = '''{
  "provider": "google_pay",
  "data": {
    "environment": "PRODUCTION",
    "apiVersion": 2,
    "apiVersionMinor": 0,
    "allowedPaymentMethods": [
      {
        "type": "CARD",
        "tokenizationSpecification": {
          "type": "PAYMENT_GATEWAY",
          "parameters": {
            "gateway": "stripe",
            "stripe:version": "2020-08-27",
            "stripe:publishableKey": ""
          }
        },
        "parameters": {
          "allowedCardNetworks": ["VISA", "MASTERCARD"],
          "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
          "billingAddressRequired": false,
          "billingAddressParameters": {
            "format": "FULL",
            "phoneNumberRequired": true
          }
        }
      }
    ],
    "merchantInfo": {
      "merchantId": "merchant.com.devclients.parkvip",
      "merchantName": "Kevin"
    },
    "transactionInfo": {
      "countryCode": "US",
      "currencyCode": "USD"
    }
  }
}''';

