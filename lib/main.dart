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
  int _selectedIndex = 0;
  bool _botaoCarregarVisivel = false;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    lerQrcode();
    setState(() {
      _selectedIndex = index;
      _botaoCarregarVisivel = true;
    });
  }

  void adicionar(
      String codigo, String nome, String unidade, String valorUnitario) {
    setState(() {
      Produto prod = Produto(
          id: null, codigo: codigo, nome: nome, unidade: unidade, salvar: true);
      prod.valorUnitario = double.parse(valorUnitario);
      widget.produtos.add(prod);
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
    Map produto, itemFeira;
    Feira f;
    Produto p;
    try {
      var uriResponse = await client.post(
          "https://familiai-servicos.herokuapp.com/feira/",
          headers: {"content-type": "application/json"},
          body: jsonEncode(feira));
      if (uriResponse.statusCode == 200) {
        f = Feira.fromJson(json.decode(uriResponse.body));
        for (Produto prod in widget.produtos) {
          produto = {
            "codigo": prod.codigo,
            "nome": prod.nome,
            "unidade": prod.unidade,
          };
          uriResponse = await client.post(
              "https://familiai-servicos.herokuapp.com/produto/",
              headers: {"content-type": "application/json"},
              body: jsonEncode(produto));
          if (uriResponse.statusCode == 200) {
            p = Produto.fromJson(json.decode(uriResponse.body));
            itemFeira = {
              "id_feira": f.id,
              "id_produto": p.id,
              "valor_unitario": prod.valorUnitario
            };
            print(jsonEncode(itemFeira));
            uriResponse = await client.post(
                "https://familiai-servicos.herokuapp.com/item_feira/",
                headers: {"content-type": "application/json"},
                body: jsonEncode(itemFeira));
          }
        }
      } else {
        // If that response was not OK, throw an error.
        throw Exception('Failed to load post');
      }
      //print(await client.get(uriResponse.body));
    } finally {
      setState(() {
        widget.produtos = [];
        icone = Icons.camera_enhance;
        salvar = false;
      });
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
            node.findElements('uCom').single.text,
            node.findElements('vUnCom').single.text));
      } else {
        // If that response was not OK, throw an error.
        throw Exception('Failed to load post');
      }
    } else {
      print("Entrou no ELSE");
      incluirFeira();
      //for (var p in widget.produtos) {}
      _botaoCarregarVisivel = false;
    }
  }

  /*Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Economizai"),
      ),
      body: ListView.builder(
        itemCount: widget.produtos.length,
        itemBuilder: (BuildContext ctx, int index) {
          final produto = widget.produtos[index];
          return CheckboxListTile(
            title: Text(produto.codigo + "\n - " + produto.nome),
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
  }*/

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
            title: Text(produto.codigo + "\n - " + produto.nome),
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_enhance),
            title: Text('Nova Feira'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            title: Text('Minhas Feiras'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      floatingActionButton: new Visibility(
        visible: _botaoCarregarVisivel,
        child: new FloatingActionButton(
            onPressed: lerQrcode, child: Icon(Icons.cloud_upload)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
