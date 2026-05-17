import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'perfil_page.dart';
import 'tarefa.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Mantemos as duas listas: a original completa e a filtrada que aparece na tela
  List<Tarefa> _itensCompleto = [];
  List<Tarefa> _itensFiltrados = [];

  bool _estaPesquisando = false;
  final TextEditingController _buscaController = TextEditingController();
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
        _itensCompleto = listaDecodificada.map((item) => Tarefa.fromMap(item)).toList();
        _filtrarTarefas(_buscaController.text); // Inicializa a lista visual
      });
    } else {
      setState(() {
        _itensCompleto = [
          Tarefa(titulo: "Tarefa de Flutter", descricao: "Estudar Widget"),
          Tarefa(titulo: "Prática de Dart ", descricao: "Fazer exercícios da professora"),
          Tarefa(titulo: "Projeto Integrado", descricao: "Atividade da Sprint"),
        ];
        _filtrarTarefas('');
      });
      _salvarNoDispositivo(); 
    }
  }

  Future<void> _salvarNoDispositivo() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> listaMapas = _itensCompleto.map((t) => t.toMap()).toList();
    final String dadosMapeados = json.encode(listaMapas);
    await prefs.setString('lista_tarefas', dadosMapeados);
  }

  // Função responsável por filtrar a lista conforme a digitação
  void _filtrarTarefas(String termoBusca) {
    setState(() {
      if (termoBusca.isEmpty) {
        _itensFiltrados = List.from(_itensCompleto);
      } else {
        _itensFiltrados = _itensCompleto
            .where((tarefa) => tarefa.titulo.toLowerCase().contains(termoBusca.toLowerCase()))
            .toList();
      }
    });
  }

  void _salvarTarefa(int? index) {
    if (_tituloController.text.isEmpty || _descricaoController.text.isEmpty) return;
    
    setState(() {
      if (index == null) {
        _itensCompleto.add(
          Tarefa(
            titulo: _tituloController.text,
            descricao: _descricaoController.text,
          ),
        );
      } else {
        // Encontra a tarefa correta na lista completa comparando a referência
        final tarefaEditada = _itensFiltrados[index];
        final indexNaCompleta = _itensCompleto.indexOf(tarefaEditada);
        
        _itensCompleto[indexNaCompleta].titulo = _tituloController.text;
        _itensCompleto[indexNaCompleta].descricao = _descricaoController.text;
      }
      _filtrarTarefas(_buscaController.text); // Atualiza o filtro na tela
    });

    _salvarNoDispositivo();
    _tituloController.clear();
    _descricaoController.clear();
    Navigator.pop(context);
  }

  void _excluirTarefa(int index) {
    setState(() {
      final tarefaExcluida = _itensFiltrados[index];
      _itensCompleto.remove(tarefaExcluida);
      _filtrarTarefas(_buscaController.text); // Atualiza o filtro na tela
    });
    _salvarNoDispositivo();
  }

  void _mostrarFormulario([int? index]) {
    if (index != null) {
      _tituloController.text = _itensFiltrados[index].titulo;
      _descricaoController.text = _itensFiltrados[index].descricao;
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
        // Altera dinamicamente o título para um TextField de busca
        title: _estaPesquisando
            ? TextField(
                controller: _buscaController,
                autofocus: true,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Buscar tarefa pelo título...',
                  border: InputBorder.none,
                ),
                onChanged: _filtrarTarefas,
              )
            : const Text('Home'),
        actions: [
          // Botão para ativar/desativar a barra de pesquisa
          IconButton(
            icon: Icon(_estaPesquisando ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _estaPesquisando = !_estaPesquisando;
                if (!_estaPesquisando) {
                  _buscaController.clear();
                  _filtrarTarefas('');
                }
              });
            },
          ),
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

      // Passamos a ler e renderizar a lista _itensFiltrados
      body: _itensFiltrados.isEmpty
          ? const Center(child: Text("Nenhuma tarefa encontrada."))
          : ListView.builder(
              itemCount: _itensFiltrados.length,
              itemBuilder: (context, index) {
                final tarefa = _itensFiltrados[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: tarefa.concluida, 
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
