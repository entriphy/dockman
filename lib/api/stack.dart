class PortainerStack {
  String createdBy;
  DateTime creationDate;
  int endpointId;
  String entrypoint;
  int id;
  String name;
  String namespace;
  String projectPath;
  int status;
  int type;

  PortainerStack(Map<String, dynamic> stack)
      : createdBy = stack["CreatedBy"],
        creationDate =
            DateTime.fromMillisecondsSinceEpoch(stack["CreationDate"] * 1000),
        endpointId = stack["EndpointId"],
        entrypoint = stack["EntryPoint"],
        id = stack["Id"],
        name = stack["Name"],
        namespace = stack["Namespace"],
        projectPath = stack["ProjectPath"],
        status = stack["Status"],
        type = stack["Type"];
}
