import 'dart:async';
//import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:xml/xml.dart' as xml;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'models/produto.dart';
import 'models/feira.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Economizai',
      home: new HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  var produtos = List<Produto>();

  HomePage() {
    produtos = [];
    /*produtos
        .add(Produto(nome: "Macarrão Vitarella", preco: "2.25", salvar: true));
    produtos.add(Produto(nome: "Feijão Turquesa", preco: "6.5", salvar: true));
    produtos.add(Produto(nome: "Coca Cola 355", preco: "1.80", salvar: true));*/
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String qrcode = "";
  var icone = Icons.camera_enhance;
  bool salvar = false;

  void adicionar(String codigo, String nome, String unidade) {
    setState(() {
      widget.produtos
          .add(Produto(id: codigo, nome: nome, unidade: unidade, salvar: true));
    });
    icone = Icons.cloud_upload;
    salvar = true;
  }

  Future<String> incluirProduto() async {
    var client = new http.Client();
    Map conteudo = {
      "codigo": "1234533678",
      "nome": "biscoito goiaba",
      "unidade": "un"
    };
    try {
      print("ANTES");
      var uriResponse = await client.post(
          "https://familiai-servicos.herokuapp.com/produto/",
          headers: {"content-type": "application/json"},
          body: jsonEncode(conteudo));
      //print(await client.get(uriResponse.body));
    } finally {
      client.close();
    }
  }

  Future<String> incluirFeira() async {
    var client = new http.Client();
    DateTime now = DateTime.now();
    String data = DateFormat('yyyy-MM-dd').format(now);
    Map feira = {"data": data};
    Feira f;
    try {
      var uriResponse = await client.post(
          "https://familiai-servicos.herokuapp.com/feira/",
          headers: {"content-type": "application/json"},
          body: jsonEncode(feira));
      if (uriResponse.statusCode == 200) {
        // If server returns an OK response, parse the JSON.
        f = Feira.fromJson(json.decode(uriResponse.body));
        print(">>> " + uriResponse.body);
        print("ID da feira criada: " + f.id.toString());
      } else {
        // If that response was not OK, throw an error.
        throw Exception('Failed to load post');
      }
      //print(await client.get(uriResponse.body));
    } finally {
      client.close();
    }
  }

  Future lerQrcode() async {
    if (!salvar) {
      qrcode =
          await FlutterBarcodeScanner.scanBarcode("#004297", "Cancelar", true);
      if (!qrcode.startsWith('http://nfce.sefaz.pe.gov.br/')) {
        qrcode =
            'http://nfce.sefaz.pe.gov.br/nfce/consulta?p=26191145543915006112650160000846161993009980|2|1|1|5DA87AC4A0913EF27664A556AE70B1EAF80292E2';
      }
      final response = await http.get(qrcode);
      if (response.statusCode == 200) {
        widget.produtos.clear();
        var document = xml.parse(response.body);
        var titles = document.findAllElements('prod');
        titles.forEach((node) => adicionar(
            node.findElements('cProd').single.text,
            node.findElements('xProd').single.text,
            node.findElements('uCom').single.text));
      } else {
        // If that response was not OK, throw an error.
        throw Exception('Failed to load post');
      }
    } else {
      print("Entrou no ELSE");
      incluirFeira();
      //for (var p in widget.produtos) {}
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Economizai"),
      ),
      body: ListView.builder(
        itemCount: widget.produtos.length,
        itemBuilder: (BuildContext ctx, int index) {
          final produto = widget.produtos[index];
          return CheckboxListTile(
            title: Text(produto.id + "\n - " + produto.nome),
            key: Key(produto.nome),
            value: produto.salvar,
            onChanged: (value) {
              setState(() {
                produto.salvar = value;
              });
              print(value);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: lerQrcode,
        child: Icon(icone),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
