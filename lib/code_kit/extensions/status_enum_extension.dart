
import 'package:md_notes/code_kit/enums/app_enums.dart';

extension StatusEnumExtension on BlocStatesEnum{
  bool isSuccess() => this == BlocStatesEnum.success;
  bool isLoading() => this == BlocStatesEnum.loading;
  bool isFailure() => this == BlocStatesEnum.failure;
}