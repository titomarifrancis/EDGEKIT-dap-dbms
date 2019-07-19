create table userlevel (
	id serial primary key,
	userlevel integer check (userlevel < 4),
	creationdate timestamptz not null
);

create index idx_userlevel on userlevel(id, userlevel);

create table position (
	id serial primary key,
	occupationdesc varchar(64) not null,
	creationdate timestamptz not null	
);

create index idx_position on position(id, occupationdesc);

create table region (
	id serial primary key,
	regionname varchar(24) not null,
	creationdate timestamptz not null	
);

create index idx_region on region(id, regionname);

create table province (
	id serial primary key,
	provincename varchar(24) not null,
	regionid integer references region(id) on delete restrict,
	creationdate timestamptz not null	
);

create index idx_province on province(id, provincename);

create table distdiv (
	id serial primary key,
	distdivname varchar(24) not null,
	provinceid integer references province(id) on delete restrict,
	creationdate timestamptz not null	
);

create index idx_distdiv on distdiv(id, distdivname);

create table municipality (
	id serial primary key,
	townmunicipalityname varchar(24) not null,
	distdivid integer references distdiv(id) on delete restrict,
	creationdate timestamptz not null
);

create index idx_municipality on municipality(id, townmunicipalityname);

create table barangay (
	id serial primary key,
	barangayname varchar(24) not null,
	municipalityid integer references municipality(id) on delete restrict,
	creationdate timestamptz not null
);

create index idx_barangay on barangay(id, barangayname);

create table govtagencyclass (
	id serial primary key,
	agencyclassdesc varchar(32) not null,
	creationdate timestamptz not null
);

create index idx_govtagencyclass on govtagencyclass(id, agencyclassdesc);

create table govtagency (
	id serial primary key,
	agencyname varchar(32) not null,
	govtagencyclassid integer references govtagencyclass(id) on delete restrict,
	parentgovagency integer references govtagency(id) on delete restrict,
	creationdate timestamptz not null
);

create index idx_govtagency on govtagency(id, agencyname);

create table agencyregprovdistdivmunicipalitybrgy (
	id serial primary key,
	govtagencyid integer references govtagency(id) on delete restrict,
	regionid integer default null references region(id) on delete restrict,
	provinceid integer default null references province(id) on delete restrict,
	distdivid integer default null references distdiv(id) on delete restrict,
	municipalityid integer default null references municipality(id) on delete restrict,
	barangayid integer default null references barangay(id) on delete restrict,
	creationdate timestamptz not null
);

create index idx_agencyregprovdistdivmunicipalitybrgy on agencyregprovdistdivmunicipalitybrgy(id);

create table systemuser (
	id serial primary key,
	lastname varchar(64) not null,
	firstname varchar(64) not null,
	midname varchar(64) not null,
	extname varchar(15) not null,
	positionid integer references position(id) on delete restrict,
	organizationaffiliation varchar(128) default null,
	agencyregprovdistdivmunicipalitybrgyid integer references agencyregprovdistdivmunicipalitybrgy(id) on delete restrict,
	username varchar(20) not null,
	password varchar(32) not null,
	userlevelid integer default 0 references userlevel(id) on delete restrict check(userlevelid < 3),
	createdby integer default null references systemuser(id) on delete restrict,
	creationdate timestamptz not null
);

create index idx_systemuser on systemuser(id, lastname, firstname, midname, extname, username, password);
alter table userlevel add column createdby integer references systemuser(id) on delete restrict;
alter table position add column createdby integer references systemuser(id) on delete restrict;
alter table region add column createdby integer references systemuser(id) on delete restrict;
alter table province add column createdby integer references systemuser(id) on delete restrict;
alter table distdiv add column createdby integer references systemuser(id) on delete restrict;
alter table municipality add column createdby integer references systemuser(id) on delete restrict;
alter table barangay add column createdby integer references systemuser(id) on delete restrict;
alter table govtagencyclass add column createdby integer references systemuser(id) on delete restrict;
alter table govtagency add column createdby integer references systemuser(id) on delete restrict;
alter table agencyregprovdistdivmunicipalitybrgy add column createdby integer references systemuser(id) on delete restrict;

create table certification (
	id serial primary key,
	certificationstandard varchar(32) not null,
	createdby integer default null references systemuser(id) on delete restrict,
	creationdate timestamptz not null
);

create index idx_certification on certification(id, certificationstandard);

create table certifyingbody (
	id serial primary key,
	ispubaccredited boolean default false,
	providerorg varchar(32) not null,
	createdby integer default null references systemuser(id) on delete restrict,
	creationdate timestamptz not null
);

create index idx_certifyingbody on certifyingbody(id, providerorg);

create table agencycertification (
	id serial primary key,
	govtagencyid integer references govtagency(id) on delete restrict,
	certifyingbodyid integer references certifyingbody(id) on delete restrict,
	certificationid integer references certification(id) on delete restrict,
	certificationregnumber varchar(16) not null,
	certificationscope text not null,
	scope_ispartial boolean default null,
	provinceid integer default null references province(id) on delete restrict,
	distdivid integer default null references distdiv(id) on delete restrict,
	municipalityid integer default null references municipality(id) on delete restrict,
	barangayid integer default null references barangay(id) on delete restrict,
	certvalidstartdate date not null,
	certvalidenddate date not null,
	isapproved boolean default false,
	approvedby integer default null references systemuser(id) on delete restrict,
	approveddate timestamptz default null,
	createdby integer default null references systemuser(id) on delete restrict,
	creationdate timestamptz not null
);

create index idx_agencycertification on agencycertification(id, certificationregnumber, certificationscope, certvalidstartdate, certvalidenddate);
