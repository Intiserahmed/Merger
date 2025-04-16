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
    r'col': PropertySchema(
      id: 1,
      name: r'col',
      type: IsarType.long,
    ),
    r'cooldownSeconds': PropertySchema(
      id: 2,
      name: r'cooldownSeconds',
      type: IsarType.long,
    ),
    r'energyCost': PropertySchema(
      id: 3,
      name: r'energyCost',
      type: IsarType.long,
    ),
    r'generatesItemPath': PropertySchema(
      id: 4,
      name: r'generatesItemPath',
      type: IsarType.string,
    ),
    r'isEmpty': PropertySchema(
      id: 5,
      name: r'isEmpty',
      type: IsarType.bool,
    ),
    r'isGenerator': PropertySchema(
      id: 6,
      name: r'isGenerator',
      type: IsarType.bool,
    ),
    r'isItem': PropertySchema(
      id: 7,
      name: r'isItem',
      type: IsarType.bool,
    ),
    r'isLocked': PropertySchema(
      id: 8,
      name: r'isLocked',
      type: IsarType.bool,
    ),
    r'itemImagePath': PropertySchema(
      id: 9,
      name: r'itemImagePath',
      type: IsarType.string,
    ),
    r'lastUsedTimestamp': PropertySchema(
      id: 10,
      name: r'lastUsedTimestamp',
      type: IsarType.dateTime,
    ),
    r'overlayNumber': PropertySchema(
      id: 11,
      name: r'overlayNumber',
      type: IsarType.long,
    ),
    r'row': PropertySchema(
      id: 12,
      name: r'row',
      type: IsarType.long,
    ),
    r'type': PropertySchema(
      id: 13,
      name: r'type',
      type: IsarType.byte,
      enumMap: _TileDatatypeEnumValueMap,
    )
  },
  estimateSize: _tileDataEstimateSize,
  serialize: _tileDataSerialize,
  deserialize: _tileDataDeserialize,
  deserializeProp: _tileDataDeserializeProp,
  idName: r'id',
  indexes: {
    r'row': IndexSchema(
      id: -2734084670436536211,
      name: r'row',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'row',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'col': IndexSchema(
      id: 2387585023331177592,
      name: r'col',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'col',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
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
    final value = object.generatesItemPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
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
  writer.writeLong(offsets[1], object.col);
  writer.writeLong(offsets[2], object.cooldownSeconds);
  writer.writeLong(offsets[3], object.energyCost);
  writer.writeString(offsets[4], object.generatesItemPath);
  writer.writeBool(offsets[5], object.isEmpty);
  writer.writeBool(offsets[6], object.isGenerator);
  writer.writeBool(offsets[7], object.isItem);
  writer.writeBool(offsets[8], object.isLocked);
  writer.writeString(offsets[9], object.itemImagePath);
  writer.writeDateTime(offsets[10], object.lastUsedTimestamp);
  writer.writeLong(offsets[11], object.overlayNumber);
  writer.writeLong(offsets[12], object.row);
  writer.writeByte(offsets[13], object.type.index);
}

TileData _tileDataDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TileData(
    baseImagePath: reader.readString(offsets[0]),
    col: reader.readLong(offsets[1]),
    cooldownSeconds: reader.readLongOrNull(offsets[2]) ?? 0,
    energyCost: reader.readLongOrNull(offsets[3]) ?? 0,
    generatesItemPath: reader.readStringOrNull(offsets[4]),
    id: id,
    itemImagePath: reader.readStringOrNull(offsets[9]),
    lastUsedTimestamp: reader.readDateTimeOrNull(offsets[10]),
    overlayNumber: reader.readLongOrNull(offsets[11]) ?? 0,
    row: reader.readLong(offsets[12]),
    type: _TileDatatypeValueEnumMap[reader.readByteOrNull(offsets[13])] ??
        TileType.empty,
  );
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
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (_TileDatatypeValueEnumMap[reader.readByteOrNull(offset)] ??
          TileType.empty) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _TileDatatypeEnumValueMap = {
  'empty': 0,
  'item': 1,
  'generator': 2,
  'locked': 3,
};
const _TileDatatypeValueEnumMap = {
  0: TileType.empty,
  1: TileType.item,
  2: TileType.generator,
  3: TileType.locked,
};

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

  QueryBuilder<TileData, TileData, QAfterWhere> anyRow() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'row'),
      );
    });
  }

  QueryBuilder<TileData, TileData, QAfterWhere> anyCol() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'col'),
      );
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

  QueryBuilder<TileData, TileData, QAfterWhereClause> rowEqualTo(int row) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'row',
        value: [row],
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterWhereClause> rowNotEqualTo(int row) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'row',
              lower: [],
              upper: [row],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'row',
              lower: [row],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'row',
              lower: [row],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'row',
              lower: [],
              upper: [row],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TileData, TileData, QAfterWhereClause> rowGreaterThan(
    int row, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'row',
        lower: [row],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterWhereClause> rowLessThan(
    int row, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'row',
        lower: [],
        upper: [row],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterWhereClause> rowBetween(
    int lowerRow,
    int upperRow, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'row',
        lower: [lowerRow],
        includeLower: includeLower,
        upper: [upperRow],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterWhereClause> colEqualTo(int col) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'col',
        value: [col],
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterWhereClause> colNotEqualTo(int col) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'col',
              lower: [],
              upper: [col],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'col',
              lower: [col],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'col',
              lower: [col],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'col',
              lower: [],
              upper: [col],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TileData, TileData, QAfterWhereClause> colGreaterThan(
    int col, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'col',
        lower: [col],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterWhereClause> colLessThan(
    int col, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'col',
        lower: [],
        upper: [col],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterWhereClause> colBetween(
    int lowerCol,
    int upperCol, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'col',
        lower: [lowerCol],
        includeLower: includeLower,
        upper: [upperCol],
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

  QueryBuilder<TileData, TileData, QAfterFilterCondition> colEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'col',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> colGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'col',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> colLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'col',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> colBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'col',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      cooldownSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cooldownSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      cooldownSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cooldownSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      cooldownSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cooldownSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      cooldownSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cooldownSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> energyCostEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'energyCost',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> energyCostGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'energyCost',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> energyCostLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'energyCost',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> energyCostBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'energyCost',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      generatesItemPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'generatesItemPath',
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      generatesItemPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'generatesItemPath',
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      generatesItemPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'generatesItemPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      generatesItemPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'generatesItemPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      generatesItemPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'generatesItemPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      generatesItemPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'generatesItemPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      generatesItemPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'generatesItemPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      generatesItemPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'generatesItemPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      generatesItemPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'generatesItemPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      generatesItemPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'generatesItemPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      generatesItemPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'generatesItemPath',
        value: '',
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      generatesItemPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'generatesItemPath',
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

  QueryBuilder<TileData, TileData, QAfterFilterCondition> isEmptyEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isEmpty',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> isGeneratorEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isGenerator',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> isItemEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isItem',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> isLockedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isLocked',
        value: value,
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

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      lastUsedTimestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUsedTimestamp',
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      lastUsedTimestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUsedTimestamp',
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      lastUsedTimestampEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUsedTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      lastUsedTimestampGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUsedTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      lastUsedTimestampLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUsedTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition>
      lastUsedTimestampBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUsedTimestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
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

  QueryBuilder<TileData, TileData, QAfterFilterCondition> rowEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'row',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> rowGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'row',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> rowLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'row',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> rowBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'row',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> typeEqualTo(
      TileType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> typeGreaterThan(
    TileType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> typeLessThan(
    TileType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<TileData, TileData, QAfterFilterCondition> typeBetween(
    TileType lower,
    TileType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
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

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByCol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'col', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByColDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'col', Sort.desc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByCooldownSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cooldownSeconds', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByCooldownSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cooldownSeconds', Sort.desc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByEnergyCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'energyCost', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByEnergyCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'energyCost', Sort.desc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByGeneratesItemPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatesItemPath', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByGeneratesItemPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatesItemPath', Sort.desc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEmpty', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByIsEmptyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEmpty', Sort.desc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByIsGenerator() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGenerator', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByIsGeneratorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGenerator', Sort.desc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByIsItem() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isItem', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByIsItemDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isItem', Sort.desc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByIsLocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocked', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByIsLockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocked', Sort.desc);
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

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByLastUsedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedTimestamp', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByLastUsedTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedTimestamp', Sort.desc);
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

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByRow() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'row', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByRowDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'row', Sort.desc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
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

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByCol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'col', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByColDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'col', Sort.desc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByCooldownSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cooldownSeconds', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByCooldownSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cooldownSeconds', Sort.desc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByEnergyCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'energyCost', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByEnergyCostDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'energyCost', Sort.desc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByGeneratesItemPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatesItemPath', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByGeneratesItemPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'generatesItemPath', Sort.desc);
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

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEmpty', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByIsEmptyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEmpty', Sort.desc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByIsGenerator() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGenerator', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByIsGeneratorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGenerator', Sort.desc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByIsItem() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isItem', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByIsItemDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isItem', Sort.desc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByIsLocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocked', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByIsLockedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocked', Sort.desc);
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

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByLastUsedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedTimestamp', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByLastUsedTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedTimestamp', Sort.desc);
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

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByRow() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'row', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByRowDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'row', Sort.desc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<TileData, TileData, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
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

  QueryBuilder<TileData, TileData, QDistinct> distinctByCol() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'col');
    });
  }

  QueryBuilder<TileData, TileData, QDistinct> distinctByCooldownSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cooldownSeconds');
    });
  }

  QueryBuilder<TileData, TileData, QDistinct> distinctByEnergyCost() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'energyCost');
    });
  }

  QueryBuilder<TileData, TileData, QDistinct> distinctByGeneratesItemPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'generatesItemPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TileData, TileData, QDistinct> distinctByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isEmpty');
    });
  }

  QueryBuilder<TileData, TileData, QDistinct> distinctByIsGenerator() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isGenerator');
    });
  }

  QueryBuilder<TileData, TileData, QDistinct> distinctByIsItem() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isItem');
    });
  }

  QueryBuilder<TileData, TileData, QDistinct> distinctByIsLocked() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLocked');
    });
  }

  QueryBuilder<TileData, TileData, QDistinct> distinctByItemImagePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemImagePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TileData, TileData, QDistinct> distinctByLastUsedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUsedTimestamp');
    });
  }

  QueryBuilder<TileData, TileData, QDistinct> distinctByOverlayNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'overlayNumber');
    });
  }

  QueryBuilder<TileData, TileData, QDistinct> distinctByRow() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'row');
    });
  }

  QueryBuilder<TileData, TileData, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
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

  QueryBuilder<TileData, int, QQueryOperations> colProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'col');
    });
  }

  QueryBuilder<TileData, int, QQueryOperations> cooldownSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cooldownSeconds');
    });
  }

  QueryBuilder<TileData, int, QQueryOperations> energyCostProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'energyCost');
    });
  }

  QueryBuilder<TileData, String?, QQueryOperations>
      generatesItemPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'generatesItemPath');
    });
  }

  QueryBuilder<TileData, bool, QQueryOperations> isEmptyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isEmpty');
    });
  }

  QueryBuilder<TileData, bool, QQueryOperations> isGeneratorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isGenerator');
    });
  }

  QueryBuilder<TileData, bool, QQueryOperations> isItemProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isItem');
    });
  }

  QueryBuilder<TileData, bool, QQueryOperations> isLockedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLocked');
    });
  }

  QueryBuilder<TileData, String?, QQueryOperations> itemImagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemImagePath');
    });
  }

  QueryBuilder<TileData, DateTime?, QQueryOperations>
      lastUsedTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUsedTimestamp');
    });
  }

  QueryBuilder<TileData, int, QQueryOperations> overlayNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'overlayNumber');
    });
  }

  QueryBuilder<TileData, int, QQueryOperations> rowProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'row');
    });
  }

  QueryBuilder<TileData, TileType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
