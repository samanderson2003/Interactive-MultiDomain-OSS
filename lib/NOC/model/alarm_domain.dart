enum AlarmDomain { ran, core, ip, transport, security, application }

extension AlarmDomainExtension on AlarmDomain {
  String get displayName {
    switch (this) {
      case AlarmDomain.ran:
        return 'RAN';
      case AlarmDomain.core:
        return 'CORE';
      case AlarmDomain.ip:
        return 'IP Transport';
      case AlarmDomain.transport:
        return 'Transport';
      case AlarmDomain.security:
        return 'Security';
      case AlarmDomain.application:
        return 'Application';
    }
  }

  String get shortName {
    switch (this) {
      case AlarmDomain.ran:
        return 'RAN';
      case AlarmDomain.core:
        return 'CORE';
      case AlarmDomain.ip:
        return 'IP';
      case AlarmDomain.transport:
        return 'TRN';
      case AlarmDomain.security:
        return 'SEC';
      case AlarmDomain.application:
        return 'APP';
    }
  }
}
