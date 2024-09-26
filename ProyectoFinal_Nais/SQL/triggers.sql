
CREATE OR REPLACE FUNCTION verifica_num_pisos()
RETURNS trigger AS $$
DECLARE
	tupla RECORD;
BEGIN
IF tg_op = 'INSERT' THEN
	IF (SELECT COUNT(*) FROM piso WHERE new.id_edificio = id_edificio ) >= 10 THEN
		RAISE EXCEPTION 'Numero de pisos excedidos.'
		USING HINT = 'No pueden existir mas de 10 pisos en un edificio.';
	END IF;
	tupla := new;
ELSEIF tg_op = 'UPDATE' THEN
	IF (old.id_edificio != new.edificio) AND 
		((SELECT COUNT(*) FROM piso WHERE old.id_edificio = id_edificio ) <= 8 OR
		(SELECT COUNT(*) FROM piso WHERE new.id_edificio = id_edificio ) >= 10) THEN
		RAISE EXCEPTION 'El numero de pisos de un edificio debe ser 8-10.'
		USING HINT = 'Verifica el numero de pisos en cada edificio.';
	END IF;
	tupla := new;
ELSEIF tg_op = 'DELETE' THEN
	IF (SELECT COUNT(*) FROM piso WHERE new.id_edificio = id_edificio ) <= 8 THEN
		RAISE EXCEPTION 'Numero de pisos insuficientes.'
		USING HINT = 'No pueden existir menos de 8 pisos en un edificio.';
	END IF;
	tupla := old;
END IF;
RETURN tupla;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER num_pisos
BEFORE INSERT OR UPDATE OR DELETE
ON piso
FOR EACH ROW
EXECUTE PROCEDURE verifica_num_pisos();

CREATE OR REPLACE FUNCTION verifica_num_salas()
RETURNS trigger AS $$
DECLARE 
num_salas_entrenamiento INTEGER;
num_salas_operaciones INTEGER;
tupla RECORD;
BEGIN
IF tg_op = 'INSERT' OR tg_op = 'UPDATE' THEN
	SELECT COUNT(*) INTO num_salas_entrenamiento FROM Sala_Entrenamiento 
	 WHERE new.Id_Edificio = Id_Edificio AND new.Id_Piso = Id_Piso;
	SELECT COUNT(*) INTO num_salas_operaciones FROM Sala_Operaciones 
	 WHERE new.Id_Edificio = Id_Edificio AND new.Id_Piso = Id_Piso;
	IF (num_salas_entrenamiento + num_salas_operaciones) >= 8 THEN
		RAISE EXCEPTION 'Numero de salas en el piso % excedidas.', new.Id_Piso
		USING HINT = 'No pueden existir mas de 8 salas en un piso.';
	END IF;
	tupla := new;
END IF;
RETURN tupla;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER num_salas_e
BEFORE INSERT OR UPDATE
ON Sala_Entrenamiento
FOR EACH ROW
EXECUTE PROCEDURE verifica_num_salas();

CREATE OR REPLACE TRIGGER num_salas_o
BEFORE INSERT OR UPDATE
ON Sala_Operaciones
FOR EACH ROW
EXECUTE PROCEDURE verifica_num_salas();

CREATE OR REPLACE FUNCTION verifica_num_pisos_de_operacion()
RETURNS trigger AS $$
DECLARE
	tupla RECORD;
BEGIN
IF tg_op = 'INSERT' OR tg_op = 'UPDATE' THEN
	IF (SELECT COUNT(*) FROM Sala_Operaciones WHERE new.Id_Edificio = Id_Edificio AND new.Id_Piso = Id_Piso) >= 4 THEN
		RAISE EXCEPTION 'Numero de salas de operacion en el piso % excedidos.', new.Id_Piso
		USING HINT = 'Solo pueden existir 4 salas de operacion en un piso.';
	ELSEIF (SELECT COUNT(*) FROM Sala_Operaciones WHERE new.Id_Edificio = Id_Edificio 
			GROUP BY Id_Piso HAVING COUNT(Id_Sala_Operaciones) > 0) >= 4 THEN
		RAISE EXCEPTION 'Numero de pisos de operaciones en el edificio % excedidos.', Id_Edificio
		USING HINT = 'No pueden existir mas de 4 pisos de operaciones en un edificio.';
	END IF;
	tupla:= new;
