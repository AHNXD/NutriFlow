/// One PDF design template. Keep this catalog in sync with the Python side
/// — `NutriFlow-backend/app/layouts.py` — same `id`s, since the `id` is what
/// gets stored in `plans.pdf_layout` and picks the template directory the
/// PDF service renders (`app/templates/layouts/<id>/`).
///
/// A layout is the *shape* of the document — page composition, typography,
/// how a meal is drawn. It is independent of the colour palette in
/// [PdfThemes]: every layout renders in every theme, so a plan is described
/// by the pair (layout, theme).
class PdfLayout {
  final String id;
  final String labelAr;
  final String descriptionAr;

  const PdfLayout({
    required this.id,
    required this.labelAr,
    required this.descriptionAr,
  });
}

class PdfLayouts {
  PdfLayouts._();

  static const aurora = PdfLayout(
    id: 'aurora',
    labelAr: 'أورورا',
    descriptionAr: 'تدرّجات لونية ناعمة وبطاقات مستديرة — حديث ومشرق',
  );

  static const editorial = PdfLayout(
    id: 'editorial',
    labelAr: 'مجلة',
    descriptionAr: 'طباعة جريئة وخطوط فاصلة رفيعة بأسلوب المجلات',
  );

  static const minimal = PdfLayout(
    id: 'minimal',
    labelAr: 'بسيط',
    descriptionAr: 'مساحات بيضاء واسعة وتفاصيل هادئة — مثالي للطباعة',
  );

  static const bloom = PdfLayout(
    id: 'bloom',
    labelAr: 'ناعم',
    descriptionAr: 'ألوان باستيل وأشكال دائرية دافئة بروح العافية',
  );

  static const noir = PdfLayout(
    id: 'noir',
    labelAr: 'ليلي',
    descriptionAr: 'غلاف داكن فاخر مع لمسات لونية وإطار أنيق',
  );

  static const all = [aurora, editorial, minimal, bloom, noir];

  static const defaultId = 'aurora';

  static PdfLayout byId(String id) =>
      all.firstWhere((l) => l.id == id, orElse: () => aurora);
}
