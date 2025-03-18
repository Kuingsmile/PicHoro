import 'package:flutter/material.dart';

class NewFolderDialog extends AlertDialog {
  NewFolderDialog({super.key, required Widget contentWidget})
      : super(
          content: contentWidget,
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
          backgroundColor: Colors.white,
        );
}

class NewFolderDialogContent extends StatefulWidget {
  final double buttonHeight;
  final double borderWidth;
  final String title;
  final String cancelButtonLabel;
  final String confirmButtonTitle;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final TextEditingController folderNameController;

  const NewFolderDialogContent({
    super.key,
    required this.title,
    this.cancelButtonLabel = "取消",
    this.confirmButtonTitle = "确定",
    this.buttonHeight = 50,
    this.borderWidth = 1,
    required this.onCancel,
    required this.onConfirm,
    required this.folderNameController,
  });

  @override
  NewFolderDialogContentState createState() => NewFolderDialogContentState();
}

class NewFolderDialogContentState extends State<NewFolderDialogContent> {
  final _formKey = GlobalKey<FormState>();
  bool _isValid = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 350),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF303030),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                cursorHeight: 20,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                controller: widget.folderNameController,
                autofocus: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    setState(() => _isValid = false);
                    return '文件夹名称不能为空';
                  }
                  setState(() => _isValid = true);
                  return null;
                },
                decoration: InputDecoration(
                  labelText: '文件夹名称',
                  hintText: '请输入新文件夹的名称',
                  prefixIcon: const Icon(Icons.folder_outlined),
                  filled: true,
                  fillColor: Colors.grey[50],
                  errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.primaryColor, width: 2),
                  ),
                ),
                onChanged: (value) {
                  if (!_isValid) {
                    _formKey.currentState?.validate();
                  }
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      widget.folderNameController.text = "";
                      widget.onCancel();
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Text(
                      widget.cancelButtonLabel,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onConfirm();
                        Navigator.of(context).pop();
                        widget.folderNameController.text = "";
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.confirmButtonTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
