import 'package:flutter/material.dart';
import 'package:empty/flutter/cat/bemen3/m7/t_shirt_calculator_logic.dart';

class TShirtCalculatorScreen extends StatefulWidget {
  const TShirtCalculatorScreen({super.key});

  @override
  TShirtCalculatorScreenState createState() => TShirtCalculatorScreenState();
}

class TShirtCalculatorScreenState extends State<TShirtCalculatorScreen> {
  static const double smallPrice = TShirtCalculatorLogic.small;
  static const double mediumPrice = TShirtCalculatorLogic.medium;
  static const double largePrice = TShirtCalculatorLogic.large;

  int? _numTShirts;
  String? _size;
  String? _offer;
  double _price = 0.0;

  void _calculatePrice() {
    if (_numTShirts == null || _size == null) {
      setState(() {
        _price = 0.0;
      });
      return;
    }

    if (_offer == null) {
      setState(() {
        _price = TShirtCalculatorLogic.calculatePrice(_size!, _numTShirts!);
      });
    } else {
      setState(() {
        _price = TShirtCalculatorLogic.calculatePriceWithDiscount(
            _size!, _numTShirts!, _offer!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20),
          MyTextInput(
            labelText: 'Samarretes',
            hintText: 'Número de samarretes',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _numTShirts = int.tryParse(value);
                _calculatePrice();
              });
            },
          ),
          const Text('Talla'),
          RadioListTile(
            title: Text('Petita ($smallPrice €)'),
            value: 'small',
            groupValue: _size,
            onChanged: (value) {
              setState(() {
                _size = value;
                _calculatePrice();
              });
            },
          ),
          RadioListTile(
            title: Text('Mitjana ($mediumPrice €)'),
            value: 'medium',
            groupValue: _size,
            onChanged: (value) {
              setState(() {
                _size = value;
                _calculatePrice();
              });
            },
          ),
          RadioListTile(
            title: Text('Gran ($largePrice €)'),
            value: 'large',
            groupValue: _size,
            onChanged: (value) {
              setState(() {
                _size = value;
                _calculatePrice();
              });
            },
          ),
          const SizedBox(height: 20),
          const Text('Oferta'),
          DropdownButton<String>(
            value: _offer,
            items: const [
              DropdownMenuItem(
                value: null,
                child: Text('Sense desompte'),
              ),
              DropdownMenuItem(
                value: '10%',
                child: Text('Descompte del 10%'),
              ),
              DropdownMenuItem(
                value: '20€',
                child: Text('Descompte per quantitat'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _offer = value;
                _calculatePrice();
              });
            },
            hint: const Text('Selecciona una oferta'),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Preu: $_price €',
                style: const TextStyle(fontSize: 32),
              ),
              //TODO Aquí iría otro children con el texto de alerta en casode que descuento por cantidad
            ],
          ),
        ],
      ),
    );
  }
}

class MyTextInput extends StatelessWidget {
  final String labelText;
  final String hintText;
  final TextInputType keyboardType;
  final Function(String) onChanged;

  const MyTextInput({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.keyboardType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, // Set the desired width
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey), // Add border
        borderRadius: BorderRadius.circular(8), // Optional: Add border radius
      ),
      child: TextField(
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: InputBorder.none, // Remove default border
          contentPadding: EdgeInsets.all(8), // Add padding inside the border
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
    );
  }
}