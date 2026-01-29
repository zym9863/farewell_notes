import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import '../widgets/widgets.dart';
import 'capsule_editor_screen.dart';
import 'capsule_detail_screen.dart';

/// 时空胶囊列表页面
class CapsuleListScreen extends StatefulWidget {
  const CapsuleListScreen({super.key});

  @override
  State<CapsuleListScreen> createState() => _CapsuleListScreenState();
}

class _CapsuleListScreenState extends State<CapsuleListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 加载胶囊数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CapsuleProvider>().loadCapsules();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: _buildHeroHeader(theme),
            ),
            // Tab栏
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(
                  0.6,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerHeight: 0,
                labelStyle: theme.textTheme.labelLarge,
                tabs: const [
                  Tab(text: '待解锁'),
                  Tab(text: '已解锁'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // 列表内容
            Expanded(
              child: Consumer<CapsuleProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      // 待解锁列表
                      _buildCapsuleList(
                        provider.lockedCapsules,
                        '还没有待解锁的胶囊',
                        Icons.lock_clock,
                      ),
                      // 已解锁列表
                      _buildCapsuleList(
                        provider.unlockedCapsules,
                        '还没有已解锁的胶囊',
                        Icons.mail_outline,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewCapsule(context),
        icon: const Icon(Icons.add),
        label: const Text('写一封告别信'),
      ),
    );
  }

  Widget _buildCapsuleList(
    List capsules,
    String emptyMessage,
    IconData emptyIcon,
  ) {
    if (capsules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.8),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                emptyIcon,
                size: 34,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      itemCount: capsules.length,
      itemBuilder: (context, index) {
        final capsule = capsules[index];
        return CapsuleCard(
          capsule: capsule,
          onTap: () => _viewCapsule(context, capsule),
          onDelete: () => _confirmDeleteCapsule(context, capsule),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 4),
    );
  }

  Widget _buildHeroHeader(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.secondaryDark.withOpacity(0.45),
                  AppTheme.primaryDark.withOpacity(0.2),
                ]
              : [
                  AppTheme.primaryLight.withOpacity(0.12),
                  AppTheme.secondaryLight.withOpacity(0.08),
                ],
        ),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.25),
                    theme.colorScheme.secondary.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary.withOpacity(0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '时空胶囊信箱',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '写给未来的告别信',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    '把时间寄存在温柔里',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.75),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _createNewCapsule(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CapsuleEditorScreen()),
    );
  }

  void _viewCapsule(BuildContext context, capsule) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CapsuleDetailScreen(capsule: capsule),
      ),
    );
  }

  void _confirmDeleteCapsule(BuildContext context, capsule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除这封告别信「${capsule.title}」吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              context.read<CapsuleProvider>().deleteCapsule(capsule.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
