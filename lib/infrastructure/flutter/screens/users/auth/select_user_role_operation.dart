import 'package:flutter/material.dart';
import 'package:sistema_ies/application/ies_system.dart';
// import 'package:sistema_ies/application/ies_system.dart';

class SelectUserRoleOperationPage extends StatelessWidget {
  const SelectUserRoleOperationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Seleccionar operación'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              const SizedBox(height: 28.0),
              ListView(
                  shrinkWrap: true,
                  children: IESSystem()
                      .getCurrentIESUserRoleOperations()
                      .map((e) => ElevatedButton(
                          onPressed: () => {}, child: Text(e.operationName())))
                      .toList()),
              const SizedBox(height: 28.0),
              ElevatedButton(
                onPressed: () => IESSystem().authUseCase.restartLogin(),
                child: const Text(
                  'Regresar a login!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ));
  }
}
