import 'package:flutter/material.dart';

class FileBottomSheetWidget extends StatelessWidget {
  final Widget thumbnailWidget;
  final String fileName;
  final String fileDate;
  final List<BottomSheetAction> actions;

  const FileBottomSheetWidget({
    super.key,
    required this.thumbnailWidget,
    required this.fileName,
    required this.fileDate,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 6,
            width: 40,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // File information header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: thumbnailWidget,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName.length > 25
                            ? '${fileName.substring(0, 12)}...${fileName.substring(fileName.length - 12)}'
                            : fileName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fileDate,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action items
          ...actions.map((action) => _buildActionTile(
                icon: action.icon,
                iconColor: action.iconColor,
                title: action.title,
                onTap: action.onTap,
              )),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}

class BottomSheetAction {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  BottomSheetAction({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });
}
