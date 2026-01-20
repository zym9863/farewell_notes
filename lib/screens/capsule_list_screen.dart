import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '时空胶囊信箱',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '写给未来的告别信',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Tab栏
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(
                  0.6,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerHeight: 0,
                tabs: const [
                  Tab(text: '待解锁'),
                  Tab(text: '已解锁'),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
            Icon(emptyIcon, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(emptyMessage, style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: capsules.length,
      itemBuilder: (context, index) {
        final capsule = capsules[index];
        return CapsuleCard(
          capsule: capsule,
          onTap: () => _viewCapsule(context, capsule),
          onDelete: () => _confirmDeleteCapsule(context, capsule),
        );
      },
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
