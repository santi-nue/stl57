import 'package:flutter/material.dart';

abstract class ConfigItem extends StatefulWidget {
  const ConfigItem({super.key, required this.label});
  final String label;

  @override
  ConfigItemState createState();
}

abstract class ConfigItemState<T extends ConfigItem> extends State<T> {
  @override
  Widget build(BuildContext ctx) {
    return Text(widget.label);
  }
}

class SliderItem extends ConfigItem {
  const SliderItem({super.key, required super.label});

  @override
  ConfigItemState createState() => SliderItemState();
}

class SliderItemState extends ConfigItemState<SliderItem> {
  // In Flutter camelCase is used to name variables
  double currValue = 50;

  @override
  Widget build(BuildContext ctx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 50,
              minHeight: 20,
            ),
            child: super.build(ctx),
          ),
        ),
        Flexible(
          flex: 3,
          child: Slider(
            value: currValue,
            min: 0,
            max: 100,
            onChanged: (double value) {
              setState(() {
                currValue = value;
              });
            },
          ),
        ),
        Flexible(
          flex: 1,
          child: Text(currValue.toString()),
        ),
      ],
    );
  }
}

class InputItem extends ConfigItem {
  const InputItem({super.key, required super.label});

  @override
  ConfigItemState createState() => InputItemState();
}

class InputItemState extends ConfigItemState<InputItem> {
  @override
  Widget build(BuildContext ctx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 50,
              minHeight: 20,
            ),
            child: super.build(ctx),
          ),
        ),
        const Flexible(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                )),
          ),
        ),
      ],
    );
  }
}