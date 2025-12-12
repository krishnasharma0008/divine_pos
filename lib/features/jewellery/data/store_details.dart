class StoreDetail {
  final int customerID;
  final String code;
  final String locationType;
  final String? pCustomerCode;
  final String? pjGroup;
  final String? pjActivationDate;
  final String name;
  final String nickName;
  final String address;
  final String country;
  final String state;
  final String city;
  final String pinCode;
  final String? latitude;
  final String? longitude;
  final String creationDate;
  final String? modificationDate;
  final String? contactNo;
  final String? orderEmail;
  final String? stockEmail;
  final String? accountsEmail;

  final int salesPersonId;
  final String salesPerson;
  final String? salesPersonEmail;

  final int zbhId;
  final String zbh;
  final String? zbhEmail;

  final int rbhId;
  final String rbh;
  final String? rbhEmail;

  final int cseId;
  final String cse;
  final String? cseEmail;

  final int beId;
  final String be;
  final String? beEmail;

  final String sor;
  final String? dateOfEstablishment;
  final String kyc;
  final String pjActive;
  final String? companyLogoImage;
  final String? locationLogoImage;
  final String? weeklyOff;
  final String paymentTerms;
  final String? margin;

  final int csaLimit;
  final int assLimit;
  final int exhibitionLimit;
  final int outrightLimit;
  final int totalStock;
  final int storewiseTarget;

  final String? status;

  StoreDetail({
    required this.customerID,
    required this.code,
    required this.locationType,
    this.pCustomerCode,
    this.pjGroup,
    this.pjActivationDate,
    required this.name,
    required this.nickName,
    required this.address,
    required this.country,
    required this.state,
    required this.city,
    required this.pinCode,
    this.latitude,
    this.longitude,
    required this.creationDate,
    this.modificationDate,
    this.contactNo,
    this.orderEmail,
    this.stockEmail,
    this.accountsEmail,
    required this.salesPersonId,
    required this.salesPerson,
    this.salesPersonEmail,
    required this.zbhId,
    required this.zbh,
    this.zbhEmail,
    required this.rbhId,
    required this.rbh,
    this.rbhEmail,
    required this.cseId,
    required this.cse,
    this.cseEmail,
    required this.beId,
    required this.be,
    this.beEmail,
    required this.sor,
    this.dateOfEstablishment,
    required this.kyc,
    required this.pjActive,
    this.companyLogoImage,
    this.locationLogoImage,
    this.weeklyOff,
    required this.paymentTerms,
    this.margin,
    required this.csaLimit,
    required this.assLimit,
    required this.exhibitionLimit,
    required this.outrightLimit,
    required this.totalStock,
    required this.storewiseTarget,
    this.status,
  });

  factory StoreDetail.fromJson(Map<String, dynamic> json) {
    return StoreDetail(
      customerID: json['CustomerID'] ?? 0,
      code: json['Code'] ?? '',
      locationType: json['Location_Type'] ?? '',
      pCustomerCode: json['PCustomerCode'],
      pjGroup: json['PJ_Group'],
      pjActivationDate: json['PJ_Activation_Date'],
      name: json['Name'] ?? '',
      nickName: json['NickName'] ?? '',
      address: json['Address'] ?? '',
      country: json['Country'] ?? '',
      state: json['State'] ?? '',
      city: json['City'] ?? '',
      pinCode: json['PinCode'] ?? '',
      latitude: json['Latitude'],
      longitude: json['Longitude'],
      creationDate: json['CreationDate'] ?? '',
      //creationDate: DateTime.tryParse(json['CreationDate'] ?? '') ?? DateTime.now(),
      modificationDate: json['ModificationDate'],
      contactNo: json['ContactNo'],
      orderEmail: json['OrderEmail'],
      stockEmail: json['StockEmail'],
      accountsEmail: json['AccountsEmail'],
      salesPersonId: json['SalesPerson_ID'] ?? 0,
      salesPerson: json['SalesPerson'] ?? '',
      salesPersonEmail: json['SalesPerson_Email'],
      zbhId: json['ZBH_ID'] ?? 0,
      zbh: json['ZBH'] ?? '',
      zbhEmail: json['ZBH_Email'],
      rbhId: json['RBH_ID'] ?? 0,
      rbh: json['RBH'] ?? '',
      rbhEmail: json['RBH_Email'],
      cseId: json['CSE_ID'] ?? 0,
      cse: json['CSE'] ?? '',
      cseEmail: json['CSE_Email'],
      beId: json['BE_ID'] ?? 0,
      be: json['BE'] ?? '',
      beEmail: json['BE_Email'],
      sor: json['SOR'] ?? '',
      dateOfEstablishment: json['DateOfEstablishment'],
      kyc: json['KYC'] ?? '',
      pjActive: json['PJ_Active'] ?? '',
      companyLogoImage: json['CompanyLogoImage'],
      locationLogoImage: json['LocationLogoImage'],
      weeklyOff: json['WeeklyOff'],
      paymentTerms: json['PaymentTerms'] ?? '',
      margin: json['Margin'],
      csaLimit: json['CSA_Limit'] ?? 0,
      assLimit: json['ASS_Limit'] ?? 0,
      exhibitionLimit: json['Exihibition_Limit'] ?? 0,
      outrightLimit: json['Outright_Limit'] ?? 0,
      totalStock: json['TotalStock'] ?? 0,
      storewiseTarget: json['StorewiseTarget'] ?? 0,
      status: json['Status'],
    );
  }
}
