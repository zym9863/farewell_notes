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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.25),
            ),
            gradient: isUnlocked
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.12),
                      theme.colorScheme.secondary.withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: isUnlocked
                          ? LinearGradient(
                              colors: [
                                AppTheme.primaryLight,
                                AppTheme.secondaryLight,
                              ],
                            )
                          : LinearGradient(
                              colors: [
                                theme.colorScheme.surfaceVariant,
                                theme.colorScheme.surface,
                              ],
                            ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isUnlocked ? Icons.mail_outline : Icons.lock_outline,
                      color: isUnlocked
                          ? Colors.white
                          : theme.colorScheme.onSurface.withOpacity(0.6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
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
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      iconSize: 20,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUnlocked
                              ? Icons.check_circle_outline
                              : Icons.schedule,
                          size: 16,
                          color: isUnlocked
                              ? const Color(0xFF3C9F6C)
                              : theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isUnlocked
                              ? '已解锁 · 可阅读'
                              : _formatRemainingTime(capsule.remainingTime),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isUnlocked
                                ? const Color(0xFF3C9F6C)
                                : theme.colorScheme.onSurface.withOpacity(0.75),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (capsule.mood != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.tertiaryLight.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        capsule.mood!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.tertiaryLight,
                        ),
                      ),
                    ),
                ],
              ),
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
