import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';

class ImportExcelScreen extends StatefulWidget {
  @override
  _ImportExcelScreenState createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends State<ImportExcelScreen> {
  final ApiService _apiService = ApiService();
  bool _isUploading = false;
  bool _isComplete = false;
  bool _isError = false;
  String _errorMessage = '';
  String _selectedFilePath = '';
  String _selectedFileName = '';
  Map<String, dynamic> _importResult = {};

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Import Excel Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column - Instructions and file selection
        Expanded(
          flex: 1,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Import Excel Data',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  SizedBox(height: 16),
                  _buildInstructions(),
                  SizedBox(height: 24),
                  _buildFileSelection(),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        // Right column - Results
        Expanded(
          flex: 1,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Import Results',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  SizedBox(height: 16),
                  _buildResults(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Import Excel Data',
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildInstructions(),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildFileSelection(),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Import Results',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 16),
                  _buildResults(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Instructions',
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 8),
        Text(
          'You can import client and account data from an Excel file. The Excel file should contain the following worksheets:',
        ),
        SizedBox(height: 8),
        _buildInstructionItem('Clients', 'Client information including name, contact details, etc.'),
        _buildInstructionItem('Accounts', 'Account information linked to clients'),
        _buildInstructionItem('Activities', 'Transaction activities for each account'),
        _buildInstructionItem('Performance', 'Performance metrics for each account'),
        SizedBox(height: 16),
        Text(
          'Note: Each worksheet must contain specific columns. Please refer to the documentation for the required format.',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Excel File',
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 16),
        _selectedFilePath.isEmpty
            ? ElevatedButton.icon(
                icon: Icon(Icons.upload_file),
                label: Text('Choose File'),
                onPressed: _pickExcelFile,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, color: Colors.blue),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedFileName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _selectedFilePath = '';
                            _selectedFileName = '';
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.upload),
                          label: Text('Upload and Import'),
                          onPressed: _isUploading ? null : _uploadExcelFile,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        if (_isUploading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                LinearProgressIndicator(),
                SizedBox(height: 8),
                Text(
                  'Uploading and processing file...',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        if (_isError)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildResults() {
    if (_isUploading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_isError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          SizedBox(height: 16),
          Text(
            'Import Failed',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    
    if (_isComplete && _importResult.isNotEmpty) {
      // Display successful import results
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Import Successful',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Imported Worksheets:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ..._buildImportedSheetsList(),
          SizedBox(height: 16),
          ElevatedButton.icon(
            icon: Icon(Icons.home),
            label: Text('Return to Dashboard'),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
          ),
        ],
      );
    }
    
    // Default state - no import yet
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.upload_file,
            color: Colors.grey,
            size: 60,
          ),
          SizedBox(height: 16),
          Text(
            'No Import Results Yet',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Select and upload an Excel file to see import results',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildImportedSheetsList() {
    List<Widget> sheetWidgets = [];
    
    if (_importResult.containsKey('sheets')) {
      final sheets = _importResult['sheets'] as List<dynamic>;
      
      for (var sheet in sheets) {
        sheetWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Icon(Icons.check, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text(sheet.toString()),
              ],
            ),
          ),
        );
      }
    }
    
    return sheetWidgets;
  }

  Future<void> _pickExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );

      if (result != null) {
        setState(() {
          _selectedFilePath = result.files.single.path ?? '';
          _selectedFileName = result.files.single.name;
          _isError = false;
          _errorMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = 'Error selecting file: ${e.toString()}';
      });
    }
  }

  Future<void> _uploadExcelFile() async {
    if (_selectedFilePath.isEmpty) {
      setState(() {
        _isError = true;
        _errorMessage = 'Please select a file first';
      });
      return;
    }

    try {
      setState(() {
        _isUploading = true;
        _isError = false;
        _errorMessage = '';
        _isComplete = false;
      });

      // Upload the file
      final result = await _apiService.importExcelFile(_selectedFilePath);
      
      setState(() {
        _isUploading = false;
        _isComplete = true;
        _importResult = result;
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
        _isError = true;
        _errorMessage = 'Error uploading file: ${e.toString()}';
      });
    }
  }
}
