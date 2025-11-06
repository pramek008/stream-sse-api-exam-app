import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stream vs Static API Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StreamDemoPage(),
    );
  }
}

class StreamDemoPage extends StatefulWidget {
  const StreamDemoPage({super.key});

  @override
  State<StreamDemoPage> createState() => _StreamDemoPageState();
}

class _StreamDemoPageState extends State<StreamDemoPage> {
  // Base URL for our API endpoints
  final String baseUrl = 'https://sse-example-api.ekanovation.my.id';

  // Dio instance configured for streaming
  final Dio dio = Dio();

  // State management for SSE Stream
  String sseText = '';
  bool sseLoading = false;

  // State management for NDJSON Stream
  String ndjsonText = '';
  bool ndjsonLoading = false;

  // State management for Static Response
  String staticText = '';
  bool staticLoading = false;

  @override
  void initState() {
    super.initState();
    // Configure Dio to handle streaming responses
    dio.options.responseType = ResponseType.stream;
  }

  /// Method 1: SSE (Server-Sent Events) Stream
  /// Format: "data: {...}\n\n"
  /// Use case: Real-time updates, similar to ChatGPT streaming
  Future<void> fetchSSEStream() async {
    setState(() {
      sseText = '';
      sseLoading = true;
    });

    try {
      // Make GET request with stream response type
      final response = await dio.get(
        '$baseUrl/stream-sse',
        options: Options(responseType: ResponseType.stream),
      );

      // Get the stream from response
      final stream = response.data.stream;

      // Listen to stream chunks
      await for (var chunk in stream) {
        // Decode bytes to string
        final text = utf8.decode(chunk);

        // Parse SSE format: "data: {...}\n\n"
        final lines = text.split('\n');
        for (var line in lines) {
          if (line.startsWith('data: ')) {
            // Remove "data: " prefix
            final jsonStr = line.substring(6);
            try {
              final data = json.decode(jsonStr);

              // Check if stream is finished
              if (data['finish'] == false && data['content'] != null) {
                // Update UI with new content (word by word)
                setState(() {
                  sseText += data['content'];
                });
              } else if (data['finish'] == true) {
                // Stream complete
                setState(() {
                  sseLoading = false;
                });
                return;
              }
            } catch (e) {
              // Skip invalid JSON lines
            }
          }
        }
      }
    } catch (e) {
      setState(() {
        sseText = 'Error: $e';
        sseLoading = false;
      });
    }
  }

  /// Method 2: NDJSON (Newline Delimited JSON) Stream
  /// Format: "{...}\n{...}\n"
  /// Use case: Similar to Ollama API response format
  Future<void> fetchNDJSONStream() async {
    setState(() {
      ndjsonText = '';
      ndjsonLoading = true;
    });

    try {
      // Make GET request with stream response type
      final response = await dio.get(
        '$baseUrl/stream-ndjson',
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data.stream;
      String buffer = ''; // Buffer for incomplete JSON lines

      // Listen to stream chunks
      await for (var chunk in stream) {
        buffer += utf8.decode(chunk);

        // Split by newline to get individual JSON objects
        final lines = buffer.split('\n');
        // Keep last incomplete line in buffer
        buffer = lines.last;

        // Process complete lines
        for (int i = 0; i < lines.length - 1; i++) {
          final line = lines[i].trim();
          if (line.isNotEmpty) {
            try {
              final data = json.decode(line);

              // Check if stream is finished
              if (data['finish'] == false && data['content'] != null) {
                // Update UI with new content (word by word)
                setState(() {
                  ndjsonText += data['content'];
                });
              } else if (data['finish'] == true) {
                // Stream complete
                setState(() {
                  ndjsonLoading = false;
                });
                return;
              }
            } catch (e) {
              // Skip invalid JSON
            }
          }
        }
      }
    } catch (e) {
      setState(() {
        ndjsonText = 'Error: $e';
        ndjsonLoading = false;
      });
    }
  }

  /// Method 3: Static Response (Traditional REST API)
  /// Format: Complete JSON object sent at once
  /// Use case: Standard API calls when streaming is not needed
  Future<void> fetchStaticData() async {
    setState(() {
      staticText = '';
      staticLoading = true;
    });

    try {
      // Make GET request with JSON response type
      final response = await dio.get(
        '$baseUrl/api/data',
        options: Options(responseType: ResponseType.json),
      );

      // Simulate network delay to show the difference
      await Future.delayed(const Duration(milliseconds: 500));

      // All data arrives at once
      setState(() {
        staticText = response.data['message'];
        staticLoading = false;
      });
    } catch (e) {
      setState(() {
        staticText = 'Error: $e';
        staticLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Stream vs Static API Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Information Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📚 Streaming vs Static Response',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Compare how data is received:\n'
                      '• Stream: Data arrives progressively (like LLM responses)\n'
                      '• Static: Complete data arrives at once',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // SSE Stream Demo Card
            _buildDemoCard(
              title: '1️⃣ SSE Stream (text/event-stream)',
              description: 'Format: data: {"content":"...", "finish":false}',
              text: sseText,
              isLoading: sseLoading,
              onPressed: fetchSSEStream,
              color: Colors.purple,
            ),
            const SizedBox(height: 16),

            // NDJSON Stream Demo Card
            _buildDemoCard(
              title: '2️⃣ NDJSON Stream (application/x-ndjson)',
              description: 'Format: {"content":"...", "finish":false}\\n',
              text: ndjsonText,
              isLoading: ndjsonLoading,
              onPressed: fetchNDJSONStream,
              color: Colors.green,
            ),
            const SizedBox(height: 16),

            // Static Response Demo Card
            _buildDemoCard(
              title: '3️⃣ Static Response (application/json)',
              description: 'Traditional REST API - complete data at once',
              text: staticText,
              isLoading: staticLoading,
              onPressed: fetchStaticData,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable widget for demo cards
  Widget _buildDemoCard({
    required String title,
    required String description,
    required String text,
    required bool isLoading,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Title
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),

            // Card Description
            Text(
              description,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),

            // Action Button
            ElevatedButton.icon(
              onPressed: isLoading ? null : onPressed,
              icon: Icon(isLoading ? Icons.hourglass_empty : Icons.play_arrow),
              label: Text(isLoading ? 'Loading...' : 'Fetch Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // Response Display Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SingleChildScrollView(
                child: Text(
                  text.isEmpty ? 'Press button to fetch data...' : text,
                  style: TextStyle(
                    fontSize: 13,
                    color: text.isEmpty ? Colors.grey : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
