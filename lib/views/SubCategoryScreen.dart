import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);
const Color lightBlue = Color(0xFF7ed2f7);
const Color whiteColor = Color(0xFFf7f7f7);

class SubCategoryScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const SubCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class SubCategory {
  final int categoryId;
  final int id;
  final String subCategoryName;
  final String categoryName;

  SubCategory({
    required this.categoryId,
    required this.id,
    required this.subCategoryName,
    required this.categoryName,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      categoryId: json['category_id'] as int,
      id: json['id'] as int,
      subCategoryName: json['sub_categoryname'] as String,
      categoryName: json['category_name'] as String,
    );
  }
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  List<SubCategory> subCategories = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSubCategories();
  }

  Future<void> _fetchSubCategories() async {
    try {
      final String apiUrl =
          'https://54kidsstreet.org/api/subCategory/${widget.categoryId}';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == true) {
          final List<dynamic> subCategoryData = jsonData['data'];
          setState(() {
            subCategories =
                subCategoryData.map((data) => SubCategory.fromJson(data)).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = jsonData['msg'] ?? 'Failed to load subcategories';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load subcategories: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching subcategories: $e';
        isLoading = false;
      });
    }
  }

  // Build subcategory button without icon, matching HomeServiceView style
  Widget _buildSubCategoryButton(SubCategory subCategory) {
    return ElevatedButton(
      onPressed: () {
        // Show a snackbar for now; replace with navigation if needed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected: ${subCategory.subCategoryName}'),
            backgroundColor: mediumBlue,
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: whiteColor,
        side: const BorderSide(color: mediumBlue, width: 2),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            subCategory.subCategoryName,
            style: const TextStyle(
              color: darkBlue,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.categoryName} Subcategories',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: whiteColor,
            fontSize: 18,
          ),
        ),
        backgroundColor: darkBlue,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: whiteColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: darkBlue))
              : errorMessage != null
              ? Center(
            child: Text(
              errorMessage!,
              style: const TextStyle(color: darkBlue), // Using darkBlue for error
            ),
          )
              : subCategories.isEmpty
              ? const Center(child: Text('No subcategories available', style: TextStyle(color: darkBlue)))
              : ListView.builder(
            itemCount: subCategories.length,
            itemBuilder: (context, index) {
              final subCategory = subCategories[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: _buildSubCategoryButton(subCategory),
              );
            },
          ),
        ),
      ),
    );
  }
}