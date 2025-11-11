class ServiceResponseModel {
  final bool success;
  final int totalServices;
  final List<ServiceModel> services;

  ServiceResponseModel({
    required this.success,
    required this.totalServices,
    required this.services,
  });

  factory ServiceResponseModel.fromJson(Map<String, dynamic> json) {
    return ServiceResponseModel(
      success: json['success'] ?? false,
      totalServices: json['totalServices'] ?? 0,
      services:
          (json['services'] as List<dynamic>?)
              ?.map((service) => ServiceModel.fromJson(service))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'totalServices': totalServices,
      'services': services.map((service) => service.toJson()).toList(),
    };
  }
}

class ServiceModel {
  final String id;
  final String serviceId;
  final String name;
  final String description;
  final double vat;
  final double priceInclVat;
  final double priceExclVat;
  final double partCostExclVat;
  final double partCostInclVat;
  final int serviceTimeInMinutes;
  final double laborRate;
  final double profitMarkup;
  final String priceType;
  final bool enableDeviceDetails;
  final bool labourCalculator;
  final bool enableServiceDetails;
  final bool enableSearchInExpress;
  final String location;
  final String userId;
  final String brandId;
  final String category;
  final String manufacturer;
  final String model;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final List<ServiceImage> images;
  final List<AssignedItem> assignedItems;
  final List<String> assignedItemIds;