END IF;
IF tg_op = 'UPDATE' OR tg_op = 'DELETE' THEN
	IF (SELECT COUNT(*) FROM Sala_Operaciones WHERE old.Id_Edificio = Id_Edificio AND old.Id_Piso = Id_Piso) <= 4 THEN
		RAISE EXCEPTION 'Numero de salas de operacion en el piso % insuficientes.', new.Id_Piso
		USING HINT = 'Deben existir 4 salas de operacion en un piso de operaciones.';
	END IF;
	IF tg_op = 'UPDATE' THEN
		tupla := new;
	ELSE 
		tupla := old;
	END IF;
END IF;
RETURN tupla;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER num_pisos_de_operacion
BEFORE INSERT OR UPDATE OR DELETE
ON Sala_Operaciones
FOR EACH ROW
EXECUTE PROCEDURE verifica_num_pisos_de_operacion();

CREATE OR REPLACE FUNCTION verifica_aditamentos_entrenamiento()
RETURNS trigger AS $$
DECLARE 
	tupla RECORD;
BEGIN
IF tg_op = 'INSERT' OR tg_op = 'UPDATE' THEN
	IF new.Id_Estacion IS NOT NULL THEN
			IF new.Nombre = 'Mouse' OR new.Nombre = 'Teclado' OR new.Nombre = 'Headset' THEN
				IF EXISTS (SELECT FROM Aditamento_Entrenamiento WHERE new.Id_Estacion = Id_Estacion AND new.Nombre = Nombre) THEN
					RAISE EXCEPTION 'La estacion % ya esta equipada con un %.', new.Id_Estacion, new.Nombre
					USING HINT = 'Una estacion solo puede estar equipada con un Mouse, un Teclado y un Headset.';
				END IF;
			ELSE 
				RAISE EXCEPTION 'La solo puede estar equipada con un Mouse, un Teclado y un Headset'
				USING HINT = 'Verifica que el aditamento sea un Mouse, un Teclado o un Headset.';
			END IF;
	END IF;
	tupla := new;
END IF;
RETURN tupla;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER aditamentos_entrenamiento
BEFORE INSERT OR UPDATE
ON Aditamento_Entrenamiento
FOR EACH ROW
EXECUTE PROCEDURE verifica_aditamentos_entrenamiento();

CREATE OR REPLACE FUNCTION verifica_aditamentos_operaciones()
RETURNS trigger AS $$
DECLARE 
	tupla RECORD;
BEGIN
IF tg_op = 'INSERT' OR tg_op = 'UPDATE' THEN
	IF new.Id_Estacion IS NOT NULL THEN
			IF new.Nombre = 'Mouse' OR new.Nombre = 'Teclado' OR new.Nombre = 'Headset' THEN
				IF EXISTS (SELECT FROM Aditamento_Operaciones WHERE new.Id_Estacion = Id_Estacion AND new.Nombre = Nombre) THEN
					RAISE EXCEPTION 'La estacion % ya esta equipada con un %.', new.Id_Estacion, new.Nombre
					USING HINT = 'Una estacion solo puede estar equipada con un Mouse, un Teclado y un Headset.';
				END IF;
			ELSE 
				RAISE EXCEPTION 'La solo puede estar equipada con un Mouse, un Teclado y un Headset'
				USING HINT = 'Verifica que el aditamento sea un Mouse, un Teclado o un Headset.';
			END IF;
	END IF;
	tupla := new;
END IF;
RETURN tupla;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER aditamentos_operaciones
BEFORE INSERT OR UPDATE
ON Aditamento_Operaciones
FOR EACH ROW
EXECUTE PROCEDURE verifica_aditamentos_operaciones();

