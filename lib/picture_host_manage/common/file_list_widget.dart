import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

Widget getSlidableAction({
  required IconData icon,
  required Color backgroundColor,
  Color foregroundColor = Colors.white,
  required void Function(BuildContext context) onPressed,
  required String label,
  String position = 'left',
}) {
  return SlidableAction(
    onPressed: onPressed,
    autoClose: true,
    padding: EdgeInsets.zero,
    backgroundColor: backgroundColor,
    foregroundColor: Colors.white,
    icon: icon,
    label: label,
    borderRadius: position == 'left'
        ? const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          )
        : position == 'right'
            ? const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              )
            : const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
  );
}

Widget getFileListWidget({
  required BuildContext context,
  required List<Widget> slidableActions,
  required bool isSelected,
  required Future<Widget> thumbnailWidget,
  required String fileName,
  required String fileDate,
  String? fileSize,
  required VoidCallback onButtonPressed,
  required VoidCallback onTap,
  required VoidCallback onLongPress,
  required Widget mshCheckbox,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    child: Column(
      children: [
        Slidable(
          direction: Axis.horizontal,
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: slidableActions,
          ),
          child: Card(
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.5) : Colors.transparent,
                width: 1.5,
              ),
            ),
            color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Theme.of(context).cardColor,
            child: Stack(
              fit: StackFit.loose,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minLeadingWidth: 0,
                  minVerticalPadding: 0,
                  leading: Container(
                    width: 56,
                    height: 56,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: FutureBuilder<Widget>(
                        future: thumbnailWidget,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Icon(Icons.error, color: Colors.red);
                          } else {
                            return snapshot.data!;
                          }
                        },
                      ),
                    ),
                  ),
                  title: Text(
                    fileName.length > 25
                        ? '${fileName.substring(0, 12)}...${fileName.substring(fileName.length - 12)}'
                        : fileName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          fileDate.isEmpty
                              ? const SizedBox.shrink()
                              : const Icon(
                                  Icons.access_time_outlined,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                          fileDate.isEmpty ? const SizedBox(width: 4) : const SizedBox.shrink(),
                          fileDate.isEmpty
                              ? const SizedBox.shrink()
                              : Text(
                                  fileDate,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                        ],
                      ),
                      fileSize != null ? const SizedBox(height: 4) : const SizedBox.shrink(),
                      fileSize != null
                          ? Row(
                              children: [
                                const Icon(
                                  Icons.file_present_outlined,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  fileSize,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.more_horiz,
                        color: Colors.blueGrey,
                      ),
                      onPressed: onButtonPressed,
                    ),
                  ),
                  onTap: onTap,
                  onLongPress: onLongPress,
                ),
                Positioned(
                  left: 2,
                  top: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(55)),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: mshCheckbox,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
