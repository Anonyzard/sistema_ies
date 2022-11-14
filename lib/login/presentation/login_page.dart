import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sistema_ies/core/domain/ies_system.dart';
import 'package:sistema_ies/core/domain/utils/operation_utils.dart';
import 'package:sistema_ies/core/presentation/widgets/fields.dart';
import 'package:sistema_ies/login/domain/login.dart';

class LoginPage extends ConsumerWidget {
  LoginPage({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<OperationState>(IESSystem().loginUseCase.stateNotifierProvider,
        (previous, next) {
      if (next.stateName == LoginStateName.failure) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: const Text("Usuario o contraseñas incorrecta")));
      } else if (next.stateName == LoginStateName.emailNotVerifiedFailure) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            content: const Text(
                "Su email no ha sido verificado aún. Revise si casilla de correos por favor")));
      }
    });
    return Scaffold(
      appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ver',
                style: Theme.of(context).textTheme.headline1,
              ),
              Text('App', style: Theme.of(context).textTheme.headline2)
            ],
          ),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 198, 198, 198)),
      body: Container(
        decoration:
            const BoxDecoration(color: Color.fromARGB(255, 255, 255, 255)),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            width: MediaQuery.of(context).size.width / 0.5,
            child: Form(
                key: _formKey,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 150),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    //mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      fieldEmailDNI(
                          _emailTextController, "Email o DNI", false, context),
                      const SizedBox(height: 10),
                      fieldPassword(
                          _passwordTextController, "Contraseña", true, context),
                      const SizedBox(height: 60),
                      Container(
                        width: MediaQuery.of(context).size.width / 0.5,
                        height: 50,
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 36, 110, 221),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: TextButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await IESSystem().loginUseCase.signIn(
                                  _emailTextController.text.trim(),
                                  _passwordTextController.text.trim());
                            }
                          },
                          child: const Text(
                            'Iniciar Sesión',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("¿No tienes cuenta?"),
                          TextButton(
                            onPressed: () async {
                              IESSystem().startRegisteringNewUser();
                            },
                            child: Text(
                              'Registrate',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () async {
                          IESSystem().loginUseCase.startRecoveryPass();
                        },
                        child: Text(
                          '¿Olvidaste la contraseña?',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
