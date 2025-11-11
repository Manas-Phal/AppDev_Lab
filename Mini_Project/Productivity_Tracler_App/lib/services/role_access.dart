class RoleAccess {
  // Role types: guest, user, vip, admin(student), admin(professor)
  
  static bool isGuest(String role) {
    return role == 'guest' || role.isEmpty;
  }
  
  static bool isUser(String role) {
    return role == 'user';
  }
  
  static bool isVIP(String role) {
    return role == 'vip';
  }
  
  static bool isAdmin(String role) {
    return role.startsWith('admin');
  }
  
  static bool isAdminStudent(String role) {
    return role == 'admin(student)';
  }
  
  static bool isAdminProfessor(String role) {
    return role == 'admin(professor)';
  }
  
  // Check if user has access to analytics (VIP and Professor only)
  static bool hasAnalyticsAccess(String role) {
    return isVIP(role) || isAdminProfessor(role);
  }
  
  // Check if user has limited access
  static bool hasLimitedAccess(String role) {
    return isUser(role) || isAdminStudent(role);
  }
  
  // Get role display name
  static String getRoleDisplayName(String role) {
    switch (role) {
      case 'guest':
        return 'Guest';
      case 'user':
        return 'User';
      case 'vip':
        return 'VIP';
      case 'admin(student)':
        return 'Admin (Student)';
      case 'admin(professor)':
        return 'Admin (Professor)';
      default:
        return 'User';
    }
  }
}

