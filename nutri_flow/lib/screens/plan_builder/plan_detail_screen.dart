import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/plan_providers.dart';
import '../../services/pdf_export_service.dart';
import 'day_builder_view.dart';
import 'plan_extras_view.dart';

/// Hosts the day-builder tabs (one per plan day) plus the plan-level
/// "drinks & supplements" tab, and the PDF export action (spec §5–6).
class PlanDetailScreen extends ConsumerStatefulWidget {
  const PlanDetailScreen({super.key, required this.planId});
  final String planId;

  @override
  ConsumerState<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends ConsumerState<PlanDetailScreen> {
  bool _exporting = false;

  Future<void> _exportPdf() async {
    setState(() => _exporting = true);
    try {
      final bytes = await PdfExportService().generatePlanPdf(widget.planId);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/nutriflow-plan-${widget.planId}.pdf');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: 'خطة غذائية — NutriFlow'),
      );
    } on PdfServiceNotConfiguredException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('خدمة توليد PDF غير مُعدّة بعد (PDF_SERVICE_URL) — راجعي README'),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('تعذّر تصدير الملف: $e')));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(planDetailProvider(widget.planId));

    return detail.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('تعذّر تحميل الخطة: $e')),
      ),
      data: (state) {
        final tabCount = state.days.length + 1;
        return DefaultTabController(
          length: tabCount,
          child: Scaffold(
            appBar: AppBar(
              title: Text(state.plan.patientName),
              actions: [
                IconButton(
                  tooltip: 'تصدير PDF',
                  onPressed: _exporting ? null : _exportPdf,
                  icon: _exporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.picture_as_pdf_outlined),
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  for (final day in state.days) Tab(text: 'اليوم ${day.dayNumber}'),
                  const Tab(text: 'المشروبات والمكملات'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                for (final day in state.days)
                  DayBuilderView(planId: widget.planId, day: day),
                PlanExtrasView(planId: widget.planId),
              ],
            ),
          ),
        );
      },
    );
  }
}
