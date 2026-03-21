import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolhq_ng/core/constants/constants.dart';
import 'package:schoolhq_ng/core/feedback/app_snackbar.dart';
import 'package:schoolhq_ng/core/formatters/school_currency_formatter.dart';
import 'package:schoolhq_ng/providers/mobile_provider.dart';
import 'package:schoolhq_ng/views/home/shared/widgets/mobile_top_action_bar.dart';

class TestsScreen extends ConsumerWidget {
  const TestsScreen({super.key});

  Future<void> _refreshFeesData(WidgetRef ref, String role) async {
    if (role == 'parent') {
      ref.invalidate(parentChildrenProvider);
      await ref.read(parentChildrenProvider.future);
    }

    ref.invalidate(mobileSessionsMetaProvider);
    await ref.read(mobileSessionsMetaProvider.future);

    ref.invalidate(mobileFeesProvider);
    await ref.read(mobileFeesProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    final feesAsync = ref.watch(mobileFeesProvider);
    final metaAsync = ref.watch(mobileSessionsMetaProvider);
    final childrenAsync = role == 'parent'
        ? ref.watch(parentChildrenProvider)
        : const AsyncValue<List<Map<String, dynamic>>>.data([]);
    final selectedChildId = ref.watch(parentSelectedChildIdProvider);
    final selectedSessionId = ref.watch(resultsSelectedSessionIdProvider);
    final selectedTermId = ref.watch(resultsSelectedTermIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refreshFeesData(ref, role),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              MobileTopActionBar(
                title: 'Fees',
                subtitle:
                    'Follow assigned fees, payments, and balances with school-aware currency formatting.',
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onRefresh: () => _refreshFeesData(ref, role),
              ),
              const SizedBox(height: 16),
              if (role == 'parent') ...[
                childrenAsync.when(
                  loading: () => const LinearProgressIndicator(minHeight: 2),
                  error: (e, _) =>
                      _ErrorCard(message: 'Failed to load children: $e'),
                  data: (children) => _ParentChildSelector(
                    children: children,
                    selectedChildId: selectedChildId,
                    onSelected: (id) {
                      ref.read(parentSelectedChildIdProvider.notifier).set(id);
                      ref.invalidate(mobileFeesProvider);
                      ref.invalidate(mobileTermResultsProvider);
                      ref.invalidate(mobileSessionResultsProvider);
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
              metaAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (sessions) => _FilterCard(
                  sessions: sessions,
                  selectedSessionId: selectedSessionId,
                  selectedTermId: selectedTermId,
                  onSessionChanged: (sessionId) {
                    ref.read(resultsSelectedSessionIdProvider.notifier).state =
                        sessionId;
                    final selectedSession = sessions.firstWhere(
                      (s) => s['id']?.toString() == sessionId,
                      orElse: () => sessions.isNotEmpty
                          ? sessions.first
                          : <String, dynamic>{},
                    );
                    final terms = _termsForSession(selectedSession);
                    if (terms.isNotEmpty) {
                      final currentTerm = terms.firstWhere(
                        (t) => t['is_current'] == true,
                        orElse: () => terms.first,
                      );
                      ref.read(resultsSelectedTermIdProvider.notifier).state =
                          currentTerm['id']?.toString();
                    }
                    ref.invalidate(mobileFeesProvider);
                  },
                  onTermChanged: (termId) {
                    ref.read(resultsSelectedTermIdProvider.notifier).state =
                        termId;
                    ref.invalidate(mobileFeesProvider);
                  },
                ),
              ),
              const SizedBox(height: 14),
              feesAsync.when(
                loading: () =>
                    const _LoadingCard(label: 'Loading fee records...'),
                error: (error, _) => _ErrorCard(message: error.toString()),
                data: (data) => _FeesContent(
                  data: data,
                  role: role,
                  selectedChildId: selectedChildId,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeesContent extends StatelessWidget {
  final Map<String, dynamic> data;
  final String role;
  final String? selectedChildId;

  const _FeesContent({
    required this.data,
    required this.role,
    required this.selectedChildId,
  });

  @override
  Widget build(BuildContext context) {
    final summary = _asMap(data['summary']);
    final subjectEntity = role == 'parent'
        ? _asMap(data['child'])
        : _asMap(data['student']);
    final bankDetails = _asMap(data['bank_details']);
    final items = _asList(data['items']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryCard(
          title: (subjectEntity['full_name'] ?? 'Fee Summary').toString(),
          assigned: _num(summary['assigned']),
          paid: _num(summary['paid']),
          balance: _num(summary['balance']),
        ),
        const SizedBox(height: 12),
        _BankDetailsCard(bankDetails: bankDetails),
        const SizedBox(height: 16),
        Text('Fee Items', style: AppTextStyles.headingMedium),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const _EmptyCard(
            message: 'No fee items found for the selected filter.',
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FeeItemTile(
                item: item,
                bankDetails: bankDetails,
                role: role,
                selectedChildId: selectedChildId,
              ),
            ),
          ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double assigned;
  final double paid;
  final double balance;

  const _SummaryCard({
    required this.title,
    required this.assigned,
    required this.paid,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text('Fees summary', style: AppTextStyles.subtitle),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MoneyChip(
                label: 'Assigned',
                value: assigned,
                color: AppColors.primary,
              ),
              _MoneyChip(
                label: 'Paid',
                value: paid,
                color: const Color(0xFF16A34A),
              ),
              _MoneyChip(
                label: 'Balance',
                value: balance,
                color: const Color(0xFFD97706),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BankDetailsCard extends StatelessWidget {
  final Map<String, dynamic> bankDetails;

  const _BankDetailsCard({required this.bankDetails});

  @override
  Widget build(BuildContext context) {
    final isConfigured = bankDetails['is_configured'] == true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isConfigured
              ? const Color(0xFF99F6E4)
              : const Color(0xFFFCD34D),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'School transfer details',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (isConfigured) ...[
            Text(
              'Bank: ${(bankDetails['bank_name'] ?? 'Not set').toString()}',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 4),
            Text(
              'Account name: ${(bankDetails['account_name'] ?? 'Not set').toString()}',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 4),
            Text(
              'Account number: ${(bankDetails['account_number'] ?? 'Not set').toString()}',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
            ),
            if ((bankDetails['instructions'] ?? '')
                .toString()
                .trim()
                .isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  bankDetails['instructions'].toString(),
                  style: AppTextStyles.small,
                ),
              ),
          ] else
            Text(
              'The school has not added bank transfer details yet.',
              style: AppTextStyles.small.copyWith(color: AppColors.error),
            ),
        ],
      ),
    );
  }
}

class _MoneyChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MoneyChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _money(value),
            style: AppTextStyles.body.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(label, style: AppTextStyles.small.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _FeeItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final Map<String, dynamic> bankDetails;
  final String role;
  final String? selectedChildId;

  const _FeeItemTile({
    required this.item,
    required this.bankDetails,
    required this.role,
    required this.selectedChildId,
  });

  @override
  Widget build(BuildContext context) {
    final fee = _asMap(item['fee_structure']);
    final payments = _asList(item['payments']);
    final status = (item['status'] ?? 'unknown').toString().toLowerCase();
    final color = switch (status) {
      'paid' => const Color(0xFF16A34A),
      'partial' => const Color(0xFFD97706),
      _ => AppColors.primary,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  (fee['name'] ?? 'Fee Item').toString(),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: AppTextStyles.small.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            [
              fee['class']?.toString(),
              fee['term']?.toString(),
              fee['session']?.toString(),
            ].where((e) => e != null && e.isNotEmpty).join(' | '),
            style: AppTextStyles.small,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _miniAmount('Assigned', _num(item['amount_assigned'])),
              ),
              Expanded(child: _miniAmount('Paid', _num(item['amount_paid']))),
              Expanded(child: _miniAmount('Balance', _num(item['balance']))),
            ],
          ),
          if (payments.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Recent payments',
              style: AppTextStyles.small.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...payments
                .take(3)
                .map(
                  (payment) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _money(_num(payment['amount'])),
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              [
                                    (payment['method'] ?? 'payment')
                                        .toString()
                                        .replaceAll('_', ' '),
                                    payment['payment_date']?.toString(),
                                    if ((payment['receipt_name'] ?? '')
                                        .toString()
                                        .trim()
                                        .isNotEmpty)
                                      payment['receipt_name']?.toString(),
                                  ]
                                  .where((e) => e != null && e.isNotEmpty)
                                  .join(' | '),
                              textAlign: TextAlign.right,
                              style: AppTextStyles.small,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
          if (_num(item['balance']) > 0) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openPaymentSheet(context),
                icon: const Icon(Icons.payments_outlined),
                label: Text(
                  'Pay now',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openPaymentSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FeePaymentSheet(
        fee: item,
        bankDetails: bankDetails,
        role: role,
        selectedChildId: selectedChildId,
      ),
    );
  }

  Widget _miniAmount(String label, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.small),
        const SizedBox(height: 2),
        Text(
          _money(amount),
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _FeePaymentSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic> fee;
  final Map<String, dynamic> bankDetails;
  final String role;
  final String? selectedChildId;

  const _FeePaymentSheet({
    required this.fee,
    required this.bankDetails,
    required this.role,
    required this.selectedChildId,
  });

  @override
  ConsumerState<_FeePaymentSheet> createState() => _FeePaymentSheetState();
}

class _FeePaymentSheetState extends ConsumerState<_FeePaymentSheet> {
  late final TextEditingController _amountController;
  String? _receiptPath;
  String? _receiptName;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: _num(widget.fee['balance']).toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.trim());
    final balance = _num(widget.fee['balance']);
    final isConfigured = widget.bankDetails['is_configured'] == true;

    if (!isConfigured) {
      AppSnackBar.error(
        context,
        'The school has not added bank transfer details yet.',
      );
      return;
    }

    if (amount == null || amount <= 0) {
      AppSnackBar.error(context, 'Enter a valid payment amount.');
      return;
    }

    if (amount > balance) {
      AppSnackBar.error(
        context,
        'Payment amount cannot be more than the current balance.',
      );
      return;
    }

    if (_receiptPath == null || _receiptPath!.isEmpty) {
      AppSnackBar.error(context, 'Upload the receipt or transfer proof.');
      return;
    }

    setState(() => _submitting = true);

    try {
      await ref
          .read(mobileRepositoryProvider)
          .submitFeePayment(
            role: widget.role,
            feeId: (widget.fee['id'] ?? '').toString(),
            childId: widget.selectedChildId,
            amount: amount,
            receiptPath: _receiptPath!,
          );

      ref.invalidate(mobileFeesProvider);
      ref.invalidate(mobileDashboardProvider);

      if (context.mounted) {
        Navigator.of(context).pop();
        AppSnackBar.success(context, 'Payment recorded successfully.');
      }
    } catch (error) {
      if (context.mounted) {
        AppSnackBar.error(
          context,
          error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _pickReceipt() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf', 'webp'],
    );

    final file = result != null && result.files.isNotEmpty
        ? result.files.first
        : null;
    final path = file?.path;

    if (path == null || path.isEmpty) {
      return;
    }

    setState(() {
      _receiptPath = path;
      _receiptName = file?.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fee = _asMap(widget.fee['fee_structure']);
    final bankDetails = widget.bankDetails;
    final isConfigured = bankDetails['is_configured'] == true;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submit payment proof for ${(fee['name'] ?? 'fee item').toString()}',
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Balance: ${_money(_num(widget.fee['balance']))}',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 18),
              _BankDetailsCard(bankDetails: bankDetails),
              const SizedBox(height: 18),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _submitting || !isConfigured ? null : _pickReceipt,
                icon: const Icon(Icons.upload_file_outlined),
                label: Text(
                  _receiptName ?? 'Upload receipt or transfer proof',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Accepted formats: JPG, PNG, WEBP, PDF',
                style: AppTextStyles.small,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting || !isConfigured ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit payment proof'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterCard extends StatelessWidget {
  final List<Map<String, dynamic>> sessions;
  final String? selectedSessionId;
  final String? selectedTermId;
  final ValueChanged<String?> onSessionChanged;
  final ValueChanged<String?> onTermChanged;

  const _FilterCard({
    required this.sessions,
    required this.selectedSessionId,
    required this.selectedTermId,
    required this.onSessionChanged,
    required this.onTermChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox.shrink();

    final currentSession = sessions.firstWhere(
      (s) => s['id']?.toString() == selectedSessionId,
      orElse: () => sessions.first,
    );
    final terms = _termsForSession(currentSession);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: currentSession['id']?.toString(),
            items: sessions
                .map(
                  (s) => DropdownMenuItem<String>(
                    value: s['id']?.toString(),
                    child: Text((s['name'] ?? 'Session').toString()),
                  ),
                )
                .toList(),
            onChanged: onSessionChanged,
            decoration: const InputDecoration(
              labelText: 'Session',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: terms.any((t) => t['id']?.toString() == selectedTermId)
                ? selectedTermId
                : (terms.isNotEmpty ? terms.first['id']?.toString() : null),
            items: terms
                .map(
                  (t) => DropdownMenuItem<String>(
                    value: t['id']?.toString(),
                    child: Text((t['name'] ?? 'Term').toString()),
                  ),
                )
                .toList(),
            onChanged: terms.isEmpty ? null : onTermChanged,
            decoration: const InputDecoration(
              labelText: 'Term',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentChildSelector extends StatelessWidget {
  final List<Map<String, dynamic>> children;
  final String? selectedChildId;
  final ValueChanged<String> onSelected;

  const _ParentChildSelector({
    required this.children,
    required this.selectedChildId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const _ErrorCard(
        message: 'No children linked to this parent account.',
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: children.map((child) {
        final id = (child['id'] ?? '').toString();
        final selected =
            id == selectedChildId ||
            (selectedChildId == null && children.first == child);
        return ChoiceChip(
          label: Text((child['full_name'] ?? 'Student').toString()),
          selected: selected,
          onSelected: (_) => onSelected(id),
          selectedColor: AppColors.primary.withOpacity(0.15),
          labelStyle: AppTextStyles.small.copyWith(
            color: selected ? AppColors.primary : AppColors.textPrimary,
          ),
        );
      }).toList(),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final String label;

  const _LoadingCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.subtitle),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(message, style: AppTextStyles.subtitle),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.25)),
      ),
      child: Text(
        message,
        style: AppTextStyles.subtitle.copyWith(color: AppColors.error),
      ),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

List<Map<String, dynamic>> _asList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

List<Map<String, dynamic>> _termsForSession(Map<String, dynamic> session) {
  final terms = (session['terms'] as List?) ?? const [];
  return terms
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

double _num(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse('${value ?? 0}') ?? 0;
}

String _money(double amount) => formatSchoolMoney(amount);
