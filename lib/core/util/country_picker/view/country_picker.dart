import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_color.dart';
import '../../common_widgets.dart';
import '../controller/country_controller.dart';
import '../model/country_model.dart';

class CountryPicker extends StatefulWidget {
  const CountryPicker({super.key});

  @override
  State<CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends State<CountryPicker> {
  List<String> countryNames = [];
  List<String> filteredCountryNames = [];
  TextEditingController searchController = TextEditingController();
  final contrlr = Get.put(CountryController());

  @override
  void initState() {
    super.initState();
    countryNames = countryMap.keys.toList();
    filteredCountryNames = countryNames;
  }

  void filterCountries(String query) {
    if (query.isEmpty) {
      filteredCountryNames = countryNames;
    } else {
      filteredCountryNames =
          countryNames
              .where(
                (country) =>
                    country.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.white,
        title: const Text(
          'Choose Country',
          style: TextStyle(color: AppColor.black),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 45,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.black.withOpacity(0.4),
            ),
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Center(
              child: TextField(
                controller: searchController,
                onChanged: (value) => filterCountries(value),
                cursorColor: AppColor.black,
                style: const TextStyle(color: AppColor.black, fontSize: 10),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: AppColor.black),
                  hintText: 'Search country...',
                  hintStyle: TextStyle(
                    color: AppColor.black,
                    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filteredCountryNames.length,
              itemBuilder: (context, index) {
                final data = countryMap[filteredCountryNames[index]] ?? {};
                return ListTile(
                  onTap: () {
                    contrlr.countryChanged(data, filteredCountryNames[index]);
                    Get.back();
                  },
                  leading: CachedNetworkImage(
                    imageUrl: "${data['flag']}",
                    placeholder:
                        (context, url) => const CircularProgressIndicator(),
                    errorWidget:
                        (context, url, error) => const Icon(Icons.error),
                    height: 30,
                    width: 30,
                  ),
                  title: text(
                    text: filteredCountryNames[index],
                    size: 16,
                    color: AppColor.black,
                    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
