// sign_out_prompt.dart
// ignore_for_file: prefer_const_constructors, deprecated_member_use, use_build_context_synchronously, library_private_types_in_public_api, use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'winterark_home.dart';

class SignOutPrompt extends StatefulWidget {
  final Widget child;
  final Future<void> Function()? onSignOut;

  const SignOutPrompt({
    Key? key,
    required this.child,
    this.onSignOut,
  }) : super(key: key);

  @override
  _SignOutPromptState createState() => _SignOutPromptState();
}

class _SignOutPromptState extends State<SignOutPrompt> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<bool> _confirmSignOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Sign Out?",
          textAlign: TextAlign.center, 
        ),
        actionsAlignment: MainAxisAlignment.center, 
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );
    return shouldSignOut ?? false;
  }

  Future<void> _handleSignOut() async {
    if (await _confirmSignOut()) {
      if (widget.onSignOut != null) {
        await widget.onSignOut!();
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WinterArkHome()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _handleSignOut();
        return false;
      },
      child: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (RawKeyEvent event) async {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            await _handleSignOut();
          }
        },
        child: widget.child,
      ),
    );
  }
}
