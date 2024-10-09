enum Order {
  latest,
  oldest,
  popular,
  random
}

extension OrderExtension on Order {

  static Order getOrder(String string) {
    switch (string) {
      case "oldest":
        return Order.oldest;
      case "popular":
        return Order.popular;
      case "random":
        return Order.random;
      default:
        return Order.latest;
    }
  }

  static String getOrderViewName(Order order) {
    switch (order) {
      case Order.latest:
        return "Recientes";
      case Order.oldest:
        return "Antiguas";
      case Order.popular:
        return "Populares";
      case Order.random:
        return "Aleatorio";
    }
  }

}