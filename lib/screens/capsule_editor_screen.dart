import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';

/// 胶囊编辑器页面
class CapsuleEditorScreen extends StatefulWidget {
  final TimeCapsule? capsule; // 如果是编辑模式，传入现有胶囊

  const CapsuleEditorScreen({super.key, this.capsule});

  @override
  State<CapsuleEditorScreen> createState() => _CapsuleEditorScreenState();
}

class _CapsuleEditorScreenState extends State<CapsuleEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _recipientNameController = TextEditingController();

  String _recipientType = 'self';
  DateTime _unlockDate = DateTime.now().add(const Duration(days: 30));
  TimeOfDay _unlockTime = const TimeOfDay(hour: 9, minute: 0);
  String? _selectedMood;
  bool _isSaving = false;

  final List<String> _moods = [
    '释怀 🕊️',
    '感恩 💝',
    '怀念 🌙',
    '期待 ✨',
    '平静 🌊',
    '温暖 ☀️',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.capsule != null) {
      _titleController.text = widget.capsule!.title;
      _contentController.text = widget.capsule!.content;
      _recipientType = widget.capsule!.recipientType;
      _recipientNameController.text = widget.capsule!.recipientName ?? '';
      _unlockDate = widget.capsule!.unlockAt;
      _unlockTime = TimeOfDay.fromDateTime(widget.capsule!.unlockAt);
      _selectedMood = widget.capsule!.mood;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _recipientNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.capsule == null ? '写一封告别信' : '编辑告别信'),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _saveCapsule,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 标题输入
            _buildSectionTitle('信件标题'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: '给这封信取个名字...'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入标题';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 收件人类型
            _buildSectionTitle('收件人'),
            const SizedBox(height: 12),
            _buildRecipientSelector(theme, isDark),
            if (_recipientType == 'person') ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _recipientNameController,
                decoration: const InputDecoration(
                  hintText: '输入收件人的名字...',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (_recipientType == 'person' &&
                      (value == null || value.trim().isEmpty)) {
                    return '请输入收件人名字';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 24),

            // 解锁时间
            _buildSectionTitle('解锁时间'),
            const SizedBox(height: 8),
            _buildUnlockTimePicker(theme, isDark),
            const SizedBox(height: 24),

            // 心情标签
            _buildSectionTitle('此刻心情'),
            const SizedBox(height: 12),
            _buildMoodSelector(theme, isDark),
            const SizedBox(height: 24),

            // 信件内容
            _buildSectionTitle('信件内容'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.surfaceDark.withOpacity(0.6)
                    : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                ),
              ),
              child: TextFormField(
                controller: _contentController,
                maxLines: 12,
                decoration: const InputDecoration(
                  hintText:
                      '在这里写下你想说的话...\n\n可以是对过去的告别，\n对未来的期许，\n或是对某人想说却未曾说出口的话...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入信件内容';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildRecipientSelector(ThemeData theme, bool isDark) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildRecipientChip('self', '给未来的自己', Icons.auto_awesome, isDark),
        _buildRecipientChip('person', '给某个人', Icons.person_outline, isDark),
        _buildRecipientChip(
          'memory',
          '告别一段回忆',
          Icons.photo_album_outlined,
          isDark,
        ),
      ],
    );
  }

  Widget _buildRecipientChip(
    String type,
    String label,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = _recipientType == type;
    final primaryColor = isDark ? AppTheme.primaryDark : AppTheme.primaryLight;

    return ChoiceChip(
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _recipientType = type;
          });
        }
      },
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected ? Colors.white : primaryColor,
      ),
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.w500 : null,
      ),
      selectedColor: primaryColor,
      backgroundColor: isDark
          ? AppTheme.surfaceDark.withOpacity(0.6)
          : Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? primaryColor : Colors.transparent),
      ),
    );
  }

  Widget _buildUnlockTimePicker(ThemeData theme, bool isDark) {
    final primaryColor = isDark ? AppTheme.primaryDark : AppTheme.primaryLight;
    final unlockDateTime = DateTime(
      _unlockDate.year,
      _unlockDate.month,
      _unlockDate.day,
      _unlockTime.hour,
      _unlockTime.minute,
    );
    final remaining = unlockDateTime.difference(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withOpacity(0.6)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${_unlockDate.year}/${_unlockDate.month}/${_unlockDate.day}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _pickTime,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: primaryColor, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _unlockTime.format(context),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_clock, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  _formatRemainingTime(remaining),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector(ThemeData theme, bool isDark) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _moods.map((mood) {
        final isSelected = _selectedMood == mood;
        final primaryColor = isDark
            ? AppTheme.primaryDark
            : AppTheme.primaryLight;

        return ChoiceChip(
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedMood = selected ? mood : null;
            });
          },
          label: Text(mood),
          labelStyle: TextStyle(color: isSelected ? Colors.white : null),
          selectedColor: primaryColor,
          backgroundColor: isDark
              ? AppTheme.surfaceDark.withOpacity(0.6)
              : Colors.white.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _unlockDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) {
      setState(() {
        _unlockDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _unlockTime,
    );
    if (time != null) {
      setState(() {
        _unlockTime = time;
      });
    }
  }

  String _formatRemainingTime(Duration duration) {
    if (duration.isNegative) {
      return '解锁时间已过，将立即解锁';
    }
    if (duration.inDays > 365) {
      final years = duration.inDays ~/ 365;
      return '将在 $years 年后解锁';
    } else if (duration.inDays > 30) {
      final months = duration.inDays ~/ 30;
      return '将在约 $months 个月后解锁';
    } else if (duration.inDays > 0) {
      return '将在 ${duration.inDays} 天后解锁';
    } else if (duration.inHours > 0) {
      return '将在 ${duration.inHours} 小时后解锁';
    } else {
      return '将在 ${duration.inMinutes} 分钟后解锁';
    }
  }

  Future<void> _saveCapsule() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final unlockDateTime = DateTime(
        _unlockDate.year,
        _unlockDate.month,
        _unlockDate.day,
        _unlockTime.hour,
        _unlockTime.minute,
      );

      final capsule = TimeCapsule(
        id: widget.capsule?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        recipientType: _recipientType,
        recipientName: _recipientType == 'person'
            ? _recipientNameController.text.trim()
            : null,
        createdAt: widget.capsule?.createdAt ?? DateTime.now(),
        unlockAt: unlockDateTime,
        isUnlocked: unlockDateTime.isBefore(DateTime.now()),
        isRead: false,
        mood: _selectedMood,
      );

      final provider = context.read<CapsuleProvider>();
      if (widget.capsule == null) {
        await provider.createCapsule(capsule);
      } else {
        await provider.updateCapsule(capsule);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.capsule == null ? '告别信已保存 💌' : '告别信已更新'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
