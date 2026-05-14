import 'package:equatable/equatable.dart';

class SingleTempleteDataModel extends Equatable {
  final bool? success;
  final TemplateData? data;

  const SingleTempleteDataModel({this.success, this.data});

  factory SingleTempleteDataModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return SingleTempleteDataModel(
      success:
          json['success'] == true || rawData != null || json['_id'] != null,
      data: rawData is Map<String, dynamic>
          ? TemplateData.fromJson(rawData)
          : json['_id'] != null
          ? TemplateData.fromJson(json)
          : null,
    );
  }

  @override
  List<Object?> get props => [success, data];
}

class TemplateData extends Equatable {
  final String? id;
  final String? userId;
  final String? name;
  final String? type;

  final TemplateDetails? templateDetails;

  final String? textMessageContent;

  final List<SuggestionModel>? suggestions;

  final String? orientation;
  final String? height;
  final String? width;

  final StandAloneCard? standAlone;

  final List<CarouselCard>? carouselList;

  final List<String>? mediaUrls;

  final String? status;
  final dynamic rmlResponse;

  final String? createdAt;
  final String? updatedAt;

  final int? version;

  const TemplateData({
    this.id,
    this.userId,
    this.name,
    this.type,
    this.templateDetails,
    this.textMessageContent,
    this.suggestions,
    this.orientation,
    this.height,
    this.width,
    this.standAlone,
    this.carouselList,
    this.mediaUrls,
    this.status,
    this.rmlResponse,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory TemplateData.fromJson(Map<String, dynamic> json) {
    return TemplateData(
      id: json['_id'],
      userId: json['userId'],
      name: json['name'],
      type: json['type'],

      templateDetails: json['templateDetails'] != null
          ? TemplateDetails.fromJson(json['templateDetails'])
          : null,

      textMessageContent: json['textMessageContent'],

      suggestions: json['suggestions'] != null
          ? List<SuggestionModel>.from(
              json['suggestions'].map((x) => SuggestionModel.fromJson(x)),
            )
          : [],

      orientation: json['orientation'],
      height: json['height'],
      width: json['width'],

      standAlone: json['standAlone'] != null
          ? StandAloneCard.fromJson(json['standAlone'])
          : null,

      carouselList: json['carouselList'] != null
          ? List<CarouselCard>.from(
              json['carouselList'].map((x) => CarouselCard.fromJson(x)),
            )
          : [],

      mediaUrls: json['mediaUrls'] != null
          ? List<String>.from(json['mediaUrls'])
          : [],

      status: json['status'],
      rmlResponse: json['rmlResponse'],

      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],

      version: json['__v'],
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
    orientation,
    height,
    width,
    standAlone,
    carouselList,
    mediaUrls,
    status,
    rmlResponse,
    createdAt,
    updatedAt,
    version,
  ];
}

class TemplateDetails extends Equatable {
  final List<String>? variables;
  final String? category;

  const TemplateDetails({this.variables, this.category});

  factory TemplateDetails.fromJson(Map<String, dynamic> json) {
    return TemplateDetails(
      variables: json['variables'] != null
          ? List<String>.from(json['variables'])
          : [],
      category: json['category'],
    );
  }

  @override
  List<Object?> get props => [variables, category];
}

class StandAloneCard extends Equatable {
  final String? cardTitle;
  final String? cardDescription;
  final String? fileName;

  final List<SuggestionModel>? suggestions;

  const StandAloneCard({
    this.cardTitle,
    this.cardDescription,
    this.fileName,
    this.suggestions,
  });

  factory StandAloneCard.fromJson(Map<String, dynamic> json) {
    return StandAloneCard(
      cardTitle: json['cardTitle'],
      cardDescription: json['cardDescription'],
      fileName: json['fileName'],

      suggestions: json['suggestions'] != null
          ? List<SuggestionModel>.from(
              json['suggestions'].map((x) => SuggestionModel.fromJson(x)),
            )
          : [],
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

class CarouselCard extends Equatable {
  final String? cardTitle;
  final String? cardDescription;
  final String? fileName;

  final List<SuggestionModel>? suggestions;

  const CarouselCard({
    this.cardTitle,
    this.cardDescription,
    this.fileName,
    this.suggestions,
  });

  factory CarouselCard.fromJson(Map<String, dynamic> json) {
    return CarouselCard(
      cardTitle: json['cardTitle'],
      cardDescription: json['cardDescription'],
      fileName: json['fileName'],

      suggestions: json['suggestions'] != null
          ? List<SuggestionModel>.from(
              json['suggestions'].map((x) => SuggestionModel.fromJson(x)),
            )
          : [],
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
  final String? suggestionType;
  final String? displayText;
  final String? postback;

  final String? phoneNumber;
  final String? url;

  const SuggestionModel({
    this.suggestionType,
    this.displayText,
    this.postback,
    this.phoneNumber,
    this.url,
  });

  factory SuggestionModel.fromJson(Map<String, dynamic> json) {
    return SuggestionModel(
      suggestionType: json['suggestionType'],
      displayText: json['displayText'],
      postback: json['postback'],
      phoneNumber: json['phoneNumber'],
      url: json['url'],
    );
  }

  @override
  List<Object?> get props => [
    suggestionType,
    displayText,
    postback,
    phoneNumber,
    url,
  ];
}