CREATE OR REPLACE FUNCTION verifica_id_aditamento_entrenamiento()
RETURNS trigger AS $$
DECLARE 
	tupla RECORD;
BEGIN
IF tg_op = 'INSERT' OR tg_op = 'UPDATE' THEN
	IF EXISTS (SELECT FROM Aditamento_Operaciones WHERE new.Id_Aditamento = Id_Aditamento) THEN
		RAISE EXCEPTION 'Ya existe un aditamento con id % en la tabla Aditamento_Operaciones.', new.Id_Aditamento
		USING HINT = 'El identificador de los aditamentos tiene que ser unico en ambas tablas de aditamentos.';
	END IF;
	tupla := new;
END IF;
RETURN tupla;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER id_aditamento_entrenamiento
BEFORE INSERT OR UPDATE
ON Aditamento_Entrenamiento
FOR EACH ROW
EXECUTE PROCEDURE verifica_id_aditamento_entrenamiento();

CREATE OR REPLACE FUNCTION verifica_id_aditamento_operaciones()
RETURNS trigger AS $$
DECLARE 
	tupla RECORD;
BEGIN
IF tg_op = 'INSERT' OR tg_op = 'UPDATE' THEN
	IF EXISTS (SELECT FROM Aditamento_Entrenamiento WHERE new.Id_Aditamento = Id_Aditamento) THEN
		RAISE EXCEPTION 'Ya existe un aditamento con id % en la tabla Aditamento_Entrenamiento', new.Id_Aditamento
		USING HINT = 'El identificador de los aditamentos tiene que ser unico en ambas tablas de aditamentos.';
	END IF;
	tupla:= new;
END IF;
RETURN tupla;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER id_aditamento_operaciones
BEFORE INSERT OR UPDATE
ON Aditamento_Operaciones
FOR EACH ROW
EXECUTE PROCEDURE verifica_id_aditamento_operaciones();

CREATE OR REPLACE FUNCTION verifica_id_estacion_entrenamiento()
RETURNS trigger AS $$
DECLARE 
	tupla RECORD;
BEGIN
IF tg_op = 'INSERT' OR tg_op = 'UPDATE' THEN
	IF EXISTS (SELECT FROM Estacion_Operaciones WHERE new.Id_Estacion = Id_Estacion) THEN
		RAISE EXCEPTION 'Ya existe una estacion con id % en la tabla Estacion_Operaciones.', new.Id_Estacion
		USING HINT = 'El identificador de las estaciones tiene que ser unico en ambas tablas de estaciones.';
	END IF;
	tupla := new;
END IF;
RETURN tupla;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER id_estacion_entrenamiento
BEFORE INSERT OR UPDATE
ON Estacion_Entrenamiento
FOR EACH ROW
EXECUTE PROCEDURE verifica_id_estacion_entrenamiento();

CREATE OR REPLACE FUNCTION verifica_id_estacion_operaciones()
RETURNS trigger AS $$
DECLARE 
	tupla RECORD;
BEGIN
IF tg_op = 'INSERT' OR tg_op = 'UPDATE' THEN
	IF EXISTS (SELECT FROM Estacion_Entrenamiento WHERE new.Id_Estacion = Id_Estacion) THEN
		RAISE EXCEPTION 'Ya existe una estacion con id % en la tabla Estacion_Entrenamiento', new.Id_Estacion
		USING HINT = 'El identificador de las estaciones tiene que ser unico en ambas tablas de estaciones.';
	END IF;
	tupla := new;
END IF;
RETURN tupla;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER id_estacion_operaciones
BEFORE INSERT OR UPDATE
ON Estacion_Operaciones
FOR EACH ROW
EXECUTE PROCEDURE verifica_id_estacion_operaciones();

CREATE OR REPLACE FUNCTION modifica_SO_estacion()
RETURNS trigger AS $$
DECLARE 
	tupla RECORD;
