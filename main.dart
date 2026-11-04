import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

// Stateless: кореневий віджет застосунку, не має змінного стану.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Лаба 7: конфігуратор контейнера',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.red, useMaterial3: true),
      home: const ConfiguratorPage(),
    );
  }
}

// Stateful: сторінка зберігає поточні значення ширини, висоти та радіуса.
class ConfiguratorPage extends StatefulWidget {
  const ConfiguratorPage({super.key});

  @override
  State<ConfiguratorPage> createState() => _ConfiguratorPageState();
}

class _ConfiguratorPageState extends State<ConfiguratorPage> {
  static const double _maxSize = 300;
  static const double _maxRadius = 150;

  static const double _defaultWidth = 200;
  static const double _defaultHeight = 150;
  static const double _defaultRadius = 40;

  double _width = _defaultWidth;
  double _height = _defaultHeight;
  double _radius = _defaultRadius;

  void _reset() {
    setState(() {
      _width = _defaultWidth;
      _height = _defaultHeight;
      _radius = _defaultRadius;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Конфігуратор контейнера')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Область попереднього перегляду
            Container(
              height: _maxSize + 20,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: RedBox(width: _width, height: _height, radius: _radius),
              ),
            ),
            const SizedBox(height: 16),
            ParamControl(
              label: 'Ширина',
              value: _width,
              min: 0,
              max: _maxSize,
              onChanged: (v) => setState(() => _width = v),
            ),
            ParamControl(
              label: 'Висота',
              value: _height,
              min: 0,
              max: _maxSize,
              onChanged: (v) => setState(() => _height = v),
            ),
            ParamControl(
              label: 'Радіус верхнього правого кутка',
              value: _radius,
              min: 0,
              max: _maxRadius,
              onChanged: (v) => setState(() => _radius = v),
            ),
            const SizedBox(height: 8),
            Text(
              'Ширина: ${_width.round()}, висота: ${_height.round()}, '
                  'радіус: ${_radius.round()}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Align(
              child: OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Скинути'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Stateless: червоний контейнер. Лише відображає передані параметри.
class RedBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const RedBox({
    super.key,
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.only(topRight: Radius.circular(radius)),
      ),
    );
  }
}

// Stateful: один параметр = повзунок + поле введення числа.
// Стан (контролер текстового поля та ознака помилки) живе тут.
class ParamControl extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const ParamControl({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<ParamControl> createState() => _ParamControlState();
}

class _ParamControlState extends State<ParamControl> {
  late final TextEditingController _controller;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.round().toString());
  }

  @override
  void didUpdateWidget(covariant ParamControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Якщо значення змінили ззовні (повзунок, «Скинути»), оновлюємо текст.
    final typed = int.tryParse(_controller.text);
    if (typed == null || typed != widget.value.round()) {
      _controller.text = widget.value.round().toString();
      _error = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    final parsed = double.tryParse(text);
    if (parsed != null && parsed >= widget.min && parsed <= widget.max) {
      setState(() => _error = false);
      widget.onChanged(parsed);
    } else {
      setState(() => _error = text.isNotEmpty);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: widget.value.clamp(widget.min, widget.max),
                  min: widget.min,
                  max: widget.max,
                  onChanged: widget.onChanged,
                ),
              ),
              SizedBox(
                width: 110,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    isDense: true,
                    border: const OutlineInputBorder(),
                    suffixText: 'px',
                    errorText: _error
                        ? '${widget.min.round()}–${widget.max.round()}'
                        : null,
                  ),
                  onChanged: _onTextChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}