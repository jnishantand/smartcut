import 'package:flutter/material.dart';
import '../models/salon_service.dart';

class BookingProvider extends ChangeNotifier {
  SalonService? _selectedService;
  String? _selectedStaffName; // e.g. "Any Available", "Michael Brown"
  String? _selectedStaffId; // e.g. "any", "uuid_123"
  DateTime? _selectedDate;
  String? _selectedTime;

  SalonService? get selectedService => _selectedService;
  String? get selectedStaffName => _selectedStaffName;
  String? get selectedStaffId => _selectedStaffId;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedTime => _selectedTime;

  void selectService(SalonService service) {
    _selectedService = service;
    notifyListeners();
  }

  void selectStaff(String id, String name) {
    _selectedStaffId = id;
    _selectedStaffName = name;
    notifyListeners();
  }

  void selectDateTime(DateTime date, String time) {
    _selectedDate = date;
    _selectedTime = time;
    notifyListeners();
  }

  void reset() {
    _selectedService = null;
    _selectedStaffName = null;
    _selectedStaffId = null;
    _selectedDate = null;
    _selectedTime = null;
    notifyListeners();
  }
}