DECLARE 
SO_Cliente VARCHAR(10);
BEGIN
IF tg_op = 'UPDATE' THEN
	IF new.Estado = 1 THEN
		SELECT SO INTO SO_Cliente FROM Cliente WHERE Id_Cliente = new.Id_Cliente;
		UPDATE Estacion_Operaciones SET SO = SO_Cliente WHERE Id_Sala_Operaciones = new.Id_Sala_Operaciones;
	END IF;
	tupla := new;
END IF;
RETURN tupla;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER modifica_SO
AFTER UPDATE
ON Sala_Operaciones
FOR EACH ROW
EXECUTE PROCEDURE modifica_SO_Estacion();


CREATE OR REPLACE FUNCTION verifica_sala_disponible()
RETURNS trigger AS $$
DECLARE 
	tupla RECORD;
DECLARE
fecha DATE := current_date;
BEGIN
IF tg_op = 'UPDATE' THEN
	IF new.Estado = 1 AND fecha <> new.Fecha_Inicio THEN 
		RAISE EXCEPTION 'La fecha de inicio no concuerda con la fecha actual.'
		USING HINT = 'Una reservacion tiene que inciar en el dia en que se registra.';
	END IF;
	IF old.Estado = 1 THEN
		IF new.Estado = 0 AND old.Fecha_Fin > fecha THEN 
			RAISE EXCEPTION 'La reservacion anterior aun no termina, no se puede cambiar el estado.'
			USING HINT = 'Una reservacion concluye cuando haya pasado la fecha de fin.';
		ELSEIF new.Estado = 1 AND old.Fecha_Fin > fecha AND 
		(old.Id_Cliente <> new.Id_Cliente OR old.Fecha_Incio <> new.Fecha_Inicio OR old.Fecha_Fin <> new.Fecha_Fin) THEN
			RAISE EXCEPTION 'La reservacion anterior aun no termina, no se pueden modificar sus datos.'
			USING HINT = 'Una reservacion concluye cuando haya pasado la fecha de fin.';
		END IF;
	END IF;
	tupla := new;
END IF;
RETURN tupla;
END;
$$ LANGUAGE 'plpgsql';


CREATE OR REPLACE TRIGGER sala_disponible
AFTER INSERT OR UPDATE
ON Sala_Operaciones
FOR EACH ROW
EXECUTE PROCEDURE verifica_sala_disponible();

CREATE OR REPLACE FUNCTION verifica_evaluacion()
RETURNS trigger AS $$
DECLARE 
	tupla RECORD;
BEGIN
IF tg_op = 'UPDATE' THEN
	IF new.Evaluacion IS NOT NULL AND new.Evaluacion < 8 THEN
		DELETE FROM Agente_Telefonico WHERE CURP = new.CURP CASCADE;
	END IF;
	tupla := new;
END IF;
RETURN tupla;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER evaluacion
AFTER UPDATE
ON Agente_Telefonico
FOR EACH ROW
EXECUTE PROCEDURE verifica_evaluacion();

CREATE OR REPLACE FUNCTION verifica_cursos_en_misma_sala_con_distintos_horarios()
RETURNS trigger AS $$
DECLARE 
	t RECORD;
BEGIN
	IF tg_op= 'INSERT' OR tg_op= 'UPDATE' THEN
		IF( (SELECT modalidad FROM curso WHERE id_curso=new.id_curso)='Presencial' AND EXISTS (SELECT * 
					FROM (curso NATURAL JOIN horario) 
					WHERE id_sala_entrenamiento=(SELECT id_sala_entrenamiento FROM curso WHERE id_curso=new.id_curso)  AND 
						  hora_Inicio <= new.hora_Fin OR hora_Fin <= new.hora_Inicio 
				   ) 
		  )THEN 
				RAISE EXCEPTION 'No se puede asignar el horario al curso'
				USING HINT = 'Se empalma el horario con otro curso en la misma sala';						
		END IF;
		t := new;
	END IF;
	RETURN t;
	END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER horarios_no_empalmados 
BEFORE INSERT OR UPDATE 
ON horario 
FOR EACH ROW
EXECUTE PROCEDURE verifica_cursos_en_misma_sala_con_distintos_horarios();

