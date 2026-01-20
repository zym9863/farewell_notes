import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import '../widgets/widgets.dart';
import 'scan_screen.dart';

/// 告别对象管理页面
class TargetsScreen extends StatefulWidget {
  const TargetsScreen({super.key});

  @override
  State<TargetsScreen> createState() => _TargetsScreenState();
}

class _TargetsScreenState extends State<TargetsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TargetProvider>().loadTargets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '数字痕迹清理',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '管理告别对象，清理相关数字痕迹',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildInfoCard(theme),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<TargetProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.targets.isEmpty) {
                    return _buildEmptyState(theme);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: provider.targets.length,
                    itemBuilder: (context, index) {
                      final target = provider.targets[index];
                      return TargetCard(
                        target: target,
                        onTap: () => _viewTarget(target),
                        onScan: () => _startScan(target),
                        onDelete: () => _confirmDelete(target),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewTarget,
        icon: const Icon(Icons.person_add),
        label: const Text('添加告别对象'),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.tertiaryDark.withOpacity(0.2)
            : AppTheme.tertiaryLight.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.tertiaryLight),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '添加告别对象，扫描并清理与TA相关的内容。',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text('还没有添加告别对象', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  void _addNewTarget() => _showTargetDialog();

  void _viewTarget(FarewellTarget target) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScanScreen(target: target)),
    );
  }

  void _startScan(FarewellTarget target) async {
    await context.read<TargetProvider>().scanTarget(target.id);
    if (mounted) _viewTarget(target);
  }

  void _confirmDelete(FarewellTarget target) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除「${target.name}」吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              context.read<TargetProvider>().deleteTarget(target.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showTargetDialog() {
    final nameCtrl = TextEditingController();
    final keywordsCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加告别对象'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: '名字'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keywordsCtrl,
              decoration: const InputDecoration(labelText: '关键词(逗号分隔)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              final keywords = keywordsCtrl.text
                  .split(',')
                  .map((k) => k.trim())
                  .where((k) => k.isNotEmpty)
                  .toList();
              if (!keywords.contains(name)) keywords.insert(0, name);
              context.read<TargetProvider>().addTarget(
                FarewellTarget(
                  id: const Uuid().v4(),
                  name: name,
                  keywords: keywords,
                  createdAt: DateTime.now(),
                  matchCount: 0,
                ),
              );
              Navigator.pop(ctx);
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
}
