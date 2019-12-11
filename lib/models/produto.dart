class Produto{
  String id;
  String nome;  
  String unidade;
  bool salvar;

  Produto({this.id, this.nome, this.unidade, this.salvar});

  Map<String,dynamic> toJson(){
    return {
      "id": this.id,
      "nome": this.nome,
      "unidade": this.unidade      
    };
  }
}