enum RCSTemplateFilterEnum {
  all(label: 'All', apiValue: null),
  text(label: 'Text', apiValue: 'text_message'),
  richCard(label: 'Rich Card', apiValue: 'rich_card'),
  carousel(label: 'Carousel', apiValue: 'carousel');

  final String label;
  final String? apiValue;

  const RCSTemplateFilterEnum({required this.label, required this.apiValue});
}
