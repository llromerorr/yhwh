import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:yhwh/bibles/RVR60/rvr60_verses.dart';
import 'package:yhwh/data/valuesOfBooks.dart';

class BibleManager{

  BibleManager();
  
  Future<List<String>> getChapterVerses(String version, int book, int chapter) async {
    List<String> output = [];
    List data = await jsonDecode(await rootBundle.loadString('lib/bibles/$version/${book}_$chapter.json'))['verses'];

    for(var map in data){
      output.add(map['text']);
    }

    return output;
  }

  Future<List<String>> getChapter({required int book, required int chapter}) async {
    List<String> output = [];

    for(int i = 0; i < valuesOfBooks[book - 1][chapter - 1]; i++)
      output.add(rvr60_verses['$book:$chapter:${i + 1}']!);

    return output;
  }

  Future<String> getVerse({required int book, required int chapter, required int verse}) async {
    return rvr60_verses['$book:$chapter:$verse']!;
  }
}