// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AjustesTable extends Ajustes with TableInfo<$AjustesTable, Ajuste> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AjustesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _claveMeta = const VerificationMeta('clave');
  @override
  late final GeneratedColumn<String> clave = GeneratedColumn<String>(
    'clave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [clave, valor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ajustes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ajuste> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('clave')) {
      context.handle(
        _claveMeta,
        clave.isAcceptableOrUnknown(data['clave']!, _claveMeta),
      );
    } else if (isInserting) {
      context.missing(_claveMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clave};
  @override
  Ajuste map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ajuste(
      clave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clave'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor'],
      )!,
    );
  }

  @override
  $AjustesTable createAlias(String alias) {
    return $AjustesTable(attachedDatabase, alias);
  }
}

class Ajuste extends DataClass implements Insertable<Ajuste> {
  final String clave;
  final String valor;
  const Ajuste({required this.clave, required this.valor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['clave'] = Variable<String>(clave);
    map['valor'] = Variable<String>(valor);
    return map;
  }

  AjustesCompanion toCompanion(bool nullToAbsent) {
    return AjustesCompanion(clave: Value(clave), valor: Value(valor));
  }

  factory Ajuste.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ajuste(
      clave: serializer.fromJson<String>(json['clave']),
      valor: serializer.fromJson<String>(json['valor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clave': serializer.toJson<String>(clave),
      'valor': serializer.toJson<String>(valor),
    };
  }

  Ajuste copyWith({String? clave, String? valor}) =>
      Ajuste(clave: clave ?? this.clave, valor: valor ?? this.valor);
  Ajuste copyWithCompanion(AjustesCompanion data) {
    return Ajuste(
      clave: data.clave.present ? data.clave.value : this.clave,
      valor: data.valor.present ? data.valor.value : this.valor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ajuste(')
          ..write('clave: $clave, ')
          ..write('valor: $valor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(clave, valor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ajuste &&
          other.clave == this.clave &&
          other.valor == this.valor);
}

class AjustesCompanion extends UpdateCompanion<Ajuste> {
  final Value<String> clave;
  final Value<String> valor;
  final Value<int> rowid;
  const AjustesCompanion({
    this.clave = const Value.absent(),
    this.valor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AjustesCompanion.insert({
    required String clave,
    required String valor,
    this.rowid = const Value.absent(),
  }) : clave = Value(clave),
       valor = Value(valor);
  static Insertable<Ajuste> custom({
    Expression<String>? clave,
    Expression<String>? valor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clave != null) 'clave': clave,
      if (valor != null) 'valor': valor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AjustesCompanion copyWith({
    Value<String>? clave,
    Value<String>? valor,
    Value<int>? rowid,
  }) {
    return AjustesCompanion(
      clave: clave ?? this.clave,
      valor: valor ?? this.valor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clave.present) {
      map['clave'] = Variable<String>(clave.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AjustesCompanion(')
          ..write('clave: $clave, ')
          ..write('valor: $valor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ColegiosTable extends Colegios with TableInfo<$ColegiosTable, Colegio> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ColegiosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lugarMeta = const VerificationMeta('lugar');
  @override
  late final GeneratedColumn<String> lugar = GeneratedColumn<String>(
    'lugar',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paisMeta = const VerificationMeta('pais');
  @override
  late final GeneratedColumn<String> pais = GeneratedColumn<String>(
    'pais',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PE'),
  );
  static const VerificationMeta _creadoMeta = const VerificationMeta('creado');
  @override
  late final GeneratedColumn<DateTime> creado = GeneratedColumn<DateTime>(
    'creado',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    lugar,
    color,
    pais,
    creado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'colegios';
  @override
  VerificationContext validateIntegrity(
    Insertable<Colegio> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('lugar')) {
      context.handle(
        _lugarMeta,
        lugar.isAcceptableOrUnknown(data['lugar']!, _lugarMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('pais')) {
      context.handle(
        _paisMeta,
        pais.isAcceptableOrUnknown(data['pais']!, _paisMeta),
      );
    }
    if (data.containsKey('creado')) {
      context.handle(
        _creadoMeta,
        creado.isAcceptableOrUnknown(data['creado']!, _creadoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Colegio map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Colegio(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      lugar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lugar'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      ),
      pais: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pais'],
      )!,
      creado: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado'],
      )!,
    );
  }

  @override
  $ColegiosTable createAlias(String alias) {
    return $ColegiosTable(attachedDatabase, alias);
  }
}

class Colegio extends DataClass implements Insertable<Colegio> {
  final int id;
  final String nombre;
  final String? lugar;
  final int? color;
  final String pais;
  final DateTime creado;
  const Colegio({
    required this.id,
    required this.nombre,
    this.lugar,
    this.color,
    required this.pais,
    required this.creado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || lugar != null) {
      map['lugar'] = Variable<String>(lugar);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    map['pais'] = Variable<String>(pais);
    map['creado'] = Variable<DateTime>(creado);
    return map;
  }

  ColegiosCompanion toCompanion(bool nullToAbsent) {
    return ColegiosCompanion(
      id: Value(id),
      nombre: Value(nombre),
      lugar: lugar == null && nullToAbsent
          ? const Value.absent()
          : Value(lugar),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      pais: Value(pais),
      creado: Value(creado),
    );
  }

  factory Colegio.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Colegio(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      lugar: serializer.fromJson<String?>(json['lugar']),
      color: serializer.fromJson<int?>(json['color']),
      pais: serializer.fromJson<String>(json['pais']),
      creado: serializer.fromJson<DateTime>(json['creado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'lugar': serializer.toJson<String?>(lugar),
      'color': serializer.toJson<int?>(color),
      'pais': serializer.toJson<String>(pais),
      'creado': serializer.toJson<DateTime>(creado),
    };
  }

  Colegio copyWith({
    int? id,
    String? nombre,
    Value<String?> lugar = const Value.absent(),
    Value<int?> color = const Value.absent(),
    String? pais,
    DateTime? creado,
  }) => Colegio(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    lugar: lugar.present ? lugar.value : this.lugar,
    color: color.present ? color.value : this.color,
    pais: pais ?? this.pais,
    creado: creado ?? this.creado,
  );
  Colegio copyWithCompanion(ColegiosCompanion data) {
    return Colegio(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      lugar: data.lugar.present ? data.lugar.value : this.lugar,
      color: data.color.present ? data.color.value : this.color,
      pais: data.pais.present ? data.pais.value : this.pais,
      creado: data.creado.present ? data.creado.value : this.creado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Colegio(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('lugar: $lugar, ')
          ..write('color: $color, ')
          ..write('pais: $pais, ')
          ..write('creado: $creado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, lugar, color, pais, creado);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Colegio &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.lugar == this.lugar &&
          other.color == this.color &&
          other.pais == this.pais &&
          other.creado == this.creado);
}

class ColegiosCompanion extends UpdateCompanion<Colegio> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String?> lugar;
  final Value<int?> color;
  final Value<String> pais;
  final Value<DateTime> creado;
  const ColegiosCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.lugar = const Value.absent(),
    this.color = const Value.absent(),
    this.pais = const Value.absent(),
    this.creado = const Value.absent(),
  });
  ColegiosCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    this.lugar = const Value.absent(),
    this.color = const Value.absent(),
    this.pais = const Value.absent(),
    this.creado = const Value.absent(),
  }) : nombre = Value(nombre);
  static Insertable<Colegio> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? lugar,
    Expression<int>? color,
    Expression<String>? pais,
    Expression<DateTime>? creado,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (lugar != null) 'lugar': lugar,
      if (color != null) 'color': color,
      if (pais != null) 'pais': pais,
      if (creado != null) 'creado': creado,
    });
  }

  ColegiosCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<String?>? lugar,
    Value<int?>? color,
    Value<String>? pais,
    Value<DateTime>? creado,
  }) {
    return ColegiosCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      lugar: lugar ?? this.lugar,
      color: color ?? this.color,
      pais: pais ?? this.pais,
      creado: creado ?? this.creado,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (lugar.present) {
      map['lugar'] = Variable<String>(lugar.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (pais.present) {
      map['pais'] = Variable<String>(pais.value);
    }
    if (creado.present) {
      map['creado'] = Variable<DateTime>(creado.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ColegiosCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('lugar: $lugar, ')
          ..write('color: $color, ')
          ..write('pais: $pais, ')
          ..write('creado: $creado')
          ..write(')'))
        .toString();
  }
}

class $CursosTable extends Cursos with TableInfo<$CursosTable, Curso> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CursosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _colegioIdMeta = const VerificationMeta(
    'colegioId',
  );
  @override
  late final GeneratedColumn<int> colegioId = GeneratedColumn<int>(
    'colegio_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES colegios (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nivelMeta = const VerificationMeta('nivel');
  @override
  late final GeneratedColumn<String> nivel = GeneratedColumn<String>(
    'nivel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gradoMeta = const VerificationMeta('grado');
  @override
  late final GeneratedColumn<String> grado = GeneratedColumn<String>(
    'grado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seccionMeta = const VerificationMeta(
    'seccion',
  );
  @override
  late final GeneratedColumn<String> seccion = GeneratedColumn<String>(
    'seccion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaMeta = const VerificationMeta('area');
  @override
  late final GeneratedColumn<String> area = GeneratedColumn<String>(
    'area',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tutorMeta = const VerificationMeta('tutor');
  @override
  late final GeneratedColumn<String> tutor = GeneratedColumn<String>(
    'tutor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tutorCelularMeta = const VerificationMeta(
    'tutorCelular',
  );
  @override
  late final GeneratedColumn<String> tutorCelular = GeneratedColumn<String>(
    'tutor_celular',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadoMeta = const VerificationMeta('creado');
  @override
  late final GeneratedColumn<DateTime> creado = GeneratedColumn<DateTime>(
    'creado',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    colegioId,
    nivel,
    grado,
    seccion,
    nombre,
    area,
    tutor,
    tutorCelular,
    creado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cursos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Curso> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('colegio_id')) {
      context.handle(
        _colegioIdMeta,
        colegioId.isAcceptableOrUnknown(data['colegio_id']!, _colegioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_colegioIdMeta);
    }
    if (data.containsKey('nivel')) {
      context.handle(
        _nivelMeta,
        nivel.isAcceptableOrUnknown(data['nivel']!, _nivelMeta),
      );
    } else if (isInserting) {
      context.missing(_nivelMeta);
    }
    if (data.containsKey('grado')) {
      context.handle(
        _gradoMeta,
        grado.isAcceptableOrUnknown(data['grado']!, _gradoMeta),
      );
    } else if (isInserting) {
      context.missing(_gradoMeta);
    }
    if (data.containsKey('seccion')) {
      context.handle(
        _seccionMeta,
        seccion.isAcceptableOrUnknown(data['seccion']!, _seccionMeta),
      );
    } else if (isInserting) {
      context.missing(_seccionMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('area')) {
      context.handle(
        _areaMeta,
        area.isAcceptableOrUnknown(data['area']!, _areaMeta),
      );
    }
    if (data.containsKey('tutor')) {
      context.handle(
        _tutorMeta,
        tutor.isAcceptableOrUnknown(data['tutor']!, _tutorMeta),
      );
    }
    if (data.containsKey('tutor_celular')) {
      context.handle(
        _tutorCelularMeta,
        tutorCelular.isAcceptableOrUnknown(
          data['tutor_celular']!,
          _tutorCelularMeta,
        ),
      );
    }
    if (data.containsKey('creado')) {
      context.handle(
        _creadoMeta,
        creado.isAcceptableOrUnknown(data['creado']!, _creadoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Curso map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Curso(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      colegioId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}colegio_id'],
      )!,
      nivel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nivel'],
      )!,
      grado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grado'],
      )!,
      seccion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seccion'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      area: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}area'],
      ),
      tutor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tutor'],
      ),
      tutorCelular: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tutor_celular'],
      ),
      creado: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado'],
      )!,
    );
  }

  @override
  $CursosTable createAlias(String alias) {
    return $CursosTable(attachedDatabase, alias);
  }
}

class Curso extends DataClass implements Insertable<Curso> {
  final int id;
  final int colegioId;
  final String nivel;
  final String grado;
  final String seccion;
  final String nombre;
  final String? area;
  final String? tutor;
  final String? tutorCelular;
  final DateTime creado;
  const Curso({
    required this.id,
    required this.colegioId,
    required this.nivel,
    required this.grado,
    required this.seccion,
    required this.nombre,
    this.area,
    this.tutor,
    this.tutorCelular,
    required this.creado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['colegio_id'] = Variable<int>(colegioId);
    map['nivel'] = Variable<String>(nivel);
    map['grado'] = Variable<String>(grado);
    map['seccion'] = Variable<String>(seccion);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || area != null) {
      map['area'] = Variable<String>(area);
    }
    if (!nullToAbsent || tutor != null) {
      map['tutor'] = Variable<String>(tutor);
    }
    if (!nullToAbsent || tutorCelular != null) {
      map['tutor_celular'] = Variable<String>(tutorCelular);
    }
    map['creado'] = Variable<DateTime>(creado);
    return map;
  }

  CursosCompanion toCompanion(bool nullToAbsent) {
    return CursosCompanion(
      id: Value(id),
      colegioId: Value(colegioId),
      nivel: Value(nivel),
      grado: Value(grado),
      seccion: Value(seccion),
      nombre: Value(nombre),
      area: area == null && nullToAbsent ? const Value.absent() : Value(area),
      tutor: tutor == null && nullToAbsent
          ? const Value.absent()
          : Value(tutor),
      tutorCelular: tutorCelular == null && nullToAbsent
          ? const Value.absent()
          : Value(tutorCelular),
      creado: Value(creado),
    );
  }

  factory Curso.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Curso(
      id: serializer.fromJson<int>(json['id']),
      colegioId: serializer.fromJson<int>(json['colegioId']),
      nivel: serializer.fromJson<String>(json['nivel']),
      grado: serializer.fromJson<String>(json['grado']),
      seccion: serializer.fromJson<String>(json['seccion']),
      nombre: serializer.fromJson<String>(json['nombre']),
      area: serializer.fromJson<String?>(json['area']),
      tutor: serializer.fromJson<String?>(json['tutor']),
      tutorCelular: serializer.fromJson<String?>(json['tutorCelular']),
      creado: serializer.fromJson<DateTime>(json['creado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'colegioId': serializer.toJson<int>(colegioId),
      'nivel': serializer.toJson<String>(nivel),
      'grado': serializer.toJson<String>(grado),
      'seccion': serializer.toJson<String>(seccion),
      'nombre': serializer.toJson<String>(nombre),
      'area': serializer.toJson<String?>(area),
      'tutor': serializer.toJson<String?>(tutor),
      'tutorCelular': serializer.toJson<String?>(tutorCelular),
      'creado': serializer.toJson<DateTime>(creado),
    };
  }

  Curso copyWith({
    int? id,
    int? colegioId,
    String? nivel,
    String? grado,
    String? seccion,
    String? nombre,
    Value<String?> area = const Value.absent(),
    Value<String?> tutor = const Value.absent(),
    Value<String?> tutorCelular = const Value.absent(),
    DateTime? creado,
  }) => Curso(
    id: id ?? this.id,
    colegioId: colegioId ?? this.colegioId,
    nivel: nivel ?? this.nivel,
    grado: grado ?? this.grado,
    seccion: seccion ?? this.seccion,
    nombre: nombre ?? this.nombre,
    area: area.present ? area.value : this.area,
    tutor: tutor.present ? tutor.value : this.tutor,
    tutorCelular: tutorCelular.present ? tutorCelular.value : this.tutorCelular,
    creado: creado ?? this.creado,
  );
  Curso copyWithCompanion(CursosCompanion data) {
    return Curso(
      id: data.id.present ? data.id.value : this.id,
      colegioId: data.colegioId.present ? data.colegioId.value : this.colegioId,
      nivel: data.nivel.present ? data.nivel.value : this.nivel,
      grado: data.grado.present ? data.grado.value : this.grado,
      seccion: data.seccion.present ? data.seccion.value : this.seccion,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      area: data.area.present ? data.area.value : this.area,
      tutor: data.tutor.present ? data.tutor.value : this.tutor,
      tutorCelular: data.tutorCelular.present
          ? data.tutorCelular.value
          : this.tutorCelular,
      creado: data.creado.present ? data.creado.value : this.creado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Curso(')
          ..write('id: $id, ')
          ..write('colegioId: $colegioId, ')
          ..write('nivel: $nivel, ')
          ..write('grado: $grado, ')
          ..write('seccion: $seccion, ')
          ..write('nombre: $nombre, ')
          ..write('area: $area, ')
          ..write('tutor: $tutor, ')
          ..write('tutorCelular: $tutorCelular, ')
          ..write('creado: $creado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    colegioId,
    nivel,
    grado,
    seccion,
    nombre,
    area,
    tutor,
    tutorCelular,
    creado,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Curso &&
          other.id == this.id &&
          other.colegioId == this.colegioId &&
          other.nivel == this.nivel &&
          other.grado == this.grado &&
          other.seccion == this.seccion &&
          other.nombre == this.nombre &&
          other.area == this.area &&
          other.tutor == this.tutor &&
          other.tutorCelular == this.tutorCelular &&
          other.creado == this.creado);
}

class CursosCompanion extends UpdateCompanion<Curso> {
  final Value<int> id;
  final Value<int> colegioId;
  final Value<String> nivel;
  final Value<String> grado;
  final Value<String> seccion;
  final Value<String> nombre;
  final Value<String?> area;
  final Value<String?> tutor;
  final Value<String?> tutorCelular;
  final Value<DateTime> creado;
  const CursosCompanion({
    this.id = const Value.absent(),
    this.colegioId = const Value.absent(),
    this.nivel = const Value.absent(),
    this.grado = const Value.absent(),
    this.seccion = const Value.absent(),
    this.nombre = const Value.absent(),
    this.area = const Value.absent(),
    this.tutor = const Value.absent(),
    this.tutorCelular = const Value.absent(),
    this.creado = const Value.absent(),
  });
  CursosCompanion.insert({
    this.id = const Value.absent(),
    required int colegioId,
    required String nivel,
    required String grado,
    required String seccion,
    required String nombre,
    this.area = const Value.absent(),
    this.tutor = const Value.absent(),
    this.tutorCelular = const Value.absent(),
    this.creado = const Value.absent(),
  }) : colegioId = Value(colegioId),
       nivel = Value(nivel),
       grado = Value(grado),
       seccion = Value(seccion),
       nombre = Value(nombre);
  static Insertable<Curso> custom({
    Expression<int>? id,
    Expression<int>? colegioId,
    Expression<String>? nivel,
    Expression<String>? grado,
    Expression<String>? seccion,
    Expression<String>? nombre,
    Expression<String>? area,
    Expression<String>? tutor,
    Expression<String>? tutorCelular,
    Expression<DateTime>? creado,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (colegioId != null) 'colegio_id': colegioId,
      if (nivel != null) 'nivel': nivel,
      if (grado != null) 'grado': grado,
      if (seccion != null) 'seccion': seccion,
      if (nombre != null) 'nombre': nombre,
      if (area != null) 'area': area,
      if (tutor != null) 'tutor': tutor,
      if (tutorCelular != null) 'tutor_celular': tutorCelular,
      if (creado != null) 'creado': creado,
    });
  }

  CursosCompanion copyWith({
    Value<int>? id,
    Value<int>? colegioId,
    Value<String>? nivel,
    Value<String>? grado,
    Value<String>? seccion,
    Value<String>? nombre,
    Value<String?>? area,
    Value<String?>? tutor,
    Value<String?>? tutorCelular,
    Value<DateTime>? creado,
  }) {
    return CursosCompanion(
      id: id ?? this.id,
      colegioId: colegioId ?? this.colegioId,
      nivel: nivel ?? this.nivel,
      grado: grado ?? this.grado,
      seccion: seccion ?? this.seccion,
      nombre: nombre ?? this.nombre,
      area: area ?? this.area,
      tutor: tutor ?? this.tutor,
      tutorCelular: tutorCelular ?? this.tutorCelular,
      creado: creado ?? this.creado,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (colegioId.present) {
      map['colegio_id'] = Variable<int>(colegioId.value);
    }
    if (nivel.present) {
      map['nivel'] = Variable<String>(nivel.value);
    }
    if (grado.present) {
      map['grado'] = Variable<String>(grado.value);
    }
    if (seccion.present) {
      map['seccion'] = Variable<String>(seccion.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (area.present) {
      map['area'] = Variable<String>(area.value);
    }
    if (tutor.present) {
      map['tutor'] = Variable<String>(tutor.value);
    }
    if (tutorCelular.present) {
      map['tutor_celular'] = Variable<String>(tutorCelular.value);
    }
    if (creado.present) {
      map['creado'] = Variable<DateTime>(creado.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CursosCompanion(')
          ..write('id: $id, ')
          ..write('colegioId: $colegioId, ')
          ..write('nivel: $nivel, ')
          ..write('grado: $grado, ')
          ..write('seccion: $seccion, ')
          ..write('nombre: $nombre, ')
          ..write('area: $area, ')
          ..write('tutor: $tutor, ')
          ..write('tutorCelular: $tutorCelular, ')
          ..write('creado: $creado')
          ..write(')'))
        .toString();
  }
}

class $EstudiantesTable extends Estudiantes
    with TableInfo<$EstudiantesTable, Estudiante> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EstudiantesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cursoIdMeta = const VerificationMeta(
    'cursoId',
  );
  @override
  late final GeneratedColumn<int> cursoId = GeneratedColumn<int>(
    'curso_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cursos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _apellidosMeta = const VerificationMeta(
    'apellidos',
  );
  @override
  late final GeneratedColumn<String> apellidos = GeneratedColumn<String>(
    'apellidos',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombresMeta = const VerificationMeta(
    'nombres',
  );
  @override
  late final GeneratedColumn<String> nombres = GeneratedColumn<String>(
    'nombres',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dniMeta = const VerificationMeta('dni');
  @override
  late final GeneratedColumn<String> dni = GeneratedColumn<String>(
    'dni',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _apoderadoMeta = const VerificationMeta(
    'apoderado',
  );
  @override
  late final GeneratedColumn<String> apoderado = GeneratedColumn<String>(
    'apoderado',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentescoMeta = const VerificationMeta(
    'parentesco',
  );
  @override
  late final GeneratedColumn<String> parentesco = GeneratedColumn<String>(
    'parentesco',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _telefonoMeta = const VerificationMeta(
    'telefono',
  );
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
    'telefono',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _apoderado2Meta = const VerificationMeta(
    'apoderado2',
  );
  @override
  late final GeneratedColumn<String> apoderado2 = GeneratedColumn<String>(
    'apoderado2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentesco2Meta = const VerificationMeta(
    'parentesco2',
  );
  @override
  late final GeneratedColumn<String> parentesco2 = GeneratedColumn<String>(
    'parentesco2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _telefono2Meta = const VerificationMeta(
    'telefono2',
  );
  @override
  late final GeneratedColumn<String> telefono2 = GeneratedColumn<String>(
    'telefono2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nacimientoMeta = const VerificationMeta(
    'nacimiento',
  );
  @override
  late final GeneratedColumn<String> nacimiento = GeneratedColumn<String>(
    'nacimiento',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observacionesMeta = const VerificationMeta(
    'observaciones',
  );
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
    'observaciones',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _claveMeta = const VerificationMeta('clave');
  @override
  late final GeneratedColumn<String> clave = GeneratedColumn<String>(
    'clave',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoMeta = const VerificationMeta('foto');
  @override
  late final GeneratedColumn<Uint8List> foto = GeneratedColumn<Uint8List>(
    'foto',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _desdeMeta = const VerificationMeta('desde');
  @override
  late final GeneratedColumn<int> desde = GeneratedColumn<int>(
    'desde',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _hastaMeta = const VerificationMeta('hasta');
  @override
  late final GeneratedColumn<int> hasta = GeneratedColumn<int>(
    'hasta',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadoMeta = const VerificationMeta('creado');
  @override
  late final GeneratedColumn<DateTime> creado = GeneratedColumn<DateTime>(
    'creado',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cursoId,
    apellidos,
    nombres,
    dni,
    apoderado,
    parentesco,
    telefono,
    apoderado2,
    parentesco2,
    telefono2,
    nacimiento,
    observaciones,
    codigo,
    clave,
    foto,
    desde,
    hasta,
    creado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'estudiantes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Estudiante> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('curso_id')) {
      context.handle(
        _cursoIdMeta,
        cursoId.isAcceptableOrUnknown(data['curso_id']!, _cursoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cursoIdMeta);
    }
    if (data.containsKey('apellidos')) {
      context.handle(
        _apellidosMeta,
        apellidos.isAcceptableOrUnknown(data['apellidos']!, _apellidosMeta),
      );
    } else if (isInserting) {
      context.missing(_apellidosMeta);
    }
    if (data.containsKey('nombres')) {
      context.handle(
        _nombresMeta,
        nombres.isAcceptableOrUnknown(data['nombres']!, _nombresMeta),
      );
    } else if (isInserting) {
      context.missing(_nombresMeta);
    }
    if (data.containsKey('dni')) {
      context.handle(
        _dniMeta,
        dni.isAcceptableOrUnknown(data['dni']!, _dniMeta),
      );
    }
    if (data.containsKey('apoderado')) {
      context.handle(
        _apoderadoMeta,
        apoderado.isAcceptableOrUnknown(data['apoderado']!, _apoderadoMeta),
      );
    }
    if (data.containsKey('parentesco')) {
      context.handle(
        _parentescoMeta,
        parentesco.isAcceptableOrUnknown(data['parentesco']!, _parentescoMeta),
      );
    }
    if (data.containsKey('telefono')) {
      context.handle(
        _telefonoMeta,
        telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta),
      );
    }
    if (data.containsKey('apoderado2')) {
      context.handle(
        _apoderado2Meta,
        apoderado2.isAcceptableOrUnknown(data['apoderado2']!, _apoderado2Meta),
      );
    }
    if (data.containsKey('parentesco2')) {
      context.handle(
        _parentesco2Meta,
        parentesco2.isAcceptableOrUnknown(
          data['parentesco2']!,
          _parentesco2Meta,
        ),
      );
    }
    if (data.containsKey('telefono2')) {
      context.handle(
        _telefono2Meta,
        telefono2.isAcceptableOrUnknown(data['telefono2']!, _telefono2Meta),
      );
    }
    if (data.containsKey('nacimiento')) {
      context.handle(
        _nacimientoMeta,
        nacimiento.isAcceptableOrUnknown(data['nacimiento']!, _nacimientoMeta),
      );
    }
    if (data.containsKey('observaciones')) {
      context.handle(
        _observacionesMeta,
        observaciones.isAcceptableOrUnknown(
          data['observaciones']!,
          _observacionesMeta,
        ),
      );
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    }
    if (data.containsKey('clave')) {
      context.handle(
        _claveMeta,
        clave.isAcceptableOrUnknown(data['clave']!, _claveMeta),
      );
    }
    if (data.containsKey('foto')) {
      context.handle(
        _fotoMeta,
        foto.isAcceptableOrUnknown(data['foto']!, _fotoMeta),
      );
    }
    if (data.containsKey('desde')) {
      context.handle(
        _desdeMeta,
        desde.isAcceptableOrUnknown(data['desde']!, _desdeMeta),
      );
    }
    if (data.containsKey('hasta')) {
      context.handle(
        _hastaMeta,
        hasta.isAcceptableOrUnknown(data['hasta']!, _hastaMeta),
      );
    }
    if (data.containsKey('creado')) {
      context.handle(
        _creadoMeta,
        creado.isAcceptableOrUnknown(data['creado']!, _creadoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Estudiante map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Estudiante(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cursoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}curso_id'],
      )!,
      apellidos: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apellidos'],
      )!,
      nombres: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombres'],
      )!,
      dni: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dni'],
      ),
      apoderado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apoderado'],
      ),
      parentesco: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parentesco'],
      ),
      telefono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefono'],
      ),
      apoderado2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apoderado2'],
      ),
      parentesco2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parentesco2'],
      ),
      telefono2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefono2'],
      ),
      nacimiento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nacimiento'],
      ),
      observaciones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observaciones'],
      ),
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      ),
      clave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clave'],
      ),
      foto: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}foto'],
      ),
      desde: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}desde'],
      )!,
      hasta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hasta'],
      ),
      creado: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado'],
      )!,
    );
  }

  @override
  $EstudiantesTable createAlias(String alias) {
    return $EstudiantesTable(attachedDatabase, alias);
  }
}

class Estudiante extends DataClass implements Insertable<Estudiante> {
  final int id;
  final int cursoId;
  final String apellidos;
  final String nombres;
  final String? dni;
  final String? apoderado;
  final String? parentesco;
  final String? telefono;
  final String? apoderado2;
  final String? parentesco2;
  final String? telefono2;
  final String? nacimiento;
  final String? observaciones;
  final String? codigo;
  final String? clave;
  final Uint8List? foto;
  final int desde;
  final int? hasta;
  final DateTime creado;
  const Estudiante({
    required this.id,
    required this.cursoId,
    required this.apellidos,
    required this.nombres,
    this.dni,
    this.apoderado,
    this.parentesco,
    this.telefono,
    this.apoderado2,
    this.parentesco2,
    this.telefono2,
    this.nacimiento,
    this.observaciones,
    this.codigo,
    this.clave,
    this.foto,
    required this.desde,
    this.hasta,
    required this.creado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['curso_id'] = Variable<int>(cursoId);
    map['apellidos'] = Variable<String>(apellidos);
    map['nombres'] = Variable<String>(nombres);
    if (!nullToAbsent || dni != null) {
      map['dni'] = Variable<String>(dni);
    }
    if (!nullToAbsent || apoderado != null) {
      map['apoderado'] = Variable<String>(apoderado);
    }
    if (!nullToAbsent || parentesco != null) {
      map['parentesco'] = Variable<String>(parentesco);
    }
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    if (!nullToAbsent || apoderado2 != null) {
      map['apoderado2'] = Variable<String>(apoderado2);
    }
    if (!nullToAbsent || parentesco2 != null) {
      map['parentesco2'] = Variable<String>(parentesco2);
    }
    if (!nullToAbsent || telefono2 != null) {
      map['telefono2'] = Variable<String>(telefono2);
    }
    if (!nullToAbsent || nacimiento != null) {
      map['nacimiento'] = Variable<String>(nacimiento);
    }
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    if (!nullToAbsent || codigo != null) {
      map['codigo'] = Variable<String>(codigo);
    }
    if (!nullToAbsent || clave != null) {
      map['clave'] = Variable<String>(clave);
    }
    if (!nullToAbsent || foto != null) {
      map['foto'] = Variable<Uint8List>(foto);
    }
    map['desde'] = Variable<int>(desde);
    if (!nullToAbsent || hasta != null) {
      map['hasta'] = Variable<int>(hasta);
    }
    map['creado'] = Variable<DateTime>(creado);
    return map;
  }

  EstudiantesCompanion toCompanion(bool nullToAbsent) {
    return EstudiantesCompanion(
      id: Value(id),
      cursoId: Value(cursoId),
      apellidos: Value(apellidos),
      nombres: Value(nombres),
      dni: dni == null && nullToAbsent ? const Value.absent() : Value(dni),
      apoderado: apoderado == null && nullToAbsent
          ? const Value.absent()
          : Value(apoderado),
      parentesco: parentesco == null && nullToAbsent
          ? const Value.absent()
          : Value(parentesco),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      apoderado2: apoderado2 == null && nullToAbsent
          ? const Value.absent()
          : Value(apoderado2),
      parentesco2: parentesco2 == null && nullToAbsent
          ? const Value.absent()
          : Value(parentesco2),
      telefono2: telefono2 == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono2),
      nacimiento: nacimiento == null && nullToAbsent
          ? const Value.absent()
          : Value(nacimiento),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
      codigo: codigo == null && nullToAbsent
          ? const Value.absent()
          : Value(codigo),
      clave: clave == null && nullToAbsent
          ? const Value.absent()
          : Value(clave),
      foto: foto == null && nullToAbsent ? const Value.absent() : Value(foto),
      desde: Value(desde),
      hasta: hasta == null && nullToAbsent
          ? const Value.absent()
          : Value(hasta),
      creado: Value(creado),
    );
  }

  factory Estudiante.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Estudiante(
      id: serializer.fromJson<int>(json['id']),
      cursoId: serializer.fromJson<int>(json['cursoId']),
      apellidos: serializer.fromJson<String>(json['apellidos']),
      nombres: serializer.fromJson<String>(json['nombres']),
      dni: serializer.fromJson<String?>(json['dni']),
      apoderado: serializer.fromJson<String?>(json['apoderado']),
      parentesco: serializer.fromJson<String?>(json['parentesco']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      apoderado2: serializer.fromJson<String?>(json['apoderado2']),
      parentesco2: serializer.fromJson<String?>(json['parentesco2']),
      telefono2: serializer.fromJson<String?>(json['telefono2']),
      nacimiento: serializer.fromJson<String?>(json['nacimiento']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
      codigo: serializer.fromJson<String?>(json['codigo']),
      clave: serializer.fromJson<String?>(json['clave']),
      foto: serializer.fromJson<Uint8List?>(json['foto']),
      desde: serializer.fromJson<int>(json['desde']),
      hasta: serializer.fromJson<int?>(json['hasta']),
      creado: serializer.fromJson<DateTime>(json['creado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cursoId': serializer.toJson<int>(cursoId),
      'apellidos': serializer.toJson<String>(apellidos),
      'nombres': serializer.toJson<String>(nombres),
      'dni': serializer.toJson<String?>(dni),
      'apoderado': serializer.toJson<String?>(apoderado),
      'parentesco': serializer.toJson<String?>(parentesco),
      'telefono': serializer.toJson<String?>(telefono),
      'apoderado2': serializer.toJson<String?>(apoderado2),
      'parentesco2': serializer.toJson<String?>(parentesco2),
      'telefono2': serializer.toJson<String?>(telefono2),
      'nacimiento': serializer.toJson<String?>(nacimiento),
      'observaciones': serializer.toJson<String?>(observaciones),
      'codigo': serializer.toJson<String?>(codigo),
      'clave': serializer.toJson<String?>(clave),
      'foto': serializer.toJson<Uint8List?>(foto),
      'desde': serializer.toJson<int>(desde),
      'hasta': serializer.toJson<int?>(hasta),
      'creado': serializer.toJson<DateTime>(creado),
    };
  }

  Estudiante copyWith({
    int? id,
    int? cursoId,
    String? apellidos,
    String? nombres,
    Value<String?> dni = const Value.absent(),
    Value<String?> apoderado = const Value.absent(),
    Value<String?> parentesco = const Value.absent(),
    Value<String?> telefono = const Value.absent(),
    Value<String?> apoderado2 = const Value.absent(),
    Value<String?> parentesco2 = const Value.absent(),
    Value<String?> telefono2 = const Value.absent(),
    Value<String?> nacimiento = const Value.absent(),
    Value<String?> observaciones = const Value.absent(),
    Value<String?> codigo = const Value.absent(),
    Value<String?> clave = const Value.absent(),
    Value<Uint8List?> foto = const Value.absent(),
    int? desde,
    Value<int?> hasta = const Value.absent(),
    DateTime? creado,
  }) => Estudiante(
    id: id ?? this.id,
    cursoId: cursoId ?? this.cursoId,
    apellidos: apellidos ?? this.apellidos,
    nombres: nombres ?? this.nombres,
    dni: dni.present ? dni.value : this.dni,
    apoderado: apoderado.present ? apoderado.value : this.apoderado,
    parentesco: parentesco.present ? parentesco.value : this.parentesco,
    telefono: telefono.present ? telefono.value : this.telefono,
    apoderado2: apoderado2.present ? apoderado2.value : this.apoderado2,
    parentesco2: parentesco2.present ? parentesco2.value : this.parentesco2,
    telefono2: telefono2.present ? telefono2.value : this.telefono2,
    nacimiento: nacimiento.present ? nacimiento.value : this.nacimiento,
    observaciones: observaciones.present
        ? observaciones.value
        : this.observaciones,
    codigo: codigo.present ? codigo.value : this.codigo,
    clave: clave.present ? clave.value : this.clave,
    foto: foto.present ? foto.value : this.foto,
    desde: desde ?? this.desde,
    hasta: hasta.present ? hasta.value : this.hasta,
    creado: creado ?? this.creado,
  );
  Estudiante copyWithCompanion(EstudiantesCompanion data) {
    return Estudiante(
      id: data.id.present ? data.id.value : this.id,
      cursoId: data.cursoId.present ? data.cursoId.value : this.cursoId,
      apellidos: data.apellidos.present ? data.apellidos.value : this.apellidos,
      nombres: data.nombres.present ? data.nombres.value : this.nombres,
      dni: data.dni.present ? data.dni.value : this.dni,
      apoderado: data.apoderado.present ? data.apoderado.value : this.apoderado,
      parentesco: data.parentesco.present
          ? data.parentesco.value
          : this.parentesco,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      apoderado2: data.apoderado2.present
          ? data.apoderado2.value
          : this.apoderado2,
      parentesco2: data.parentesco2.present
          ? data.parentesco2.value
          : this.parentesco2,
      telefono2: data.telefono2.present ? data.telefono2.value : this.telefono2,
      nacimiento: data.nacimiento.present
          ? data.nacimiento.value
          : this.nacimiento,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      clave: data.clave.present ? data.clave.value : this.clave,
      foto: data.foto.present ? data.foto.value : this.foto,
      desde: data.desde.present ? data.desde.value : this.desde,
      hasta: data.hasta.present ? data.hasta.value : this.hasta,
      creado: data.creado.present ? data.creado.value : this.creado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Estudiante(')
          ..write('id: $id, ')
          ..write('cursoId: $cursoId, ')
          ..write('apellidos: $apellidos, ')
          ..write('nombres: $nombres, ')
          ..write('dni: $dni, ')
          ..write('apoderado: $apoderado, ')
          ..write('parentesco: $parentesco, ')
          ..write('telefono: $telefono, ')
          ..write('apoderado2: $apoderado2, ')
          ..write('parentesco2: $parentesco2, ')
          ..write('telefono2: $telefono2, ')
          ..write('nacimiento: $nacimiento, ')
          ..write('observaciones: $observaciones, ')
          ..write('codigo: $codigo, ')
          ..write('clave: $clave, ')
          ..write('foto: $foto, ')
          ..write('desde: $desde, ')
          ..write('hasta: $hasta, ')
          ..write('creado: $creado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cursoId,
    apellidos,
    nombres,
    dni,
    apoderado,
    parentesco,
    telefono,
    apoderado2,
    parentesco2,
    telefono2,
    nacimiento,
    observaciones,
    codigo,
    clave,
    $driftBlobEquality.hash(foto),
    desde,
    hasta,
    creado,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Estudiante &&
          other.id == this.id &&
          other.cursoId == this.cursoId &&
          other.apellidos == this.apellidos &&
          other.nombres == this.nombres &&
          other.dni == this.dni &&
          other.apoderado == this.apoderado &&
          other.parentesco == this.parentesco &&
          other.telefono == this.telefono &&
          other.apoderado2 == this.apoderado2 &&
          other.parentesco2 == this.parentesco2 &&
          other.telefono2 == this.telefono2 &&
          other.nacimiento == this.nacimiento &&
          other.observaciones == this.observaciones &&
          other.codigo == this.codigo &&
          other.clave == this.clave &&
          $driftBlobEquality.equals(other.foto, this.foto) &&
          other.desde == this.desde &&
          other.hasta == this.hasta &&
          other.creado == this.creado);
}

class EstudiantesCompanion extends UpdateCompanion<Estudiante> {
  final Value<int> id;
  final Value<int> cursoId;
  final Value<String> apellidos;
  final Value<String> nombres;
  final Value<String?> dni;
  final Value<String?> apoderado;
  final Value<String?> parentesco;
  final Value<String?> telefono;
  final Value<String?> apoderado2;
  final Value<String?> parentesco2;
  final Value<String?> telefono2;
  final Value<String?> nacimiento;
  final Value<String?> observaciones;
  final Value<String?> codigo;
  final Value<String?> clave;
  final Value<Uint8List?> foto;
  final Value<int> desde;
  final Value<int?> hasta;
  final Value<DateTime> creado;
  const EstudiantesCompanion({
    this.id = const Value.absent(),
    this.cursoId = const Value.absent(),
    this.apellidos = const Value.absent(),
    this.nombres = const Value.absent(),
    this.dni = const Value.absent(),
    this.apoderado = const Value.absent(),
    this.parentesco = const Value.absent(),
    this.telefono = const Value.absent(),
    this.apoderado2 = const Value.absent(),
    this.parentesco2 = const Value.absent(),
    this.telefono2 = const Value.absent(),
    this.nacimiento = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.codigo = const Value.absent(),
    this.clave = const Value.absent(),
    this.foto = const Value.absent(),
    this.desde = const Value.absent(),
    this.hasta = const Value.absent(),
    this.creado = const Value.absent(),
  });
  EstudiantesCompanion.insert({
    this.id = const Value.absent(),
    required int cursoId,
    required String apellidos,
    required String nombres,
    this.dni = const Value.absent(),
    this.apoderado = const Value.absent(),
    this.parentesco = const Value.absent(),
    this.telefono = const Value.absent(),
    this.apoderado2 = const Value.absent(),
    this.parentesco2 = const Value.absent(),
    this.telefono2 = const Value.absent(),
    this.nacimiento = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.codigo = const Value.absent(),
    this.clave = const Value.absent(),
    this.foto = const Value.absent(),
    this.desde = const Value.absent(),
    this.hasta = const Value.absent(),
    this.creado = const Value.absent(),
  }) : cursoId = Value(cursoId),
       apellidos = Value(apellidos),
       nombres = Value(nombres);
  static Insertable<Estudiante> custom({
    Expression<int>? id,
    Expression<int>? cursoId,
    Expression<String>? apellidos,
    Expression<String>? nombres,
    Expression<String>? dni,
    Expression<String>? apoderado,
    Expression<String>? parentesco,
    Expression<String>? telefono,
    Expression<String>? apoderado2,
    Expression<String>? parentesco2,
    Expression<String>? telefono2,
    Expression<String>? nacimiento,
    Expression<String>? observaciones,
    Expression<String>? codigo,
    Expression<String>? clave,
    Expression<Uint8List>? foto,
    Expression<int>? desde,
    Expression<int>? hasta,
    Expression<DateTime>? creado,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cursoId != null) 'curso_id': cursoId,
      if (apellidos != null) 'apellidos': apellidos,
      if (nombres != null) 'nombres': nombres,
      if (dni != null) 'dni': dni,
      if (apoderado != null) 'apoderado': apoderado,
      if (parentesco != null) 'parentesco': parentesco,
      if (telefono != null) 'telefono': telefono,
      if (apoderado2 != null) 'apoderado2': apoderado2,
      if (parentesco2 != null) 'parentesco2': parentesco2,
      if (telefono2 != null) 'telefono2': telefono2,
      if (nacimiento != null) 'nacimiento': nacimiento,
      if (observaciones != null) 'observaciones': observaciones,
      if (codigo != null) 'codigo': codigo,
      if (clave != null) 'clave': clave,
      if (foto != null) 'foto': foto,
      if (desde != null) 'desde': desde,
      if (hasta != null) 'hasta': hasta,
      if (creado != null) 'creado': creado,
    });
  }

  EstudiantesCompanion copyWith({
    Value<int>? id,
    Value<int>? cursoId,
    Value<String>? apellidos,
    Value<String>? nombres,
    Value<String?>? dni,
    Value<String?>? apoderado,
    Value<String?>? parentesco,
    Value<String?>? telefono,
    Value<String?>? apoderado2,
    Value<String?>? parentesco2,
    Value<String?>? telefono2,
    Value<String?>? nacimiento,
    Value<String?>? observaciones,
    Value<String?>? codigo,
    Value<String?>? clave,
    Value<Uint8List?>? foto,
    Value<int>? desde,
    Value<int?>? hasta,
    Value<DateTime>? creado,
  }) {
    return EstudiantesCompanion(
      id: id ?? this.id,
      cursoId: cursoId ?? this.cursoId,
      apellidos: apellidos ?? this.apellidos,
      nombres: nombres ?? this.nombres,
      dni: dni ?? this.dni,
      apoderado: apoderado ?? this.apoderado,
      parentesco: parentesco ?? this.parentesco,
      telefono: telefono ?? this.telefono,
      apoderado2: apoderado2 ?? this.apoderado2,
      parentesco2: parentesco2 ?? this.parentesco2,
      telefono2: telefono2 ?? this.telefono2,
      nacimiento: nacimiento ?? this.nacimiento,
      observaciones: observaciones ?? this.observaciones,
      codigo: codigo ?? this.codigo,
      clave: clave ?? this.clave,
      foto: foto ?? this.foto,
      desde: desde ?? this.desde,
      hasta: hasta ?? this.hasta,
      creado: creado ?? this.creado,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cursoId.present) {
      map['curso_id'] = Variable<int>(cursoId.value);
    }
    if (apellidos.present) {
      map['apellidos'] = Variable<String>(apellidos.value);
    }
    if (nombres.present) {
      map['nombres'] = Variable<String>(nombres.value);
    }
    if (dni.present) {
      map['dni'] = Variable<String>(dni.value);
    }
    if (apoderado.present) {
      map['apoderado'] = Variable<String>(apoderado.value);
    }
    if (parentesco.present) {
      map['parentesco'] = Variable<String>(parentesco.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (apoderado2.present) {
      map['apoderado2'] = Variable<String>(apoderado2.value);
    }
    if (parentesco2.present) {
      map['parentesco2'] = Variable<String>(parentesco2.value);
    }
    if (telefono2.present) {
      map['telefono2'] = Variable<String>(telefono2.value);
    }
    if (nacimiento.present) {
      map['nacimiento'] = Variable<String>(nacimiento.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (clave.present) {
      map['clave'] = Variable<String>(clave.value);
    }
    if (foto.present) {
      map['foto'] = Variable<Uint8List>(foto.value);
    }
    if (desde.present) {
      map['desde'] = Variable<int>(desde.value);
    }
    if (hasta.present) {
      map['hasta'] = Variable<int>(hasta.value);
    }
    if (creado.present) {
      map['creado'] = Variable<DateTime>(creado.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EstudiantesCompanion(')
          ..write('id: $id, ')
          ..write('cursoId: $cursoId, ')
          ..write('apellidos: $apellidos, ')
          ..write('nombres: $nombres, ')
          ..write('dni: $dni, ')
          ..write('apoderado: $apoderado, ')
          ..write('parentesco: $parentesco, ')
          ..write('telefono: $telefono, ')
          ..write('apoderado2: $apoderado2, ')
          ..write('parentesco2: $parentesco2, ')
          ..write('telefono2: $telefono2, ')
          ..write('nacimiento: $nacimiento, ')
          ..write('observaciones: $observaciones, ')
          ..write('codigo: $codigo, ')
          ..write('clave: $clave, ')
          ..write('foto: $foto, ')
          ..write('desde: $desde, ')
          ..write('hasta: $hasta, ')
          ..write('creado: $creado')
          ..write(')'))
        .toString();
  }
}

class $AsistenciasTable extends Asistencias
    with TableInfo<$AsistenciasTable, Asistencia> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AsistenciasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _estudianteIdMeta = const VerificationMeta(
    'estudianteId',
  );
  @override
  late final GeneratedColumn<int> estudianteId = GeneratedColumn<int>(
    'estudiante_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES estudiantes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<String> fecha = GeneratedColumn<String>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 1,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _motivoMeta = const VerificationMeta('motivo');
  @override
  late final GeneratedColumn<String> motivo = GeneratedColumn<String>(
    'motivo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notaMeta = const VerificationMeta('nota');
  @override
  late final GeneratedColumn<String> nota = GeneratedColumn<String>(
    'nota',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    estudianteId,
    fecha,
    estado,
    motivo,
    nota,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asistencias';
  @override
  VerificationContext validateIntegrity(
    Insertable<Asistencia> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('estudiante_id')) {
      context.handle(
        _estudianteIdMeta,
        estudianteId.isAcceptableOrUnknown(
          data['estudiante_id']!,
          _estudianteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estudianteIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('motivo')) {
      context.handle(
        _motivoMeta,
        motivo.isAcceptableOrUnknown(data['motivo']!, _motivoMeta),
      );
    }
    if (data.containsKey('nota')) {
      context.handle(
        _notaMeta,
        nota.isAcceptableOrUnknown(data['nota']!, _notaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {estudianteId, fecha};
  @override
  Asistencia map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Asistencia(
      estudianteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estudiante_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      motivo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motivo'],
      ),
      nota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nota'],
      ),
    );
  }

  @override
  $AsistenciasTable createAlias(String alias) {
    return $AsistenciasTable(attachedDatabase, alias);
  }
}

class Asistencia extends DataClass implements Insertable<Asistencia> {
  final int estudianteId;
  final String fecha;
  final String estado;
  final String? motivo;
  final String? nota;
  const Asistencia({
    required this.estudianteId,
    required this.fecha,
    required this.estado,
    this.motivo,
    this.nota,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['estudiante_id'] = Variable<int>(estudianteId);
    map['fecha'] = Variable<String>(fecha);
    map['estado'] = Variable<String>(estado);
    if (!nullToAbsent || motivo != null) {
      map['motivo'] = Variable<String>(motivo);
    }
    if (!nullToAbsent || nota != null) {
      map['nota'] = Variable<String>(nota);
    }
    return map;
  }

  AsistenciasCompanion toCompanion(bool nullToAbsent) {
    return AsistenciasCompanion(
      estudianteId: Value(estudianteId),
      fecha: Value(fecha),
      estado: Value(estado),
      motivo: motivo == null && nullToAbsent
          ? const Value.absent()
          : Value(motivo),
      nota: nota == null && nullToAbsent ? const Value.absent() : Value(nota),
    );
  }

  factory Asistencia.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Asistencia(
      estudianteId: serializer.fromJson<int>(json['estudianteId']),
      fecha: serializer.fromJson<String>(json['fecha']),
      estado: serializer.fromJson<String>(json['estado']),
      motivo: serializer.fromJson<String?>(json['motivo']),
      nota: serializer.fromJson<String?>(json['nota']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'estudianteId': serializer.toJson<int>(estudianteId),
      'fecha': serializer.toJson<String>(fecha),
      'estado': serializer.toJson<String>(estado),
      'motivo': serializer.toJson<String?>(motivo),
      'nota': serializer.toJson<String?>(nota),
    };
  }

  Asistencia copyWith({
    int? estudianteId,
    String? fecha,
    String? estado,
    Value<String?> motivo = const Value.absent(),
    Value<String?> nota = const Value.absent(),
  }) => Asistencia(
    estudianteId: estudianteId ?? this.estudianteId,
    fecha: fecha ?? this.fecha,
    estado: estado ?? this.estado,
    motivo: motivo.present ? motivo.value : this.motivo,
    nota: nota.present ? nota.value : this.nota,
  );
  Asistencia copyWithCompanion(AsistenciasCompanion data) {
    return Asistencia(
      estudianteId: data.estudianteId.present
          ? data.estudianteId.value
          : this.estudianteId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      estado: data.estado.present ? data.estado.value : this.estado,
      motivo: data.motivo.present ? data.motivo.value : this.motivo,
      nota: data.nota.present ? data.nota.value : this.nota,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Asistencia(')
          ..write('estudianteId: $estudianteId, ')
          ..write('fecha: $fecha, ')
          ..write('estado: $estado, ')
          ..write('motivo: $motivo, ')
          ..write('nota: $nota')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(estudianteId, fecha, estado, motivo, nota);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Asistencia &&
          other.estudianteId == this.estudianteId &&
          other.fecha == this.fecha &&
          other.estado == this.estado &&
          other.motivo == this.motivo &&
          other.nota == this.nota);
}

class AsistenciasCompanion extends UpdateCompanion<Asistencia> {
  final Value<int> estudianteId;
  final Value<String> fecha;
  final Value<String> estado;
  final Value<String?> motivo;
  final Value<String?> nota;
  final Value<int> rowid;
  const AsistenciasCompanion({
    this.estudianteId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.estado = const Value.absent(),
    this.motivo = const Value.absent(),
    this.nota = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AsistenciasCompanion.insert({
    required int estudianteId,
    required String fecha,
    required String estado,
    this.motivo = const Value.absent(),
    this.nota = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : estudianteId = Value(estudianteId),
       fecha = Value(fecha),
       estado = Value(estado);
  static Insertable<Asistencia> custom({
    Expression<int>? estudianteId,
    Expression<String>? fecha,
    Expression<String>? estado,
    Expression<String>? motivo,
    Expression<String>? nota,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (estudianteId != null) 'estudiante_id': estudianteId,
      if (fecha != null) 'fecha': fecha,
      if (estado != null) 'estado': estado,
      if (motivo != null) 'motivo': motivo,
      if (nota != null) 'nota': nota,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AsistenciasCompanion copyWith({
    Value<int>? estudianteId,
    Value<String>? fecha,
    Value<String>? estado,
    Value<String?>? motivo,
    Value<String?>? nota,
    Value<int>? rowid,
  }) {
    return AsistenciasCompanion(
      estudianteId: estudianteId ?? this.estudianteId,
      fecha: fecha ?? this.fecha,
      estado: estado ?? this.estado,
      motivo: motivo ?? this.motivo,
      nota: nota ?? this.nota,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (estudianteId.present) {
      map['estudiante_id'] = Variable<int>(estudianteId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<String>(fecha.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (motivo.present) {
      map['motivo'] = Variable<String>(motivo.value);
    }
    if (nota.present) {
      map['nota'] = Variable<String>(nota.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AsistenciasCompanion(')
          ..write('estudianteId: $estudianteId, ')
          ..write('fecha: $fecha, ')
          ..write('estado: $estado, ')
          ..write('motivo: $motivo, ')
          ..write('nota: $nota, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotasTable extends Notas with TableInfo<$NotasTable, Nota> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _estudianteIdMeta = const VerificationMeta(
    'estudianteId',
  );
  @override
  late final GeneratedColumn<int> estudianteId = GeneratedColumn<int>(
    'estudiante_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES estudiantes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _periodoMeta = const VerificationMeta(
    'periodo',
  );
  @override
  late final GeneratedColumn<int> periodo = GeneratedColumn<int>(
    'periodo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _competenciaMeta = const VerificationMeta(
    'competencia',
  );
  @override
  late final GeneratedColumn<String> competencia = GeneratedColumn<String>(
    'competencia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notaMeta = const VerificationMeta('nota');
  @override
  late final GeneratedColumn<String> nota = GeneratedColumn<String>(
    'nota',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    estudianteId,
    periodo,
    competencia,
    nota,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Nota> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('estudiante_id')) {
      context.handle(
        _estudianteIdMeta,
        estudianteId.isAcceptableOrUnknown(
          data['estudiante_id']!,
          _estudianteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estudianteIdMeta);
    }
    if (data.containsKey('periodo')) {
      context.handle(
        _periodoMeta,
        periodo.isAcceptableOrUnknown(data['periodo']!, _periodoMeta),
      );
    } else if (isInserting) {
      context.missing(_periodoMeta);
    }
    if (data.containsKey('competencia')) {
      context.handle(
        _competenciaMeta,
        competencia.isAcceptableOrUnknown(
          data['competencia']!,
          _competenciaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_competenciaMeta);
    }
    if (data.containsKey('nota')) {
      context.handle(
        _notaMeta,
        nota.isAcceptableOrUnknown(data['nota']!, _notaMeta),
      );
    } else if (isInserting) {
      context.missing(_notaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Nota map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Nota(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      estudianteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estudiante_id'],
      )!,
      periodo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}periodo'],
      )!,
      competencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}competencia'],
      )!,
      nota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nota'],
      )!,
    );
  }

  @override
  $NotasTable createAlias(String alias) {
    return $NotasTable(attachedDatabase, alias);
  }
}

class Nota extends DataClass implements Insertable<Nota> {
  final int id;
  final int estudianteId;
  final int periodo;
  final String competencia;
  final String nota;
  const Nota({
    required this.id,
    required this.estudianteId,
    required this.periodo,
    required this.competencia,
    required this.nota,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['estudiante_id'] = Variable<int>(estudianteId);
    map['periodo'] = Variable<int>(periodo);
    map['competencia'] = Variable<String>(competencia);
    map['nota'] = Variable<String>(nota);
    return map;
  }

  NotasCompanion toCompanion(bool nullToAbsent) {
    return NotasCompanion(
      id: Value(id),
      estudianteId: Value(estudianteId),
      periodo: Value(periodo),
      competencia: Value(competencia),
      nota: Value(nota),
    );
  }

  factory Nota.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Nota(
      id: serializer.fromJson<int>(json['id']),
      estudianteId: serializer.fromJson<int>(json['estudianteId']),
      periodo: serializer.fromJson<int>(json['periodo']),
      competencia: serializer.fromJson<String>(json['competencia']),
      nota: serializer.fromJson<String>(json['nota']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'estudianteId': serializer.toJson<int>(estudianteId),
      'periodo': serializer.toJson<int>(periodo),
      'competencia': serializer.toJson<String>(competencia),
      'nota': serializer.toJson<String>(nota),
    };
  }

  Nota copyWith({
    int? id,
    int? estudianteId,
    int? periodo,
    String? competencia,
    String? nota,
  }) => Nota(
    id: id ?? this.id,
    estudianteId: estudianteId ?? this.estudianteId,
    periodo: periodo ?? this.periodo,
    competencia: competencia ?? this.competencia,
    nota: nota ?? this.nota,
  );
  Nota copyWithCompanion(NotasCompanion data) {
    return Nota(
      id: data.id.present ? data.id.value : this.id,
      estudianteId: data.estudianteId.present
          ? data.estudianteId.value
          : this.estudianteId,
      periodo: data.periodo.present ? data.periodo.value : this.periodo,
      competencia: data.competencia.present
          ? data.competencia.value
          : this.competencia,
      nota: data.nota.present ? data.nota.value : this.nota,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Nota(')
          ..write('id: $id, ')
          ..write('estudianteId: $estudianteId, ')
          ..write('periodo: $periodo, ')
          ..write('competencia: $competencia, ')
          ..write('nota: $nota')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, estudianteId, periodo, competencia, nota);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Nota &&
          other.id == this.id &&
          other.estudianteId == this.estudianteId &&
          other.periodo == this.periodo &&
          other.competencia == this.competencia &&
          other.nota == this.nota);
}

class NotasCompanion extends UpdateCompanion<Nota> {
  final Value<int> id;
  final Value<int> estudianteId;
  final Value<int> periodo;
  final Value<String> competencia;
  final Value<String> nota;
  const NotasCompanion({
    this.id = const Value.absent(),
    this.estudianteId = const Value.absent(),
    this.periodo = const Value.absent(),
    this.competencia = const Value.absent(),
    this.nota = const Value.absent(),
  });
  NotasCompanion.insert({
    this.id = const Value.absent(),
    required int estudianteId,
    required int periodo,
    required String competencia,
    required String nota,
  }) : estudianteId = Value(estudianteId),
       periodo = Value(periodo),
       competencia = Value(competencia),
       nota = Value(nota);
  static Insertable<Nota> custom({
    Expression<int>? id,
    Expression<int>? estudianteId,
    Expression<int>? periodo,
    Expression<String>? competencia,
    Expression<String>? nota,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (estudianteId != null) 'estudiante_id': estudianteId,
      if (periodo != null) 'periodo': periodo,
      if (competencia != null) 'competencia': competencia,
      if (nota != null) 'nota': nota,
    });
  }

  NotasCompanion copyWith({
    Value<int>? id,
    Value<int>? estudianteId,
    Value<int>? periodo,
    Value<String>? competencia,
    Value<String>? nota,
  }) {
    return NotasCompanion(
      id: id ?? this.id,
      estudianteId: estudianteId ?? this.estudianteId,
      periodo: periodo ?? this.periodo,
      competencia: competencia ?? this.competencia,
      nota: nota ?? this.nota,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (estudianteId.present) {
      map['estudiante_id'] = Variable<int>(estudianteId.value);
    }
    if (periodo.present) {
      map['periodo'] = Variable<int>(periodo.value);
    }
    if (competencia.present) {
      map['competencia'] = Variable<String>(competencia.value);
    }
    if (nota.present) {
      map['nota'] = Variable<String>(nota.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotasCompanion(')
          ..write('id: $id, ')
          ..write('estudianteId: $estudianteId, ')
          ..write('periodo: $periodo, ')
          ..write('competencia: $competencia, ')
          ..write('nota: $nota')
          ..write(')'))
        .toString();
  }
}

class $EventosTable extends Eventos with TableInfo<$EventosTable, Evento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<String> fecha = GeneratedColumn<String>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _horaMeta = const VerificationMeta('hora');
  @override
  late final GeneratedColumn<String> hora = GeneratedColumn<String>(
    'hora',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
    'titulo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _etiquetaMeta = const VerificationMeta(
    'etiqueta',
  );
  @override
  late final GeneratedColumn<String> etiqueta = GeneratedColumn<String>(
    'etiqueta',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('tarea'),
  );
  static const VerificationMeta _recordarMeta = const VerificationMeta(
    'recordar',
  );
  @override
  late final GeneratedColumn<int> recordar = GeneratedColumn<int>(
    'recordar',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repetirMeta = const VerificationMeta(
    'repetir',
  );
  @override
  late final GeneratedColumn<String> repetir = GeneratedColumn<String>(
    'repetir',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cursoIdMeta = const VerificationMeta(
    'cursoId',
  );
  @override
  late final GeneratedColumn<int> cursoId = GeneratedColumn<int>(
    'curso_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detalleMeta = const VerificationMeta(
    'detalle',
  );
  @override
  late final GeneratedColumn<String> detalle = GeneratedColumn<String>(
    'detalle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colegioIdMeta = const VerificationMeta(
    'colegioId',
  );
  @override
  late final GeneratedColumn<int> colegioId = GeneratedColumn<int>(
    'colegio_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fecha,
    hora,
    titulo,
    etiqueta,
    tipo,
    recordar,
    repetir,
    cursoId,
    detalle,
    colegioId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'eventos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Evento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('hora')) {
      context.handle(
        _horaMeta,
        hora.isAcceptableOrUnknown(data['hora']!, _horaMeta),
      );
    }
    if (data.containsKey('titulo')) {
      context.handle(
        _tituloMeta,
        titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta),
      );
    } else if (isInserting) {
      context.missing(_tituloMeta);
    }
    if (data.containsKey('etiqueta')) {
      context.handle(
        _etiquetaMeta,
        etiqueta.isAcceptableOrUnknown(data['etiqueta']!, _etiquetaMeta),
      );
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    }
    if (data.containsKey('recordar')) {
      context.handle(
        _recordarMeta,
        recordar.isAcceptableOrUnknown(data['recordar']!, _recordarMeta),
      );
    }
    if (data.containsKey('repetir')) {
      context.handle(
        _repetirMeta,
        repetir.isAcceptableOrUnknown(data['repetir']!, _repetirMeta),
      );
    }
    if (data.containsKey('curso_id')) {
      context.handle(
        _cursoIdMeta,
        cursoId.isAcceptableOrUnknown(data['curso_id']!, _cursoIdMeta),
      );
    }
    if (data.containsKey('detalle')) {
      context.handle(
        _detalleMeta,
        detalle.isAcceptableOrUnknown(data['detalle']!, _detalleMeta),
      );
    }
    if (data.containsKey('colegio_id')) {
      context.handle(
        _colegioIdMeta,
        colegioId.isAcceptableOrUnknown(data['colegio_id']!, _colegioIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Evento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Evento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha'],
      )!,
      hora: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hora'],
      ),
      titulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titulo'],
      )!,
      etiqueta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etiqueta'],
      ),
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      recordar: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recordar'],
      ),
      repetir: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repetir'],
      ),
      cursoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}curso_id'],
      ),
      detalle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detalle'],
      ),
      colegioId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}colegio_id'],
      ),
    );
  }

  @override
  $EventosTable createAlias(String alias) {
    return $EventosTable(attachedDatabase, alias);
  }
}

class Evento extends DataClass implements Insertable<Evento> {
  final int id;
  final String fecha;
  final String? hora;
  final String titulo;
  final String? etiqueta;
  final String tipo;

  /// Minutos antes para avisar (0 = a la hora); null = sin aviso.
  final int? recordar;

  /// null = una vez · semanal · mensual · anual.
  final String? repetir;
  final int? cursoId;
  final String? detalle;

  /// Colegio del evento; null = para todos (p. ej. un feriado nacional).
  final int? colegioId;
  const Evento({
    required this.id,
    required this.fecha,
    this.hora,
    required this.titulo,
    this.etiqueta,
    required this.tipo,
    this.recordar,
    this.repetir,
    this.cursoId,
    this.detalle,
    this.colegioId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fecha'] = Variable<String>(fecha);
    if (!nullToAbsent || hora != null) {
      map['hora'] = Variable<String>(hora);
    }
    map['titulo'] = Variable<String>(titulo);
    if (!nullToAbsent || etiqueta != null) {
      map['etiqueta'] = Variable<String>(etiqueta);
    }
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || recordar != null) {
      map['recordar'] = Variable<int>(recordar);
    }
    if (!nullToAbsent || repetir != null) {
      map['repetir'] = Variable<String>(repetir);
    }
    if (!nullToAbsent || cursoId != null) {
      map['curso_id'] = Variable<int>(cursoId);
    }
    if (!nullToAbsent || detalle != null) {
      map['detalle'] = Variable<String>(detalle);
    }
    if (!nullToAbsent || colegioId != null) {
      map['colegio_id'] = Variable<int>(colegioId);
    }
    return map;
  }

  EventosCompanion toCompanion(bool nullToAbsent) {
    return EventosCompanion(
      id: Value(id),
      fecha: Value(fecha),
      hora: hora == null && nullToAbsent ? const Value.absent() : Value(hora),
      titulo: Value(titulo),
      etiqueta: etiqueta == null && nullToAbsent
          ? const Value.absent()
          : Value(etiqueta),
      tipo: Value(tipo),
      recordar: recordar == null && nullToAbsent
          ? const Value.absent()
          : Value(recordar),
      repetir: repetir == null && nullToAbsent
          ? const Value.absent()
          : Value(repetir),
      cursoId: cursoId == null && nullToAbsent
          ? const Value.absent()
          : Value(cursoId),
      detalle: detalle == null && nullToAbsent
          ? const Value.absent()
          : Value(detalle),
      colegioId: colegioId == null && nullToAbsent
          ? const Value.absent()
          : Value(colegioId),
    );
  }

  factory Evento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Evento(
      id: serializer.fromJson<int>(json['id']),
      fecha: serializer.fromJson<String>(json['fecha']),
      hora: serializer.fromJson<String?>(json['hora']),
      titulo: serializer.fromJson<String>(json['titulo']),
      etiqueta: serializer.fromJson<String?>(json['etiqueta']),
      tipo: serializer.fromJson<String>(json['tipo']),
      recordar: serializer.fromJson<int?>(json['recordar']),
      repetir: serializer.fromJson<String?>(json['repetir']),
      cursoId: serializer.fromJson<int?>(json['cursoId']),
      detalle: serializer.fromJson<String?>(json['detalle']),
      colegioId: serializer.fromJson<int?>(json['colegioId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fecha': serializer.toJson<String>(fecha),
      'hora': serializer.toJson<String?>(hora),
      'titulo': serializer.toJson<String>(titulo),
      'etiqueta': serializer.toJson<String?>(etiqueta),
      'tipo': serializer.toJson<String>(tipo),
      'recordar': serializer.toJson<int?>(recordar),
      'repetir': serializer.toJson<String?>(repetir),
      'cursoId': serializer.toJson<int?>(cursoId),
      'detalle': serializer.toJson<String?>(detalle),
      'colegioId': serializer.toJson<int?>(colegioId),
    };
  }

  Evento copyWith({
    int? id,
    String? fecha,
    Value<String?> hora = const Value.absent(),
    String? titulo,
    Value<String?> etiqueta = const Value.absent(),
    String? tipo,
    Value<int?> recordar = const Value.absent(),
    Value<String?> repetir = const Value.absent(),
    Value<int?> cursoId = const Value.absent(),
    Value<String?> detalle = const Value.absent(),
    Value<int?> colegioId = const Value.absent(),
  }) => Evento(
    id: id ?? this.id,
    fecha: fecha ?? this.fecha,
    hora: hora.present ? hora.value : this.hora,
    titulo: titulo ?? this.titulo,
    etiqueta: etiqueta.present ? etiqueta.value : this.etiqueta,
    tipo: tipo ?? this.tipo,
    recordar: recordar.present ? recordar.value : this.recordar,
    repetir: repetir.present ? repetir.value : this.repetir,
    cursoId: cursoId.present ? cursoId.value : this.cursoId,
    detalle: detalle.present ? detalle.value : this.detalle,
    colegioId: colegioId.present ? colegioId.value : this.colegioId,
  );
  Evento copyWithCompanion(EventosCompanion data) {
    return Evento(
      id: data.id.present ? data.id.value : this.id,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      hora: data.hora.present ? data.hora.value : this.hora,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      etiqueta: data.etiqueta.present ? data.etiqueta.value : this.etiqueta,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      recordar: data.recordar.present ? data.recordar.value : this.recordar,
      repetir: data.repetir.present ? data.repetir.value : this.repetir,
      cursoId: data.cursoId.present ? data.cursoId.value : this.cursoId,
      detalle: data.detalle.present ? data.detalle.value : this.detalle,
      colegioId: data.colegioId.present ? data.colegioId.value : this.colegioId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Evento(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('hora: $hora, ')
          ..write('titulo: $titulo, ')
          ..write('etiqueta: $etiqueta, ')
          ..write('tipo: $tipo, ')
          ..write('recordar: $recordar, ')
          ..write('repetir: $repetir, ')
          ..write('cursoId: $cursoId, ')
          ..write('detalle: $detalle, ')
          ..write('colegioId: $colegioId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fecha,
    hora,
    titulo,
    etiqueta,
    tipo,
    recordar,
    repetir,
    cursoId,
    detalle,
    colegioId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Evento &&
          other.id == this.id &&
          other.fecha == this.fecha &&
          other.hora == this.hora &&
          other.titulo == this.titulo &&
          other.etiqueta == this.etiqueta &&
          other.tipo == this.tipo &&
          other.recordar == this.recordar &&
          other.repetir == this.repetir &&
          other.cursoId == this.cursoId &&
          other.detalle == this.detalle &&
          other.colegioId == this.colegioId);
}

class EventosCompanion extends UpdateCompanion<Evento> {
  final Value<int> id;
  final Value<String> fecha;
  final Value<String?> hora;
  final Value<String> titulo;
  final Value<String?> etiqueta;
  final Value<String> tipo;
  final Value<int?> recordar;
  final Value<String?> repetir;
  final Value<int?> cursoId;
  final Value<String?> detalle;
  final Value<int?> colegioId;
  const EventosCompanion({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    this.hora = const Value.absent(),
    this.titulo = const Value.absent(),
    this.etiqueta = const Value.absent(),
    this.tipo = const Value.absent(),
    this.recordar = const Value.absent(),
    this.repetir = const Value.absent(),
    this.cursoId = const Value.absent(),
    this.detalle = const Value.absent(),
    this.colegioId = const Value.absent(),
  });
  EventosCompanion.insert({
    this.id = const Value.absent(),
    required String fecha,
    this.hora = const Value.absent(),
    required String titulo,
    this.etiqueta = const Value.absent(),
    this.tipo = const Value.absent(),
    this.recordar = const Value.absent(),
    this.repetir = const Value.absent(),
    this.cursoId = const Value.absent(),
    this.detalle = const Value.absent(),
    this.colegioId = const Value.absent(),
  }) : fecha = Value(fecha),
       titulo = Value(titulo);
  static Insertable<Evento> custom({
    Expression<int>? id,
    Expression<String>? fecha,
    Expression<String>? hora,
    Expression<String>? titulo,
    Expression<String>? etiqueta,
    Expression<String>? tipo,
    Expression<int>? recordar,
    Expression<String>? repetir,
    Expression<int>? cursoId,
    Expression<String>? detalle,
    Expression<int>? colegioId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fecha != null) 'fecha': fecha,
      if (hora != null) 'hora': hora,
      if (titulo != null) 'titulo': titulo,
      if (etiqueta != null) 'etiqueta': etiqueta,
      if (tipo != null) 'tipo': tipo,
      if (recordar != null) 'recordar': recordar,
      if (repetir != null) 'repetir': repetir,
      if (cursoId != null) 'curso_id': cursoId,
      if (detalle != null) 'detalle': detalle,
      if (colegioId != null) 'colegio_id': colegioId,
    });
  }

  EventosCompanion copyWith({
    Value<int>? id,
    Value<String>? fecha,
    Value<String?>? hora,
    Value<String>? titulo,
    Value<String?>? etiqueta,
    Value<String>? tipo,
    Value<int?>? recordar,
    Value<String?>? repetir,
    Value<int?>? cursoId,
    Value<String?>? detalle,
    Value<int?>? colegioId,
  }) {
    return EventosCompanion(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      titulo: titulo ?? this.titulo,
      etiqueta: etiqueta ?? this.etiqueta,
      tipo: tipo ?? this.tipo,
      recordar: recordar ?? this.recordar,
      repetir: repetir ?? this.repetir,
      cursoId: cursoId ?? this.cursoId,
      detalle: detalle ?? this.detalle,
      colegioId: colegioId ?? this.colegioId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<String>(fecha.value);
    }
    if (hora.present) {
      map['hora'] = Variable<String>(hora.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (etiqueta.present) {
      map['etiqueta'] = Variable<String>(etiqueta.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (recordar.present) {
      map['recordar'] = Variable<int>(recordar.value);
    }
    if (repetir.present) {
      map['repetir'] = Variable<String>(repetir.value);
    }
    if (cursoId.present) {
      map['curso_id'] = Variable<int>(cursoId.value);
    }
    if (detalle.present) {
      map['detalle'] = Variable<String>(detalle.value);
    }
    if (colegioId.present) {
      map['colegio_id'] = Variable<int>(colegioId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventosCompanion(')
          ..write('id: $id, ')
          ..write('fecha: $fecha, ')
          ..write('hora: $hora, ')
          ..write('titulo: $titulo, ')
          ..write('etiqueta: $etiqueta, ')
          ..write('tipo: $tipo, ')
          ..write('recordar: $recordar, ')
          ..write('repetir: $repetir, ')
          ..write('cursoId: $cursoId, ')
          ..write('detalle: $detalle, ')
          ..write('colegioId: $colegioId')
          ..write(')'))
        .toString();
  }
}

class $HorariosTable extends Horarios with TableInfo<$HorariosTable, Horario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HorariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cursoIdMeta = const VerificationMeta(
    'cursoId',
  );
  @override
  late final GeneratedColumn<int> cursoId = GeneratedColumn<int>(
    'curso_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cursos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _diaMeta = const VerificationMeta('dia');
  @override
  late final GeneratedColumn<int> dia = GeneratedColumn<int>(
    'dia',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inicioMeta = const VerificationMeta('inicio');
  @override
  late final GeneratedColumn<String> inicio = GeneratedColumn<String>(
    'inicio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finMeta = const VerificationMeta('fin');
  @override
  late final GeneratedColumn<String> fin = GeneratedColumn<String>(
    'fin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, cursoId, dia, inicio, fin];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'horarios';
  @override
  VerificationContext validateIntegrity(
    Insertable<Horario> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('curso_id')) {
      context.handle(
        _cursoIdMeta,
        cursoId.isAcceptableOrUnknown(data['curso_id']!, _cursoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cursoIdMeta);
    }
    if (data.containsKey('dia')) {
      context.handle(
        _diaMeta,
        dia.isAcceptableOrUnknown(data['dia']!, _diaMeta),
      );
    } else if (isInserting) {
      context.missing(_diaMeta);
    }
    if (data.containsKey('inicio')) {
      context.handle(
        _inicioMeta,
        inicio.isAcceptableOrUnknown(data['inicio']!, _inicioMeta),
      );
    } else if (isInserting) {
      context.missing(_inicioMeta);
    }
    if (data.containsKey('fin')) {
      context.handle(
        _finMeta,
        fin.isAcceptableOrUnknown(data['fin']!, _finMeta),
      );
    } else if (isInserting) {
      context.missing(_finMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Horario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Horario(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cursoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}curso_id'],
      )!,
      dia: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dia'],
      )!,
      inicio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inicio'],
      )!,
      fin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fin'],
      )!,
    );
  }

  @override
  $HorariosTable createAlias(String alias) {
    return $HorariosTable(attachedDatabase, alias);
  }
}

class Horario extends DataClass implements Insertable<Horario> {
  final int id;
  final int cursoId;
  final int dia;
  final String inicio;
  final String fin;
  const Horario({
    required this.id,
    required this.cursoId,
    required this.dia,
    required this.inicio,
    required this.fin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['curso_id'] = Variable<int>(cursoId);
    map['dia'] = Variable<int>(dia);
    map['inicio'] = Variable<String>(inicio);
    map['fin'] = Variable<String>(fin);
    return map;
  }

  HorariosCompanion toCompanion(bool nullToAbsent) {
    return HorariosCompanion(
      id: Value(id),
      cursoId: Value(cursoId),
      dia: Value(dia),
      inicio: Value(inicio),
      fin: Value(fin),
    );
  }

  factory Horario.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Horario(
      id: serializer.fromJson<int>(json['id']),
      cursoId: serializer.fromJson<int>(json['cursoId']),
      dia: serializer.fromJson<int>(json['dia']),
      inicio: serializer.fromJson<String>(json['inicio']),
      fin: serializer.fromJson<String>(json['fin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cursoId': serializer.toJson<int>(cursoId),
      'dia': serializer.toJson<int>(dia),
      'inicio': serializer.toJson<String>(inicio),
      'fin': serializer.toJson<String>(fin),
    };
  }

  Horario copyWith({
    int? id,
    int? cursoId,
    int? dia,
    String? inicio,
    String? fin,
  }) => Horario(
    id: id ?? this.id,
    cursoId: cursoId ?? this.cursoId,
    dia: dia ?? this.dia,
    inicio: inicio ?? this.inicio,
    fin: fin ?? this.fin,
  );
  Horario copyWithCompanion(HorariosCompanion data) {
    return Horario(
      id: data.id.present ? data.id.value : this.id,
      cursoId: data.cursoId.present ? data.cursoId.value : this.cursoId,
      dia: data.dia.present ? data.dia.value : this.dia,
      inicio: data.inicio.present ? data.inicio.value : this.inicio,
      fin: data.fin.present ? data.fin.value : this.fin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Horario(')
          ..write('id: $id, ')
          ..write('cursoId: $cursoId, ')
          ..write('dia: $dia, ')
          ..write('inicio: $inicio, ')
          ..write('fin: $fin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cursoId, dia, inicio, fin);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Horario &&
          other.id == this.id &&
          other.cursoId == this.cursoId &&
          other.dia == this.dia &&
          other.inicio == this.inicio &&
          other.fin == this.fin);
}

class HorariosCompanion extends UpdateCompanion<Horario> {
  final Value<int> id;
  final Value<int> cursoId;
  final Value<int> dia;
  final Value<String> inicio;
  final Value<String> fin;
  const HorariosCompanion({
    this.id = const Value.absent(),
    this.cursoId = const Value.absent(),
    this.dia = const Value.absent(),
    this.inicio = const Value.absent(),
    this.fin = const Value.absent(),
  });
  HorariosCompanion.insert({
    this.id = const Value.absent(),
    required int cursoId,
    required int dia,
    required String inicio,
    required String fin,
  }) : cursoId = Value(cursoId),
       dia = Value(dia),
       inicio = Value(inicio),
       fin = Value(fin);
  static Insertable<Horario> custom({
    Expression<int>? id,
    Expression<int>? cursoId,
    Expression<int>? dia,
    Expression<String>? inicio,
    Expression<String>? fin,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cursoId != null) 'curso_id': cursoId,
      if (dia != null) 'dia': dia,
      if (inicio != null) 'inicio': inicio,
      if (fin != null) 'fin': fin,
    });
  }

  HorariosCompanion copyWith({
    Value<int>? id,
    Value<int>? cursoId,
    Value<int>? dia,
    Value<String>? inicio,
    Value<String>? fin,
  }) {
    return HorariosCompanion(
      id: id ?? this.id,
      cursoId: cursoId ?? this.cursoId,
      dia: dia ?? this.dia,
      inicio: inicio ?? this.inicio,
      fin: fin ?? this.fin,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cursoId.present) {
      map['curso_id'] = Variable<int>(cursoId.value);
    }
    if (dia.present) {
      map['dia'] = Variable<int>(dia.value);
    }
    if (inicio.present) {
      map['inicio'] = Variable<String>(inicio.value);
    }
    if (fin.present) {
      map['fin'] = Variable<String>(fin.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HorariosCompanion(')
          ..write('id: $id, ')
          ..write('cursoId: $cursoId, ')
          ..write('dia: $dia, ')
          ..write('inicio: $inicio, ')
          ..write('fin: $fin')
          ..write(')'))
        .toString();
  }
}

class $FranjasTable extends Franjas with TableInfo<$FranjasTable, Franja> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FranjasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _colegioIdMeta = const VerificationMeta(
    'colegioId',
  );
  @override
  late final GeneratedColumn<int> colegioId = GeneratedColumn<int>(
    'colegio_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES colegios (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _inicioMeta = const VerificationMeta('inicio');
  @override
  late final GeneratedColumn<String> inicio = GeneratedColumn<String>(
    'inicio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finMeta = const VerificationMeta('fin');
  @override
  late final GeneratedColumn<String> fin = GeneratedColumn<String>(
    'fin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recreoMeta = const VerificationMeta('recreo');
  @override
  late final GeneratedColumn<bool> recreo = GeneratedColumn<bool>(
    'recreo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("recreo" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, colegioId, inicio, fin, recreo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'franjas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Franja> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('colegio_id')) {
      context.handle(
        _colegioIdMeta,
        colegioId.isAcceptableOrUnknown(data['colegio_id']!, _colegioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_colegioIdMeta);
    }
    if (data.containsKey('inicio')) {
      context.handle(
        _inicioMeta,
        inicio.isAcceptableOrUnknown(data['inicio']!, _inicioMeta),
      );
    } else if (isInserting) {
      context.missing(_inicioMeta);
    }
    if (data.containsKey('fin')) {
      context.handle(
        _finMeta,
        fin.isAcceptableOrUnknown(data['fin']!, _finMeta),
      );
    } else if (isInserting) {
      context.missing(_finMeta);
    }
    if (data.containsKey('recreo')) {
      context.handle(
        _recreoMeta,
        recreo.isAcceptableOrUnknown(data['recreo']!, _recreoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Franja map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Franja(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      colegioId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}colegio_id'],
      )!,
      inicio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inicio'],
      )!,
      fin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fin'],
      )!,
      recreo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}recreo'],
      )!,
    );
  }

  @override
  $FranjasTable createAlias(String alias) {
    return $FranjasTable(attachedDatabase, alias);
  }
}

class Franja extends DataClass implements Insertable<Franja> {
  final int id;
  final int colegioId;
  final String inicio;
  final String fin;
  final bool recreo;
  const Franja({
    required this.id,
    required this.colegioId,
    required this.inicio,
    required this.fin,
    required this.recreo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['colegio_id'] = Variable<int>(colegioId);
    map['inicio'] = Variable<String>(inicio);
    map['fin'] = Variable<String>(fin);
    map['recreo'] = Variable<bool>(recreo);
    return map;
  }

  FranjasCompanion toCompanion(bool nullToAbsent) {
    return FranjasCompanion(
      id: Value(id),
      colegioId: Value(colegioId),
      inicio: Value(inicio),
      fin: Value(fin),
      recreo: Value(recreo),
    );
  }

  factory Franja.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Franja(
      id: serializer.fromJson<int>(json['id']),
      colegioId: serializer.fromJson<int>(json['colegioId']),
      inicio: serializer.fromJson<String>(json['inicio']),
      fin: serializer.fromJson<String>(json['fin']),
      recreo: serializer.fromJson<bool>(json['recreo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'colegioId': serializer.toJson<int>(colegioId),
      'inicio': serializer.toJson<String>(inicio),
      'fin': serializer.toJson<String>(fin),
      'recreo': serializer.toJson<bool>(recreo),
    };
  }

  Franja copyWith({
    int? id,
    int? colegioId,
    String? inicio,
    String? fin,
    bool? recreo,
  }) => Franja(
    id: id ?? this.id,
    colegioId: colegioId ?? this.colegioId,
    inicio: inicio ?? this.inicio,
    fin: fin ?? this.fin,
    recreo: recreo ?? this.recreo,
  );
  Franja copyWithCompanion(FranjasCompanion data) {
    return Franja(
      id: data.id.present ? data.id.value : this.id,
      colegioId: data.colegioId.present ? data.colegioId.value : this.colegioId,
      inicio: data.inicio.present ? data.inicio.value : this.inicio,
      fin: data.fin.present ? data.fin.value : this.fin,
      recreo: data.recreo.present ? data.recreo.value : this.recreo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Franja(')
          ..write('id: $id, ')
          ..write('colegioId: $colegioId, ')
          ..write('inicio: $inicio, ')
          ..write('fin: $fin, ')
          ..write('recreo: $recreo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, colegioId, inicio, fin, recreo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Franja &&
          other.id == this.id &&
          other.colegioId == this.colegioId &&
          other.inicio == this.inicio &&
          other.fin == this.fin &&
          other.recreo == this.recreo);
}

class FranjasCompanion extends UpdateCompanion<Franja> {
  final Value<int> id;
  final Value<int> colegioId;
  final Value<String> inicio;
  final Value<String> fin;
  final Value<bool> recreo;
  const FranjasCompanion({
    this.id = const Value.absent(),
    this.colegioId = const Value.absent(),
    this.inicio = const Value.absent(),
    this.fin = const Value.absent(),
    this.recreo = const Value.absent(),
  });
  FranjasCompanion.insert({
    this.id = const Value.absent(),
    required int colegioId,
    required String inicio,
    required String fin,
    this.recreo = const Value.absent(),
  }) : colegioId = Value(colegioId),
       inicio = Value(inicio),
       fin = Value(fin);
  static Insertable<Franja> custom({
    Expression<int>? id,
    Expression<int>? colegioId,
    Expression<String>? inicio,
    Expression<String>? fin,
    Expression<bool>? recreo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (colegioId != null) 'colegio_id': colegioId,
      if (inicio != null) 'inicio': inicio,
      if (fin != null) 'fin': fin,
      if (recreo != null) 'recreo': recreo,
    });
  }

  FranjasCompanion copyWith({
    Value<int>? id,
    Value<int>? colegioId,
    Value<String>? inicio,
    Value<String>? fin,
    Value<bool>? recreo,
  }) {
    return FranjasCompanion(
      id: id ?? this.id,
      colegioId: colegioId ?? this.colegioId,
      inicio: inicio ?? this.inicio,
      fin: fin ?? this.fin,
      recreo: recreo ?? this.recreo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (colegioId.present) {
      map['colegio_id'] = Variable<int>(colegioId.value);
    }
    if (inicio.present) {
      map['inicio'] = Variable<String>(inicio.value);
    }
    if (fin.present) {
      map['fin'] = Variable<String>(fin.value);
    }
    if (recreo.present) {
      map['recreo'] = Variable<bool>(recreo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FranjasCompanion(')
          ..write('id: $id, ')
          ..write('colegioId: $colegioId, ')
          ..write('inicio: $inicio, ')
          ..write('fin: $fin, ')
          ..write('recreo: $recreo')
          ..write(')'))
        .toString();
  }
}

class $RegistroColumnasTable extends RegistroColumnas
    with TableInfo<$RegistroColumnasTable, RegistroColumna> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegistroColumnasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cursoIdMeta = const VerificationMeta(
    'cursoId',
  );
  @override
  late final GeneratedColumn<int> cursoId = GeneratedColumn<int>(
    'curso_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cursos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _periodoMeta = const VerificationMeta(
    'periodo',
  );
  @override
  late final GeneratedColumn<int> periodo = GeneratedColumn<int>(
    'periodo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temaMeta = const VerificationMeta('tema');
  @override
  late final GeneratedColumn<String> tema = GeneratedColumn<String>(
    'tema',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<String> fecha = GeneratedColumn<String>(
    'fecha',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('nota'),
  );
  static const VerificationMeta _escalaMeta = const VerificationMeta('escala');
  @override
  late final GeneratedColumn<String> escala = GeneratedColumn<String>(
    'escala',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enEquipoMeta = const VerificationMeta(
    'enEquipo',
  );
  @override
  late final GeneratedColumn<bool> enEquipo = GeneratedColumn<bool>(
    'en_equipo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("en_equipo" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _grupoMeta = const VerificationMeta('grupo');
  @override
  late final GeneratedColumn<int> grupo = GeneratedColumn<int>(
    'grupo',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fijadaMeta = const VerificationMeta('fijada');
  @override
  late final GeneratedColumn<bool> fijada = GeneratedColumn<bool>(
    'fijada',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("fijada" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cursoId,
    periodo,
    orden,
    codigo,
    tema,
    fecha,
    tipo,
    escala,
    enEquipo,
    grupo,
    fijada,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'registro_columnas';
  @override
  VerificationContext validateIntegrity(
    Insertable<RegistroColumna> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('curso_id')) {
      context.handle(
        _cursoIdMeta,
        cursoId.isAcceptableOrUnknown(data['curso_id']!, _cursoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cursoIdMeta);
    }
    if (data.containsKey('periodo')) {
      context.handle(
        _periodoMeta,
        periodo.isAcceptableOrUnknown(data['periodo']!, _periodoMeta),
      );
    } else if (isInserting) {
      context.missing(_periodoMeta);
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    } else if (isInserting) {
      context.missing(_ordenMeta);
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    } else if (isInserting) {
      context.missing(_codigoMeta);
    }
    if (data.containsKey('tema')) {
      context.handle(
        _temaMeta,
        tema.isAcceptableOrUnknown(data['tema']!, _temaMeta),
      );
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    }
    if (data.containsKey('escala')) {
      context.handle(
        _escalaMeta,
        escala.isAcceptableOrUnknown(data['escala']!, _escalaMeta),
      );
    }
    if (data.containsKey('en_equipo')) {
      context.handle(
        _enEquipoMeta,
        enEquipo.isAcceptableOrUnknown(data['en_equipo']!, _enEquipoMeta),
      );
    }
    if (data.containsKey('grupo')) {
      context.handle(
        _grupoMeta,
        grupo.isAcceptableOrUnknown(data['grupo']!, _grupoMeta),
      );
    }
    if (data.containsKey('fijada')) {
      context.handle(
        _fijadaMeta,
        fijada.isAcceptableOrUnknown(data['fijada']!, _fijadaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RegistroColumna map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RegistroColumna(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cursoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}curso_id'],
      )!,
      periodo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}periodo'],
      )!,
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      tema: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tema'],
      ),
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha'],
      ),
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      escala: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}escala'],
      ),
      enEquipo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}en_equipo'],
      )!,
      grupo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grupo'],
      ),
      fijada: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}fijada'],
      )!,
    );
  }

  @override
  $RegistroColumnasTable createAlias(String alias) {
    return $RegistroColumnasTable(attachedDatabase, alias);
  }
}

class RegistroColumna extends DataClass implements Insertable<RegistroColumna> {
  final int id;
  final int cursoId;
  final int periodo;
  final int orden;
  final String codigo;
  final String? tema;
  final String? fecha;
  final String tipo;
  final String? escala;
  final bool enEquipo;

  /// Qué equipos usa una columna en equipo (id del grupo de equipos del curso).
  final int? grupo;

  /// Queda fija a la derecha al deslizar (solo una por curso y periodo).
  final bool fijada;
  const RegistroColumna({
    required this.id,
    required this.cursoId,
    required this.periodo,
    required this.orden,
    required this.codigo,
    this.tema,
    this.fecha,
    required this.tipo,
    this.escala,
    required this.enEquipo,
    this.grupo,
    required this.fijada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['curso_id'] = Variable<int>(cursoId);
    map['periodo'] = Variable<int>(periodo);
    map['orden'] = Variable<int>(orden);
    map['codigo'] = Variable<String>(codigo);
    if (!nullToAbsent || tema != null) {
      map['tema'] = Variable<String>(tema);
    }
    if (!nullToAbsent || fecha != null) {
      map['fecha'] = Variable<String>(fecha);
    }
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || escala != null) {
      map['escala'] = Variable<String>(escala);
    }
    map['en_equipo'] = Variable<bool>(enEquipo);
    if (!nullToAbsent || grupo != null) {
      map['grupo'] = Variable<int>(grupo);
    }
    map['fijada'] = Variable<bool>(fijada);
    return map;
  }

  RegistroColumnasCompanion toCompanion(bool nullToAbsent) {
    return RegistroColumnasCompanion(
      id: Value(id),
      cursoId: Value(cursoId),
      periodo: Value(periodo),
      orden: Value(orden),
      codigo: Value(codigo),
      tema: tema == null && nullToAbsent ? const Value.absent() : Value(tema),
      fecha: fecha == null && nullToAbsent
          ? const Value.absent()
          : Value(fecha),
      tipo: Value(tipo),
      escala: escala == null && nullToAbsent
          ? const Value.absent()
          : Value(escala),
      enEquipo: Value(enEquipo),
      grupo: grupo == null && nullToAbsent
          ? const Value.absent()
          : Value(grupo),
      fijada: Value(fijada),
    );
  }

  factory RegistroColumna.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RegistroColumna(
      id: serializer.fromJson<int>(json['id']),
      cursoId: serializer.fromJson<int>(json['cursoId']),
      periodo: serializer.fromJson<int>(json['periodo']),
      orden: serializer.fromJson<int>(json['orden']),
      codigo: serializer.fromJson<String>(json['codigo']),
      tema: serializer.fromJson<String?>(json['tema']),
      fecha: serializer.fromJson<String?>(json['fecha']),
      tipo: serializer.fromJson<String>(json['tipo']),
      escala: serializer.fromJson<String?>(json['escala']),
      enEquipo: serializer.fromJson<bool>(json['enEquipo']),
      grupo: serializer.fromJson<int?>(json['grupo']),
      fijada: serializer.fromJson<bool>(json['fijada']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cursoId': serializer.toJson<int>(cursoId),
      'periodo': serializer.toJson<int>(periodo),
      'orden': serializer.toJson<int>(orden),
      'codigo': serializer.toJson<String>(codigo),
      'tema': serializer.toJson<String?>(tema),
      'fecha': serializer.toJson<String?>(fecha),
      'tipo': serializer.toJson<String>(tipo),
      'escala': serializer.toJson<String?>(escala),
      'enEquipo': serializer.toJson<bool>(enEquipo),
      'grupo': serializer.toJson<int?>(grupo),
      'fijada': serializer.toJson<bool>(fijada),
    };
  }

  RegistroColumna copyWith({
    int? id,
    int? cursoId,
    int? periodo,
    int? orden,
    String? codigo,
    Value<String?> tema = const Value.absent(),
    Value<String?> fecha = const Value.absent(),
    String? tipo,
    Value<String?> escala = const Value.absent(),
    bool? enEquipo,
    Value<int?> grupo = const Value.absent(),
    bool? fijada,
  }) => RegistroColumna(
    id: id ?? this.id,
    cursoId: cursoId ?? this.cursoId,
    periodo: periodo ?? this.periodo,
    orden: orden ?? this.orden,
    codigo: codigo ?? this.codigo,
    tema: tema.present ? tema.value : this.tema,
    fecha: fecha.present ? fecha.value : this.fecha,
    tipo: tipo ?? this.tipo,
    escala: escala.present ? escala.value : this.escala,
    enEquipo: enEquipo ?? this.enEquipo,
    grupo: grupo.present ? grupo.value : this.grupo,
    fijada: fijada ?? this.fijada,
  );
  RegistroColumna copyWithCompanion(RegistroColumnasCompanion data) {
    return RegistroColumna(
      id: data.id.present ? data.id.value : this.id,
      cursoId: data.cursoId.present ? data.cursoId.value : this.cursoId,
      periodo: data.periodo.present ? data.periodo.value : this.periodo,
      orden: data.orden.present ? data.orden.value : this.orden,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      tema: data.tema.present ? data.tema.value : this.tema,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      escala: data.escala.present ? data.escala.value : this.escala,
      enEquipo: data.enEquipo.present ? data.enEquipo.value : this.enEquipo,
      grupo: data.grupo.present ? data.grupo.value : this.grupo,
      fijada: data.fijada.present ? data.fijada.value : this.fijada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RegistroColumna(')
          ..write('id: $id, ')
          ..write('cursoId: $cursoId, ')
          ..write('periodo: $periodo, ')
          ..write('orden: $orden, ')
          ..write('codigo: $codigo, ')
          ..write('tema: $tema, ')
          ..write('fecha: $fecha, ')
          ..write('tipo: $tipo, ')
          ..write('escala: $escala, ')
          ..write('enEquipo: $enEquipo, ')
          ..write('grupo: $grupo, ')
          ..write('fijada: $fijada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cursoId,
    periodo,
    orden,
    codigo,
    tema,
    fecha,
    tipo,
    escala,
    enEquipo,
    grupo,
    fijada,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegistroColumna &&
          other.id == this.id &&
          other.cursoId == this.cursoId &&
          other.periodo == this.periodo &&
          other.orden == this.orden &&
          other.codigo == this.codigo &&
          other.tema == this.tema &&
          other.fecha == this.fecha &&
          other.tipo == this.tipo &&
          other.escala == this.escala &&
          other.enEquipo == this.enEquipo &&
          other.grupo == this.grupo &&
          other.fijada == this.fijada);
}

class RegistroColumnasCompanion extends UpdateCompanion<RegistroColumna> {
  final Value<int> id;
  final Value<int> cursoId;
  final Value<int> periodo;
  final Value<int> orden;
  final Value<String> codigo;
  final Value<String?> tema;
  final Value<String?> fecha;
  final Value<String> tipo;
  final Value<String?> escala;
  final Value<bool> enEquipo;
  final Value<int?> grupo;
  final Value<bool> fijada;
  const RegistroColumnasCompanion({
    this.id = const Value.absent(),
    this.cursoId = const Value.absent(),
    this.periodo = const Value.absent(),
    this.orden = const Value.absent(),
    this.codigo = const Value.absent(),
    this.tema = const Value.absent(),
    this.fecha = const Value.absent(),
    this.tipo = const Value.absent(),
    this.escala = const Value.absent(),
    this.enEquipo = const Value.absent(),
    this.grupo = const Value.absent(),
    this.fijada = const Value.absent(),
  });
  RegistroColumnasCompanion.insert({
    this.id = const Value.absent(),
    required int cursoId,
    required int periodo,
    required int orden,
    required String codigo,
    this.tema = const Value.absent(),
    this.fecha = const Value.absent(),
    this.tipo = const Value.absent(),
    this.escala = const Value.absent(),
    this.enEquipo = const Value.absent(),
    this.grupo = const Value.absent(),
    this.fijada = const Value.absent(),
  }) : cursoId = Value(cursoId),
       periodo = Value(periodo),
       orden = Value(orden),
       codigo = Value(codigo);
  static Insertable<RegistroColumna> custom({
    Expression<int>? id,
    Expression<int>? cursoId,
    Expression<int>? periodo,
    Expression<int>? orden,
    Expression<String>? codigo,
    Expression<String>? tema,
    Expression<String>? fecha,
    Expression<String>? tipo,
    Expression<String>? escala,
    Expression<bool>? enEquipo,
    Expression<int>? grupo,
    Expression<bool>? fijada,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cursoId != null) 'curso_id': cursoId,
      if (periodo != null) 'periodo': periodo,
      if (orden != null) 'orden': orden,
      if (codigo != null) 'codigo': codigo,
      if (tema != null) 'tema': tema,
      if (fecha != null) 'fecha': fecha,
      if (tipo != null) 'tipo': tipo,
      if (escala != null) 'escala': escala,
      if (enEquipo != null) 'en_equipo': enEquipo,
      if (grupo != null) 'grupo': grupo,
      if (fijada != null) 'fijada': fijada,
    });
  }

  RegistroColumnasCompanion copyWith({
    Value<int>? id,
    Value<int>? cursoId,
    Value<int>? periodo,
    Value<int>? orden,
    Value<String>? codigo,
    Value<String?>? tema,
    Value<String?>? fecha,
    Value<String>? tipo,
    Value<String?>? escala,
    Value<bool>? enEquipo,
    Value<int?>? grupo,
    Value<bool>? fijada,
  }) {
    return RegistroColumnasCompanion(
      id: id ?? this.id,
      cursoId: cursoId ?? this.cursoId,
      periodo: periodo ?? this.periodo,
      orden: orden ?? this.orden,
      codigo: codigo ?? this.codigo,
      tema: tema ?? this.tema,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      escala: escala ?? this.escala,
      enEquipo: enEquipo ?? this.enEquipo,
      grupo: grupo ?? this.grupo,
      fijada: fijada ?? this.fijada,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cursoId.present) {
      map['curso_id'] = Variable<int>(cursoId.value);
    }
    if (periodo.present) {
      map['periodo'] = Variable<int>(periodo.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (tema.present) {
      map['tema'] = Variable<String>(tema.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<String>(fecha.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (escala.present) {
      map['escala'] = Variable<String>(escala.value);
    }
    if (enEquipo.present) {
      map['en_equipo'] = Variable<bool>(enEquipo.value);
    }
    if (grupo.present) {
      map['grupo'] = Variable<int>(grupo.value);
    }
    if (fijada.present) {
      map['fijada'] = Variable<bool>(fijada.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RegistroColumnasCompanion(')
          ..write('id: $id, ')
          ..write('cursoId: $cursoId, ')
          ..write('periodo: $periodo, ')
          ..write('orden: $orden, ')
          ..write('codigo: $codigo, ')
          ..write('tema: $tema, ')
          ..write('fecha: $fecha, ')
          ..write('tipo: $tipo, ')
          ..write('escala: $escala, ')
          ..write('enEquipo: $enEquipo, ')
          ..write('grupo: $grupo, ')
          ..write('fijada: $fijada')
          ..write(')'))
        .toString();
  }
}

class $RegistroNotasTable extends RegistroNotas
    with TableInfo<$RegistroNotasTable, RegistroNota> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegistroNotasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _columnaIdMeta = const VerificationMeta(
    'columnaId',
  );
  @override
  late final GeneratedColumn<int> columnaId = GeneratedColumn<int>(
    'columna_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES registro_columnas (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _estudianteIdMeta = const VerificationMeta(
    'estudianteId',
  );
  @override
  late final GeneratedColumn<int> estudianteId = GeneratedColumn<int>(
    'estudiante_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES estudiantes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [columnaId, estudianteId, valor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'registro_notas';
  @override
  VerificationContext validateIntegrity(
    Insertable<RegistroNota> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('columna_id')) {
      context.handle(
        _columnaIdMeta,
        columnaId.isAcceptableOrUnknown(data['columna_id']!, _columnaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_columnaIdMeta);
    }
    if (data.containsKey('estudiante_id')) {
      context.handle(
        _estudianteIdMeta,
        estudianteId.isAcceptableOrUnknown(
          data['estudiante_id']!,
          _estudianteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estudianteIdMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {columnaId, estudianteId};
  @override
  RegistroNota map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RegistroNota(
      columnaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}columna_id'],
      )!,
      estudianteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estudiante_id'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor'],
      )!,
    );
  }

  @override
  $RegistroNotasTable createAlias(String alias) {
    return $RegistroNotasTable(attachedDatabase, alias);
  }
}

class RegistroNota extends DataClass implements Insertable<RegistroNota> {
  final int columnaId;
  final int estudianteId;
  final String valor;
  const RegistroNota({
    required this.columnaId,
    required this.estudianteId,
    required this.valor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['columna_id'] = Variable<int>(columnaId);
    map['estudiante_id'] = Variable<int>(estudianteId);
    map['valor'] = Variable<String>(valor);
    return map;
  }

  RegistroNotasCompanion toCompanion(bool nullToAbsent) {
    return RegistroNotasCompanion(
      columnaId: Value(columnaId),
      estudianteId: Value(estudianteId),
      valor: Value(valor),
    );
  }

  factory RegistroNota.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RegistroNota(
      columnaId: serializer.fromJson<int>(json['columnaId']),
      estudianteId: serializer.fromJson<int>(json['estudianteId']),
      valor: serializer.fromJson<String>(json['valor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'columnaId': serializer.toJson<int>(columnaId),
      'estudianteId': serializer.toJson<int>(estudianteId),
      'valor': serializer.toJson<String>(valor),
    };
  }

  RegistroNota copyWith({int? columnaId, int? estudianteId, String? valor}) =>
      RegistroNota(
        columnaId: columnaId ?? this.columnaId,
        estudianteId: estudianteId ?? this.estudianteId,
        valor: valor ?? this.valor,
      );
  RegistroNota copyWithCompanion(RegistroNotasCompanion data) {
    return RegistroNota(
      columnaId: data.columnaId.present ? data.columnaId.value : this.columnaId,
      estudianteId: data.estudianteId.present
          ? data.estudianteId.value
          : this.estudianteId,
      valor: data.valor.present ? data.valor.value : this.valor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RegistroNota(')
          ..write('columnaId: $columnaId, ')
          ..write('estudianteId: $estudianteId, ')
          ..write('valor: $valor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(columnaId, estudianteId, valor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegistroNota &&
          other.columnaId == this.columnaId &&
          other.estudianteId == this.estudianteId &&
          other.valor == this.valor);
}

class RegistroNotasCompanion extends UpdateCompanion<RegistroNota> {
  final Value<int> columnaId;
  final Value<int> estudianteId;
  final Value<String> valor;
  final Value<int> rowid;
  const RegistroNotasCompanion({
    this.columnaId = const Value.absent(),
    this.estudianteId = const Value.absent(),
    this.valor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RegistroNotasCompanion.insert({
    required int columnaId,
    required int estudianteId,
    required String valor,
    this.rowid = const Value.absent(),
  }) : columnaId = Value(columnaId),
       estudianteId = Value(estudianteId),
       valor = Value(valor);
  static Insertable<RegistroNota> custom({
    Expression<int>? columnaId,
    Expression<int>? estudianteId,
    Expression<String>? valor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (columnaId != null) 'columna_id': columnaId,
      if (estudianteId != null) 'estudiante_id': estudianteId,
      if (valor != null) 'valor': valor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RegistroNotasCompanion copyWith({
    Value<int>? columnaId,
    Value<int>? estudianteId,
    Value<String>? valor,
    Value<int>? rowid,
  }) {
    return RegistroNotasCompanion(
      columnaId: columnaId ?? this.columnaId,
      estudianteId: estudianteId ?? this.estudianteId,
      valor: valor ?? this.valor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (columnaId.present) {
      map['columna_id'] = Variable<int>(columnaId.value);
    }
    if (estudianteId.present) {
      map['estudiante_id'] = Variable<int>(estudianteId.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RegistroNotasCompanion(')
          ..write('columnaId: $columnaId, ')
          ..write('estudianteId: $estudianteId, ')
          ..write('valor: $valor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConductasTable extends Conductas
    with TableInfo<$ConductasTable, Conducta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConductasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _estudianteIdMeta = const VerificationMeta(
    'estudianteId',
  );
  @override
  late final GeneratedColumn<int> estudianteId = GeneratedColumn<int>(
    'estudiante_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES estudiantes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<String> fecha = GeneratedColumn<String>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positivaMeta = const VerificationMeta(
    'positiva',
  );
  @override
  late final GeneratedColumn<bool> positiva = GeneratedColumn<bool>(
    'positiva',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("positiva" IN (0, 1))',
    ),
  );
  static const VerificationMeta _motivoMeta = const VerificationMeta('motivo');
  @override
  late final GeneratedColumn<String> motivo = GeneratedColumn<String>(
    'motivo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    estudianteId,
    fecha,
    positiva,
    motivo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conductas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Conducta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('estudiante_id')) {
      context.handle(
        _estudianteIdMeta,
        estudianteId.isAcceptableOrUnknown(
          data['estudiante_id']!,
          _estudianteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estudianteIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('positiva')) {
      context.handle(
        _positivaMeta,
        positiva.isAcceptableOrUnknown(data['positiva']!, _positivaMeta),
      );
    } else if (isInserting) {
      context.missing(_positivaMeta);
    }
    if (data.containsKey('motivo')) {
      context.handle(
        _motivoMeta,
        motivo.isAcceptableOrUnknown(data['motivo']!, _motivoMeta),
      );
    } else if (isInserting) {
      context.missing(_motivoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conducta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conducta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      estudianteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estudiante_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha'],
      )!,
      positiva: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}positiva'],
      )!,
      motivo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motivo'],
      )!,
    );
  }

  @override
  $ConductasTable createAlias(String alias) {
    return $ConductasTable(attachedDatabase, alias);
  }
}

class Conducta extends DataClass implements Insertable<Conducta> {
  final int id;
  final int estudianteId;
  final String fecha;
  final bool positiva;
  final String motivo;
  const Conducta({
    required this.id,
    required this.estudianteId,
    required this.fecha,
    required this.positiva,
    required this.motivo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['estudiante_id'] = Variable<int>(estudianteId);
    map['fecha'] = Variable<String>(fecha);
    map['positiva'] = Variable<bool>(positiva);
    map['motivo'] = Variable<String>(motivo);
    return map;
  }

  ConductasCompanion toCompanion(bool nullToAbsent) {
    return ConductasCompanion(
      id: Value(id),
      estudianteId: Value(estudianteId),
      fecha: Value(fecha),
      positiva: Value(positiva),
      motivo: Value(motivo),
    );
  }

  factory Conducta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conducta(
      id: serializer.fromJson<int>(json['id']),
      estudianteId: serializer.fromJson<int>(json['estudianteId']),
      fecha: serializer.fromJson<String>(json['fecha']),
      positiva: serializer.fromJson<bool>(json['positiva']),
      motivo: serializer.fromJson<String>(json['motivo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'estudianteId': serializer.toJson<int>(estudianteId),
      'fecha': serializer.toJson<String>(fecha),
      'positiva': serializer.toJson<bool>(positiva),
      'motivo': serializer.toJson<String>(motivo),
    };
  }

  Conducta copyWith({
    int? id,
    int? estudianteId,
    String? fecha,
    bool? positiva,
    String? motivo,
  }) => Conducta(
    id: id ?? this.id,
    estudianteId: estudianteId ?? this.estudianteId,
    fecha: fecha ?? this.fecha,
    positiva: positiva ?? this.positiva,
    motivo: motivo ?? this.motivo,
  );
  Conducta copyWithCompanion(ConductasCompanion data) {
    return Conducta(
      id: data.id.present ? data.id.value : this.id,
      estudianteId: data.estudianteId.present
          ? data.estudianteId.value
          : this.estudianteId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      positiva: data.positiva.present ? data.positiva.value : this.positiva,
      motivo: data.motivo.present ? data.motivo.value : this.motivo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conducta(')
          ..write('id: $id, ')
          ..write('estudianteId: $estudianteId, ')
          ..write('fecha: $fecha, ')
          ..write('positiva: $positiva, ')
          ..write('motivo: $motivo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, estudianteId, fecha, positiva, motivo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conducta &&
          other.id == this.id &&
          other.estudianteId == this.estudianteId &&
          other.fecha == this.fecha &&
          other.positiva == this.positiva &&
          other.motivo == this.motivo);
}

class ConductasCompanion extends UpdateCompanion<Conducta> {
  final Value<int> id;
  final Value<int> estudianteId;
  final Value<String> fecha;
  final Value<bool> positiva;
  final Value<String> motivo;
  const ConductasCompanion({
    this.id = const Value.absent(),
    this.estudianteId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.positiva = const Value.absent(),
    this.motivo = const Value.absent(),
  });
  ConductasCompanion.insert({
    this.id = const Value.absent(),
    required int estudianteId,
    required String fecha,
    required bool positiva,
    required String motivo,
  }) : estudianteId = Value(estudianteId),
       fecha = Value(fecha),
       positiva = Value(positiva),
       motivo = Value(motivo);
  static Insertable<Conducta> custom({
    Expression<int>? id,
    Expression<int>? estudianteId,
    Expression<String>? fecha,
    Expression<bool>? positiva,
    Expression<String>? motivo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (estudianteId != null) 'estudiante_id': estudianteId,
      if (fecha != null) 'fecha': fecha,
      if (positiva != null) 'positiva': positiva,
      if (motivo != null) 'motivo': motivo,
    });
  }

  ConductasCompanion copyWith({
    Value<int>? id,
    Value<int>? estudianteId,
    Value<String>? fecha,
    Value<bool>? positiva,
    Value<String>? motivo,
  }) {
    return ConductasCompanion(
      id: id ?? this.id,
      estudianteId: estudianteId ?? this.estudianteId,
      fecha: fecha ?? this.fecha,
      positiva: positiva ?? this.positiva,
      motivo: motivo ?? this.motivo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (estudianteId.present) {
      map['estudiante_id'] = Variable<int>(estudianteId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<String>(fecha.value);
    }
    if (positiva.present) {
      map['positiva'] = Variable<bool>(positiva.value);
    }
    if (motivo.present) {
      map['motivo'] = Variable<String>(motivo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConductasCompanion(')
          ..write('id: $id, ')
          ..write('estudianteId: $estudianteId, ')
          ..write('fecha: $fecha, ')
          ..write('positiva: $positiva, ')
          ..write('motivo: $motivo')
          ..write(')'))
        .toString();
  }
}

class $PendientesTable extends Pendientes
    with TableInfo<$PendientesTable, Pendiente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendientesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _textoMeta = const VerificationMeta('texto');
  @override
  late final GeneratedColumn<String> texto = GeneratedColumn<String>(
    'texto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hechoMeta = const VerificationMeta('hecho');
  @override
  late final GeneratedColumn<bool> hecho = GeneratedColumn<bool>(
    'hecho',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hecho" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _venceMeta = const VerificationMeta('vence');
  @override
  late final GeneratedColumn<String> vence = GeneratedColumn<String>(
    'vence',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cursoIdMeta = const VerificationMeta(
    'cursoId',
  );
  @override
  late final GeneratedColumn<int> cursoId = GeneratedColumn<int>(
    'curso_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estudianteIdMeta = const VerificationMeta(
    'estudianteId',
  );
  @override
  late final GeneratedColumn<int> estudianteId = GeneratedColumn<int>(
    'estudiante_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadoMeta = const VerificationMeta('creado');
  @override
  late final GeneratedColumn<DateTime> creado = GeneratedColumn<DateTime>(
    'creado',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    texto,
    hecho,
    vence,
    cursoId,
    estudianteId,
    creado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pendientes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pendiente> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('texto')) {
      context.handle(
        _textoMeta,
        texto.isAcceptableOrUnknown(data['texto']!, _textoMeta),
      );
    } else if (isInserting) {
      context.missing(_textoMeta);
    }
    if (data.containsKey('hecho')) {
      context.handle(
        _hechoMeta,
        hecho.isAcceptableOrUnknown(data['hecho']!, _hechoMeta),
      );
    }
    if (data.containsKey('vence')) {
      context.handle(
        _venceMeta,
        vence.isAcceptableOrUnknown(data['vence']!, _venceMeta),
      );
    }
    if (data.containsKey('curso_id')) {
      context.handle(
        _cursoIdMeta,
        cursoId.isAcceptableOrUnknown(data['curso_id']!, _cursoIdMeta),
      );
    }
    if (data.containsKey('estudiante_id')) {
      context.handle(
        _estudianteIdMeta,
        estudianteId.isAcceptableOrUnknown(
          data['estudiante_id']!,
          _estudianteIdMeta,
        ),
      );
    }
    if (data.containsKey('creado')) {
      context.handle(
        _creadoMeta,
        creado.isAcceptableOrUnknown(data['creado']!, _creadoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pendiente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pendiente(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      texto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}texto'],
      )!,
      hecho: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hecho'],
      )!,
      vence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vence'],
      ),
      cursoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}curso_id'],
      ),
      estudianteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estudiante_id'],
      ),
      creado: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado'],
      )!,
    );
  }

  @override
  $PendientesTable createAlias(String alias) {
    return $PendientesTable(attachedDatabase, alias);
  }
}

class Pendiente extends DataClass implements Insertable<Pendiente> {
  final int id;
  final String texto;
  final bool hecho;
  final String? vence;
  final int? cursoId;
  final int? estudianteId;
  final DateTime creado;
  const Pendiente({
    required this.id,
    required this.texto,
    required this.hecho,
    this.vence,
    this.cursoId,
    this.estudianteId,
    required this.creado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['texto'] = Variable<String>(texto);
    map['hecho'] = Variable<bool>(hecho);
    if (!nullToAbsent || vence != null) {
      map['vence'] = Variable<String>(vence);
    }
    if (!nullToAbsent || cursoId != null) {
      map['curso_id'] = Variable<int>(cursoId);
    }
    if (!nullToAbsent || estudianteId != null) {
      map['estudiante_id'] = Variable<int>(estudianteId);
    }
    map['creado'] = Variable<DateTime>(creado);
    return map;
  }

  PendientesCompanion toCompanion(bool nullToAbsent) {
    return PendientesCompanion(
      id: Value(id),
      texto: Value(texto),
      hecho: Value(hecho),
      vence: vence == null && nullToAbsent
          ? const Value.absent()
          : Value(vence),
      cursoId: cursoId == null && nullToAbsent
          ? const Value.absent()
          : Value(cursoId),
      estudianteId: estudianteId == null && nullToAbsent
          ? const Value.absent()
          : Value(estudianteId),
      creado: Value(creado),
    );
  }

  factory Pendiente.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pendiente(
      id: serializer.fromJson<int>(json['id']),
      texto: serializer.fromJson<String>(json['texto']),
      hecho: serializer.fromJson<bool>(json['hecho']),
      vence: serializer.fromJson<String?>(json['vence']),
      cursoId: serializer.fromJson<int?>(json['cursoId']),
      estudianteId: serializer.fromJson<int?>(json['estudianteId']),
      creado: serializer.fromJson<DateTime>(json['creado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'texto': serializer.toJson<String>(texto),
      'hecho': serializer.toJson<bool>(hecho),
      'vence': serializer.toJson<String?>(vence),
      'cursoId': serializer.toJson<int?>(cursoId),
      'estudianteId': serializer.toJson<int?>(estudianteId),
      'creado': serializer.toJson<DateTime>(creado),
    };
  }

  Pendiente copyWith({
    int? id,
    String? texto,
    bool? hecho,
    Value<String?> vence = const Value.absent(),
    Value<int?> cursoId = const Value.absent(),
    Value<int?> estudianteId = const Value.absent(),
    DateTime? creado,
  }) => Pendiente(
    id: id ?? this.id,
    texto: texto ?? this.texto,
    hecho: hecho ?? this.hecho,
    vence: vence.present ? vence.value : this.vence,
    cursoId: cursoId.present ? cursoId.value : this.cursoId,
    estudianteId: estudianteId.present ? estudianteId.value : this.estudianteId,
    creado: creado ?? this.creado,
  );
  Pendiente copyWithCompanion(PendientesCompanion data) {
    return Pendiente(
      id: data.id.present ? data.id.value : this.id,
      texto: data.texto.present ? data.texto.value : this.texto,
      hecho: data.hecho.present ? data.hecho.value : this.hecho,
      vence: data.vence.present ? data.vence.value : this.vence,
      cursoId: data.cursoId.present ? data.cursoId.value : this.cursoId,
      estudianteId: data.estudianteId.present
          ? data.estudianteId.value
          : this.estudianteId,
      creado: data.creado.present ? data.creado.value : this.creado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pendiente(')
          ..write('id: $id, ')
          ..write('texto: $texto, ')
          ..write('hecho: $hecho, ')
          ..write('vence: $vence, ')
          ..write('cursoId: $cursoId, ')
          ..write('estudianteId: $estudianteId, ')
          ..write('creado: $creado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, texto, hecho, vence, cursoId, estudianteId, creado);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pendiente &&
          other.id == this.id &&
          other.texto == this.texto &&
          other.hecho == this.hecho &&
          other.vence == this.vence &&
          other.cursoId == this.cursoId &&
          other.estudianteId == this.estudianteId &&
          other.creado == this.creado);
}

class PendientesCompanion extends UpdateCompanion<Pendiente> {
  final Value<int> id;
  final Value<String> texto;
  final Value<bool> hecho;
  final Value<String?> vence;
  final Value<int?> cursoId;
  final Value<int?> estudianteId;
  final Value<DateTime> creado;
  const PendientesCompanion({
    this.id = const Value.absent(),
    this.texto = const Value.absent(),
    this.hecho = const Value.absent(),
    this.vence = const Value.absent(),
    this.cursoId = const Value.absent(),
    this.estudianteId = const Value.absent(),
    this.creado = const Value.absent(),
  });
  PendientesCompanion.insert({
    this.id = const Value.absent(),
    required String texto,
    this.hecho = const Value.absent(),
    this.vence = const Value.absent(),
    this.cursoId = const Value.absent(),
    this.estudianteId = const Value.absent(),
    this.creado = const Value.absent(),
  }) : texto = Value(texto);
  static Insertable<Pendiente> custom({
    Expression<int>? id,
    Expression<String>? texto,
    Expression<bool>? hecho,
    Expression<String>? vence,
    Expression<int>? cursoId,
    Expression<int>? estudianteId,
    Expression<DateTime>? creado,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (texto != null) 'texto': texto,
      if (hecho != null) 'hecho': hecho,
      if (vence != null) 'vence': vence,
      if (cursoId != null) 'curso_id': cursoId,
      if (estudianteId != null) 'estudiante_id': estudianteId,
      if (creado != null) 'creado': creado,
    });
  }

  PendientesCompanion copyWith({
    Value<int>? id,
    Value<String>? texto,
    Value<bool>? hecho,
    Value<String?>? vence,
    Value<int?>? cursoId,
    Value<int?>? estudianteId,
    Value<DateTime>? creado,
  }) {
    return PendientesCompanion(
      id: id ?? this.id,
      texto: texto ?? this.texto,
      hecho: hecho ?? this.hecho,
      vence: vence ?? this.vence,
      cursoId: cursoId ?? this.cursoId,
      estudianteId: estudianteId ?? this.estudianteId,
      creado: creado ?? this.creado,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (texto.present) {
      map['texto'] = Variable<String>(texto.value);
    }
    if (hecho.present) {
      map['hecho'] = Variable<bool>(hecho.value);
    }
    if (vence.present) {
      map['vence'] = Variable<String>(vence.value);
    }
    if (cursoId.present) {
      map['curso_id'] = Variable<int>(cursoId.value);
    }
    if (estudianteId.present) {
      map['estudiante_id'] = Variable<int>(estudianteId.value);
    }
    if (creado.present) {
      map['creado'] = Variable<DateTime>(creado.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendientesCompanion(')
          ..write('id: $id, ')
          ..write('texto: $texto, ')
          ..write('hecho: $hecho, ')
          ..write('vence: $vence, ')
          ..write('cursoId: $cursoId, ')
          ..write('estudianteId: $estudianteId, ')
          ..write('creado: $creado')
          ..write(')'))
        .toString();
  }
}

class $AnecdotasTable extends Anecdotas
    with TableInfo<$AnecdotasTable, Anecdota> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AnecdotasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _estudianteIdMeta = const VerificationMeta(
    'estudianteId',
  );
  @override
  late final GeneratedColumn<int> estudianteId = GeneratedColumn<int>(
    'estudiante_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES estudiantes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<String> fecha = GeneratedColumn<String>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('neutro'),
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('otro'),
  );
  static const VerificationMeta _textoMeta = const VerificationMeta('texto');
  @override
  late final GeneratedColumn<String> texto = GeneratedColumn<String>(
    'texto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fotoMeta = const VerificationMeta('foto');
  @override
  late final GeneratedColumn<Uint8List> foto = GeneratedColumn<Uint8List>(
    'foto',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _apoderadoMeta = const VerificationMeta(
    'apoderado',
  );
  @override
  late final GeneratedColumn<String> apoderado = GeneratedColumn<String>(
    'apoderado',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _acuerdosMeta = const VerificationMeta(
    'acuerdos',
  );
  @override
  late final GeneratedColumn<String> acuerdos = GeneratedColumn<String>(
    'acuerdos',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seguimientoMeta = const VerificationMeta(
    'seguimiento',
  );
  @override
  late final GeneratedColumn<String> seguimiento = GeneratedColumn<String>(
    'seguimiento',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    estudianteId,
    fecha,
    tipo,
    categoria,
    texto,
    foto,
    apoderado,
    acuerdos,
    seguimiento,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'anecdotas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Anecdota> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('estudiante_id')) {
      context.handle(
        _estudianteIdMeta,
        estudianteId.isAcceptableOrUnknown(
          data['estudiante_id']!,
          _estudianteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estudianteIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    }
    if (data.containsKey('texto')) {
      context.handle(
        _textoMeta,
        texto.isAcceptableOrUnknown(data['texto']!, _textoMeta),
      );
    } else if (isInserting) {
      context.missing(_textoMeta);
    }
    if (data.containsKey('foto')) {
      context.handle(
        _fotoMeta,
        foto.isAcceptableOrUnknown(data['foto']!, _fotoMeta),
      );
    }
    if (data.containsKey('apoderado')) {
      context.handle(
        _apoderadoMeta,
        apoderado.isAcceptableOrUnknown(data['apoderado']!, _apoderadoMeta),
      );
    }
    if (data.containsKey('acuerdos')) {
      context.handle(
        _acuerdosMeta,
        acuerdos.isAcceptableOrUnknown(data['acuerdos']!, _acuerdosMeta),
      );
    }
    if (data.containsKey('seguimiento')) {
      context.handle(
        _seguimientoMeta,
        seguimiento.isAcceptableOrUnknown(
          data['seguimiento']!,
          _seguimientoMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Anecdota map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Anecdota(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      estudianteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estudiante_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      )!,
      texto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}texto'],
      )!,
      foto: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}foto'],
      ),
      apoderado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apoderado'],
      ),
      acuerdos: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}acuerdos'],
      ),
      seguimiento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seguimiento'],
      ),
    );
  }

  @override
  $AnecdotasTable createAlias(String alias) {
    return $AnecdotasTable(attachedDatabase, alias);
  }
}

class Anecdota extends DataClass implements Insertable<Anecdota> {
  final int id;
  final int estudianteId;
  final String fecha;
  final String tipo;
  final String categoria;
  final String texto;
  final Uint8List? foto;
  final String? apoderado;
  final String? acuerdos;
  final String? seguimiento;
  const Anecdota({
    required this.id,
    required this.estudianteId,
    required this.fecha,
    required this.tipo,
    required this.categoria,
    required this.texto,
    this.foto,
    this.apoderado,
    this.acuerdos,
    this.seguimiento,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['estudiante_id'] = Variable<int>(estudianteId);
    map['fecha'] = Variable<String>(fecha);
    map['tipo'] = Variable<String>(tipo);
    map['categoria'] = Variable<String>(categoria);
    map['texto'] = Variable<String>(texto);
    if (!nullToAbsent || foto != null) {
      map['foto'] = Variable<Uint8List>(foto);
    }
    if (!nullToAbsent || apoderado != null) {
      map['apoderado'] = Variable<String>(apoderado);
    }
    if (!nullToAbsent || acuerdos != null) {
      map['acuerdos'] = Variable<String>(acuerdos);
    }
    if (!nullToAbsent || seguimiento != null) {
      map['seguimiento'] = Variable<String>(seguimiento);
    }
    return map;
  }

  AnecdotasCompanion toCompanion(bool nullToAbsent) {
    return AnecdotasCompanion(
      id: Value(id),
      estudianteId: Value(estudianteId),
      fecha: Value(fecha),
      tipo: Value(tipo),
      categoria: Value(categoria),
      texto: Value(texto),
      foto: foto == null && nullToAbsent ? const Value.absent() : Value(foto),
      apoderado: apoderado == null && nullToAbsent
          ? const Value.absent()
          : Value(apoderado),
      acuerdos: acuerdos == null && nullToAbsent
          ? const Value.absent()
          : Value(acuerdos),
      seguimiento: seguimiento == null && nullToAbsent
          ? const Value.absent()
          : Value(seguimiento),
    );
  }

  factory Anecdota.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Anecdota(
      id: serializer.fromJson<int>(json['id']),
      estudianteId: serializer.fromJson<int>(json['estudianteId']),
      fecha: serializer.fromJson<String>(json['fecha']),
      tipo: serializer.fromJson<String>(json['tipo']),
      categoria: serializer.fromJson<String>(json['categoria']),
      texto: serializer.fromJson<String>(json['texto']),
      foto: serializer.fromJson<Uint8List?>(json['foto']),
      apoderado: serializer.fromJson<String?>(json['apoderado']),
      acuerdos: serializer.fromJson<String?>(json['acuerdos']),
      seguimiento: serializer.fromJson<String?>(json['seguimiento']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'estudianteId': serializer.toJson<int>(estudianteId),
      'fecha': serializer.toJson<String>(fecha),
      'tipo': serializer.toJson<String>(tipo),
      'categoria': serializer.toJson<String>(categoria),
      'texto': serializer.toJson<String>(texto),
      'foto': serializer.toJson<Uint8List?>(foto),
      'apoderado': serializer.toJson<String?>(apoderado),
      'acuerdos': serializer.toJson<String?>(acuerdos),
      'seguimiento': serializer.toJson<String?>(seguimiento),
    };
  }

  Anecdota copyWith({
    int? id,
    int? estudianteId,
    String? fecha,
    String? tipo,
    String? categoria,
    String? texto,
    Value<Uint8List?> foto = const Value.absent(),
    Value<String?> apoderado = const Value.absent(),
    Value<String?> acuerdos = const Value.absent(),
    Value<String?> seguimiento = const Value.absent(),
  }) => Anecdota(
    id: id ?? this.id,
    estudianteId: estudianteId ?? this.estudianteId,
    fecha: fecha ?? this.fecha,
    tipo: tipo ?? this.tipo,
    categoria: categoria ?? this.categoria,
    texto: texto ?? this.texto,
    foto: foto.present ? foto.value : this.foto,
    apoderado: apoderado.present ? apoderado.value : this.apoderado,
    acuerdos: acuerdos.present ? acuerdos.value : this.acuerdos,
    seguimiento: seguimiento.present ? seguimiento.value : this.seguimiento,
  );
  Anecdota copyWithCompanion(AnecdotasCompanion data) {
    return Anecdota(
      id: data.id.present ? data.id.value : this.id,
      estudianteId: data.estudianteId.present
          ? data.estudianteId.value
          : this.estudianteId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      texto: data.texto.present ? data.texto.value : this.texto,
      foto: data.foto.present ? data.foto.value : this.foto,
      apoderado: data.apoderado.present ? data.apoderado.value : this.apoderado,
      acuerdos: data.acuerdos.present ? data.acuerdos.value : this.acuerdos,
      seguimiento: data.seguimiento.present
          ? data.seguimiento.value
          : this.seguimiento,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Anecdota(')
          ..write('id: $id, ')
          ..write('estudianteId: $estudianteId, ')
          ..write('fecha: $fecha, ')
          ..write('tipo: $tipo, ')
          ..write('categoria: $categoria, ')
          ..write('texto: $texto, ')
          ..write('foto: $foto, ')
          ..write('apoderado: $apoderado, ')
          ..write('acuerdos: $acuerdos, ')
          ..write('seguimiento: $seguimiento')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    estudianteId,
    fecha,
    tipo,
    categoria,
    texto,
    $driftBlobEquality.hash(foto),
    apoderado,
    acuerdos,
    seguimiento,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Anecdota &&
          other.id == this.id &&
          other.estudianteId == this.estudianteId &&
          other.fecha == this.fecha &&
          other.tipo == this.tipo &&
          other.categoria == this.categoria &&
          other.texto == this.texto &&
          $driftBlobEquality.equals(other.foto, this.foto) &&
          other.apoderado == this.apoderado &&
          other.acuerdos == this.acuerdos &&
          other.seguimiento == this.seguimiento);
}

class AnecdotasCompanion extends UpdateCompanion<Anecdota> {
  final Value<int> id;
  final Value<int> estudianteId;
  final Value<String> fecha;
  final Value<String> tipo;
  final Value<String> categoria;
  final Value<String> texto;
  final Value<Uint8List?> foto;
  final Value<String?> apoderado;
  final Value<String?> acuerdos;
  final Value<String?> seguimiento;
  const AnecdotasCompanion({
    this.id = const Value.absent(),
    this.estudianteId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.tipo = const Value.absent(),
    this.categoria = const Value.absent(),
    this.texto = const Value.absent(),
    this.foto = const Value.absent(),
    this.apoderado = const Value.absent(),
    this.acuerdos = const Value.absent(),
    this.seguimiento = const Value.absent(),
  });
  AnecdotasCompanion.insert({
    this.id = const Value.absent(),
    required int estudianteId,
    required String fecha,
    this.tipo = const Value.absent(),
    this.categoria = const Value.absent(),
    required String texto,
    this.foto = const Value.absent(),
    this.apoderado = const Value.absent(),
    this.acuerdos = const Value.absent(),
    this.seguimiento = const Value.absent(),
  }) : estudianteId = Value(estudianteId),
       fecha = Value(fecha),
       texto = Value(texto);
  static Insertable<Anecdota> custom({
    Expression<int>? id,
    Expression<int>? estudianteId,
    Expression<String>? fecha,
    Expression<String>? tipo,
    Expression<String>? categoria,
    Expression<String>? texto,
    Expression<Uint8List>? foto,
    Expression<String>? apoderado,
    Expression<String>? acuerdos,
    Expression<String>? seguimiento,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (estudianteId != null) 'estudiante_id': estudianteId,
      if (fecha != null) 'fecha': fecha,
      if (tipo != null) 'tipo': tipo,
      if (categoria != null) 'categoria': categoria,
      if (texto != null) 'texto': texto,
      if (foto != null) 'foto': foto,
      if (apoderado != null) 'apoderado': apoderado,
      if (acuerdos != null) 'acuerdos': acuerdos,
      if (seguimiento != null) 'seguimiento': seguimiento,
    });
  }

  AnecdotasCompanion copyWith({
    Value<int>? id,
    Value<int>? estudianteId,
    Value<String>? fecha,
    Value<String>? tipo,
    Value<String>? categoria,
    Value<String>? texto,
    Value<Uint8List?>? foto,
    Value<String?>? apoderado,
    Value<String?>? acuerdos,
    Value<String?>? seguimiento,
  }) {
    return AnecdotasCompanion(
      id: id ?? this.id,
      estudianteId: estudianteId ?? this.estudianteId,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      categoria: categoria ?? this.categoria,
      texto: texto ?? this.texto,
      foto: foto ?? this.foto,
      apoderado: apoderado ?? this.apoderado,
      acuerdos: acuerdos ?? this.acuerdos,
      seguimiento: seguimiento ?? this.seguimiento,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (estudianteId.present) {
      map['estudiante_id'] = Variable<int>(estudianteId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<String>(fecha.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (texto.present) {
      map['texto'] = Variable<String>(texto.value);
    }
    if (foto.present) {
      map['foto'] = Variable<Uint8List>(foto.value);
    }
    if (apoderado.present) {
      map['apoderado'] = Variable<String>(apoderado.value);
    }
    if (acuerdos.present) {
      map['acuerdos'] = Variable<String>(acuerdos.value);
    }
    if (seguimiento.present) {
      map['seguimiento'] = Variable<String>(seguimiento.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AnecdotasCompanion(')
          ..write('id: $id, ')
          ..write('estudianteId: $estudianteId, ')
          ..write('fecha: $fecha, ')
          ..write('tipo: $tipo, ')
          ..write('categoria: $categoria, ')
          ..write('texto: $texto, ')
          ..write('foto: $foto, ')
          ..write('apoderado: $apoderado, ')
          ..write('acuerdos: $acuerdos, ')
          ..write('seguimiento: $seguimiento')
          ..write(')'))
        .toString();
  }
}

class $ClasesDiarioTable extends ClasesDiario
    with TableInfo<$ClasesDiarioTable, ClaseDiario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClasesDiarioTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cursoIdMeta = const VerificationMeta(
    'cursoId',
  );
  @override
  late final GeneratedColumn<int> cursoId = GeneratedColumn<int>(
    'curso_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cursos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<String> fecha = GeneratedColumn<String>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trabajadoMeta = const VerificationMeta(
    'trabajado',
  );
  @override
  late final GeneratedColumn<String> trabajado = GeneratedColumn<String>(
    'trabajado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _faltaMeta = const VerificationMeta('falta');
  @override
  late final GeneratedColumn<String> falta = GeneratedColumn<String>(
    'falta',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _materialMeta = const VerificationMeta(
    'material',
  );
  @override
  late final GeneratedColumn<String> material = GeneratedColumn<String>(
    'material',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cursoId,
    fecha,
    trabajado,
    falta,
    material,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clases_diario';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClaseDiario> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('curso_id')) {
      context.handle(
        _cursoIdMeta,
        cursoId.isAcceptableOrUnknown(data['curso_id']!, _cursoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cursoIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('trabajado')) {
      context.handle(
        _trabajadoMeta,
        trabajado.isAcceptableOrUnknown(data['trabajado']!, _trabajadoMeta),
      );
    } else if (isInserting) {
      context.missing(_trabajadoMeta);
    }
    if (data.containsKey('falta')) {
      context.handle(
        _faltaMeta,
        falta.isAcceptableOrUnknown(data['falta']!, _faltaMeta),
      );
    }
    if (data.containsKey('material')) {
      context.handle(
        _materialMeta,
        material.isAcceptableOrUnknown(data['material']!, _materialMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClaseDiario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClaseDiario(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cursoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}curso_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha'],
      )!,
      trabajado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trabajado'],
      )!,
      falta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}falta'],
      ),
      material: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material'],
      ),
    );
  }

  @override
  $ClasesDiarioTable createAlias(String alias) {
    return $ClasesDiarioTable(attachedDatabase, alias);
  }
}

class ClaseDiario extends DataClass implements Insertable<ClaseDiario> {
  final int id;
  final int cursoId;
  final String fecha;
  final String trabajado;
  final String? falta;
  final String? material;
  const ClaseDiario({
    required this.id,
    required this.cursoId,
    required this.fecha,
    required this.trabajado,
    this.falta,
    this.material,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['curso_id'] = Variable<int>(cursoId);
    map['fecha'] = Variable<String>(fecha);
    map['trabajado'] = Variable<String>(trabajado);
    if (!nullToAbsent || falta != null) {
      map['falta'] = Variable<String>(falta);
    }
    if (!nullToAbsent || material != null) {
      map['material'] = Variable<String>(material);
    }
    return map;
  }

  ClasesDiarioCompanion toCompanion(bool nullToAbsent) {
    return ClasesDiarioCompanion(
      id: Value(id),
      cursoId: Value(cursoId),
      fecha: Value(fecha),
      trabajado: Value(trabajado),
      falta: falta == null && nullToAbsent
          ? const Value.absent()
          : Value(falta),
      material: material == null && nullToAbsent
          ? const Value.absent()
          : Value(material),
    );
  }

  factory ClaseDiario.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClaseDiario(
      id: serializer.fromJson<int>(json['id']),
      cursoId: serializer.fromJson<int>(json['cursoId']),
      fecha: serializer.fromJson<String>(json['fecha']),
      trabajado: serializer.fromJson<String>(json['trabajado']),
      falta: serializer.fromJson<String?>(json['falta']),
      material: serializer.fromJson<String?>(json['material']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cursoId': serializer.toJson<int>(cursoId),
      'fecha': serializer.toJson<String>(fecha),
      'trabajado': serializer.toJson<String>(trabajado),
      'falta': serializer.toJson<String?>(falta),
      'material': serializer.toJson<String?>(material),
    };
  }

  ClaseDiario copyWith({
    int? id,
    int? cursoId,
    String? fecha,
    String? trabajado,
    Value<String?> falta = const Value.absent(),
    Value<String?> material = const Value.absent(),
  }) => ClaseDiario(
    id: id ?? this.id,
    cursoId: cursoId ?? this.cursoId,
    fecha: fecha ?? this.fecha,
    trabajado: trabajado ?? this.trabajado,
    falta: falta.present ? falta.value : this.falta,
    material: material.present ? material.value : this.material,
  );
  ClaseDiario copyWithCompanion(ClasesDiarioCompanion data) {
    return ClaseDiario(
      id: data.id.present ? data.id.value : this.id,
      cursoId: data.cursoId.present ? data.cursoId.value : this.cursoId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      trabajado: data.trabajado.present ? data.trabajado.value : this.trabajado,
      falta: data.falta.present ? data.falta.value : this.falta,
      material: data.material.present ? data.material.value : this.material,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClaseDiario(')
          ..write('id: $id, ')
          ..write('cursoId: $cursoId, ')
          ..write('fecha: $fecha, ')
          ..write('trabajado: $trabajado, ')
          ..write('falta: $falta, ')
          ..write('material: $material')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cursoId, fecha, trabajado, falta, material);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClaseDiario &&
          other.id == this.id &&
          other.cursoId == this.cursoId &&
          other.fecha == this.fecha &&
          other.trabajado == this.trabajado &&
          other.falta == this.falta &&
          other.material == this.material);
}

class ClasesDiarioCompanion extends UpdateCompanion<ClaseDiario> {
  final Value<int> id;
  final Value<int> cursoId;
  final Value<String> fecha;
  final Value<String> trabajado;
  final Value<String?> falta;
  final Value<String?> material;
  const ClasesDiarioCompanion({
    this.id = const Value.absent(),
    this.cursoId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.trabajado = const Value.absent(),
    this.falta = const Value.absent(),
    this.material = const Value.absent(),
  });
  ClasesDiarioCompanion.insert({
    this.id = const Value.absent(),
    required int cursoId,
    required String fecha,
    required String trabajado,
    this.falta = const Value.absent(),
    this.material = const Value.absent(),
  }) : cursoId = Value(cursoId),
       fecha = Value(fecha),
       trabajado = Value(trabajado);
  static Insertable<ClaseDiario> custom({
    Expression<int>? id,
    Expression<int>? cursoId,
    Expression<String>? fecha,
    Expression<String>? trabajado,
    Expression<String>? falta,
    Expression<String>? material,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cursoId != null) 'curso_id': cursoId,
      if (fecha != null) 'fecha': fecha,
      if (trabajado != null) 'trabajado': trabajado,
      if (falta != null) 'falta': falta,
      if (material != null) 'material': material,
    });
  }

  ClasesDiarioCompanion copyWith({
    Value<int>? id,
    Value<int>? cursoId,
    Value<String>? fecha,
    Value<String>? trabajado,
    Value<String?>? falta,
    Value<String?>? material,
  }) {
    return ClasesDiarioCompanion(
      id: id ?? this.id,
      cursoId: cursoId ?? this.cursoId,
      fecha: fecha ?? this.fecha,
      trabajado: trabajado ?? this.trabajado,
      falta: falta ?? this.falta,
      material: material ?? this.material,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cursoId.present) {
      map['curso_id'] = Variable<int>(cursoId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<String>(fecha.value);
    }
    if (trabajado.present) {
      map['trabajado'] = Variable<String>(trabajado.value);
    }
    if (falta.present) {
      map['falta'] = Variable<String>(falta.value);
    }
    if (material.present) {
      map['material'] = Variable<String>(material.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClasesDiarioCompanion(')
          ..write('id: $id, ')
          ..write('cursoId: $cursoId, ')
          ..write('fecha: $fecha, ')
          ..write('trabajado: $trabajado, ')
          ..write('falta: $falta, ')
          ..write('material: $material')
          ..write(')'))
        .toString();
  }
}

class $UnidadesTable extends Unidades with TableInfo<$UnidadesTable, Unidad> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnidadesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cursoIdMeta = const VerificationMeta(
    'cursoId',
  );
  @override
  late final GeneratedColumn<int> cursoId = GeneratedColumn<int>(
    'curso_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cursos (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _anioMeta = const VerificationMeta('anio');
  @override
  late final GeneratedColumn<int> anio = GeneratedColumn<int>(
    'anio',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodoMeta = const VerificationMeta(
    'periodo',
  );
  @override
  late final GeneratedColumn<int> periodo = GeneratedColumn<int>(
    'periodo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
    'titulo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _desdeMeta = const VerificationMeta('desde');
  @override
  late final GeneratedColumn<String> desde = GeneratedColumn<String>(
    'desde',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hastaMeta = const VerificationMeta('hasta');
  @override
  late final GeneratedColumn<String> hasta = GeneratedColumn<String>(
    'hasta',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _competenciasMeta = const VerificationMeta(
    'competencias',
  );
  @override
  late final GeneratedColumn<String> competencias = GeneratedColumn<String>(
    'competencias',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _situacionMeta = const VerificationMeta(
    'situacion',
  );
  @override
  late final GeneratedColumn<String> situacion = GeneratedColumn<String>(
    'situacion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temasMeta = const VerificationMeta('temas');
  @override
  late final GeneratedColumn<String> temas = GeneratedColumn<String>(
    'temas',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productoMeta = const VerificationMeta(
    'producto',
  );
  @override
  late final GeneratedColumn<String> producto = GeneratedColumn<String>(
    'producto',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enfoquesMeta = const VerificationMeta(
    'enfoques',
  );
  @override
  late final GeneratedColumn<String> enfoques = GeneratedColumn<String>(
    'enfoques',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _propositosMeta = const VerificationMeta(
    'propositos',
  );
  @override
  late final GeneratedColumn<String> propositos = GeneratedColumn<String>(
    'propositos',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _materialesMeta = const VerificationMeta(
    'materiales',
  );
  @override
  late final GeneratedColumn<String> materiales = GeneratedColumn<String>(
    'materiales',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cursoId,
    anio,
    periodo,
    orden,
    titulo,
    desde,
    hasta,
    competencias,
    situacion,
    temas,
    producto,
    enfoques,
    propositos,
    materiales,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unidades';
  @override
  VerificationContext validateIntegrity(
    Insertable<Unidad> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('curso_id')) {
      context.handle(
        _cursoIdMeta,
        cursoId.isAcceptableOrUnknown(data['curso_id']!, _cursoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cursoIdMeta);
    }
    if (data.containsKey('anio')) {
      context.handle(
        _anioMeta,
        anio.isAcceptableOrUnknown(data['anio']!, _anioMeta),
      );
    } else if (isInserting) {
      context.missing(_anioMeta);
    }
    if (data.containsKey('periodo')) {
      context.handle(
        _periodoMeta,
        periodo.isAcceptableOrUnknown(data['periodo']!, _periodoMeta),
      );
    } else if (isInserting) {
      context.missing(_periodoMeta);
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    } else if (isInserting) {
      context.missing(_ordenMeta);
    }
    if (data.containsKey('titulo')) {
      context.handle(
        _tituloMeta,
        titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta),
      );
    } else if (isInserting) {
      context.missing(_tituloMeta);
    }
    if (data.containsKey('desde')) {
      context.handle(
        _desdeMeta,
        desde.isAcceptableOrUnknown(data['desde']!, _desdeMeta),
      );
    }
    if (data.containsKey('hasta')) {
      context.handle(
        _hastaMeta,
        hasta.isAcceptableOrUnknown(data['hasta']!, _hastaMeta),
      );
    }
    if (data.containsKey('competencias')) {
      context.handle(
        _competenciasMeta,
        competencias.isAcceptableOrUnknown(
          data['competencias']!,
          _competenciasMeta,
        ),
      );
    }
    if (data.containsKey('situacion')) {
      context.handle(
        _situacionMeta,
        situacion.isAcceptableOrUnknown(data['situacion']!, _situacionMeta),
      );
    }
    if (data.containsKey('temas')) {
      context.handle(
        _temasMeta,
        temas.isAcceptableOrUnknown(data['temas']!, _temasMeta),
      );
    }
    if (data.containsKey('producto')) {
      context.handle(
        _productoMeta,
        producto.isAcceptableOrUnknown(data['producto']!, _productoMeta),
      );
    }
    if (data.containsKey('enfoques')) {
      context.handle(
        _enfoquesMeta,
        enfoques.isAcceptableOrUnknown(data['enfoques']!, _enfoquesMeta),
      );
    }
    if (data.containsKey('propositos')) {
      context.handle(
        _propositosMeta,
        propositos.isAcceptableOrUnknown(data['propositos']!, _propositosMeta),
      );
    }
    if (data.containsKey('materiales')) {
      context.handle(
        _materialesMeta,
        materiales.isAcceptableOrUnknown(data['materiales']!, _materialesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Unidad map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Unidad(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cursoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}curso_id'],
      )!,
      anio: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anio'],
      )!,
      periodo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}periodo'],
      )!,
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
      titulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titulo'],
      )!,
      desde: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}desde'],
      ),
      hasta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hasta'],
      ),
      competencias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}competencias'],
      )!,
      situacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}situacion'],
      ),
      temas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}temas'],
      ),
      producto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto'],
      ),
      enfoques: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enfoques'],
      )!,
      propositos: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}propositos'],
      ),
      materiales: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}materiales'],
      ),
    );
  }

  @override
  $UnidadesTable createAlias(String alias) {
    return $UnidadesTable(attachedDatabase, alias);
  }
}

class Unidad extends DataClass implements Insertable<Unidad> {
  final int id;
  final int cursoId;
  final int anio;
  final int periodo;
  final int orden;
  final String titulo;
  final String? desde;
  final String? hasta;

  /// Ids de competencias del CNEB separados por coma.
  final String competencias;
  final String? situacion;
  final String? temas;
  final String? producto;

  /// Enfoques transversales separados por «|».
  final String enfoques;

  /// Propósitos de aprendizaje en JSON (ver planificacion.dart).
  final String? propositos;
  final String? materiales;
  const Unidad({
    required this.id,
    required this.cursoId,
    required this.anio,
    required this.periodo,
    required this.orden,
    required this.titulo,
    this.desde,
    this.hasta,
    required this.competencias,
    this.situacion,
    this.temas,
    this.producto,
    required this.enfoques,
    this.propositos,
    this.materiales,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['curso_id'] = Variable<int>(cursoId);
    map['anio'] = Variable<int>(anio);
    map['periodo'] = Variable<int>(periodo);
    map['orden'] = Variable<int>(orden);
    map['titulo'] = Variable<String>(titulo);
    if (!nullToAbsent || desde != null) {
      map['desde'] = Variable<String>(desde);
    }
    if (!nullToAbsent || hasta != null) {
      map['hasta'] = Variable<String>(hasta);
    }
    map['competencias'] = Variable<String>(competencias);
    if (!nullToAbsent || situacion != null) {
      map['situacion'] = Variable<String>(situacion);
    }
    if (!nullToAbsent || temas != null) {
      map['temas'] = Variable<String>(temas);
    }
    if (!nullToAbsent || producto != null) {
      map['producto'] = Variable<String>(producto);
    }
    map['enfoques'] = Variable<String>(enfoques);
    if (!nullToAbsent || propositos != null) {
      map['propositos'] = Variable<String>(propositos);
    }
    if (!nullToAbsent || materiales != null) {
      map['materiales'] = Variable<String>(materiales);
    }
    return map;
  }

  UnidadesCompanion toCompanion(bool nullToAbsent) {
    return UnidadesCompanion(
      id: Value(id),
      cursoId: Value(cursoId),
      anio: Value(anio),
      periodo: Value(periodo),
      orden: Value(orden),
      titulo: Value(titulo),
      desde: desde == null && nullToAbsent
          ? const Value.absent()
          : Value(desde),
      hasta: hasta == null && nullToAbsent
          ? const Value.absent()
          : Value(hasta),
      competencias: Value(competencias),
      situacion: situacion == null && nullToAbsent
          ? const Value.absent()
          : Value(situacion),
      temas: temas == null && nullToAbsent
          ? const Value.absent()
          : Value(temas),
      producto: producto == null && nullToAbsent
          ? const Value.absent()
          : Value(producto),
      enfoques: Value(enfoques),
      propositos: propositos == null && nullToAbsent
          ? const Value.absent()
          : Value(propositos),
      materiales: materiales == null && nullToAbsent
          ? const Value.absent()
          : Value(materiales),
    );
  }

  factory Unidad.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Unidad(
      id: serializer.fromJson<int>(json['id']),
      cursoId: serializer.fromJson<int>(json['cursoId']),
      anio: serializer.fromJson<int>(json['anio']),
      periodo: serializer.fromJson<int>(json['periodo']),
      orden: serializer.fromJson<int>(json['orden']),
      titulo: serializer.fromJson<String>(json['titulo']),
      desde: serializer.fromJson<String?>(json['desde']),
      hasta: serializer.fromJson<String?>(json['hasta']),
      competencias: serializer.fromJson<String>(json['competencias']),
      situacion: serializer.fromJson<String?>(json['situacion']),
      temas: serializer.fromJson<String?>(json['temas']),
      producto: serializer.fromJson<String?>(json['producto']),
      enfoques: serializer.fromJson<String>(json['enfoques']),
      propositos: serializer.fromJson<String?>(json['propositos']),
      materiales: serializer.fromJson<String?>(json['materiales']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cursoId': serializer.toJson<int>(cursoId),
      'anio': serializer.toJson<int>(anio),
      'periodo': serializer.toJson<int>(periodo),
      'orden': serializer.toJson<int>(orden),
      'titulo': serializer.toJson<String>(titulo),
      'desde': serializer.toJson<String?>(desde),
      'hasta': serializer.toJson<String?>(hasta),
      'competencias': serializer.toJson<String>(competencias),
      'situacion': serializer.toJson<String?>(situacion),
      'temas': serializer.toJson<String?>(temas),
      'producto': serializer.toJson<String?>(producto),
      'enfoques': serializer.toJson<String>(enfoques),
      'propositos': serializer.toJson<String?>(propositos),
      'materiales': serializer.toJson<String?>(materiales),
    };
  }

  Unidad copyWith({
    int? id,
    int? cursoId,
    int? anio,
    int? periodo,
    int? orden,
    String? titulo,
    Value<String?> desde = const Value.absent(),
    Value<String?> hasta = const Value.absent(),
    String? competencias,
    Value<String?> situacion = const Value.absent(),
    Value<String?> temas = const Value.absent(),
    Value<String?> producto = const Value.absent(),
    String? enfoques,
    Value<String?> propositos = const Value.absent(),
    Value<String?> materiales = const Value.absent(),
  }) => Unidad(
    id: id ?? this.id,
    cursoId: cursoId ?? this.cursoId,
    anio: anio ?? this.anio,
    periodo: periodo ?? this.periodo,
    orden: orden ?? this.orden,
    titulo: titulo ?? this.titulo,
    desde: desde.present ? desde.value : this.desde,
    hasta: hasta.present ? hasta.value : this.hasta,
    competencias: competencias ?? this.competencias,
    situacion: situacion.present ? situacion.value : this.situacion,
    temas: temas.present ? temas.value : this.temas,
    producto: producto.present ? producto.value : this.producto,
    enfoques: enfoques ?? this.enfoques,
    propositos: propositos.present ? propositos.value : this.propositos,
    materiales: materiales.present ? materiales.value : this.materiales,
  );
  Unidad copyWithCompanion(UnidadesCompanion data) {
    return Unidad(
      id: data.id.present ? data.id.value : this.id,
      cursoId: data.cursoId.present ? data.cursoId.value : this.cursoId,
      anio: data.anio.present ? data.anio.value : this.anio,
      periodo: data.periodo.present ? data.periodo.value : this.periodo,
      orden: data.orden.present ? data.orden.value : this.orden,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      desde: data.desde.present ? data.desde.value : this.desde,
      hasta: data.hasta.present ? data.hasta.value : this.hasta,
      competencias: data.competencias.present
          ? data.competencias.value
          : this.competencias,
      situacion: data.situacion.present ? data.situacion.value : this.situacion,
      temas: data.temas.present ? data.temas.value : this.temas,
      producto: data.producto.present ? data.producto.value : this.producto,
      enfoques: data.enfoques.present ? data.enfoques.value : this.enfoques,
      propositos: data.propositos.present
          ? data.propositos.value
          : this.propositos,
      materiales: data.materiales.present
          ? data.materiales.value
          : this.materiales,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Unidad(')
          ..write('id: $id, ')
          ..write('cursoId: $cursoId, ')
          ..write('anio: $anio, ')
          ..write('periodo: $periodo, ')
          ..write('orden: $orden, ')
          ..write('titulo: $titulo, ')
          ..write('desde: $desde, ')
          ..write('hasta: $hasta, ')
          ..write('competencias: $competencias, ')
          ..write('situacion: $situacion, ')
          ..write('temas: $temas, ')
          ..write('producto: $producto, ')
          ..write('enfoques: $enfoques, ')
          ..write('propositos: $propositos, ')
          ..write('materiales: $materiales')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cursoId,
    anio,
    periodo,
    orden,
    titulo,
    desde,
    hasta,
    competencias,
    situacion,
    temas,
    producto,
    enfoques,
    propositos,
    materiales,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Unidad &&
          other.id == this.id &&
          other.cursoId == this.cursoId &&
          other.anio == this.anio &&
          other.periodo == this.periodo &&
          other.orden == this.orden &&
          other.titulo == this.titulo &&
          other.desde == this.desde &&
          other.hasta == this.hasta &&
          other.competencias == this.competencias &&
          other.situacion == this.situacion &&
          other.temas == this.temas &&
          other.producto == this.producto &&
          other.enfoques == this.enfoques &&
          other.propositos == this.propositos &&
          other.materiales == this.materiales);
}

class UnidadesCompanion extends UpdateCompanion<Unidad> {
  final Value<int> id;
  final Value<int> cursoId;
  final Value<int> anio;
  final Value<int> periodo;
  final Value<int> orden;
  final Value<String> titulo;
  final Value<String?> desde;
  final Value<String?> hasta;
  final Value<String> competencias;
  final Value<String?> situacion;
  final Value<String?> temas;
  final Value<String?> producto;
  final Value<String> enfoques;
  final Value<String?> propositos;
  final Value<String?> materiales;
  const UnidadesCompanion({
    this.id = const Value.absent(),
    this.cursoId = const Value.absent(),
    this.anio = const Value.absent(),
    this.periodo = const Value.absent(),
    this.orden = const Value.absent(),
    this.titulo = const Value.absent(),
    this.desde = const Value.absent(),
    this.hasta = const Value.absent(),
    this.competencias = const Value.absent(),
    this.situacion = const Value.absent(),
    this.temas = const Value.absent(),
    this.producto = const Value.absent(),
    this.enfoques = const Value.absent(),
    this.propositos = const Value.absent(),
    this.materiales = const Value.absent(),
  });
  UnidadesCompanion.insert({
    this.id = const Value.absent(),
    required int cursoId,
    required int anio,
    required int periodo,
    required int orden,
    required String titulo,
    this.desde = const Value.absent(),
    this.hasta = const Value.absent(),
    this.competencias = const Value.absent(),
    this.situacion = const Value.absent(),
    this.temas = const Value.absent(),
    this.producto = const Value.absent(),
    this.enfoques = const Value.absent(),
    this.propositos = const Value.absent(),
    this.materiales = const Value.absent(),
  }) : cursoId = Value(cursoId),
       anio = Value(anio),
       periodo = Value(periodo),
       orden = Value(orden),
       titulo = Value(titulo);
  static Insertable<Unidad> custom({
    Expression<int>? id,
    Expression<int>? cursoId,
    Expression<int>? anio,
    Expression<int>? periodo,
    Expression<int>? orden,
    Expression<String>? titulo,
    Expression<String>? desde,
    Expression<String>? hasta,
    Expression<String>? competencias,
    Expression<String>? situacion,
    Expression<String>? temas,
    Expression<String>? producto,
    Expression<String>? enfoques,
    Expression<String>? propositos,
    Expression<String>? materiales,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cursoId != null) 'curso_id': cursoId,
      if (anio != null) 'anio': anio,
      if (periodo != null) 'periodo': periodo,
      if (orden != null) 'orden': orden,
      if (titulo != null) 'titulo': titulo,
      if (desde != null) 'desde': desde,
      if (hasta != null) 'hasta': hasta,
      if (competencias != null) 'competencias': competencias,
      if (situacion != null) 'situacion': situacion,
      if (temas != null) 'temas': temas,
      if (producto != null) 'producto': producto,
      if (enfoques != null) 'enfoques': enfoques,
      if (propositos != null) 'propositos': propositos,
      if (materiales != null) 'materiales': materiales,
    });
  }

  UnidadesCompanion copyWith({
    Value<int>? id,
    Value<int>? cursoId,
    Value<int>? anio,
    Value<int>? periodo,
    Value<int>? orden,
    Value<String>? titulo,
    Value<String?>? desde,
    Value<String?>? hasta,
    Value<String>? competencias,
    Value<String?>? situacion,
    Value<String?>? temas,
    Value<String?>? producto,
    Value<String>? enfoques,
    Value<String?>? propositos,
    Value<String?>? materiales,
  }) {
    return UnidadesCompanion(
      id: id ?? this.id,
      cursoId: cursoId ?? this.cursoId,
      anio: anio ?? this.anio,
      periodo: periodo ?? this.periodo,
      orden: orden ?? this.orden,
      titulo: titulo ?? this.titulo,
      desde: desde ?? this.desde,
      hasta: hasta ?? this.hasta,
      competencias: competencias ?? this.competencias,
      situacion: situacion ?? this.situacion,
      temas: temas ?? this.temas,
      producto: producto ?? this.producto,
      enfoques: enfoques ?? this.enfoques,
      propositos: propositos ?? this.propositos,
      materiales: materiales ?? this.materiales,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cursoId.present) {
      map['curso_id'] = Variable<int>(cursoId.value);
    }
    if (anio.present) {
      map['anio'] = Variable<int>(anio.value);
    }
    if (periodo.present) {
      map['periodo'] = Variable<int>(periodo.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (desde.present) {
      map['desde'] = Variable<String>(desde.value);
    }
    if (hasta.present) {
      map['hasta'] = Variable<String>(hasta.value);
    }
    if (competencias.present) {
      map['competencias'] = Variable<String>(competencias.value);
    }
    if (situacion.present) {
      map['situacion'] = Variable<String>(situacion.value);
    }
    if (temas.present) {
      map['temas'] = Variable<String>(temas.value);
    }
    if (producto.present) {
      map['producto'] = Variable<String>(producto.value);
    }
    if (enfoques.present) {
      map['enfoques'] = Variable<String>(enfoques.value);
    }
    if (propositos.present) {
      map['propositos'] = Variable<String>(propositos.value);
    }
    if (materiales.present) {
      map['materiales'] = Variable<String>(materiales.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnidadesCompanion(')
          ..write('id: $id, ')
          ..write('cursoId: $cursoId, ')
          ..write('anio: $anio, ')
          ..write('periodo: $periodo, ')
          ..write('orden: $orden, ')
          ..write('titulo: $titulo, ')
          ..write('desde: $desde, ')
          ..write('hasta: $hasta, ')
          ..write('competencias: $competencias, ')
          ..write('situacion: $situacion, ')
          ..write('temas: $temas, ')
          ..write('producto: $producto, ')
          ..write('enfoques: $enfoques, ')
          ..write('propositos: $propositos, ')
          ..write('materiales: $materiales')
          ..write(')'))
        .toString();
  }
}

class $SesionesTable extends Sesiones with TableInfo<$SesionesTable, Sesion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SesionesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _unidadIdMeta = const VerificationMeta(
    'unidadId',
  );
  @override
  late final GeneratedColumn<int> unidadId = GeneratedColumn<int>(
    'unidad_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES unidades (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
    'titulo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<String> fecha = GeneratedColumn<String>(
    'fecha',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _horaMeta = const VerificationMeta('hora');
  @override
  late final GeneratedColumn<String> hora = GeneratedColumn<String>(
    'hora',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _competenciaMeta = const VerificationMeta(
    'competencia',
  );
  @override
  late final GeneratedColumn<String> competencia = GeneratedColumn<String>(
    'competencia',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _propositoMeta = const VerificationMeta(
    'proposito',
  );
  @override
  late final GeneratedColumn<String> proposito = GeneratedColumn<String>(
    'proposito',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inicioMeta = const VerificationMeta('inicio');
  @override
  late final GeneratedColumn<String> inicio = GeneratedColumn<String>(
    'inicio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _desarrolloMeta = const VerificationMeta(
    'desarrollo',
  );
  @override
  late final GeneratedColumn<String> desarrollo = GeneratedColumn<String>(
    'desarrollo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cierreMeta = const VerificationMeta('cierre');
  @override
  late final GeneratedColumn<String> cierre = GeneratedColumn<String>(
    'cierre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minInicioMeta = const VerificationMeta(
    'minInicio',
  );
  @override
  late final GeneratedColumn<int> minInicio = GeneratedColumn<int>(
    'min_inicio',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minDesarrolloMeta = const VerificationMeta(
    'minDesarrollo',
  );
  @override
  late final GeneratedColumn<int> minDesarrollo = GeneratedColumn<int>(
    'min_desarrollo',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minCierreMeta = const VerificationMeta(
    'minCierre',
  );
  @override
  late final GeneratedColumn<int> minCierre = GeneratedColumn<int>(
    'min_cierre',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _materialesMeta = const VerificationMeta(
    'materiales',
  );
  @override
  late final GeneratedColumn<String> materiales = GeneratedColumn<String>(
    'materiales',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tareaMeta = const VerificationMeta('tarea');
  @override
  late final GeneratedColumn<String> tarea = GeneratedColumn<String>(
    'tarea',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hechaMeta = const VerificationMeta('hecha');
  @override
  late final GeneratedColumn<bool> hecha = GeneratedColumn<bool>(
    'hecha',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hecha" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _columnaIdMeta = const VerificationMeta(
    'columnaId',
  );
  @override
  late final GeneratedColumn<int> columnaId = GeneratedColumn<int>(
    'columna_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    unidadId,
    orden,
    titulo,
    fecha,
    hora,
    competencia,
    proposito,
    inicio,
    desarrollo,
    cierre,
    minInicio,
    minDesarrollo,
    minCierre,
    materiales,
    tarea,
    hecha,
    columnaId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sesiones';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sesion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('unidad_id')) {
      context.handle(
        _unidadIdMeta,
        unidadId.isAcceptableOrUnknown(data['unidad_id']!, _unidadIdMeta),
      );
    } else if (isInserting) {
      context.missing(_unidadIdMeta);
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    } else if (isInserting) {
      context.missing(_ordenMeta);
    }
    if (data.containsKey('titulo')) {
      context.handle(
        _tituloMeta,
        titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta),
      );
    } else if (isInserting) {
      context.missing(_tituloMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    }
    if (data.containsKey('hora')) {
      context.handle(
        _horaMeta,
        hora.isAcceptableOrUnknown(data['hora']!, _horaMeta),
      );
    }
    if (data.containsKey('competencia')) {
      context.handle(
        _competenciaMeta,
        competencia.isAcceptableOrUnknown(
          data['competencia']!,
          _competenciaMeta,
        ),
      );
    }
    if (data.containsKey('proposito')) {
      context.handle(
        _propositoMeta,
        proposito.isAcceptableOrUnknown(data['proposito']!, _propositoMeta),
      );
    }
    if (data.containsKey('inicio')) {
      context.handle(
        _inicioMeta,
        inicio.isAcceptableOrUnknown(data['inicio']!, _inicioMeta),
      );
    }
    if (data.containsKey('desarrollo')) {
      context.handle(
        _desarrolloMeta,
        desarrollo.isAcceptableOrUnknown(data['desarrollo']!, _desarrolloMeta),
      );
    }
    if (data.containsKey('cierre')) {
      context.handle(
        _cierreMeta,
        cierre.isAcceptableOrUnknown(data['cierre']!, _cierreMeta),
      );
    }
    if (data.containsKey('min_inicio')) {
      context.handle(
        _minInicioMeta,
        minInicio.isAcceptableOrUnknown(data['min_inicio']!, _minInicioMeta),
      );
    }
    if (data.containsKey('min_desarrollo')) {
      context.handle(
        _minDesarrolloMeta,
        minDesarrollo.isAcceptableOrUnknown(
          data['min_desarrollo']!,
          _minDesarrolloMeta,
        ),
      );
    }
    if (data.containsKey('min_cierre')) {
      context.handle(
        _minCierreMeta,
        minCierre.isAcceptableOrUnknown(data['min_cierre']!, _minCierreMeta),
      );
    }
    if (data.containsKey('materiales')) {
      context.handle(
        _materialesMeta,
        materiales.isAcceptableOrUnknown(data['materiales']!, _materialesMeta),
      );
    }
    if (data.containsKey('tarea')) {
      context.handle(
        _tareaMeta,
        tarea.isAcceptableOrUnknown(data['tarea']!, _tareaMeta),
      );
    }
    if (data.containsKey('hecha')) {
      context.handle(
        _hechaMeta,
        hecha.isAcceptableOrUnknown(data['hecha']!, _hechaMeta),
      );
    }
    if (data.containsKey('columna_id')) {
      context.handle(
        _columnaIdMeta,
        columnaId.isAcceptableOrUnknown(data['columna_id']!, _columnaIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sesion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sesion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      unidadId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unidad_id'],
      )!,
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
      titulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titulo'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fecha'],
      ),
      hora: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hora'],
      ),
      competencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}competencia'],
      ),
      proposito: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proposito'],
      ),
      inicio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inicio'],
      ),
      desarrollo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}desarrollo'],
      ),
      cierre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cierre'],
      ),
      minInicio: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_inicio'],
      ),
      minDesarrollo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_desarrollo'],
      ),
      minCierre: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_cierre'],
      ),
      materiales: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}materiales'],
      ),
      tarea: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tarea'],
      ),
      hecha: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hecha'],
      )!,
      columnaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}columna_id'],
      ),
    );
  }

  @override
  $SesionesTable createAlias(String alias) {
    return $SesionesTable(attachedDatabase, alias);
  }
}

class Sesion extends DataClass implements Insertable<Sesion> {
  final int id;
  final int unidadId;
  final int orden;
  final String titulo;
  final String? fecha;
  final String? hora;
  final String? competencia;
  final String? proposito;

  /// Momentos (colegio público) o actividades (privado: solo [desarrollo]).
  final String? inicio;
  final String? desarrollo;
  final String? cierre;
  final int? minInicio;
  final int? minDesarrollo;
  final int? minCierre;
  final String? materiales;
  final String? tarea;
  final bool hecha;

  /// Columna del registro creada desde la sesión.
  final int? columnaId;
  const Sesion({
    required this.id,
    required this.unidadId,
    required this.orden,
    required this.titulo,
    this.fecha,
    this.hora,
    this.competencia,
    this.proposito,
    this.inicio,
    this.desarrollo,
    this.cierre,
    this.minInicio,
    this.minDesarrollo,
    this.minCierre,
    this.materiales,
    this.tarea,
    required this.hecha,
    this.columnaId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['unidad_id'] = Variable<int>(unidadId);
    map['orden'] = Variable<int>(orden);
    map['titulo'] = Variable<String>(titulo);
    if (!nullToAbsent || fecha != null) {
      map['fecha'] = Variable<String>(fecha);
    }
    if (!nullToAbsent || hora != null) {
      map['hora'] = Variable<String>(hora);
    }
    if (!nullToAbsent || competencia != null) {
      map['competencia'] = Variable<String>(competencia);
    }
    if (!nullToAbsent || proposito != null) {
      map['proposito'] = Variable<String>(proposito);
    }
    if (!nullToAbsent || inicio != null) {
      map['inicio'] = Variable<String>(inicio);
    }
    if (!nullToAbsent || desarrollo != null) {
      map['desarrollo'] = Variable<String>(desarrollo);
    }
    if (!nullToAbsent || cierre != null) {
      map['cierre'] = Variable<String>(cierre);
    }
    if (!nullToAbsent || minInicio != null) {
      map['min_inicio'] = Variable<int>(minInicio);
    }
    if (!nullToAbsent || minDesarrollo != null) {
      map['min_desarrollo'] = Variable<int>(minDesarrollo);
    }
    if (!nullToAbsent || minCierre != null) {
      map['min_cierre'] = Variable<int>(minCierre);
    }
    if (!nullToAbsent || materiales != null) {
      map['materiales'] = Variable<String>(materiales);
    }
    if (!nullToAbsent || tarea != null) {
      map['tarea'] = Variable<String>(tarea);
    }
    map['hecha'] = Variable<bool>(hecha);
    if (!nullToAbsent || columnaId != null) {
      map['columna_id'] = Variable<int>(columnaId);
    }
    return map;
  }

  SesionesCompanion toCompanion(bool nullToAbsent) {
    return SesionesCompanion(
      id: Value(id),
      unidadId: Value(unidadId),
      orden: Value(orden),
      titulo: Value(titulo),
      fecha: fecha == null && nullToAbsent
          ? const Value.absent()
          : Value(fecha),
      hora: hora == null && nullToAbsent ? const Value.absent() : Value(hora),
      competencia: competencia == null && nullToAbsent
          ? const Value.absent()
          : Value(competencia),
      proposito: proposito == null && nullToAbsent
          ? const Value.absent()
          : Value(proposito),
      inicio: inicio == null && nullToAbsent
          ? const Value.absent()
          : Value(inicio),
      desarrollo: desarrollo == null && nullToAbsent
          ? const Value.absent()
          : Value(desarrollo),
      cierre: cierre == null && nullToAbsent
          ? const Value.absent()
          : Value(cierre),
      minInicio: minInicio == null && nullToAbsent
          ? const Value.absent()
          : Value(minInicio),
      minDesarrollo: minDesarrollo == null && nullToAbsent
          ? const Value.absent()
          : Value(minDesarrollo),
      minCierre: minCierre == null && nullToAbsent
          ? const Value.absent()
          : Value(minCierre),
      materiales: materiales == null && nullToAbsent
          ? const Value.absent()
          : Value(materiales),
      tarea: tarea == null && nullToAbsent
          ? const Value.absent()
          : Value(tarea),
      hecha: Value(hecha),
      columnaId: columnaId == null && nullToAbsent
          ? const Value.absent()
          : Value(columnaId),
    );
  }

  factory Sesion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sesion(
      id: serializer.fromJson<int>(json['id']),
      unidadId: serializer.fromJson<int>(json['unidadId']),
      orden: serializer.fromJson<int>(json['orden']),
      titulo: serializer.fromJson<String>(json['titulo']),
      fecha: serializer.fromJson<String?>(json['fecha']),
      hora: serializer.fromJson<String?>(json['hora']),
      competencia: serializer.fromJson<String?>(json['competencia']),
      proposito: serializer.fromJson<String?>(json['proposito']),
      inicio: serializer.fromJson<String?>(json['inicio']),
      desarrollo: serializer.fromJson<String?>(json['desarrollo']),
      cierre: serializer.fromJson<String?>(json['cierre']),
      minInicio: serializer.fromJson<int?>(json['minInicio']),
      minDesarrollo: serializer.fromJson<int?>(json['minDesarrollo']),
      minCierre: serializer.fromJson<int?>(json['minCierre']),
      materiales: serializer.fromJson<String?>(json['materiales']),
      tarea: serializer.fromJson<String?>(json['tarea']),
      hecha: serializer.fromJson<bool>(json['hecha']),
      columnaId: serializer.fromJson<int?>(json['columnaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'unidadId': serializer.toJson<int>(unidadId),
      'orden': serializer.toJson<int>(orden),
      'titulo': serializer.toJson<String>(titulo),
      'fecha': serializer.toJson<String?>(fecha),
      'hora': serializer.toJson<String?>(hora),
      'competencia': serializer.toJson<String?>(competencia),
      'proposito': serializer.toJson<String?>(proposito),
      'inicio': serializer.toJson<String?>(inicio),
      'desarrollo': serializer.toJson<String?>(desarrollo),
      'cierre': serializer.toJson<String?>(cierre),
      'minInicio': serializer.toJson<int?>(minInicio),
      'minDesarrollo': serializer.toJson<int?>(minDesarrollo),
      'minCierre': serializer.toJson<int?>(minCierre),
      'materiales': serializer.toJson<String?>(materiales),
      'tarea': serializer.toJson<String?>(tarea),
      'hecha': serializer.toJson<bool>(hecha),
      'columnaId': serializer.toJson<int?>(columnaId),
    };
  }

  Sesion copyWith({
    int? id,
    int? unidadId,
    int? orden,
    String? titulo,
    Value<String?> fecha = const Value.absent(),
    Value<String?> hora = const Value.absent(),
    Value<String?> competencia = const Value.absent(),
    Value<String?> proposito = const Value.absent(),
    Value<String?> inicio = const Value.absent(),
    Value<String?> desarrollo = const Value.absent(),
    Value<String?> cierre = const Value.absent(),
    Value<int?> minInicio = const Value.absent(),
    Value<int?> minDesarrollo = const Value.absent(),
    Value<int?> minCierre = const Value.absent(),
    Value<String?> materiales = const Value.absent(),
    Value<String?> tarea = const Value.absent(),
    bool? hecha,
    Value<int?> columnaId = const Value.absent(),
  }) => Sesion(
    id: id ?? this.id,
    unidadId: unidadId ?? this.unidadId,
    orden: orden ?? this.orden,
    titulo: titulo ?? this.titulo,
    fecha: fecha.present ? fecha.value : this.fecha,
    hora: hora.present ? hora.value : this.hora,
    competencia: competencia.present ? competencia.value : this.competencia,
    proposito: proposito.present ? proposito.value : this.proposito,
    inicio: inicio.present ? inicio.value : this.inicio,
    desarrollo: desarrollo.present ? desarrollo.value : this.desarrollo,
    cierre: cierre.present ? cierre.value : this.cierre,
    minInicio: minInicio.present ? minInicio.value : this.minInicio,
    minDesarrollo: minDesarrollo.present
        ? minDesarrollo.value
        : this.minDesarrollo,
    minCierre: minCierre.present ? minCierre.value : this.minCierre,
    materiales: materiales.present ? materiales.value : this.materiales,
    tarea: tarea.present ? tarea.value : this.tarea,
    hecha: hecha ?? this.hecha,
    columnaId: columnaId.present ? columnaId.value : this.columnaId,
  );
  Sesion copyWithCompanion(SesionesCompanion data) {
    return Sesion(
      id: data.id.present ? data.id.value : this.id,
      unidadId: data.unidadId.present ? data.unidadId.value : this.unidadId,
      orden: data.orden.present ? data.orden.value : this.orden,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      hora: data.hora.present ? data.hora.value : this.hora,
      competencia: data.competencia.present
          ? data.competencia.value
          : this.competencia,
      proposito: data.proposito.present ? data.proposito.value : this.proposito,
      inicio: data.inicio.present ? data.inicio.value : this.inicio,
      desarrollo: data.desarrollo.present
          ? data.desarrollo.value
          : this.desarrollo,
      cierre: data.cierre.present ? data.cierre.value : this.cierre,
      minInicio: data.minInicio.present ? data.minInicio.value : this.minInicio,
      minDesarrollo: data.minDesarrollo.present
          ? data.minDesarrollo.value
          : this.minDesarrollo,
      minCierre: data.minCierre.present ? data.minCierre.value : this.minCierre,
      materiales: data.materiales.present
          ? data.materiales.value
          : this.materiales,
      tarea: data.tarea.present ? data.tarea.value : this.tarea,
      hecha: data.hecha.present ? data.hecha.value : this.hecha,
      columnaId: data.columnaId.present ? data.columnaId.value : this.columnaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sesion(')
          ..write('id: $id, ')
          ..write('unidadId: $unidadId, ')
          ..write('orden: $orden, ')
          ..write('titulo: $titulo, ')
          ..write('fecha: $fecha, ')
          ..write('hora: $hora, ')
          ..write('competencia: $competencia, ')
          ..write('proposito: $proposito, ')
          ..write('inicio: $inicio, ')
          ..write('desarrollo: $desarrollo, ')
          ..write('cierre: $cierre, ')
          ..write('minInicio: $minInicio, ')
          ..write('minDesarrollo: $minDesarrollo, ')
          ..write('minCierre: $minCierre, ')
          ..write('materiales: $materiales, ')
          ..write('tarea: $tarea, ')
          ..write('hecha: $hecha, ')
          ..write('columnaId: $columnaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    unidadId,
    orden,
    titulo,
    fecha,
    hora,
    competencia,
    proposito,
    inicio,
    desarrollo,
    cierre,
    minInicio,
    minDesarrollo,
    minCierre,
    materiales,
    tarea,
    hecha,
    columnaId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sesion &&
          other.id == this.id &&
          other.unidadId == this.unidadId &&
          other.orden == this.orden &&
          other.titulo == this.titulo &&
          other.fecha == this.fecha &&
          other.hora == this.hora &&
          other.competencia == this.competencia &&
          other.proposito == this.proposito &&
          other.inicio == this.inicio &&
          other.desarrollo == this.desarrollo &&
          other.cierre == this.cierre &&
          other.minInicio == this.minInicio &&
          other.minDesarrollo == this.minDesarrollo &&
          other.minCierre == this.minCierre &&
          other.materiales == this.materiales &&
          other.tarea == this.tarea &&
          other.hecha == this.hecha &&
          other.columnaId == this.columnaId);
}

class SesionesCompanion extends UpdateCompanion<Sesion> {
  final Value<int> id;
  final Value<int> unidadId;
  final Value<int> orden;
  final Value<String> titulo;
  final Value<String?> fecha;
  final Value<String?> hora;
  final Value<String?> competencia;
  final Value<String?> proposito;
  final Value<String?> inicio;
  final Value<String?> desarrollo;
  final Value<String?> cierre;
  final Value<int?> minInicio;
  final Value<int?> minDesarrollo;
  final Value<int?> minCierre;
  final Value<String?> materiales;
  final Value<String?> tarea;
  final Value<bool> hecha;
  final Value<int?> columnaId;
  const SesionesCompanion({
    this.id = const Value.absent(),
    this.unidadId = const Value.absent(),
    this.orden = const Value.absent(),
    this.titulo = const Value.absent(),
    this.fecha = const Value.absent(),
    this.hora = const Value.absent(),
    this.competencia = const Value.absent(),
    this.proposito = const Value.absent(),
    this.inicio = const Value.absent(),
    this.desarrollo = const Value.absent(),
    this.cierre = const Value.absent(),
    this.minInicio = const Value.absent(),
    this.minDesarrollo = const Value.absent(),
    this.minCierre = const Value.absent(),
    this.materiales = const Value.absent(),
    this.tarea = const Value.absent(),
    this.hecha = const Value.absent(),
    this.columnaId = const Value.absent(),
  });
  SesionesCompanion.insert({
    this.id = const Value.absent(),
    required int unidadId,
    required int orden,
    required String titulo,
    this.fecha = const Value.absent(),
    this.hora = const Value.absent(),
    this.competencia = const Value.absent(),
    this.proposito = const Value.absent(),
    this.inicio = const Value.absent(),
    this.desarrollo = const Value.absent(),
    this.cierre = const Value.absent(),
    this.minInicio = const Value.absent(),
    this.minDesarrollo = const Value.absent(),
    this.minCierre = const Value.absent(),
    this.materiales = const Value.absent(),
    this.tarea = const Value.absent(),
    this.hecha = const Value.absent(),
    this.columnaId = const Value.absent(),
  }) : unidadId = Value(unidadId),
       orden = Value(orden),
       titulo = Value(titulo);
  static Insertable<Sesion> custom({
    Expression<int>? id,
    Expression<int>? unidadId,
    Expression<int>? orden,
    Expression<String>? titulo,
    Expression<String>? fecha,
    Expression<String>? hora,
    Expression<String>? competencia,
    Expression<String>? proposito,
    Expression<String>? inicio,
    Expression<String>? desarrollo,
    Expression<String>? cierre,
    Expression<int>? minInicio,
    Expression<int>? minDesarrollo,
    Expression<int>? minCierre,
    Expression<String>? materiales,
    Expression<String>? tarea,
    Expression<bool>? hecha,
    Expression<int>? columnaId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (unidadId != null) 'unidad_id': unidadId,
      if (orden != null) 'orden': orden,
      if (titulo != null) 'titulo': titulo,
      if (fecha != null) 'fecha': fecha,
      if (hora != null) 'hora': hora,
      if (competencia != null) 'competencia': competencia,
      if (proposito != null) 'proposito': proposito,
      if (inicio != null) 'inicio': inicio,
      if (desarrollo != null) 'desarrollo': desarrollo,
      if (cierre != null) 'cierre': cierre,
      if (minInicio != null) 'min_inicio': minInicio,
      if (minDesarrollo != null) 'min_desarrollo': minDesarrollo,
      if (minCierre != null) 'min_cierre': minCierre,
      if (materiales != null) 'materiales': materiales,
      if (tarea != null) 'tarea': tarea,
      if (hecha != null) 'hecha': hecha,
      if (columnaId != null) 'columna_id': columnaId,
    });
  }

  SesionesCompanion copyWith({
    Value<int>? id,
    Value<int>? unidadId,
    Value<int>? orden,
    Value<String>? titulo,
    Value<String?>? fecha,
    Value<String?>? hora,
    Value<String?>? competencia,
    Value<String?>? proposito,
    Value<String?>? inicio,
    Value<String?>? desarrollo,
    Value<String?>? cierre,
    Value<int?>? minInicio,
    Value<int?>? minDesarrollo,
    Value<int?>? minCierre,
    Value<String?>? materiales,
    Value<String?>? tarea,
    Value<bool>? hecha,
    Value<int?>? columnaId,
  }) {
    return SesionesCompanion(
      id: id ?? this.id,
      unidadId: unidadId ?? this.unidadId,
      orden: orden ?? this.orden,
      titulo: titulo ?? this.titulo,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      competencia: competencia ?? this.competencia,
      proposito: proposito ?? this.proposito,
      inicio: inicio ?? this.inicio,
      desarrollo: desarrollo ?? this.desarrollo,
      cierre: cierre ?? this.cierre,
      minInicio: minInicio ?? this.minInicio,
      minDesarrollo: minDesarrollo ?? this.minDesarrollo,
      minCierre: minCierre ?? this.minCierre,
      materiales: materiales ?? this.materiales,
      tarea: tarea ?? this.tarea,
      hecha: hecha ?? this.hecha,
      columnaId: columnaId ?? this.columnaId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (unidadId.present) {
      map['unidad_id'] = Variable<int>(unidadId.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<String>(fecha.value);
    }
    if (hora.present) {
      map['hora'] = Variable<String>(hora.value);
    }
    if (competencia.present) {
      map['competencia'] = Variable<String>(competencia.value);
    }
    if (proposito.present) {
      map['proposito'] = Variable<String>(proposito.value);
    }
    if (inicio.present) {
      map['inicio'] = Variable<String>(inicio.value);
    }
    if (desarrollo.present) {
      map['desarrollo'] = Variable<String>(desarrollo.value);
    }
    if (cierre.present) {
      map['cierre'] = Variable<String>(cierre.value);
    }
    if (minInicio.present) {
      map['min_inicio'] = Variable<int>(minInicio.value);
    }
    if (minDesarrollo.present) {
      map['min_desarrollo'] = Variable<int>(minDesarrollo.value);
    }
    if (minCierre.present) {
      map['min_cierre'] = Variable<int>(minCierre.value);
    }
    if (materiales.present) {
      map['materiales'] = Variable<String>(materiales.value);
    }
    if (tarea.present) {
      map['tarea'] = Variable<String>(tarea.value);
    }
    if (hecha.present) {
      map['hecha'] = Variable<bool>(hecha.value);
    }
    if (columnaId.present) {
      map['columna_id'] = Variable<int>(columnaId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SesionesCompanion(')
          ..write('id: $id, ')
          ..write('unidadId: $unidadId, ')
          ..write('orden: $orden, ')
          ..write('titulo: $titulo, ')
          ..write('fecha: $fecha, ')
          ..write('hora: $hora, ')
          ..write('competencia: $competencia, ')
          ..write('proposito: $proposito, ')
          ..write('inicio: $inicio, ')
          ..write('desarrollo: $desarrollo, ')
          ..write('cierre: $cierre, ')
          ..write('minInicio: $minInicio, ')
          ..write('minDesarrollo: $minDesarrollo, ')
          ..write('minCierre: $minCierre, ')
          ..write('materiales: $materiales, ')
          ..write('tarea: $tarea, ')
          ..write('hecha: $hecha, ')
          ..write('columnaId: $columnaId')
          ..write(')'))
        .toString();
  }
}

abstract class _$KipuDb extends GeneratedDatabase {
  _$KipuDb(QueryExecutor e) : super(e);
  $KipuDbManager get managers => $KipuDbManager(this);
  late final $AjustesTable ajustes = $AjustesTable(this);
  late final $ColegiosTable colegios = $ColegiosTable(this);
  late final $CursosTable cursos = $CursosTable(this);
  late final $EstudiantesTable estudiantes = $EstudiantesTable(this);
  late final $AsistenciasTable asistencias = $AsistenciasTable(this);
  late final $NotasTable notas = $NotasTable(this);
  late final $EventosTable eventos = $EventosTable(this);
  late final $HorariosTable horarios = $HorariosTable(this);
  late final $FranjasTable franjas = $FranjasTable(this);
  late final $RegistroColumnasTable registroColumnas = $RegistroColumnasTable(
    this,
  );
  late final $RegistroNotasTable registroNotas = $RegistroNotasTable(this);
  late final $ConductasTable conductas = $ConductasTable(this);
  late final $PendientesTable pendientes = $PendientesTable(this);
  late final $AnecdotasTable anecdotas = $AnecdotasTable(this);
  late final $ClasesDiarioTable clasesDiario = $ClasesDiarioTable(this);
  late final $UnidadesTable unidades = $UnidadesTable(this);
  late final $SesionesTable sesiones = $SesionesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    ajustes,
    colegios,
    cursos,
    estudiantes,
    asistencias,
    notas,
    eventos,
    horarios,
    franjas,
    registroColumnas,
    registroNotas,
    conductas,
    pendientes,
    anecdotas,
    clasesDiario,
    unidades,
    sesiones,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'colegios',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cursos', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cursos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('estudiantes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'estudiantes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('asistencias', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'estudiantes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('notas', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cursos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('horarios', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'colegios',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('franjas', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cursos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('registro_columnas', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'registro_columnas',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('registro_notas', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'estudiantes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('registro_notas', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'estudiantes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('conductas', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'estudiantes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('anecdotas', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cursos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('clases_diario', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cursos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('unidades', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'unidades',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sesiones', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$AjustesTableCreateCompanionBuilder = AjustesCompanion Function({
  required String clave,
  required String valor,
  Value<int> rowid,
});
typedef $$AjustesTableUpdateCompanionBuilder = AjustesCompanion Function({
  Value<String> clave,
  Value<String> valor,
  Value<int> rowid,
});

class $$AjustesTableFilterComposer extends Composer<_$KipuDb, $AjustesTable> {
  $$AjustesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AjustesTableOrderingComposer extends Composer<_$KipuDb, $AjustesTable> {
  $$AjustesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AjustesTableAnnotationComposer
    extends Composer<_$KipuDb, $AjustesTable> {
  $$AjustesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clave =>
      $composableBuilder(column: $table.clave, builder: (column) => column);

  GeneratedColumn<String> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);
}

class $$AjustesTableTableManager
    extends
        RootTableManager<
          _$KipuDb,
          $AjustesTable,
          Ajuste,
          $$AjustesTableFilterComposer,
          $$AjustesTableOrderingComposer,
          $$AjustesTableAnnotationComposer,
          $$AjustesTableCreateCompanionBuilder,
          $$AjustesTableUpdateCompanionBuilder,
          (Ajuste, BaseReferences<_$KipuDb, $AjustesTable, Ajuste>),
          Ajuste,
          PrefetchHooks Function()
        > {
  $$AjustesTableTableManager(_$KipuDb db, $AjustesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AjustesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AjustesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AjustesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> clave = const Value.absent(),
            Value<String> valor = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AjustesCompanion(clave: clave, valor: valor, rowid: rowid),
          createCompanionCallback:
              ({
                required String clave,
                required String valor,
                Value<int> rowid = const Value.absent(),
              }) => AjustesCompanion.insert(
                clave: clave,
                valor: valor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AjustesTable, Ajuste>(table),
                  BaseReferences<_$KipuDb, $AjustesTable, Ajuste>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AjustesTableProcessedTableManager =
    ProcessedTableManager<
      _$KipuDb,
      $AjustesTable,
      Ajuste,
      $$AjustesTableFilterComposer,
      $$AjustesTableOrderingComposer,
      $$AjustesTableAnnotationComposer,
      $$AjustesTableCreateCompanionBuilder,
      $$AjustesTableUpdateCompanionBuilder,
      (Ajuste, BaseReferences<_$KipuDb, $AjustesTable, Ajuste>),
      Ajuste,
      PrefetchHooks Function()
    >;
typedef $$ColegiosTableCreateCompanionBuilder = ColegiosCompanion Function({
  Value<int> id,
  required String nombre,
  Value<String?> lugar,
  Value<int?> color,
  Value<String> pais,
  Value<DateTime> creado,
});
typedef $$ColegiosTableUpdateCompanionBuilder = ColegiosCompanion Function({
  Value<int> id,
  Value<String> nombre,
  Value<String?> lugar,
  Value<int?> color,
  Value<String> pais,
  Value<DateTime> creado,
});

final class $$ColegiosTableReferences
    extends BaseReferences<_$KipuDb, $ColegiosTable, Colegio> {
  $$ColegiosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CursosTable, List<Curso>> _cursosRefsTable(
    _$KipuDb db,
  ) => MultiTypedResultKey.fromTable(
    db.cursos,
    aliasName: 'colegios__id__cursos__colegio_id',
  );

  $$CursosTableProcessedTableManager get cursosRefs {
    final manager = $$CursosTableTableManager(
      $_db,
      $_db.cursos,
    ).filter((f) => f.colegioId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cursosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FranjasTable, List<Franja>> _franjasRefsTable(
    _$KipuDb db,
  ) => MultiTypedResultKey.fromTable(
    db.franjas,
    aliasName: 'colegios__id__franjas__colegio_id',
  );

  $$FranjasTableProcessedTableManager get franjasRefs {
    final manager = $$FranjasTableTableManager(
      $_db,
      $_db.franjas,
    ).filter((f) => f.colegioId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_franjasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ColegiosTableFilterComposer extends Composer<_$KipuDb, $ColegiosTable> {
  $$ColegiosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lugar => $composableBuilder(
    column: $table.lugar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pais => $composableBuilder(
    column: $table.pais,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creado => $composableBuilder(
    column: $table.creado,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cursosRefs(
    Expression<bool> Function($$CursosTableFilterComposer f) f,
  ) {
    final $$CursosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cursos,
      getReferencedColumn: (t) => t.colegioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CursosTableFilterComposer(
            $db: $db,
            $table: $db.cursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> franjasRefs(
    Expression<bool> Function($$FranjasTableFilterComposer f) f,
  ) {
    final $$FranjasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.franjas,
      getReferencedColumn: (t) => t.colegioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FranjasTableFilterComposer(
            $db: $db,
            $table: $db.franjas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ColegiosTableOrderingComposer
    extends Composer<_$KipuDb, $ColegiosTable> {
  $$ColegiosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lugar => $composableBuilder(
    column: $table.lugar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pais => $composableBuilder(
    column: $table.pais,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creado => $composableBuilder(
    column: $table.creado,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ColegiosTableAnnotationComposer
    extends Composer<_$KipuDb, $ColegiosTable> {
  $$ColegiosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get lugar =>
      $composableBuilder(column: $table.lugar, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get pais =>
      $composableBuilder(column: $table.pais, builder: (column) => column);

  GeneratedColumn<DateTime> get creado =>
      $composableBuilder(column: $table.creado, builder: (column) => column);

  Expression<T> cursosRefs<T extends Object>(
    Expression<T> Function($$CursosTableAnnotationComposer a) f,
  ) {
    final $$CursosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cursos,
      getReferencedColumn: (t) => t.colegioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CursosTableAnnotationComposer(
            $db: $db,
            $table: $db.cursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> franjasRefs<T extends Object>(
    Expression<T> Function($$FranjasTableAnnotationComposer a) f,
  ) {
    final $$FranjasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.franjas,
      getReferencedColumn: (t) => t.colegioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FranjasTableAnnotationComposer(
            $db: $db,
            $table: $db.franjas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ColegiosTableTableManager
    extends
        RootTableManager<
          _$KipuDb,
          $ColegiosTable,
          Colegio,
          $$ColegiosTableFilterComposer,
          $$ColegiosTableOrderingComposer,
          $$ColegiosTableAnnotationComposer,
          $$ColegiosTableCreateCompanionBuilder,
          $$ColegiosTableUpdateCompanionBuilder,
          (Colegio, $$ColegiosTableReferences),
          Colegio,
          PrefetchHooks Function({bool cursosRefs, bool franjasRefs})
        > {
  $$ColegiosTableTableManager(_$KipuDb db, $ColegiosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ColegiosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ColegiosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ColegiosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> lugar = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<String> pais = const Value.absent(),
                Value<DateTime> creado = const Value.absent(),
              }) => ColegiosCompanion(
                id: id,
                nombre: nombre,
                lugar: lugar,
                color: color,
                pais: pais,
                creado: creado,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                Value<String?> lugar = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<String> pais = const Value.absent(),
                Value<DateTime> creado = const Value.absent(),
              }) => ColegiosCompanion.insert(
                id: id,
                nombre: nombre,
                lugar: lugar,
                color: color,
                pais: pais,
                creado: creado,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ColegiosTable, Colegio>(table),
                  $$ColegiosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cursosRefs = false, franjasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (cursosRefs) db.cursos,
                if (franjasRefs) db.franjas,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cursosRefs)
                    await $_getPrefetchedDataByColumns<
                      Colegio,
                      $ColegiosTable,
                      Curso,
                      $CursosTable
                    >(
                      currentTable: table,
                      referencedTable: $$ColegiosTableReferences
                          ._cursosRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ColegiosTableReferences(db, table, p0).cursosRefs,
                      currentColumn: 'id',
                      referencedColumn: 'colegio_id',
                      typedResults: items,
                    ),
                  if (franjasRefs)
                    await $_getPrefetchedDataByColumns<
                      Colegio,
                      $ColegiosTable,
                      Franja,
                      $FranjasTable
                    >(
                      currentTable: table,
                      referencedTable: $$ColegiosTableReferences
                          ._franjasRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ColegiosTableReferences(db, table, p0).franjasRefs,
                      currentColumn: 'id',
                      referencedColumn: 'colegio_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ColegiosTableProcessedTableManager =
    ProcessedTableManager<
      _$KipuDb,
      $ColegiosTable,
      Colegio,
      $$ColegiosTableFilterComposer,
      $$ColegiosTableOrderingComposer,
      $$ColegiosTableAnnotationComposer,
      $$ColegiosTableCreateCompanionBuilder,
      $$ColegiosTableUpdateCompanionBuilder,
      (Colegio, $$ColegiosTableReferences),
      Colegio,
      PrefetchHooks Function({bool cursosRefs, bool franjasRefs})
    >;
typedef $$CursosTableCreateCompanionBuilder = CursosCompanion Function({
  Value<int> id,
  required int colegioId,
  required String nivel,
  required String grado,
  required String seccion,
  required String nombre,
  Value<String?> area,
  Value<String?> tutor,
  Value<String?> tutorCelular,
  Value<DateTime> creado,
});
typedef $$CursosTableUpdateCompanionBuilder = CursosCompanion Function({
  Value<int> id,
  Value<int> colegioId,
  Value<String> nivel,
  Value<String> grado,
  Value<String> seccion,
  Value<String> nombre,
  Value<String?> area,
  Value<String?> tutor,
  Value<String?> tutorCelular,
  Value<DateTime> creado,
});

final class $$CursosTableReferences
    extends BaseReferences<_$KipuDb, $CursosTable, Curso> {
  $$CursosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ColegiosTable _colegioIdTable(_$KipuDb db) =>
      db.colegios.createAlias('cursos__colegio_id__colegios__id');

  $$ColegiosTableProcessedTableManager get colegioId {
    final $_column = $_itemColumn<int>('colegio_id')!;

    final manager = $$ColegiosTableTableManager(
      $_db,
      $_db.colegios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_colegioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EstudiantesTable, List<Estudiante>>
  _estudiantesRefsTable(_$KipuDb db) => MultiTypedResultKey.fromTable(
    db.estudiantes,
    aliasName: 'cursos__id__estudiantes__curso_id',
  );

  $$EstudiantesTableProcessedTableManager get estudiantesRefs {
    final manager = $$EstudiantesTableTableManager(
      $_db,
      $_db.estudiantes,
    ).filter((f) => f.cursoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_estudiantesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$HorariosTable, List<Horario>> _horariosRefsTable(
    _$KipuDb db,
  ) => MultiTypedResultKey.fromTable(
    db.horarios,
    aliasName: 'cursos__id__horarios__curso_id',
  );

  $$HorariosTableProcessedTableManager get horariosRefs {
    final manager = $$HorariosTableTableManager(
      $_db,
      $_db.horarios,
    ).filter((f) => f.cursoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_horariosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RegistroColumnasTable, List<RegistroColumna>>
  _registroColumnasRefsTable(_$KipuDb db) => MultiTypedResultKey.fromTable(
    db.registroColumnas,
    aliasName: 'cursos__id__registro_columnas__curso_id',
  );

  $$RegistroColumnasTableProcessedTableManager get registroColumnasRefs {
    final manager = $$RegistroColumnasTableTableManager(
      $_db,
      $_db.registroColumnas,
    ).filter((f) => f.cursoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _registroColumnasRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ClasesDiarioTable, List<ClaseDiario>>
  _clasesDiarioRefsTable(_$KipuDb db) => MultiTypedResultKey.fromTable(
    db.clasesDiario,
    aliasName: 'cursos__id__clases_diario__curso_id',
  );

  $$ClasesDiarioTableProcessedTableManager get clasesDiarioRefs {
    final manager = $$ClasesDiarioTableTableManager(
      $_db,
      $_db.clasesDiario,
    ).filter((f) => f.cursoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_clasesDiarioRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UnidadesTable, List<Unidad>> _unidadesRefsTable(
    _$KipuDb db,
  ) => MultiTypedResultKey.fromTable(
    db.unidades,
    aliasName: 'cursos__id__unidades__curso_id',
  );

  $$UnidadesTableProcessedTableManager get unidadesRefs {
    final manager = $$UnidadesTableTableManager(
      $_db,
      $_db.unidades,
    ).filter((f) => f.cursoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_unidadesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CursosTableFilterComposer extends Composer<_$KipuDb, $CursosTable> {
  $$CursosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nivel => $composableBuilder(
    column: $table.nivel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grado => $composableBuilder(
    column: $table.grado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seccion => $composableBuilder(
    column: $table.seccion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tutor => $composableBuilder(
    column: $table.tutor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tutorCelular => $composableBuilder(
    column: $table.tutorCelular,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creado => $composableBuilder(
    column: $table.creado,
    builder: (column) => ColumnFilters(column),
  );

  $$ColegiosTableFilterComposer get colegioId {
    final $$ColegiosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.colegioId,
      referencedTable: $db.colegios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColegiosTableFilterComposer(
            $db: $db,
            $table: $db.colegios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> estudiantesRefs(
    Expression<bool> Function($$EstudiantesTableFilterComposer f) f,
  ) {
    final $$EstudiantesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.estudiantes,
      getReferencedColumn: (t) => t.cursoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstudiantesTableFilterComposer(
            $db: $db,
            $table: $db.estudiantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> horariosRefs(
    Expression<bool> Function($$HorariosTableFilterComposer f) f,
  ) {
    final $$HorariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.horarios,
      getReferencedColumn: (t) => t.cursoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HorariosTableFilterComposer(
            $db: $db,
            $table: $db.horarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> registroColumnasRefs(
    Expression<bool> Function($$RegistroColumnasTableFilterComposer f) f,
  ) {
    final $$RegistroColumnasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.registroColumnas,
      getReferencedColumn: (t) => t.cursoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegistroColumnasTableFilterComposer(
            $db: $db,
            $table: $db.registroColumnas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> clasesDiarioRefs(
    Expression<bool> Function($$ClasesDiarioTableFilterComposer f) f,
  ) {
    final $$ClasesDiarioTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clasesDiario,
      getReferencedColumn: (t) => t.cursoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClasesDiarioTableFilterComposer(
            $db: $db,
            $table: $db.clasesDiario,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> unidadesRefs(
    Expression<bool> Function($$UnidadesTableFilterComposer f) f,
  ) {
    final $$UnidadesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.unidades,
      getReferencedColumn: (t) => t.cursoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnidadesTableFilterComposer(
            $db: $db,
            $table: $db.unidades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CursosTableOrderingComposer extends Composer<_$KipuDb, $CursosTable> {
  $$CursosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nivel => $composableBuilder(
    column: $table.nivel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grado => $composableBuilder(
    column: $table.grado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seccion => $composableBuilder(
    column: $table.seccion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tutor => $composableBuilder(
    column: $table.tutor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tutorCelular => $composableBuilder(
    column: $table.tutorCelular,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creado => $composableBuilder(
    column: $table.creado,
    builder: (column) => ColumnOrderings(column),
  );

  $$ColegiosTableOrderingComposer get colegioId {
    final $$ColegiosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.colegioId,
      referencedTable: $db.colegios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColegiosTableOrderingComposer(
            $db: $db,
            $table: $db.colegios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CursosTableAnnotationComposer extends Composer<_$KipuDb, $CursosTable> {
  $$CursosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nivel =>
      $composableBuilder(column: $table.nivel, builder: (column) => column);

  GeneratedColumn<String> get grado =>
      $composableBuilder(column: $table.grado, builder: (column) => column);

  GeneratedColumn<String> get seccion =>
      $composableBuilder(column: $table.seccion, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get area =>
      $composableBuilder(column: $table.area, builder: (column) => column);

  GeneratedColumn<String> get tutor =>
      $composableBuilder(column: $table.tutor, builder: (column) => column);

  GeneratedColumn<String> get tutorCelular => $composableBuilder(
    column: $table.tutorCelular,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get creado =>
      $composableBuilder(column: $table.creado, builder: (column) => column);

  $$ColegiosTableAnnotationComposer get colegioId {
    final $$ColegiosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.colegioId,
      referencedTable: $db.colegios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColegiosTableAnnotationComposer(
            $db: $db,
            $table: $db.colegios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> estudiantesRefs<T extends Object>(
    Expression<T> Function($$EstudiantesTableAnnotationComposer a) f,
  ) {
    final $$EstudiantesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.estudiantes,
      getReferencedColumn: (t) => t.cursoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstudiantesTableAnnotationComposer(
            $db: $db,
            $table: $db.estudiantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> horariosRefs<T extends Object>(
    Expression<T> Function($$HorariosTableAnnotationComposer a) f,
  ) {
    final $$HorariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.horarios,
      getReferencedColumn: (t) => t.cursoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HorariosTableAnnotationComposer(
            $db: $db,
            $table: $db.horarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> registroColumnasRefs<T extends Object>(
    Expression<T> Function($$RegistroColumnasTableAnnotationComposer a) f,
  ) {
    final $$RegistroColumnasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.registroColumnas,
      getReferencedColumn: (t) => t.cursoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegistroColumnasTableAnnotationComposer(
            $db: $db,
            $table: $db.registroColumnas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> clasesDiarioRefs<T extends Object>(
    Expression<T> Function($$ClasesDiarioTableAnnotationComposer a) f,
  ) {
    final $$ClasesDiarioTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.clasesDiario,
      getReferencedColumn: (t) => t.cursoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClasesDiarioTableAnnotationComposer(
            $db: $db,
            $table: $db.clasesDiario,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> unidadesRefs<T extends Object>(
    Expression<T> Function($$UnidadesTableAnnotationComposer a) f,
  ) {
    final $$UnidadesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.unidades,
      getReferencedColumn: (t) => t.cursoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnidadesTableAnnotationComposer(
            $db: $db,
            $table: $db.unidades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CursosTableTableManager
    extends
        RootTableManager<
          _$KipuDb,
          $CursosTable,
          Curso,
          $$CursosTableFilterComposer,
          $$CursosTableOrderingComposer,
          $$CursosTableAnnotationComposer,
          $$CursosTableCreateCompanionBuilder,
          $$CursosTableUpdateCompanionBuilder,
          (Curso, $$CursosTableReferences),
          Curso,
          PrefetchHooks Function({
            bool colegioId,
            bool estudiantesRefs,
            bool horariosRefs,
            bool registroColumnasRefs,
            bool clasesDiarioRefs,
            bool unidadesRefs,
          })
        > {
  $$CursosTableTableManager(_$KipuDb db, $CursosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CursosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CursosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CursosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> colegioId = const Value.absent(),
                Value<String> nivel = const Value.absent(),
                Value<String> grado = const Value.absent(),
                Value<String> seccion = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> area = const Value.absent(),
                Value<String?> tutor = const Value.absent(),
                Value<String?> tutorCelular = const Value.absent(),
                Value<DateTime> creado = const Value.absent(),
              }) => CursosCompanion(
                id: id,
                colegioId: colegioId,
                nivel: nivel,
                grado: grado,
                seccion: seccion,
                nombre: nombre,
                area: area,
                tutor: tutor,
                tutorCelular: tutorCelular,
                creado: creado,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int colegioId,
                required String nivel,
                required String grado,
                required String seccion,
                required String nombre,
                Value<String?> area = const Value.absent(),
                Value<String?> tutor = const Value.absent(),
                Value<String?> tutorCelular = const Value.absent(),
                Value<DateTime> creado = const Value.absent(),
              }) => CursosCompanion.insert(
                id: id,
                colegioId: colegioId,
                nivel: nivel,
                grado: grado,
                seccion: seccion,
                nombre: nombre,
                area: area,
                tutor: tutor,
                tutorCelular: tutorCelular,
                creado: creado,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CursosTable, Curso>(table),
                  $$CursosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                colegioId = false,
                estudiantesRefs = false,
                horariosRefs = false,
                registroColumnasRefs = false,
                clasesDiarioRefs = false,
                unidadesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (estudiantesRefs) db.estudiantes,
                    if (horariosRefs) db.horarios,
                    if (registroColumnasRefs) db.registroColumnas,
                    if (clasesDiarioRefs) db.clasesDiario,
                    if (unidadesRefs) db.unidades,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (colegioId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.colegioId,
                            referencedTable: $$CursosTableReferences
                                ._colegioIdTable(db),
                            referencedColumn: $$CursosTableReferences
                                ._colegioIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (estudiantesRefs)
                        await $_getPrefetchedDataByColumns<
                          Curso,
                          $CursosTable,
                          Estudiante,
                          $EstudiantesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CursosTableReferences
                              ._estudiantesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CursosTableReferences(
                                db,
                                table,
                                p0,
                              ).estudiantesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'curso_id',
                          typedResults: items,
                        ),
                      if (horariosRefs)
                        await $_getPrefetchedDataByColumns<
                          Curso,
                          $CursosTable,
                          Horario,
                          $HorariosTable
                        >(
                          currentTable: table,
                          referencedTable: $$CursosTableReferences
                              ._horariosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CursosTableReferences(
                                db,
                                table,
                                p0,
                              ).horariosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'curso_id',
                          typedResults: items,
                        ),
                      if (registroColumnasRefs)
                        await $_getPrefetchedDataByColumns<
                          Curso,
                          $CursosTable,
                          RegistroColumna,
                          $RegistroColumnasTable
                        >(
                          currentTable: table,
                          referencedTable: $$CursosTableReferences
                              ._registroColumnasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CursosTableReferences(
                                db,
                                table,
                                p0,
                              ).registroColumnasRefs,
                          currentColumn: 'id',
                          referencedColumn: 'curso_id',
                          typedResults: items,
                        ),
                      if (clasesDiarioRefs)
                        await $_getPrefetchedDataByColumns<
                          Curso,
                          $CursosTable,
                          ClaseDiario,
                          $ClasesDiarioTable
                        >(
                          currentTable: table,
                          referencedTable: $$CursosTableReferences
                              ._clasesDiarioRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CursosTableReferences(
                                db,
                                table,
                                p0,
                              ).clasesDiarioRefs,
                          currentColumn: 'id',
                          referencedColumn: 'curso_id',
                          typedResults: items,
                        ),
                      if (unidadesRefs)
                        await $_getPrefetchedDataByColumns<
                          Curso,
                          $CursosTable,
                          Unidad,
                          $UnidadesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CursosTableReferences
                              ._unidadesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CursosTableReferences(
                                db,
                                table,
                                p0,
                              ).unidadesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'curso_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CursosTableProcessedTableManager =
    ProcessedTableManager<
      _$KipuDb,
      $CursosTable,
      Curso,
      $$CursosTableFilterComposer,
      $$CursosTableOrderingComposer,
      $$CursosTableAnnotationComposer,
      $$CursosTableCreateCompanionBuilder,
      $$CursosTableUpdateCompanionBuilder,
      (Curso, $$CursosTableReferences),
      Curso,
      PrefetchHooks Function({
        bool colegioId,
        bool estudiantesRefs,
        bool horariosRefs,
        bool registroColumnasRefs,
        bool clasesDiarioRefs,
        bool unidadesRefs,
      })
    >;
typedef $$EstudiantesTableCreateCompanionBuilder =
    EstudiantesCompanion Function({
      Value<int> id,
      required int cursoId,
      required String apellidos,
      required String nombres,
      Value<String?> dni,
      Value<String?> apoderado,
      Value<String?> parentesco,
      Value<String?> telefono,
      Value<String?> apoderado2,
      Value<String?> parentesco2,
      Value<String?> telefono2,
      Value<String?> nacimiento,
      Value<String?> observaciones,
      Value<String?> codigo,
      Value<String?> clave,
      Value<Uint8List?> foto,
      Value<int> desde,
      Value<int?> hasta,
      Value<DateTime> creado,
    });
typedef $$EstudiantesTableUpdateCompanionBuilder =
    EstudiantesCompanion Function({
      Value<int> id,
      Value<int> cursoId,
      Value<String> apellidos,
      Value<String> nombres,
      Value<String?> dni,
      Value<String?> apoderado,
      Value<String?> parentesco,
      Value<String?> telefono,
      Value<String?> apoderado2,
      Value<String?> parentesco2,
      Value<String?> telefono2,
      Value<String?> nacimiento,
      Value<String?> observaciones,
      Value<String?> codigo,
      Value<String?> clave,
      Value<Uint8List?> foto,
      Value<int> desde,
      Value<int?> hasta,
      Value<DateTime> creado,
    });

final class $$EstudiantesTableReferences
    extends BaseReferences<_$KipuDb, $EstudiantesTable, Estudiante> {
  $$EstudiantesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CursosTable _cursoIdTable(_$KipuDb db) =>
      db.cursos.createAlias('estudiantes__curso_id__cursos__id');

  $$CursosTableProcessedTableManager get cursoId {
    final $_column = $_itemColumn<int>('curso_id')!;

    final manager = $$CursosTableTableManager(
      $_db,
      $_db.cursos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cursoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AsistenciasTable, List<Asistencia>>
  _asistenciasRefsTable(_$KipuDb db) => MultiTypedResultKey.fromTable(
    db.asistencias,
    aliasName: 'estudiantes__id__asistencias__estudiante_id',
  );

  $$AsistenciasTableProcessedTableManager get asistenciasRefs {
    final manager = $$AsistenciasTableTableManager(
      $_db,
      $_db.asistencias,
    ).filter((f) => f.estudianteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_asistenciasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NotasTable, List<Nota>> _notasRefsTable(
    _$KipuDb db,
  ) => MultiTypedResultKey.fromTable(
    db.notas,
    aliasName: 'estudiantes__id__notas__estudiante_id',
  );

  $$NotasTableProcessedTableManager get notasRefs {
    final manager = $$NotasTableTableManager(
      $_db,
      $_db.notas,
    ).filter((f) => f.estudianteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_notasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RegistroNotasTable, List<RegistroNota>>
  _registroNotasRefsTable(_$KipuDb db) => MultiTypedResultKey.fromTable(
    db.registroNotas,
    aliasName: 'estudiantes__id__registro_notas__estudiante_id',
  );

  $$RegistroNotasTableProcessedTableManager get registroNotasRefs {
    final manager = $$RegistroNotasTableTableManager(
      $_db,
      $_db.registroNotas,
    ).filter((f) => f.estudianteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_registroNotasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConductasTable, List<Conducta>>
  _conductasRefsTable(_$KipuDb db) => MultiTypedResultKey.fromTable(
    db.conductas,
    aliasName: 'estudiantes__id__conductas__estudiante_id',
  );

  $$ConductasTableProcessedTableManager get conductasRefs {
    final manager = $$ConductasTableTableManager(
      $_db,
      $_db.conductas,
    ).filter((f) => f.estudianteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_conductasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AnecdotasTable, List<Anecdota>>
  _anecdotasRefsTable(_$KipuDb db) => MultiTypedResultKey.fromTable(
    db.anecdotas,
    aliasName: 'estudiantes__id__anecdotas__estudiante_id',
  );

  $$AnecdotasTableProcessedTableManager get anecdotasRefs {
    final manager = $$AnecdotasTableTableManager(
      $_db,
      $_db.anecdotas,
    ).filter((f) => f.estudianteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_anecdotasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EstudiantesTableFilterComposer
    extends Composer<_$KipuDb, $EstudiantesTable> {
  $$EstudiantesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apellidos => $composableBuilder(
    column: $table.apellidos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombres => $composableBuilder(
    column: $table.nombres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dni => $composableBuilder(
    column: $table.dni,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apoderado => $composableBuilder(
    column: $table.apoderado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentesco => $composableBuilder(
    column: $table.parentesco,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apoderado2 => $composableBuilder(
    column: $table.apoderado2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentesco2 => $composableBuilder(
    column: $table.parentesco2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefono2 => $composableBuilder(
    column: $table.telefono2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nacimiento => $composableBuilder(
    column: $table.nacimiento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get foto => $composableBuilder(
    column: $table.foto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get desde => $composableBuilder(
    column: $table.desde,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hasta => $composableBuilder(
    column: $table.hasta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creado => $composableBuilder(
    column: $table.creado,
    builder: (column) => ColumnFilters(column),
  );

  $$CursosTableFilterComposer get cursoId {
    final $$CursosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cursoId,
      referencedTable: $db.cursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CursosTableFilterComposer(
            $db: $db,
            $table: $db.cursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> asistenciasRefs(
    Expression<bool> Function($$AsistenciasTableFilterComposer f) f,
  ) {
    final $$AsistenciasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.asistencias,
      getReferencedColumn: (t) => t.estudianteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AsistenciasTableFilterComposer(
            $db: $db,
            $table: $db.asistencias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> notasRefs(
    Expression<bool> Function($$NotasTableFilterComposer f) f,
  ) {
    final $$NotasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notas,
      getReferencedColumn: (t) => t.estudianteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotasTableFilterComposer(
            $db: $db,
            $table: $db.notas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> registroNotasRefs(
    Expression<bool> Function($$RegistroNotasTableFilterComposer f) f,
  ) {
    final $$RegistroNotasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.registroNotas,
      getReferencedColumn: (t) => t.estudianteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegistroNotasTableFilterComposer(
            $db: $db,
            $table: $db.registroNotas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> conductasRefs(
    Expression<bool> Function($$ConductasTableFilterComposer f) f,
  ) {
    final $$ConductasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conductas,
      getReferencedColumn: (t) => t.estudianteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConductasTableFilterComposer(
            $db: $db,
            $table: $db.conductas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> anecdotasRefs(
    Expression<bool> Function($$AnecdotasTableFilterComposer f) f,
  ) {
    final $$AnecdotasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.anecdotas,
      getReferencedColumn: (t) => t.estudianteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnecdotasTableFilterComposer(
            $db: $db,
            $table: $db.anecdotas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EstudiantesTableOrderingComposer
    extends Composer<_$KipuDb, $EstudiantesTable> {
  $$EstudiantesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apellidos => $composableBuilder(
    column: $table.apellidos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombres => $composableBuilder(
    column: $table.nombres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dni => $composableBuilder(
    column: $table.dni,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apoderado => $composableBuilder(
    column: $table.apoderado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentesco => $composableBuilder(
    column: $table.parentesco,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apoderado2 => $composableBuilder(
    column: $table.apoderado2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentesco2 => $composableBuilder(
    column: $table.parentesco2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefono2 => $composableBuilder(
    column: $table.telefono2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nacimiento => $composableBuilder(
    column: $table.nacimiento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get foto => $composableBuilder(
    column: $table.foto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get desde => $composableBuilder(
    column: $table.desde,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hasta => $composableBuilder(
    column: $table.hasta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creado => $composableBuilder(
    column: $table.creado,
    builder: (column) => ColumnOrderings(column),
  );

  $$CursosTableOrderingComposer get cursoId {
    final $$CursosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cursoId,
      referencedTable: $db.cursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CursosTableOrderingComposer(
            $db: $db,
            $table: $db.cursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EstudiantesTableAnnotationComposer
    extends Composer<_$KipuDb, $EstudiantesTable> {
  $$EstudiantesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get apellidos =>
      $composableBuilder(column: $table.apellidos, builder: (column) => column);

  GeneratedColumn<String> get nombres =>
      $composableBuilder(column: $table.nombres, builder: (column) => column);

  GeneratedColumn<String> get dni =>
      $composableBuilder(column: $table.dni, builder: (column) => column);

  GeneratedColumn<String> get apoderado =>
      $composableBuilder(column: $table.apoderado, builder: (column) => column);

  GeneratedColumn<String> get parentesco => $composableBuilder(
    column: $table.parentesco,
    builder: (column) => column,
  );

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<String> get apoderado2 => $composableBuilder(
    column: $table.apoderado2,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentesco2 => $composableBuilder(
    column: $table.parentesco2,
    builder: (column) => column,
  );

  GeneratedColumn<String> get telefono2 =>
      $composableBuilder(column: $table.telefono2, builder: (column) => column);

  GeneratedColumn<String> get nacimiento => $composableBuilder(
    column: $table.nacimiento,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => column,
  );

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get clave =>
      $composableBuilder(column: $table.clave, builder: (column) => column);

  GeneratedColumn<Uint8List> get foto =>
      $composableBuilder(column: $table.foto, builder: (column) => column);

  GeneratedColumn<int> get desde =>
      $composableBuilder(column: $table.desde, builder: (column) => column);

  GeneratedColumn<int> get hasta =>
      $composableBuilder(column: $table.hasta, builder: (column) => column);

  GeneratedColumn<DateTime> get creado =>
      $composableBuilder(column: $table.creado, builder: (column) => column);

  $$CursosTableAnnotationComposer get cursoId {
    final $$CursosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cursoId,
      referencedTable: $db.cursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CursosTableAnnotationComposer(
            $db: $db,
            $table: $db.cursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> asistenciasRefs<T extends Object>(
    Expression<T> Function($$AsistenciasTableAnnotationComposer a) f,
  ) {
    final $$AsistenciasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.asistencias,
      getReferencedColumn: (t) => t.estudianteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AsistenciasTableAnnotationComposer(
            $db: $db,
            $table: $db.asistencias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> notasRefs<T extends Object>(
    Expression<T> Function($$NotasTableAnnotationComposer a) f,
  ) {
    final $$NotasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notas,
      getReferencedColumn: (t) => t.estudianteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotasTableAnnotationComposer(
            $db: $db,
            $table: $db.notas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> registroNotasRefs<T extends Object>(
    Expression<T> Function($$RegistroNotasTableAnnotationComposer a) f,
  ) {
    final $$RegistroNotasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.registroNotas,
      getReferencedColumn: (t) => t.estudianteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegistroNotasTableAnnotationComposer(
            $db: $db,
            $table: $db.registroNotas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> conductasRefs<T extends Object>(
    Expression<T> Function($$ConductasTableAnnotationComposer a) f,
  ) {
    final $$ConductasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conductas,
      getReferencedColumn: (t) => t.estudianteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConductasTableAnnotationComposer(
            $db: $db,
            $table: $db.conductas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> anecdotasRefs<T extends Object>(
    Expression<T> Function($$AnecdotasTableAnnotationComposer a) f,
  ) {
    final $$AnecdotasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.anecdotas,
      getReferencedColumn: (t) => t.estudianteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AnecdotasTableAnnotationComposer(
            $db: $db,
            $table: $db.anecdotas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EstudiantesTableTableManager
    extends
        RootTableManager<
          _$KipuDb,
          $EstudiantesTable,
          Estudiante,
          $$EstudiantesTableFilterComposer,
          $$EstudiantesTableOrderingComposer,
          $$EstudiantesTableAnnotationComposer,
          $$EstudiantesTableCreateCompanionBuilder,
          $$EstudiantesTableUpdateCompanionBuilder,
          (Estudiante, $$EstudiantesTableReferences),
          Estudiante,
          PrefetchHooks Function({
            bool cursoId,
            bool asistenciasRefs,
            bool notasRefs,
            bool registroNotasRefs,
            bool conductasRefs,
            bool anecdotasRefs,
          })
        > {
  $$EstudiantesTableTableManager(_$KipuDb db, $EstudiantesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EstudiantesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EstudiantesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EstudiantesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cursoId = const Value.absent(),
                Value<String> apellidos = const Value.absent(),
                Value<String> nombres = const Value.absent(),
                Value<String?> dni = const Value.absent(),
                Value<String?> apoderado = const Value.absent(),
                Value<String?> parentesco = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<String?> apoderado2 = const Value.absent(),
                Value<String?> parentesco2 = const Value.absent(),
                Value<String?> telefono2 = const Value.absent(),
                Value<String?> nacimiento = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
                Value<String?> codigo = const Value.absent(),
                Value<String?> clave = const Value.absent(),
                Value<Uint8List?> foto = const Value.absent(),
                Value<int> desde = const Value.absent(),
                Value<int?> hasta = const Value.absent(),
                Value<DateTime> creado = const Value.absent(),
              }) => EstudiantesCompanion(
                id: id,
                cursoId: cursoId,
                apellidos: apellidos,
                nombres: nombres,
                dni: dni,
                apoderado: apoderado,
                parentesco: parentesco,
                telefono: telefono,
                apoderado2: apoderado2,
                parentesco2: parentesco2,
                telefono2: telefono2,
                nacimiento: nacimiento,
                observaciones: observaciones,
                codigo: codigo,
                clave: clave,
                foto: foto,
                desde: desde,
                hasta: hasta,
                creado: creado,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cursoId,
                required String apellidos,
                required String nombres,
                Value<String?> dni = const Value.absent(),
                Value<String?> apoderado = const Value.absent(),
                Value<String?> parentesco = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<String?> apoderado2 = const Value.absent(),
                Value<String?> parentesco2 = const Value.absent(),
                Value<String?> telefono2 = const Value.absent(),
                Value<String?> nacimiento = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
                Value<String?> codigo = const Value.absent(),
                Value<String?> clave = const Value.absent(),
                Value<Uint8List?> foto = const Value.absent(),
                Value<int> desde = const Value.absent(),
                Value<int?> hasta = const Value.absent(),
                Value<DateTime> creado = const Value.absent(),
              }) => EstudiantesCompanion.insert(
                id: id,
                cursoId: cursoId,
                apellidos: apellidos,
                nombres: nombres,
                dni: dni,
                apoderado: apoderado,
                parentesco: parentesco,
                telefono: telefono,
                apoderado2: apoderado2,
                parentesco2: parentesco2,
                telefono2: telefono2,
                nacimiento: nacimiento,
                observaciones: observaciones,
                codigo: codigo,
                clave: clave,
                foto: foto,
                desde: desde,
                hasta: hasta,
                creado: creado,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EstudiantesTable, Estudiante>(table),
                  $$EstudiantesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                cursoId = false,
                asistenciasRefs = false,
                notasRefs = false,
                registroNotasRefs = false,
                conductasRefs = false,
                anecdotasRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (asistenciasRefs) db.asistencias,
                    if (notasRefs) db.notas,
                    if (registroNotasRefs) db.registroNotas,
                    if (conductasRefs) db.conductas,
                    if (anecdotasRefs) db.anecdotas,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (cursoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.cursoId,
                            referencedTable: $$EstudiantesTableReferences
                                ._cursoIdTable(db),
                            referencedColumn: $$EstudiantesTableReferences
                                ._cursoIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (asistenciasRefs)
                        await $_getPrefetchedDataByColumns<
                          Estudiante,
                          $EstudiantesTable,
                          Asistencia,
                          $AsistenciasTable
                        >(
                          currentTable: table,
                          referencedTable: $$EstudiantesTableReferences
                              ._asistenciasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EstudiantesTableReferences(
                                db,
                                table,
                                p0,
                              ).asistenciasRefs,
                          currentColumn: 'id',
                          referencedColumn: 'estudiante_id',
                          typedResults: items,
                        ),
                      if (notasRefs)
                        await $_getPrefetchedDataByColumns<
                          Estudiante,
                          $EstudiantesTable,
                          Nota,
                          $NotasTable
                        >(
                          currentTable: table,
                          referencedTable: $$EstudiantesTableReferences
                              ._notasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EstudiantesTableReferences(
                                db,
                                table,
                                p0,
                              ).notasRefs,
                          currentColumn: 'id',
                          referencedColumn: 'estudiante_id',
                          typedResults: items,
                        ),
                      if (registroNotasRefs)
                        await $_getPrefetchedDataByColumns<
                          Estudiante,
                          $EstudiantesTable,
                          RegistroNota,
                          $RegistroNotasTable
                        >(
                          currentTable: table,
                          referencedTable: $$EstudiantesTableReferences
                              ._registroNotasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EstudiantesTableReferences(
                                db,
                                table,
                                p0,
                              ).registroNotasRefs,
                          currentColumn: 'id',
                          referencedColumn: 'estudiante_id',
                          typedResults: items,
                        ),
                      if (conductasRefs)
                        await $_getPrefetchedDataByColumns<
                          Estudiante,
                          $EstudiantesTable,
                          Conducta,
                          $ConductasTable
                        >(
                          currentTable: table,
                          referencedTable: $$EstudiantesTableReferences
                              ._conductasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EstudiantesTableReferences(
                                db,
                                table,
                                p0,
                              ).conductasRefs,
                          currentColumn: 'id',
                          referencedColumn: 'estudiante_id',
                          typedResults: items,
                        ),
                      if (anecdotasRefs)
                        await $_getPrefetchedDataByColumns<
                          Estudiante,
                          $EstudiantesTable,
                          Anecdota,
                          $AnecdotasTable
                        >(
                          currentTable: table,
                          referencedTable: $$EstudiantesTableReferences
                              ._anecdotasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EstudiantesTableReferences(
                                db,
                                table,
                                p0,
                              ).anecdotasRefs,
                          currentColumn: 'id',
                          referencedColumn: 'estudiante_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EstudiantesTableProcessedTableManager =
    ProcessedTableManager<
      _$KipuDb,
      $EstudiantesTable,
      Estudiante,
      $$EstudiantesTableFilterComposer,
      $$EstudiantesTableOrderingComposer,
      $$EstudiantesTableAnnotationComposer,
      $$EstudiantesTableCreateCompanionBuilder,
      $$EstudiantesTableUpdateCompanionBuilder,
      (Estudiante, $$EstudiantesTableReferences),
      Estudiante,
      PrefetchHooks Function({
        bool cursoId,
        bool asistenciasRefs,
        bool notasRefs,
        bool registroNotasRefs,
        bool conductasRefs,
        bool anecdotasRefs,
      })
    >;
typedef $$AsistenciasTableCreateCompanionBuilder =
    AsistenciasCompanion Function({
      required int estudianteId,
      required String fecha,
      required String estado,
      Value<String?> motivo,
      Value<String?> nota,
      Value<int> rowid,
    });
typedef $$AsistenciasTableUpdateCompanionBuilder =
    AsistenciasCompanion Function({
      Value<int> estudianteId,
      Value<String> fecha,
      Value<String> estado,
      Value<String?> motivo,
      Value<String?> nota,
      Value<int> rowid,
    });

final class $$AsistenciasTableReferences
    extends BaseReferences<_$KipuDb, $AsistenciasTable, Asistencia> {
  $$AsistenciasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EstudiantesTable _estudianteIdTable(_$KipuDb db) =>
      db.estudiantes.createAlias('asistencias__estudiante_id__estudiantes__id');

  $$EstudiantesTableProcessedTableManager get estudianteId {
    final $_column = $_itemColumn<int>('estudiante_id')!;

    final manager = $$EstudiantesTableTableManager(
      $_db,
      $_db.estudiantes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_estudianteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AsistenciasTableFilterComposer
    extends Composer<_$KipuDb, $AsistenciasTable> {
  $$AsistenciasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motivo => $composableBuilder(
    column: $table.motivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnFilters(column),
  );

  $$EstudiantesTableFilterComposer get estudianteId {
    final $$EstudiantesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.estudianteId,
      referencedTable: $db.estudiantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstudiantesTableFilterComposer(
            $db: $db,
            $table: $db.estudiantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AsistenciasTableOrderingComposer
    extends Composer<_$KipuDb, $AsistenciasTable> {
  $$AsistenciasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motivo => $composableBuilder(
    column: $table.motivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnOrderings(column),
  );

  $$EstudiantesTableOrderingComposer get estudianteId {
    final $$EstudiantesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.estudianteId,
      referencedTable: $db.estudiantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstudiantesTableOrderingComposer(
            $db: $db,
            $table: $db.estudiantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AsistenciasTableAnnotationComposer
    extends Composer<_$KipuDb, $AsistenciasTable> {
  $$AsistenciasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get motivo =>
      $composableBuilder(column: $table.motivo, builder: (column) => column);

  GeneratedColumn<String> get nota =>
      $composableBuilder(column: $table.nota, builder: (column) => column);

  $$EstudiantesTableAnnotationComposer get estudianteId {
    final $$EstudiantesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.estudianteId,
      referencedTable: $db.estudiantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstudiantesTableAnnotationComposer(
            $db: $db,
            $table: $db.estudiantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AsistenciasTableTableManager
    extends
        RootTableManager<
          _$KipuDb,
          $AsistenciasTable,
          Asistencia,
          $$AsistenciasTableFilterComposer,
          $$AsistenciasTableOrderingComposer,
          $$AsistenciasTableAnnotationComposer,
          $$AsistenciasTableCreateCompanionBuilder,
          $$AsistenciasTableUpdateCompanionBuilder,
          (Asistencia, $$AsistenciasTableReferences),
          Asistencia,
          PrefetchHooks Function({bool estudianteId})
        > {
  $$AsistenciasTableTableManager(_$KipuDb db, $AsistenciasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AsistenciasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AsistenciasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AsistenciasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> estudianteId = const Value.absent(),
                Value<String> fecha = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<String?> motivo = const Value.absent(),
                Value<String?> nota = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AsistenciasCompanion(
                estudianteId: estudianteId,
                fecha: fecha,
                estado: estado,
                motivo: motivo,
                nota: nota,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int estudianteId,
                required String fecha,
                required String estado,
                Value<String?> motivo = const Value.absent(),
                Value<String?> nota = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AsistenciasCompanion.insert(
                estudianteId: estudianteId,
                fecha: fecha,
                estado: estado,
                motivo: motivo,
                nota: nota,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AsistenciasTable, Asistencia>(table),
                  $$AsistenciasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({estudianteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (estudianteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.estudianteId,
                        referencedTable: $$AsistenciasTableReferences
                            ._estudianteIdTable(db),
                        referencedColumn: $$AsistenciasTableReferences
                            ._estudianteIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AsistenciasTableProcessedTableManager =
    ProcessedTableManager<
      _$KipuDb,
      $AsistenciasTable,
      Asistencia,
      $$AsistenciasTableFilterComposer,
      $$AsistenciasTableOrderingComposer,
      $$AsistenciasTableAnnotationComposer,
      $$AsistenciasTableCreateCompanionBuilder,
      $$AsistenciasTableUpdateCompanionBuilder,
      (Asistencia, $$AsistenciasTableReferences),
      Asistencia,
      PrefetchHooks Function({bool estudianteId})
    >;
typedef $$NotasTableCreateCompanionBuilder = NotasCompanion Function({
  Value<int> id,
  required int estudianteId,
  required int periodo,
  required String competencia,
  required String nota,
});
typedef $$NotasTableUpdateCompanionBuilder = NotasCompanion Function({
  Value<int> id,
  Value<int> estudianteId,
  Value<int> periodo,
  Value<String> competencia,
  Value<String> nota,
});

final class $$NotasTableReferences
    extends BaseReferences<_$KipuDb, $NotasTable, Nota> {
  $$NotasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EstudiantesTable _estudianteIdTable(_$KipuDb db) =>
      db.estudiantes.createAlias('notas__estudiante_id__estudiantes__id');

  $$EstudiantesTableProcessedTableManager get estudianteId {
    final $_column = $_itemColumn<int>('estudiante_id')!;

    final manager = $$EstudiantesTableTableManager(
      $_db,
      $_db.estudiantes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_estudianteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NotasTableFilterComposer extends Composer<_$KipuDb, $NotasTable> {
  $$NotasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodo => $composableBuilder(
    column: $table.periodo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get competencia => $composableBuilder(
    column: $table.competencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnFilters(column),
  );

  $$EstudiantesTableFilterComposer get estudianteId {
    final $$EstudiantesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.estudianteId,
      referencedTable: $db.estudiantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstudiantesTableFilterComposer(
            $db: $db,
            $table: $db.estudiantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotasTableOrderingComposer extends Composer<_$KipuDb, $NotasTable> {
  $$NotasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodo => $composableBuilder(
    column: $table.periodo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get competencia => $composableBuilder(
    column: $table.competencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnOrderings(column),
  );

  $$EstudiantesTableOrderingComposer get estudianteId {
    final $$EstudiantesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.estudianteId,
      referencedTable: $db.estudiantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstudiantesTableOrderingComposer(
            $db: $db,
            $table: $db.estudiantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotasTableAnnotationComposer extends Composer<_$KipuDb, $NotasTable> {
  $$NotasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get periodo =>
      $composableBuilder(column: $table.periodo, builder: (column) => column);

  GeneratedColumn<String> get competencia => $composableBuilder(
    column: $table.competencia,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nota =>
      $composableBuilder(column: $table.nota, builder: (column) => column);

  $$EstudiantesTableAnnotationComposer get estudianteId {
    final $$EstudiantesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.estudianteId,
      referencedTable: $db.estudiantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstudiantesTableAnnotationComposer(
            $db: $db,
            $table: $db.estudiantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotasTableTableManager
    extends
        RootTableManager<
          _$KipuDb,
          $NotasTable,
          Nota,
          $$NotasTableFilterComposer,
          $$NotasTableOrderingComposer,
          $$NotasTableAnnotationComposer,
          $$NotasTableCreateCompanionBuilder,
          $$NotasTableUpdateCompanionBuilder,
          (Nota, $$NotasTableReferences),
          Nota,
          PrefetchHooks Function({bool estudianteId})
        > {
  $$NotasTableTableManager(_$KipuDb db, $NotasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> estudianteId = const Value.absent(),
                Value<int> periodo = const Value.absent(),
                Value<String> competencia = const Value.absent(),
                Value<String> nota = const Value.absent(),
              }) => NotasCompanion(
                id: id,
                estudianteId: estudianteId,
                periodo: periodo,
                competencia: competencia,
                nota: nota,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int estudianteId,
                required int periodo,
                required String competencia,
                required String nota,
              }) => NotasCompanion.insert(
                id: id,
                estudianteId: estudianteId,
                periodo: periodo,
                competencia: competencia,
                nota: nota,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotasTable, Nota>(table),
                  $$NotasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({estudianteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (estudianteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.estudianteId,
                        referencedTable: $$NotasTableReferences
                            ._estudianteIdTable(db),
                        referencedColumn: $$NotasTableReferences
                            ._estudianteIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NotasTableProcessedTableManager =
    ProcessedTableManager<
      _$KipuDb,
      $NotasTable,
      Nota,
      $$NotasTableFilterComposer,
      $$NotasTableOrderingComposer,
      $$NotasTableAnnotationComposer,
      $$NotasTableCreateCompanionBuilder,
      $$NotasTableUpdateCompanionBuilder,
      (Nota, $$NotasTableReferences),
      Nota,
      PrefetchHooks Function({bool estudianteId})
    >;
typedef $$EventosTableCreateCompanionBuilder = EventosCompanion Function({
  Value<int> id,
  required String fecha,
  Value<String?> hora,
  required String titulo,
  Value<String?> etiqueta,
  Value<String> tipo,
  Value<int?> recordar,
  Value<String?> repetir,
  Value<int?> cursoId,
  Value<String?> detalle,
  Value<int?> colegioId,
});
typedef $$EventosTableUpdateCompanionBuilder = EventosCompanion Function({
  Value<int> id,
  Value<String> fecha,
  Value<String?> hora,
  Value<String> titulo,
  Value<String?> etiqueta,
  Value<String> tipo,
  Value<int?> recordar,
  Value<String?> repetir,
  Value<int?> cursoId,
  Value<String?> detalle,
  Value<int?> colegioId,
});

class $$EventosTableFilterComposer extends Composer<_$KipuDb, $EventosTable> {
  $$EventosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hora => $composableBuilder(
    column: $table.hora,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etiqueta => $composableBuilder(
    column: $table.etiqueta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordar => $composableBuilder(
    column: $table.recordar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repetir => $composableBuilder(
    column: $table.repetir,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cursoId => $composableBuilder(
    column: $table.cursoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detalle => $composableBuilder(
    column: $table.detalle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colegioId => $composableBuilder(
    column: $table.colegioId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventosTableOrderingComposer extends Composer<_$KipuDb, $EventosTable> {
  $$EventosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hora => $composableBuilder(
    column: $table.hora,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etiqueta => $composableBuilder(
    column: $table.etiqueta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordar => $composableBuilder(
    column: $table.recordar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repetir => $composableBuilder(
    column: $table.repetir,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cursoId => $composableBuilder(
    column: $table.cursoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detalle => $composableBuilder(
    column: $table.detalle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colegioId => $composableBuilder(
    column: $table.colegioId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventosTableAnnotationComposer
    extends Composer<_$KipuDb, $EventosTable> {
  $$EventosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get hora =>
      $composableBuilder(column: $table.hora, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<String> get etiqueta =>
      $composableBuilder(column: $table.etiqueta, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get recordar =>
      $composableBuilder(column: $table.recordar, builder: (column) => column);

  GeneratedColumn<String> get repetir =>
      $composableBuilder(column: $table.repetir, builder: (column) => column);

  GeneratedColumn<int> get cursoId =>
      $composableBuilder(column: $table.cursoId, builder: (column) => column);

  GeneratedColumn<String> get detalle =>
      $composableBuilder(column: $table.detalle, builder: (column) => column);

  GeneratedColumn<int> get colegioId =>
      $composableBuilder(column: $table.colegioId, builder: (column) => column);
}

class $$EventosTableTableManager
    extends
        RootTableManager<
          _$KipuDb,
          $EventosTable,
          Evento,
          $$EventosTableFilterComposer,
          $$EventosTableOrderingComposer,
          $$EventosTableAnnotationComposer,
          $$EventosTableCreateCompanionBuilder,
          $$EventosTableUpdateCompanionBuilder,
          (Evento, BaseReferences<_$KipuDb, $EventosTable, Evento>),
          Evento,
          PrefetchHooks Function()
        > {
  $$EventosTableTableManager(_$KipuDb db, $EventosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> fecha = const Value.absent(),
                Value<String?> hora = const Value.absent(),
                Value<String> titulo = const Value.absent(),
                Value<String?> etiqueta = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<int?> recordar = const Value.absent(),
                Value<String?> repetir = const Value.absent(),
                Value<int?> cursoId = const Value.absent(),
                Value<String?> detalle = const Value.absent(),
                Value<int?> colegioId = const Value.absent(),
              }) => EventosCompanion(
                id: id,
                fecha: fecha,
                hora: hora,
                titulo: titulo,
                etiqueta: etiqueta,
                tipo: tipo,
                recordar: recordar,
                repetir: repetir,
                cursoId: cursoId,
                detalle: detalle,
                colegioId: colegioId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String fecha,
                Value<String?> hora = const Value.absent(),
                required String titulo,
                Value<String?> etiqueta = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<int?> recordar = const Value.absent(),
                Value<String?> repetir = const Value.absent(),
                Value<int?> cursoId = const Value.absent(),
                Value<String?> detalle = const Value.absent(),
                Value<int?> colegioId = const Value.absent(),
              }) => EventosCompanion.insert(
                id: id,
                fecha: fecha,
                hora: hora,
                titulo: titulo,
                etiqueta: etiqueta,
                tipo: tipo,
                recordar: recordar,
                repetir: repetir,
                cursoId: cursoId,
                detalle: detalle,
                colegioId: colegioId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EventosTable, Evento>(table),
                  BaseReferences<_$KipuDb, $EventosTable, Evento>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventosTableProcessedTableManager =
    ProcessedTableManager<
      _$KipuDb,
      $EventosTable,
      Evento,
      $$EventosTableFilterComposer,
      $$EventosTableOrderingComposer,
      $$EventosTableAnnotationComposer,
      $$EventosTableCreateCompanionBuilder,
      $$EventosTableUpdateCompanionBuilder,
      (Evento, BaseReferences<_$KipuDb, $EventosTable, Evento>),
      Evento,
      PrefetchHooks Function()
    >;
typedef $$HorariosTableCreateCompanionBuilder = HorariosCompanion Function({
  Value<int> id,
  required int cursoId,
  required int dia,
  required String inicio,
  required String fin,
});
typedef $$HorariosTableUpdateCompanionBuilder = HorariosCompanion Function({
  Value<int> id,
  Value<int> cursoId,
  Value<int> dia,
  Value<String> inicio,
  Value<String> fin,
});

final class $$HorariosTableReferences
    extends BaseReferences<_$KipuDb, $HorariosTable, Horario> {
  $$HorariosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CursosTable _cursoIdTable(_$KipuDb db) =>
      db.cursos.createAlias('horarios__curso_id__cursos__id');

  $$CursosTableProcessedTableManager get cursoId {
    final $_column = $_itemColumn<int>('curso_id')!;

    final manager = $$CursosTableTableManager(
      $_db,
      $_db.cursos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cursoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HorariosTableFilterComposer extends Composer<_$KipuDb, $HorariosTable> {
  $$HorariosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dia => $composableBuilder(
    column: $table.dia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fin => $composableBuilder(
    column: $table.fin,
    builder: (column) => ColumnFilters(column),
  );

  $$CursosTableFilterComposer get cursoId {
    final $$CursosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cursoId,
      referencedTable: $db.cursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CursosTableFilterComposer(
            $db: $db,
            $table: $db.cursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HorariosTableOrderingComposer
    extends Composer<_$KipuDb, $HorariosTable> {
  $$HorariosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dia => $composableBuilder(
    column: $table.dia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fin => $composableBuilder(
    column: $table.fin,
    builder: (column) => ColumnOrderings(column),
  );

  $$CursosTableOrderingComposer get cursoId {
    final $$CursosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cursoId,
      referencedTable: $db.cursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CursosTableOrderingComposer(
            $db: $db,
            $table: $db.cursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HorariosTableAnnotationComposer
    extends Composer<_$KipuDb, $HorariosTable> {
  $$HorariosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dia =>
      $composableBuilder(column: $table.dia, builder: (column) => column);

  GeneratedColumn<String> get inicio =>
      $composableBuilder(column: $table.inicio, builder: (column) => column);

  GeneratedColumn<String> get fin =>
      $composableBuilder(column: $table.fin, builder: (column) => column);

  $$CursosTableAnnotationComposer get cursoId {
    final $$CursosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cursoId,
      referencedTable: $db.cursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CursosTableAnnotationComposer(
            $db: $db,
            $table: $db.cursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HorariosTableTableManager
    extends
        RootTableManager<
          _$KipuDb,
          $HorariosTable,
          Horario,
          $$HorariosTableFilterComposer,
          $$HorariosTableOrderingComposer,
          $$HorariosTableAnnotationComposer,
          $$HorariosTableCreateCompanionBuilder,
          $$HorariosTableUpdateCompanionBuilder,
          (Horario, $$HorariosTableReferences),
          Horario,
          PrefetchHooks Function({bool cursoId})
        > {
  $$HorariosTableTableManager(_$KipuDb db, $HorariosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HorariosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HorariosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HorariosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cursoId = const Value.absent(),
                Value<int> dia = const Value.absent(),
                Value<String> inicio = const Value.absent(),
                Value<String> fin = const Value.absent(),
              }) => HorariosCompanion(
                id: id,
                cursoId: cursoId,
                dia: dia,
                inicio: inicio,
                fin: fin,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cursoId,
                required int dia,
                required String inicio,
                required String fin,
              }) => HorariosCompanion.insert(
                id: id,
                cursoId: cursoId,
                dia: dia,
                inicio: inicio,
                fin: fin,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HorariosTable, Horario>(table),
                  $$HorariosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cursoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cursoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cursoId,
                        referencedTable: $$HorariosTableReferences
                            ._cursoIdTable(db),
                        referencedColumn: $$HorariosTableReferences
                            ._cursoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HorariosTableProcessedTableManager =
    ProcessedTableManager<
      _$KipuDb,
      $HorariosTable,
      Horario,
      $$HorariosTableFilterComposer,
      $$HorariosTableOrderingComposer,
      $$HorariosTableAnnotationComposer,
      $$HorariosTableCreateCompanionBuilder,
      $$HorariosTableUpdateCompanionBuilder,
      (Horario, $$HorariosTableReferences),
      Horario,
      PrefetchHooks Function({bool cursoId})
    >;
typedef $$FranjasTableCreateCompanionBuilder = FranjasCompanion Function({
  Value<int> id,
  required int colegioId,
  required String inicio,
  required String fin,
  Value<bool> recreo,
});
typedef $$FranjasTableUpdateCompanionBuilder = FranjasCompanion Function({
  Value<int> id,
  Value<int> colegioId,
  Value<String> inicio,
  Value<String> fin,
  Value<bool> recreo,
});

final class $$FranjasTableReferences
    extends BaseReferences<_$KipuDb, $FranjasTable, Franja> {
  $$FranjasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ColegiosTable _colegioIdTable(_$KipuDb db) =>
      db.colegios.createAlias('franjas__colegio_id__colegios__id');

  $$ColegiosTableProcessedTableManager get colegioId {
    final $_column = $_itemColumn<int>('colegio_id')!;

    final manager = $$ColegiosTableTableManager(
      $_db,
      $_db.colegios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_colegioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FranjasTableFilterComposer extends Composer<_$KipuDb, $FranjasTable> {
  $$FranjasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fin => $composableBuilder(
    column: $table.fin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get recreo => $composableBuilder(
    column: $table.recreo,
    builder: (column) => ColumnFilters(column),
  );

  $$ColegiosTableFilterComposer get colegioId {
    final $$ColegiosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.colegioId,
      referencedTable: $db.colegios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColegiosTableFilterComposer(
            $db: $db,
            $table: $db.colegios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FranjasTableOrderingComposer extends Composer<_$KipuDb, $FranjasTable> {
  $$FranjasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fin => $composableBuilder(
    column: $table.fin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get recreo => $composableBuilder(
    column: $table.recreo,
    builder: (column) => ColumnOrderings(column),
  );

  $$ColegiosTableOrderingComposer get colegioId {
    final $$ColegiosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.colegioId,
      referencedTable: $db.colegios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColegiosTableOrderingComposer(
            $db: $db,
            $table: $db.colegios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FranjasTableAnnotationComposer
    extends Composer<_$KipuDb, $FranjasTable> {
  $$FranjasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get inicio =>
      $composableBuilder(column: $table.inicio, builder: (column) => column);

  GeneratedColumn<String> get fin =>
      $composableBuilder(column: $table.fin, builder: (column) => column);

  GeneratedColumn<bool> get recreo =>
      $composableBuilder(column: $table.recreo, builder: (column) => column);

  $$ColegiosTableAnnotationComposer get colegioId {
    final $$ColegiosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.colegioId,
      referencedTable: $db.colegios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColegiosTableAnnotationComposer(
            $db: $db,
            $table: $db.colegios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FranjasTableTableManager
    extends
        RootTableManager<
          _$KipuDb,
          $FranjasTable,
          Franja,
          $$FranjasTableFilterComposer,
          $$FranjasTableOrderingComposer,
          $$FranjasTableAnnotationComposer,
          $$FranjasTableCreateCompanionBuilder,
          $$FranjasTableUpdateCompanionBuilder,
          (Franja, $$FranjasTableReferences),
          Franja,
          PrefetchHooks Function({bool colegioId})
        > {
  $$FranjasTableTableManager(_$KipuDb db, $FranjasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FranjasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FranjasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FranjasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> colegioId = const Value.absent(),
                Value<String> inicio = const Value.absent(),
                Value<String> fin = const Value.absent(),
                Value<bool> recreo = const Value.absent(),
              }) => FranjasCompanion(
                id: id,
                colegioId: colegioId,
                inicio: inicio,
                fin: fin,
                recreo: recreo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int colegioId,
                required String inicio,
                required String fin,
                Value<bool> recreo = const Value.absent(),
              }) => FranjasCompanion.insert(
                id: id,
                colegioId: colegioId,
                inicio: inicio,
                fin: fin,
                recreo: recreo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FranjasTable, Franja>(table),
                  $$FranjasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({colegioId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (colegioId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.colegioId,
                        referencedTable: $$FranjasTableReferences
                            ._colegioIdTable(db),
                        referencedColumn: $$FranjasTableReferences
                            ._colegioIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FranjasTableProcessedTableManager =
    ProcessedTableManager<
      _$KipuDb,
      $FranjasTable,
      Franja,
      $$FranjasTableFilterComposer,
      $$FranjasTableOrderingComposer,
      $$FranjasTableAnnotationComposer,
      $$FranjasTableCreateCompanionBuilder,
      $$FranjasTableUpdateCompanionBuilder,
      (Franja, $$FranjasTableReferences),
      Franja,
      PrefetchHooks Function({bool colegioId})
    >;
typedef $$RegistroColumnasTableCreateCompanionBuilder =
    RegistroColumnasCompanion Function({
      Value<int> id,
      required int cursoId,
      required int periodo,
      required int orden,
      required String codigo,
      Value<String?> tema,
      Value<String?> fecha,
      Value<String> tipo,
      Value<String?> escala,
      Value<bool> enEquipo,
      Value<int?> grupo,
      Value<bool> fijada,
    });
typedef $$RegistroColumnasTableUpdateCompanionBuilder =
    RegistroColumnasCompanion Function({
      Value<int> id,
      Value<int> cursoId,
      Value<int> periodo,
      Value<int> orden,
      Value<String> codigo,
      Value<String?> tema,
      Value<String?> fecha,
      Value<String> tipo,
      Value<String?> escala,
      Value<bool> enEquipo,
      Value<int?> grupo,
      Value<bool> fijada,
    });

final class $$RegistroColumnasTableReferences
    extends BaseReferences<_$KipuDb, $RegistroColumnasTable, RegistroColumna> {
  $$RegistroColumnasTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CursosTable _cursoIdTable(_$KipuDb db) =>
      db.cursos.createAlias('registro_columnas__curso_id__cursos__id');

  $$CursosTableProcessedTableManager get cursoId {
    final $_column = $_itemColumn<int>('curso_id')!;

    final manager = $$CursosTableTableManager(
      $_db,
      $_db.cursos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cursoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RegistroNotasTable, List<RegistroNota>>
  _registroNotasRefsTable(_$KipuDb db) => MultiTypedResultKey.fromTable(
    db.registroNotas,
    aliasName: 'registro_columnas__id__registro_notas__columna_id',
  );

  $$RegistroNotasTableProcessedTableManager get registroNotasRefs {
    final manager = $$RegistroNotasTableTableManager(
      $_db,
      $_db.registroNotas,
    ).filter((f) => f.columnaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_registroNotasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RegistroColumnasTableFilterComposer
    extends Composer<_$KipuDb, $RegistroColumnasTable> {
  $$RegistroColumnasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodo => $composableBuilder(
    column: $table.periodo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tema => $composableBuilder(
    column: $table.tema,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get escala => $composableBuilder(
    column: $table.escala,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enEquipo => $composableBuilder(
    column: $table.enEquipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grupo => $composableBuilder(
    column: $table.grupo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get fijada => $composableBuilder(
    column: $table.fijada,
    builder: (column) => ColumnFilters(column),
  );

  $$CursosTableFilterComposer get cursoId {
    final $$CursosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cursoId,
      referencedTable: $db.cursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CursosTableFilterComposer(
            $db: $db,
            $table: $db.cursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> registroNotasRefs(
    Expression<bool> Function($$RegistroNotasTableFilterComposer f) f,
  ) {
    final $$RegistroNotasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.registroNotas,
      getReferencedColumn: (t) => t.columnaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegistroNotasTableFilterComposer(
            $db: $db,
            $table: $db.registroNotas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RegistroColumnasTableOrderingComposer
    extends Composer<_$KipuDb, $RegistroColumnasTable> {
  $$RegistroColumnasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodo => $composableBuilder(
    column: $table.periodo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tema => $composableBuilder(
    column: $table.tema,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get escala => $composableBuilder(
    column: $table.escala,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enEquipo => $composableBuilder(
    column: $table.enEquipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grupo => $composableBuilder(
    column: $table.grupo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get fijada => $composableBuilder(
    column: $table.fijada,
    builder: (column) => ColumnOrderings(column),
  );

  $$CursosTableOrderingComposer get cursoId {
    final $$CursosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cursoId,
      referencedTable: $db.cursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CursosTableOrderingComposer(
            $db: $db,
            $table: $db.cursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RegistroColumnasTableAnnotationComposer
    extends Composer<_$KipuDb, $RegistroColumnasTable> {
  $$RegistroColumnasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get periodo =>
      $composableBuilder(column: $table.periodo, builder: (column) => column);

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get tema =>
      $composableBuilder(column: $table.tema, builder: (column) => column);

  GeneratedColumn<String> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get escala =>
      $composableBuilder(column: $table.escala, builder: (column) => column);

  GeneratedColumn<bool> get enEquipo =>
      $composableBuilder(column: $table.enEquipo, builder: (column) => column);

  GeneratedColumn<int> get grupo =>
      $composableBuilder(column: $table.grupo, builder: (column) => column);

  GeneratedColumn<bool> get fijada =>
      $composableBuilder(column: $table.fijada, builder: (column) => column);

  $$CursosTableAnnotationComposer get cursoId {
    final $$CursosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cursoId,
      referencedTable: $db.cursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CursosTableAnnotationComposer(
            $db: $db,
            $table: $db.cursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> registroNotasRefs<T extends Object>(
    Expression<T> Function($$RegistroNotasTableAnnotationComposer a) f,
  ) {
    final $$RegistroNotasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.registroNotas,
      getReferencedColumn: (t) => t.columnaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegistroNotasTableAnnotationComposer(
            $db: $db,
            $table: $db.registroNotas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RegistroColumnasTableTableManager
    extends
        RootTableManager<
          _$KipuDb,
          $RegistroColumnasTable,
          RegistroColumna,
          $$RegistroColumnasTableFilterComposer,
          $$RegistroColumnasTableOrderingComposer,
          $$RegistroColumnasTableAnnotationComposer,
          $$RegistroColumnasTableCreateCompanionBuilder,
          $$RegistroColumnasTableUpdateCompanionBuilder,
          (RegistroColumna, $$RegistroColumnasTableReferences),
          RegistroColumna,
          PrefetchHooks Function({bool cursoId, bool registroNotasRefs})
        > {
  $$RegistroColumnasTableTableManager(_$KipuDb db, $RegistroColumnasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RegistroColumnasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RegistroColumnasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RegistroColumnasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cursoId = const Value.absent(),
                Value<int> periodo = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String?> tema = const Value.absent(),
                Value<String?> fecha = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String?> escala = const Value.absent(),
                Value<bool> enEquipo = const Value.absent(),
                Value<int?> grupo = const Value.absent(),
                Value<bool> fijada = const Value.absent(),
              }) => RegistroColumnasCompanion(
                id: id,
                cursoId: cursoId,
                periodo: periodo,
                orden: orden,
                codigo: codigo,
                tema: tema,
                fecha: fecha,
                tipo: tipo,
                escala: escala,
                enEquipo: enEquipo,
                grupo: grupo,
                fijada: fijada,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cursoId,
                required int periodo,
                required int orden,
                required String codigo,
                Value<String?> tema = const Value.absent(),
                Value<String?> fecha = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String?> escala = const Value.absent(),
                Value<bool> enEquipo = const Value.absent(),
                Value<int?> grupo = const Value.absent(),
                Value<bool> fijada = const Value.absent(),
              }) => RegistroColumnasCompanion.insert(
                id: id,
                cursoId: cursoId,
                periodo: periodo,
                orden: orden,
                codigo: codigo,
                tema: tema,
                fecha: fecha,
                tipo: tipo,
                escala: escala,
                enEquipo: enEquipo,
                grupo: grupo,
                fijada: fijada,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RegistroColumnasTable, RegistroColumna>(table),
                  $$RegistroColumnasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({cursoId = false, registroNotasRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (registroNotasRefs) db.registroNotas,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (cursoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.cursoId,
                            referencedTable: $$RegistroColumnasTableReferences
                                ._cursoIdTable(db),
                            referencedColumn: $$RegistroColumnasTableReferences
                                ._cursoIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (registroNotasRefs)
                        await $_getPrefetchedDataByColumns<
                          RegistroColumna,
                          $RegistroColumnasTable,
                          RegistroNota,
                          $RegistroNotasTable
                        >(
                          currentTable: table,
                          referencedTable: $$RegistroColumnasTableReferences
                              ._registroNotasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RegistroColumnasTableReferences(
                                db,
                                table,
                                p0,
                              ).registroNotasRefs,
                          currentColumn: 'id',
                          referencedColumn: 'columna_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RegistroColumnasTableProcessedTableManager =
    ProcessedTableManager<
      _$KipuDb,
      $RegistroColumnasTable,
      RegistroColumna,
      $$RegistroColumnasTableFilterComposer,
      $$RegistroColumnasTableOrderingComposer,
      $$RegistroColumnasTableAnnotationComposer,
      $$RegistroColumnasTableCreateCompanionBuilder,
      $$RegistroColumnasTableUpdateCompanionBuilder,
      (RegistroColumna, $$RegistroColumnasTableReferences),
      RegistroColumna,
      PrefetchHooks Function({bool cursoId, bool registroNotasRefs})
    >;
typedef $$RegistroNotasTableCreateCompanionBuilder =
    RegistroNotasCompanion Function({
      required int columnaId,
      required int estudianteId,
      required String valor,
      Value<int> rowid,
    });
typedef $$RegistroNotasTableUpdateCompanionBuilder =
    RegistroNotasCompanion Function({
      Value<int> columnaId,
      Value<int> estudianteId,
      Value<String> valor,
      Value<int> rowid,
    });

final class $$RegistroNotasTableReferences
    extends BaseReferences<_$KipuDb, $RegistroNotasTable, RegistroNota> {
  $$RegistroNotasTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RegistroColumnasTable _columnaIdTable(_$KipuDb db) => db
      .registroColumnas
      .createAlias('registro_notas__columna_id__registro_columnas__id');

  $$RegistroColumnasTableProcessedTableManager get columnaId {
    final $_column = $_itemColumn<int>('columna_id')!;

    final manager = $$RegistroColumnasTableTableManager(
      $_db,
      $_db.registroColumnas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_columnaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EstudiantesTable _estudianteIdTable(_$KipuDb db) => db.estudiantes
      .createAlias('registro_notas__estudiante_id__estudiantes__id');

  $$EstudiantesTableProcessedTableManager get estudianteId {
    final $_column = $_itemColumn<int>('estudiante_id')!;

    final manager = $$EstudiantesTableTableManager(
      $_db,
      $_db.estudiantes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_estudianteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RegistroNotasTableFilterComposer
    extends Composer<_$KipuDb, $RegistroNotasTable> {
  $$RegistroNotasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  $$RegistroColumnasTableFilterComposer get columnaId {
    final $$RegistroColumnasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.columnaId,
      referencedTable: $db.registroColumnas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegistroColumnasTableFilterComposer(
            $db: $db,
            $table: $db.registroColumnas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EstudiantesTableFilterComposer get estudianteId {
    final $$EstudiantesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.estudianteId,
      referencedTable: $db.estudiantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstudiantesTableFilterComposer(
            $db: $db,
            $table: $db.estudiantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RegistroNotasTableOrderingComposer
    extends Composer<_$KipuDb, $RegistroNotasTable> {
  $$RegistroNotasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  $$RegistroColumnasTableOrderingComposer get columnaId {
    final $$RegistroColumnasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.columnaId,
      referencedTable: $db.registroColumnas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegistroColumnasTableOrderingComposer(
            $db: $db,
            $table: $db.registroColumnas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EstudiantesTableOrderingComposer get estudianteId {
    final $$EstudiantesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.estudianteId,
      referencedTable: $db.estudiantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstudiantesTableOrderingComposer(
            $db: $db,
            $table: $db.estudiantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RegistroNotasTableAnnotationComposer
    extends Composer<_$KipuDb, $RegistroNotasTable> {
  $$RegistroNotasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  $$RegistroColumnasTableAnnotationComposer get columnaId {
    final $$RegistroColumnasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.columnaId,
      referencedTable: $db.registroColumnas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RegistroColumnasTableAnnotationComposer(
            $db: $db,
            $table: $db.registroColumnas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EstudiantesTableAnnotationComposer get estudianteId {
    final $$EstudiantesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.estudianteId,
      referencedTable: $db.estudiantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstudiantesTableAnnotationComposer(
            $db: $db,
            $table: $db.estudiantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RegistroNotasTableTableManager
    extends
        RootTableManager<
          _$KipuDb,
          $RegistroNotasTable,
          RegistroNota,
          $$RegistroNotasTableFilterComposer,
          $$RegistroNotasTableOrderingComposer,
          $$RegistroNotasTableAnnotationComposer,
          $$RegistroNotasTableCreateCompanionBuilder,
          $$RegistroNotasTableUpdateCompanionBuilder,
          (RegistroNota, $$RegistroNotasTableReferences),
          RegistroNota,
          PrefetchHooks Function({bool columnaId, bool estudianteId})
        > {
  $$RegistroNotasTableTableManager(_$KipuDb db, $RegistroNotasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RegistroNotasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RegistroNotasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RegistroNotasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> columnaId = const Value.absent(),
                Value<int> estudianteId = const Value.absent(),
                Value<String> valor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RegistroNotasCompanion(
                columnaId: columnaId,
                estudianteId: estudianteId,
                valor: valor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int columnaId,
                required int estudianteId,
                required String valor,
                Value<int> rowid = const Value.absent(),
              }) => RegistroNotasCompanion.insert(
                columnaId: columnaId,
                estudianteId: estudianteId,
                valor: valor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RegistroNotasTable, RegistroNota>(table),
                  $$RegistroNotasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({columnaId = false, estudianteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (columnaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.columnaId,
                        referencedTable: $$RegistroNotasTableReferences
                            ._columnaIdTable(db),
                        referencedColumn: $$RegistroNotasTableReferences
                            ._columnaIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (estudianteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.estudianteId,
                        referencedTable: $$RegistroNotasTableReferences
                            ._estudianteIdTable(db),
                        referencedColumn: $$RegistroNotasTableReferences
                            ._estudianteIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RegistroNotasTableProcessedTableManager =
    ProcessedTableManager<
      _$KipuDb,
      $RegistroNotasTable,
      RegistroNota,
      $$RegistroNotasTableFilterComposer,
      $$RegistroNotasTableOrderingComposer,
      $$RegistroNotasTableAnnotationComposer,
      $$RegistroNotasTableCreateCompanionBuilder,
      $$RegistroNotasTableUpdateCompanionBuilder,
      (RegistroNota, $$RegistroNotasTableReferences),
      RegistroNota,
      PrefetchHooks Function({bool columnaId, bool estudianteId})
    >;
typedef $$ConductasTableCreateCompanionBuilder = ConductasCompanion Function({
  Value<int> id,
  required int estudianteId,
  required String fecha,
  required bool positiva,
  required String motivo,
});
typedef $$ConductasTableUpdateCompanionBuilder = ConductasCompanion Function({
  Value<int> id,
  Value<int> estudianteId,
  Value<String> fecha,
  Value<bool> positiva,
  Value<String> motivo,
});

final class $$ConductasTableReferences
    extends BaseReferences<_$KipuDb, $ConductasTable, Conducta> {
  $$ConductasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EstudiantesTable _estudianteIdTable(_$KipuDb db) =>
      db.estudiantes.createAlias('conductas__estudiante_id__estudiantes__id');

  $$EstudiantesTableProcessedTableManager get estudianteId {
    final $_column = $_itemColumn<int>('estudiante_id')!;

    final manager = $$EstudiantesTableTableManager(
      $_db,
      $_db.estudiantes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_estudianteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ConductasTableFilterComposer
    extends Composer<_$KipuDb, $ConductasTable> {
  $$ConductasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get positiva => $composableBuilder(
    column: $table.positiva,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motivo => $composableBuilder(
    column: $table.motivo,
    builder: (column) => ColumnFilters(column),
  );

  $$EstudiantesTableFilterComposer get estudianteId {
    final $$EstudiantesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.estudianteId,
      referencedTable: $db.estudiantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstudiantesTableFilterComposer(
            $db: $db,
            $table: $db.estudiantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConductasTableOrderingComposer
    extends Composer<_$KipuDb, $ConductasTable> {
  $$ConductasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get positiva => $composableBuilder(
    column: $table.positiva,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motivo => $composableBuilder(
    column: $table.motivo,
    builder: (column) => ColumnOrderings(column),
  );

  $$EstudiantesTableOrderingComposer get estudianteId {
    final $$EstudiantesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.estudianteId,
      referencedTable: $db.estudiantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstudiantesTableOrderingComposer(
            $db: $db,
            $table: $db.estudiantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConductasTableAnnotationComposer
    extends Composer<_$KipuDb, $ConductasTable> {
  $$ConductasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<bool> get positiva =>
      $composableBuilder(column: $table.positiva, builder: (column) => column);

  GeneratedColumn<String> get motivo =>
      $composableBuilder(column: $table.motivo, builder: (column) => column);

  $$EstudiantesTableAnnotationComposer get estudianteId {
    final $$EstudiantesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.estudianteId,
      referencedTable: $db.estudiantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstudiantesTableAnnotationComposer(
            $db: $db,
            $table: $db.estudiantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConductasTableTableManager
    extends
        RootTableManager<
          _$KipuDb,
          $ConductasTable,
          Conducta,
          $$ConductasTableFilterComposer,
          $$ConductasTableOrderingComposer,
          $$ConductasTableAnnotationComposer,
          $$ConductasTableCreateCompanionBuilder,
          $$ConductasTableUpdateCompanionBuilder,
          (Conducta, $$ConductasTableReferences),
          Conducta,
          PrefetchHooks Function({bool estudianteId})
        > {
  $$ConductasTableTableManager(_$KipuDb db, $ConductasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConductasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConductasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConductasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> estudianteId = const Value.absent(),
                Value<String> fecha = const Value.absent(),
                Value<bool> positiva = const Value.absent(),
                Value<String> motivo = const Value.absent(),
              }) => ConductasCompanion(
                id: id,
                estudianteId: estudianteId,
                fecha: fecha,
                positiva: positiva,
                motivo: motivo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int estudianteId,
                required String fecha,
                required bool positiva,
                required String motivo,
              }) => ConductasCompanion.insert(
                id: id,
                estudianteId: estudianteId,
                fecha: fecha,
                positiva: positiva,
                motivo: motivo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConductasTable, Conducta>(table),
                  $$ConductasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({estudianteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (estudianteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.estudianteId,
                        referencedTable: $$ConductasTableReferences
                            ._estudianteIdTable(db),
                        referencedColumn: $$ConductasTableReferences
                            ._estudianteIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ConductasTableProcessedTableManager =
    ProcessedTableManager<
      _$KipuDb,
      $ConductasTable,
      Conducta,
      $$ConductasTableFilterComposer,
      $$ConductasTableOrderingComposer,
      $$ConductasTableAnnotationComposer,
      $$ConductasTableCreateCompanionBuilder,
      $$ConductasTableUpdateCompanionBuilder,
      (Conducta, $$ConductasTableReferences),
      Conducta,
      PrefetchHooks Function({bool estudianteId})
    >;
typedef $$PendientesTableCreateCompanionBuilder = PendientesCompanion Function({
  Value<int> id,
  required String texto,
  Value<bool> hecho,
  Value<String?> vence,
  Value<int?> cursoId,
  Value<int?> estudianteId,
  Value<DateTime> creado,
});
typedef $$PendientesTableUpdateCompanionBuilder = PendientesCompanion Function({
  Value<int> id,
  Value<String> texto,
  Value<bool> hecho,
  Value<String?> vence,
  Value<int?> cursoId,
  Value<int?> estudianteId,
  Value<DateTime> creado,
});

class $$PendientesTableFilterComposer
    extends Composer<_$KipuDb, $PendientesTable> {
  $$PendientesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get texto => $composableBuilder(
    column: $table.texto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hecho => $composableBuilder(
    column: $table.hecho,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vence => $composableBuilder(
    column: $table.vence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cursoId => $composableBuilder(
    column: $table.cursoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estudianteId => $composableBuilder(
    column: $table.estudianteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creado => $composableBuilder(
    column: $table.creado,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendientesTableOrderingComposer
    extends Composer<_$KipuDb, $PendientesTable> {
  $$PendientesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get texto => $composableBuilder(
    column: $table.texto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hecho => $composableBuilder(
    column: $table.hecho,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vence => $composableBuilder(
    column: $table.vence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cursoId => $composableBuilder(
    column: $table.cursoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estudianteId => $composableBuilder(
    column: $table.estudianteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creado => $composableBuilder(
    column: $table.creado,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendientesTableAnnotationComposer
    extends Composer<_$KipuDb, $PendientesTable> {
  $$PendientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get texto =>
      $composableBuilder(column: $table.texto, builder: (column) => column);

  GeneratedColumn<bool> get hecho =>
      $composableBuilder(column: $table.hecho, builder: (column) => column);

  GeneratedColumn<String> get vence =>
      $composableBuilder(column: $table.vence, builder: (column) => column);

  GeneratedColumn<int> get cursoId =>
      $composableBuilder(column: $table.cursoId, builder: (column) => column);

  GeneratedColumn<int> get estudianteId => $composableBuilder(
    column: $table.estudianteId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get creado =>
      $composableBuilder(column: $table.creado, builder: (column) => column);
}

class $$PendientesTableTableManager
    extends
        RootTableManager<
          _$KipuDb,
          $PendientesTable,
          Pendiente,
          $$PendientesTableFilterComposer,
          $$PendientesTableOrderingComposer,
          $$PendientesTableAnnotationComposer,
          $$PendientesTableCreateCompanionBuilder,
          $$PendientesTableUpdateCompanionBuilder,
          (Pendiente, BaseReferences<_$KipuDb, $PendientesTable, Pendiente>),
          Pendiente,
          PrefetchHooks Function()
        > {
  $$PendientesTableTableManager(_$KipuDb db, $PendientesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendientesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendientesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendientesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> texto = const Value.absent(),
                Value<bool> hecho = const Value.absent(),
                Value<String?> vence = const Value.absent(),
                Value<int?> cursoId = const Value.absent(),
                Value<int?> estudianteId = const Value.absent(),
                Value<DateTime> creado = const Value.absent(),
              }) => PendientesCompanion(
                id: id,
                texto: texto,
                hecho: hecho,
                vence: vence,
                cursoId: cursoId,
                estudianteId: estudianteId,
                creado: creado,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String texto,
                Value<bool> hecho = const Value.absent(),
                Value<String?> vence = const Value.absent(),
                Value<int?> cursoId = const Value.absent(),
                Value<int?> estudianteId = const Value.absent(),
                Value<DateTime> creado = const Value.absent(),
              }) => PendientesCompanion.insert(
                id: id,
                texto: texto,
                hecho: hecho,
                vence: vence,
                cursoId: cursoId,
                estudianteId: estudianteId,
                creado: creado,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PendientesTable, Pendiente>(table),
                  BaseReferences<_$KipuDb, $PendientesTable, Pendiente>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendientesTableProcessedTableManager =
    ProcessedTableManager<
      _$KipuDb,
      $PendientesTable,
      Pendiente,
      $$PendientesTableFilterComposer,
      $$PendientesTableOrderingComposer,
      $$PendientesTableAnnotationComposer,
      $$PendientesTableCreateCompanionBuilder,
      $$PendientesTableUpdateCompanionBuilder,
      (Pendiente, BaseReferences<_$KipuDb, $PendientesTable, Pendiente>),
      Pendiente,
      PrefetchHooks Function()
    >;
typedef $$AnecdotasTableCreateCompanionBuilder = AnecdotasCompanion Function({
  Value<int> id,
  required int estudianteId,
  required String fecha,
  Value<String> tipo,
  Value<String> categoria,
  required String texto,
  Value<Uint8List?> foto,
  Value<String?> apoderado,
  Value<String?> acuerdos,
  Value<String?> seguimiento,
});
typedef $$AnecdotasTableUpdateCompanionBuilder = AnecdotasCompanion Function({
  Value<int> id,
  Value<int> estudianteId,
  Value<String> fecha,
  Value<String> tipo,
  Value<String> categoria,
  Value<String> texto,
  Value<Uint8List?> foto,
  Value<String?> apoderado,
  Value<String?> acuerdos,
  Value<String?> seguimiento,
});

final class $$AnecdotasTableReferences
    extends BaseReferences<_$KipuDb, $AnecdotasTable, Anecdota> {
  $$AnecdotasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EstudiantesTable _estudianteIdTable(_$KipuDb db) =>
      db.estudiantes.createAlias('anecdotas__estudiante_id__estudiantes__id');

  $$EstudiantesTableProcessedTableManager get estudianteId {
    final $_column = $_itemColumn<int>('estudiante_id')!;

    final manager = $$EstudiantesTableTableManager(
      $_db,
      $_db.estudiantes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_estudianteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AnecdotasTableFilterComposer
    extends Composer<_$KipuDb, $AnecdotasTable> {
  $$AnecdotasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get texto => $composableBuilder(
    column: $table.texto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get foto => $composableBuilder(
    column: $table.foto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apoderado => $composableBuilder(
    column: $table.apoderado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get acuerdos => $composableBuilder(
    column: $table.acuerdos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seguimiento => $composableBuilder(
    column: $table.seguimiento,
    builder: (column) => ColumnFilters(column),
  );

  $$EstudiantesTableFilterComposer get estudianteId {
    final $$EstudiantesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.estudianteId,
      referencedTable: $db.estudiantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstudiantesTableFilterComposer(
            $db: $db,
            $table: $db.estudiantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnecdotasTableOrderingComposer
    extends Composer<_$KipuDb, $AnecdotasTable> {
  $$AnecdotasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get texto => $composableBuilder(
    column: $table.texto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get foto => $composableBuilder(
    column: $table.foto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apoderado => $composableBuilder(
    column: $table.apoderado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get acuerdos => $composableBuilder(
    column: $table.acuerdos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seguimiento => $composableBuilder(
    column: $table.seguimiento,
    builder: (column) => ColumnOrderings(column),
  );

  $$EstudiantesTableOrderingComposer get estudianteId {
    final $$EstudiantesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.estudianteId,
      referencedTable: $db.estudiantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstudiantesTableOrderingComposer(
            $db: $db,
            $table: $db.estudiantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnecdotasTableAnnotationComposer
    extends Composer<_$KipuDb, $AnecdotasTable> {
  $$AnecdotasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<String> get texto =>
      $composableBuilder(column: $table.texto, builder: (column) => column);

  GeneratedColumn<Uint8List> get foto =>
      $composableBuilder(column: $table.foto, builder: (column) => column);

  GeneratedColumn<String> get apoderado =>
      $composableBuilder(column: $table.apoderado, builder: (column) => column);

  GeneratedColumn<String> get acuerdos =>
      $composableBuilder(column: $table.acuerdos, builder: (column) => column);

  GeneratedColumn<String> get seguimiento => $composableBuilder(
    column: $table.seguimiento,
    builder: (column) => column,
  );

  $$EstudiantesTableAnnotationComposer get estudianteId {
    final $$EstudiantesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.estudianteId,
      referencedTable: $db.estudiantes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstudiantesTableAnnotationComposer(
            $db: $db,
            $table: $db.estudiantes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AnecdotasTableTableManager
    extends
        RootTableManager<
          _$KipuDb,
          $AnecdotasTable,
          Anecdota,
          $$AnecdotasTableFilterComposer,
          $$AnecdotasTableOrderingComposer,
          $$AnecdotasTableAnnotationComposer,
          $$AnecdotasTableCreateCompanionBuilder,
          $$AnecdotasTableUpdateCompanionBuilder,
          (Anecdota, $$AnecdotasTableReferences),
          Anecdota,
          PrefetchHooks Function({bool estudianteId})
        > {
  $$AnecdotasTableTableManager(_$KipuDb db, $AnecdotasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AnecdotasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AnecdotasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AnecdotasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> estudianteId = const Value.absent(),
                Value<String> fecha = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String> categoria = const Value.absent(),
                Value<String> texto = const Value.absent(),
                Value<Uint8List?> foto = const Value.absent(),
                Value<String?> apoderado = const Value.absent(),
                Value<String?> acuerdos = const Value.absent(),
                Value<String?> seguimiento = const Value.absent(),
              }) => AnecdotasCompanion(
                id: id,
                estudianteId: estudianteId,
                fecha: fecha,
                tipo: tipo,
                categoria: categoria,
                texto: texto,
                foto: foto,
                apoderado: apoderado,
                acuerdos: acuerdos,
                seguimiento: seguimiento,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int estudianteId,
                required String fecha,
                Value<String> tipo = const Value.absent(),
                Value<String> categoria = const Value.absent(),
                required String texto,
                Value<Uint8List?> foto = const Value.absent(),
                Value<String?> apoderado = const Value.absent(),
                Value<String?> acuerdos = const Value.absent(),
                Value<String?> seguimiento = const Value.absent(),
              }) => AnecdotasCompanion.insert(
                id: id,
                estudianteId: estudianteId,
                fecha: fecha,
                tipo: tipo,
                categoria: categoria,
                texto: texto,
                foto: foto,
                apoderado: apoderado,
                acuerdos: acuerdos,
                seguimiento: seguimiento,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AnecdotasTable, Anecdota>(table),
                  $$AnecdotasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({estudianteId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (estudianteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.estudianteId,
                        referencedTable: $$AnecdotasTableReferences
                            ._estudianteIdTable(db),
                        referencedColumn: $$AnecdotasTableReferences
                            ._estudianteIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AnecdotasTableProcessedTableManager =
    ProcessedTableManager<
      _$KipuDb,
      $AnecdotasTable,
      Anecdota,
      $$AnecdotasTableFilterComposer,
      $$AnecdotasTableOrderingComposer,
      $$AnecdotasTableAnnotationComposer,
      $$AnecdotasTableCreateCompanionBuilder,
      $$AnecdotasTableUpdateCompanionBuilder,
      (Anecdota, $$AnecdotasTableReferences),
      Anecdota,
      PrefetchHooks Function({bool estudianteId})
    >;
typedef $$ClasesDiarioTableCreateCompanionBuilder =
    ClasesDiarioCompanion Function({
      Value<int> id,
      required int cursoId,
      required String fecha,
      required String trabajado,
      Value<String?> falta,
      Value<String?> material,
    });
typedef $$ClasesDiarioTableUpdateCompanionBuilder =
    ClasesDiarioCompanion Function({
      Value<int> id,
      Value<int> cursoId,
      Value<String> fecha,
      Value<String> trabajado,
      Value<String?> falta,
      Value<String?> material,
    });

final class $$ClasesDiarioTableReferences
    extends BaseReferences<_$KipuDb, $ClasesDiarioTable, ClaseDiario> {
  $$ClasesDiarioTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CursosTable _cursoIdTable(_$KipuDb db) =>
      db.cursos.createAlias('clases_diario__curso_id__cursos__id');

  $$CursosTableProcessedTableManager get cursoId {
    final $_column = $_itemColumn<int>('curso_id')!;

    final manager = $$CursosTableTableManager(
      $_db,
      $_db.cursos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cursoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ClasesDiarioTableFilterComposer
    extends Composer<_$KipuDb, $ClasesDiarioTable> {
  $$ClasesDiarioTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trabajado => $composableBuilder(
    column: $table.trabajado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get falta => $composableBuilder(
    column: $table.falta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => ColumnFilters(column),
  );

  $$CursosTableFilterComposer get cursoId {
    final $$CursosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cursoId,
      referencedTable: $db.cursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CursosTableFilterComposer(
            $db: $db,
            $table: $db.cursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClasesDiarioTableOrderingComposer
    extends Composer<_$KipuDb, $ClasesDiarioTable> {
  $$ClasesDiarioTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trabajado => $composableBuilder(
    column: $table.trabajado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get falta => $composableBuilder(
    column: $table.falta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => ColumnOrderings(column),
  );

  $$CursosTableOrderingComposer get cursoId {
    final $$CursosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cursoId,
      referencedTable: $db.cursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CursosTableOrderingComposer(
            $db: $db,
            $table: $db.cursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClasesDiarioTableAnnotationComposer
    extends Composer<_$KipuDb, $ClasesDiarioTable> {
  $$ClasesDiarioTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get trabajado =>
      $composableBuilder(column: $table.trabajado, builder: (column) => column);

  GeneratedColumn<String> get falta =>
      $composableBuilder(column: $table.falta, builder: (column) => column);

  GeneratedColumn<String> get material =>
      $composableBuilder(column: $table.material, builder: (column) => column);

  $$CursosTableAnnotationComposer get cursoId {
    final $$CursosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cursoId,
      referencedTable: $db.cursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CursosTableAnnotationComposer(
            $db: $db,
            $table: $db.cursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClasesDiarioTableTableManager
    extends
        RootTableManager<
          _$KipuDb,
          $ClasesDiarioTable,
          ClaseDiario,
          $$ClasesDiarioTableFilterComposer,
          $$ClasesDiarioTableOrderingComposer,
          $$ClasesDiarioTableAnnotationComposer,
          $$ClasesDiarioTableCreateCompanionBuilder,
          $$ClasesDiarioTableUpdateCompanionBuilder,
          (ClaseDiario, $$ClasesDiarioTableReferences),
          ClaseDiario,
          PrefetchHooks Function({bool cursoId})
        > {
  $$ClasesDiarioTableTableManager(_$KipuDb db, $ClasesDiarioTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClasesDiarioTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClasesDiarioTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClasesDiarioTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cursoId = const Value.absent(),
                Value<String> fecha = const Value.absent(),
                Value<String> trabajado = const Value.absent(),
                Value<String?> falta = const Value.absent(),
                Value<String?> material = const Value.absent(),
              }) => ClasesDiarioCompanion(
                id: id,
                cursoId: cursoId,
                fecha: fecha,
                trabajado: trabajado,
                falta: falta,
                material: material,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cursoId,
                required String fecha,
                required String trabajado,
                Value<String?> falta = const Value.absent(),
                Value<String?> material = const Value.absent(),
              }) => ClasesDiarioCompanion.insert(
                id: id,
                cursoId: cursoId,
                fecha: fecha,
                trabajado: trabajado,
                falta: falta,
                material: material,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClasesDiarioTable, ClaseDiario>(table),
                  $$ClasesDiarioTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cursoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cursoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cursoId,
                        referencedTable: $$ClasesDiarioTableReferences
                            ._cursoIdTable(db),
                        referencedColumn: $$ClasesDiarioTableReferences
                            ._cursoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ClasesDiarioTableProcessedTableManager =
    ProcessedTableManager<
      _$KipuDb,
      $ClasesDiarioTable,
      ClaseDiario,
      $$ClasesDiarioTableFilterComposer,
      $$ClasesDiarioTableOrderingComposer,
      $$ClasesDiarioTableAnnotationComposer,
      $$ClasesDiarioTableCreateCompanionBuilder,
      $$ClasesDiarioTableUpdateCompanionBuilder,
      (ClaseDiario, $$ClasesDiarioTableReferences),
      ClaseDiario,
      PrefetchHooks Function({bool cursoId})
    >;
typedef $$UnidadesTableCreateCompanionBuilder = UnidadesCompanion Function({
  Value<int> id,
  required int cursoId,
  required int anio,
  required int periodo,
  required int orden,
  required String titulo,
  Value<String?> desde,
  Value<String?> hasta,
  Value<String> competencias,
  Value<String?> situacion,
  Value<String?> temas,
  Value<String?> producto,
  Value<String> enfoques,
  Value<String?> propositos,
  Value<String?> materiales,
});
typedef $$UnidadesTableUpdateCompanionBuilder = UnidadesCompanion Function({
  Value<int> id,
  Value<int> cursoId,
  Value<int> anio,
  Value<int> periodo,
  Value<int> orden,
  Value<String> titulo,
  Value<String?> desde,
  Value<String?> hasta,
  Value<String> competencias,
  Value<String?> situacion,
  Value<String?> temas,
  Value<String?> producto,
  Value<String> enfoques,
  Value<String?> propositos,
  Value<String?> materiales,
});

final class $$UnidadesTableReferences
    extends BaseReferences<_$KipuDb, $UnidadesTable, Unidad> {
  $$UnidadesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CursosTable _cursoIdTable(_$KipuDb db) =>
      db.cursos.createAlias('unidades__curso_id__cursos__id');

  $$CursosTableProcessedTableManager get cursoId {
    final $_column = $_itemColumn<int>('curso_id')!;

    final manager = $$CursosTableTableManager(
      $_db,
      $_db.cursos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cursoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SesionesTable, List<Sesion>> _sesionesRefsTable(
    _$KipuDb db,
  ) => MultiTypedResultKey.fromTable(
    db.sesiones,
    aliasName: 'unidades__id__sesiones__unidad_id',
  );

  $$SesionesTableProcessedTableManager get sesionesRefs {
    final manager = $$SesionesTableTableManager(
      $_db,
      $_db.sesiones,
    ).filter((f) => f.unidadId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sesionesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UnidadesTableFilterComposer extends Composer<_$KipuDb, $UnidadesTable> {
  $$UnidadesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anio => $composableBuilder(
    column: $table.anio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get periodo => $composableBuilder(
    column: $table.periodo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get desde => $composableBuilder(
    column: $table.desde,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hasta => $composableBuilder(
    column: $table.hasta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get competencias => $composableBuilder(
    column: $table.competencias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get situacion => $composableBuilder(
    column: $table.situacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get temas => $composableBuilder(
    column: $table.temas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get producto => $composableBuilder(
    column: $table.producto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enfoques => $composableBuilder(
    column: $table.enfoques,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get propositos => $composableBuilder(
    column: $table.propositos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get materiales => $composableBuilder(
    column: $table.materiales,
    builder: (column) => ColumnFilters(column),
  );

  $$CursosTableFilterComposer get cursoId {
    final $$CursosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cursoId,
      referencedTable: $db.cursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CursosTableFilterComposer(
            $db: $db,
            $table: $db.cursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> sesionesRefs(
    Expression<bool> Function($$SesionesTableFilterComposer f) f,
  ) {
    final $$SesionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sesiones,
      getReferencedColumn: (t) => t.unidadId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SesionesTableFilterComposer(
            $db: $db,
            $table: $db.sesiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UnidadesTableOrderingComposer
    extends Composer<_$KipuDb, $UnidadesTable> {
  $$UnidadesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anio => $composableBuilder(
    column: $table.anio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodo => $composableBuilder(
    column: $table.periodo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get desde => $composableBuilder(
    column: $table.desde,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hasta => $composableBuilder(
    column: $table.hasta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get competencias => $composableBuilder(
    column: $table.competencias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get situacion => $composableBuilder(
    column: $table.situacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get temas => $composableBuilder(
    column: $table.temas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get producto => $composableBuilder(
    column: $table.producto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enfoques => $composableBuilder(
    column: $table.enfoques,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get propositos => $composableBuilder(
    column: $table.propositos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get materiales => $composableBuilder(
    column: $table.materiales,
    builder: (column) => ColumnOrderings(column),
  );

  $$CursosTableOrderingComposer get cursoId {
    final $$CursosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cursoId,
      referencedTable: $db.cursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CursosTableOrderingComposer(
            $db: $db,
            $table: $db.cursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UnidadesTableAnnotationComposer
    extends Composer<_$KipuDb, $UnidadesTable> {
  $$UnidadesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get anio =>
      $composableBuilder(column: $table.anio, builder: (column) => column);

  GeneratedColumn<int> get periodo =>
      $composableBuilder(column: $table.periodo, builder: (column) => column);

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<String> get desde =>
      $composableBuilder(column: $table.desde, builder: (column) => column);

  GeneratedColumn<String> get hasta =>
      $composableBuilder(column: $table.hasta, builder: (column) => column);

  GeneratedColumn<String> get competencias => $composableBuilder(
    column: $table.competencias,
    builder: (column) => column,
  );

  GeneratedColumn<String> get situacion =>
      $composableBuilder(column: $table.situacion, builder: (column) => column);

  GeneratedColumn<String> get temas =>
      $composableBuilder(column: $table.temas, builder: (column) => column);

  GeneratedColumn<String> get producto =>
      $composableBuilder(column: $table.producto, builder: (column) => column);

  GeneratedColumn<String> get enfoques =>
      $composableBuilder(column: $table.enfoques, builder: (column) => column);

  GeneratedColumn<String> get propositos => $composableBuilder(
    column: $table.propositos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get materiales => $composableBuilder(
    column: $table.materiales,
    builder: (column) => column,
  );

  $$CursosTableAnnotationComposer get cursoId {
    final $$CursosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cursoId,
      referencedTable: $db.cursos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CursosTableAnnotationComposer(
            $db: $db,
            $table: $db.cursos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> sesionesRefs<T extends Object>(
    Expression<T> Function($$SesionesTableAnnotationComposer a) f,
  ) {
    final $$SesionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sesiones,
      getReferencedColumn: (t) => t.unidadId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SesionesTableAnnotationComposer(
            $db: $db,
            $table: $db.sesiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UnidadesTableTableManager
    extends
        RootTableManager<
          _$KipuDb,
          $UnidadesTable,
          Unidad,
          $$UnidadesTableFilterComposer,
          $$UnidadesTableOrderingComposer,
          $$UnidadesTableAnnotationComposer,
          $$UnidadesTableCreateCompanionBuilder,
          $$UnidadesTableUpdateCompanionBuilder,
          (Unidad, $$UnidadesTableReferences),
          Unidad,
          PrefetchHooks Function({bool cursoId, bool sesionesRefs})
        > {
  $$UnidadesTableTableManager(_$KipuDb db, $UnidadesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnidadesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnidadesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnidadesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cursoId = const Value.absent(),
                Value<int> anio = const Value.absent(),
                Value<int> periodo = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<String> titulo = const Value.absent(),
                Value<String?> desde = const Value.absent(),
                Value<String?> hasta = const Value.absent(),
                Value<String> competencias = const Value.absent(),
                Value<String?> situacion = const Value.absent(),
                Value<String?> temas = const Value.absent(),
                Value<String?> producto = const Value.absent(),
                Value<String> enfoques = const Value.absent(),
                Value<String?> propositos = const Value.absent(),
                Value<String?> materiales = const Value.absent(),
              }) => UnidadesCompanion(
                id: id,
                cursoId: cursoId,
                anio: anio,
                periodo: periodo,
                orden: orden,
                titulo: titulo,
                desde: desde,
                hasta: hasta,
                competencias: competencias,
                situacion: situacion,
                temas: temas,
                producto: producto,
                enfoques: enfoques,
                propositos: propositos,
                materiales: materiales,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cursoId,
                required int anio,
                required int periodo,
                required int orden,
                required String titulo,
                Value<String?> desde = const Value.absent(),
                Value<String?> hasta = const Value.absent(),
                Value<String> competencias = const Value.absent(),
                Value<String?> situacion = const Value.absent(),
                Value<String?> temas = const Value.absent(),
                Value<String?> producto = const Value.absent(),
                Value<String> enfoques = const Value.absent(),
                Value<String?> propositos = const Value.absent(),
                Value<String?> materiales = const Value.absent(),
              }) => UnidadesCompanion.insert(
                id: id,
                cursoId: cursoId,
                anio: anio,
                periodo: periodo,
                orden: orden,
                titulo: titulo,
                desde: desde,
                hasta: hasta,
                competencias: competencias,
                situacion: situacion,
                temas: temas,
                producto: producto,
                enfoques: enfoques,
                propositos: propositos,
                materiales: materiales,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UnidadesTable, Unidad>(table),
                  $$UnidadesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cursoId = false, sesionesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sesionesRefs) db.sesiones],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cursoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cursoId,
                        referencedTable: $$UnidadesTableReferences
                            ._cursoIdTable(db),
                        referencedColumn: $$UnidadesTableReferences
                            ._cursoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sesionesRefs)
                    await $_getPrefetchedDataByColumns<
                      Unidad,
                      $UnidadesTable,
                      Sesion,
                      $SesionesTable
                    >(
                      currentTable: table,
                      referencedTable: $$UnidadesTableReferences
                          ._sesionesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$UnidadesTableReferences(db, table, p0).sesionesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'unidad_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UnidadesTableProcessedTableManager =
    ProcessedTableManager<
      _$KipuDb,
      $UnidadesTable,
      Unidad,
      $$UnidadesTableFilterComposer,
      $$UnidadesTableOrderingComposer,
      $$UnidadesTableAnnotationComposer,
      $$UnidadesTableCreateCompanionBuilder,
      $$UnidadesTableUpdateCompanionBuilder,
      (Unidad, $$UnidadesTableReferences),
      Unidad,
      PrefetchHooks Function({bool cursoId, bool sesionesRefs})
    >;
typedef $$SesionesTableCreateCompanionBuilder = SesionesCompanion Function({
  Value<int> id,
  required int unidadId,
  required int orden,
  required String titulo,
  Value<String?> fecha,
  Value<String?> hora,
  Value<String?> competencia,
  Value<String?> proposito,
  Value<String?> inicio,
  Value<String?> desarrollo,
  Value<String?> cierre,
  Value<int?> minInicio,
  Value<int?> minDesarrollo,
  Value<int?> minCierre,
  Value<String?> materiales,
  Value<String?> tarea,
  Value<bool> hecha,
  Value<int?> columnaId,
});
typedef $$SesionesTableUpdateCompanionBuilder = SesionesCompanion Function({
  Value<int> id,
  Value<int> unidadId,
  Value<int> orden,
  Value<String> titulo,
  Value<String?> fecha,
  Value<String?> hora,
  Value<String?> competencia,
  Value<String?> proposito,
  Value<String?> inicio,
  Value<String?> desarrollo,
  Value<String?> cierre,
  Value<int?> minInicio,
  Value<int?> minDesarrollo,
  Value<int?> minCierre,
  Value<String?> materiales,
  Value<String?> tarea,
  Value<bool> hecha,
  Value<int?> columnaId,
});

final class $$SesionesTableReferences
    extends BaseReferences<_$KipuDb, $SesionesTable, Sesion> {
  $$SesionesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UnidadesTable _unidadIdTable(_$KipuDb db) =>
      db.unidades.createAlias('sesiones__unidad_id__unidades__id');

  $$UnidadesTableProcessedTableManager get unidadId {
    final $_column = $_itemColumn<int>('unidad_id')!;

    final manager = $$UnidadesTableTableManager(
      $_db,
      $_db.unidades,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_unidadIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SesionesTableFilterComposer extends Composer<_$KipuDb, $SesionesTable> {
  $$SesionesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hora => $composableBuilder(
    column: $table.hora,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get competencia => $composableBuilder(
    column: $table.competencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proposito => $composableBuilder(
    column: $table.proposito,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get desarrollo => $composableBuilder(
    column: $table.desarrollo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cierre => $composableBuilder(
    column: $table.cierre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minInicio => $composableBuilder(
    column: $table.minInicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minDesarrollo => $composableBuilder(
    column: $table.minDesarrollo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minCierre => $composableBuilder(
    column: $table.minCierre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get materiales => $composableBuilder(
    column: $table.materiales,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tarea => $composableBuilder(
    column: $table.tarea,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hecha => $composableBuilder(
    column: $table.hecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get columnaId => $composableBuilder(
    column: $table.columnaId,
    builder: (column) => ColumnFilters(column),
  );

  $$UnidadesTableFilterComposer get unidadId {
    final $$UnidadesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unidadId,
      referencedTable: $db.unidades,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnidadesTableFilterComposer(
            $db: $db,
            $table: $db.unidades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SesionesTableOrderingComposer
    extends Composer<_$KipuDb, $SesionesTable> {
  $$SesionesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hora => $composableBuilder(
    column: $table.hora,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get competencia => $composableBuilder(
    column: $table.competencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proposito => $composableBuilder(
    column: $table.proposito,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get desarrollo => $composableBuilder(
    column: $table.desarrollo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cierre => $composableBuilder(
    column: $table.cierre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minInicio => $composableBuilder(
    column: $table.minInicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minDesarrollo => $composableBuilder(
    column: $table.minDesarrollo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minCierre => $composableBuilder(
    column: $table.minCierre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get materiales => $composableBuilder(
    column: $table.materiales,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tarea => $composableBuilder(
    column: $table.tarea,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hecha => $composableBuilder(
    column: $table.hecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get columnaId => $composableBuilder(
    column: $table.columnaId,
    builder: (column) => ColumnOrderings(column),
  );

  $$UnidadesTableOrderingComposer get unidadId {
    final $$UnidadesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unidadId,
      referencedTable: $db.unidades,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnidadesTableOrderingComposer(
            $db: $db,
            $table: $db.unidades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SesionesTableAnnotationComposer
    extends Composer<_$KipuDb, $SesionesTable> {
  $$SesionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<String> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get hora =>
      $composableBuilder(column: $table.hora, builder: (column) => column);

  GeneratedColumn<String> get competencia => $composableBuilder(
    column: $table.competencia,
    builder: (column) => column,
  );

  GeneratedColumn<String> get proposito =>
      $composableBuilder(column: $table.proposito, builder: (column) => column);

  GeneratedColumn<String> get inicio =>
      $composableBuilder(column: $table.inicio, builder: (column) => column);

  GeneratedColumn<String> get desarrollo => $composableBuilder(
    column: $table.desarrollo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cierre =>
      $composableBuilder(column: $table.cierre, builder: (column) => column);

  GeneratedColumn<int> get minInicio =>
      $composableBuilder(column: $table.minInicio, builder: (column) => column);

  GeneratedColumn<int> get minDesarrollo => $composableBuilder(
    column: $table.minDesarrollo,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minCierre =>
      $composableBuilder(column: $table.minCierre, builder: (column) => column);

  GeneratedColumn<String> get materiales => $composableBuilder(
    column: $table.materiales,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tarea =>
      $composableBuilder(column: $table.tarea, builder: (column) => column);

  GeneratedColumn<bool> get hecha =>
      $composableBuilder(column: $table.hecha, builder: (column) => column);

  GeneratedColumn<int> get columnaId =>
      $composableBuilder(column: $table.columnaId, builder: (column) => column);

  $$UnidadesTableAnnotationComposer get unidadId {
    final $$UnidadesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.unidadId,
      referencedTable: $db.unidades,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnidadesTableAnnotationComposer(
            $db: $db,
            $table: $db.unidades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SesionesTableTableManager
    extends
        RootTableManager<
          _$KipuDb,
          $SesionesTable,
          Sesion,
          $$SesionesTableFilterComposer,
          $$SesionesTableOrderingComposer,
          $$SesionesTableAnnotationComposer,
          $$SesionesTableCreateCompanionBuilder,
          $$SesionesTableUpdateCompanionBuilder,
          (Sesion, $$SesionesTableReferences),
          Sesion,
          PrefetchHooks Function({bool unidadId})
        > {
  $$SesionesTableTableManager(_$KipuDb db, $SesionesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SesionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SesionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SesionesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> unidadId = const Value.absent(),
                Value<int> orden = const Value.absent(),
                Value<String> titulo = const Value.absent(),
                Value<String?> fecha = const Value.absent(),
                Value<String?> hora = const Value.absent(),
                Value<String?> competencia = const Value.absent(),
                Value<String?> proposito = const Value.absent(),
                Value<String?> inicio = const Value.absent(),
                Value<String?> desarrollo = const Value.absent(),
                Value<String?> cierre = const Value.absent(),
                Value<int?> minInicio = const Value.absent(),
                Value<int?> minDesarrollo = const Value.absent(),
                Value<int?> minCierre = const Value.absent(),
                Value<String?> materiales = const Value.absent(),
                Value<String?> tarea = const Value.absent(),
                Value<bool> hecha = const Value.absent(),
                Value<int?> columnaId = const Value.absent(),
              }) => SesionesCompanion(
                id: id,
                unidadId: unidadId,
                orden: orden,
                titulo: titulo,
                fecha: fecha,
                hora: hora,
                competencia: competencia,
                proposito: proposito,
                inicio: inicio,
                desarrollo: desarrollo,
                cierre: cierre,
                minInicio: minInicio,
                minDesarrollo: minDesarrollo,
                minCierre: minCierre,
                materiales: materiales,
                tarea: tarea,
                hecha: hecha,
                columnaId: columnaId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int unidadId,
                required int orden,
                required String titulo,
                Value<String?> fecha = const Value.absent(),
                Value<String?> hora = const Value.absent(),
                Value<String?> competencia = const Value.absent(),
                Value<String?> proposito = const Value.absent(),
                Value<String?> inicio = const Value.absent(),
                Value<String?> desarrollo = const Value.absent(),
                Value<String?> cierre = const Value.absent(),
                Value<int?> minInicio = const Value.absent(),
                Value<int?> minDesarrollo = const Value.absent(),
                Value<int?> minCierre = const Value.absent(),
                Value<String?> materiales = const Value.absent(),
                Value<String?> tarea = const Value.absent(),
                Value<bool> hecha = const Value.absent(),
                Value<int?> columnaId = const Value.absent(),
              }) => SesionesCompanion.insert(
                id: id,
                unidadId: unidadId,
                orden: orden,
                titulo: titulo,
                fecha: fecha,
                hora: hora,
                competencia: competencia,
                proposito: proposito,
                inicio: inicio,
                desarrollo: desarrollo,
                cierre: cierre,
                minInicio: minInicio,
                minDesarrollo: minDesarrollo,
                minCierre: minCierre,
                materiales: materiales,
                tarea: tarea,
                hecha: hecha,
                columnaId: columnaId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SesionesTable, Sesion>(table),
                  $$SesionesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({unidadId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (unidadId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.unidadId,
                        referencedTable: $$SesionesTableReferences
                            ._unidadIdTable(db),
                        referencedColumn: $$SesionesTableReferences
                            ._unidadIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SesionesTableProcessedTableManager =
    ProcessedTableManager<
      _$KipuDb,
      $SesionesTable,
      Sesion,
      $$SesionesTableFilterComposer,
      $$SesionesTableOrderingComposer,
      $$SesionesTableAnnotationComposer,
      $$SesionesTableCreateCompanionBuilder,
      $$SesionesTableUpdateCompanionBuilder,
      (Sesion, $$SesionesTableReferences),
      Sesion,
      PrefetchHooks Function({bool unidadId})
    >;

class $KipuDbManager {
  final _$KipuDb _db;
  $KipuDbManager(this._db);
  $$AjustesTableTableManager get ajustes =>
      $$AjustesTableTableManager(_db, _db.ajustes);
  $$ColegiosTableTableManager get colegios =>
      $$ColegiosTableTableManager(_db, _db.colegios);
  $$CursosTableTableManager get cursos =>
      $$CursosTableTableManager(_db, _db.cursos);
  $$EstudiantesTableTableManager get estudiantes =>
      $$EstudiantesTableTableManager(_db, _db.estudiantes);
  $$AsistenciasTableTableManager get asistencias =>
      $$AsistenciasTableTableManager(_db, _db.asistencias);
  $$NotasTableTableManager get notas =>
      $$NotasTableTableManager(_db, _db.notas);
  $$EventosTableTableManager get eventos =>
      $$EventosTableTableManager(_db, _db.eventos);
  $$HorariosTableTableManager get horarios =>
      $$HorariosTableTableManager(_db, _db.horarios);
  $$FranjasTableTableManager get franjas =>
      $$FranjasTableTableManager(_db, _db.franjas);
  $$RegistroColumnasTableTableManager get registroColumnas =>
      $$RegistroColumnasTableTableManager(_db, _db.registroColumnas);
  $$RegistroNotasTableTableManager get registroNotas =>
      $$RegistroNotasTableTableManager(_db, _db.registroNotas);
  $$ConductasTableTableManager get conductas =>
      $$ConductasTableTableManager(_db, _db.conductas);
  $$PendientesTableTableManager get pendientes =>
      $$PendientesTableTableManager(_db, _db.pendientes);
  $$AnecdotasTableTableManager get anecdotas =>
      $$AnecdotasTableTableManager(_db, _db.anecdotas);
  $$ClasesDiarioTableTableManager get clasesDiario =>
      $$ClasesDiarioTableTableManager(_db, _db.clasesDiario);
  $$UnidadesTableTableManager get unidades =>
      $$UnidadesTableTableManager(_db, _db.unidades);
  $$SesionesTableTableManager get sesiones =>
      $$SesionesTableTableManager(_db, _db.sesiones);
}