CREATE OR REPLACE FUNCTION reestrige_valores_de_horario()
RETURNS trigger AS $$
DECLARE 
	t RECORD;
BEGIN

	IF tg_op= 'INSERT' THEN
		IF( (SELECT SUM( (hora_fin - hora_inicio)::interval )
			 FROM horario 
			 WHERE  id_curso = new.id_curso) + (new.hora_fin - new.hora_inicio)::interval  > INTERVAL'42 hours' ) THEN
			 
			RAISE EXCEPTION 'No se puede insertar el horario al curso'
			USING HINT = 'Solo se pueden tener un máximo de 42 horas en el curso';	
		END IF;
		t := new;
	ELSEIF tg_op= 'UPDATE' THEN
		IF( (SELECT SUM( (hora_fin- hora_inicio)::interval )
			 FROM horario 
			 WHERE  id_curso = new.id_curso)- (old.hora_fin-old.hora_inicio)::interval + (new.hora_fin - new.hora_inicio)
		  >= INTERVAL'42 hours' ) THEN
			 
			RAISE EXCEPTION 'No se puede modificar el horario al curso'
			USING HINT = 'Solo se pueden tener un máximo de 42 horas en el curso';	
		END IF;
		t:= new;
	ELSEIF tg_op= 'DELETE' THEN
		IF(EXISTS (SELECT * 
				   FROM (horario NATURAL JOIN curso) 
				   WHERE id_curso=old.id_curso AND (fecha_fin < (SELECT current_date)) 
				  )
		  )THEN
		  	RAISE EXCEPTION 'No se puede eliminar el horario del curso'
			USING HINT = 'El curso sigue vigente, solo se puede eliminar si este ha acabado';	
		END IF;
		t:= old;
	END IF;
	RETURN t;
	END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER manipulacion_horario
BEFORE INSERT OR UPDATE OR DELETE
ON horario 
FOR EACH ROW
EXECUTE PROCEDURE reestrige_valores_de_horario();

CREATE OR REPLACE FUNCTION verifica_mismo_piso_agente()
RETURNS trigger AS $$
DECLARE 
	r RECORD;
	t RECORD;
BEGIN
	IF tg_op= 'INSERT' OR tg_op='UPDATE' THEN
		IF (new.id_curso IS NOT NULL) AND ((SELECT id_Piso FROM curso WHERE id_curso=new.id_curso) IS NOT NULL) THEN
			IF((SELECT id_piso FROM curso where id_curso=new.id_curso) <> new.id_piso ) THEN
				RAISE EXCEPTION 'El agente no puede estar en ese curso'
				USING HINT = 'Un agente solo puede de estar en un curso del mismo piso al que está asignado';	
			END IF;
		END IF;
		t:=new;
	END IF;
	RETURN t;
	END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER curso_y_agente_en_mismo_piso
BEFORE INSERT OR UPDATE
ON agente_telefonico 
FOR EACH ROW
EXECUTE PROCEDURE verifica_mismo_piso_agente();

CREATE OR REPLACE FUNCTION verifica_mismo_piso_entrenador()
RETURNS trigger AS $$
DECLARE 
	t RECORD;
BEGIN
	IF tg_op= 'INSERT' OR tg_op='UPDATE' THEN
		IF( new.id_piso IS NOT NULL )THEN
			IF((SELECT id_piso FROM entrenador where curp=new.id_entrenador) <> new.id_piso ) THEN
				RAISE EXCEPTION 'El agente no puede estar en este curso'
				USING HINT = 'Un agente solo puede estar en un curso del mismo piso al que está asignado';	
			END IF;
		END IF;
		t:=new;
	END IF;
	RETURN t;
	END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER curso_y_entrenador_en_mismo_piso
BEFORE INSERT OR UPDATE
ON curso 
FOR EACH ROW
EXECUTE PROCEDURE verifica_mismo_piso_entrenador();

