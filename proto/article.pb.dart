///
//  Generated code. Do not modify.
//  source: article.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'google/protobuf/timestamp.pb.dart' as $0;

class Article extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Article', package: const $pb.PackageName('cta'), createEmptyInstance: create)
    ..aOM<$0.Timestamp>(1, 'addDate', subBuilder: $0.Timestamp.create)
    ..aOS(2, 'chineseBody')
    ..aOS(3, 'chineseTitle')
    ..aOS(4, 'url')
    ..aOM<$0.Timestamp>(5, 'publishDate', subBuilder: $0.Timestamp.create)
    ..aOS(6, 'author')
    ..a<$core.int>(7, 'wordCount', $pb.PbFieldType.O3)
    ..a<$core.double>(8, 'averageWordDifficulty', $pb.PbFieldType.OD)
    ..pPS(9, 'uniqueWords')
    ..aOM<Stats>(10, 'stats', subBuilder: Stats.create)
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

  @$pb.TagNumber(7)
  $core.int get wordCount => $_getIZ(6);
  @$pb.TagNumber(7)
  set wordCount($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasWordCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearWordCount() => clearField(7);

  @$pb.TagNumber(8)
  $core.double get averageWordDifficulty => $_getN(7);
  @$pb.TagNumber(8)
  set averageWordDifficulty($core.double v) { $_setDouble(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasAverageWordDifficulty() => $_has(7);
  @$pb.TagNumber(8)
  void clearAverageWordDifficulty() => clearField(8);

  @$pb.TagNumber(9)
  $core.List<$core.String> get uniqueWords => $_getList(8);

  @$pb.TagNumber(10)
  Stats get stats => $_getN(9);
  @$pb.TagNumber(10)
  set stats(Stats v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasStats() => $_has(9);
  @$pb.TagNumber(10)
  void clearStats() => clearField(10);
  @$pb.TagNumber(10)
  Stats ensureStats() => $_ensure(9);
}

class Stats extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Stats', package: const $pb.PackageName('cta'), createEmptyInstance: create)
    ..a<$core.int>(1, 'knownWordCount', $pb.PbFieldType.O3)
    ..a<$core.double>(2, 'knownRatio', $pb.PbFieldType.OD)
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
  $core.int get knownWordCount => $_getIZ(0);
  @$pb.TagNumber(1)
  set knownWordCount($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKnownWordCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearKnownWordCount() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get knownRatio => $_getN(1);
  @$pb.TagNumber(2)
  set knownRatio($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasKnownRatio() => $_has(1);
  @$pb.TagNumber(2)
  void clearKnownRatio() => clearField(2);
}

