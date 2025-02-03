class UserStats {
  final int conversationCount;
  final int totalPoints;
  final List<Achievement> achievements;
  final String currentLevel;

  UserStats({
    required this.conversationCount,
    required this.totalPoints,
    required this.achievements,
    required this.currentLevel,
  });
}

class Achievement {
  final String name;
  final String icon;
  final int pointsRequired;
  final bool isUnlocked;

  Achievement({
    required this.name,
    required this.icon,
    required this.pointsRequired,
    required this.isUnlocked,
  });
}
