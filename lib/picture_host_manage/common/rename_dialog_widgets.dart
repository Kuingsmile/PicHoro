import 'package:flutter/material.dart';

class RenameDialog extends AlertDialog {
  RenameDialog({super.key, required Widget contentWidget})
      : super(
          content: contentWidget,
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.white,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
}

class RenameDialogContent extends StatefulWidget {
  final String title;
  final String cancelButtonText;
  final String confirmButtonTitle;
  final VoidCallback onCancel;
  final Function(bool isCoverFile) onConfirm;
  final TextEditingController renameTextController;
  final String isCoverMsg;
  final double buttonHeight;
  final double borderWidth;
  final bool isShowCoverFileWidget;

  const RenameDialogContent({
    super.key,
    required this.title,
    this.cancelButtonText = "取消",
    this.confirmButtonTitle = "确定",
    this.buttonHeight = 50,
    this.borderWidth = 1,
    this.isShowCoverFileWidget = false,
    this.isCoverMsg = "是否覆盖同名文件",
    required this.onCancel,
    required this.onConfirm,
    required this.renameTextController,
  });

  @override
  RenameDialogContentState createState() => RenameDialogContentState();
}

class RenameDialogContentState extends State<RenameDialogContent> {
  var isCoverFile = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final backgroundColor = Colors.grey.shade50;

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      constraints: BoxConstraints(
        minHeight: 200,
        maxHeight: widget.isShowCoverFileWidget ? 250 : 200,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Text(
              widget.title,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: TextFormField(
              cursorHeight: 20,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
              controller: widget.renameTextController,
              validator: (value) {
                if (value!.isEmpty) {
                  return '不能为空';
                }
                return null;
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                filled: true,
                fillColor: Colors.grey.shade100,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
          ),
          if (widget.isShowCoverFileWidget)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Checkbox(
                    value: isCoverFile,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setState(() {
                        isCoverFile = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      widget.isCoverMsg,
                      style: const TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          Divider(height: 1, color: Colors.grey.shade300),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      widget.renameTextController.text = "";
                      widget.onCancel();
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                    ),
                    child: Text(
                      widget.cancelButtonText,
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                  ),
                ),
                VerticalDivider(width: 1, color: Colors.grey.shade300),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      widget.onConfirm(isCoverFile);
                      Navigator.of(context).pop();
                      widget.renameTextController.text = "";
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                    ),
                    child: Text(
                      widget.confirmButtonTitle,
                      style: TextStyle(fontSize: 16, color: primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
