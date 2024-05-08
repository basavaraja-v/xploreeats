String getFormattedCount(num count) {
  if (count >= 1000000000) {
    return '${(count / 1000000000).toStringAsFixed(1)}B';
  } else if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1)}M';
  } else if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}K';
  } else {
    return count.toInt().toString();
  }
}
