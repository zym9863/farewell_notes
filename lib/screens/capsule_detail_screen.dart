import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import 'capsule_editor_screen.dart';

/// 胶囊详情页面
class CapsuleDetailScreen extends StatefulWidget {
  final TimeCapsule capsule;

  const CapsuleDetailScreen({super.key, required this.capsule});

  @override
  State<CapsuleDetailScreen> createState() => _CapsuleDetailScreenState();
}

class _CapsuleDetailScreenState extends State<CapsuleDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isUnlocking = false;
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    // 检查是否可以解锁
    _isUnlocked = widget.capsule.isUnlocked || widget.capsule.canUnlock;
    if (_isUnlocked) {
      _animationController.forward();
      // 标记为已读
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CapsuleProvider>().markAsRead(widget.capsule.id);
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.primaryDark : AppTheme.primaryLight;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 自定义 AppBar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [AppTheme.primaryDark, AppTheme.tertiaryDark]
                        : [AppTheme.primaryLight, AppTheme.secondaryLight],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        _isUnlocked ? Icons.mail_outline : Icons.lock_outline,
                        size: 48,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isUnlocked ? '信件已解锁' : '信件已封存',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              if (_isUnlocked)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CapsuleEditorScreen(capsule: widget.capsule),
                      ),
                    );
                  },
                ),
            ],
          ),

          // 内容区域
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Text(
                    widget.capsule.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 收件人信息
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.capsule.recipientTypeDisplay,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 时间信息卡片
                  _buildTimeInfoCard(theme, isDark, primaryColor),
                  const SizedBox(height: 24),

                  // 信件内容
                  if (_isUnlocked)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildContentCard(theme, isDark),
                      ),
                    )
                  else
                    _buildLockedContent(theme, isDark, primaryColor),

                  // 心情标签
                  if (widget.capsule.mood != null && _isUnlocked) ...[
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Row(
                        children: [
                          Text(
                            '写信时的心情：',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.tertiaryLight.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.capsule.mood!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.tertiaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfoCard(ThemeData theme, bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withOpacity(0.6)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTimeRow(
            Icons.create_outlined,
            '创建时间',
            _formatDateTime(widget.capsule.createdAt),
            theme,
          ),
          const Divider(height: 24),
          _buildTimeRow(
            _isUnlocked ? Icons.lock_open_outlined : Icons.lock_clock,
            _isUnlocked ? '解锁时间' : '将于此时解锁',
            _formatDateTime(widget.capsule.unlockAt),
            theme,
            highlight: !_isUnlocked,
            highlightColor: primaryColor,
          ),
          if (!_isUnlocked) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.hourglass_empty, size: 16, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    _formatRemainingTime(widget.capsule.remainingTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme, {
    bool highlight = false,
    Color? highlightColor,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: (highlightColor ?? theme.colorScheme.primary).withOpacity(
              0.1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: highlightColor ?? theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: highlight ? FontWeight.w600 : null,
                color: highlight ? highlightColor : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentCard(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withOpacity(0.6)
            : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : AppTheme.primaryLight.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote,
                color: AppTheme.primaryLight.withOpacity(0.5),
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.capsule.content,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.8,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.format_quote,
                color: AppTheme.primaryLight.withOpacity(0.5),
                size: 28,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLockedContent(ThemeData theme, bool isDark, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withOpacity(0.6)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: _isUnlocking
                ? const CircularProgressIndicator()
                : Icon(Icons.lock_outline, size: 40, color: primaryColor),
          ),
          const SizedBox(height: 20),
          Text(
            '这封信还未到解锁时间',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请耐心等待，到时间后会自动解锁',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatRemainingTime(Duration duration) {
    if (duration.inDays > 365) {
      final years = duration.inDays ~/ 365;
      return '还有 $years 年';
    } else if (duration.inDays > 30) {
      final months = duration.inDays ~/ 30;
      return '还有约 $months 个月';
    } else if (duration.inDays > 0) {
      return '还有 ${duration.inDays} 天';
    } else if (duration.inHours > 0) {
      return '还有 ${duration.inHours} 小时';
    } else {
      return '还有 ${duration.inMinutes} 分钟';
    }
  }
}
