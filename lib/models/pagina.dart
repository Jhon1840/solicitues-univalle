class Pagina<T> {
  final List<T> items;
  final int paginaActual;
  final int ultimaPagina;

  const Pagina({
    required this.items,
    required this.paginaActual,
    required this.ultimaPagina,
  });

  bool get hayMas => paginaActual < ultimaPagina;
}
