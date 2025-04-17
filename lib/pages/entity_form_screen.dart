import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

enum FormMode { add, edit }

class EntityFormScreen extends StatefulWidget {
  @override
  _EntityFormScreenState createState() => _EntityFormScreenState();
}

class _EntityFormScreenState extends State<EntityFormScreen> {
  final _idController = TextEditingController();
  final _titleController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  File? _imageFile;
  String _responseText = '';
  FormMode _selectedMode = FormMode.add;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _submitNew() async {
    if (_imageFile == null) {
      setState(() {
        _responseText = 'Please pick an image.';
      });
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://labs.anontech.info/cse489/t3/api.php'),
    );

    String baseImage = base64Encode(_imageFile!.readAsBytesSync());
    // var header = {'Content-Type': 'multipart/form-data'};

    // request.headers['Accept'] = 'application/json'; // or 'text/plain'
    // request.headers['Content-Type'] = 'multipart/form-data';

    request.fields.addAll({
      'title': _titleController.text,
      'lat': _latController.text,
      'lon': _lonController.text,
    });

    request.fields['image'] = baseImage;

    // request.fields['image'] = 'konbanwa';

    // request.files.add(
    //   http.MultipartFile(
    //     'image',
    //     _imageFile!.readAsBytes().asStream(),
    //     _imageFile!.lengthSync(),
    //     filename: _imageFile!.path.split('/').last,
    //     contentType: MediaType('image', 'jpeg'),
    //   ),
    // );

    // request.headers.addAll(header);

    // File file = File(_imageFile!.path);

    // request.files.add(
    //   await http.MultipartFile.fromPath('image', _imageFile!.path),
    // );

    // request.files.add(
    //   http.MultipartFile(
    //     "image",
    //     file.readAsBytes().asStream(),
    //     file.lengthSync(),
    //     filename: file.path.split('/').last,
    //   ),
    // );

    var response = await request.send();

    if (response.statusCode == 200) {
      final result = await response.stream.bytesToString();
      setState(() {
        _responseText = 'Add Success:\n$result';
      });
    } else {
      setState(() {
        _responseText =
            'Add Failed: ${response.statusCode.toString()} ${response.reasonPhrase}';
      });
    }
  }

  Future<void> _updateEntity(int id) async {
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};

    // Prepare the body fields for the update
    var request = http.Request(
      'PUT',
      Uri.parse('https://labs.anontech.info/cse489/t3/api.php'),
    );

    request.bodyFields = {
      'id': id.toString(),
      'title': _titleController.text,
      'lat': _latController.text,
      'lon': _lonController.text,
      'image':
          _imageFile != null ? _imageFile!.path : '', // Placeholder for image
    };

    request.headers.addAll(headers);

    // Send the PUT request
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final result = await response.stream.bytesToString();
      setState(() {
        _responseText = 'Update Success:\n$result';
      });
    } else {
      setState(() {
        _responseText = 'Update Failed: ${response.reasonPhrase}';
      });
    }
  }

  void _handleSubmit() {
    if (_selectedMode == FormMode.add) {
      _submitNew();
    } else {
      final id = int.tryParse(_idController.text);
      if (id != null) {
        _updateEntity(id);
      } else {
        setState(() {
          _responseText = 'Please enter a valid ID to update.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Entity Form')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Mode Selector
              // SizedBox(height: 10),
              Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SegmentedButton<FormMode>(
                    segments: const <ButtonSegment<FormMode>>[
                      ButtonSegment<FormMode>(
                        value: FormMode.add,
                        label: Text('Add'),
                      ),
                      ButtonSegment<FormMode>(
                        value: FormMode.edit,
                        label: Text('Edit'),
                      ),
                    ],
                    selected: <FormMode>{_selectedMode},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _selectedMode = newSelection.first;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              if (_selectedMode == FormMode.edit)
                TextField(
                  controller: _idController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Entity ID'),
                ),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _latController,
                      decoration: InputDecoration(labelText: 'Latitude'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _lonController,
                      decoration: InputDecoration(labelText: 'Longitude'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    child: Text('Gallery'),
                  ),
                  ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    child: Text('Camera'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              _imageFile != null
                  ? Image.file(_imageFile!, height: 150)
                  : Text('No image selected'),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: Text(
                  _selectedMode == FormMode.add ? 'Submit' : 'Update',
                ),
              ),
              SizedBox(height: 20),
              Text(_responseText),
            ],
          ),
        ),
      ),
    );
  }
}
