DROP DATABASE IF EXISTS FCT_DB;
CREATE DATABASE FCT_DB;
USE FCT_DB;

CREATE TABLE Usuarios (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    rol ENUM('Administrador', 'Profesor', 'Sala_de_Profesores') NOT NULL,
    nombre VARCHAR(20) NOT NULL,
    apellido1 VARCHAR(20),
	apellido2 VARCHAR(20),
    telefono VARCHAR(15),
    fecha_incorporacion DATE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL
);

CREATE TABLE Guardias (
    id_guardia INT PRIMARY KEY AUTO_INCREMENT,
    id_profesor_asignado INT,
    id_profesor_ausente INT,
    estado ENUM('Sin Asignar', 'Asignada', 'Finalizada') DEFAULT 'Sin Asignar' NOT NULL, 
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NOT NULL,
    tarea TEXT,
    tipo_guardia ENUM('patio', 'clase'),
    CONSTRAINT FK_profesor_asginado_guardia FOREIGN KEY (id_profesor_asignado) REFERENCES Usuarios(id_usuario),
    CONSTRAINT FK_profesor_ausente_guardia FOREIGN KEY (id_profesor_ausente) REFERENCES Usuarios(id_usuario)
);

CREATE TABLE Ausencias (
    id_ausencia INT PRIMARY KEY AUTO_INCREMENT,
    id_profesor_asignado INT NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NOT NULL,
    comentario TEXT,
    motivo TEXT,
    CONSTRAINT FK_profesor_ausente_ausencia FOREIGN KEY (id_profesor_asignado) REFERENCES Usuarios(id_usuario)
);


CREATE TABLE Clases (
    cod_aula VARCHAR(50) PRIMARY KEY,
    grupo VARCHAR(50),
    id_profesor INT NOT NULL,
    CONSTRAINT FK_profesor_clase FOREIGN KEY (id_profesor) REFERENCES Usuarios(id_usuario)
);

-- Insert for Administrador role 
-- PASSWORD: "admin" -> "$2a$10$m6q6OhzLwDfUKsJEeTZTf.SBXxdrm29a.bdRCzaFZq2sgWiVDMeVa"
INSERT INTO Usuarios(rol, nombre, apellido1, apellido2, telefono, fecha_incorporacion, email, password_hash) 
VALUES ('Administrador', 'Carlos', 'Pérez', 'García', '123456789', '2025-03-15', 'carlos.perez@fct.com', 'your_calculated_hash_here');

-- Insert for Profesor role 
-- PASSWORD: "profe" -> "$2a$10$PrXCvmgEtGxuLqdG09Pn7uPV4WTe1rpQAJdNA62blEvMZCJTXN/oG"
INSERT INTO Usuarios(rol, nombre, apellido1, apellido2, telefono, fecha_incorporacion, email, password_hash) 
VALUES ('Profesor', 'Ana', 'Martínez', 'Lopez', '987654321', '2025-03-15', 'ana.martinez@fct.com', 'your_calculated_hash_here');

-- Insert for Sala_de_Profesores role
-- PASSWORD: "sala" -> "$2a$10$v99Ahj873gkncXJBcLnmRepfd5IrJ3DGMucJa3zJw642NV19OGHGi"
INSERT INTO Usuarios(rol, nombre, apellido1, apellido2, telefono, fecha_incorporacion, email, password_hash) 
VALUES ('Sala_de_Profesores', 'Luis', 'González', 'Sánchez', '112233445', '2025-03-15', 'luis.gonzalez@fct.com', 'your_calculated_hash_here');

select * from usuarios;