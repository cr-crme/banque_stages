import 'package:flutter/material.dart';

class NumberedTablet extends StatelessWidget {
  const NumberedTablet(
      {super.key, required this.number, this.hideIfEmpty = false, this.color});

  final int number;
  final bool hideIfEmpty;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return hideIfEmpty && number == 0
        ? const SizedBox(width: 0, height: 0)
        : Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black,
                          offset: Offset(2, 2),
                          blurRadius: 4)
                    ]),
                child: const Icon(
                  Icons.circle,
                  color: Colors.white70,
                  size: 30,
                ),
              ),
              const Icon(
                Icons.circle,
                color: Colors.white70,
                size: 38,
              ),
              Icon(
                Icons.circle,
                color: color ?? Theme.of(context).primaryColor,
                size: 30,
              ),
              Text(
                number.toString(),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          );
  }
}