CREATE OR REPLACE FUNCTION verifica_mismo_curso_asistencia_agente()
RETURNS trigger AS $$
DECLARE 
	t RECORD;
BEGIN
	IF tg_op= 'INSERT' OR tg_op='UPDATE' THEN
		IF(new.id_curso <> 
		   (SELECT id_curso FROM agente_telefonico WHERE id_curso=new.id_curso ) )THEN
			RAISE EXCEPTION 'El agente no puede asistir al curso %', new.id_curso
			USING HINT = 'Un agente solo puede asistir al curso al que está asignado';	
		END IF;
		t:= new;
	END IF;
	RETURN t;
	END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER agente_asiste_a_su_curso
BEFORE INSERT OR UPDATE
ON asistir_agente 
FOR EACH ROW
EXECUTE PROCEDURE verifica_mismo_curso_asistencia_agente();

CREATE OR REPLACE FUNCTION verifica_inasistencias()
RETURNS trigger AS $$
DECLARE 
	t RECORD;
BEGIN
	IF tg_op= 'INSERT' OR tg_op='UPDATE' THEN
		IF (SELECT COUNT(*) FROM (Asistir_entrenador ae LEFT JOIN 
								  (SELECT * FROM Asistir_agente where id_agente = new.id_agente) ag
								   ON ae.id_curso = ag.id_curso AND ae.id_horario = ag.id_horario AND ae.fecha = ag.fecha) 
			WHERE id_agente IS NULL) >= 3 THEN
			RAISE NOTICE 'El agente % ha superado el numero de inasistencias permitido, sera dado de baja.', new.id_agente;
			DELETE FROM agente_telefonico WHERE curp = new.id_agente CASCADE;
		END IF;
		t:=new;
	END IF;
	RETURN t;
	END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER inasistencias
AFTER INSERT OR UPDATE
ON asistir_agente 
FOR EACH ROW
EXECUTE PROCEDURE verifica_inasistencias();

CREATE OR REPLACE FUNCTION verifica_mismo_curso_asistencia_entrenador()
RETURNS trigger AS $$
DECLARE 
	t RECORD;
BEGIN
	IF tg_op= 'INSERT' OR tg_op='UPDATE' THEN
		IF(new.id_entrenador <> 
		   (SELECT id_entrenador FROM curso WHERE id_curso=new.id_curso ) )THEN
			RAISE EXCEPTION 'El entrenador no puede asistir al curso'
			USING HINT = 'Un entrenador solo puede impartir en el curso al que está asignado';	
		END IF;
		t:=new;
	END IF;
	RETURN t;
	END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER entrenador_asiste_a_su_curso
BEFORE INSERT OR UPDATE
ON asistir_entrenador 
FOR EACH ROW
EXECUTE PROCEDURE verifica_mismo_curso_asistencia_entrenador();

CREATE OR REPLACE FUNCTION actualiza_historial_cursos()
RETURNS trigger AS $$
DECLARE 
	t RECORD;
	fechaInicioA date;
	fechaFinA date;
	fechaInicioB date;
	fechaFinB date;
	fila curso%rowtype;
