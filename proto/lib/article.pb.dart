///
//  Generated code. Do not modify.
//  source: article.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'google/protobuf/timestamp.pb.dart' as $0;

class Articles extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Articles', package: const $pb.PackageName('cta'), createEmptyInstance: create)
    ..pc<Article>(1, 'articles', $pb.PbFieldType.PM, subBuilder: Article.create)
    ..hasRequiredFields = false
  ;

  Articles._() : super();
  factory Articles() => create();
  factory Articles.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Articles.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  Articles clone() => Articles()..mergeFromMessage(this);
  Articles copyWith(void Function(Articles) updates) => super.copyWith((message) => updates(message as Articles));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Articles create() => Articles._();
  Articles createEmptyInstance() => create();
  static $pb.PbList<Articles> createRepeated() => $pb.PbList<Articles>();
  @$core.pragma('dart2js:noInline')
  static Articles getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Articles>(create);
  static Articles _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Article> get articles => $_getList(0);
}

class Article extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Article', package: const $pb.PackageName('cta'), createEmptyInstance: create)
    ..aOM<$0.Timestamp>(1, 'addDate', subBuilder: $0.Timestamp.create)
    ..aOS(2, 'chineseBody')
    ..aOS(3, 'chineseTitle')
    ..aOS(4, 'url')
    ..aOM<$0.Timestamp>(5, 'publishDate', subBuilder: $0.Timestamp.create)
    ..aOS(6, 'author')
    ..pPS(9, 'segmentation')
    ..aOM<Stats>(10, 'stats', subBuilder: Stats.create)
    ..aOB(11, 'favorite')
    ..pPS(12, 'tags')
    ..a<$core.int>(13, 'chapterNum', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  Article._() : super();
  factory Article() => create();
  factory Article.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Article.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  Article clone() => Article()..mergeFromMessage(this);
  Article copyWith(void Function(Article) updates) => super.copyWith((message) => updates(message as Article));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Article create() => Article._();
  Article createEmptyInstance() => create();
  static $pb.PbList<Article> createRepeated() => $pb.PbList<Article>();
  @$core.pragma('dart2js:noInline')
  static Article getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Article>(create);
  static Article _defaultInstance;

  @$pb.TagNumber(1)
  $0.Timestamp get addDate => $_getN(0);
  @$pb.TagNumber(1)
  set addDate($0.Timestamp v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddDate() => clearField(1);
  @$pb.TagNumber(1)
  $0.Timestamp ensureAddDate() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get chineseBody => $_getSZ(1);
  @$pb.TagNumber(2)
  set chineseBody($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasChineseBody() => $_has(1);
  @$pb.TagNumber(2)
  void clearChineseBody() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get chineseTitle => $_getSZ(2);
  @$pb.TagNumber(3)
  set chineseTitle($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasChineseTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearChineseTitle() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get url => $_getSZ(3);
  @$pb.TagNumber(4)
  set url($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearUrl() => clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get publishDate => $_getN(4);
  @$pb.TagNumber(5)
  set publishDate($0.Timestamp v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasPublishDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearPublishDate() => clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensurePublishDate() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get author => $_getSZ(5);
  @$pb.TagNumber(6)
  set author($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasAuthor() => $_has(5);
  @$pb.TagNumber(6)
  void clearAuthor() => clearField(6);

  @$pb.TagNumber(9)
  $core.List<$core.String> get segmentation => $_getList(6);

  @$pb.TagNumber(10)
  Stats get stats => $_getN(7);
  @$pb.TagNumber(10)
  set stats(Stats v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasStats() => $_has(7);
  @$pb.TagNumber(10)
  void clearStats() => clearField(10);
  @$pb.TagNumber(10)
  Stats ensureStats() => $_ensure(7);

  @$pb.TagNumber(11)
  $core.bool get favorite => $_getBF(8);
  @$pb.TagNumber(11)
  set favorite($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(11)
  $core.bool hasFavorite() => $_has(8);
  @$pb.TagNumber(11)
  void clearFavorite() => clearField(11);

  @$pb.TagNumber(12)
  $core.List<$core.String> get tags => $_getList(9);

  @$pb.TagNumber(13)
  $core.int get chapterNum => $_getIZ(10);
  @$pb.TagNumber(13)
  set chapterNum($core.int v) { $_setSignedInt32(10, v); }
  @$pb.TagNumber(13)
  $core.bool hasChapterNum() => $_has(10);
  @$pb.TagNumber(13)
  void clearChapterNum() => clearField(13);
}

class Stats extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Stats', package: const $pb.PackageName('cta'), createEmptyInstance: create)
    ..a<$core.int>(1, 'wordCount', $pb.PbFieldType.O3)
    ..a<$core.double>(2, 'averageWordDifficulty', $pb.PbFieldType.OD)
    ..a<$core.double>(3, 'meanSquareDifficulty', $pb.PbFieldType.OD)
    ..a<$core.double>(4, 'uniqueKnownRatio', $pb.PbFieldType.OD)
    ..a<$core.double>(5, 'knownRatio', $pb.PbFieldType.OD)
    ..a<$core.int>(6, 'knownWordCount', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  Stats._() : super();
  factory Stats() => create();
  factory Stats.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Stats.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  Stats clone() => Stats()..mergeFromMessage(this);
  Stats copyWith(void Function(Stats) updates) => super.copyWith((message) => updates(message as Stats));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Stats create() => Stats._();
  Stats createEmptyInstance() => create();
  static $pb.PbList<Stats> createRepeated() => $pb.PbList<Stats>();
  @$core.pragma('dart2js:noInline')
  static Stats getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Stats>(create);
  static Stats _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get wordCount => $_getIZ(0);
  @$pb.TagNumber(1)
  set wordCount($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWordCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearWordCount() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get averageWordDifficulty => $_getN(1);
  @$pb.TagNumber(2)
  set averageWordDifficulty($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAverageWordDifficulty() => $_has(1);
  @$pb.TagNumber(2)
  void clearAverageWordDifficulty() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get meanSquareDifficulty => $_getN(2);
  @$pb.TagNumber(3)
  set meanSquareDifficulty($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMeanSquareDifficulty() => $_has(2);
  @$pb.TagNumber(3)
  void clearMeanSquareDifficulty() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get uniqueKnownRatio => $_getN(3);
  @$pb.TagNumber(4)
  set uniqueKnownRatio($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasUniqueKnownRatio() => $_has(3);
  @$pb.TagNumber(4)
  void clearUniqueKnownRatio() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get knownRatio => $_getN(4);
  @$pb.TagNumber(5)
  set knownRatio($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasKnownRatio() => $_has(4);
  @$pb.TagNumber(5)
  void clearKnownRatio() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get knownWordCount => $_getIZ(5);
  @$pb.TagNumber(6)
  set knownWordCount($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasKnownWordCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearKnownWordCount() => clearField(6);
}

