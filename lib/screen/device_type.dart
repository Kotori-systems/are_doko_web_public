import 'package:flutter/material.dart';

/// デバイスの種類を判定する
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

DeviceType getDeviceType(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth < 430) {
    // 430pxはiPhone最大の横幅と思われる（iPhone 14 Pro Maxなど）
    return DeviceType.mobile;
  } else if (screenWidth < 1024) {
    // 1024pxはiPad最大の横幅(短い方)と思われる（iPad Pro 12.9 inchなど）
    return DeviceType.tablet;
  } else {
    return DeviceType.desktop;
  }
}