BEGIN
	IF EXISTS(SELECT FROM PG_CATALOG.PG_TABLES
			  WHERE SCHEMANAME='public' AND
			  TABLENAME='historial_cursos') THEN
		RAISE NOTICE 'El historial ya existe';
	ELSE
		CREATE TABLE historial_cursos(
			id_curso int,
			id_cliente varchar(13),
			nombre_curso text,
			turno varchar(10),
			fecha_inicio date,
			fecha_fin date
		);
	END IF;
	IF tg_op= 'DELETE' THEN
		IF NOT EXISTS (SELECT * FROM curso WHERE id_curso=old.id_curso) THEN
			RAISE EXCEPTION 'No existe tal curso'; 
		ELSEIF (old.fecha_fin < (SELECT NOW())) THEN
			INSERT INTO historial_cursos
			VALUES (old.id_curso,
		   			old.id_cliente,
					old.nombre_curso,
					old.turno,
					old.fecha_inicio,
					old.fecha_fin
		   		   );
			UPDATE agente_telefonico SET id_curso=null WHERE id_curso=old.id_curso;
		ELSE
			RAISE EXCEPTION 'No se puede eliminar el curso % ', old.nombre_curso
			USING HINT = 'Tiene que haber terminado antes de ser eliminado';
		END IF;
		t:=old;
	ELSEIF tg_op = 'INSERT' THEN 
			fechaInicioA := (SELECT fecha_inicio FROM curso WHERE id_curso=new.id_curso);
			fechaFinA := (SELECT fecha_fin FROM curso WHERE id_curso=new.id_curso);	
			FOR fila IN (SELECT * FROM curso WHERE id_entrenador=new.id_entrenador )
			LOOP
				fechaInicioB := fila.fecha_inicio;
				fechaFinB := fila.fecha_fin;
				IF( fechaInicioB < fechaFinA AND fechaInicioA < fechaFinB ) THEN
					RAISE EXCEPTION 'No se puede agregar el curso % ', new.nombre_curso
					USING HINT = 'Se empalma en inicio y fin con otro curso del mismo entrenador';
				END IF;
			END LOOP;
			t:=new;
	ELSEIF tg_op = 'UPDATE' THEN 
			RAISE EXCEPTION 'No se pueden modificar cursos'
			USING HINT = 'Manipulación dinámica de Cursos se deja para futuro desarrollo';
	END IF;
	
	RETURN t;
	END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER manipulacion_curso 
BEFORE INSERT OR UPDATE OR DELETE
ON curso 
FOR EACH ROW
EXECUTE PROCEDURE actualiza_historial_cursos();
CREATE OR REPLACE FUNCTION muestra_inventario()
RETURNS VOID AS $$
BEGIN
SELECT * FROM (SELECT * 
			  FROM (SELECT Id_Estacion Id_Equipo, 'Estacion' Nombre, Id_Sala_Entrenamiento Id_Sala, 'Entrenamiento' Tipo_Sala, Id_Piso, Id_Edificio 
			  		FROM estacion_entrenamiento 
					UNION 
					SELECT Id_Estacion Id_Equipo, 'Estacion' Nombre, Id_Sala_Operaciones Id_Sala, 'Operaciones' Tipo_Sala, Id_Piso, Id_Edificio 
					FROM estacion_operaciones) inv_estaciones
			  UNION
			  SELECT *
			  FROM (SELECT Id_Aditamento, Nombre, Id_Sala_Entrenamiento, 'Entrenamiento' Tipo_Sala, Id_Piso, Id_Edificio 
			  		FROM aditamento_entrenamiento ae LEFT JOIN estacion_entrenamiento ee 
					ON ae.Id_Estacion = ee.Id_Estacion 
				    UNION 
				    SELECT Id_Aditamento, Nombre, Id_Sala_Operaciones, 'Operaciones' Tipo_Sala, Id_Piso, Id_Edificio  
					FROM aditamento_operaciones ao LEFT JOIN estacion_operaciones eo
					ON ao.Id_Estacion = eo.Id_Estacion) inv_aditamentos) inv;
RETURN;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION verifica_a_lo_mas_veinte()
RETURNS trigger AS $$
DECLARE 
	t RECORD;
BEGIN
	IF tg_op= 'INSERT' THEN
		IF ( (new.id_curso IS NOT NULL  ) AND 
			(SELECT COUNT(curp)
			FROM (agente_telefonico NATURAL JOIN curso)
		   	WHERE (id_curso=new.id_curso) ) > 20) THEN
				RAISE EXCEPTION 'No se puede asignar el curso al agente telefónico'
				USING HINT = 'El entrenador no puede tener más de 20 agentes a cargo';
		END IF;
		t:=new;
	END IF;
	RETURN t;
	END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER entrenador_a_lo_mas_veinte_agentes
BEFORE INSERT OR UPDATE
ON agente_telefonico 
FOR EACH ROW
EXECUTE PROCEDURE verifica_a_lo_mas_veinte();