  ServiceModel({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.description,
    required this.vat,
    required this.priceInclVat,
    required this.priceExclVat,
    required this.partCostExclVat,
    required this.partCostInclVat,
    required this.serviceTimeInMinutes,
    required this.laborRate,
    required this.profitMarkup,
    required this.priceType,
    required this.enableDeviceDetails,
    required this.labourCalculator,
    required this.enableServiceDetails,
    required this.enableSearchInExpress,
    required this.location,
    required this.userId,
    required this.brandId,
    required this.category,
    required this.manufacturer,
    required this.model,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
    required this.images,
    required this.assignedItems,
    required this.assignedItemIds,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'] ?? json['id'] ?? '',
      serviceId: json['serviceId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      vat: (json['vat'] as num?)?.toDouble() ?? 0.0,
      priceInclVat: (json['price_incl_vat'] as num?)?.toDouble() ?? 0.0,
      priceExclVat: (json['price_excl_vat'] as num?)?.toDouble() ?? 0.0,
      partCostExclVat: (json['part_cost_excl_vat'] as num?)?.toDouble() ?? 0.0,
      partCostInclVat: (json['part_cost_incl_vat'] as num?)?.toDouble() ?? 0.0,
      serviceTimeInMinutes: json['service_time_in_minutes'] ?? 0,
      laborRate: (json['labor_rate'] as num?)?.toDouble() ?? 0.0,
      profitMarkup: (json['profitMarkup'] as num?)?.toDouble() ?? 0.0,
      priceType: json['price_type'] ?? '',
      enableDeviceDetails: json['enable_device_details'] ?? false,
      labourCalculator: json['labour_calculator'] ?? false,
      enableServiceDetails: json['enable_service_details'] ?? false,
      enableSearchInExpress: json['enable_search_in_express'] ?? false,
      location: json['location'] ?? '',
      userId: json['userId'] ?? '',
      brandId: json['brandId'] ?? '',
      category: json['category'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      model: json['model'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      images:
          (json['images'] as List<dynamic>?)
              ?.map((image) => ServiceImage.fromJson(image))
              .toList() ??
          [],
      assignedItems:
          (json['assignedItems'] as List<dynamic>?)
              ?.map((item) => AssignedItem.fromJson(item))
              .toList() ??
          [],
      assignedItemIds:
          (json['assignedItemIds'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'serviceId': serviceId,
      'name': name,
      'description': description,
      'vat': vat,
      'price_incl_vat': priceInclVat,
      'price_excl_vat': priceExclVat,
      'part_cost_excl_vat': partCostExclVat,
      'part_cost_incl_vat': partCostInclVat,
      'service_time_in_minutes': serviceTimeInMinutes,
      'labor_rate': laborRate,
      'profitMarkup': profitMarkup,
      'price_type': priceType,
      'enable_device_details': enableDeviceDetails,
      'labour_calculator': labourCalculator,
      'enable_service_details': enableServiceDetails,
      'enable_search_in_express': enableSearchInExpress,
      'location': location,
      'userId': userId,
      'brandId': brandId,
      'category': category,
      'manufacturer': manufacturer,
      'model': model,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'images': images.map((image) => image.toJson()).toList(),
      'assignedItems': assignedItems.map((item) => item.toJson()).toList(),
      'assignedItemIds': assignedItemIds,
    };
  }
}

class ServiceImage {
  final bool favorite;
  final String path;
  final String id;

  ServiceImage({required this.favorite, required this.path, required this.id});

  factory ServiceImage.fromJson(Map<String, dynamic> json) {
    return ServiceImage(
      favorite: json['favorite'] ?? false,
      path: json['path'] ?? '',
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'favorite': favorite, 'path': path, 'id': id};
  }
}

class AssignedItem {
  final String id;
  final String productName;
  final dynamic itemNumber;
  final int stockValue;
  final String stockUnit;
  final String manufacturer;
  final String category;
  final String condition;
  final double vatPercent;
  final double profitMarkup;
  final String profitMarkupSymbol;
  final String description;
  final double purchasePriceExlVat;
  final double purchasePriceIncVat;
  final double salePriceExlVat;
  final double salePriceIncVat;
  final bool serialNoManagement;
  final bool pricingCalculator;
  final String location;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ItemImage> images;
  final List<dynamic> transactions;
  final List<StockSetting> stockSetting;

  AssignedItem({
    required this.id,
    required this.productName,
    required this.itemNumber,
    required this.stockValue,
    required this.stockUnit,
    required this.manufacturer,
    required this.category,
    required this.condition,
    required this.vatPercent,
    required this.profitMarkup,
    required this.profitMarkupSymbol,
    required this.description,
    required this.purchasePriceExlVat,
    required this.purchasePriceIncVat,
    required this.salePriceExlVat,
    required this.salePriceIncVat,
    required this.serialNoManagement,
    required this.pricingCalculator,
    required this.location,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
    required this.transactions,
    required this.stockSetting,
  });

  factory AssignedItem.fromJson(Map<String, dynamic> json) {
    return AssignedItem(
      id: json['_id'] ?? json['id'] ?? '',
      productName: json['productName'] ?? '',
      itemNumber: json['itemNumber'] ?? '',
      stockValue: json['stockValue'] ?? 0,
      stockUnit: json['stockUnit'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      category: json['category'] ?? '',
      condition: json['condition'] ?? '',
      vatPercent: (json['vatPercent'] as num?)?.toDouble() ?? 0.0,
      profitMarkup: (json['profitMarkup'] as num?)?.toDouble() ?? 0.0,
      profitMarkupSymbol: json['profitMarkupSymbol'] ?? '',
      description: json['description'] ?? '',
      purchasePriceExlVat:
          (json['purchasePriceExlVat'] as num?)?.toDouble() ?? 0.0,
      purchasePriceIncVat:
          (json['purchasePriceIncVat'] as num?)?.toDouble() ?? 0.0,
      salePriceExlVat: (json['salePriceExlVat'] as num?)?.toDouble() ?? 0.0,
      salePriceIncVat: (json['salePriceIncVat'] as num?)?.toDouble() ?? 0.0,
      serialNoManagement: json['serialNoManagement'] ?? false,
      pricingCalculator: json['pricingCalculator'] ?? false,
      location: json['location'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((image) => ItemImage.fromJson(image))
              .toList() ??
          [],
      transactions: json['transactions'] ?? [],
      stockSetting:
          (json['stockSetting'] as List<dynamic>?)
              ?.map((setting) => StockSetting.fromJson(setting))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productName': productName,
      'itemNumber': itemNumber,
      'stockValue': stockValue,
      'stockUnit': stockUnit,
      'manufacturer': manufacturer,
      'category': category,
      'condition': condition,
      'vatPercent': vatPercent,
      'profitMarkup': profitMarkup,
      'profitMarkupSymbol': profitMarkupSymbol,
      'description': description,
      'purchasePriceExlVat': purchasePriceExlVat,
      'purchasePriceIncVat': purchasePriceIncVat,
      'salePriceExlVat': salePriceExlVat,
      'salePriceIncVat': salePriceIncVat,
      'serialNoManagement': serialNoManagement,
      'pricingCalculator': pricingCalculator,
      'location': location,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'images': images.map((image) => image.toJson()).toList(),
      'transactions': transactions,
      'stockSetting': stockSetting.map((setting) => setting.toJson()).toList(),
    };
  }
}

class ItemImage {
  final String id;
  final bool favorite;
  final String path;
  final String itemId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String url;

  ItemImage({
    required this.id,
    required this.favorite,
    required this.path,
    required this.itemId,
    required this.createdAt,
    required this.updatedAt,
    required this.url,
  });

  factory ItemImage.fromJson(Map<String, dynamic> json) {
    return ItemImage(
      id: json['_id'] ?? '',
      favorite: json['favorite'] ?? false,
      path: json['path'] ?? '',
      itemId: json['itemId'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'favorite': favorite,
      'path': path,
      'itemId': itemId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'url': url,
    };
  }
}

class StockSetting {
  final String id;
  final bool enableStockManagement;
  final List<dynamic> alertRecipients;
  final String itemId;

  StockSetting({
    required this.id,
    required this.enableStockManagement,
    required this.alertRecipients,
    required this.itemId,
  });

  factory StockSetting.fromJson(Map<String, dynamic> json) {
    return StockSetting(
      id: json['_id'] ?? '',
      enableStockManagement: json['enableStockManagement'] ?? false,
      alertRecipients: json['alertRecipients'] ?? [],
      itemId: json['itemId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'enableStockManagement': enableStockManagement,
      'alertRecipients': alertRecipients,
      'itemId': itemId,
    };
  }
}
