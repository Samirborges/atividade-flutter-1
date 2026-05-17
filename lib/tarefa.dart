class Tarefa {
  String titulo;
  String descricao;
  bool concluida;

  Tarefa({
    required this.titulo,
    required this.descricao,
    this.concluida = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida
    };
  }

  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      concluida: map['concluida'] ?? false,
    );
  }
}
