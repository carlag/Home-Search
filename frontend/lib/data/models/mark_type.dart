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

MarkType? markTypeFromJSON(String markType) {
  if (markType == MarkType.liked.string) {
    return MarkType.liked;
  }
  if (markType == MarkType.rejected.string) {
    return MarkType.rejected;
  }
  if (markType == MarkType.unsure.string) {
    return MarkType.unsure;
  }
  return null;
}
