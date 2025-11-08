import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../config/api_endpoints.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final Dio _dio = Dio();
  String _status = 'Not tested';
  String _response = '';
  bool _isLoading = false;

  Future<void> _testApi() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing...';
      _response = '';
    });

    try {
      // Test basic connectivity
      final response = await _dio.get('http://10.0.2.2:8000/');
      
      setState(() {
        _status = 'Connection successful! ✅';
        _response = response.data.toString();
      });
    } catch (e) {
      setState(() {
        _status = 'Connection failed! ❌';
        _response = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testHealthEndpoint() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing health endpoint...';
      _response = '';
    });

    try {
      final response = await _dio.get('http://10.0.2.2:8000/health');
      
      setState(() {
        _status = 'Health check passed! ✅';
        _response = response.data.toString();
      });
    } catch (e) {
      setState(() {
        _status = 'Health check failed! ❌';
        _response = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGenerationEndpoint() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing generation endpoint...';
      _response = '';
    });

    try {
      final response = await _dio.post(
        'http://10.0.2.2:8000/test-generation',
        data: {
          'prompt': 'A beautiful sunset over mountains',
          'style': 'vintage_poster',
        },
      );
      
      setState(() {
        _status = 'Generation test passed! ✅';
        _response = response.data.toString();
      });
    } catch (e) {
      setState(() {
        _status = 'Generation test failed! ❌';
        _response = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Connection Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Base URL:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      ApiEndpoints.baseUrl,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Divider(height: 24),
                    Text(
                      'Status: $_status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: _testApi,
                    icon: const Icon(Icons.network_check),
                    label: const Text('Test Basic Connection'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _testHealthEndpoint,
                    icon: const Icon(Icons.favorite),
                    label: const Text('Test Health Endpoint'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _testGenerationEndpoint,
                    icon: const Icon(Icons.image),
                    label: const Text('Test Generation Endpoint'),
                  ),
                ],
              ),
            if (_response.isNotEmpty) ...[
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Response:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            _response,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}