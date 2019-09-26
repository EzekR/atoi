import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/search_model.dart';
import 'package:atoi/models/engineer_model.dart';
import 'package:atoi/models/manager_model.dart';
import 'package:atoi/models/constants_model.dart';

class MainModel extends Model with SearchModel, EngineerModel, ManagerModel, ConstantsModel{
  static MainModel of(context) =>
      ScopedModel.of<MainModel>(context);
}