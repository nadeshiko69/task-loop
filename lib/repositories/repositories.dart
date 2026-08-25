import 'auth_repository.dart';
import 'household_repository.dart';
import 'task_repository.dart';
import 'user_repository.dart';

/// 画面から参照する入口。テストで差し替えるときはコンストラクタ引数を使う。
final authRepository = AuthRepository();
final userRepository = UserRepository();
final householdRepository = HouseholdRepository();
final taskRepository = TaskRepository();
