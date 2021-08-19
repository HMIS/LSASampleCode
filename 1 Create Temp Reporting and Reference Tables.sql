/*
LSA FY2021 Sample Code

Name:  1 Create Temp Reporting and Reference Tables.sql
Date:  19 AUG 2021

This script drops (if tables exist) and creates the following temp reporting tables:

	tlsa_CohortDates - based on ReportStart and ReportEnd, all cohorts and dates used in the LSA
	tlsa_HHID - 'master' table of HMIS HouseholdIDs active in continuum ES/SH/TH/RRH/PSH projects 
			between 10/1/2012 and ReportEnd.  Used to store adjusted move-in and exit dates, 
			household types, and other frequently-referenced data 
	tlsa_Enrollment - a 'master' table of enrollments associated with the HouseholdIDs in tlsa_HHID
			with enrollment ages and other frequently-referenced data

	tlsa_Person - a person-level pre-cursor to LSAPerson / people active in report period
		ch_Exclude - dates in TH or housed in RRH/PSH; used for LSAPerson chronic homelessness determination
		ch_Include - dates in ES/SH or on the street; used for LSAPerson chronic homelessness determination
		ch_Episodes - episodes of ES/SH/Street time constructed from ch_Include for chronic homelessness determination
	tlsa_Household - a household-level precursor to LSAHousehold / households active in report period
		sys_TimePadded - used to identify households' last inactive date for SystemPath 
		sys_Time - used to count dates in ES/SH, TH, RRH/PSH but not housed, housed in RRH/PSH, and ES/SH/StreetDates
	tlsa_Exit - household-level precursor to LSAExit / households with system exits in exit cohort periods
	tlsa_ExitHoHAdult - used as the basis for determining chronic homelessness for LSAExit
	tlsa_Pops - used to identify people/households in various populations

	dq_Enrollment - Enrollments included in LSAReport data quality reporting 

This script drops (if tables exist), creates, and populates the following 
reference tables used in the sample code:  
	ref_Calendar 
		-Table of dates between 10/1/2012 and 9/30/2022
	
*/

if object_id ('tlsa_CohortDates') is not null drop table tlsa_CohortDates
	
create table tlsa_CohortDates (
	Cohort int
	, CohortStart date
	, CohortEnd date
	, ReportID int
	, constraint pk_tlsa_CohortDates primary key clustered (Cohort)
	)
	;

if object_id ('tlsa_HHID') is not NULL drop table tlsa_HHID 

create table tlsa_HHID (
	 HouseholdID varchar(32)
	, HoHID varchar(32)
	, EnrollmentID varchar(32)
	, ProjectID varchar(32)
	, ProjectType int
	, EntryDate date
	, MoveInDate date
	, ExitDate date
	, LastBednight date
	, EntryHHType int
	, ActiveHHType int
	, Exit1HHType int
	, Exit2HHType int
	, ExitDest int
	, Active bit default 0
	, AHAR bit default 0
	, PITOctober bit default 0
	, PITJanuary bit default 0
	, PITApril bit default 0
	, PITJuly bit default 0
	, ExitCohort int
	, DQ1 int default 0
	, DQ3 int default 0
	, HHChronic int default 0
	, HHVet int default 0
	, HHDisability int default 0
	, HHFleeingDV int default 0
	, HHAdultAge int default 0
	, HHParent int default 0
	, AC3Plus int default 0
	, Step varchar(10) not NULL
	, constraint pk_tlsa_HHID primary key clustered (HouseholdID)
	)

if object_id ('tlsa_Enrollment') is not NULL drop table tlsa_Enrollment 

create table tlsa_Enrollment (
	EnrollmentID varchar(32)
	, PersonalID varchar(32)
	, HouseholdID varchar(32)
	, RelationshipToHoH int
	, ProjectID varchar(32)
	, ProjectType int
	, EntryDate date
	, MoveInDate date
	, ExitDate date
	, LastBednight date
	, EntryAge int
	, ActiveAge int
	, Exit1Age int
	, Exit2Age int
	, DisabilityStatus int
	, DVStatus int
	, Active bit default 0
	, AHAR bit default 0
	, PITOctober bit default 0
	, PITJanuary bit default 0
	, PITApril bit default 0
	, PITJuly bit default 0
	, CH bit default 0
	, Step varchar(10) not NULL
	, constraint pk_tlsa_Enrollment primary key clustered (EnrollmentID)
	)


if object_id ('tlsa_Person') is not NULL drop table tlsa_Person

