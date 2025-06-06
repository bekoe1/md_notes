import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:md_notes/code_kit/theme/app_themes.dart' show EndernoteColors;

import '../../bloc/directory/directory_bloc.dart';
import '../../bloc/directory/directory_events.dart';

class CustomFAB extends StatelessWidget {
  const CustomFAB({super.key, required this.rootPath});

  final String rootPath;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isDialOpen = ValueNotifier(false);
    final TextEditingController folderController = TextEditingController();
    final TextEditingController fileController = TextEditingController();

    return SpeedDial(
      openCloseDial: isDialOpen,
      children: [
        _buildDialChild(
          context,
          controller: folderController,
          icon: Icons.link,
          label: "Import",
          onCreate: () async {
            context.read<DirectoryBloc>().add(
                  ImportNotes(),
                );
          },
        ),
        _buildDialChild(
          context,
          controller: folderController,
          icon: IconsaxPlusLinear.folder,
          label: "Folder",
          onCreate: () async {
            if (folderController.text.isNotEmpty) {
              await Directory(
                '$rootPath/${folderController.text}',
              ).create(recursive: true);
              context.read<DirectoryBloc>().add(
                    FetchDirectory(
                      path: rootPath,
                    ),
                  );
            }
            Navigator.pop(context);
            folderController.clear();
          },
        ),
        _buildDialChild(
          context,
          controller: fileController,
          icon: IconsaxPlusLinear.task_square,
          label: "Note",
          onCreate: () async {
            if (fileController.text.isNotEmpty) {
              await File(
                '$rootPath/${fileController.text}.md',
              ).create(recursive: true);
              context.read<DirectoryBloc>().add(
                    FetchDirectory(
                      path: rootPath,
                    ),
                  );
            }
            Navigator.pop(context);
            fileController.clear();
          },
        ),
      ],
      child: const Icon(IconsaxPlusLinear.add),
    );
  }

  SpeedDialChild _buildDialChild(
    BuildContext context, {
    required TextEditingController controller,
    required IconData icon,
    required String label,
    bool needToOpenWindow = false,
    required Future<void> Function() onCreate,
  }) {
    return SpeedDialChild(
      child: Icon(icon),
      label: label,
      onTap: () {
        if (!needToOpenWindow) {
          onCreate();
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor:
                  Theme.of(context).extension<EndernoteColors>()?.clrBase,
              title: Text(
                'New $label',
                style: TextStyle(
                  color:
                      Theme.of(context).extension<EndernoteColors>()?.clrText,
                ),
              ),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '$label name',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onSubmitted: (value) => onCreate(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    controller.clear();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: onCreate,
                  child: const Text('Create'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
