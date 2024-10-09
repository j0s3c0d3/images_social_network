import 'package:flutter/material.dart';

import '../../../util/image_filters.dart';

class FilterOption extends StatefulWidget {
  const FilterOption({super.key, required this.onFilterChanged, required this.currentFilter});

  final Function(ColorFilter) onFilterChanged;
  final ColorFilter currentFilter;

  @override
  _FilterOptionState createState() => _FilterOptionState();
}

class _FilterOptionState extends State<FilterOption> {

  static final List<ColorFilter> filterOptions = <ColorFilter> [
    ImageFilters.neutral,
    ImageFilters.greyscale,
    ImageFilters.invert,
    ImageFilters.sepia,
    ImageFilters.vintage,
    ImageFilters.cooler,
    ImageFilters.warmer,
  ];

  static final List<String> filterNames = <String> [
    "",
    "B&N",
    "Negativo",
    "Sepia",
    "Vintage",
    "Frío",
    "Calor"
  ];

  late int selectedIndex;

  void changeFilter(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.onFilterChanged(filterOptions[index]);
  }

  @override
  void initState() {
    setState(() {
      selectedIndex = filterOptions.indexOf(widget.currentFilter);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filterOptions.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              changeFilter(index);
            },
            child: Container(
              width: 75,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selectedIndex == index ? Colors.deepOrange : Colors.white,
                border: Border.all(
                  color: Colors.deepOrange,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: index == 0
                    ? const Icon(Icons.cancel_outlined)
                    : Text(
                        filterNames[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                      ),
              ),
            ),
          );
        }
    );
  }
}