create table tlsa_Person (
-- client-level precursor to aggregate lsa_Person (LSAPerson.csv)
	PersonalID varchar(32) not NULL,
	HoHAdult int,
	CHStart date,
	LastActive date,
	Gender int,
	Race int,
	Ethnicity int,
	VetStatus int,
	DisabilityStatus int,
	CHTime int,
	CHTimeStatus int,
	DVStatus int,
	ESTAgeMin int default -1,
	ESTAgeMax int default -1,
	HHTypeEST int default -1,
	HoHEST int default -1,
	AdultEST int default -1,
	HHChronicEST int default -1,
	HHVetEST int default -1,
	HHDisabilityEST int default -1,
	HHFleeingDVEST int default -1,
	HHAdultAgeAOEST int default -1,
	HHAdultAgeACEST int default -1,
	HHParentEST int default -1,
	AC3PlusEST int default -1,
	AHAREST int default -1,
	AHARHoHEST int default -1,
	AHARAdultEST int default -1,
	RRHAgeMin int default -1,
	RRHAgeMax int default -1,
	HHTypeRRH int default -1,
	HoHRRH int default -1,
	AdultRRH int default -1,
	HHChronicRRH int default -1,
	HHVetRRH int default -1,
	HHDisabilityRRH int default -1,
	HHFleeingDVRRH int default -1,
	HHAdultAgeAORRH int default -1,
	HHAdultAgeACRRH int default -1,
	HHParentRRH int default -1,
	AC3PlusRRH int default -1,
	AHARRRH int default -1,
	AHARHoHRRH int default -1,
	AHARAdultRRH int default -1,
	PSHAgeMin int default -1,
	PSHAgeMax int default -1,
	HHTypePSH int default -1,
	HoHPSH int default -1,
	AdultPSH int default -1,
	HHChronicPSH int default -1,
	HHVetPSH int default -1,
	HHDisabilityPSH int default -1,
	HHFleeingDVPSH int default -1,
	HHAdultAgeAOPSH int default -1,
	HHAdultAgeACPSH int default -1,
	HHParentPSH int default -1,
	AC3PlusPSH int default -1,
	AHARPSH int default -1,
	AHARHoHPSH int default -1,
	AHARAdultPSH int default -1,
	ReportID int,
	Step varchar(10) not NULL,
	constraint pk_tlsa_Person primary key clustered (PersonalID) 
	)
	;


if object_id ('ch_Exclude') is not NULL drop table ch_Exclude

	create table ch_Exclude(
	PersonalID varchar(32) not NULL,
	excludeDate date not NULL,
	Step varchar(10) not NULL,
	constraint pk_ch_Exclude primary key clustered (PersonalID, excludeDate) 
	)
	;

if object_id ('ch_Include') is not NULL drop table ch_Include
	
	create table ch_Include(
	PersonalID varchar(32) not NULL,
	ESSHStreetDate date not NULL,
	Step varchar(10) not NULL,
	constraint pk_ch_Include primary key clustered (PersonalID, ESSHStreetDate)
	)
	;
	
if object_id ('ch_Episodes') is not NULL drop table ch_Episodes
	create table ch_Episodes(
	PersonalID varchar(32),
	episodeStart date,
	episodeEnd date,
	episodeDays int null,
	Step varchar(10) not NULL,
	constraint pk_ch_Episodes primary key clustered (PersonalID, episodeStart)
	)
	;

if object_id ('tlsa_Household') is not NULL drop table tlsa_Household

