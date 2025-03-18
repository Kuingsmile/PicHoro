import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';

class ConfigureWidgets {
  static Widget buildSettingCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
        ],
      ),
    );
  }

  static Widget buildSettingItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
    Color? iconColor,
    Widget? subtitle,
    required BuildContext context,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor ?? Theme.of(context).primaryColor.withAlpha(51),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
      ),
      title: Text(title),
      subtitle: subtitle,
      onTap: onTap,
      trailing: trailing,
    );
  }

  static Widget buildFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: validator,
      ),
    );
  }

  static AppBar buildConfigAppBar({required String title, required BuildContext context}) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      title: titleText(
        title,
        fontsize: 18,
      ),
      flexibleSpace: getFlexibleSpace(context),
    );
  }

  static Widget buildDivider() {
    return const Divider(height: 1, indent: 56);
  }
}
