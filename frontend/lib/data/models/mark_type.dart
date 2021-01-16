enum MarkType {
  liked,
  rejected,
  unsure,
}

extension MarkTypeString on MarkType {
  String get string {
    switch (this) {
      case MarkType.liked:
        return 'liked';
      case MarkType.rejected:
        return 'rejected';
      case MarkType.unsure:
        return 'unsure';
      default:
        throw ('Unexpected MarkType');
    }
  }
}
