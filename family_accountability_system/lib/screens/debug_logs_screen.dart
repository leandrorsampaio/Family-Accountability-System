import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_logger.dart';

class DebugLogsScreen extends StatefulWidget {
  const DebugLogsScreen({super.key});

  @override
  State<DebugLogsScreen> createState() => _DebugLogsScreenState();
}

class _DebugLogsScreenState extends State<DebugLogsScreen> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    // Auto-scroll to bottom when new logs appear
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _copyLogsToClipboard() {
    final logs = InMemoryLogger.getLogs();
    if (logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No logs to copy')),
      );
      return;
    }
    
    final logText = logs.join('\n');
    Clipboard.setData(ClipboardData(text: logText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${logs.length} log entries copied to clipboard')),
    );
  }

  void _clearLogs() {
    setState(() {
      InMemoryLogger.clearLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Logs'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyLogsToClipboard,
            tooltip: 'Copy logs to clipboard',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearLogs,
            tooltip: 'Clear logs',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Text(
                'Live Debug Logs - ${InMemoryLogger.getLogs().length} entries',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
            // Copy All Logs Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: ElevatedButton.icon(
                onPressed: InMemoryLogger.getLogs().isEmpty ? null : _copyLogsToClipboard,
                icon: const Icon(Icons.content_copy),
                label: Text('Copy All ${InMemoryLogger.getLogs().length} Logs'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            // Logs Display
            Expanded(
              child: InMemoryLogger.getLogs().isEmpty
                  ? const Center(
                      child: Text(
                        'No logs yet.\nTry creating a database to see logs.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[700]!),
                      ),
                      child: SelectableText(
                        InMemoryLogger.getLogs().join('\n'),
                        style: const TextStyle(
                          fontFamily: 'Monaco',
                          fontSize: 12,
                          color: Colors.white,
                          height: 1.4,
                        ),
                        toolbarOptions: const ToolbarOptions(
                          copy: true,
                          selectAll: true,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {}),
        tooltip: 'Refresh logs',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Color _getLogColor(String log) {
    if (log.contains('ERROR') || log.contains('🚨')) return Colors.red;
    if (log.contains('WARNING') || log.contains('⚠️')) return Colors.orange;
    if (log.contains('AUTH') || log.contains('🔐')) return Colors.cyan;
    if (log.contains('DB') || log.contains('🗄️')) return Colors.green;
    if (log.contains('UI') || log.contains('🖼️')) return Colors.blue;
    return Colors.white;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}