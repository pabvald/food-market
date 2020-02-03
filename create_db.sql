-- Drop tables
DROP TABLE Infraccion;
DROP TABLE TipoFalta;
DROP TABLE Licencia;
DROP TABLE Denominacion;
DROP TABLE DependientePuesto;
DROP TABLE EmpleoMercado;
DROP TABLE Cargo;
DROP TABLE Familiar;
DROP TABLE Persona;
DROP TABLE Almacenaje;
DROP TABLE Puesto;
DROP TABLE Almacen;
DROP TABLE Mercado;

-- Create tables
CREATE TABLE Mercado (
	nombre_mercado CHAR(30),
	direccion CHAR(60) NOT NULL,
	CONSTRAINT pk_mercado PRIMARY KEY (nombre_mercado)
);


CREATE TABLE Almacen (
	nombre_mercado CHAR(30),
	numero_local INTEGER,
	dimension REAL NOT NULL,
	frigorifico BOOLEAN NOT NULL,
	libre REAL NOT NULL,	
	FOREIGN KEY (nombre_mercado) REFERENCES Mercado
		ON DELETE CASCADE
		ON UPDATE NO ACTION,
	CONSTRAINT pk_almacen PRIMARY KEY (nombre_mercado,numero_local),
	CHECK (dimension > 0.0),
	CHECK (libre >= 0.0)
);


CREATE TABLE Puesto (
	nombre_mercado CHAR(30),
	numero_local INTEGER NOT NULL,
	dimension REAL NOT NULL,
	FOREIGN KEY (nombre_mercado) REFERENCES Mercado
		ON DELETE CASCADE
		ON UPDATE NO ACTION,
	CONSTRAINT pk_puesto PRIMARY KEY (nombre_mercado,numero_local),
	CHECK (dimension > 0.0)
);


CREATE TABLE Almacenaje (
	numero_almacen INTEGER,
	nombre_mercado CHAR(30),
	numero_puesto INTEGER,
	espacio_asignado REAL,
	FOREIGN KEY (nombre_mercado, numero_almacen) REFERENCES Almacen
		ON DELETE CASCADE
		ON UPDATE NO ACTION,
	FOREIGN KEY (nombre_mercado, numero_puesto) REFERENCES Puesto
		ON DELETE CASCADE
		ON UPDATE NO ACTION,
	CONSTRAINT pk_almacenaje PRIMARY KEY (nombre_mercado,numero_almacen,numero_puesto),
	CHECK (numero_puesto >= 1),
	CHECK (espacio_asignado >= 0.0)
);


CREATE TABLE Persona (
	dni CHAR(11),
	nombre CHAR(20) NOT NULL,
	apellido01 CHAR(20) NOT NULL,
	apellido02 CHAR(20),
	fecha_nac DATE NOT NULL,
	numero_ss CHAR(20) NOT NULL,
	UNIQUE (numero_ss),
	CONSTRAINT pk_persona PRIMARY KEY (dni),
	CHECK (fecha_nac < NOW())
);


CREATE TABLE Familiar (
	dni_familiar01 CHAR(11),
	dni_familiar02 CHAR(11),
	FOREIGN KEY (dni_familiar01) REFERENCES Persona
		ON DELETE CASCADE
		ON UPDATE NO ACTION,
	FOREIGN KEY (dni_familiar02) REFERENCES Persona
		ON DELETE CASCADE
		ON UPDATE NO ACTION,
	CONSTRAINT pk_familiar PRIMARY KEY (dni_familiar01,dni_familiar02)
);



CREATE TABLE Cargo (
	numero_cargo INTEGER,
	nombre_cargo CHAR(15) NOT NULL,
	CONSTRAINT pk_cargo PRIMARY KEY(numero_cargo),
	UNIQUE(nombre_cargo)
);


CREATE TABLE EmpleoMercado (
	dni CHAR(11),
	nombre_mercado CHAR(30),
	numero_cargo INTEGER,
	fecha_inicio DATE ,
	fecha_fin DATE,
	FOREIGN KEY (dni) REFERENCES Persona
		ON DELETE CASCADE
		ON UPDATE NO ACTION,
	FOREIGN KEY (nombre_mercado) REFERENCES Mercado
		ON DELETE CASCADE
		ON UPDATE NO ACTION,
	FOREIGN KEY (numero_cargo) REFERENCES Cargo
		ON DELETE CASCADE
		ON UPDATE NO ACTION,
	CONSTRAINT pk_empleo_mercado PRIMARY KEY (dni,nombre_mercado, fecha_inicio),
	CONSTRAINT fin_empleo CHECK(fecha_fin >= fecha_inicio),
	CONSTRAINT inicio_empleo CHECK(fecha_inicio <= NOW())	
);


