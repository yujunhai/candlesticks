class AABBRangeX {
  final double minX;
  final double maxX;

  AABBRangeX(this.minX, this.maxX);

  AABBRangeX operator -(AABBRangeX other) {
    return AABBRangeX(this.minX - other.minX, this.maxX - other.maxX);
  }

  AABBRangeX operator +(AABBRangeX other) {
    return AABBRangeX(this.minX + other.minX, this.maxX - other.maxX);
  }

  AABBRangeX operator *(double process) {
    return AABBRangeX(this.minX * process, this.maxX * process);
  }

  double get width => maxX - minX;
}