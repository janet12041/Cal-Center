-- Listo
CREATE TABLE entrenador (
    curp             varchar(18) PRIMARY KEY,
    id_piso          int NOT NULL,
    id_edificio      int NOT NULL,
    nombre           varchar(50),
    apellido_pat     varchar(50) CHECK (apellido_pat != ''),
    apellido_mat     varchar(50) CHECK (apellido_mat != ''),
    fecha_nacimiento date NOT NULL,
    calle            varchar(50) NOT NULL CHECK (calle != ''),
    num_ext          int NOT NULL CHECK (num_ext > 0),
    colonia          varchar(50) NOT NULL CHECK (colonia != ''),
    municipio        varchar(50) NOT NULL CHECK (municipio != ''),
    estado           varchar(50) NOT NULL CHECK (estado != ''),
    cp               int NOT NULL CHECK (cp > 0),
    telefono         bigint UNIQUE,
    correo           varchar(100) UNIQUE,
    fotografia       text NOT NULL CHECK (fotografia != ''),
    salario_x_hora   int CHECK (salario_x_hora = 70),
    nss              bigint UNIQUE CHECK (nss > 0),
    fecha_inicio    date NOT NULL,

    CONSTRAINT curp_notnull CHECK (curp != '' AND length(curp) = 18),
    CONSTRAINT nombre_notnull CHECK (nombre IS NOT NULL AND nombre != '')
);

-- Listo
CREATE TABLE agente_telefonico (
    curp             varchar(18) PRIMARY KEY,
    id_piso          int NOT NULL,
    id_edificio      int NOT NULL,
    id_curso         int, 
    nombre           varchar(50),
    apellido_pat     varchar(50) CHECK (apellido_pat != ''),
    apellido_mat     varchar(50) CHECK (apellido_mat != ''),
    fecha_nacimiento date NOT NULL,
    calle            varchar(50) NOT NULL CHECK (calle != ''),
    num_ext          int NOT NULL CHECK (num_ext > 0),
    colonia          varchar(50) NOT NULL CHECK (colonia != ''),
    municipio        varchar(50) NOT NULL CHECK (municipio != ''),
    estado           varchar(50) NOT NULL CHECK (estado != ''),
    cp               int NOT NULL CHECK (cp > 0),
    telefono         bigint UNIQUE,
    correo           varchar(100) UNIQUE,
    fotografia       text NOT NULL CHECK (fotografia != ''),
    salario_x_hora   int CHECK (salario_x_hora = 40),
    evaluacion	     int CHECK (evaluacion >= 0 AND evaluacion <= 10),

    CONSTRAINT curp_notnull CHECK (curp != '' AND length(curp) = 18),
    CONSTRAINT nombre_notnull CHECK (nombre IS NOT NULL AND nombre != '')
);

-- Listo
CREATE TABLE asistir_entrenador (
    id_entrenador  varchar(18) NOT NULL,
    id_horario     int NOT NULL,
    id_curso       int NOT NULL,
    fecha          date NOT NULL
);


-- Listo
CREATE TABLE asistir_agente (
    id_agente  varchar(18) NOT NULL,
    id_horario int NOT NULL,
    id_curso   int NOT NULL,
    fecha      date NOT NULL
);

-- Listo
CREATE TABLE horario (
    id_horario  int,
    id_curso    int,
    dia         varchar(10),
    hora_inicio time NOT NULL,
    hora_fin    time NOT NULL,
	
    CONSTRAINT horas CHECK (hora_fin > hora_inicio),
    CONSTRAINT dias CHECK (dia IS NOT NULL AND (dia = 'Lunes' OR dia = 'Martes' OR dia = 'Miercoles' OR dia = 'Jueves' OR dia = 'Viernes' OR dia = 'Sabado'))
);

