/*
LSA FY2021 Sample Code

Name:  1 Create Temp Reporting and Reference Tables.sql
Date:  16 AUG 2021

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
	 HouseholdID nvarchar(32)
	, HoHID nvarchar(32)
	, EnrollmentID nvarchar(32)
	, ProjectID nvarchar(32)
	, ProjectType int
	, TrackingMethod int
	, EntryDate date
	, MoveInDate date
	, ExitDate date
	, LastBednight date
	, EntryHHType int
	, ActiveHHType int
	, Exit1HHType int
	, Exit2HHType int
	, ExitDest int
	, Active bit
	, AHAR bit
	, PITOctober bit
	, PITJanuary bit
	, PITApril bit
	, PITJuly bit
	, ExitCohort int
	, ActivePath int
	, ExitPath int
	, DQ1 int
	, DQ3 int
	, HHChronic int
	, HHVet int
	, HHDisability int
	, HHFleeingDV int
	, HHAdultAge int
	, HHParent int
	, AC3Plus int
	, Step nvarchar(10) not NULL
	, constraint pk_tlsa_HHID primary key clustered (HouseholdID)
	)

if object_id ('tlsa_Enrollment') is not NULL drop table tlsa_Enrollment 

create table tlsa_Enrollment (
	EnrollmentID nvarchar(32)
	, PersonalID nvarchar(32)
	, HouseholdID nvarchar(32)
	, RelationshipToHoH int
	, ProjectID nvarchar(32)
	, ProjectType int
	, TrackingMethod int
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
	, Active bit
	, AHAR bit
	, PITOctober bit
	, PITJanuary bit
	, PITApril bit
	, PITJuly bit
	, CH bit
	, Step nvarchar(10) not NULL
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
	ESTAgeMin int,
	ESTAgeMax int,
	HHTypeEST int,
	HoHEST int,
	AdultEST int,
	HHChronicEST int,
	HHVetEST int,
	HHDisabilityEST int,
	HHFleeingDVEST int,
	HHAdultAgeAOEST int,
	HHAdultAgeACEST int,
	HHParentEST int,
	AC3PlusEST int,
	AHAREST int,
	AHARHoHEST int,
	AHARAdultEST int,
	RRHAgeMin int,
	RRHAgeMax int,
	HHTypeRRH int,
	HoHRRH int,
	AdultRRH int,
	HHChronicRRH int,
	HHVetRRH int,
	HHDisabilityRRH int,
	HHFleeingDVRRH int,
	HHAdultAgeAORRH int,
	HHAdultAgeACRRH int,
	HHParentRRH int,
	AC3PlusRRH int,
	AHARRRH int,
	AHARHoHRRH int,
	AHARAdultRRH int,
	PSHAgeMin int,
	PSHAgeMax int,
	HHTypePSH int,
	HoHPSH int,
	AdultPSH int,
	HHChronicPSH int,
	HHVetPSH int,
	HHDisabilityPSH int,
	HHFleeingDVPSH int,
	HHAdultAgeAOPSH int,
	HHAdultAgeACPSH int,
	HHParentPSH int,
	AC3PlusPSH int,
	AHARPSH int,
	AHARHoHPSH int,
	AHARAdultPSH int,
	ReportID int,
	Step nvarchar(10) not NULL,
	constraint pk_tlsa_Person primary key clustered (PersonalID) 
	)
	;


if object_id ('ch_Exclude') is not NULL drop table ch_Exclude

	create table ch_Exclude(
	PersonalID varchar(32) not NULL,
	excludeDate date not NULL,
	Step nvarchar(10) not NULL,
	constraint pk_ch_Exclude primary key clustered (PersonalID, excludeDate) 
	)
	;

if object_id ('ch_Include') is not NULL drop table ch_Include
	
	create table ch_Include(
	PersonalID varchar(32) not NULL,
	ESSHStreetDate date not NULL,
	Step nvarchar(10) not NULL,
	constraint pk_ch_Include primary key clustered (PersonalID, ESSHStreetDate)
	)
	;
	
if object_id ('ch_Episodes') is not NULL drop table ch_Episodes
	create table ch_Episodes(
	PersonalID varchar(32),
	episodeStart date,
	episodeEnd date,
	episodeDays int null,
	Step nvarchar(10) not NULL,
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
	Step nvarchar(10) not NULL,
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
	, Step nvarchar(10) not NULL
	)
	;

	if object_id ('sys_Time') is not null drop table sys_Time
	
	create table sys_Time (
		HoHID nvarchar(32)
		, HHType int
		, sysDate date
		, sysStatus int
		, Step nvarchar(10) not NULL
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
	, Step nvarchar(10) not NULL
    constraint pk_dq_Enrollment primary key clustered (EnrollmentID) 
	)
	;
		

	if object_id ('tlsa_Exit') is not NULL drop table tlsa_Exit
 
	create table tlsa_Exit(
		HoHID nvarchar(32) not null,
		HHType int not null,
		QualifyingExitHHID nvarchar(32),
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
		Step nvarchar(10) not NULL,
		constraint pk_tlsa_Exit primary key (Cohort, HoHID, HHType)
		)
		;

	if object_id ('tlsa_ExitHoHAdult') is not NULL drop table tlsa_ExitHoHAdult
 
	create table tlsa_ExitHoHAdult(
		PersonalID nvarchar(32) not null,
		QualifyingExitHHID nvarchar(32),
		Cohort int not NULL,
		DisabilityStatus int,
		CHStart int,
		LastActive int,
		CHTime int,
		CHTimeStatus int,
		Step nvarchar(10) not NULL,
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


