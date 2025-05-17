import 'package:dockman/preferences.dart';
import 'package:flutter/material.dart';

class ConnectionDialog extends StatefulWidget {
  const ConnectionDialog({super.key});

  @override
  ConnectionDialogState createState() => ConnectionDialogState();
}

class ConnectionDialogState extends State<ConnectionDialog> {
  String _host = "";
  String _token = "";
  String? _error;
  bool connecting = false;

  final _formKey = GlobalKey<FormState>();

  void _onSubmit(BuildContext context) async {
    _formKey.currentState!.save();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final connection = DockerConnection("", _host, _token);
    setState(() => connecting = true);
    try {
      final api = connection.createAPI();
      await api.getApiSettings();
      if (context.mounted) Navigator.pop(context, connection);
    } catch (e) {
      setState(() => _error = e.toString());
    }
    setState(() => connecting = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Connect to Portainer"),
      content: Form(
        key: _formKey,
        child: Column(
          spacing: 8.0,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                label: Text("Portainer URL"),
                helperText: "ex. http://192.168.0.2:9000",
                icon: Icon(Icons.settings_ethernet),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? "Please enter a value." : null,
              onSaved: (value) => _host = value!,
            ),
            TextFormField(
              decoration: const InputDecoration(
                label: Text("Access Token"),
                helperText: "ex. ptr_xxxxx",
                icon: Icon(Icons.key),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? "Please enter a value." : null,
              onSaved: (value) => _token = value!,
            ),
            if (_error != null) Text(_error!)
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: connecting ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: connecting ? null : () => _onSubmit(context),
          child: const Text("Ok"),
        ),
      ],
    );
  }
}
