class WorkspaceData {
  const WorkspaceData({
    required this.assistedId,
    required this.version,
    required this.data,
  });

  final String assistedId;
  final int version;
  final Map<String, dynamic> data;
}

class WorkspaceConflict implements Exception {
  const WorkspaceConflict();
}

abstract class WorkspaceRepository {
  Future<WorkspaceData?> load(String role);
  Future<int> save(WorkspaceData current, Map<String, dynamic> data);
  Future<String> createInvite();
  Future<void> redeemInvite(String code);
}
