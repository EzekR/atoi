import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/search_model.dart';
import 'package:atoi/models/engineer_model.dart';
import 'package:atoi/models/manager_model.dart';
import 'package:atoi/models/constants_model.dart';

/// app主模型类
class MainModel extends Model with SearchModel, EngineerModel, ManagerModel, ConstantsModel{
  /// 重写模型of方法
  static MainModel of(context) =>
      ScopedModel.of<MainModel>(context);
}