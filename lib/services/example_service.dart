import 'package:dio/dio.dart';
import 'package:tfg_project/model/example_model.dart';
import 'package:tfg_project/util/order_enum.dart';

class ExampleService {

  Future<dynamic> _getMethod(String url) async {
    Dio dio = Dio();
    dio.options.headers['content-type'] = 'application/json';

    return await dio.get(url,
        options: Options(
            responseType: ResponseType.json,
            method: 'GET')).then((value) {
      return value;
    });
  }

  Future<List<Example>?> getExamples(String order) async {
    dynamic response;
    if (order == Order.random.name) {
      response = await _getMethod('https://api.unsplash.com/photos/random?count=30&client_id=pMluX6Cg5TI5izDiSEl_N0kYh_xtRlGD9-5dMDUPZA4');
    }
    else {
      response = await _getMethod('https://api.unsplash.com/photos?per_page=30&order_by=$order&client_id=pMluX6Cg5TI5izDiSEl_N0kYh_xtRlGD9-5dMDUPZA4');
    }

    if (response.statusCode == 200) {
      List<Example> examples = [];
      response.data.forEach((elm) {
        Example example = Example.fromJSON(elm);
        examples.add(example);
      });
      return examples;
    }
    return null;
  }

}