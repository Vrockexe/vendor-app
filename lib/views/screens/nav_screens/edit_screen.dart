//This code was generated from ai
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mac_vendor_store/controllers/category_controller.dart';
import 'package:mac_vendor_store/controllers/product_controller.dart';
import 'package:mac_vendor_store/controllers/subcategory_controller.dart';
import 'package:mac_vendor_store/models/category.dart';
import 'package:mac_vendor_store/models/product.dart';
import 'package:mac_vendor_store/models/subcategory.dart';
import 'package:mac_vendor_store/provider/vendor_provider.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  const EditProductScreen({super.key});

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late Future<List<Category>> futureCategories;
  Future<List<Subcategory>>? futureSubcategories;
  List<Product> products = [];
  Product? selectedProduct;
  Category? selectedCategory;
  Subcategory? selectedSubcategory;

  String? productName;
  int? productPrice;
  int? quantity;
  String? description;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    futureCategories = CategoryController().loadCategories();
  }

  void getSubcategoryByCategory(Category category) {
    futureSubcategories =
        SubcategoryController().getSubCategoriesByCategoryName(category.name);
    selectedSubcategory = null;
    products = [];
    selectedProduct = null;
    setState(() {});
  }

  Future<void> getProductsBySubCategory(String subCategory) async {
    final vendorId = ref.read(vendorProvider)!.id;
    final productController = ProductController();

    if (selectedCategory == null) return;

    final fetchedProducts =
        await productController.getProductsByCategoryAndSubcategory(
      category: selectedCategory!.name,
      subCategory: subCategory,
      vendorId: vendorId,
    );

    setState(() {
      products = fetchedProducts;
    });
  }

  void onSaveChanges() async {
    if (_formKey.currentState!.validate() && selectedProduct != null) {
      setState(() => isLoading = true);

      final updatedProduct = Product(
        id: selectedProduct!.id,
        productName: productName ?? selectedProduct!.productName,
        productPrice: productPrice ?? selectedProduct!.productPrice,
        quantity: quantity ?? selectedProduct!.quantity,
        description: description ?? selectedProduct!.description,
        category: selectedProduct!.category,
        vendorId: selectedProduct!.vendorId,
        name: selectedProduct!.name,
        subCategory: selectedProduct!.subCategory,
        images: selectedProduct!.images,
      );

      try {
        await ProductController()
            .updateProduct(product: updatedProduct, context: context);
      } finally {
        if (mounted) setState(() => isLoading = false); // ✅ ensures button re-enables even if error
      }
    }
  }

  Widget buildDropdown<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return SizedBox(
      width: 350,
      child: DropdownButtonFormField<T>(
        value: value,
        hint: Text(hint),
        items: items,
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding:
          EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// Product Image at Top
                if (selectedProduct != null &&
                    selectedProduct!.images.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      selectedProduct!.images.first,
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 30),

                /// Category Dropdown
                FutureBuilder<List<Category>>(
                  future: futureCategories,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasData) {
                      return buildDropdown<Category>(
                        hint: 'Select Category',
                        value: selectedCategory,
                        items: snapshot.data!
                            .map((Category category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category.name),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => selectedCategory = value);
                          getSubcategoryByCategory(value!);
                        },
                      );
                    } else {
                      return const Text("No categories found");
                    }
                  },
                ),

                const SizedBox(height: 15),

                /// Subcategory Dropdown
                FutureBuilder<List<Subcategory>>(
                  future: futureSubcategories,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasData) {
                      return buildDropdown<Subcategory>(
                        hint: 'Select Subcategory',
                        value: selectedSubcategory,
                        items: snapshot.data!
                            .map((Subcategory subcategory) =>
                                DropdownMenuItem(
                                  value: subcategory,
                                  child: Text(subcategory.subcategoryName),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => selectedSubcategory = value);
                          getProductsBySubCategory(value!.subcategoryName);
                        },
                      );
                    } else {
                      return const Text("No subcategories found");
                    }
                  },
                ),

                const SizedBox(height: 15),

                /// Product Dropdown
                buildDropdown<Product>(
                  hint: 'Select Product',
                  value: selectedProduct,
                  items: products
                      .map((Product product) => DropdownMenuItem(
                            value: product,
                            child: Text(product.productName),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedProduct = value;
                      productName = value!.productName;
                      productPrice = value.productPrice;
                      quantity = value.quantity;
                      description = value.description;
                      isLoading = false; // ✅ re-enable button after selection
                    });
                  },
                ),

                const SizedBox(height: 25),

                /// Editable Fields
                if (selectedProduct != null) ...[
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      initialValue: productName,
                      onChanged: (val) => productName = val,
                      decoration:
                          const InputDecoration(labelText: 'Product Name'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      initialValue: productPrice?.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => productPrice = int.tryParse(val),
                      decoration:
                          const InputDecoration(labelText: 'Product Price'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      initialValue: quantity?.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => quantity = int.tryParse(val),
                      decoration:
                          const InputDecoration(labelText: 'Quantity'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      initialValue: description,
                      maxLines: 3,
                      onChanged: (val) => description = val,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 350,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onSaveChanges,
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Update Product'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