-- Listo
CREATE TABLE curso (
    id_curso              int PRIMARY KEY,
    id_entrenador         varchar(18) NOT NULL,
    id_sala_entrenamiento int,
    id_piso               int ,
    id_edificio           int ,
    id_cliente            varchar(13) NOT NULL,
    nombre_curso          text,
    turno                 varchar(10),
    fecha_inicio          date NOT NULL,
    fecha_fin             date NOT NULL,
    modalidad		  varchar(10),
    num_horas             int NOT NULL CHECK (num_horas > 0),

    CONSTRAINT nombre_curso_notnull CHECK (nombre_curso IS NOT NULL AND nombre_curso <> ''),
    CONSTRAINT turno_notnull CHECK (turno IS NOT NULL AND (turno = 'Matutino' OR turno = 'Vespertino')),
	CONSTRAINT modalidad_notnull CHECK (modalidad IS NOT NULL AND ((modalidad = 'Presencial' AND id_piso IS NOT NULL AND id_sala_entrenamiento IS NOT NULL AND id_edificio IS NOT NULL) OR (modalidad = 'Linea' AND id_piso IS NULL AND id_sala_entrenamiento IS NULL AND id_edificio IS NULL))),
	CONSTRAINT fechas CHECK (fecha_fin > fecha_inicio)
);
-- Listo
CREATE TABLE cliente (
    rfc               varchar(13) PRIMARY KEY,
    razon_social      text,
    telefono_contacto bigint NOT NULL CHECK (telefono_contacto > 0),
    persona_contacto  varchar(50),
    correo_contacto   varchar(100),
    so                varchar(10),

    CONSTRAINT rfc_notnull CHECK (rfc != '' AND (length(rfc) = 12 OR length(rfc) = 13)),
    CONSTRAINT razon_social_notnull CHECK (razon_social IS NOT NULL AND razon_social != ''),
    CONSTRAINT persona_contacto_notnull CHECK (persona_contacto IS NOT NULL AND persona_contacto != ''),
    CONSTRAINT correo_contacto_notnull CHECK (correo_contacto IS NOT NULL AND correo_contacto != ''),
    CONSTRAINT so_notnull CHECK (so IS NOT NULL AND (so = 'Linux' OR so = 'Windows'))
);

-- Listo
CREATE TABLE piso (
    id_piso     int,
    id_edificio int
);

CREATE TABLE edificio (
    id_edificio 	 int PRIMARY KEY,
    calle            varchar(50) NOT NULL CHECK (calle != ''),
    num_ext          int NOT NULL CHECK (num_ext > 0),
    colonia          varchar(50) NOT NULL CHECK (colonia != ''),
    municipio        varchar(50) NOT NULL CHECK (municipio != ''),
    estado           varchar(50) NOT NULL CHECK (estado != ''),
    cp               int NOT NULL CHECK (cp > 0)
);

CREATE TABLE sala_entrenamiento (
    id_sala_entrenamiento int,
    id_piso               int,
    id_edificio           int
);

CREATE TABLE sala_operaciones (
    id_sala_operaciones int,
    id_piso             int,
    id_edificio         int,
    id_cliente          varchar(13),
    estado              int,
    fecha_inicio       date,
    fecha_fin          date,
    
    CONSTRAINT estado_notnull CHECK (estado IS NOT NULL AND (estado = 0 OR estado = 1)),
	CONSTRAINT estado_sala CHECK ((id_cliente IS NULL AND estado = 0 AND fecha_inicio IS NULL AND fecha_fin IS NULL) OR 
							 (id_cliente IS NOT NULL AND estado = 1 AND fecha_inicio IS NOT NULL AND fecha_fin IS NOT NULL)),
	CONSTRAINT fechas CHECK (fecha_fin > fecha_inicio)
);

CREATE TABLE estacion_entrenamiento (
    id_estacion           int PRIMARY KEY,
    id_sala_entrenamiento int NOT NULL,
    id_piso               int NOT NULL,
    id_edificio           int NOT NULL,
    so                    varchar(10),

	CONSTRAINT so_notnull CHECK (so IS NOT NULL AND (so = 'Linux' OR so = 'Windows'))
);

CREATE TABLE estacion_operaciones (
    id_estacion         int PRIMARY KEY,
    id_sala_operaciones int NOT NULL,
    id_piso             int NOT NULL,
    id_edificio         int NOT NULL,
    so                  varchar(10),

    CONSTRAINT so_notnull CHECK (so IS NOT NULL AND (so = 'Linux' OR so = 'Windows'))
);

CREATE TABLE aditamento_entrenamiento (
    id_aditamento int PRIMARY KEY,
    id_estacion   int NOT NULL,
    nombre        varchar(50)

    CONSTRAINT nombre_notnull CHECK (nombre IS NOT NULL AND nombre != '')
);

CREATE TABLE aditamento_operaciones (
    id_aditamento int PRIMARY KEY,
    id_estacion   int NOT NULL,
    nombre        varchar(50)

    CONSTRAINT nombre_notnull CHECK (nombre IS NOT NULL AND nombre != '')
);

ALTER TABLE horario
ADD CONSTRAINT pk_horario
PRIMARY KEY (id_horario, id_curso);

ALTER TABLE piso
ADD CONSTRAINT pk_piso
PRIMARY KEY (id_piso, id_edificio);

ALTER TABLE sala_entrenamiento
ADD CONSTRAINT pk_sala_entrenamiento
PRIMARY KEY (id_sala_entrenamiento,id_piso,id_edificio);

ALTER TABLE sala_operaciones
ADD CONSTRAINT pk_operaciones
PRIMARY KEY (id_sala_operaciones, id_piso, id_edificio);


