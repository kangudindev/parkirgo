class SessionStatus {
  static const String active = 'active';
  static const String exited = 'exited';
  static const String voided = 'void';
}

class PaymentTiming {
  static const String entry = 'entry';
  static const String exit = 'exit';
}

class PaymentStatus {
  static const String unpaid = 'unpaid';
  static const String paid = 'paid';
}

class PaymentMethod {
  static const String cash = 'cash';
  static const String qris = 'qris';
}

class PaymentRecordStatus {
  static const String recorded = 'recorded';
  static const String verified = 'verified';
  static const String rejected = 'rejected';
}

class SyncStatus {
  static const String synced = 'synced';
  static const String pending = 'pending';
}

class PricingType {
  static const String flat = 'flat';
  static const String progressive = 'progressive';
}

class Role {
  static const String jukir = 'jukir';
  static const String supervisor = 'supervisor';
  static const String admin = 'admin';
}
