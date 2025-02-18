class AppException implements Exception {
  final _message;
  final _prefix;


  AppException([this._message, this._prefix]);
}

class FetchDataException extends AppException {
  FetchDataException([message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends AppException {
  //InvalidInputException([String message]) : super(message, "Invalid Input: ");
  InvalidInputException([message]) : super(message, "Invalid Input: ");
}
