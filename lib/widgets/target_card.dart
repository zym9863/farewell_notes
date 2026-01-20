import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';

/// 告别对象卡片组件
class TargetCard extends StatelessWidget {
  final FarewellTarget target;
  final VoidCallback? onTap;
  final VoidCallback? onScan;
  final VoidCallback? onDelete;

  const TargetCard({
    super.key,
    required this.target,
    this.onTap,
    this.onScan,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部：头像 + 名称 + 操作
              Row(
                children: [
                  // 头像
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.primaryLight,
                          AppTheme.secondaryLight,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        target.name.isNotEmpty
                            ? target.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 名称和统计
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          target.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          target.matchCount > 0
                              ? '发现 ${target.matchCount} 条相关记录'
                              : '尚未扫描',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: target.matchCount > 0
                                ? AppTheme.secondaryLight
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 操作按钮
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'scan':
                          onScan?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'scan',
                        child: Row(
                          children: [
                            Icon(Icons.search, size: 20),
                            SizedBox(width: 12),
                            Text('重新扫描'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            SizedBox(width: 12),
                            Text('删除', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // 关键词标签
              if (target.keywords.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: target.keywords.map((keyword) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        keyword,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              // 备注
              if (target.note != null && target.note!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  target.note!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
