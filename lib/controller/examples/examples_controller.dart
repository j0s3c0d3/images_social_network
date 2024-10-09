import 'package:tfg_project/model/example_model.dart';

import '../../util/order_enum.dart';
import '../base_controller.dart';

class ExamplesController extends BaseController {

  Future<List<Example>?> getExamples(Order order) async {
    return await exampleService.getExamples(order.name);
  }

}