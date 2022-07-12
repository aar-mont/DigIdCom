
SET foreign_key_checks = 0; # eliminamos la detección de dependencias

create database DigIdCom;

use DigIdCom;

drop table if exists miembro;
create table miembro(
	nombreApellidos varchar(50) not null, ID varchar(10),
 	constraint mie_cp primary key (ID)
);

drop table if exists gestor;
create table gestor(
	nombreApellidos varchar(50) not null, ID varchar(10),
	constraint ges_cp primary key (ID)
);

drop table if exists comunidad;
create table comunidad(
	nombreComunidad varchar(20),fechaCreacion varchar(70),
	creador varchar(10), numMiembros integer check (numMiembros >= 0),
	constraint com_cp primary key (nombreComunidad),
	constraint com_cf foreign key (creador) references gestor(ID)
	
);

drop table if exists ca_root;
create table ca_root(
	nombreOrg_cert varchar(10) not null, ubicacion varchar(30) not null,
	serialNumber_root varchar(70), 
	valida_root varchar(1) check (valida_root in ('s', 'n')),
	fechaFin_root varchar(25),
	constraint car_cp primary key (serialNumber_root)
);	 
	
drop table if exists ca_int;
create table ca_int(
	nombreCom_int varchar(20), ubicacion_Com varchar(30), 
	serialNumber_int varchar(70),
	valida varchar(1) check (valida in ('s', 'n')),
	fechaFin_int varchar(25),
	constraint cai_cp primary key (serialNumber_int),
	constraint cai_cf foreign key (nombreCom_int) references comunidad(nombreComunidad)
);

drop table if exists certificado;
create table certificado(
	serialNumber varchar(70),
	revocado varchar(1) check (revocado in ('s', 'n')),
	fechaFin varchar(25),
	constraint cer_cp primary key (serialNumber)
);

drop table if exists es_propietario_de;
create table es_propietario_de(
	ID varchar(10), serialNumber varchar(70),
	constraint esp_cp primary key (serialNumber),
	constraint esp_cf foreign key (ID) references miembro(ID),
	constraint esp_cf2 foreign key (serialNumber) references certificado(serialNumber)
);

drop table if exists certifica;
create table certifica(
	serialNumber_int varchar(70), nombreComunidad varchar(20),
	constraint certi_cp primary key (serialNumber_int),
	constraint certi_cf foreign key (nombreComunidad) references comunidad(nombreComunidad),
	constraint certi_cf2 foreign key (serialNumber_int) references ca_int(serialNumber_int)
);

drop table if exists emite;
create table emite(
	serialNumber_int varchar(70), serialNumber varchar(70),
	constraint emi_cp primary key (serialNumber),
	constraint emi_cf foreign key (serialNumber_int) references ca_int(serialNumber_int),
	constraint emi_cf2 foreign key (serialNumber) references certificado(serialNumber)
);

drop table if exists crea;
create table crea(
	serialNumber_root varchar(70), serialNumber_int varchar(70),
	constraint cre_cp primary key (serialNumber_int),
	constraint cre_cf foreign key (serialNumber_int) references ca_int(serialNumber_int),
	constraint cre_cf2 foreign key (serialNumber_root) references ca_root(serialNumber_root)
);










