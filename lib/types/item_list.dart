import 'package:flutter/material.dart';

abstract class FileItemList {
  /// The title line to show in a list item.
  Widget buildTitle(BuildContext context);

  /// The subtitle line, if any, to show in a list item.
  Widget buildSubtitle(BuildContext context);
}

/// A ListItem that contains data to display a message.
class MessageItemList implements FileItemList {
  final String sender;
  final String body;

  MessageItemList(this.sender, this.body, message);

  @override
  Widget buildTitle(BuildContext context) {
    return (Text(sender));
  }

  @override
  Widget buildSubtitle(BuildContext context) {
    return (TextButton(
      child: Text(body),
      onPressed: () {
        Navigator.pushNamed(
          context,
          "item/edit",
          arguments: <String, String>{
            'type': 'edit',
            'country': 'Germany',
          },
        );
      },
    ));
  }
}
