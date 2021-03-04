import 'dart:convert';


import 'package:http/http.dart' as http;
import 'package:personal_dictionary_with_sync/model/Words.dart';
import 'package:personal_dictionary_with_sync/utils/Constant.dart';

class ApiClient {

  /*Words*/
  Future<List<Words>> getAllAgentsData() async {
    var client = http.Client();
    Iterable wordList;

    try {
      var response = await client.get(BASE_URL + GET_ALL_WORDS);

      if (response.statusCode == 200) {
        var jsonString = response.body;
        wordList = json.decode(jsonString);

        return wordList.map((word) => Words.fromJson(word)).toList();
      }
    } catch (Exception) {
      return wordList;
    }

    return wordList;
  }



}
