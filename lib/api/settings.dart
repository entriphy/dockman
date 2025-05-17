class PortainerApiSettings {
  int authenticationMethod;

  PortainerApiSettings(Map<String, dynamic> settings)
      : authenticationMethod = settings["AuthenticationMethod"];
}
