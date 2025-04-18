// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_stats.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlayerStatsCollection on Isar {
  IsarCollection<PlayerStats> get playerStats => this.collection();
}

const PlayerStatsSchema = CollectionSchema(
  name: r'PlayerStats',
  id: 5703076723331647343,
  properties: {
    r'coins': PropertySchema(
      id: 0,
      name: r'coins',
      type: IsarType.long,
    ),
    r'energy': PropertySchema(
      id: 1,
      name: r'energy',
      type: IsarType.long,
    ),
    r'gems': PropertySchema(
      id: 2,
      name: r'gems',
      type: IsarType.long,
    ),
    r'infrastructureLevelsData': PropertySchema(
      id: 3,
      name: r'infrastructureLevelsData',
      type: IsarType.stringList,
    ),
    r'level': PropertySchema(
      id: 4,
      name: r'level',
      type: IsarType.long,
    ),
    r'maxEnergy': PropertySchema(
      id: 5,
      name: r'maxEnergy',
      type: IsarType.long,
    ),
    r'unlockedZoneIds': PropertySchema(
      id: 6,
      name: r'unlockedZoneIds',
      type: IsarType.stringList,
    ),
    r'xp': PropertySchema(
      id: 7,
      name: r'xp',
      type: IsarType.long,
    )
  },
  estimateSize: _playerStatsEstimateSize,
  serialize: _playerStatsSerialize,
  deserialize: _playerStatsDeserialize,
  deserializeProp: _playerStatsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _playerStatsGetId,
  getLinks: _playerStatsGetLinks,
  attach: _playerStatsAttach,
  version: '3.1.0+1',
);

int _playerStatsEstimateSize(
  PlayerStats object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.infrastructureLevelsData.length * 3;
  {
    for (var i = 0; i < object.infrastructureLevelsData.length; i++) {
      final value = object.infrastructureLevelsData[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.unlockedZoneIds.length * 3;
  {
    for (var i = 0; i < object.unlockedZoneIds.length; i++) {
      final value = object.unlockedZoneIds[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _playerStatsSerialize(
  PlayerStats object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.coins);
  writer.writeLong(offsets[1], object.energy);
  writer.writeLong(offsets[2], object.gems);
  writer.writeStringList(offsets[3], object.infrastructureLevelsData);
  writer.writeLong(offsets[4], object.level);
  writer.writeLong(offsets[5], object.maxEnergy);
  writer.writeStringList(offsets[6], object.unlockedZoneIds);
  writer.writeLong(offsets[7], object.xp);
}

PlayerStats _playerStatsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlayerStats(
    coins: reader.readLongOrNull(offsets[0]) ?? 50,
    energy: reader.readLongOrNull(offsets[1]) ?? 100,
    gems: reader.readLongOrNull(offsets[2]) ?? 20,
    level: reader.readLongOrNull(offsets[4]) ?? 1,
    maxEnergy: reader.readLongOrNull(offsets[5]) ?? 100,
    xp: reader.readLongOrNull(offsets[7]) ?? 0,
  );
  object.id = id;
  object.infrastructureLevelsData = reader.readStringList(offsets[3]) ?? [];
  object.unlockedZoneIds = reader.readStringList(offsets[6]) ?? [];
  return object;
}

P _playerStatsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 50) as P;
    case 1:
      return (reader.readLongOrNull(offset) ?? 100) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 20) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readLongOrNull(offset) ?? 1) as P;
    case 5:
      return (reader.readLongOrNull(offset) ?? 100) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _playerStatsGetId(PlayerStats object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _playerStatsGetLinks(PlayerStats object) {
  return [];
}

void _playerStatsAttach(
    IsarCollection<dynamic> col, Id id, PlayerStats object) {
  object.id = id;
}

extension PlayerStatsQueryWhereSort
    on QueryBuilder<PlayerStats, PlayerStats, QWhere> {
  QueryBuilder<PlayerStats, PlayerStats, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PlayerStatsQueryWhere
    on QueryBuilder<PlayerStats, PlayerStats, QWhereClause> {
  QueryBuilder<PlayerStats, PlayerStats, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<PlayerStats, PlayerStats, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterWhereClause> idBetween(
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

extension PlayerStatsQueryFilter
    on QueryBuilder<PlayerStats, PlayerStats, QFilterCondition> {
  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition> coinsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'coins',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      coinsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'coins',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition> coinsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'coins',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition> coinsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'coins',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition> energyEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'energy',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      energyGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'energy',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition> energyLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'energy',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition> energyBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'energy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition> gemsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gems',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition> gemsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gems',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition> gemsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gems',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition> gemsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gems',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      infrastructureLevelsDataElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'infrastructureLevelsData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      infrastructureLevelsDataElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'infrastructureLevelsData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      infrastructureLevelsDataElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'infrastructureLevelsData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      infrastructureLevelsDataElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'infrastructureLevelsData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      infrastructureLevelsDataElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'infrastructureLevelsData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      infrastructureLevelsDataElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'infrastructureLevelsData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      infrastructureLevelsDataElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'infrastructureLevelsData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      infrastructureLevelsDataElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'infrastructureLevelsData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      infrastructureLevelsDataElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'infrastructureLevelsData',
        value: '',
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      infrastructureLevelsDataElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'infrastructureLevelsData',
        value: '',
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      infrastructureLevelsDataLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'infrastructureLevelsData',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      infrastructureLevelsDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'infrastructureLevelsData',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      infrastructureLevelsDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'infrastructureLevelsData',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      infrastructureLevelsDataLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'infrastructureLevelsData',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      infrastructureLevelsDataLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'infrastructureLevelsData',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      infrastructureLevelsDataLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'infrastructureLevelsData',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition> levelEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'level',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      levelGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'level',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition> levelLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'level',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition> levelBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'level',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      maxEnergyEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxEnergy',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      maxEnergyGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxEnergy',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      maxEnergyLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxEnergy',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      maxEnergyBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxEnergy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      unlockedZoneIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedZoneIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      unlockedZoneIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unlockedZoneIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      unlockedZoneIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unlockedZoneIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      unlockedZoneIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unlockedZoneIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      unlockedZoneIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unlockedZoneIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      unlockedZoneIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unlockedZoneIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      unlockedZoneIdsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unlockedZoneIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      unlockedZoneIdsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unlockedZoneIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      unlockedZoneIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedZoneIds',
        value: '',
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      unlockedZoneIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unlockedZoneIds',
        value: '',
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      unlockedZoneIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedZoneIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      unlockedZoneIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedZoneIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      unlockedZoneIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedZoneIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      unlockedZoneIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedZoneIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      unlockedZoneIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedZoneIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition>
      unlockedZoneIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedZoneIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition> xpEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'xp',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition> xpGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'xp',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition> xpLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'xp',
        value: value,
      ));
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterFilterCondition> xpBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'xp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PlayerStatsQueryObject
    on QueryBuilder<PlayerStats, PlayerStats, QFilterCondition> {}

extension PlayerStatsQueryLinks
    on QueryBuilder<PlayerStats, PlayerStats, QFilterCondition> {}

extension PlayerStatsQuerySortBy
    on QueryBuilder<PlayerStats, PlayerStats, QSortBy> {
  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> sortByCoins() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coins', Sort.asc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> sortByCoinsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coins', Sort.desc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> sortByEnergy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'energy', Sort.asc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> sortByEnergyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'energy', Sort.desc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> sortByGems() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gems', Sort.asc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> sortByGemsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gems', Sort.desc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> sortByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> sortByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> sortByMaxEnergy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxEnergy', Sort.asc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> sortByMaxEnergyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxEnergy', Sort.desc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> sortByXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xp', Sort.asc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> sortByXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xp', Sort.desc);
    });
  }
}

extension PlayerStatsQuerySortThenBy
    on QueryBuilder<PlayerStats, PlayerStats, QSortThenBy> {
  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> thenByCoins() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coins', Sort.asc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> thenByCoinsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'coins', Sort.desc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> thenByEnergy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'energy', Sort.asc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> thenByEnergyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'energy', Sort.desc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> thenByGems() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gems', Sort.asc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> thenByGemsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gems', Sort.desc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> thenByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> thenByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> thenByMaxEnergy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxEnergy', Sort.asc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> thenByMaxEnergyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxEnergy', Sort.desc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> thenByXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xp', Sort.asc);
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QAfterSortBy> thenByXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'xp', Sort.desc);
    });
  }
}

