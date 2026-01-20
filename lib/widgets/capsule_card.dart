import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';

/// 胶囊卡片组件
class CapsuleCard extends StatelessWidget {
  final TimeCapsule capsule;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CapsuleCard({
    super.key,
    required this.capsule,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = capsule.isUnlocked || capsule.canUnlock;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isUnlocked
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryLight.withOpacity(0.1),
                      AppTheme.secondaryLight.withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部：图标 + 标题 + 状态
              Row(
                children: [
                  // 胶囊图标
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? AppTheme.primaryLight
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isUnlocked ? Icons.mail_outline : Icons.lock_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // 标题和收件人
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          capsule.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          capsule.recipientTypeDisplay,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 删除按钮
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                      color: Colors.grey,
                      iconSize: 20,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // 时间信息
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUnlocked ? Icons.check_circle_outline : Icons.schedule,
                      size: 16,
                      color: isUnlocked
                          ? Colors.green
                          : AppTheme.secondaryLight,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isUnlocked
                          ? '已解锁 - 可以打开了'
                          : _formatRemainingTime(capsule.remainingTime),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isUnlocked
                            ? Colors.green
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // 心情标签
              if (capsule.mood != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.tertiaryLight.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    capsule.mood!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.tertiaryLight,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatRemainingTime(Duration duration) {
    if (duration.inDays > 365) {
      final years = duration.inDays ~/ 365;
      return '还有 $years 年后解锁';
    } else if (duration.inDays > 30) {
      final months = duration.inDays ~/ 30;
      return '还有 $months 个月后解锁';
    } else if (duration.inDays > 0) {
      return '还有 ${duration.inDays} 天后解锁';
    } else if (duration.inHours > 0) {
      return '还有 ${duration.inHours} 小时后解锁';
    } else if (duration.inMinutes > 0) {
      return '还有 ${duration.inMinutes} 分钟后解锁';
    } else {
      return '即将解锁';
    }
  }
}
