import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/shift_house_viewmodel.dart';
import 'item_category_screen.dart';

const Color darkBlue = Color(0xFF03669d);
const Color mediumBlue = Color(0xFF37b3e7);
const Color lightBlue = Color(0xFF7ed2f7);
const Color whiteColor = Color(0xFFf7f7f7);

class ShiftHouseScreen extends StatelessWidget {
  const ShiftHouseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShiftHouseViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Shift My House',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
               // backgroundColor: Colors.white,

                color: whiteColor,
                fontSize: 20,
              ),
            ),
            backgroundColor: darkBlue,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: whiteColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'When to shift?',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _selectDate(context, viewModel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mediumBlue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          viewModel.shiftHouseData.selectedDate.isEmpty
                              ? 'Select date'
                              : viewModel.shiftHouseData.selectedDate,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true, // ✅ Prevent overflow
                        decoration: InputDecoration(
                          hintText: 'Select time',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // ✅ Adjust padding
                        ),
                        value: viewModel.shiftHouseData.selectedTime.isEmpty
                            ? null
                            : viewModel.shiftHouseData.selectedTime,
                        items: viewModel.timeSlots.map((String time) {
                          return DropdownMenuItem<String>(
                            value: time,
                            child: Text(time, overflow: TextOverflow.ellipsis), // ✅ Avoid long text pushing arrow
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            viewModel.updateTime(newValue);
                          }
                        },
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Type of house',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Residential',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: viewModel.houseTypes.length,
                    itemBuilder: (context, index) {
                      final houseType = viewModel.houseTypes[index];
                      final isSelected = viewModel.shiftHouseData.houseType == houseType;

                      return GestureDetector(
                        onTap: () => viewModel.updateHouseType(houseType),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? mediumBlue : Colors.grey,
                              width: isSelected ? 3 : 2,
                            ),
                            color: isSelected ? mediumBlue.withOpacity(0.1) : Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              houseType,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? mediumBlue : Colors.black,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider.value(
                            value: viewModel,
                            child: const ItemCategoryScreen(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                    //  backgroundColor: Colors.red,
                        backgroundColor: darkBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, ShiftHouseViewModel viewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: mediumBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      viewModel.updateDate('${picked.day}/${picked.month}/${picked.year}');
    }
  }
}