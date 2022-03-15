



import 'package:flutter/material.dart';

void showScaffoldMessage(BuildContext ctx,String message) {
  ScaffoldMessenger.of(ctx)
      .showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Color(0xfff28516)
            ),
          ),
          backgroundColor: const Color(0xff120c0c),
        )
      );
}