CREATE TABLE DependientePuesto (
	dni CHAR(11),
	nombre_mercado CHAR(30),
	numero_local INTEGER,
	fecha_inicio DATE,
	fecha_fin	DATE,
	FOREIGN KEY (nombre_mercado,numero_local) REFERENCES Puesto
		ON DELETE CASCADE
		ON UPDATE NO ACTION,
	FOREIGN KEY (dni) REFERENCES Persona
		ON DELETE CASCADE
		ON UPDATE NO ACTION,
	CONSTRAINT pk_dependiente_puesto PRIMARY KEY (dni,nombre_mercado,numero_local,fecha_inicio),
	CONSTRAINT fin_dependiente CHECK(fecha_fin >= fecha_inicio),
	CONSTRAINT incio_dependiente CHECK(fecha_inicio <= NOW())
);


CREATE TABLE Denominacion(
	numero_denominacion INTEGER,
	nombre_denominacion CHAR(40) NOT NULL,
	CONSTRAINT pk_denominacion PRIMARY KEY (numero_denominacion),
	UNIQUE (nombre_denominacion)
);


CREATE TABLE Licencia (
	numero_licencia INTEGER,
	dni CHAR(11) NOT NULL,
	nombre_mercado CHAR(30) NOT NULL,
	numero_local INTEGER NOT NULL,
	numero_denominacion INTEGER NOT NULL,
	ultimo_pago_canon DATE,
	fecha_inicio DATE NOT NULL,
	fecha_fin DATE NOT NULL,
	deuda_agua REAL NOT NULL,
	deuda_gas REAL NOT NULL,
	deuda_luz REAL NOT NULL,
	deuda_camara REAL NOT NULL,
	deuda_residuos REAL NOT NULL,
	dias_cerrados INTEGER NOT NULL,
	obras_realizadas BOOLEAN,
	FOREIGN KEY (dni) REFERENCES Persona
		ON DELETE CASCADE
		ON UPDATE NO ACTION,
	FOREIGN KEY (nombre_mercado, numero_local) REFERENCES Puesto
		ON DELETE CASCADE
		ON UPDATE NO ACTION,
	FOREIGN KEY (numero_denominacion) REFERENCES Denominacion
		ON DELETE CASCADE
		ON UPDATE NO ACTION,
	CONSTRAINT pk_licencia PRIMARY KEY (numero_licencia),
	CONSTRAINT inicio_licencia CHECK (fecha_inicio <= NOW()),
	CONSTRAINT fin_licencia CHECK (fecha_fin > fecha_inicio),
	CHECK (ultimo_pago_canon <= NOW()),
	CHECK (deuda_agua >= 0),
	CHECK (deuda_gas >= 0),
	CHECK (deuda_luz >= 0),
	CHECK (deuda_camara >= 0),
	CHECK (deuda_residuos >= 0),
	CHECK (dias_cerrados >= 0)
	
);


CREATE TABLE TipoFalta (
	numero_falta INTEGER,
	nombre_falta CHAR(20) NOT NULL,
	CONSTRAINT pk_tipo_falta PRIMARY KEY (numero_falta),
	UNIQUE (nombre_falta)
);	


CREATE TABLE Infraccion (
	numero_licencia INTEGER,
	numero_infraccion INTEGER,
	numero_falta INTEGER NOT NULL,
	descripcion CHAR(100),
	fecha DATE NOT NULL,
	FOREIGN KEY (numero_licencia) REFERENCES Licencia
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	FOREIGN KEY (numero_falta) REFERENCES TipoFalta
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	CONSTRAINT pk_infraccion PRIMARY KEY (numero_infraccion),
	CONSTRAINT fecha CHECK (fecha <= NOW())
);


-- Enum Cargo
INSERT INTO Cargo(numero_cargo,nombre_cargo) VALUES (0,'Encargado');
INSERT INTO Cargo(numero_cargo,nombre_cargo) VALUES (1,'Veterinario');
INSERT INTO Cargo(numero_cargo,nombre_cargo) VALUES (2,'Auxiliar');


-- Enum TipoFalta
INSERT INTO TipoFalta(numero_falta, nombre_falta) VALUES (0,'Leve');
INSERT INTO TipoFalta(numero_falta, nombre_falta) VALUES (1,'Grave');
INSERT INTO TipoFalta(numero_falta, nombre_falta) VALUES (2,'Muy grave');

-- Enum Denominacion
INSERT INTO Denominacion(numero_denominacion, nombre_denominacion) VALUES (0,'Pescaderia');
INSERT INTO Denominacion(numero_denominacion, nombre_denominacion) VALUES (1, 'Carniceria');
INSERT INTO Denominacion(numero_denominacion, nombre_denominacion) VALUES (2, 'Frutas y verduras');
INSERT INTO Denominacion(numero_denominacion, nombre_denominacion) VALUES (3, 'Minorista Polivalente de Alimentacion');
INSERT INTO Denominacion(numero_denominacion, nombre_denominacion) VALUES (4, 'Panaderia');
INSERT INTO Denominacion(numero_denominacion, nombre_denominacion) VALUES (5, 'Bar');
INSERT INTO Denominacion(numero_denominacion, nombre_denominacion) VALUES (6,'Otro');
