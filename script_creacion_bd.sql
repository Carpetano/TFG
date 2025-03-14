-- Almacena la información de los usuarios del sistema para la gestión del login y sus credenciales
CREATE TABLE Usuarios (  
    id_usuario      INT AUTO_INCREMENT PRIMARY KEY,   					-- Identificador único de cada usuario
    email           VARCHAR(255) UNIQUE NOT NULL,      					-- Email único que se utiliza para el login del usuario
    password_hash   VARCHAR(255) NOT NULL,             					-- Hash Contraseña del usuario 
    estado          ENUM('activo', 'inactivo', 'bloqueado') DEFAULT 'activo',  		-- Estado del usuario: activo, inactivo o bloqueado
    creado_en       TIMESTAMP DEFAULT CURRENT_TIMESTAMP					-- Fecha y hora de creación de la cuenta
);


-- Almacena la información de todos los docentes (administradores, profesores y sala de profesores)
CREATE TABLE Docentes (  
    id_docente          INT AUTO_INCREMENT PRIMARY KEY,  				-- Identificador único de cada docente
    id_usuario          INT UNIQUE NOT NULL,  						-- Relación con la tabla Usuarios (para obtener datos de login)
    nombre              VARCHAR(255) NOT NULL,  					-- Nombre del docente
    telefono            VARCHAR(20) NULL,  						-- Número de teléfono (opcional)
    fecha_incorporacion DATE NULL,  							-- Fecha en la que el docente se incorporó (opcional)
    rol                 ENUM('admin', 'profesor', 'sala_profesores') NOT NULL,  	-- Rol del usuario en el sistema

    -- Relación con la tabla Usuarios. Si el usuario es eliminado, se elimina el docente relacionado.
    CONSTRAINT fk_docente_usuario FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE  
);


-- Almacena las guardias generadas cuando un profesor está ausente
CREATE TABLE Guardias (
    id_guardia           INT AUTO_INCREMENT PRIMARY KEY,  				-- Identificador único de la guardia
    id_profesor_asignado INT NULL,                        				-- Relación con el profesor que asume la guardia (puede ser NULL si no está asignada)
    id_profesor_ausente  INT NOT NULL,                    				-- Relación con el profesor cuya ausencia genera la guardia
    estado               ENUM('pendiente_asignar', 'asignada', 'cancelada') NOT NULL,  	-- Estado de la guardia: si está asignada, pendiente o cancelada
    fecha_inicio         DATETIME NOT NULL,               				-- Fecha y hora de inicio de la guardia
    fecha_fin            DATETIME NOT NULL,               				-- Fecha y hora de fin de la guardia
    tarea                TEXT NULL,                       				-- (Opcional) Tarea que el profesor ausente asigna a sus alumnos durante la guardia

    -- Relación con el profesor asignado a la guardia, si el profesor es eliminado, la guardia queda sin asignar (SET NULL)
    CONSTRAINT fk_guardias_profesor_asignado FOREIGN KEY (id_profesor_asignado) REFERENCES Usuarios(id_usuario) ON DELETE SET NULL,

    -- Relación con el profesor ausente, si el profesor es eliminado, se elimina la guardia asociada
    CONSTRAINT fk_guardias_profesor_ausente FOREIGN KEY (id_profesor_ausente) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE
);


-- Almacena las ausencias de los docentes para poder gestionar la cobertura de las guardias
CREATE TABLE Ausencias (
    id_ausencia         INT AUTO_INCREMENT PRIMARY KEY,  				-- Identificador único de la ausencia
    id_usuario          INT NOT NULL,                    				-- Relación con el profesor que registra la ausencia
    fecha_inicio        DATETIME NOT NULL,               				-- Fecha y hora de inicio de la ausencia
    fecha_fin           DATETIME NOT NULL,               				-- Fecha y hora de fin de la ausencia
    motivo              TEXT NULL,                       				-- (Opcional) Motivo de la ausencia (puede estar vacío)

    -- Relación con la tabla Usuarios. Si el usuario es eliminado, se elimina la ausencia registrada
    CONSTRAINT fk_ausencias_usuario FOREIGN KEY (id_usuario) REFERENCES Usuarios(id_usuario) ON DELETE CASCADE
);




