///
//  Generated code. Do not modify.
//  source: vocab.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Vocabularies extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Vocabularies', package: const $pb.PackageName('cta'), createEmptyInstance: create)
    ..pc<Word>(1, 'knownWords', $pb.PbFieldType.PM, subBuilder: Word.create)
    ..hasRequiredFields = false
  ;

  Vocabularies._() : super();
  factory Vocabularies() => create();
  factory Vocabularies.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Vocabularies.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  Vocabularies clone() => Vocabularies()..mergeFromMessage(this);
  Vocabularies copyWith(void Function(Vocabularies) updates) => super.copyWith((message) => updates(message as Vocabularies));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Vocabularies create() => Vocabularies._();
  Vocabularies createEmptyInstance() => create();
  static $pb.PbList<Vocabularies> createRepeated() => $pb.PbList<Vocabularies>();
  @$core.pragma('dart2js:noInline')
  static Vocabularies getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Vocabularies>(create);
  static Vocabularies _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Word> get knownWords => $_getList(0);
}

class Word extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Word', package: const $pb.PackageName('cta'), createEmptyInstance: create)
    ..aOS(1, 'headWord')
    ..aOS(2, 'pinyin')
    ..pPS(3, 'definition')
    ..hasRequiredFields = false
  ;

  Word._() : super();
  factory Word() => create();
  factory Word.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Word.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  Word clone() => Word()..mergeFromMessage(this);
  Word copyWith(void Function(Word) updates) => super.copyWith((message) => updates(message as Word));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Word create() => Word._();
  Word createEmptyInstance() => create();
  static $pb.PbList<Word> createRepeated() => $pb.PbList<Word>();
  @$core.pragma('dart2js:noInline')
  static Word getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Word>(create);
  static Word _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get headWord => $_getSZ(0);
  @$pb.TagNumber(1)
  set headWord($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHeadWord() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeadWord() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get pinyin => $_getSZ(1);
  @$pb.TagNumber(2)
  set pinyin($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPinyin() => $_has(1);
  @$pb.TagNumber(2)
  void clearPinyin() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.String> get definition => $_getList(2);
}

