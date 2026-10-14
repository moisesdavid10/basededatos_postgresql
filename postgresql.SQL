CREATE database "peloterosDB";


--Canchas de Deportes disponibles (Futbol, Voley)
CREATE TABLE deporte (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    CONSTRAINT PK_deporte PRIMARY KEY(id)
);


-- Roles globales (CLIENTE, PROPIETARIO, ADMIN)
CREATE TABLE rol (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    CONSTRAINT PK_rol PRIMARY KEY(id)
);


-- Cargos locales (PROPIETARIO, ADMINISTRADOR, CAJERO)
CREATE TABLE cargo (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    CONSTRAINT PK_cargo PRIMARY KEY(id)
);

-- Personas registradas en la app
CREATE TABLE usuario (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    telefono VARCHAR(50) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
	modified_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT PK_usuario PRIMARY KEY(id)
);



-- Conecta al usuario con sus roles globales 
CREATE TABLE usuario_rol (
    usuario_id BIGINT NOT NULL,
    rol_id BIGINT NOT NULL,
    CONSTRAINT PK_usuario_rol PRIMARY KEY (usuario_id, rol_id),
    CONSTRAINT FK_usuariorol_usuario FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
    CONSTRAINT FK_usuariorol_rol FOREIGN KEY (rol_id) REFERENCES rol(id) ON DELETE CASCADE
);



-- Complejo deportivo
CREATE TABLE complejo_deportivo(
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    nombre VARCHAR(100) NOT NULL,
	direccion VARCHAR(255) NOT NULL,
	telefono VARCHAR(50),
	latitud NUMERIC(10,8),
	longitud NUMERIC(11,8),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
  	modified_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT PK_complejo_deportivo PRIMARY KEY(id)
);


-- Conecta al usuario con un complejo específico y define su cargo
CREATE TABLE complejo_usuario (
    id BIGINT GENERATED ALWAYS AS IDENTITY,
    usuario_id BIGINT NOT NULL,
    complejo_id BIGINT NOT NULL,
	cargo_id BIGINT NOT NULL,
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT PK_complejo_usuario PRIMARY KEY(id),
    CONSTRAINT FK_complejousuario_usuario FOREIGN KEY(usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
    CONSTRAINT FK_complejousuario_complejo FOREIGN KEY(complejo_id) REFERENCES complejo_deportivo(id) ON DELETE CASCADE,
    CONSTRAINT FK_complejousuario_cargo FOREIGN KEY(cargo_id) REFERENCES cargo(id),
    CONSTRAINT UQ_usuario_complejo UNIQUE(usuario_id, complejo_id)
);


-- Cancha sintetica que pertenece a un complejo deportivo
CREATE TABLE cancha_sintetica(
	id BIGINT GENERATED ALWAYS AS IDENTITY,
	nombre VARCHAR(100) NOT NULL,
	deporte_id BIGINT NOT NULL,
	capacidad INT NOT NULL,
	precio_hora NUMERIC(10,2) NOT NULL CHECK(precio_hora >=0),
	disponible BOOLEAN DEFAULT TRUE NOT NULL,
	complejo_id BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT PK_cancha_sintetica PRIMARY KEY(id),
    CONSTRAINT FK_cancha_deporte FOREIGN KEY(deporte_id) REFERENCES deporte(id),
    CONSTRAINT FK_cancha_complejo FOREIGN KEY(complejo_id) REFERENCES complejo_deportivo(id) ON DELETE CASCADE
);

-- Enum de estados finitos de reserva
CREATE TYPE estado_reserva_enum AS ENUM ('PENDIENTE_PAGO', 'CONFIRMADA', 'CANCELADA');

-- reservas turno de las canchas sinteticas
CREATE TABLE reserva_turno(
	id BIGINT GENERATED ALWAYS AS IDENTITY,
	cancha_id BIGINT NOT NULL,
	usuario_id BIGINT NOT NULL,
	fecha DATE NOT NULL,
	hora_inicio TIME NOT NULL,
	hora_fin TIME NOT NULL,
	precio_total NUMERIC(10,2) NOT NULL CHECK(precio_total >=0),
	estado estado_reserva_enum NOT NULL DEFAULT ('PENDIENTE_PAGO'),
	created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
	modified_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT PK_reserva_turno PRIMARY KEY(id),
	CONSTRAINT fk_reserva_cancha FOREIGN KEY (cancha_id) REFERENCES cancha_sintetica (id) ON DELETE CASCADE,
	CONSTRAINT fk_reserva_usuario FOREIGN KEY (usuario_id) REFERENCES usuario (id) ON DELETE CASCADE,
	CONSTRAINT chk_horario_valido CHECK (hora_fin > hora_inicio)
);


-- Índice clave para optimizar las búsquedas 
CREATE INDEX idx_cancha_complejo_id ON cancha_sintetica(complejo_id);
CREATE INDEX idx_cancha_deporte_id ON cancha_sintetica(deporte_id);
CREATE INDEX idx_usuariorol_usuario ON usuario_rol(usuario_id);
CREATE INDEX idx_complejousuario_usuario ON complejo_usuario(usuario_id);
CREATE INDEX idx_complejousuario_complejo ON complejo_usuario(complejo_id);
CREATE INDEX idx_reserva_cancha_fecha ON reserva_turno (cancha_id, fecha);



INSERT INTO deporte (nombre) VALUES ('Futbol'), ('Voley');
INSERT INTO rol (nombre) VALUES ('CLIENTE'), ('PROPIETARIO'), ('ADMIN');
INSERT INTO cargo (nombre) VALUES ('PROPIETARIO'), ('ADMINISTRADOR'), ('CAJERO');



INSERT INTO usuario (email, password, nombres, apellidos, telefono) 
VALUES 	('admin@peloteros.com', 'admin123', 'Super', 'Administrador', '999999999'),
		('luis@gmail.com', 'admin123', 'Luis', 'Zeballos', '147258369');


INSERT INTO usuario_rol (usuario_id, rol_id) 
VALUES (
    (SELECT id FROM usuario WHERE email = 'admin@peloteros.com'), 
    (SELECT id FROM rol WHERE nombre = 'ADMIN')
);


INSERT INTO usuario_rol (usuario_id, rol_id) 
VALUES (
    (SELECT id FROM usuario WHERE email = 'luis@gmail.com'), 
    (SELECT id FROM rol WHERE nombre = 'CLIENTE')
);



INSERT INTO complejo_deportivo (nombre, direccion, telefono) VALUES ('Real Club de Lima', 'Calle Los Castaños 505, San Isidro 15076', '+012070760');
INSERT INTO complejo_deportivo (nombre, direccion, telefono) VALUES ('DeporPlaza Campo de Marte', 'Jr. Nazca s/n Jesús Maria', '+01452565');
INSERT INTO complejo_deportivo (nombre, direccion, telefono) VALUES ('Sport Point', 'Av. El polo 925 Santiago Surco', '+014785963');

INSERT INTO cancha_sintetica (nombre, deporte_id, capacidad, precio_hora, complejo_id) 
VALUES ('Cancha #1', 1, 10, 55.00, 1), ('Cancha #2', 1, 10, 65.00, 1), ('Cancha #3', 2, 12, 35.00, 1);
