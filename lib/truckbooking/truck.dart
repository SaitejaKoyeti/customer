class Truck {
  final String imagePath;
  final String name;
  final double price;
  final double weightCapacity;
  bool isSelected; // Add isSelected property

  Truck({
    required this.imagePath,
    required this.name,
    required this.price,
    required this.weightCapacity,
    this.isSelected = false, // Provide a default value for isSelected
  });
}