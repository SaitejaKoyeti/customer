class Truck {
  final String imagePath;
  final String name;
  final String weightCapacity;
  bool isSelected; // Add isSelected property

  Truck({
    required this.imagePath,
    required this.name,
    required this.weightCapacity,
    this.isSelected = false, // Provide a default value for isSelected
  });
}
