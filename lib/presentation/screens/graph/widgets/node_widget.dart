import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NodeWidget extends StatelessWidget {
  const NodeWidget({
    super.key,
    required this.title,
    required this.folderType,
  });

  final String title;
  final bool folderType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: folderType ? Colors.red : Colors.blueAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(folderType ? 6 : 10),
          child: Row(
            children: [
              if (folderType) ...[
                Icon(Icons.folder_copy_outlined),
                SizedBox(width: 3),
              ],
              Text(
                title,
              ),
            ],
          ),
        ),
      ),
    );
    ;
  }
}
