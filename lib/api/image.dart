class PortainerImage {
  int containers;
  DateTime created;
  String id;
  String parentId;
  int sharedSize;
  int size;
  List<String> repoTags;
  List<String> repoDigests;

  PortainerImage(Map<String, dynamic> image)
      : containers = image["Containers"],
        created = DateTime.fromMillisecondsSinceEpoch(
          image["Created"] * 1000,
          isUtc: true,
        ),
        id = image["Id"],
        parentId = image["ParentId"],
        sharedSize = image["SharedSize"],
        size = image["Size"],
        repoTags = List<String>.from(image["RepoTags"]),
        repoDigests = List<String>.from(image["RepoDigests"]);
}
