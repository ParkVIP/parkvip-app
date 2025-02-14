import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../helper/app_exceptions.dart';
import '../helper/endpoints.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/login.dart';
import 'package:flutter/material.dart';


class ApiBaseHelper {
  static final ApiBaseHelper _singleton =  ApiBaseHelper._internal();
  var endpoint;
  factory ApiBaseHelper() {
    return _singleton;
  }
  ApiBaseHelper._internal(){
    endpoint = Endpoints();
  }

  Future<dynamic> getTwilioReq(String url, accessToken, queryParams) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var responseJson;
    try {
      var response;
      var uri=  endpoint.callToUrl(url);

      if(queryParams!=null) {
        uri += queryParams;
      }
      response = await http.get(
          Uri.parse(uri),
          headers: {"access-token": accessToken});

      responseJson = response.body.toString();
      /*if(responseJson['response_code']==401 && (responseJson['message']=='jwt expired' || responseJson['message']=='16 UNAUTHENTICATED: jwt expired')){
        await _refreshToken();
        var accToken = prefs.getString('access_token');
        if(accToken!=null){
          response = await http.get(Uri.parse(uri),headers: {"access-token": accToken});
          responseJson = response.body.toString();
        }
      }*/
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }
  Future<dynamic> get(context,String url, accessToken, queryParams) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var responseJson;
    var uri=  endpoint.callToUrl(url);

    if(queryParams!=null) {
      uri += queryParams;
    }

    try {
      var response;
      if(accessToken!=null){
        response = await http.get(Uri.parse(uri),headers: {"access-token": accessToken});
        responseJson = await _returnResponse(response,context);
        print("respose code=======${responseJson['response_code']}");
        if(responseJson['response_code']==401 && (responseJson['message']=='jwt expired' || 
          responseJson['message']=='16 UNAUTHENTICATED: jwt expired')){
          await _refreshToken(context);
          var accToken = prefs.getString('access_token');
          if(accToken!=null){
            response = await http.get(Uri.parse(uri),headers: {"access-token": accToken});
            responseJson = _returnResponse(response,context);
          }
        }
      }
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> post(context,String url, accessToken, dynamic body,queryParams) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var responseJson;
    var uri=  endpoint.callToUrl(url);

    if(queryParams!=null) {
      uri += queryParams;
    }
    try {
      var response;
      if(accessToken!=null){
        response = await http.post(
          Uri.parse(uri),
          body: json.encode(body),
          headers: {
            "access-token": accessToken,
            "Content-Type": "application/json"
          },
        );
      }
      responseJson = await _returnResponse(response,context);
      print(responseJson);
      if(responseJson['response_code']==401 && (responseJson['message']=='jwt expired' || responseJson['message']=='16 UNAUTHENTICATED: jwt expired')){
        await _refreshToken(context);
        var accToken = prefs.getString('access_token');
        if(accToken!=null){
          response = await http.get(Uri.parse(uri),headers: {"access-token": accToken});
          responseJson = _returnResponse(response,context);
        }
      }
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> postWithoutToken(String url, dynamic body,queryParams) async {
    var responseJson;
    try {
      var response;
      var uri=  endpoint.callToUrl(url);
      if(queryParams!=null) {
        uri += queryParams;
      }
      response = await http.post(
        Uri.parse(uri),
        body: json.encode(body),
        headers: {
          "Content-Type": "application/json"
        },
      );
      responseJson = json.decode(response.body.toString());
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }


  Future<dynamic> delete(context,String url, accessToken, queryParams) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var responseJson;
    var uri=  endpoint.callToUrl(url);

    if(queryParams!=null) {
      uri += queryParams;
    }

    var response;
    try {
      if(accessToken!=null){
        response = await http.delete(
            Uri.parse(uri),
            headers: {"access-token": accessToken}
        );
      }
      responseJson = await _returnResponse(response,context);
      if(responseJson['response_code']==401 && (responseJson['message']=='jwt expired' || responseJson['message']=='16 UNAUTHENTICATED: jwt expired')){
        await _refreshToken(context);
        var accToken = prefs.getString('access_token');
        if(accToken!=null){
          response = await http.get(Uri.parse(uri),headers: {"access-token": accToken});
          responseJson = _returnResponse(response,context);
        }
      }
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  dynamic _refreshToken(context) async {
    print('refresh token called-----');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var refreshToken = prefs.getString('refresh_token');
    var jsonResponse;
    try{
      var formData = <String, dynamic>{};
      formData['refreshToken'] = refreshToken;
      jsonResponse =await postWithoutToken('refreshToken', formData,'');
      if(jsonResponse['response_code']==200){
        prefs.setString("access_token", jsonResponse['accessToken']);
      }else{
        await prefs.clear();
        return Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => LoginPage()),(Route<dynamic> route) => true);
      }
      return jsonResponse;
    }catch (e) {
      return e.toString();
    }
  }
}

dynamic _returnResponse(http.Response response,context) async {
  switch (response.statusCode) {
    case 200:
      var responseJson = json.decode(response.body.toString());
      return responseJson;
    case 400:
      throw BadRequestException(response.body.toString());
    case 401:
      var responseJson = json.decode(response.body.toString());
      print(responseJson);
      if(responseJson['message']!="jwt expired" && responseJson['message']!="16 UNAUTHENTICATED: jwt expired"){
        print('--------------------------------------------token not expited-----------------------------------------------------');
        final pref = await SharedPreferences.getInstance();
        await pref.clear();
        return Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => LoginPage()),(Route<dynamic> route) => true);
      }else{
        print('--------------------------------------------token expited-----------------------------------------------------');
        return responseJson;
      }
    case 403:
      throw UnauthorisedException(response.body.toString());
    case 404:
      var responseJson = json.decode(response.body.toString());
      return responseJson;
    case 500:
      var responseJson = json.decode(response.body.toString());
      return responseJson;
    case 504:
      var responseJson = json.decode(response.body.toString());
      return responseJson;
    default:
      throw FetchDataException(
          'Error occurred while Communication with Server with StatusCode : ${response.statusCode}'
      );
  }
}
