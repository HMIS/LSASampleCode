---
layout: default
title: LSA Temporary and Reference Tables
nav_order: 15
parent: LSA Programming Specifications
has_toc: true
last_modified_date: 2026-08-01
last_edit_timestamp: true
aux_links:
  "LSASampleCode Repository on GitHub":
    - "//github.com/HMIS/LSASampleCode"
---
# LSA Temporary and Reference Tables
These tables are created by [01 Temp Reporting and Reference Tables.sql](https://github.com/HMIS/LSASampleCode/blob/master/01%20Temp%20Reporting%20and%20Reference%20Tables.sql).  

## tlsa_CohortDates
Based on <u>ReportStart</u> and <u>ReportEnd</u>, includes all cohorts used in the LSA with their associated start, end, and lookback dates.

Logic is defined in [3.2 LSA Reporting Cohorts and Dates](03 - Core Concepts and Data Universe.md#32-lsa-reporting-cohorts-and-dates-tlsa_cohortdates).

| Column Name | Data Type | Notes |
| --- | --- | --- |
| Cohort | int |  |
| CohortStart | date |  |
| CohortEnd | date |  |
| LookbackDate | date |  |
| ReportID | int |  |

## tlsa_HHID
A master table of potentially reportable HMIS HouseholdIDs active in continuum ES/SH/TH/RRH/PSH projects between LookbackDate (<u>ReportStart</u> - 7 years) and <u>ReportEnd</u>.  Used to store effective entry, move-in, and exit dates, household types, and other frequently-referenced data.

Business logic associated with populating tlsa_HHID is in section [3.3 HMIS Household Enrollments](03 - Core Concepts and Data Universe.md#33-hmis-household-enrollments-tlsa_hhid)

| Column Name | Data Type | Notes |
| --- | --- | --- |
| HouseholdID | nvarchar(32) |  |
| HoHID | nvarchar(32) |  |
| EnrollmentID | nvarchar(32) |  |
| ProjectID | nvarchar(32) |  |
| LSAProjectType | int |  |
| EntryDate | date |  |
| MoveInDate | date |  |
| ExitDate | date |  |
| LastBednight | date |  |
| EntryHHType | int |  |
| ActiveHHType | int |  |
| Exit1HHType | int |  |
| Exit2HHType | int |  |
| ExitDest | int |  |
| Active | bit |  |
| AIR | bit |  |
| ExitCohort | int |  |
| HHChronic | int |  |
| HHVet | int |  |
| HHDisability | int |  |
| HHFleeingDV | int |  |
| HHAdultAge | int |  |
| HHParent | int |  |
| AC3Plus | int |  |
| Step | nvarchar(10) |  |

## tlsa_Enrollment
A master table of potentially reportable enrollments associated with the HouseholdIDs in tlsa_HHID; used to store entry, exit, and move-in dates, enrollment ages, and other frequently-referenced data.

Business logic associated with populating tlsa_Enrollment is in section [3.4 HMIS Client Enrollments (tlsa_Enrollment)](03 - Core Concepts and Data Universe.md#34-hmis-client-enrollments-tlsa_enrollment).

| Column Name | Data Type | Notes |
| --- | --- | --- |
| EnrollmentID | nvarchar(32) |  |
| PersonalID | nvarchar(32) |  |
| HouseholdID | nvarchar(32) |  |
| RelationshipToHoH | int |  |
| ProjectID | nvarchar(32) |  |
| LSAProjectType | int |  |
| EntryDate | date |  |
| MoveInDate | date |  |
| ExitDate | date |  |
| LastBednight | date |  |
| EntryAge | int |  |
| ActiveAge | int |  |
| Exit1Age | int |  |
| Exit2Age | int |  |
| DisabilityStatus | int |  |
| DVStatus | int |  |
| Active | bit |  |
| AIR | bit |  |
| PITOctober | bit |  |
| PITJanuary | bit |  |
| PITApril | bit |  |
| PITJuly | bit |  |
| CH | bit |  |
| HIV | bit |  |
| SMI | bit |  |
| SUD | bit |  |
| Step | nvarchar(10) |  |

## tlsa_Person
 A client-level pre-cursor to LSAPerson with records for each PersonalID active in report period.

 Business logic associated with tlsa_Person is in section [5 - HMIS Business Logic - LSAPerson](05 - LSAPerson.md)

| Column Name | Data Type | Notes |
| --- | --- | --- |
| PersonalID | nvarchar(32) |  |
| HoHAdult | int |  |
| CHStart | date |  |
| LastActive | date |  |
| RaceEthnicity | int |  |
| VetStatus | int |  |
| DisabilityStatus | int |  |
| CHTime | int |  |
| CHTimeStatus | int |  |
| DVStatus | int |  |
| ESTAgeMin | int |  |
| ESTAgeMax | int |  |
| HHTypeEST | int |  |
| HoHEST | int |  |
| AdultEST | int |  |
| AIRAdultEST | int |  |
| HHChronicEST | int |  |
| HHVetEST | int |  |
| HHDisabilityEST | int |  |
| HHFleeingDVEST | int |  |
| HHAdultAgeAOEST | int |  |
| HHAdultAgeACEST | int |  |
| HHParentEST | int |  |
| AC3PlusEST | int |  |
| AIREST | int |  |
| AIRHoHEST | int |  |
| RRHAgeMin | int |  |
| RRHAgeMax | int |  |
| HHTypeRRH | int |  |
| HoHRRH | int |  |
| AdultRRH | int |  |
| AIRAdultRRH | int |  |
| HHChronicRRH | int |  |
| HHVetRRH | int |  |
| HHDisabilityRRH | int |  |
| HHFleeingDVRRH | int |  |
| HHAdultAgeAORRH | int |  |
| HHAdultAgeACRRH | int |  |
| HHParentRRH | int |  |
| AC3PlusRRH | int |  |
| AIRRRH | int |  |
| AIRHoHRRH | int |  |
| PSHAgeMin | int |  |
| PSHAgeMax | int |  |
| HHTypePSH | int |  |
| HoHPSH | int |  |
| AdultPSH | int |  |
| AIRAdultPSH | int |  |
| HHChronicPSH | int |  |
| HHVetPSH | int |  |
| HHDisabilityPSH | int |  |
| HHFleeingDVPSH | int |  |
| HHAdultAgeAOPSH | int |  |
| HHAdultAgeACPSH | int |  |
| HHParentPSH | int |  |
| AC3PlusPSH | int |  |
| AIRPSH | int |  |
| AIRHoHPSH | int |  |
| RRHSOAgeMin | int |  |
| RRHSOAgeMax | int |  |
| HHTypeRRHSONoMI | int |  |
| HHTypeRRHSOMI | int |  |
| HHTypeES | int |  |
| HHTypeSH | int |  |
| HHTypeTH | int |  |
| HIV | int |  |
| SMI | int |  |
| SUD | int |  |
| SSNValid | int |  |
| ReportID | int |  |
| Step | nvarchar(10) |  |

## ch_Exclude
Dates enrolled in TH or housed in RRH/PSH; used for LSAPerson chronic homelessness determination.

Business logic associated with ch_Exclude is in section [5.7 Get Dates to Exclude from Counts of ES/SH/Street Days](05 - LSAPerson.md#57-get-dates-to-exclude-from-counts-of-esshstreet-days-ch_exclude)

| Column Name | Data Type | Notes |
| --- | --- | --- |
| PersonalID | nvarchar(32) |  |
| excludeDate | date |  |
| Step | nvarchar(10) |  |

## ch_Include
Dates in ES/SH or on the street; used for LSAPerson chronic homelessness determination.

Business logic associated with ch_Include is in section [5.8 Get Dates to Include in Counts of ES/SH/Street Days](05 - LSAPerson.md#58-get-dates-to-include-in-counts-of-esshstreet-days-ch_include)

| Column Name | Data Type | Notes |
| --- | --- | --- |
| PersonalID | nvarchar(32) |  |
| ESSHStreetDate | date |  |
| Step | nvarchar(10) |  |

## ch_Episodes
Holds episodes of ES/SH/Street time constructed from ch_Include for LSAPerson chronic homelessness determination.

Business logic associated with ch_Episodes is in section [5.9 Get ES/SH/Street Episodes](05 - LSAPerson.md#59-get-esshstreet-episodes-ch_episodes)

| Column Name | Data Type | Notes |
| --- | --- | --- |
| PersonalID | nvarchar(32) |  |
| episodeStart | date |  |
| episodeEnd | date |  |
| episodeDays | int |  |
| Step | nvarchar(10) |  |

## tlsa_Household
A household-level precursor to LSAHousehold with a record for each unique combination of the head of household's PersonalID (HoHID) and household type (HHType) active in the report period.

Business logic associated with tlsa_Household begins in section [6.1 Get Distinct Households for LSAHousehold](06 - LSAHousehold.md#61-get-distinct-households-for-lsahousehold)

| Column Name | Data Type | Notes |
| --- | --- | --- |
| HoHID | nvarchar(32) |  |
| HHType | int |  |
| FirstEntry | date |  |
| LastInactive | date |  |
| Stat | int |  |
| StatEnrollmentID | nvarchar(32) |  |
| ReturnTime | int |  |
| HHChronic | int |  |
| HHVet | int |  |
| HHDisability | int |  |
| HHFleeingDV | int |  |
| HoHRaceEthnicity | int |  |
| HHAdult | int |  |
| HHChild | int |  |
| HHNoDOB | int |  |
| HHAdultAge | int |  |
| HHParent | int |  |
| ESTStatus | int |  |
| ESTGeography | int |  |
| ESTLivingSit | int |  |
| ESTDestination | int |  |
| ESTChronic | int |  |
| ESTVet | int |  |
| ESTDisability | int |  |
| ESTFleeingDV | int |  |
| ESTAC3Plus | int |  |
| ESTAdultAge | int |  |
| ESTParent | int |  |
| RRHStatus | int |  |
| RRHMoveIn | int |  |
| RRHGeography | int |  |
| RRHLivingSit | int |  |
| RRHDestination | int |  |
| RRHPreMoveInDays | int |  |
| RRHChronic | int |  |
| RRHVet | int |  |
| RRHDisability | int |  |
| RRHFleeingDV | int |  |
| RRHAC3Plus | int |  |
| RRHAdultAge | int |  |
| RRHParent | int |  |
| PSHStatus | int |  |
| PSHMoveIn | int |  |
| PSHGeography | int |  |
| PSHLivingSit | int |  |
| PSHDestination | int |  |
| PSHHousedDays | int |  |
| PSHChronic | int |  |
| PSHVet | int |  |
| PSHDisability | int |  |
| PSHFleeingDV | int |  |
| PSHAC3Plus | int |  |
| PSHAdultAge | int |  |
| PSHParent | int |  |
| ESDays | int |  |
| THDays | int |  |
| ESTDays | int |  |
| RRHPSHPreMoveInDays | int |  |
| RRHHousedDays | int |  |
| SystemDaysNotPSHHoused | int |  |
| SystemHomelessDays | int |  |
| Other3917Days | int |  |
| TotalHomelessDays | int |  |
| SystemPath | int |  |
| ESTAIR | int |  |
| RRHAIR | int |  |
| PSHAIR | int |  |
| RRHSOStatus | int |  |
| RRHSOMoveIn | int |  |
| ReportID | int |  |
| Step | nvarchar(10) |  |


## sys_Time
Used as the basis for counts of dates in ES/SH, TH, RRH/PSH (unhoused and housed), and ES/SH/StreetDates for LSAHousehold.

Business logic associated with sys_Time is in sections: 
- [6.11 Dates Housed in PSH or RRH](06 - LSAHousehold.md#611-dates-housed-in-psh-or-rrh-sys_time)
- [6.13 Get Dates of Other System Use](06 - LSAHousehold.md#613-get-dates-of-other-system-use-sys_time)

| Column Name | Data Type | Notes |
| --- | --- | --- |
| HoHID | nvarchar(32) |  |
| HHType | int |  |
| sysDate | date |  |
| sysStatus | int |  |
| Step | nvarchar(10) |  |

## sys_TimePadded
Used to identify households' last inactive date as a precursor to reporting on SystemPath in LSAHousehold.

See section [6.12 Get Last Inactive Date](06 - LSAHousehold.md#612-get-last-inactive-date-sys_timepadded) for business logic.

| Column Name | Data Type | Notes |
| --- | --- | --- |
| HoHID | nvarchar(32) |  |
| HHType | int |  |
| Cohort | int |  |
| StartDate | date |  |
| EndDate | date |  |
| Step | nvarchar(10) |  |

## tlsa_Exit
A household-level precursor to LSAExit with a record for each unique combination of the head of household's PersonalID (HoHID), household type (HHType), and cohort with qualifying exits in the given cohort period.

Business logic begins in section [7.1 Identify Qualifying Exits in Exit Cohort Periods](07 - LSAExit.md#71-identify-qualifying-exits-in-exit-cohort-periods) and continues through the end of section 7.

| Column Name | Data Type | Notes |
| --- | --- | --- |
| HoHID | nvarchar(32) |  |
| HHType | int |  |
| QualifyingExitHHID | nvarchar(32) |  |
| LastInactive | date |  |
| Cohort | int |  |
| Stat | int |  |
| ExitFrom | int |  |
| ExitTo | int |  |
| ReturnTime | int |  |
| HHVet | int |  |
| HHChronic | int |  |
| HHDisability | int |  |
| HHFleeingDV | int |  |
| HoHRaceEthnicity | int |  |
| HHAdultAge | int |  |
| HHParent | int |  |
| AC3Plus | int |  |
| SystemPath | int |  |
| ReportID | int |  |
| Step | nvarchar(10) |  |

## ch_Exclude_exit
An analog to ch_Exclude; used to hold dates in TH or housed in RRH/PSH for LSAExit chronic homelessness determination.

Business logic is in section [7.5 Get Dates to Exclude from Counts of ES/SH/Street Days (ch_Exclude_exit)](07 - LSAExit.md#75-get-dates-to-exclude-from-counts-of-esshstreet-days-ch_exclude_exit)

| Column Name | Data Type | Notes |
| --- | --- | --- |
| PersonalID | nvarchar(32) |  |
| excludeDate | date |  |
| Step | nvarchar(10) |  |

## ch_Include_exit
An analog for ch_Include; holds dates in ES/SH or on the street for LSAExit chronic homelessness determination.

Business logic is in section [7.6 Get Dates to Include in Counts of ES/SH/Street Days (ch_Include_exit)](07 - LSAExit.md#76-get-dates-to-include-in-counts-of-esshstreet-days-ch_include_exit).

| Column Name | Data Type | Notes |
| --- | --- | --- |
| PersonalID | nvarchar(32) |  |
| ESSHStreetDate | date |  |
| Step | nvarchar(10) |  |

## ch_Episodes_exit
An analog for ch_Episodes; records of episodes of ES/SH/Street time constructed from ch_Include for LSAExit chronic homelessness determination.

| Column Name | Data Type | Notes |
| --- | --- | --- |
| PersonalID | nvarchar(32) |  |
| episodeStart | date |  |
| episodeEnd | date |  |
| episodeDays | int |  |
| Step | nvarchar(10) |  |

## sys_TimePadded_exit
An analog for sys_TimePadded; used to identify households' last inactive date as a precursor to reporting on SystemPath in LSAExit.

Business logic is in section [7.11 Last Inactive Date for Exit Cohorts](07 - LSAExit.md#711-last-inactive-date-for-exit-cohorts).

| Column Name | Data Type | Notes |
| --- | --- | --- |
| HoHID | nvarchar(32) |  |
| HHType | int |  |
| Cohort | int |  |
| StartDate | date |  |
| EndDate | date |  |
| Step | nvarchar(10) |  |

## tlsa_ExitHoHAdult

Used as the basis for reporting on chronic homelessness for LSAExit (which is limited to adults and head of household).

Business logic is in section [7.4 Identify HoH and Adult Members of Exit Cohorts](07 - LSAExit.md#74-identify-hoh-and-adult-members-of-exit-cohorts).

| Column Name | Data Type | Notes |
| --- | --- | --- |
| PersonalID | nvarchar(32) |  |
| QualifyingExitHHID | nvarchar(32) |  |
| Cohort | int |  |
| DisabilityStatus | int |  |
| CHStart | date |  |
| LastActive | date |  |
| CHTime | int |  |
| CHTimeStatus | int |  |
| Step | nvarchar(10) |  |

## tlsa_AveragePops
Used to identify households in various populations and subpopulations for reporting on average # of days in section 8 based on tlsa_Household and tlsa_Exit.

Required populations, subpopulations, and associated criteria are in section [8.3 Populations for Average Days from LSAHousehold and LSAExit](08 - LSACalculated Averages.md#83-populations-for-average-days-from-lsahousehold-and-lsaexit).

| Column Name | Data Type | Notes |
| --- | --- | --- |
| PopID | int |  |
| Cohort | int |  |
| HoHID | nvarchar(32) |  |
| HHType | int |  |
| Step | nvarchar(10) |  |

## tlsa_CountPops
Used to identify people/households in various populations and subpopulations for active-in-residence counts in section 9.

| Column Name | Data Type | Notes |
| --- | --- | --- |
| PopID | int |  |
| PersonalID | nvarchar(32) |  |
| HouseholdID | nvarchar(32) |  |
| Step | nvarchar(10) |  |

## ref_Calendar
A table of dates between 10/1/2012 and 9/30/2030.  This is populated by 01 Temp Reporting and Reference Tables.sql and used in the sample code as a tool for counting days.

| Column Name | Data Type | Notes |
| --- | --- | --- |
| theDate | date |  |
| yyyy | smallint |  |
| mm | tinyint |  |
| dd | tinyint |  |
| month_name | nvarchar(10) |  |
| day_name | nvarchar(10) |  |
| fy | smallint |  |

## ref_RowValues
A reference table of valid/required combinations of Cohort, Universe, and SystemPath values for each ReportRow in LSACalculated; this is populated by insert statements in 01 Temp Reporting and Reference Tables.sql based on requirements defined in:
- Section [8 - LSACalculated Averages](08 - LSACalculated Averages.md)
- Section [9 - LSACalculated Counts](09 - LSACalculated Counts.md)
- Section [10 - LSACalculated Data Quality Counts](10 - LSACalculated Data Quality Counts.md)

| Column Name | Data Type | Notes |
| --- | --- | --- |
| RowID | int |  |
| Cohort | int |  |
| Universe | int |  |
| SystemPath | int |  |

## ref_RowPopulations
A reference table of required populations/subpopulations for each ReportRow in LSACalculated; this is populated by insert statements in 01 Temp Reporting and Reference Tables.sql based on requirements defined in:
- Section [8 - LSACalculated Averages](08 - LSACalculated Averages.md)
- Section [9 - LSACalculated Counts](09 - LSACalculated Counts.md)
- Section [10 - LSACalculated Data Quality Counts](10 - LSACalculated Data Quality Counts.md).

| Column Name | Data Type | Notes |
| --- | --- | --- |
| RowMin | int |  |
| RowMax | int |  |
| ByPath | int |  |
| ByProject | int |  |
| PopID | int |  |
| Pop1 | int |  |
| Pop2 | int |  |

## ref_PopHHTypes
A reference table of household types associated with each population; this is populated by insert statements in 01 Temp Reporting and Reference Tables.sql based on criteria defined in sections 8 and 9.

| Column Name | Data Type | Notes |
| --- | --- | --- |
| PopID | int |  |
| HHType | int |  |

