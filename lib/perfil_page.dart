import 'package:flutter/material.dart';
import 'login_page.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  // Variável que armazena o nome editável do usuário
  String _nomeUsuario = 'Professor de Flutter';
  
  // Controller para capturar o texto digitado no modal
  final TextEditingController _nomeController = TextEditingController();

  void _abrirFormularioEdicao() {
    _nomeController.text = _nomeUsuario;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Faz o modal subir com o teclado
      builder: (context) {
        return Padding(
          // Define os espaçamentos internos e ajusta a altura com base no teclado
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Editar Nome',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Usuário',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  if (_nomeController.text.trim().isNotEmpty) {
                    setState(() {
                      _nomeUsuario = _nomeController.text.trim();
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            
            // Row que agrupa o nome do usuário e o IconButton de edição
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _nomeUsuario,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: _abrirFormularioEdicao,
                  tooltip: 'Editar nome',
                  constraints: const BoxConstraints(), // Reduz o padding interno do botão
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            
            const Text('professor@email.com'),
            const SizedBox(height: 40),

            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar para a home'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(200, 45)),
            ),
            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmar saída'),
                    content: const Text('Deseja realmente sair do sistema?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Não'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text('Sim'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sair do sistema'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