create table tlsa_Household(
	HoHID varchar(32) not NULL,
	HHType int not null,
	FirstEntry date,
	LastInactive date,
	Stat int,
	StatEnrollmentID varchar(32),
	ReturnTime int,
	HHChronic int,
	HHVet int,
	HHDisability int,
	HHFleeingDV int,
	HoHRace int,
	HoHEthnicity int,
	HHAdult int,
	HHChild int,
	HHNoDOB int,
	HHAdultAge int,
	HHParent int,
	ESTStatus int,
	ESTGeography int,
	ESTLivingSit int,
	ESTDestination int,
	ESTChronic int,
	ESTVet int,
	ESTDisability int,
	ESTFleeingDV int,
	ESTAC3Plus int,
	ESTAdultAge int,
	ESTParent int,
	RRHStatus int,
	RRHMoveIn int,
	RRHGeography int,
	RRHLivingSit int,
	RRHDestination int,
	RRHPreMoveInDays int,
	RRHChronic int,
	RRHVet int,
	RRHDisability int,
	RRHFleeingDV int,
	RRHAC3Plus int,
	RRHAdultAge int,
	RRHParent int,
	PSHStatus int,
	PSHMoveIn int,
	PSHGeography int,
	PSHLivingSit int,
	PSHDestination int,
	PSHHousedDays int,
	PSHChronic int,
	PSHVet int,
	PSHDisability int,
	PSHFleeingDV int,
	PSHAC3Plus int,
	PSHAdultAge int,
	PSHParent int,
	ESDays int,
	THDays int,
	ESTDays int,
	RRHPSHPreMoveInDays int,
	RRHHousedDays int,
	SystemDaysNotPSHHoused int,
	SystemHomelessDays int,
	Other3917Days int,
	TotalHomelessDays int,
	SystemPath int,
	ESTAHAR int,
	RRHAHAR int,
	PSHAHAR int,
	ReportID int,
	Step varchar(10) not NULL,
	constraint pk_tlsa_Household primary key clustered (HoHID, HHType)
	)
	;

	if object_id ('sys_TimePadded') is not null drop table sys_TimePadded
	
	create table sys_TimePadded (
	HoHID varchar(32) not null
	, HHType int not null
	, Cohort int not null
	, StartDate date
	, EndDate date
	, Step varchar(10) not NULL
	)
	;

	if object_id ('sys_Time') is not null drop table sys_Time
	
	create table sys_Time (
		HoHID varchar(32)
		, HHType int
		, sysDate date
		, sysStatus int
		, Step varchar(10) not NULL
		, constraint pk_sys_Time primary key clustered (HoHID, HHType, sysDate)
		)
		;


	if object_id ('dq_Enrollment') is not null drop table dq_Enrollment
	
	create table dq_Enrollment(
	EnrollmentID varchar(32) not null
	, PersonalID varchar(32) not null
	, HouseholdID varchar(32) not null
	, RelationshipToHoH int
	, ProjectType int
	, EntryDate date
	, MoveInDate date
	, ExitDate date
	, Status1 int
	, Status3 int
	, SSNValid int
	, Step varchar(10) not NULL
    constraint pk_dq_Enrollment primary key clustered (EnrollmentID) 
	)
	;
		

	if object_id ('tlsa_Exit') is not NULL drop table tlsa_Exit
 
	create table tlsa_Exit(
		HoHID varchar(32) not null,
		HHType int not null,
		QualifyingExitHHID varchar(32),
		LastInactive date,
		Cohort int not NULL,
		Stat int,
		ExitFrom int,
		ExitTo int,
		ReturnTime int,
		HHVet int,
		HHChronic int,
		HHDisability int,
		HHFleeingDV int,
		HoHRace int,
		HoHEthnicity int,
		HHAdultAge int,
		HHParent int,
		AC3Plus int,
		SystemPath int,
		ReportID int not NULL,
		Step varchar(10) not NULL,
		constraint pk_tlsa_Exit primary key (Cohort, HoHID, HHType)
		)
		;

	if object_id ('tlsa_ExitHoHAdult') is not NULL drop table tlsa_ExitHoHAdult
 
	create table tlsa_ExitHoHAdult(
		PersonalID varchar(32) not null,
		QualifyingExitHHID varchar(32),
		Cohort int not NULL,
		DisabilityStatus int,
		CHStart date,
		LastActive date,
		CHTime int,
		CHTimeStatus int,
		Step varchar(10) not NULL,
		constraint pk_tlsa_ExitHoHAdult primary key (PersonalID, QualifyingExitHHID, Cohort)
		)
		;

	if object_id ('tlsa_Pops') is not null drop table tlsa_Pops

	create table tlsa_Pops (
		PopID int
		, Cohort int
		, HoHID varchar(32)
		, HHType int
		, PersonalID varchar(32)
		, HouseholdID varchar(32))

	if object_id ('ref_Calendar') is not null drop table ref_Calendar
	create table ref_Calendar (
		theDate date not null 
		, yyyy smallint
		, mm tinyint 
		, dd tinyint
		, month_name varchar(10)
		, day_name varchar(10) 
		, fy smallint
		, constraint pk_ref_Calendar primary key clustered (theDate) 
	)
	;

	--Populate ref_Calendar
	declare @start date = '2012-10-01'
	declare @end date = '2022-09-30'
	declare @i int = 0
	declare @total_days int = DATEDIFF(d, @start, @end) 

	while @i <= @total_days
	begin
			insert into ref_Calendar (theDate) 
			select cast(dateadd(d, @i, @start) as date) 
			set @i = @i + 1
	end

	update ref_Calendar
	set	month_name = datename(month, theDate),
		day_name = datename(weekday, theDate),
		yyyy = datepart(yyyy, theDate),
		mm = datepart(mm, theDate),
		dd = datepart(dd, theDate),
		fy = case when datepart(mm, theDate) between 10 and 12 then datepart(yyyy, theDate) + 1 
			else datepart(yyyy, theDate) end

	if object_id ('ref_RowValues') is not null drop table ref_RowValues
	create table ref_RowValues (
		RowID int not null 
		, Cohort int
		, Universe int 
		, SystemPath int)
;

	if object_id ('ref_RowPopulations') is not null drop table ref_RowPopulations
	create table ref_RowPopulations (
		RowID int
		, PopID int
		, ByPath int 
		, ByGroup int
		, Pop1 int
		, Pop2 int
		, RowMin int
		, RowMax int)
;

insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (1,1,-1,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (1,1,-1,1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (1,1,-1,3)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (1,1,-1,5)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (1,1,-1,7)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (1,1,-1,9)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (1,1,-1,10)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (1,1,-1,12)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (2,1,-1,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (2,1,-1,2)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (2,1,-1,3)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (2,1,-1,6)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (2,1,-1,7)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (2,1,-1,12)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (3,1,-1,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (3,1,-1,3)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (3,1,-1,7)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (3,1,-1,12)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (4,1,-1,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (4,1,-1,4)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (4,1,-1,5)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (4,1,-1,6)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (4,1,-1,7)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (4,1,-1,8)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (4,1,-1,9)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (4,1,-1,10)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (4,1,-1,11)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (4,1,-1,12)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (5,1,-1,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (5,1,-1,5)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (5,1,-1,6)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (5,1,-1,7)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (5,1,-1,8)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (5,1,-1,9)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (5,1,-1,10)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (5,1,-1,11)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (5,1,-1,12)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (6,1,-1,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (6,1,-1,1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (6,1,-1,2)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (6,1,-1,3)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (6,1,-1,4)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (6,1,-1,5)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (6,1,-1,6)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (6,1,-1,7)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (6,1,-1,8)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (6,1,-1,9)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (6,1,-1,10)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (6,1,-1,11)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (6,1,-1,12)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (7,1,-1,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (7,1,-1,1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (7,1,-1,2)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (7,1,-1,3)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (7,1,-1,4)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (7,1,-1,5)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (7,1,-1,6)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (7,1,-1,7)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (7,1,-1,8)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (7,1,-1,9)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (7,1,-1,10)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (7,1,-1,11)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (7,1,-1,12)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (8,1,-1,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (8,1,-1,4)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (8,1,-1,5)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (8,1,-1,6)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (8,1,-1,7)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (8,1,-1,10)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (8,1,-1,11)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (8,1,-1,12)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (9,1,-1,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (9,1,-1,1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (9,1,-1,2)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (9,1,-1,3)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (9,1,-1,4)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (9,1,-1,5)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (9,1,-1,6)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (9,1,-1,7)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (9,1,-1,8)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (9,1,-1,9)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (9,1,-1,10)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (9,1,-1,11)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (9,1,-1,12)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (10,1,-1,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (11,1,-1,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (12,1,-1,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (13,1,-1,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (14,1,-1,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (15,1,-1,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (16,1,-1,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (18,-2,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (18,-2,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (18,-2,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (18,-1,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (18,-1,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (18,-1,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (18,0,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (18,0,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (18,0,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (19,-2,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (19,-2,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (19,-2,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (19,-1,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (19,-1,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (19,-1,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (19,0,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (19,0,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (19,0,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (20,-2,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (20,-2,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (20,-2,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (20,-1,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (20,-1,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (20,-1,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (20,0,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (20,0,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (20,0,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (21,-2,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (21,-2,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (21,-2,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (21,-1,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (21,-1,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (21,-1,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (21,0,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (21,0,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (21,0,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (22,-2,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (22,-2,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (22,-2,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (22,-1,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (22,-1,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (22,-1,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (22,0,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (22,0,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (22,0,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (23,-2,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (23,-2,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (23,-2,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (23,-1,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (23,-1,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (23,-1,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (23,0,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (23,0,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (23,0,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (24,-2,2,1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (24,-2,3,1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (24,-2,4,1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (24,-1,2,1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (24,-1,3,1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (24,-1,4,1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (24,0,2,1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (24,0,3,1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (24,0,4,1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (25,-2,2,2)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (25,-2,3,2)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (25,-2,4,2)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (25,-1,2,2)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (25,-1,3,2)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (25,-1,4,2)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (25,0,2,2)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (25,0,3,2)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (25,0,4,2)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (26,-2,2,3)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (26,-2,3,3)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (26,-2,4,3)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (26,-1,2,3)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (26,-1,3,3)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (26,-1,4,3)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (26,0,2,3)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (26,0,3,3)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (26,0,4,3)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (27,-2,2,4)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (27,-2,3,4)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (27,-2,4,4)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (27,-1,2,4)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (27,-1,3,4)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (27,-1,4,4)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (27,0,2,4)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (27,0,3,4)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (27,0,4,4)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (28,-2,2,5)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (28,-2,3,5)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (28,-2,4,5)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (28,-1,2,5)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (28,-1,3,5)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (28,-1,4,5)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (28,0,2,5)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (28,0,3,5)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (28,0,4,5)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (29,-2,2,6)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (29,-2,3,6)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (29,-2,4,6)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (29,-1,2,6)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (29,-1,3,6)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (29,-1,4,6)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (29,0,2,6)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (29,0,3,6)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (29,0,4,6)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (30,-2,2,7)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (30,-2,3,7)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (30,-2,4,7)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (30,-1,2,7)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (30,-1,3,7)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (30,-1,4,7)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (30,0,2,7)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (30,0,3,7)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (30,0,4,7)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (31,-2,2,8)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (31,-2,3,8)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (31,-2,4,8)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (31,-1,2,8)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (31,-1,3,8)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (31,-1,4,8)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (31,0,2,8)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (31,0,3,8)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (31,0,4,8)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (32,-2,2,9)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (32,-2,3,9)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (32,-2,4,9)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (32,-1,2,9)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (32,-1,3,9)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (32,-1,4,9)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (32,0,2,9)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (32,0,3,9)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (32,0,4,9)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (33,-2,2,10)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (33,-2,3,10)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (33,-2,4,10)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (33,-1,2,10)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (33,-1,3,10)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (33,-1,4,10)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (33,0,2,10)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (33,0,3,10)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (33,0,4,10)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (34,-2,2,11)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (34,-2,3,11)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (34,-2,4,11)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (34,-1,2,11)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (34,-1,3,11)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (34,-1,4,11)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (34,0,2,11)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (34,0,3,11)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (34,0,4,11)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (35,-2,2,12)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (35,-2,3,12)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (35,-2,4,12)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (35,-1,2,12)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (35,-1,3,12)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (35,-1,4,12)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (35,0,2,12)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (35,0,3,12)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (35,0,4,12)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (36,-2,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (36,-2,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (36,-2,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (36,-1,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (36,-1,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (36,-1,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (36,0,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (36,0,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (36,0,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (37,-2,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (37,-1,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (37,0,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (38,-2,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (38,-1,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (38,0,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (39,-2,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (39,-1,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (39,0,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (40,-2,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (40,-1,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (40,0,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (41,-2,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (41,-1,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (41,0,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (42,-2,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (42,-1,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (42,0,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (43,-2,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (43,-1,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (43,0,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (44,-2,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (44,-1,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (44,0,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (45,-2,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (45,-1,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (45,0,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (46,-2,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (46,-1,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (46,0,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (47,-2,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (47,-1,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (47,0,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (48,-2,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (48,-1,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (48,0,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (49,-2,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (49,-1,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (49,0,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (50,-2,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (50,-1,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (50,0,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (51,-2,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (51,-1,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (51,0,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (52,-2,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (52,-1,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (52,0,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,1,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,1,11,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,1,12,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,1,13,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,1,14,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,1,15,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,1,16,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,10,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,10,11,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,10,12,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,10,13,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,10,14,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,10,15,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,10,16,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,11,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,11,11,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,11,12,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,11,13,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,11,14,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,11,15,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,11,16,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,12,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,12,11,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,12,12,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,12,13,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,12,14,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,12,15,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,12,16,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,13,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,13,11,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,13,12,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,13,13,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,13,14,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,13,15,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (53,13,16,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,1,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,1,11,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,1,12,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,1,13,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,1,14,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,1,15,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,1,16,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,10,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,10,11,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,10,12,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,10,13,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,10,14,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,10,15,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,10,16,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,11,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,11,11,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,11,12,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,11,13,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,11,14,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,11,15,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,11,16,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,12,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,12,11,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,12,12,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,12,13,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,12,14,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,12,15,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,12,16,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,13,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,13,11,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,13,12,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,13,13,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,13,14,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,13,15,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (54,13,16,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,1,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,1,11,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,1,12,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,1,13,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,1,14,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,1,15,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,1,16,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,10,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,10,11,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,10,12,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,10,13,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,10,14,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,10,15,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,10,16,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,11,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,11,11,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,11,12,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,11,13,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,11,14,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,11,15,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,11,16,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,12,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,12,11,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,12,12,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,12,13,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,12,14,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,12,15,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,12,16,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,13,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,13,11,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,13,12,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,13,13,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,13,14,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,13,15,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (55,13,16,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (56,1,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (56,1,11,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (56,1,12,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (56,1,13,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (56,1,14,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (56,1,15,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (56,1,16,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (57,1,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (57,1,11,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (57,1,12,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (57,1,13,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (57,1,14,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (57,1,15,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (57,1,16,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (58,20,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (59,20,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (60,20,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (61,20,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (62,1,10,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (63,-2,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (63,-2,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (63,-2,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (63,-1,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (63,-1,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (63,-1,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (63,0,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (63,0,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (63,0,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (64,-2,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (64,-2,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (64,-2,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (64,-1,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (64,-1,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (64,-1,4,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (64,0,2,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (64,0,3,-1)
insert into ref_RowValues (RowID, Cohort, Universe, SystemPath) values (64,0,4,-1)


insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,0,NULL,NULL,0,0,1,52)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,0,1,NULL,0,0,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,10,1,NULL,0,10,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,10,NULL,NULL,0,10,1,52)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,11,NULL,NULL,0,11,1,52)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,11,1,NULL,0,11,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,12,1,NULL,0,12,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,12,NULL,NULL,0,12,1,52)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,13,NULL,NULL,0,13,1,52)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,13,1,NULL,0,13,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,14,1,NULL,0,14,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,14,NULL,NULL,0,14,1,52)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,15,NULL,NULL,0,15,1,52)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,15,1,NULL,0,15,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,16,1,NULL,0,16,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,16,NULL,NULL,0,16,1,52)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,17,NULL,NULL,0,17,1,52)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,17,1,NULL,0,17,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,18,NULL,NULL,0,18,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,19,NULL,NULL,0,19,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,20,NULL,NULL,0,20,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,21,NULL,NULL,0,21,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,22,NULL,NULL,0,22,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,23,NULL,NULL,0,23,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,24,NULL,NULL,0,24,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,25,NULL,NULL,0,25,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,26,NULL,NULL,0,26,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,27,NULL,NULL,0,27,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,28,NULL,NULL,0,28,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,29,NULL,NULL,0,29,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,30,NULL,NULL,0,30,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,31,NULL,NULL,0,31,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,32,NULL,NULL,0,32,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,33,NULL,NULL,0,33,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,34,NULL,NULL,0,34,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,35,NULL,NULL,0,35,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,36,NULL,NULL,0,36,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1018,NULL,NULL,10,18,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1019,NULL,NULL,10,19,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1020,NULL,NULL,10,20,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1021,NULL,NULL,10,21,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1022,NULL,NULL,10,22,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1023,NULL,NULL,10,23,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1024,NULL,NULL,10,24,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1025,NULL,NULL,10,25,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1026,NULL,NULL,10,26,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1027,NULL,NULL,10,27,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1028,NULL,NULL,10,28,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1029,NULL,NULL,10,29,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1030,NULL,NULL,10,30,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1031,NULL,NULL,10,31,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1032,NULL,NULL,10,32,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1033,NULL,NULL,10,33,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1118,NULL,NULL,11,18,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1119,NULL,NULL,11,19,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1120,NULL,NULL,11,20,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1121,NULL,NULL,11,21,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1122,NULL,NULL,11,22,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1123,NULL,NULL,11,23,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1124,NULL,NULL,11,24,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1125,NULL,NULL,11,25,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1126,NULL,NULL,11,26,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1127,NULL,NULL,11,27,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1128,NULL,NULL,11,28,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1129,NULL,NULL,11,29,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1130,NULL,NULL,11,30,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1131,NULL,NULL,11,31,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1132,NULL,NULL,11,32,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1133,NULL,NULL,11,33,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1218,NULL,NULL,12,18,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1219,NULL,NULL,12,19,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1220,NULL,NULL,12,20,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1221,NULL,NULL,12,21,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1222,NULL,NULL,12,22,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1223,NULL,NULL,12,23,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1224,NULL,NULL,12,24,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1225,NULL,NULL,12,25,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1226,NULL,NULL,12,26,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1227,NULL,NULL,12,27,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1228,NULL,NULL,12,28,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1229,NULL,NULL,12,29,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1230,NULL,NULL,12,30,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1231,NULL,NULL,12,31,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1232,NULL,NULL,12,32,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1233,NULL,NULL,12,33,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1318,NULL,NULL,13,18,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1319,NULL,NULL,13,19,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1320,NULL,NULL,13,20,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1321,NULL,NULL,13,21,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1322,NULL,NULL,13,22,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1323,NULL,NULL,13,23,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1324,NULL,NULL,13,24,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1325,NULL,NULL,13,25,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1326,NULL,NULL,13,26,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1327,NULL,NULL,13,27,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1328,NULL,NULL,13,28,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1329,NULL,NULL,13,29,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1330,NULL,NULL,13,30,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1331,NULL,NULL,13,31,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1332,NULL,NULL,13,32,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1333,NULL,NULL,13,33,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1334,NULL,NULL,13,34,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1418,NULL,NULL,14,18,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1419,NULL,NULL,14,19,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1420,NULL,NULL,14,20,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1421,NULL,NULL,14,21,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1422,NULL,NULL,14,22,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1423,NULL,NULL,14,23,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1424,NULL,NULL,14,24,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1425,NULL,NULL,14,25,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1426,NULL,NULL,14,26,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1427,NULL,NULL,14,27,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1428,NULL,NULL,14,28,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1429,NULL,NULL,14,29,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1430,NULL,NULL,14,30,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1431,NULL,NULL,14,31,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1432,NULL,NULL,14,32,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1433,NULL,NULL,14,33,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1434,NULL,NULL,14,34,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1519,NULL,NULL,15,19,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1520,NULL,NULL,15,20,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1521,NULL,NULL,15,21,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1522,NULL,NULL,15,22,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1523,NULL,NULL,15,23,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1524,NULL,NULL,15,24,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1525,NULL,NULL,15,25,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1526,NULL,NULL,15,26,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1527,NULL,NULL,15,27,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1528,NULL,NULL,15,28,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1529,NULL,NULL,15,29,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1530,NULL,NULL,15,30,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1531,NULL,NULL,15,31,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1532,NULL,NULL,15,32,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,1533,NULL,NULL,15,33,1,9)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,0,NULL,NULL,0,0,18,22)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,10,NULL,NULL,0,10,18,22)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,11,NULL,NULL,0,11,18,22)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,12,NULL,NULL,0,12,18,22)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,13,NULL,NULL,0,13,18,22)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,14,NULL,NULL,0,14,18,22)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,15,NULL,NULL,0,15,18,22)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,16,NULL,NULL,0,16,18,22)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,17,NULL,NULL,0,17,18,22)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,0,NULL,NULL,0,0,24,52)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,10,NULL,NULL,0,10,24,52)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,11,NULL,NULL,0,11,24,52)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,12,NULL,NULL,0,12,24,52)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,13,NULL,NULL,0,13,24,52)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,14,NULL,NULL,0,14,24,52)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,15,NULL,NULL,0,15,24,52)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,16,NULL,NULL,0,16,24,52)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,17,NULL,NULL,0,17,24,52)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,0,NULL,NULL,0,0,63,64)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,10,NULL,NULL,0,10,63,64)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,11,NULL,NULL,0,11,63,64)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,12,NULL,NULL,0,12,63,64)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,13,NULL,NULL,0,13,63,64)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,14,NULL,NULL,0,14,63,64)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,15,NULL,NULL,0,15,63,64)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,16,NULL,NULL,0,16,63,64)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (NULL,17,NULL,NULL,0,17,63,64)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,0,NULL,NULL,0,0,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,10,NULL,NULL,0,10,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,11,NULL,NULL,0,11,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,12,NULL,NULL,0,12,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,13,NULL,NULL,0,13,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,14,NULL,NULL,0,14,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,15,NULL,NULL,0,15,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,16,NULL,NULL,0,16,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,17,NULL,NULL,0,17,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,18,NULL,NULL,0,18,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,19,NULL,NULL,0,19,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,20,NULL,NULL,0,20,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,21,NULL,NULL,0,21,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,22,NULL,NULL,0,22,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,23,NULL,NULL,0,23,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,24,NULL,NULL,0,24,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,25,NULL,NULL,0,25,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,26,NULL,NULL,0,26,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,27,NULL,NULL,0,27,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,28,NULL,NULL,0,28,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,29,NULL,NULL,0,29,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,30,NULL,NULL,0,30,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,31,NULL,NULL,0,31,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,32,NULL,NULL,0,32,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,33,NULL,NULL,0,33,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,34,NULL,NULL,0,34,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,35,NULL,NULL,0,35,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,36,NULL,NULL,0,36,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1018,NULL,NULL,10,18,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1019,NULL,NULL,10,19,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1020,NULL,NULL,10,20,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1021,NULL,NULL,10,21,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1022,NULL,NULL,10,22,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1023,NULL,NULL,10,23,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1024,NULL,NULL,10,24,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1025,NULL,NULL,10,25,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1026,NULL,NULL,10,26,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1027,NULL,NULL,10,27,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1028,NULL,NULL,10,28,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1029,NULL,NULL,10,29,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1030,NULL,NULL,10,30,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1031,NULL,NULL,10,31,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1032,NULL,NULL,10,32,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1033,NULL,NULL,10,33,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1118,NULL,NULL,11,18,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1119,NULL,NULL,11,19,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1120,NULL,NULL,11,20,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1121,NULL,NULL,11,21,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1122,NULL,NULL,11,22,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1123,NULL,NULL,11,23,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1124,NULL,NULL,11,24,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1125,NULL,NULL,11,25,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1126,NULL,NULL,11,26,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1127,NULL,NULL,11,27,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1128,NULL,NULL,11,28,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1129,NULL,NULL,11,29,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1130,NULL,NULL,11,30,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1131,NULL,NULL,11,31,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1132,NULL,NULL,11,32,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1133,NULL,NULL,11,33,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1218,NULL,NULL,12,18,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1219,NULL,NULL,12,19,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1220,NULL,NULL,12,20,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1221,NULL,NULL,12,21,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1222,NULL,NULL,12,22,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1223,NULL,NULL,12,23,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1224,NULL,NULL,12,24,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1225,NULL,NULL,12,25,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1226,NULL,NULL,12,26,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1227,NULL,NULL,12,27,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1228,NULL,NULL,12,28,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1229,NULL,NULL,12,29,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1230,NULL,NULL,12,30,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1231,NULL,NULL,12,31,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1232,NULL,NULL,12,32,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1233,NULL,NULL,12,33,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1318,NULL,NULL,13,18,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1319,NULL,NULL,13,19,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1320,NULL,NULL,13,20,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1321,NULL,NULL,13,21,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1322,NULL,NULL,13,22,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1323,NULL,NULL,13,23,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1324,NULL,NULL,13,24,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1325,NULL,NULL,13,25,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1326,NULL,NULL,13,26,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1327,NULL,NULL,13,27,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1328,NULL,NULL,13,28,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1329,NULL,NULL,13,29,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1330,NULL,NULL,13,30,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1331,NULL,NULL,13,31,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1332,NULL,NULL,13,32,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1333,NULL,NULL,13,33,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1334,NULL,NULL,13,34,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1418,NULL,NULL,14,18,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1419,NULL,NULL,14,19,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1420,NULL,NULL,14,20,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1421,NULL,NULL,14,21,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1422,NULL,NULL,14,22,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1423,NULL,NULL,14,23,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1424,NULL,NULL,14,24,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1425,NULL,NULL,14,25,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1426,NULL,NULL,14,26,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1427,NULL,NULL,14,27,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1428,NULL,NULL,14,28,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1429,NULL,NULL,14,29,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1430,NULL,NULL,14,30,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1431,NULL,NULL,14,31,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1432,NULL,NULL,14,32,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1433,NULL,NULL,14,33,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1434,NULL,NULL,14,34,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1519,NULL,NULL,15,19,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1520,NULL,NULL,15,20,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1521,NULL,NULL,15,21,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1522,NULL,NULL,15,22,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1523,NULL,NULL,15,23,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1524,NULL,NULL,15,24,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1525,NULL,NULL,15,25,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1526,NULL,NULL,15,26,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1527,NULL,NULL,15,27,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1528,NULL,NULL,15,28,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1529,NULL,NULL,15,29,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1530,NULL,NULL,15,30,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1531,NULL,NULL,15,31,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1532,NULL,NULL,15,32,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (23,1533,NULL,NULL,15,33,23,23)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (53,0,NULL,NULL,0,0,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (53,10,NULL,NULL,0,10,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (53,11,NULL,NULL,0,11,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (53,12,NULL,NULL,0,12,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (53,13,NULL,NULL,0,13,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (53,14,NULL,NULL,0,14,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (53,15,NULL,NULL,0,15,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (53,18,NULL,NULL,0,18,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (53,19,NULL,NULL,0,19,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (53,34,NULL,NULL,0,34,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (53,35,NULL,NULL,0,35,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (54,0,NULL,NULL,0,0,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (54,10,NULL,NULL,0,10,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (54,11,NULL,NULL,0,11,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (54,12,NULL,NULL,0,12,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (54,13,NULL,NULL,0,13,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (54,14,NULL,NULL,0,14,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (54,15,NULL,NULL,0,15,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (54,18,NULL,NULL,0,18,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (54,19,NULL,NULL,0,19,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (54,34,NULL,NULL,0,34,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (54,35,NULL,NULL,0,35,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,50,NULL,NULL,0,50,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,50,NULL,1,0,50,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,51,NULL,1,0,51,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,52,NULL,1,0,52,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,53,NULL,NULL,0,53,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,53,NULL,1,0,53,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,54,NULL,1,0,54,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,55,NULL,1,0,55,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,56,NULL,1,0,56,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,57,NULL,1,0,57,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,58,NULL,1,0,58,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,59,NULL,1,0,59,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,60,NULL,1,0,60,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,61,NULL,1,0,61,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,62,NULL,1,0,62,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,63,NULL,1,0,63,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,64,NULL,1,0,64,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,65,NULL,1,0,65,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,66,NULL,1,0,66,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,67,NULL,1,0,67,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,68,NULL,1,0,68,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,69,NULL,1,0,69,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,70,NULL,1,0,70,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,71,NULL,1,0,71,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,72,NULL,1,0,72,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,73,NULL,1,0,73,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,74,NULL,1,0,74,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,75,NULL,1,0,75,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,76,NULL,1,0,76,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,77,NULL,1,0,77,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,78,NULL,1,0,78,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,79,NULL,1,0,79,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,80,NULL,1,0,80,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,81,NULL,1,0,81,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,82,NULL,1,0,82,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5053,NULL,1,50,53,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5054,NULL,1,50,54,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5055,NULL,1,50,55,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5056,NULL,1,50,56,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5057,NULL,1,50,57,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5058,NULL,1,50,58,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5059,NULL,1,50,59,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5060,NULL,1,50,60,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5061,NULL,1,50,61,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5062,NULL,1,50,62,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5063,NULL,1,50,63,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5064,NULL,1,50,64,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5065,NULL,1,50,65,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5066,NULL,1,50,66,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5067,NULL,1,50,67,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5068,NULL,1,50,68,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5069,NULL,1,50,69,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5070,NULL,1,50,70,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5071,NULL,1,50,71,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5153,NULL,1,51,53,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5154,NULL,1,51,54,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5155,NULL,1,51,55,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5156,NULL,1,51,56,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5157,NULL,1,51,57,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5158,NULL,1,51,58,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5159,NULL,1,51,59,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5160,NULL,1,51,60,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5161,NULL,1,51,61,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5162,NULL,1,51,62,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5163,NULL,1,51,63,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5164,NULL,1,51,64,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5165,NULL,1,51,65,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5166,NULL,1,51,66,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5167,NULL,1,51,67,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5168,NULL,1,51,68,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5169,NULL,1,51,69,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5170,NULL,1,51,70,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5171,NULL,1,51,71,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5253,NULL,1,52,53,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5254,NULL,1,52,54,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5255,NULL,1,52,55,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5256,NULL,1,52,56,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5257,NULL,1,52,57,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5258,NULL,1,52,58,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5259,NULL,1,52,59,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5260,NULL,1,52,60,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5261,NULL,1,52,61,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5262,NULL,1,52,62,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5263,NULL,1,52,63,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5264,NULL,1,52,64,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5265,NULL,1,52,65,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5266,NULL,1,52,66,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5267,NULL,1,52,67,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5268,NULL,1,52,68,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5269,NULL,1,52,69,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5270,NULL,1,52,70,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (55,5271,NULL,1,52,71,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (56,0,NULL,NULL,0,0,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (56,10,NULL,NULL,0,10,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (56,11,NULL,NULL,0,11,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (57,50,NULL,NULL,0,50,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (57,53,NULL,NULL,0,53,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (58,0,NULL,NULL,0,0,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (59,0,NULL,NULL,0,0,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (60,0,NULL,NULL,0,0,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (61,0,NULL,NULL,0,0,NULL,NULL)
insert into ref_RowPopulations (RowID, PopID, ByPath, ByGroup, Pop1, Pop2, RowMin, RowMax) values (62,0,NULL,NULL,0,0,NULL,NULL)


