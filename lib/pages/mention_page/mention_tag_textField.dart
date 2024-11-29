import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mention_tag_text_field/mention_tag_text_field.dart';
import 'package:http/http.dart' as http;
import 'package:testing/model/user.dart';

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

  OverlayEntry? _overlayEntry;

  String? mentionValue;
  List searchResults = [];
  List searchResultsAfterMention = [];
  final GlobalKey _textFieldKey = GlobalKey(); // GlobalKey for TextField
  Timer? _debounceTimer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (mentionValue != null && searchResults.length > 0) ...[
                // suggestions(),
              ],
              // else
              //   const Expanded(child: SizedBox()),
              const SizedBox(
                height: 16,
              ),
              mentionField(),
              SizedBox(
                height: 20,
              ),
              // Row(
              //   children: _controller.mentions.map((user) {
              //     return Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 4.0),
              //       child: Chip(
              //         label: Text(user.id),
              //         avatar: CircleAvatar(
              //           child: Text(user.name[0]),
              //         ),
              //       ),
              //     );
              //   }).toList(),
              // ),
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
      key: _textFieldKey,
      keyboardType: TextInputType.multiline,
      minLines: 5,
      maxLines: 5,
      controller: _controller,
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
    if (searchResultsAfterMention.isEmpty &&
        searchResultsAfterMention.length > 0) {
      return Container(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      );
    }
    return Flexible(
      fit: FlexFit.loose,
      child: Container(
        constraints: new BoxConstraints(
          minHeight: 50,
          maxHeight: 600,
        ),
        color: Colors.red[50],
        child: ListView.builder(
          itemCount: searchResultsAfterMention.length,
          reverse: true,
          primary: true,
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
                );
                mentionValue = null;
                setState(() {});
              },
              child: ListTile(
                title: Text(
                    "${searchResultsAfterMention[index]['firstNameKh']} ${searchResultsAfterMention[index]['lastNameKh']}"),
                subtitle: Text(
                  "${searchResultsAfterMention[index]['fullNameEn']}",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> onMention(String? value) async {
    print(_controller.getText);
    print(_controller.text);

    mentionValue = value;
    searchResults.clear();
    await searchResultsAfterMention.clear;
    setState(() {});
    if (value == null) return;
    final searchInput = value.substring(1);

    searchResults = await fetchSuggestionsFromServer(
            input: searchInput, limit: 10 + _controller.mentions.length) ??
        [];
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
    setState(() {
      _dismissPopupMenu();
      if (searchResultsAfterMention.length > 0) {
        _showPopupMenu(context);
      }
    });
  }

  Future<List?> fetchSuggestionsFromServer({String? input, int? limit}) async {
    // URL with corrected query parameter syntax
    final url = Uri.parse(
        'https://api.test.dwf.mptc.gov.kh/admin/users?searchText=$input&limit=$limit&offset=0');
    final headers = {
      'x-session-token': '59aea09f2a4b3784706b225502fd91f7',
    };

    try {
      // HTTP GET request
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // Parse JSON response
        final data = jsonDecode(response.body);
        if (data['rows'].length > 0) {
          searchResults = [];
          setState(() {});
        }
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

  void _showPopupMenu(BuildContext context) {
    // Get the position of the TextField using GlobalKey
    final RenderBox renderBox =
        _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    // Get the global position of the TextField
    final Offset textFieldOffset =
        renderBox.localToGlobal(Offset.zero, ancestor: overlay);

    // Get the size of the TextField
    final Size textFieldSize = renderBox.size;

    // Define popup menu position (just below the TextField)
    final RelativeRect popupPosition = RelativeRect.fromLTRB(
      textFieldOffset.dx, // Left boundary (aligned to dx)
      textFieldOffset.dy + textFieldSize.height, // Directly below the TextField
      overlay.size.width -
          (textFieldOffset.dx + textFieldSize.width), // Right boundary
      overlay.size.height -
          (textFieldOffset.dy + textFieldSize.height), // Bottom boundary
    );

    // Show the popup menu with width equal to TextField's width
    showMenu(
      context: context,
      position: popupPosition,
      items: searchResultsAfterMention.map((item) {
        return PopupMenuItem<String>(
          value: "${item['firstNameKh']} ${item['lastNameKh']}",
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.orange[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['fullNameKh'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${item['firstNameEn']} ${item['lastNameEn']}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          onTap: () {
            if (_controller.mentions.isNotEmpty) {
              for (int i = 0; i < _controller.mentions.length; i++) {
                print(_controller.mentions[i].name);
              }
            } else {
              print("The mentions list is empty.");
            }
            _controller.addMention(
              label: "${item['firstNameKh']} ${item['lastNameKh']}",
              data: User(
                  id: item['id'],
                  name: "${item['firstNameKh']} ${item['lastNameKh']}"),
            );
            mentionValue = null;
            setState(() {});
          },
        );
      }).toList(),
      constraints:
          BoxConstraints(maxWidth: textFieldSize.width, maxHeight: 300),
    ).then((value) {
      if (value != null) {
        setState(() {
          // _selectedValue = value; // Update selected value
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected: $value')),
        );
      }
    });
  }

  void _dismissPopupMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
