// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tile_data.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTileDataCollection on Isar {
  IsarCollection<TileData> get tileDatas => this.collection();
}

const TileDataSchema = CollectionSchema(
  name: r'TileData',
  id: -6697509844783765344,
  properties: {
    r'baseImagePath': PropertySchema(
      id: 0,
      name: r'baseImagePath',
      type: IsarType.string,
    ),
    r'itemImagePath': PropertySchema(
      id: 1,
      name: r'itemImagePath',
      type: IsarType.string,
    ),
    r'overlayNumber': PropertySchema(
      id: 2,
      name: r'overlayNumber',
      type: IsarType.long,
    )
  },
  estimateSize: _tileDataEstimateSize,
  serialize: _tileDataSerialize,
  deserialize: _tileDataDeserialize,
  deserializeProp: _tileDataDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _tileDataGetId,
  getLinks: _tileDataGetLinks,
  attach: _tileDataAttach,
  version: '3.1.0+1',
);

int _tileDataEstimateSize(
  TileData object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.baseImagePath.length * 3;
  {
    final value = object.itemImagePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _tileDataSerialize(
  TileData object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.baseImagePath);
  writer.writeString(offsets[1], object.itemImagePath);
  writer.writeLong(offsets[2], object.overlayNumber);
}

TileData _tileDataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TileData(
    baseImagePath: reader.readString(offsets[0]),
    itemImagePath: reader.readStringOrNull(offsets[1]),
    overlayNumber: reader.readLongOrNull(offsets[2]) ?? 0,
  );
  object.id = id;
  return object;
}

P _tileDataDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _tileDataGetId(TileData object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _tileDataGetLinks(TileData object) {
  return [];
}

void _tileDataAttach(IsarCollection<dynamic> col, Id id, TileData object) {
  object.id = id;
}

extension TileDataQueryWhereSort on QueryBuilder<TileData, TileData, QWhere> {
  QueryBuilder<TileData, TileData, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TileDataQueryWhere on QueryBuilder<TileData, TileData, QWhereClause> {
  QueryBuilder<TileData, TileData, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TileData, TileData, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TileData, TileData, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TileData, TileData, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TileDataQueryFilter
    on QueryBuilder<TileData, TileData, QFilterCondition> {
  QueryBuilder<TileData, TileData, QAfterFilterCondition> baseImagePathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      baseImagePathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'baseImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> baseImagePathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'baseImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> baseImagePathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'baseImagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      baseImagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'baseImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> baseImagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'baseImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> baseImagePathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'baseImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> baseImagePathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'baseImagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      baseImagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'baseImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      baseImagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'baseImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      itemImagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'itemImagePath',
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      itemImagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'itemImagePath',
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> itemImagePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      itemImagePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> itemImagePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> itemImagePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemImagePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      itemImagePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'itemImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> itemImagePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'itemImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> itemImagePathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'itemImagePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> itemImagePathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'itemImagePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      itemImagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      itemImagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'itemImagePath',
        value: '',
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> overlayNumberEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'overlayNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      overlayNumberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'overlayNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> overlayNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'overlayNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> overlayNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'overlayNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TileDataQueryObject
    on QueryBuilder<TileData, TileData, QFilterCondition> {}

extension TileDataQueryLinks
    on QueryBuilder<TileData, TileData, QFilterCondition> {}

extension TileDataQuerySortBy on QueryBuilder<TileData, TileData, QSortBy> {
  QueryBuilder<TileData, TileData, QAfterSortBy> sortByBaseImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseImagePath', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByBaseImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseImagePath', Sort.desc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByItemImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemImagePath', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByItemImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemImagePath', Sort.desc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByOverlayNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overlayNumber', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByOverlayNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overlayNumber', Sort.desc);
    });
  }
}

extension TileDataQuerySortThenBy
    on QueryBuilder<TileData, TileData, QSortThenBy> {
  QueryBuilder<TileData, TileData, QAfterSortBy> thenByBaseImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseImagePath', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByBaseImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'baseImagePath', Sort.desc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByItemImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemImagePath', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByItemImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemImagePath', Sort.desc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByOverlayNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overlayNumber', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByOverlayNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'overlayNumber', Sort.desc);
    });
  }
}

extension TileDataQueryWhereDistinct
    on QueryBuilder<TileData, TileData, QDistinct> {
  QueryBuilder<TileData, TileData, QDistinct> distinctByBaseImagePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'baseImagePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TileData, TileData, QDistinct> distinctByItemImagePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemImagePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TileData, TileData, QDistinct> distinctByOverlayNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'overlayNumber');
    });
  }
}

extension TileDataQueryProperty
    on QueryBuilder<TileData, TileData, QQueryProperty> {
  QueryBuilder<TileData, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TileData, String, QQueryOperations> baseImagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'baseImagePath');
    });
  }

  QueryBuilder<TileData, String?, QQueryOperations> itemImagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemImagePath');
    });
  }

  QueryBuilder<TileData, int, QQueryOperations> overlayNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'overlayNumber');
    });
  }
}
