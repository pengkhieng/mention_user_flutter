import 'package:flutter/material.dart';
import 'package:testing/pages/mention_page/mention_tag_textField.dart';

class HomePage extends StatelessWidget {
  void showFullScreenPopup(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
              insetPadding: EdgeInsets.zero,
              backgroundColor: Colors.transparent,
              child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.green.withOpacity(.2),
                  child: Stack(children: [
                    Center(
                        child: Container(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            width: MediaQuery.of(context).size.width / 2,
                            child: CustomMention())),
                    Positioned(
                        top: 40,
                        right: 20,
                        child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop();
                            }))
                  ])));
        });
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
                child: Text('Show Full-Screen Popup'))));
  }
}
