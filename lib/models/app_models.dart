// lib/models/app_models.dart
import 'package:flutter/material.dart';

/// App usage tracking model
class AppUsageRecord {
  final String appName;
  final DateTime timestamp;
  final int minutesUsed;
  final String category;

  AppUsageRecord({
    required this.appName,
    required this.timestamp,
    required this.minutesUsed,
    required this.category,
  });
}

/// Activity log model
class ActivityLog {
  final String event;
  final DateTime timestamp;
  final String type; // 'app_usage', 'lock', 'unlock', 'website', 'system'

  ActivityLog({
    required this.event,
    required this.timestamp,
    required this.type,
  });
}

/// App blocking/control model
class AppControl {
  final String name;
  final String category;
  bool blocked;
  int timeLimitMinutes;
  int dailyUsageMinutes;
  final DateTime? lastAccessTime;

  AppControl({
    required this.name,
    required this.category,
    this.blocked = false,
    this.timeLimitMinutes = 60,
    this.dailyUsageMinutes = 0,
    this.lastAccessTime,
  });
}

/// Website filtering model
class WebsiteFilter {
  final String domain;
  final String category; // 'social', 'gaming', 'streaming', 'education', 'blocked'
  bool allowed;

  WebsiteFilter({
    required this.domain,
    required this.category,
    this.allowed = true,
  });
}

/// Downtime schedule model
class DowntimeSchedule {
  final String name;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<String> daysOfWeek; // ['Mon', 'Tue', ...]
  bool enabled;

  DowntimeSchedule({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
    this.enabled = true,
  });
}
