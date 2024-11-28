import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mention_tag_text_field/mention_tag_text_field.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MentionTagTextFieldExample(),
    );
  }
}

class MentionTagTextFieldExample extends StatefulWidget {
  const MentionTagTextFieldExample({
    super.key,
  });

  @override
  State<MentionTagTextFieldExample> createState() =>
      _MentionTagTextFieldExampleState();
}

class _MentionTagTextFieldExampleState
    extends State<MentionTagTextFieldExample> {
  final MentionTagTextEditingController _controller =
      MentionTagTextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.setText = "Hello @Emily Johnson ";
  }

  String? mentionValue;
  List searchResults = [];
  List searchResultsAfterMention = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (mentionValue != null)
                suggestions()
              else
                const Expanded(child: SizedBox()),
              const SizedBox(
                height: 16,
              ),
              mentionField(),
              SizedBox(
                height: 20,
              ),
              Row(
                children: _controller.mentions.map((user) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Chip(
                      label: Text(user.id), // Display user name
                      avatar: CircleAvatar(
                        child: Text(user
                            .name[0]), // Display the first letter of the name
                      ),
                    ),
                  );
                }).toList(),
              ),
              // Text(_controller.),
            ],
          ),
        ),
      ),
    );
  }

  MentionTagTextField mentionField() {
    final border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none);
    return MentionTagTextField(
      keyboardType: TextInputType.multiline,
      minLines: 5,
      maxLines: 5,
      controller: _controller,
      initialMentions: const [
        ('@Emily Johnson', User(id: '1', name: 'Emily Johnson'), null)
      ],
      onMention: onMention,
      mentionTagDecoration: MentionTagDecoration(
          mentionStart: ['@', '#'],
          mentionBreak: ' ',
          allowDecrement: false,
          allowEmbedding: false,
          showMentionStartSymbol: false,
          maxWords: null,
          mentionTextStyle: TextStyle(
              color: Colors.blue, backgroundColor: Colors.blue.shade50)),
      decoration: InputDecoration(
          hintText: 'Write something...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: border,
          focusedBorder: border,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)),
    );
  }

  Widget suggestions() {
    if (searchResults.isEmpty) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Flexible(
        fit: FlexFit.loose,
        child: Container(
          width: 400,
          color: Colors.red[50],
          child: ListView.builder(
              itemCount: searchResultsAfterMention.length,
              reverse: true,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (_controller.mentions.isNotEmpty) {
                      for (int i = 0; i < _controller.mentions.length; i++) {
                        print(_controller.mentions[i].name);
                      }
                    } else {
                      print("The mentions list is empty.");
                    }
                    _controller.addMention(
                        label:
                            "${searchResultsAfterMention[index]['firstNameKh']} ${searchResultsAfterMention[index]['lastNameKh']}",
                        data: User(
                            id: searchResultsAfterMention[index]['id'],
                            name:
                                "${searchResultsAfterMention[index]['firstNameKh']} ${searchResultsAfterMention[index]['lastNameKh']}"),
                        stylingWidget: _controller.mentions.length == 1
                            ? MyCustomTag(
                                controller: _controller,
                                text:
                                    "${searchResultsAfterMention[index]['firstNameKh']} ${searchResultsAfterMention[index]['firstNameKh']}")
                            : null);
                    mentionValue = null;
                    setState(() {});
                  },
                  child: ListTile(
                    // leading: CircleAvatar(
                    //   backgroundImage: NetworkImage(
                    //       searchResultsAfterMention[index]['image']),
                    // ),
                    title: Text(
                        "${searchResultsAfterMention[index]['firstNameKh']} ${searchResultsAfterMention[index]['lastNameKh']}"),
                    subtitle: Text(
                      "@${searchResultsAfterMention[index]['fullNameKh']}",
                      style:
                          TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    ),
                  ),
                );
              }),
        ));
  }

  Future<void> onMention(String? value) async {
    print(_controller.getText);
    print(_controller.text);
    mentionValue = value;
    searchResults.clear();
    searchResultsAfterMention.clear;
    setState(() {});
    if (value == null) return;
    final searchInput = value.substring(1);
    searchResults = await fetchSuggestionsFromServer(searchInput) ?? [];

    // searchResultsAfterMention = await searchResults
    //     .where((map) => !_controller.mentions.contains(map['name']))
    //     .map((map) => map['name']!)
    //     .toList();
    // print(searchResultsAfterMention.length);
    // String jsonString = jsonEncode(searchResults);

    // Get the IDs from _controller.mentions
    Set<String> mentionIds =
        _controller.mentions.map((mention) => mention.id as String).toSet();
    List<Map<String, dynamic>> jsonList =
        List<Map<String, dynamic>>.from(searchResults);

    // Filter the jsonList to exclude items with IDs in mentionIds
    List<Map<String, dynamic>> filteredList =
        jsonList.where((user) => !mentionIds.contains(user['id'])).toList();

    // Print the JSON string
    print(filteredList);
    searchResultsAfterMention = filteredList;
    setState(() {});
  }

  // Future<List?> fetchSuggestionsFromServer(String input) async {
  //   try {
  //     final response = await http
  //         .get(Uri.parse('http://dummyjson.com/users/search?q=$input'));
  //     return jsonDecode(response.body)['users'];
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  //   return null;
  // }
  Future<List?> fetchSuggestionsFromServer(String input) async {
    // URL with corrected query parameter syntax
    final url = Uri.parse(
        'https://api.test.dwf.mptc.gov.kh/admin/users?searchText=$input&limit=10&offset=0');
    final headers = {
      'x-session-token': '167d7b0faeab03ccaeb9a0c340f19501',
    };

    try {
      // HTTP GET request
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // Parse JSON response
        final data = jsonDecode(response.body);
        print(" ==== ${data['rows']} ==== ");
        return data['rows']; // Accessing 'rows' instead of 'row'
      } else {
        debugPrint('Failed to fetch suggestions: ${response.statusCode}');
      }
    } catch (e) {
      // Handle errors during the request
      debugPrint('Error fetching suggestions: $e');
    }

    return null;
  }
}

class MyCustomTag extends StatelessWidget {
  const MyCustomTag({
    super.key,
    required this.controller,
    required this.text,
  });

  final MentionTagTextEditingController controller;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
          color: Colors.yellow.shade50,
          borderRadius: const BorderRadius.all(Radius.circular(50))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: TextStyle(
                color: Colors.yellow.shade700,
              )),
          const SizedBox(
            width: 6.0,
          ),
          GestureDetector(
            onTap: () {
              controller.remove(index: 1);
            },
            child: Icon(
              Icons.close,
              size: 12,
              color: Colors.yellow.shade700,
            ),
          )
        ],
      ),
    );
  }
}

class User {
  const User({required this.id, required this.name});
  final String id;
  final String name;
}
