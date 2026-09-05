/// How many columns a grid should use for a given width.
///
/// 1 column on a phone in portrait, 2 once the screen is wide enough for a
/// phone in landscape or a small tablet, and 3 on a large tablet.
int gridColumnsFor(double width) {
  if (width >= 900) {
    return 3;
  }
  if (width >= 600) {
    return 2;
  }
  return 1;
}

bool isWide(double width) => width >= 600;
