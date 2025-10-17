class JobItemsModel {
  List<Item>? items;
  int? totalItems;
  int? pages;

  JobItemsModel({this.items, this.totalItems, this.pages});

  JobItemsModel.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Item>[];
      json['items'].forEach((v) {
        items!.add(Item.fromJson(v));
      });
    }
    totalItems = json['totalItems'];
    pages = json['pages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['totalItems'] = totalItems;
    data['pages'] = pages;
    return data;
  }
}

class Item {
  String? sId;
  String? productName;
  String? itemNumber;
  int? stockValue;
  String? stockUnit;
  String? manufacturer;
  String? category;
  String? manufacturerNumber;
  String? color;
  String? condition;
  dynamic vatPercent;
  dynamic profitMarkup;
  String? profitMarkupSymbol;
  String? description;
  dynamic purchasePriceExlVat;
  dynamic purchasePriceIncVat;
  dynamic salePriceExlVat;
  dynamic salePriceIncVat;
  List<Barcode>? barcode;
  List<SupplierList>? supplierList;
  bool? serialNoManagement;
  bool? pricingCalculator;
  String? location;
  String? userId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  List<StockSetting>? stockSetting;

  Item({
    this.sId,
    this.productName,
    this.itemNumber,
    this.stockValue,
    this.stockUnit,
    this.manufacturer,
    this.category,
    this.manufacturerNumber,
    this.color,
    this.condition,
    this.vatPercent,
    this.profitMarkup,
    this.profitMarkupSymbol,
    this.description,
    this.purchasePriceExlVat,
    this.purchasePriceIncVat,
    this.salePriceExlVat,
    this.salePriceIncVat,
    this.barcode,
    this.supplierList,
    this.serialNoManagement,
    this.pricingCalculator,
    this.location,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.stockSetting,
  });

  Item.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    productName = json['productName'];
    itemNumber = json['itemNumber'];
    stockValue = json['stockValue'];
    stockUnit = json['stockUnit'];
    manufacturer = json['manufacturer'];
    category = json['category'];
    manufacturerNumber = json['manufacturerNumber'];
    color = json['color'];
    condition = json['condition'];
    vatPercent = json['vatPercent'];
    profitMarkup = json['profitMarkup'];
    profitMarkupSymbol = json['profitMarkupSymbol'];
    description = json['description'];
    purchasePriceExlVat = json['purchasePriceExlVat'];
    purchasePriceIncVat = json['purchasePriceIncVat'];
    salePriceExlVat = json['salePriceExlVat'];
    salePriceIncVat = json['salePriceIncVat'];
    if (json['barcode'] != null) {
      barcode = <Barcode>[];
      json['barcode'].forEach((v) {
        barcode!.add(Barcode.fromJson(v));
      });
    }

    if (json['supplierList'] != null) {
      supplierList = <SupplierList>[];
      json['supplierList'].forEach((v) {
        supplierList!.add(SupplierList.fromJson(v));
      });
    }
    serialNoManagement = json['serialNoManagement'];
    pricingCalculator = json['pricingCalculator'];
    location = json['location'];
    userId = json['userId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];

    if (json['stockSetting'] != null) {
      stockSetting = <StockSetting>[];
      json['stockSetting'].forEach((v) {
        stockSetting!.add(StockSetting.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['productName'] = productName;
    data['itemNumber'] = itemNumber;
    data['stockValue'] = stockValue;
    data['stockUnit'] = stockUnit;
    data['manufacturer'] = manufacturer;
    data['category'] = category;
    data['manufacturerNumber'] = manufacturerNumber;
    data['color'] = color;
    data['condition'] = condition;
    data['vatPercent'] = vatPercent;
    data['profitMarkup'] = profitMarkup;
    data['profitMarkupSymbol'] = profitMarkupSymbol;
    data['description'] = description;
    data['purchasePriceExlVat'] = purchasePriceExlVat;
    data['purchasePriceIncVat'] = purchasePriceIncVat;
    data['salePriceExlVat'] = salePriceExlVat;
    data['salePriceIncVat'] = salePriceIncVat;
    if (barcode != null) {
      data['barcode'] = barcode!.map((v) => v.toJson()).toList();
    }

    if (supplierList != null) {
      data['supplierList'] = supplierList!.map((v) => v.toJson()).toList();
    }
    data['serialNoManagement'] = serialNoManagement;
    data['pricingCalculator'] = pricingCalculator;
    data['location'] = location;
    data['userId'] = userId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    if (stockSetting != null) {
      data['stockSetting'] = stockSetting!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Barcode {
  String? id;
  String? barcode;

  Barcode({this.id, this.barcode});

  Barcode.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    barcode = json['barcode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['barcode'] = barcode;
    return data;
  }
}

class SupplierList {
  String? fullName;
  String? id;
  String? supplierName;
  int? salePriceExlVat;
  double? salePriceIncVat;
  int? purchasePriceExlVat;
  double? purchasePriceIncVat;
  String? profitMarkupSymbol;
  int? profitMarkup;
  int? vatPercent;
  bool? primary;

  SupplierList({
    this.fullName,
    this.id,
    this.supplierName,
    this.salePriceExlVat,
    this.salePriceIncVat,
    this.purchasePriceExlVat,
    this.purchasePriceIncVat,
    this.profitMarkupSymbol,
    this.profitMarkup,
    this.vatPercent,
    this.primary,
  });

  SupplierList.fromJson(Map<String, dynamic> json) {
    fullName = json['fullName'];
    id = json['id'];
    supplierName = json['supplierName'];
    salePriceExlVat = json['salePriceExlVat'];
    salePriceIncVat = json['salePriceIncVat'];
    purchasePriceExlVat = json['purchasePriceExlVat'];
    purchasePriceIncVat = json['purchasePriceIncVat'];
    profitMarkupSymbol = json['profitMarkupSymbol'];
    profitMarkup = json['profitMarkup'];
    vatPercent = json['vatPercent'];
    primary = json['primary'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fullName'] = fullName;
    data['id'] = id;
    data['supplierName'] = supplierName;
    data['salePriceExlVat'] = salePriceExlVat;
    data['salePriceIncVat'] = salePriceIncVat;
    data['purchasePriceExlVat'] = purchasePriceExlVat;
    data['purchasePriceIncVat'] = purchasePriceIncVat;
    data['profitMarkupSymbol'] = profitMarkupSymbol;
    data['profitMarkup'] = profitMarkup;
    data['vatPercent'] = vatPercent;
    data['primary'] = primary;
    return data;
  }
}

class StockSetting {
  String? sId;

  String? itemId;
  int? iV;

  StockSetting({this.sId, this.itemId, this.iV});

  StockSetting.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];

    itemId = json['itemId'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['itemId'] = itemId;
    data['__v'] = iV;
    return data;
  }
}
