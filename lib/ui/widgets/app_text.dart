import 'dart:ui';

import 'package:chat_babakcode/constants/app_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../../providers/global_setting_provider.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? size;
  final FontWeight? fontWeight;
  final Color? color;
  final String? fontFamily;

  const AppText(this.text,
      {
      this.size,
      this.style,
      this.color,
      this.fontWeight,
      this.fontFamily,
      super.key});

  @override
  Widget build(BuildContext context) {
    final sharedProvider = context.watch<GlobalSettingProvider>();
    return Text(
      text,
      style: style ??
          TextStyle(
            fontSize: size,
            fontFamily: fontFamily,
            fontWeight: fontWeight,
            color: color ??
                (sharedProvider.isDarkTheme ? AppConstants.textColor.shade100 : AppConstants.textColor[800]),
          ),
    );
  }
}
