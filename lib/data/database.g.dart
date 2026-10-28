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
  List<GeneratedColumn> get $columns => [id, nombre, lugar, creado];
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
  final DateTime creado;
  const Colegio({
    required this.id,
    required this.nombre,
    this.lugar,
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
      'creado': serializer.toJson<DateTime>(creado),
    };
  }

  Colegio copyWith({
    int? id,
    String? nombre,
    Value<String?> lugar = const Value.absent(),
    DateTime? creado,
  }) => Colegio(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    lugar: lugar.present ? lugar.value : this.lugar,
    creado: creado ?? this.creado,
  );
  Colegio copyWithCompanion(ColegiosCompanion data) {
    return Colegio(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      lugar: data.lugar.present ? data.lugar.value : this.lugar,
      creado: data.creado.present ? data.creado.value : this.creado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Colegio(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('lugar: $lugar, ')
          ..write('creado: $creado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, lugar, creado);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Colegio &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.lugar == this.lugar &&
          other.creado == this.creado);
}

class ColegiosCompanion extends UpdateCompanion<Colegio> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String?> lugar;
  final Value<DateTime> creado;
  const ColegiosCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.lugar = const Value.absent(),
    this.creado = const Value.absent(),
  });
  ColegiosCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    this.lugar = const Value.absent(),
    this.creado = const Value.absent(),
  }) : nombre = Value(nombre);
  static Insertable<Colegio> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? lugar,
    Expression<DateTime>? creado,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (lugar != null) 'lugar': lugar,
      if (creado != null) 'creado': creado,
    });
  }

  ColegiosCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<String?>? lugar,
    Value<DateTime>? creado,
  }) {
    return ColegiosCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      lugar: lugar ?? this.lugar,
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
  final DateTime creado;
  const Curso({
    required this.id,
    required this.colegioId,
    required this.nivel,
    required this.grado,
    required this.seccion,
    required this.nombre,
    this.area,
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
    DateTime? creado,
  }) => Curso(
    id: id ?? this.id,
    colegioId: colegioId ?? this.colegioId,
    nivel: nivel ?? this.nivel,
    grado: grado ?? this.grado,
    seccion: seccion ?? this.seccion,
    nombre: nombre ?? this.nombre,
    area: area.present ? area.value : this.area,
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
          ..write('creado: $creado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, colegioId, nivel, grado, seccion, nombre, area, creado);
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
  final Value<DateTime> creado;
  const CursosCompanion({
    this.id = const Value.absent(),
    this.colegioId = const Value.absent(),
    this.nivel = const Value.absent(),
    this.grado = const Value.absent(),
    this.seccion = const Value.absent(),
    this.nombre = const Value.absent(),
    this.area = const Value.absent(),
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
    telefono,
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
    if (data.containsKey('telefono')) {
      context.handle(
        _telefonoMeta,
        telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta),
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
      telefono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefono'],
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
  final String? telefono;
  final DateTime creado;
  const Estudiante({
    required this.id,
    required this.cursoId,
    required this.apellidos,
    required this.nombres,
    this.dni,
    this.apoderado,
    this.telefono,
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
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
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
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
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
      telefono: serializer.fromJson<String?>(json['telefono']),
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
      'telefono': serializer.toJson<String?>(telefono),
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
    Value<String?> telefono = const Value.absent(),
    DateTime? creado,
  }) => Estudiante(
    id: id ?? this.id,
    cursoId: cursoId ?? this.cursoId,
    apellidos: apellidos ?? this.apellidos,
    nombres: nombres ?? this.nombres,
    dni: dni.present ? dni.value : this.dni,
    apoderado: apoderado.present ? apoderado.value : this.apoderado,
    telefono: telefono.present ? telefono.value : this.telefono,
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
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
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
          ..write('telefono: $telefono, ')
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
    telefono,
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
          other.telefono == this.telefono &&
          other.creado == this.creado);
}

class EstudiantesCompanion extends UpdateCompanion<Estudiante> {
  final Value<int> id;
  final Value<int> cursoId;
  final Value<String> apellidos;
  final Value<String> nombres;
  final Value<String?> dni;
  final Value<String?> apoderado;
  final Value<String?> telefono;
  final Value<DateTime> creado;
  const EstudiantesCompanion({
    this.id = const Value.absent(),
    this.cursoId = const Value.absent(),
    this.apellidos = const Value.absent(),
    this.nombres = const Value.absent(),
    this.dni = const Value.absent(),
    this.apoderado = const Value.absent(),
    this.telefono = const Value.absent(),
    this.creado = const Value.absent(),
  });
  EstudiantesCompanion.insert({
    this.id = const Value.absent(),
    required int cursoId,
    required String apellidos,
    required String nombres,
    this.dni = const Value.absent(),
    this.apoderado = const Value.absent(),
    this.telefono = const Value.absent(),
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
    Expression<String>? telefono,
    Expression<DateTime>? creado,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cursoId != null) 'curso_id': cursoId,
      if (apellidos != null) 'apellidos': apellidos,
      if (nombres != null) 'nombres': nombres,
      if (dni != null) 'dni': dni,
      if (apoderado != null) 'apoderado': apoderado,
      if (telefono != null) 'telefono': telefono,
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
    Value<String?>? telefono,
    Value<DateTime>? creado,
  }) {
    return EstudiantesCompanion(
      id: id ?? this.id,
      cursoId: cursoId ?? this.cursoId,
      apellidos: apellidos ?? this.apellidos,
      nombres: nombres ?? this.nombres,
      dni: dni ?? this.dni,
      apoderado: apoderado ?? this.apoderado,
      telefono: telefono ?? this.telefono,
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
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
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
          ..write('telefono: $telefono, ')
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
  @override
  List<GeneratedColumn> get $columns => [estudianteId, fecha, estado];
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
  const Asistencia({
    required this.estudianteId,
    required this.fecha,
    required this.estado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['estudiante_id'] = Variable<int>(estudianteId);
    map['fecha'] = Variable<String>(fecha);
    map['estado'] = Variable<String>(estado);
    return map;
  }

  AsistenciasCompanion toCompanion(bool nullToAbsent) {
    return AsistenciasCompanion(
      estudianteId: Value(estudianteId),
      fecha: Value(fecha),
      estado: Value(estado),
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
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'estudianteId': serializer.toJson<int>(estudianteId),
      'fecha': serializer.toJson<String>(fecha),
      'estado': serializer.toJson<String>(estado),
    };
  }

  Asistencia copyWith({int? estudianteId, String? fecha, String? estado}) =>
      Asistencia(
        estudianteId: estudianteId ?? this.estudianteId,
        fecha: fecha ?? this.fecha,
        estado: estado ?? this.estado,
      );
  Asistencia copyWithCompanion(AsistenciasCompanion data) {
    return Asistencia(
      estudianteId: data.estudianteId.present
          ? data.estudianteId.value
          : this.estudianteId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      estado: data.estado.present ? data.estado.value : this.estado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Asistencia(')
          ..write('estudianteId: $estudianteId, ')
          ..write('fecha: $fecha, ')
          ..write('estado: $estado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(estudianteId, fecha, estado);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Asistencia &&
          other.estudianteId == this.estudianteId &&
          other.fecha == this.fecha &&
          other.estado == this.estado);
}

class AsistenciasCompanion extends UpdateCompanion<Asistencia> {
  final Value<int> estudianteId;
  final Value<String> fecha;
  final Value<String> estado;
  final Value<int> rowid;
  const AsistenciasCompanion({
    this.estudianteId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.estado = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AsistenciasCompanion.insert({
    required int estudianteId,
    required String fecha,
    required String estado,
    this.rowid = const Value.absent(),
  }) : estudianteId = Value(estudianteId),
       fecha = Value(fecha),
       estado = Value(estado);
  static Insertable<Asistencia> custom({
    Expression<int>? estudianteId,
    Expression<String>? fecha,
    Expression<String>? estado,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (estudianteId != null) 'estudiante_id': estudianteId,
      if (fecha != null) 'fecha': fecha,
      if (estado != null) 'estado': estado,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AsistenciasCompanion copyWith({
    Value<int>? estudianteId,
    Value<String>? fecha,
    Value<String>? estado,
    Value<int>? rowid,
  }) {
    return AsistenciasCompanion(
      estudianteId: estudianteId ?? this.estudianteId,
      fecha: fecha ?? this.fecha,
      estado: estado ?? this.estado,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fecha,
    hora,
    titulo,
    etiqueta,
    tipo,
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
  const Evento({
    required this.id,
    required this.fecha,
    this.hora,
    required this.titulo,
    this.etiqueta,
    required this.tipo,
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
    };
  }

  Evento copyWith({
    int? id,
    String? fecha,
    Value<String?> hora = const Value.absent(),
    String? titulo,
    Value<String?> etiqueta = const Value.absent(),
    String? tipo,
  }) => Evento(
    id: id ?? this.id,
    fecha: fecha ?? this.fecha,
    hora: hora.present ? hora.value : this.hora,
    titulo: titulo ?? this.titulo,
    etiqueta: etiqueta.present ? etiqueta.value : this.etiqueta,
    tipo: tipo ?? this.tipo,
  );
  Evento copyWithCompanion(EventosCompanion data) {
    return Evento(
      id: data.id.present ? data.id.value : this.id,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      hora: data.hora.present ? data.hora.value : this.hora,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      etiqueta: data.etiqueta.present ? data.etiqueta.value : this.etiqueta,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
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
          ..write('tipo: $tipo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fecha, hora, titulo, etiqueta, tipo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Evento &&
          other.id == this.id &&
          other.fecha == this.fecha &&
          other.hora == this.hora &&
          other.titulo == this.titulo &&
          other.etiqueta == this.etiqueta &&
          other.tipo == this.tipo);
}

class EventosCompanion extends UpdateCompanion<Evento> {
  final Value<int> id;
  final Value<String> fecha;
  final Value<String?> hora;
  final Value<String> titulo;
  final Value<String?> etiqueta;
  final Value<String> tipo;
  const EventosCompanion({
    this.id = const Value.absent(),
    this.fecha = const Value.absent(),
    this.hora = const Value.absent(),
    this.titulo = const Value.absent(),
    this.etiqueta = const Value.absent(),
    this.tipo = const Value.absent(),
  });
  EventosCompanion.insert({
    this.id = const Value.absent(),
    required String fecha,
    this.hora = const Value.absent(),
    required String titulo,
    this.etiqueta = const Value.absent(),
    this.tipo = const Value.absent(),
  }) : fecha = Value(fecha),
       titulo = Value(titulo);
  static Insertable<Evento> custom({
    Expression<int>? id,
    Expression<String>? fecha,
    Expression<String>? hora,
    Expression<String>? titulo,
    Expression<String>? etiqueta,
    Expression<String>? tipo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fecha != null) 'fecha': fecha,
      if (hora != null) 'hora': hora,
      if (titulo != null) 'titulo': titulo,
      if (etiqueta != null) 'etiqueta': etiqueta,
      if (tipo != null) 'tipo': tipo,
    });
  }

  EventosCompanion copyWith({
    Value<int>? id,
    Value<String>? fecha,
    Value<String?>? hora,
    Value<String>? titulo,
    Value<String?>? etiqueta,
    Value<String>? tipo,
  }) {
    return EventosCompanion(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      titulo: titulo ?? this.titulo,
      etiqueta: etiqueta ?? this.etiqueta,
      tipo: tipo ?? this.tipo,
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
          ..write('tipo: $tipo')
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
  Value<DateTime> creado,
});
typedef $$ColegiosTableUpdateCompanionBuilder = ColegiosCompanion Function({
  Value<int> id,
  Value<String> nombre,
  Value<String?> lugar,
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
          PrefetchHooks Function({bool cursosRefs})
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
                Value<DateTime> creado = const Value.absent(),
              }) => ColegiosCompanion(
                id: id,
                nombre: nombre,
                lugar: lugar,
                creado: creado,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                Value<String?> lugar = const Value.absent(),
                Value<DateTime> creado = const Value.absent(),
              }) => ColegiosCompanion.insert(
                id: id,
                nombre: nombre,
                lugar: lugar,
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
          prefetchHooksCallback: ({cursosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cursosRefs) db.cursos],
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
      PrefetchHooks Function({bool cursosRefs})
    >;
typedef $$CursosTableCreateCompanionBuilder = CursosCompanion Function({
  Value<int> id,
  required int colegioId,
  required String nivel,
  required String grado,
  required String seccion,
  required String nombre,
  Value<String?> area,
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
                Value<DateTime> creado = const Value.absent(),
              }) => CursosCompanion(
                id: id,
                colegioId: colegioId,
                nivel: nivel,
                grado: grado,
                seccion: seccion,
                nombre: nombre,
                area: area,
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
                Value<DateTime> creado = const Value.absent(),
              }) => CursosCompanion.insert(
                id: id,
                colegioId: colegioId,
                nivel: nivel,
                grado: grado,
                seccion: seccion,
                nombre: nombre,
                area: area,
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
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (estudiantesRefs) db.estudiantes,
                    if (horariosRefs) db.horarios,
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
      Value<String?> telefono,
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
      Value<String?> telefono,
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

  ColumnFilters<String> get telefono => $composableBuilder(
    column: $table.telefono,
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

  ColumnOrderings<String> get telefono => $composableBuilder(
    column: $table.telefono,
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

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

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
                Value<String?> telefono = const Value.absent(),
                Value<DateTime> creado = const Value.absent(),
              }) => EstudiantesCompanion(
                id: id,
                cursoId: cursoId,
                apellidos: apellidos,
                nombres: nombres,
                dni: dni,
                apoderado: apoderado,
                telefono: telefono,
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
                Value<String?> telefono = const Value.absent(),
                Value<DateTime> creado = const Value.absent(),
              }) => EstudiantesCompanion.insert(
                id: id,
                cursoId: cursoId,
                apellidos: apellidos,
                nombres: nombres,
                dni: dni,
                apoderado: apoderado,
                telefono: telefono,
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
              ({cursoId = false, asistenciasRefs = false, notasRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (asistenciasRefs) db.asistencias,
                    if (notasRefs) db.notas,
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
      })
    >;
typedef $$AsistenciasTableCreateCompanionBuilder =
    AsistenciasCompanion Function({
      required int estudianteId,
      required String fecha,
      required String estado,
      Value<int> rowid,
    });
typedef $$AsistenciasTableUpdateCompanionBuilder =
    AsistenciasCompanion Function({
      Value<int> estudianteId,
      Value<String> fecha,
      Value<String> estado,
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
                Value<int> rowid = const Value.absent(),
              }) => AsistenciasCompanion(
                estudianteId: estudianteId,
                fecha: fecha,
                estado: estado,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int estudianteId,
                required String fecha,
                required String estado,
                Value<int> rowid = const Value.absent(),
              }) => AsistenciasCompanion.insert(
                estudianteId: estudianteId,
                fecha: fecha,
                estado: estado,
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
});
typedef $$EventosTableUpdateCompanionBuilder = EventosCompanion Function({
  Value<int> id,
  Value<String> fecha,
  Value<String?> hora,
  Value<String> titulo,
  Value<String?> etiqueta,
  Value<String> tipo,
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
              }) => EventosCompanion(
                id: id,
                fecha: fecha,
                hora: hora,
                titulo: titulo,
                etiqueta: etiqueta,
                tipo: tipo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String fecha,
                Value<String?> hora = const Value.absent(),
                required String titulo,
                Value<String?> etiqueta = const Value.absent(),
                Value<String> tipo = const Value.absent(),
              }) => EventosCompanion.insert(
                id: id,
                fecha: fecha,
                hora: hora,
                titulo: titulo,
                etiqueta: etiqueta,
                tipo: tipo,
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
}