extension PlayerStatsQueryWhereDistinct
    on QueryBuilder<PlayerStats, PlayerStats, QDistinct> {
  QueryBuilder<PlayerStats, PlayerStats, QDistinct> distinctByCoins() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'coins');
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QDistinct> distinctByEnergy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'energy');
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QDistinct> distinctByGems() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gems');
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QDistinct>
      distinctByInfrastructureLevelsData() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'infrastructureLevelsData');
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QDistinct> distinctByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'level');
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QDistinct> distinctByMaxEnergy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxEnergy');
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QDistinct>
      distinctByUnlockedZoneIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockedZoneIds');
    });
  }

  QueryBuilder<PlayerStats, PlayerStats, QDistinct> distinctByXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'xp');
    });
  }
}

extension PlayerStatsQueryProperty
    on QueryBuilder<PlayerStats, PlayerStats, QQueryProperty> {
  QueryBuilder<PlayerStats, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlayerStats, int, QQueryOperations> coinsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'coins');
    });
  }

  QueryBuilder<PlayerStats, int, QQueryOperations> energyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'energy');
    });
  }

  QueryBuilder<PlayerStats, int, QQueryOperations> gemsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gems');
    });
  }

  QueryBuilder<PlayerStats, List<String>, QQueryOperations>
      infrastructureLevelsDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'infrastructureLevelsData');
    });
  }

  QueryBuilder<PlayerStats, int, QQueryOperations> levelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'level');
    });
  }

  QueryBuilder<PlayerStats, int, QQueryOperations> maxEnergyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxEnergy');
    });
  }

  QueryBuilder<PlayerStats, List<String>, QQueryOperations>
      unlockedZoneIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockedZoneIds');
    });
  }

  QueryBuilder<PlayerStats, int, QQueryOperations> xpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'xp');
    });
  }
}
