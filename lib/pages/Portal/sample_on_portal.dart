import 'package:flutter/material.dart';

class TextFieldMenuWithDXExample extends StatefulWidget {
  @override
  _TextFieldMenuWithDXExampleState createState() =>
      _TextFieldMenuWithDXExampleState();
}

class _TextFieldMenuWithDXExampleState
    extends State<TextFieldMenuWithDXExample> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _textFieldKey = GlobalKey(); // GlobalKey for TextField
  List<String> _items = [
    'Option1',
    'Option2',
    'Option3',
    'Option4',
    'Option5',
    'Option6',
  ];

  // This will hold the value selected from the PopupMenu
  String _selectedValue = '';

  // Listen for text changes and show popup when '@' is typed
  void _textChangedListener(String text) {
    if (text.contains('@')) {
      _showPopupMenu(context);
    }
  }

  void _showPopupMenu(BuildContext context) {
    // Get the position of the TextField using GlobalKey
    final RenderBox renderBox =
        _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

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
      items: _items.map((item) {
        return PopupMenuItem<String>(
          value: item,
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.green,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('This is the description for $item.')
              ],
            ),
          ),
        );
      }).toList(),
      constraints: BoxConstraints(
        maxWidth: textFieldSize
            .width, // Make the popup width equal to the TextField width
      ),
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedValue = value; // Update selected value
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected: $value')),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      _textChangedListener(_controller.text); // Listen for text changes
    });
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popup Under TextField')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              key: _textFieldKey, // Assign the GlobalKey to the TextField
              controller: _controller,
              focusNode: _focusNode,
              minLines: 5,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Type here and type "@" to see popup',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text('Selected: $_selectedValue'),
          ],
        ),
      ),
    );
  }
}
