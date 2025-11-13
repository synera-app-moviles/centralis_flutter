enum Position {
  employee('EMPLOYEE'),
  manager('MANAGER'),
  director('DIRECTOR');

  const Position(this.value);
  final String value;

  static Position? fromValue(String? value) {
    if (value == null) return null;
    for (Position position in Position.values) {
      if (position.value == value.toUpperCase()) {
        return position;
      }
    }
    return null;
  }
}

enum Department {
  sales('SALES'),
  operations('OPERATIONS'),
  humanResources('HUMAN_RESOURCES'),
  finance('FINANCE'),
  administration('ADMINISTRATION'),
  it('IT'),
  other('OTHER');

  const Department(this.value);
  final String value;

  static Department? fromValue(String? value) {
    if (value == null) return null;
    for (Department department in Department.values) {
      if (department.value == value.toUpperCase()) {
        return department;
      }
    }
    return null;
  }
}

extension PositionExtension on Position {
  String get displayName {
    switch (this) {
      case Position.employee:
        return 'Employee';
      case Position.manager:
        return 'Manager';
      case Position.director:
        return 'Director';
    }
  }
}

extension DepartmentExtension on Department {
  String get displayName {
    switch (this) {
      case Department.sales:
        return 'Sales';
      case Department.operations:
        return 'Operations';
      case Department.humanResources:
        return 'Human Resources';
      case Department.finance:
        return 'Finance';
      case Department.administration:
        return 'Administration';
      case Department.it:
        return 'Information Technology';
      case Department.other:
        return 'Other';
    }
  }
}