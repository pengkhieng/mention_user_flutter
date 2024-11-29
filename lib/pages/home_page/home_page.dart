import 'package:flutter/material.dart';
import 'package:testing/pages/mention_page/mention_tag_textField.dart';

class HomePage extends StatelessWidget {
  void showFullScreenPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allows dismissal by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          insetPadding:
              EdgeInsets.zero, // Remove padding to make it full screen
          backgroundColor:
              Colors.transparent, // Optional: transparent background
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color:
                Colors.green.withOpacity(.2), // Background color of the popup
            child: Stack(
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    width: MediaQuery.of(context).size.width / 2,
                    child: MentionTagTextFieldExample(),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full-Screen Popup Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => showFullScreenPopup(context),
          child: Text('Show Full-Screen Popup'),
        ),
      ),
    );
  }
}