ALTER TABLE entrenador
ADD CONSTRAINT fk_edificio
FOREIGN KEY (id_piso, id_edificio)
REFERENCES piso (id_piso, id_edificio)
ON UPDATE CASCADE
ON DELETE CASCADE;


ALTER TABLE agente_telefonico
ADD CONSTRAINT fk_agente
FOREIGN KEY (id_piso, id_edificio)
REFERENCES piso (id_piso, id_edificio)
ON UPDATE CASCADE
ON DELETE CASCADE,

ADD CONSTRAINT fk_curso
FOREIGN KEY (id_curso)
REFERENCES curso (id_curso)
ON UPDATE CASCADE
ON DELETE CASCADE;


ALTER TABLE asistir_entrenador
ADD CONSTRAINT fk_entrenador
FOREIGN KEY (id_entrenador)
REFERENCES entrenador (curp)
ON UPDATE CASCADE
ON DELETE CASCADE,

ADD CONSTRAINT fk_asistir
FOREIGN KEY (id_horario, id_curso)
REFERENCES horario (id_horario, id_curso)
ON UPDATE CASCADE
ON DELETE CASCADE;


ALTER TABLE asistir_agente
ADD CONSTRAINT fk_agente
FOREIGN KEY (id_agente)
REFERENCES agente_telefonico (curp)
ON UPDATE CASCADE
ON DELETE CASCADE,

ADD CONSTRAINT fk_asistir
FOREIGN KEY (id_horario, id_curso)
REFERENCES horario (id_horario, id_curso)
ON UPDATE CASCADE
ON DELETE CASCADE;


ALTER TABLE horario
ADD CONSTRAINT fk_curso
FOREIGN KEY (id_curso)
REFERENCES curso (id_curso)
ON UPDATE CASCADE
ON DELETE CASCADE;


ALTER TABLE curso
ADD CONSTRAINT fk_entrenador
FOREIGN KEY (id_entrenador)
REFERENCES entrenador (curp)
ON UPDATE CASCADE
ON DELETE CASCADE,

ADD CONSTRAINT fk_sala_entrenamiento
FOREIGN KEY (id_sala_entrenamiento, id_piso, id_edificio)
REFERENCES sala_entrenamiento (id_sala_entrenamiento, id_piso, id_edificio)
ON UPDATE CASCADE
ON DELETE CASCADE,

ADD CONSTRAINT fk_cliente
FOREIGN KEY (id_cliente)
REFERENCES cliente (rfc)
ON UPDATE CASCADE
ON DELETE CASCADE;


ALTER TABLE piso
ADD CONSTRAINT fk_edificio
FOREIGN KEY (id_edificio)
REFERENCES edificio (id_edificio)
ON UPDATE CASCADE
ON DELETE CASCADE;


ALTER TABLE sala_entrenamiento
ADD CONSTRAINT fk_piso
FOREIGN KEY (id_piso, id_edificio)
REFERENCES piso (id_piso, id_edificio)
ON UPDATE CASCADE
ON DELETE CASCADE;


ALTER TABLE sala_operaciones
ADD CONSTRAINT  fk_piso
FOREIGN KEY (id_piso, id_edificio)
REFERENCES piso (id_piso, id_edificio)
ON UPDATE CASCADE
ON DELETE CASCADE,

ADD CONSTRAINT fk_cliente
FOREIGN KEY (id_cliente)
REFERENCES cliente (rfc)
ON UPDATE CASCADE
ON DELETE CASCADE;


ALTER TABLE estacion_entrenamiento
ADD CONSTRAINT fk_sala_entrenamiento
FOREIGN KEY (id_sala_entrenamiento, id_piso, id_edificio)
REFERENCES sala_entrenamiento (id_sala_entrenamiento, id_piso, id_edificio)
ON UPDATE CASCADE
ON DELETE CASCADE;


ALTER TABLE estacion_operaciones
ADD CONSTRAINT fk_sala_operaciones
FOREIGN KEY (id_sala_operaciones, id_piso, id_edificio)
REFERENCES sala_operaciones (id_sala_operaciones, id_piso, id_edificio)
ON UPDATE CASCADE
ON DELETE CASCADE;


ALTER TABLE aditamento_entrenamiento
ADD CONSTRAINT fk_estacion
FOREIGN KEY (id_estacion)
REFERENCES estacion_entrenamiento (id_estacion)
ON UPDATE CASCADE
ON DELETE CASCADE;


ALTER TABLE aditamento_operaciones
ADD CONSTRAINT fk_estacion
FOREIGN KEY (id_estacion)
REFERENCES estacion_operaciones (id_estacion)
ON UPDATE CASCADE
ON DELETE CASCADE;
