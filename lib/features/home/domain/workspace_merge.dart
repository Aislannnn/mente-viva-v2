/// Combines edits made in different sections of the shared workspace.
/// Returns null when both devices changed the same section.
Map<String, dynamic>? mergeWorkspaceChanges({
  required Map<String, dynamic> baseRaw,
  required Map<String, dynamic> baseLocal,
  required Map<String, dynamic> local,
  required Map<String, dynamic> remote,
}) {
  final merged = Map<String, dynamic>.from(remote);
  for (final key in {...baseLocal.keys, ...local.keys}) {
    if (_deepEquals(local[key], baseLocal[key])) continue;
    final remoteChanged =
        !_deepEquals(remote[key], baseRaw[key]) &&
        !_deepEquals(remote[key], baseLocal[key]);
    if (remoteChanged && !_deepEquals(remote[key], local[key])) return null;
    if (local.containsKey(key)) {
      merged[key] = local[key];
    } else {
      merged.remove(key);
    }
  }
  return merged;
}

bool _deepEquals(Object? left, Object? right) {
  if (identical(left, right)) return true;
  if (left is Map && right is Map) {
    if (left.length != right.length) return false;
    for (final key in left.keys) {
      if (!right.containsKey(key) || !_deepEquals(left[key], right[key])) {
        return false;
      }
    }
    return true;
  }
  if (left is List && right is List) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (!_deepEquals(left[index], right[index])) return false;
    }
    return true;
  }
  return left == right;
}
