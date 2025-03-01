class TShirtCalculatorLogic {
  static const double small = 7.9;
  static const double medium = 8.3;
  static const double large = 12.7;

  static double calculatePrice(String size, int quantity) {
    double unitPrice;
    switch (size) {
      case 'small':
        unitPrice = small;
        break;
      case 'medium':
        unitPrice = medium;
        break;
      case 'large':
        unitPrice = large;
        break;
      default:
        throw ArgumentError('Invalid size: $size');
    }
    return double.parse( (unitPrice * quantity).toStringAsFixed(1));
  }

  static double calculatePriceWithDiscount(String size, int quantity, String discount) {
    double price = calculatePrice(size, quantity);
    
    if (discount == '10%') {
      return price * 0.9;
    } else if (discount == '20€' && price > 100) {
      return price - 20;
    }
    return price;
  }
}