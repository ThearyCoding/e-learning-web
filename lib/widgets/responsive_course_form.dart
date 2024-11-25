import 'package:e_learningapp_admin/widgets/customize_range_textfield.dart';

import '../export/export.dart';

class ResponsiveCourseForm extends StatelessWidget {
  final TextEditingController txttitle;
  final double coursePrice;
  final int discount;
  final Function(double) onCoursePriceChanged;
  final Function(int) onDiscountChanged;

  const ResponsiveCourseForm({
    super.key,
    required this.txttitle,
    required this.coursePrice,
    required this.discount,
    required this.onCoursePriceChanged,
    required this.onDiscountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine the screen type based on width
        bool isDesktop = constraints.maxWidth > 800;
        bool isTablet =
            constraints.maxWidth > 600 && constraints.maxWidth <= 800;

        // For desktop view
        if (isDesktop) {
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTitleField(context),
              ),
              Expanded(
                flex: 1,
                child: _buildPriceField(context),
              ),
              Expanded(
                flex: 1,
                child: _buildDiscountField(context),
              ),
            ],
          );
        }

        // For tablet view
        if (isTablet) {
          return Column(
            children: [
              _buildTitleField(context),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildPriceField(context),
                  ),
                  Expanded(
                    flex: 1,
                    child: _buildDiscountField(context),
                  ),
                ],
              ),
            ],
          );
        }

        // For mobile view
        return Column(
          children: [
            _buildTitleField(context),
            _buildPriceField(context),
            _buildDiscountField(context),
          ],
        );
      },
    );
  }

  Widget _buildTitleField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ResponsiveLayout.isDesktop(context) ? 50 : 20),
          child: const Text(
            'Enter Course title',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 10),
        CustomizTextFormFieldV1(
          controller: txttitle,
          autoFocus: true,
          hintText: 'Course title',
          validator: (value) {
            if (value!.isEmpty) {
              return 'Enter Course title';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPriceField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ResponsiveLayout.isDesktop(context) ? 50 : 20),
          child: const Text(
            'Course Price',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ResponsiveLayout.isDesktop(context) ? 50 : 20),
          child: RangeTextField<double>(
            initialValue: coursePrice,
            minValue: 0,
            maxValue: 1000,
            height: 50,
            onChanged: (value) {
              onCoursePriceChanged(value);
            },
            fieldType: TextFieldType.price,
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ResponsiveLayout.isDesktop(context) ? 50 : 20),
          child: const Text(
            'Discount Percentage (%)',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: ResponsiveLayout.isDesktop(context) ? 50 : 20),
          child: RangeTextField<int>(
            initialValue: discount,
            minValue: 0,
            maxValue: 100,
            height: 50,
            onChanged: (value) {
              onDiscountChanged(value);
            },
            fieldType: TextFieldType.percentage,
          ),
        ),
      ],
    );
  }
}
