import 'package:equatable/equatable.dart';

class ManageTemplateModel extends Equatable {
  final bool success;
  final int total;
  final int page;
  final List<TemplateData> data;

  const ManageTemplateModel({
    required this.success,
    required this.total,
    required this.page,
    required this.data,
  });

  factory ManageTemplateModel.fromJson(Map<String, dynamic> json) {
    return ManageTemplateModel(
      success: json['success'] ?? false,
      total: json['total'] ?? 0,
      page: json['page'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => TemplateData.fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [success, total, page, data];
}

class TemplateData extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String type;
  final TemplateDetails? templateDetails;
  final String textMessageContent;
  final List<SuggestionModel> suggestions;
  final String height;
  final String width;
  final List<CarouselCard> carouselList;
  final List<String> mediaUrls;
  final String status;
  final dynamic rmlResponse;
  final String createdAt;
  final String updatedAt;
  final int version;
  final String orientation;
  final CarouselCard? standAlone;

  const TemplateData({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.templateDetails,
    required this.textMessageContent,
    required this.suggestions,
    required this.height,
    required this.width,
    required this.carouselList,
    required this.mediaUrls,
    required this.status,
    this.rmlResponse,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.orientation,
    this.standAlone,
  });

  factory TemplateData.fromJson(Map<String, dynamic> json) {
    return TemplateData(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      templateDetails: json['templateDetails'] != null
          ? TemplateDetails.fromJson(json['templateDetails'])
          : null,
      textMessageContent: json['textMessageContent'] ?? '',
      suggestions:
          (json['suggestions'] as List<dynamic>?)
              ?.map((e) => SuggestionModel.fromJson(e))
              .toList() ??
          [],
      height: json['height'] ?? '',
      width: json['width'] ?? '',
      carouselList:
          (json['carouselList'] as List<dynamic>?)
              ?.map((e) => CarouselCard.fromJson(e))
              .toList() ??
          [],
      mediaUrls:
          (json['mediaUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: json['status'] ?? '',
      rmlResponse: json['rmlResponse'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      version: json['__v'] ?? 0,
      orientation: json['orientation'] ?? '',
      standAlone: json['standAlone'] != null
          ? CarouselCard.fromJson(json['standAlone'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    type,
    templateDetails,
    textMessageContent,
    suggestions,
    height,
    width,
    carouselList,
    mediaUrls,
    status,
    rmlResponse,
    createdAt,
    updatedAt,
    version,
    orientation,
    standAlone,
  ];
}

class TemplateDetails extends Equatable {
  final List<String> variables;
  final String category;

  const TemplateDetails({required this.variables, required this.category});

  factory TemplateDetails.fromJson(Map<String, dynamic> json) {
    return TemplateDetails(
      variables:
          (json['variables'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      category: json['category'] ?? '',
    );
  }

  @override
  List<Object?> get props => [variables, category];
}

class CarouselCard extends Equatable {
  final String cardTitle;
  final String cardDescription;
  final String fileName;
  final List<SuggestionModel> suggestions;

  const CarouselCard({
    required this.cardTitle,
    required this.cardDescription,
    required this.fileName,
    required this.suggestions,
  });

  factory CarouselCard.fromJson(Map<String, dynamic> json) {
    return CarouselCard(
      cardTitle: json['cardTitle'] ?? '',
      cardDescription: json['cardDescription'] ?? '',
      fileName: json['fileName'] ?? '',
      suggestions:
          (json['suggestions'] as List<dynamic>?)
              ?.map((e) => SuggestionModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
    cardTitle,
    cardDescription,
    fileName,
    suggestions,
  ];
}

class SuggestionModel extends Equatable {
  final String suggestionType;
  final String displayText;
  final String postback;
  final String url;
  final String phoneNumber;

  const SuggestionModel({
    required this.suggestionType,
    required this.displayText,
    required this.postback,
    required this.url,
    required this.phoneNumber,
  });

  factory SuggestionModel.fromJson(Map<String, dynamic> json) {
    return SuggestionModel(
      suggestionType: json['suggestionType'] ?? '',
      displayText: json['displayText'] ?? '',
      postback: json['postback'] ?? '',
      url: json['url'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
    suggestionType,
    displayText,
    postback,
    url,
    phoneNumber,
  ];
}
