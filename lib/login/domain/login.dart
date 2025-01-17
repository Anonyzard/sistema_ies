import 'package:either_dart/either.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sistema_ies/core/domain/entities/student.dart';
import 'package:sistema_ies/core/domain/entities/user_roles.dart';
// import 'package:sistema_ies/core/domain/entities/student.dart';
// import 'package:sistema_ies/core/domain/entities/user_roles.dart';
import 'package:sistema_ies/core/domain/entities/users.dart';
import 'package:sistema_ies/core/domain/ies_system.dart';
import 'package:sistema_ies/core/domain/utils/operation_utils.dart';
import 'package:sistema_ies/core/domain/repositories/users_repository_port.dart';
import 'package:sistema_ies/core/domain/utils/responses.dart';

//Login states

enum LoginStateName {
  init,
  failure,
  emailNotVerifiedFailure,
  successfullySignIn,
  passwordResetSent,
  verificationEmailSent,
  loading
}

class LoginState extends OperationState {
  final IESUser? currentIESUserIfAny;
  // final IESUser? currentIESUserRole;

  const LoginState({required this.currentIESUserIfAny, required stateName})
      : super(stateName: stateName);

  @override
  List<Object?> get props => [];

  LoginState copyChangingState({required LoginStateName newState}) {
    return LoginState(
        currentIESUserIfAny: currentIESUserIfAny, stateName: newState);
  }
}

// LOGIN USE CASE
class LoginUseCase extends Operation<LoginState> {
//Auth Use Case initialization
  LoginUseCase()
      : super(const LoginState(
            currentIESUserIfAny: null, stateName: LoginStateName.init));

  Future signIn(String userDNIOrEmail, String password) async {
    // var response;
    bool successfullyLogin = false;
    bool validEmail = true;
    LoginStateName failureType = LoginStateName.failure;
    IESUser? signInUser;
    String userEmail = userDNIOrEmail;
    changeState(
        currentState.copyChangingState(newState: LoginStateName.loading));
    if (!userDNIOrEmail.contains('@')) {
      await IESSystem()
          .getUsersRepository()
          .getIESUserByDNI(dni: int.parse(userDNIOrEmail))
          .then((getIESUserByDNI) =>
              getIESUserByDNI.fold((failure) => validEmail = false, (iesUser) {
                userEmail = iesUser.email;
              }));
    }
    if (validEmail) {
      await IESSystem()
          .getUsersRepository()
          .signInUsingEmailAndPassword(email: userEmail, password: password)
          .then((signInResponse) => signInResponse.fold((failure) {
                if (failure.failureName ==
                    UsersRepositoryFailureName.notVerifiedEmail) {
                  failureType = LoginStateName.emailNotVerifiedFailure;
                }
              }, (iesUser) {
                successfullyLogin = true;
                signInUser = iesUser;
              }));
    }
    if (successfullyLogin) {
      if ((signInUser!.getCurrentRole().userRoleTypeName() ==
          UserRoleTypeName.student)) {
        await IESSystem().getStudentRecordRepository().getStudentRecord(
            idUser: signInUser!.id,
            syllabus: (signInUser!.getCurrentRole() as Student)
                .syllabus
                .administrativeResolution);
      }

      changeState(LoginState(
          currentIESUserIfAny: signInUser,
          stateName: LoginStateName.successfullySignIn));
      IESSystem().onUserLogged(signInUser!);
    } else {
      changeState(currentState.copyChangingState(newState: failureType));
    }
  }

  Future reSendEmailVerification() async {
    Either<Failure, Success> response =
        await IESSystem().getUsersRepository().reSendEmailVerification();
    response.fold(
        (failure) => changeState(
            currentState.copyChangingState(newState: LoginStateName.failure)),
        (success) {
      changeState(currentState.copyChangingState(
          newState: LoginStateName.verificationEmailSent));
    });
  }

  void startRegisteringIncomingUser() async {
    /*  */
    IESSystem().startRegisteringNewUser();
  }

  returnToLogin() {
    changeState(currentState.copyChangingState(newState: LoginStateName.init));
  }
}

class PasswordVisibilityHandler {
  PasswordVisibilityHandler(this.visibility);
  final bool visibility;
}

class PasswordVisibilityHandlerNotifier
    extends StateNotifier<PasswordVisibilityHandler> {
  PasswordVisibilityHandlerNotifier() : super(PasswordVisibilityHandler(false));

  bool passState() {
    return state.visibility;
  }

  void switchState() {
    state = PasswordVisibilityHandler(!passState());
  }
}
