import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'perfil_page.dart';
import 'tarefa.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Tarefa> _itens = [];

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

    
  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }


  Future<void> _carregarTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tarefasString = prefs.getString('lista_tarefas');

    if (tarefasString != null) {
      final List<dynamic> listaDecodificada = json.decode(tarefasString);
      setState(() {
        _itens = listaDecodificada.map((item) => Tarefa.fromMap(item)).toList();
      });
    } else {
      setState(() {
        _itens = [
          Tarefa(titulo: "Tarefa de Flutter", descricao: "Estudar Widget"),
          Tarefa(titulo: "Prática de Dart ", descricao: "Fazer exercícios da professora"),
          Tarefa(titulo: "Projeto Integrado", descricao: "Atividade da Sprint"),
        ];
      });
      _salvarNoDispositivo(); 
    }
  }

  Future<void> _salvarNoDispositivo() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> listaMapas = _itens.map((t) => t.toMap()).toList();
    final String dadosMapeados = json.encode(listaMapas);
    await prefs.setString('lista_tarefas', dadosMapeados);
  }

  void _salvarTarefa(int? index) {
    if (_tituloController.text.isEmpty || _descricaoController.text.isEmpty) return;
    
    setState(() {
      if (index == null) {
        _itens.add(
          Tarefa(
            titulo: _tituloController.text,
            descricao: _descricaoController.text,
          ),
        );
      } else {
        _itens[index].titulo = _tituloController.text;
        _itens[index].descricao = _descricaoController.text;
      }
    });

    _salvarNoDispositivo();
    _tituloController.clear();
    _descricaoController.clear();
    Navigator.pop(context);
  }

  void _excluirTarefa(int index) {
    setState(() {
      _itens.removeAt(index);
    });
    _salvarNoDispositivo();
  }

  void _mostrarFormulario([int? index]) {
    if (index != null) {
      _tituloController.text = _itens[index].titulo;
      _descricaoController.text = _itens[index].descricao;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? 'Nova Tarefa' : 'Editar Tarefa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(labelText: 'Título'),
              autofocus: true,
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _tituloController.clear();
              _descricaoController.clear();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _salvarTarefa(index),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair do Sistema',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Meu Perfil'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const PerfilPage()),
              ),
            ),
          ],
        ),
      ),

      body: _itens.isEmpty
          ? const Center(child: Text("Nenhuma tarefa cadastrada."))
          : ListView.builder(
              itemCount: _itens.length,
              itemBuilder: (context, index) {
                final tarefa = _itens[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: Checkbox(value: tarefa.concluida, 
                      onChanged: (bool? valor) {
                        setState(() {
                          tarefa.concluida = valor ?? false;
                        });
                        _salvarNoDispositivo();
                      }
                    ),
                    title: Text(
                      tarefa.titulo,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: tarefa.concluida
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(tarefa.descricao),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _mostrarFormulario(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _excluirTarefa(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const PerfilPage()),
            );
          }
        },
      ),
    );
  }
}
