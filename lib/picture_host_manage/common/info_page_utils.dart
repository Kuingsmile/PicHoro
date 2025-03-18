import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void copyToClipboard(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('已复制到剪贴板'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      duration: const Duration(seconds: 1),
      action: SnackBarAction(
        label: '关闭',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}

Widget buildInfoSection(String title, List<Widget> children) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 8),
      ],
    ),
  );
}

Widget buildInfoItem({
  required BuildContext context,
  required String title,
  required String value,
  required IconData icon,
  bool copyable = false,
}) {
  return ListTile(
    leading: Icon(icon, color: Theme.of(context).primaryColor),
    title: Text(title),
    subtitle: SelectableText(
      value,
      style: const TextStyle(fontSize: 15),
    ),
    trailing: copyable
        ? IconButton(
            icon: const Icon(Icons.copy, size: 20),
            onPressed: () => copyToClipboard(context, value),
            tooltip: '复制',
          )
        : null,
  );
}

Widget buildFeatureCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
  required VoidCallback onTap,
}) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      splashColor: color.withValues(alpha: 0.1),
      highlightColor: color.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    ),
  );
}
