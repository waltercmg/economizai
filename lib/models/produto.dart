class Produto {
  int id;
  String codigo;
  String nome;
  String unidade;
  bool salvar;
  double
      valorUnitario; // preco nao esta na entidade Produto. Esta aqui para facilitar a insercao do dado

  Produto({this.id, this.codigo, this.nome, this.unidade, this.salvar});

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['ID'],
      codigo: json['codigo'],
      nome: json['nome'],
      unidade: json['unidade'],
      salvar: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ID": this.id,
      "codigo": codigo,
      "nome": this.nome,
      "unidade": this.unidade
    };
  }
}
