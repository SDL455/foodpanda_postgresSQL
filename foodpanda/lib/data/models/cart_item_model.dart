import 'menu_item_model.dart';

class CartItemModel {
  final String id;
  final MenuItemModel menuItem;
  int quantity;
  final List<SelectedOption>? selectedOptions;
  final String? note;

  CartItemModel({
    required this.id,
    required this.menuItem,
    this.quantity = 1,
    this.selectedOptions,
    this.note,
  });

  double get totalPrice {
    double optionsPrice = 0;
    if (selectedOptions != null) {
      for (var option in selectedOptions!) {
        optionsPrice += option.totalPrice;
      }
    }
    return (menuItem.price + optionsPrice) * quantity;
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? '',
      menuItem: MenuItemModel.fromJson(json['menu_item']),
      quantity: json['quantity'] ?? 1,
      selectedOptions: json['selected_options'] != null
          ? (json['selected_options'] as List)
              .map((e) => SelectedOption.fromJson(e))
              .toList()
          : null,
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menu_item': menuItem.toJson(),
      'quantity': quantity,
      'selected_options': selectedOptions?.map((e) => e.toJson()).toList(),
      'note': note,
    };
  }

  CartItemModel copyWith({
    String? id,
    MenuItemModel? menuItem,
    int? quantity,
    List<SelectedOption>? selectedOptions,
    String? note,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      note: note ?? this.note,
    );
  }
}

class SelectedOption {
  final String optionId;
  final String optionName;
  final List<OptionItem> selectedItems;

  SelectedOption({
    required this.optionId,
    required this.optionName,
    required this.selectedItems,
  });

  double get totalPrice {
    return selectedItems.fold(0, (sum, item) => sum + item.price);
  }

  factory SelectedOption.fromJson(Map<String, dynamic> json) {
    return SelectedOption(
      optionId: json['option_id'] ?? '',
      optionName: json['option_name'] ?? '',
      selectedItems: json['selected_items'] != null
          ? (json['selected_items'] as List)
              .map((e) => OptionItem.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'option_id': optionId,
      'option_name': optionName,
      'selected_items': selectedItems.map((e) => e.toJson()).toList(),
    };
  }
}
