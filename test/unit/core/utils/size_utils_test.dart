import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';

void main() {
  group('SizeUtils', () {
    test('should set the correct width and height for portrait orientation',
        () {
      // Arrange
      const constraints = BoxConstraints(maxWidth: 200, maxHeight: 400);
      const orientation = Orientation.portrait;

      // Act
      SizeUtils.setScreenSize(constraints, orientation);

      // Assert
      expect(SizeUtils.width, 200);
      expect(SizeUtils.height, 400);
    });

    test('should set the correct width and height for landscape orientation',
        () {
      // Arrange
      const constraints = BoxConstraints(maxWidth: 300, maxHeight: 150);
      const orientation = Orientation.landscape;

      // Act
      SizeUtils.setScreenSize(constraints, orientation);

      // Assert
      expect(SizeUtils.width, 150);
      expect(SizeUtils.height, 300);
    });
  });

  group('ResponsiveExtension', () {
    test('should return correct width based on viewport width', () {
      // Arrange
      SizeUtils.width = 390;
      const num value = 100;

      // Act
      final result = value.w;

      // Assert
      expect(result, 100);
    });

    test('should return correct height based on viewport height', () {
      // Arrange
      SizeUtils.height = 844;
      const num value = 200;

      // Act
      final result = value.h;

      // Assert
      expect(result, closeTo(200, 0.1));
    });

    test('should return smallest value between width and height', () {
      // Arrange
      SizeUtils.width = 390;
      SizeUtils.height = 844;
      const num value = 50;

      // Act
      final result = value.adaptSize;

      // Assert
      expect(result, 50.w);
    });
  });

  group('FormatException', () {
    test('should return double with specified fraction digits', () {
      // Arrange
      const double value = 123.456789;

      // Act
      final result = value.toDoubleValue(fractionDigits: 2);

      // Assert
      expect(result, 123.46);
    });

    test('should return default value if number is zero', () {
      // Arrange
      const double value = 0.0;
      const double defaultValue = 10.0;

      // Act
      final result = value.isNonZero(defaultValue: defaultValue);

      // Assert
      expect(result, defaultValue);
    });
  });
}
