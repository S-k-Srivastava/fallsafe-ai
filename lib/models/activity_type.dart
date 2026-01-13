/// Activity type labels from the fall detection model
const Map<int, String> activityMap = {
  0: "Back sitting fall",
  1: "Forward fall",
  2: "Sideward fall",
  3: "Straight down fall",
  4: "Walking",
  5: "Jogging",
  6: "Standing",
  7: "Standing up",
  8: "Sitting",
  9: "Sitting on chair",
  10: "Sitting on ground",
  11: "Sit-stand movement",
  12: "Lying",
};

/// Fall-related activity indices (0-3 are fall types)
const Set<int> fallActivityIndices = {0, 1, 2, 3};

/// Get activity name from class index
String getActivityName(int classIndex) {
  return activityMap[classIndex] ?? "Unknown ($classIndex)";
}

/// Check if activity class represents a fall
bool isFallActivity(int classIndex) {
  return fallActivityIndices.contains(classIndex);
}

/// Get activity icon based on type
String getActivityEmoji(int classIndex) {
  switch (classIndex) {
    case 0:
    case 1:
    case 2:
    case 3:
      return "🚨"; // Fall types
    case 4:
      return "🚶"; // Walking
    case 5:
      return "🏃"; // Jogging
    case 6:
    case 7:
      return "🧍"; // Standing
    case 8:
    case 9:
    case 10:
    case 11:
      return "🪑"; // Sitting variations
    case 12:
      return "🛌"; // Lying
    default:
      return "❓";
  }
}
