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

abstract class _$KipuDb extends GeneratedDatabase {
  _$KipuDb(QueryExecutor e) : super(e);
  $KipuDbManager get managers => $KipuDbManager(this);
  late final $AjustesTable ajustes = $AjustesTable(this);
  late final $ColegiosTable colegios = $ColegiosTable(this);
  late final $CursosTable cursos = $CursosTable(this);
  late final $EstudiantesTable estudiantes = $EstudiantesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    ajustes,
    colegios,
    cursos,
    estudiantes,
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
          PrefetchHooks Function({bool colegioId, bool estudiantesRefs})
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
              ({colegioId = false, estudiantesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (estudiantesRefs) db.estudiantes,
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
      PrefetchHooks Function({bool colegioId, bool estudiantesRefs})
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
          PrefetchHooks Function({bool cursoId})
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
                return [];
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
}
