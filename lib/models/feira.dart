class Feira {
  int id;
  String idNfe;
  String cnpj;
  String nome;
  String endereco;
  DateTime dataEmissao;
  DateTime dataUpload;

  Feira({this.id, this.idNfe, this.cnpj, this.nome, this.endereco, this.dataEmissao, this.dataUpload);

  factory Feira.fromJson(Map<String, dynamic> json) {
    return Feira(      
      id: json['ID'],
      idNfe: json['id_nfe'],
      cnpj: json['cnpj'],
      nome: json['nome'],
      endereco: json['endereco'],
      dataEmissao: json['data_emissao'],
      dataUpload: json['data_upload'],
    );
  }
}
