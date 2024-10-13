import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sendBy;
  const MessageTile({
    super.key,
    required this.message,
    required this.sender,
    required this.sendBy,
  });

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        top: 2,
        bottom: 4,
        left: widget.sendBy ? 0 : 24,
        right: widget.sendBy ? 24 : 0,
      ),
      alignment: widget.sendBy ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: widget.sendBy
            ? EdgeInsets.only(left: 140)
            : EdgeInsets.only(right: 140),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              widget.sendBy ? Theme.of(context).primaryColor : Colors.grey[700],
          borderRadius: widget.sendBy
              ? BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20))
              : BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              widget.sendBy ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: widget.message,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.copy,
                    size: 20,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.message));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
