import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';

/// 扫描结果页面
class ScanScreen extends StatefulWidget {
  final FarewellTarget target;

  const ScanScreen({super.key, required this.target});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TargetProvider>().loadScanRecords(widget.target.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.target.name} 的痕迹'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _rescan(),
          ),
        ],
      ),
      body: Consumer<TargetProvider>(
        builder: (context, provider, child) {
          if (provider.isScanning) {
            return _buildScanningView(theme, isDark);
          }

          final records = provider.currentRecords;
          if (records.isEmpty) {
            return _buildEmptyView(theme);
          }

          return _buildRecordsList(records, theme, isDark);
        },
      ),
    );
  }

  Widget _buildScanningView(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
            ),
          ),
          const SizedBox(height: 24),
          Text('正在扫描...', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '正在查找与「${widget.target.name}」相关的内容',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('未找到相关内容', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '可以尝试添加更多关键词后重新扫描',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _rescan,
            icon: const Icon(Icons.search),
            label: const Text('重新扫描'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList(
    List<ScanRecord> records,
    ThemeData theme,
    bool isDark,
  ) {
    final pending = records.where((r) => r.status == 'pending').toList();
    final processed = records.where((r) => r.status != 'pending').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (pending.isNotEmpty) ...[
          _buildSectionHeader('待处理 (${pending.length})', theme),
          ...pending.map((r) => _buildRecordCard(r, theme, isDark)),
        ],
        if (processed.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionHeader('已处理 (${processed.length})', theme),
          ...processed.map((r) => _buildRecordCard(r, theme, isDark)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildRecordCard(ScanRecord record, ThemeData theme, bool isDark) {
    final isPending = record.status == 'pending';
    final primaryColor = isDark ? AppTheme.primaryDark : AppTheme.primaryLight;

    IconData typeIcon;
    switch (record.type) {
      case 'photo':
        typeIcon = Icons.photo_outlined;
        break;
      case 'note':
        typeIcon = Icons.note_outlined;
        break;
      default:
        typeIcon = Icons.chat_bubble_outline;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(typeIcon, color: primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTypeLabel(record.type),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        record.content,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(record.status, theme),
              ],
            ),
            if (isPending) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _updateStatus(record.id, 'archived'),
                    icon: const Icon(Icons.archive_outlined, size: 18),
                    label: const Text('归档'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _updateStatus(record.id, 'deleted'),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('删除'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    Color color;
    String label;
    switch (status) {
      case 'archived':
        color = Colors.blue;
        label = '已归档';
        break;
      case 'deleted':
        color = Colors.red;
        label = '已删除';
        break;
      default:
        color = Colors.orange;
        label = '待处理';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'photo':
        return '照片';
      case 'note':
        return '备忘录';
      default:
        return '社交媒体';
    }
  }

  void _rescan() {
    context.read<TargetProvider>().scanTarget(widget.target.id);
  }

  void _updateStatus(String recordId, String status) {
    context.read<TargetProvider>().updateRecordStatus(recordId, status);
  }
}
