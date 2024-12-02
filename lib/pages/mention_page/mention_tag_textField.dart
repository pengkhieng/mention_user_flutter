import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mention_tag_text_field/mention_tag_text_field.dart';
import 'package:http/http.dart' as http;
import 'package:testing/model/user.dart';

class CustomMention extends StatefulWidget {
  const CustomMention({
    super.key,
  });

  @override
  State<CustomMention> createState() => _CustomMentionState();
}

class _CustomMentionState extends State<CustomMention> {
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
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 16,
              ),
              mentionField(),
              SizedBox(
                height: 20,
              ),
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
      style: TextStyle(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      mentionTagDecoration: MentionTagDecoration(
          mentionStart: ['@', '#'],
          mentionBreak: ' ',
          allowDecrement: false,
          allowEmbedding: false,
          showMentionStartSymbol: false,
          maxWords: null,
          mentionTextStyle: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: Colors.red,
              backgroundColor: Colors.blue.shade50)),
      decoration: InputDecoration(
          hintText: 'Write something...',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
          ),
          filled: true,
          fillColor: Colors.green.shade100,
          border: border,
          focusedBorder: border,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)),
    );
  }

  Future<void> onMention(String? value) async {
    _dismissPopupMenu();
    print(_controller.getText);
    print(_controller.text);

    if (value == null) return;

    if (mentionValue != value) {
      mentionValue = value;
      searchResults.clear();
      await searchResultsAfterMention.clear;
      setState(() {});

      final searchInput = value.substring(1);

      _debounceTimer?.cancel();

      _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
        searchResults = await fetchSuggestionsFromServer(
                input: searchInput, limit: 10 + _controller.mentions.length) ??
            [];

        Set<String> mentionIds =
            _controller.mentions.map((mention) => mention.id as String).toSet();
        List<Map<String, dynamic>> jsonList =
            List<Map<String, dynamic>>.from(searchResults);

        List<Map<String, dynamic>> filteredList =
            jsonList.where((user) => !mentionIds.contains(user['id'])).toList();
        print(filteredList);
        searchResultsAfterMention = filteredList;

        setState(() {
          _dismissPopupMenu();
          if (searchResultsAfterMention.isNotEmpty) {
            _showPopupMenu(context);
          }
        });
      });
    }
  }

  Future<List?> fetchSuggestionsFromServer({String? input, int? limit}) async {
    final url = Uri.parse(
        'https://api.test.dwf.mptc.gov.kh/admin/users?searchText=$input&limit=$limit&offset=0');
    final headers = {
      'x-session-token': '6211fd77f85395493ba0d35d78dc6aeb',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['rows'].length > 0) {
          searchResults = [];
          mentionValue = null;
          searchResultsAfterMention = [];
          setState(() {});
        }
        _dismissPopupMenu();
        return data['rows'];
      } else {
        mentionValue = null;
        searchResults = [];
        searchResultsAfterMention = [];
        debugPrint('Failed to fetch suggestions: ${response.statusCode}');
      }
    } catch (e) {
      // Handle errors during the request
      debugPrint('Error fetching suggestions: $e');
    }

    return null;
  }

  bool _isPopupMenuVisible = false;

  void _showPopupMenu(BuildContext context) {
    if (_isPopupMenuVisible) {
      Navigator.pop(context);
      _isPopupMenuVisible = false;
      return;
    }

    final RenderBox renderBox =
        _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final Offset textFieldOffset =
        renderBox.localToGlobal(Offset.zero, ancestor: overlay);

    final Size textFieldSize = renderBox.size;

    double paddingBottom = 10;

    final RelativeRect popupPosition = RelativeRect.fromLTRB(
      textFieldOffset.dx,
      textFieldOffset.dy + textFieldSize.height + paddingBottom,
      overlay.size.width - (textFieldOffset.dx + textFieldSize.width),
      overlay.size.height -
          (textFieldOffset.dy + textFieldSize.height) -
          paddingBottom,
    );

    showMenu(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      menuPadding: EdgeInsets.all(10),
      color: Colors.white,
      context: context,
      position: popupPosition,
      items: searchResultsAfterMention.map((item) {
        return PopupMenuItem<String>(
          value: "${item['firstNameKh']} ${item['lastNameKh']}",
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.grey.withOpacity(.1),
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
          onTap: () async {
            _isPopupMenuVisible = false;
            _controller.addMention(
              label: "${item['firstNameKh']} ${item['lastNameKh']}",
              data: User(
                  id: item['id'],
                  name: "${item['firstNameKh']} ${item['lastNameKh']}"),
            );
            mentionValue = null;
            searchResults = [];
            searchResultsAfterMention = [];
            _dismissPopupMenu();
            setState(() {});
          },
        );
      }).toList(),
      constraints: BoxConstraints(
        maxWidth: textFieldSize.width,
        maxHeight: 300,
      ),
    ).then((value) {
      _isPopupMenuVisible = false;
    });

    _isPopupMenuVisible = true;
  }

  void _dismissPopupMenu() {
    if (_isPopupMenuVisible) {
      Navigator.pop(context);
      _isPopupMenuVisible = false;
    }
  }
}
