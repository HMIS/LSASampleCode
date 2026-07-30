---
layout: default
title: "LSA Data Dictionary - Files and Columns"
nav_order: 13
parent: "LSA Programming Specifications"
has_toc: true
---

# LSA Data Dictionary - Files and Columns
List numbers are clickable and hyperlinked to the relevant list.

## 1 - LSAReport

| # | Column Name | DataType | List | Nullable | Description | Max Length |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | ReportID | int |  | 0 | Unique identifier | 10 |
| 2 | ReportDate | datetime |  | 0 | The date and time that reporting procedures completed the process of generating the LSA. | 19 |
| 3 | ReportStart | date |  | 0 | User-entered report parameter | 19 |
| 4 | ReportEnd | date |  | 0 | User-entered report parameter | 19 |
| 5 |  <u>ReportCoC</u> | nvarchar(6) |  | 0 | User-entered report parameter | 6 |
| 6 | SoftwareVendor | nvarchar(50) |  | 0 | The name of the HMIS vendor  | 50 |
| 7 | SoftwareName | nvarchar(50) |  | 0 | The name of the HMIS application | 50 |
| 8 | VendorContact | nvarchar(50) |  | 0 | Optional name of a vendor contact point for HDX 2.0 staff (department or person) | 50 |
| 9 | VendorEmail | nvarchar(50) |  | 0 | Optional email for vendor contact | 50 |
| 10 | LSAScope | int | [1](LSA Data Dictionary - Lists.md#list-1) | 0 | Identifies whether LSA is systemwide (clients of all relevant continuum projects are included based on project types); project-focused (only clients of projects selected by the user generating the LSA are included); or HIC (systemwide single day) | 1 |
| 11 | LookbackDate | date |  | 0 | ReportStart - 7 years | 19 |
| 12 | NoCoC | int |  | 0 | Systemwide count of _HouseholdID_s served in continuum ES/SH/TH/RRH/PSH projects during the report period and excluded from the LSA because there is no record of the CoC in which the households were served.   | 10 |
| 13 | NotOneHoH | int |  | 0 | Systemwide count of _HouseholdID_s active in continuum ES/SH/TH/RRH/PSH projects during the report period but excluded from the LSA due to improper designation of a head of household. | 10 |
| 14 | RelationshipToHoH | int |  | 0 | Count of enrollments associated with households active during the LSA report period but excluded from the LSA due to missing/invalid _RelationshipToHoH_ values. | 10 |
| 15 | MoveInDate | int |  | 0 | Count of RRH/PSH enrollments with move-in dates recorded in HMIS that fall either prior to project entry or after project exit. | 10 |
| 16 | UnduplicatedClient | int |  | 0 | A count of distinct  **PersonalID**s in LSAPerson | 10 |
| 17 | HouseholdEntry | int |  | 0 | A count of distinct HouseholdIDs for the active cohort with enrollment dates that fall within the report period.    | 10 |
| 18 | ClientEntry | int |  | 0 | A count of distinct **EnrollmentID**s for the active cohort with enrollment dates that fall within the report period.    | 10 |
| 19 | AdultHoHEntry | int |  | 0 | A count of distinct **EnrollmentID**s for adults and heads of household in the active cohort with enrollment dates that fall within the report period.    | 10 |
| 20 | ClientExit | int |  | 0 | A count of distinct **EnrollmentID**s for the active cohort with an exit date within the report period.    | 10 |
| 21 | SSN4Digit | int |  | 0 | The total number of **PersonalID**s reported in LSAPerson where the value for *SSNDataQuality* is Approximate or partial SSN collected (2), the first five characters of *SSN* are all x and/or X, and the last 4 are a combination of digits other than '0000'.   | 10 |
| 22 | SSNNotProvided | int |  | 0 | The total number of **PersonalID**s reported in LSAPerson where the value for _SSNDataQuality_ is Client doesn’t know (8) or Client refused (9).  | 10 |
| 23 | SSNMissingOrInvalid | int |  | 0 | The total number of **PersonalID**s reported in LSAPerson where the value for *SSNDataQuality* is NOT Client doesn’t know (8) or Client refused (9); and • The value for _SSN_ is the system default value (if any) for missing SSN, or the value is not valid per SSA guidelines. | 10 |
| 24 | ClientSSNNotUnique | int |  | 0 | The total number of **PersonalID**s reported in LSAPerson where there is at least one record in HMIS for a different *PersonalID* with the same value for SSN, excluding the system default value (if any) for missing SSN. | 10 |
| 25 | DistinctSSNValueNotUnique | int |  | 0 | The total number of distinct SSN values, excluding the system default value (if any) for missing SSN, that are associated with **PersonalID**s reported in LSAPerson; and • The distinct SSN value is shared by one or more **PersonalID**s.    | 10 |
| 26 | DisablingCond | int |  | 0 | A count of distinct **EnrollmentID**s with missing or invalid values for _DisablingCondition_  | 10 |
| 27 | LivingSituation | int |  | 0 | A count of distinct  **EnrollmentID**s with missing or invalid values for _LivingSituation_  | 10 |
| 28 | LengthOfStay | int |  | 0 | A count of distinct **EnrollmentID**s with missing or invalid values for _LengthOfStay_  | 10 |
| 29 | HomelessDate | int |  | 0 | A count of distinct **EnrollmentID**s with missing or invalid values for _DateToStreetESSH_  | 10 |
| 30 | TimesHomeless | int |  | 0 | A count of distinct **EnrollmentID**s with missing or invalid values for _TimesHomelessPastThreeYears_   | 10 |
| 31 | MonthsHomeless | int |  | 0 | A count of distinct **EnrollmentID**s with missing or invalid values for _MonthsHomelessPastThreeYears_   | 10 |
| 32 | Destination | int |  | 0 | A count of distinct **EnrollmentID**s with exits in the report period with missing or invalid values for _Destination_ | 10 |

## 2 - LSAHousehold

| # | Column Name | DataType | List | Nullable | Description | Max Length |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | RowTotal | int |  | 0 | The total number of households served in continuum ES, SH, TH, RRH, and/or PSH projects during the report period with the characteristics represented by the values in each column of the row. All values must be integers > 0.  | 10 |
| 2 | Stat | int | [2](LSA Data Dictionary - Lists.md#list-2) | 0 | The household status related to continuum engagement on the first day of the earliest enrollment active during the report period. | 1 |
| 3 | ReturnTime | int | [3](LSA Data Dictionary - Lists.md#list-3) | 0 | When Stat = (2,3,4), the length of time in days between exit and the earliest active enrollment. | 3 |
| 4 | HHType | int | [4](LSA Data Dictionary - Lists.md#list-4) | 0 | The household type. | 2 |
| 5 | HHChronic | int | [43](LSA Data Dictionary - Lists.md#list-43) | 0 | Identifies household status related to long-term/chronic homelessness | 1 |
| 6 | HHVet | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Identifies whether or not the household includes a veteran. Based on VetStatus value, as determined for LSAPerson reporting.  | 1 |
| 7 | HHDisability | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Identifies whether or not the head of household or any adult member was identified as having a disabling condition on any active enrollment. | 1 |
| 8 | HHFleeingDV | int | [48](LSA Data Dictionary - Lists.md#list-48) | 0 | Identifies whether or not the head of household or any adult member was identified as fleeing domestic violence or impacted by domestic violence on any active enrollment. Based on DVStatus value, as determined for LSAPerson reporting.  | 1 |
| 9 | HoHRaceEthnicity | int | [6](LSA Data Dictionary - Lists.md#list-6) | 0 | Identifies race and ethnicity for head of household as reported in LSAPerson.  | 7 |
| 10 | HHAdult | int | [8](LSA Data Dictionary - Lists.md#list-8) | 0 | Number of people (including the head of household) 18 and older served with the head of household in the household type reflected in the HHType column.  | 1 |
| 11 | HHChild | int | [8](LSA Data Dictionary - Lists.md#list-8) | 0 | Number of people (including the head of household) under the age of 18 served with the head of household in the household type reflected in the HHType column.  | 1 |
| 12 | HHNoDOB | int | [8](LSA Data Dictionary - Lists.md#list-8) | 0 | Number of people (including the head of household) with no valid date of birth served with the head of household. | 1 |
| 13 | HHAdultAge | int | [9](LSA Data Dictionary - Lists.md#list-9) | 0 | The age groups of adult household members. The categories are mutually exclusive (a household can only fall into one group) and inclusive (every household with adults will fall into one group). | 2 |
| 14 | HHParent | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Identifies whether or not any household member has RelationshiptoHoH = 2 (child of the HoH).  | 1 |
| 15 | ESTStatus | int | [10](LSA Data Dictionary - Lists.md#list-10) | 0 | Identifies whether the household was served in ES, SH, and/or TH during the report period or prior to the report period during a period of continuous system use.  If served, the status indicates how the enrollment timeframe relates to the report period. | 2 |
| 16 | ESTGeography | int | [13](LSA Data Dictionary - Lists.md#list-13) | 0 | For households with active EST enrollments (ESTStatus > 2) during the report period, the Geography of the most recent project in which the household was enrolled. | 2 |
| 17 | ESTLivingSit | int | [14](LSA Data Dictionary - Lists.md#list-14) | 0 | For households with active EST enrollments (ESTStatus > 2) during the report period, the LivingSituation associated with the earliest active enrollment. | 3 |
| 18 | ESTDestination | int | [15](LSA Data Dictionary - Lists.md#list-15) | 0 | For households who exited an EST enrollment during the report period and were not active in an EST project as of ReportEnd (ESTStatus in (12,22)), the Destination associated with the most recent exit. | 2 |
| 19 | ESTChronic | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Population identifier specific to EST; see HHChronic. | 1 |
| 20 | ESTVet | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Population identifier specific to EST; see HHVet. | 1 |
| 21 | ESTDisability | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Population identifier specific to EST; see HHDisability. | 1 |
| 22 | ESTFleeingDV | int | [48](LSA Data Dictionary - Lists.md#list-48) | 0 | Population identifier specific to EST; see HHFleeingDV. | 1 |
| 23 | ESTAC3Plus | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Population identifier; for AC households, specifies whether or not there were at least three household members under the age of 18 served with the HoH in EST. | 1 |
| 24 | ESTAdultAge | int | [9](LSA Data Dictionary - Lists.md#list-9) | 0 | Population identifier specific to EST; see HHAdultAge. | 2 |
| 25 | ESTParent | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Population identifier specific to EST; see HHParent. | 1 |
| 26 | RRHStatus | int | [10](LSA Data Dictionary - Lists.md#list-10) | 0 | Identifies whether the household was served in RRH during the report period or in an episode of homelessness that overlaps with the report period. If served, the status indicates how the enrollment timeframe relates to the report period. | 2 |
| 27 | RRHMoveIn | int | [11](LSA Data Dictionary - Lists.md#list-11) | 0 | For households served in RRH during the report period, indicates if the household has a move-in date. If so, indicates whether it was before or during the report period. | 2 |
| 28 | RRHGeography | int | [13](LSA Data Dictionary - Lists.md#list-13) | 0 | For households with active RRH enrollments (RRHStatus > 2) during the report period, the Geography of the most recent project in which the household was enrolled. | 2 |
| 29 | RRHLivingSit | int | [14](LSA Data Dictionary - Lists.md#list-14) | 0 | For households with active RRH enrollments (RRHStatus > 2) during the report period, the LivingSituation associated with the earliest active enrollment. | 3 |
| 30 | RRHDestination | int | [15](LSA Data Dictionary - Lists.md#list-15) | 0 | For households who exited an RRH enrollment during the report period and were not active in an RRH project as of ReportEnd (RRHStatus in (12,22)), the Destination associated with the most recent exit. | 2 |
| 31 | RRHPreMoveInDays | int | [12](LSA Data Dictionary - Lists.md#list-12) | 0 | For households who were housed in RRH at any point in the report period, including those with a MoveInDate prior to ReportStart, the total number of days between EntryDate and MoveInDate for any active RRH enrollment. It differs from other day counts in that it includes all days in RRH prior to move-in, even if the household was simultaneously enrolled in ES/SH/TH/PSH. | 4 |
| 32 | RRHChronic | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Population identifier specific to RRH; see HHChronic. | 1 |
| 33 | RRHVet | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Population identifier specific to RRH; see HHVet. | 1 |
| 34 | RRHDisability | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Population identifier specific to RRH; see HHDisability. | 1 |
| 35 | RRHFleeingDV | int | [48](LSA Data Dictionary - Lists.md#list-48) | 0 | Population identifier specific to RRH; see HHFleeingDV. | 1 |
| 36 | RRHAC3Plus | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Population identifier; for AC households, specifies whether or not there were at least three household members under the age of 18 served with the HoH in RRH. | 1 |
| 37 | RRHAdultAge | int | [9](LSA Data Dictionary - Lists.md#list-9) | 0 | Population identifier specific to RRH; see HHAdultAge. | 2 |
| 38 | RRHParent | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Population identifier specific to RRH; see HHParent. | 1 |
| 39 | PSHStatus | int | [10](LSA Data Dictionary - Lists.md#list-10) | 0 | Identifies whether the household was served in PSH during the report period or in an episode of homelessness that overlaps with the report period. If served, the status indicates how the enrollment timeframe relates to the report period. | 2 |
| 40 | PSHMoveIn | int | [11](LSA Data Dictionary - Lists.md#list-11) | 0 | For households served in PSH during the report period, indicates if the household has a move-in date. If so, indicates whether it was before or during the report period. | 2 |
| 41 | PSHGeography | int | [13](LSA Data Dictionary - Lists.md#list-13) | 0 | For households with active PSH enrollments (PSHStatus > 2) during the report period, the Geography of the most recent project in which the household was enrolled. | 2 |
| 42 | PSHLivingSit | int | [14](LSA Data Dictionary - Lists.md#list-14) | 0 | For households with active PSH enrollments (PSHStatus > 2) during the report period, the LivingSituation associated with the earliest active enrollment. | 3 |
| 43 | PSHDestination | int | [15](LSA Data Dictionary - Lists.md#list-15) | 0 | For households who exited a PSH enrollment during the report period and were not active in PSH as of ReportEnd (PSHStatus in (12,22)), the Destination associated with the most recent exit. | 2 |
| 44 | PSHHousedDays | int | [16](LSA Data Dictionary - Lists.md#list-16) | 0 | From active enrollments, days spent housed in PSH. (Note that this differs from other day counts in that it does not include continuous enrollments prior to the report period.) | 3 |
| 45 | PSHChronic | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Population identifier specific to PSH; see HHChronic. | 1 |
| 46 | PSHVet | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Population identifier specific to PSH; see HHVet. | 1 |
| 47 | PSHDisability | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Population identifier specific to PSH; see HHDisability. | 1 |
| 48 | PSHFleeingDV | int | [48](LSA Data Dictionary - Lists.md#list-48) | 0 | Population identifier specific to PSH; see HHFleeingDV. | 1 |
| 49 | PSHAC3Plus | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Population identifier; for AC households, specifies whether or not there were at least three household members under the age of 18 served with the HoH in PSH. | 1 |
| 50 | PSHAdultAge | int | [9](LSA Data Dictionary - Lists.md#list-9) | 0 | Population identifier specific to PSH; see HHAdultAge. | 2 |
| 51 | PSHParent | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Population identifier specific to PSH; see HHParent. | 1 |
| 52 | ESDays | int | [12](LSA Data Dictionary - Lists.md#list-12) | 0 | Days spent in ES or SH during the report period and/or in any continuous episode of homelessness/system use prior to the report period when the household was not in TH or housed in RRH/PSH. | 4 |
| 53 | THDays | int | [12](LSA Data Dictionary - Lists.md#list-12) | 0 | Days spent in TH during the report period and/or in any continuous episode of engagement/homelessness prior to report period when the household was not in housed in RRH/PSH.  | 4 |
| 54 | ESTDays | int | [12](LSA Data Dictionary - Lists.md#list-12) | 0 | Days spent in ES/SH/TH in the report period and/or in any continuous episode of homelessness prior to report period when the household was not housed in RRH/PSH.  | 4 |
| 55 | RRHPSHPreMoveInDays | int | [12](LSA Data Dictionary - Lists.md#list-12) | 0 | For households served in RRH and/or PSH, the total number of days spent homeless in RRH/PSH in the report period or in any continuous episode of engagement/homelessness prior to report period when household was not housed in RRH/PSH and not active in ES/SH/TH. | 4 |
| 56 | RRHHousedDays | int | [12](LSA Data Dictionary - Lists.md#list-12) | 0 | Days spent housed in RRH in the report period and/or in any continuous episode of engagement/homelessness prior to report period when the household was not housed in PSH. | 4 |
| 57 | SystemDaysNotPSHHoused | int | [12](LSA Data Dictionary - Lists.md#list-12) | 0 | The total number of days spent in ES, SH, TH, RRH, or PSH (pre-move-in) in the report period or in any continuous episode of homelessness prior to the report period while not housed in PSH. | 4 |
| 58 | SystemHomelessDays | int | [12](LSA Data Dictionary - Lists.md#list-12) | 0 | The combined total number of days in the report period or in any episode of continuous homelessness that overlaps the report period when the household was in ES/SH/TH or was enrolled, but not housed in RRH/PSH (i.e. does not have a move-in date). | 4 |
| 59 | Other3917Days | int | [12](LSA Data Dictionary - Lists.md#list-12) | 0 | The total number of days in the report period or in any episode of continuous homelessness that overlaps the report period when the household was on the street or in ES/SH based on 3.917 Living Situation records for any System Path enrollment, but was not active in a continuum ES/SH/TH/RRH/PSH project. | 4 |
| 60 | TotalHomelessDays | int | [12](LSA Data Dictionary - Lists.md#list-12) | 0 | The combined total number of days in the report period or in any episode of continuous homelessness that overlaps the report period when the household was in ES/SH/TH; was enrolled, but not housed in RRH/PSH (i.e. does not have a move-in date); or on the street or in ES/SH based on 3.917 Living Situation records for any System Path enrollment and was not housed in RRH/PSH. | 4 |
| 61 | SystemPath | int | [17](LSA Data Dictionary - Lists.md#list-17) | 0 | The combinations of system use during the report period and in the contiguous periods of service prior to the report period – i.e., the ‘path’ through the system. It is not dependent on the sequence of service. System Paths are mutually exclusive. | 2 |
| 62 | ESTAIR | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Identifies households active in residence for ES/SH/TH (with 1 or more ES/SH/TH bednights in the report period). | 1 |
| 63 | RRHAIR | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Identifies households active in residence for RRH (with 1 or more RRH bednights in the report period). | 1 |
| 64 | PSHAIR | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Identifies households active in residence for PSH (with 1 or more PSH bednights in the report period). | 1 |
| 65 | RRHSOStatus | int | [10](LSA Data Dictionary - Lists.md#list-10) | 0 | Identifies whether the household was served in RRH-SO during the report period or in an episode of homelessness that overlaps with the report period. If served, the status indicates how the enrollment timeframe relates to the report period. | 2 |
| 66 | RRHSOMoveIn | int | [11](LSA Data Dictionary - Lists.md#list-11) | 0 | For households served in RRH-SO during the report period, indicates if the household has a move-in date. If so, indicates whether it was before or during the report period. | 2 |
| 67 | ReportID | int |  | 0 | Must match LSAReport.ReportID  | 10 |

## 3 - LSAPerson

| # | Column Name | DataType | List | Nullable | Description | Max Length |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | RowTotal | int |  | 0 | The total number of people served in continuum ES, SH, TH, RRH, and/or PSH projects during the report period with the characteristics represented by the values in each column of the row. All values must be integers > 0.  | 10 |
| 2 | RaceEthnicity | int | [6](LSA Data Dictionary - Lists.md#list-6) | 0 | Race and Ethnicity for all persons | 7 |
| 3 | VetStatus | int | [20](LSA Data Dictionary - Lists.md#list-20) | 0 | Veteran Status for adults; not applicable (value = -1) for children | 2 |
| 4 | DisabilityStatus | int | [20](LSA Data Dictionary - Lists.md#list-20) | 0 | Disability Status  for adults and heads of household based on records of 3.08 Disabling Condition for all active enrollments; not applicable (value = -1) for non-HoH children.   | 2 |
| 5 | CHTime | int | [21](LSA Data Dictionary - Lists.md#list-21) | 0 | For adults and heads of household, the total number of days in ES/SH or on the street in the three years prior to the client's last active date in the report period.  Based on data from active and inactive enrollments, the count of days excludes any time enrolled in continuum TH projects or housed in RRH/PSH, but otherwise includes: - Dates between entry and exit in continuum entry-exit ES and SH projects; and - Bed-night dates in night-by-night shelters; and - Dates between 3.917 DateToStreetESSH and EntryDate for ES/SH/TH/RRH/PSH projects; and  - Dates between any RRH/PSH EntryDate and the earlier of MoveInDate or ExitDate when LivingSituation is ES/SH/Street; or  -May be set based on 3.917 number of months and number of times homeless in the past three years from ES/SH/TH/RRH/PSH enrollments with entry dates in the year ending on the client's last active date.  | 3 |
| 6 | CHTimeStatus | int | [22](LSA Data Dictionary - Lists.md#list-22) | 0 | For clients with 365+ days of ES/SH/Street time in the three years prior to their last active date (CHTime), specifies whether the dates are grouped so that the client meets the time criteria for chronic homelessness. Otherwise not applicable.  | 2 |
| 7 | DVStatus | int | [23](LSA Data Dictionary - Lists.md#list-23) | 0 | DV Status for adults and heads of household based on records of 4.11 Domestic Violence for all active enrollments; not applicable (value = -1) for non-HoH children | 2 |
| 8 | ESTAgeMin | int | [18](LSA Data Dictionary - Lists.md#list-18) | 0 | The minimum age at the later of ReportStart and EntryDate for any ES/SH/TH enrollment. | 2 |
| 9 | ESTAgeMax | int | [18](LSA Data Dictionary - Lists.md#list-18) | 0 | The maximum age at the later of ReportStart and EntryDate for any ES/SH/TH enrollment. | 2 |
| 10 | HHTypeEST | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | The combination of household types in which clients were served in ES/SH/TH projects. | 4 |
| 11 | HoHEST | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | The combination of household types in which clients were served in ES/SH/TH projects as HoH. | 4 |
| 12 | AdultEST | int | [25](LSA Data Dictionary - Lists.md#list-25) | 0 | The combination of household types in which clients were served in ES/SH/TH projects as an adult. | 3 |
| 13 | AIRAdultEST | int | [25](LSA Data Dictionary - Lists.md#list-25) | 0 | The combination of household types in which adults had at least one ES/SH/TH bednight in the report period. | 3 |
| 14 | HHChronicEST | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | Population identifier; the combination of household types in which clients were served in ES/SH/TH projects in household with a chronically homeless adult or HoH. | 4 |
| 15 | HHVetEST | int | [25](LSA Data Dictionary - Lists.md#list-25) | 0 | Population identifier; the combination of household types in which clients were served in ES/SH/TH projects in household with a veteran. | 3 |
| 16 | HHDisabilityEST | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | Population identifier; the combination of household types in which clients were served in ES/SH/TH projects in household with a disabled adult or HoH. | 4 |
| 17 | HHFleeingDVEST | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | Population identifier; the combination of household types in which clients were served in ES/SH/TH projects in household with an adult or HoH fleeing domestic violence. | 4 |
| 18 | HHAdultAgeAOEST | int | [9](LSA Data Dictionary - Lists.md#list-9) | 0 | Population identifier (see list values); for AO households served in ES/SH/TH projects. | 2 |
| 19 | HHAdultAgeACEST | int | [9](LSA Data Dictionary - Lists.md#list-9) | 0 | Population identifier (see list values); for AC households served in ES/SH/TH projects. | 2 |
| 20 | HHParentEST | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | Population identifier; the combination of household types in which clients were served in ES/SH/TH projects in a household that includes at least one member whose RelationshipToHoH is 'Child'. | 4 |
| 21 | AC3PlusEST | int | [44](LSA Data Dictionary - Lists.md#list-44) | 0 | Population identifier; indicates whether or not clients were served in ES/SH/TH projects in an AC household with 3 or more household members under 18. | 2 |
| 22 | AIREST | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | The combination of household types in which clients were active in residence for ES/SH/TH (i.e., were active in the report period other than an exit on ReportStart). | 4 |
| 23 | AIRHoHEST | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | The combination of household types in which clients were active in residence for ES/SH/TH (i.e., were active in the report period other than an exit on ReportStart) as head of household. | 4 |
| 24 | RRHAgeMin | int | [18](LSA Data Dictionary - Lists.md#list-18) | 0 | The minimum age at the later of ReportStart and EntryDate for any RRH enrollment. | 2 |
| 25 | RRHAgeMax | int | [18](LSA Data Dictionary - Lists.md#list-18) | 0 | The maximum age at the later of ReportStart and EntryDate for any RRH enrollment. | 2 |
| 26 | HHTypeRRH | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | The combination of household types in which clients were served in RRH projects. | 4 |
| 27 | HoHRRH | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | The combination of household types in which clients were served in RRH projects as HoH. | 4 |
| 28 | AdultRRH | int | [25](LSA Data Dictionary - Lists.md#list-25) | 0 | The combination of household types in which clients were served in RRH projects as an adult. | 3 |
| 29 | AIRAdultRRH | int | [25](LSA Data Dictionary - Lists.md#list-25) | 0 | The combination of household types in which adults had at least one RRH bednight in the report period. | 3 |
| 30 | HHChronicRRH | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | Population identifier; the combination of household types in which clients were served in RRH projects in household with a chronically homeless adult or HoH. | 4 |
| 31 | HHVetRRH | int | [25](LSA Data Dictionary - Lists.md#list-25) | 0 | Population identifier; the combination of household types in which clients were served in RRH projects in household with a veteran. | 3 |
| 32 | HHDisabilityRRH | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | Population identifier; the combination of household types in which clients were served in RRH projects in household with a disabled adult or HoH. | 4 |
| 33 | HHFleeingDVRRH | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | Population identifier; the combination of household types in which clients were served in RRH projects in household with an adult or HoH fleeing domestic violence. | 4 |
| 34 | HHAdultAgeAORRH | int | [9](LSA Data Dictionary - Lists.md#list-9) | 0 | Population identifier (see list values); for AO households served in RRH projects. | 2 |
| 35 | HHAdultAgeACRRH | int | [9](LSA Data Dictionary - Lists.md#list-9) | 0 | Population identifier (see list values); for AC households served in RRH projects. | 2 |
| 36 | HHParentRRH | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | Population identifier; the combination of household types in which clients were served in RRH projects in a household that includes at least one member whose RelationshipToHoH is 'Child'. | 4 |
| 37 | AC3PlusRRH | int | [44](LSA Data Dictionary - Lists.md#list-44) | 0 | Population identifier; indicates whether or not clients were served in RRH projects in an AC household with 3 or more household members under 18. | 2 |
| 38 | AIRRRH | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | The combination of household types in which clients were active in residence for RRH (had at least one bed night during the report period in an RRH project). | 4 |
| 39 | AIRHoHRRH | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | The combination of household types in which clients were active in residence for RRH (had at least one bed night during the report period in an RRH project) as head of household. | 4 |
| 40 | PSHAgeMin | int | [18](LSA Data Dictionary - Lists.md#list-18) | 0 | The minimum age at the later of ReportStart and EntryDate for any PSH enrollment. | 2 |
| 41 | PSHAgeMax | int | [18](LSA Data Dictionary - Lists.md#list-18) | 0 | The maximum age at the later of ReportStart and EntryDate for any PSH enrollment. | 2 |
| 42 | HHTypePSH | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | The combination of household types in which clients were served in PSH projects. | 4 |
| 43 | HoHPSH | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | The combination of household types in which clients were served in PSH projects as HoH. | 4 |
| 44 | AdultPSH | int | [25](LSA Data Dictionary - Lists.md#list-25) | 0 | The combination of household types in which clients were served in PSH projects as an adult. | 3 |
| 45 | AIRAdultPSH | int | [25](LSA Data Dictionary - Lists.md#list-25) | 0 | The combination of household types in which adults had at least one PSH bednight in the report period. | 3 |
| 46 | HHChronicPSH | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | Population identifier; the combination of household types in which clients were served in PSH projects in household with a chronically homeless adult or HoH. | 4 |
| 47 | HHVetPSH | int | [25](LSA Data Dictionary - Lists.md#list-25) | 0 | Population identifier; the combination of household types in which clients were served in PSH projects in household with a veteran. | 3 |
| 48 | HHDisabilityPSH | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | Population identifier; the combination of household types in which clients were served in PSH projects in household with a disabled adult or HoH. | 4 |
| 49 | HHFleeingDVPSH | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | Population identifier; the combination of household types in which clients were served in PSH projects in household with an adult or HoH fleeing domestic violence. | 4 |
| 50 | HHAdultAgeAOPSH | int | [9](LSA Data Dictionary - Lists.md#list-9) | 0 | Population identifier (see list values); for AO households served in PSH projects. | 2 |
| 51 | HHAdultAgeACPSH | int | [9](LSA Data Dictionary - Lists.md#list-9) | 0 | Population identifier (see list values); for AC households served in PSH projects. | 2 |
| 52 | HHParentPSH | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | Population identifier; the combination of household types in which clients were served in PSH projects in a household that includes at least one member whose RelationshipToHoH is 'Child'. | 4 |
| 53 | AC3PlusPSH | int | [44](LSA Data Dictionary - Lists.md#list-44) | 0 | Population identifier; indicates whether or not clients were served in PSH projects in an AC household with 3 or more household members under 18. | 2 |
| 54 | AIRPSH | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | The combination of household types in which clients were active in residence for PSH (had at least one bed night during the report period in a PSH project). | 4 |
| 55 | AIRHoHPSH | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | The combination of household types in which clients were active in residence for PSH (had at least one bed night during the report period in a PSH project) as HoH. | 4 |
| 56 | RRHSOAgeMin | int | [18](LSA Data Dictionary - Lists.md#list-18) | 0 | The minimum age at the later of ReportStart and EntryDate for any RRH-SO enrollment. |  |
| 57 | RRHSOAgeMax | int | [18](LSA Data Dictionary - Lists.md#list-18) | 0 | The maximum age at the later of ReportStart and EntryDate for any RRH-SO enrollment. |  |
| 58 | HHTypeRRHSONoMI | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | The combination of household types in which clients were served in RRH-SO projects with no move-in date |  |
| 59 | HHTypeRRHSOMI | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | The combination of household types in which clients were served in RRH-SO projects with a move-in date |  |
| 60 | HHTypeES | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | The combination of household types in which clients were served in ES projects. |  |
| 61 | HHTypeSH | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | The combination of household types in which clients were served in SH projects. |  |
| 62 | HHTypeTH | int | [24](LSA Data Dictionary - Lists.md#list-24) | 0 | The combination of household types in which clients were served in TH projects. |  |
| 63 | HIV | int | [44](LSA Data Dictionary - Lists.md#list-44) | 0 | Population identifier for adults diagnosed with HIV or AIDS and active in residence during the report period |  |
| 64 | SMI | int | [44](LSA Data Dictionary - Lists.md#list-44) | 0 | Population identifier for adults with Serious Mental Illness and active in residence during the report period |  |
| 65 | SUD | int | [44](LSA Data Dictionary - Lists.md#list-44) | 0 | Population identifier for adults with a Substance Use Disorder and active in residence during the report period |  |
| 66 | ReportID | int |  | 0 | Must match LSAReport.ReportID  | 10 |

## 4 - LSAExit

| # | Column Name | DataType | List | Nullable | Description | Max Length |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | RowTotal | int |  | 0 | The total number of households served in the continuum with the characteristics represented by the values in each column of the row. All values must be integers >0. | 10 |
| 2 | Cohort | int | [27](LSA Data Dictionary - Lists.md#list-27) | 0 | Identifies which return cohort the household is in. These categories are not mutually exclusive.  | 2 |
| 3 | Stat | int | [2](LSA Data Dictionary - Lists.md#list-2) | 0 | Identifies the status of households at the start of the cohort period. | 1 |
| 4 | ExitFrom | int | [28](LSA Data Dictionary - Lists.md#list-28) | 0 | Identifies the project type from which household exited. | 1 |
| 5 | ExitTo | int | [15](LSA Data Dictionary - Lists.md#list-15) | 0 | Identifies the exit destination. | 3 |
| 6 | ReturnTime | int | [3](LSA Data Dictionary - Lists.md#list-3) | 0 | The number of days between exiting to the destination identified in ExitTo and an EntryDate for any continuum ES, SH, TH, RRH, or PSH project.  | 3 |
| 7 | HHType | int | [4](LSA Data Dictionary - Lists.md#list-4) | 0 | The household type. | 2 |
| 8 | HHVet | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Identifies whether or not the household includes a veteran. | 1 |
| 9 | HHChronic | int | [43](LSA Data Dictionary - Lists.md#list-43) | 0 | Identifies household status related to long-term/chronic homelessness | 1 |
| 10 | HHDisability | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Identifies households with a disabled adult or HoH | 1 |
| 11 | HHFleeingDV | int | [48](LSA Data Dictionary - Lists.md#list-48) | 0 | Identifies households fleeing domestic violence | 1 |
| 12 | HoHRaceEthnicity | int | [6](LSA Data Dictionary - Lists.md#list-6) | 0 | Identifies race and ethnicity for head of household.  | 7 |
| 13 | HHAdultAge | int | [9](LSA Data Dictionary - Lists.md#list-9) | 0 | The age groups of adult household members. The categories are mutually exclusive (a household can only fall into one group) and inclusive (every household with adults will fall into one group). | 2 |
| 14 | HHParent | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Identifies whether or not any household member has RelationshiptoHoH = 2 (child of the HoH) on any active enrollment in the cohort period. | 1 |
| 15 | AC3Plus | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | Identifies AC households that include 3 or more children on any active enrollment in the cohort period. | 1 |
| 16 | SystemPath | int | [17](LSA Data Dictionary - Lists.md#list-17) | 0 | The combinations of system use during the cohort period and in the continuous periods of service prior to the cohort period – i.e., the ‘path’ through the system. It is not dependent on the sequence of service. Categories are mutually exclusive. | 2 |
| 17 | ReportID | int |  | 0 | Must match LSAReport.ReportID  | 10 |

## 5 - LSACalculated

| # | Column Name | DataType | List | Nullable | Description | Max Length |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Value | int |  | 0 | The calculated report row value (average or count)  | 10 |
| 2 | Cohort | int | [29](LSA Data Dictionary - Lists.md#list-29) | 0 |  | 2 |
| 3 | Universe | int | [30](LSA Data Dictionary - Lists.md#list-30) | 0 |  | 2 |
| 4 | HHType | int | [31](LSA Data Dictionary - Lists.md#list-31) | 0 |  | 2 |
| 5 | Population | int | [32](LSA Data Dictionary - Lists.md#list-32) | 0 |  | 4 |
| 6 | SystemPath | int | [17](LSA Data Dictionary - Lists.md#list-17) | 0 |  | 2 |
| 7 | ProjectID | nvarchar(32) |  | 1 | If ReportRow between 53 and 57 and Universe = 10, must match Project.csv.ProjectID; otherwise, must be NULL.  | 32 |
| 8 | ReportRow | int | [33](LSA Data Dictionary - Lists.md#list-33) | 0 |  | 3 |
| 9 | ReportID | int |  | 0 | Must match LSAReport.ReportID  | 10 |

## 10 - Organization

| # | Column Name | DataType | List | Nullable | Description | Max Length |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | OrganizationID | nvarchar(32) |  | 0 |  | 32 |
| 2 | OrganizationName | nvarchar(200) |  | 0 |  | 200 |
| 3 | VictimServiceProvider | int | [5](LSA Data Dictionary - Lists.md#list-5) | 0 | There must be a valid (0 or 1) response in this column.  Neither NULL nor 99 are acceptable. | 2 |
| 4 | OrganizationCommonName | nvarchar(200) |  | 1 | n/a - will not be imported | 200 |
| 5 | DateCreated | datetime |  | 0 |  | 19 |
| 6 | DateUpdated | datetime |  | 0 |  | 19 |
| 7 | UserID | nvarchar(32) |  | 1 | n/a - will not be imported | 32 |
| 8 | DateDeleted | datetime |  | 1 | Must be NULL | 19 |
| 9 | ExportID | nvarchar(32) |  | 0 | Must match LSAReport.ReportID  | 32 |

## 11 - Project

| # | Column Name | DataType | List | Nullable | Description | Max Length |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | ProjectID | nvarchar(32) |  | 0 |  | 32 |
| 2 | OrganizationID | nvarchar(32) |  | 0 |  | 32 |
| 3 | ProjectName | nvarchar(200) |  | 0 |  | 200 |
| 4 | ProjectCommonName | nvarchar(200) |  | 1 | n/a - will not be imported | 200 |
| 5 | OperatingStartDate | date |  | 0 |  | 19 |
| 6 | OperatingEndDate | date |  | 1 |  | 19 |
| 7 | ContinuumProject | int |  | 0 | Must = 1 | 1 |
| 8 | ProjectType | int | [34](LSA Data Dictionary - Lists.md#list-34) | 0 |  | 2 |
| 9 | HousingType | int | [37](LSA Data Dictionary - Lists.md#list-37) | 1 |  | 1 |
| 10 | RRHSubType | int | [35](LSA Data Dictionary - Lists.md#list-35) | 1 | Must be NULL unless ProjectType = 13; if not NULL, must be in (1,2) | 1 |
| 11 | ResidentialAffiliation | int | [5](LSA Data Dictionary - Lists.md#list-5) | 1 | Must be NULL unless RRHSubType = 1; if not NULL, must be in (0,1) | 1 |
| 12 | TargetPopulation | int | [36](LSA Data Dictionary - Lists.md#list-36) | 1 |  | 1 |
| 13 | HOPWAMedAssistedLivingFac | int | [45](LSA Data Dictionary - Lists.md#list-45) | 1 |  | 1 |
| 14 | PITCount | int |  | 1 | n/a - will not be imported | 10 |
| 15 | DateCreated | datetime |  | 0 |  | 19 |
| 16 | DateUpdated | datetime |  | 0 |  | 19 |
| 17 | UserID | nvarchar(32) |  | 1 | n/a - will not be imported | 32 |
| 18 | DateDeleted | datetime |  | 1 | Must be NULL | 19 |
| 19 | ExportID | nvarchar(32) |  | 0 | Must match LSAReport.ReportID  | 32 |

## 12 - Funder

| # | Column Name | DataType | List | Nullable | Description | Max Length |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | FunderID | nvarchar(32) |  | 0 |  | 32 |
| 2 | ProjectID | nvarchar(32) |  | 0 |  | 32 |
| 3 | Funder | int | [38](LSA Data Dictionary - Lists.md#list-38) | 0 |  | 2 |
| 4 | OtherFunder | nvarchar(100) |  | 1 |  | 100 |
| 5 | GrantID | nvarchar(100) |  | 1 | n/a - will not be imported | 100 |
| 6 | StartDate | date |  | 0 |  | 19 |
| 7 | EndDate | date |  | 1 |  | 19 |
| 8 | DateCreated | datetime |  | 0 |  | 19 |
| 9 | DateUpdated | datetime |  | 0 |  | 19 |
| 10 | UserID | nvarchar(32) |  | 1 | n/a - will not be imported | 32 |
| 11 | DateDeleted | datetime |  | 1 | Must be NULL | 19 |
| 12 | ExportID | nvarchar(32) |  | 0 | Must match LSAReport.ReportID  | 32 |

## 13 - ProjectCoC

| # | Column Name | DataType | List | Nullable | Description | Max Length |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | ProjectCoCID | nvarchar(32) |  | 0 |  | 32 |
| 2 | ProjectID | nvarchar(32) |  | 0 |  | 32 |
| 3 | CoCCode | nvarchar(6) |  | 0 | Must match LSAReport. <u>ReportCoC</u> | 6 |
| 4 | Geocode | nvarchar(6) |  | 0 |  | 6 |
| 5 | Address1 | nvarchar(100) |  | 1 |  | 100 |
| 6 | Address2 | nvarchar(100) |  | 1 |  | 100 |
| 7 | City | nvarchar(50) |  | 1 |  | 50 |
| 8 | State | nvarchar(2) |  | 1 |  | 2 |
| 9 | ZIP | nvarchar(5) |  | 0 |  | 5 |
| 10 | GeographyType | int | [42](LSA Data Dictionary - Lists.md#list-42) | 0 |  | 2 |
| 11 | DateCreated | datetime |  | 0 |  | 19 |
| 12 | DateUpdated | datetime |  | 0 |  | 19 |
| 13 | UserID | nvarchar(32) |  | 1 | n/a - will not be imported | 32 |
| 14 | DateDeleted | datetime |  | 1 | Must be NULL | 19 |
| 15 | ExportID | nvarchar(32) |  | 0 | Must match LSAReport.ReportID  | 32 |

## 14 - Inventory

| # | Column Name | DataType | List | Nullable | Description | Max Length |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | InventoryID | nvarchar(32) |  | 0 |  | 32 |
| 2 | ProjectID | nvarchar(32) |  | 0 |  | 32 |
| 3 | CoCCode | nvarchar(6) |  | 0 | Must match LSAReport. <u>ReportCoC</u> | 6 |
| 4 | HouseholdType | int | [39](LSA Data Dictionary - Lists.md#list-39) | 0 |  | 1 |
| 5 | Availability | int | [40](LSA Data Dictionary - Lists.md#list-40) | 1 |  | 1 |
| 6 | UnitInventory | int |  | 0 |  | 10 |
| 7 | BedInventory | int |  | 0 |  | 10 |
| 8 | CHVetBedInventory | int |  | 0 |  | 10 |
| 9 | YouthVetBedInventory | int |  | 0 |  | 10 |
| 10 | VetBedInventory | int |  | 0 |  | 10 |
| 11 | CHYouthBedInventory | int |  | 0 |  | 10 |
| 12 | YouthBedInventory | int |  | 0 |  | 10 |
| 13 | CHBedInventory | int |  | 0 |  | 10 |
| 14 | OtherBedInventory | int |  | 0 |  | 10 |
| 15 | ESBedType | int | [41](LSA Data Dictionary - Lists.md#list-41) | 1 |  | 1 |
| 16 | InventoryStartDate | date |  | 0 |  | 19 |
| 17 | InventoryEndDate | date |  | 1 |  | 19 |
| 18 | DateCreated | datetime |  | 0 |  | 19 |
| 19 | DateUpdated | datetime |  | 0 |  | 19 |
| 20 | UserID | nvarchar(32) |  | 1 | n/a - will not be imported | 32 |
| 21 | DateDeleted | datetime |  | 1 | Must be NULL | 19 |
| 22 | ExportID | nvarchar(32) |  | 0 | Must match LSAReport.ReportID  | 32 |

## 15 - HMISParticipation

| # | Column Name | DataType | List | Nullable | Description | Max Length |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | HMISParticipationID | nvarchar(32) |  | 0 |  | 32 |
| 2 | ProjectID | nvarchar(32) |  | 0 | Must match a ProjectID in Project.csv | 32 |
| 3 | HMISParticipationType | int | [47](LSA Data Dictionary - Lists.md#list-47) | 0 |  | 1 |
| 4 | HMISParticipationStatusStartDate | datetime |  | 0 |  | 19 |
| 5 | HMISParticipationStatusEndDate | datetime |  | 1 |  | 19 |
| 6 | DateCreated | datetime |  | 0 |  | 19 |
| 7 | DateUpdated | datetime |  | 0 |  | 19 |
| 8 | UserID | nvarchar(32) |  | 1 | n/a - will not be imported | 32 |
| 9 | DateDeleted | datetime |  | 1 | Must be NULL | 19 |
| 10 | ExportID | nvarchar(32) |  | 0 | Must match LSAReport.ReportID  | 32 |

## 16 - Affiliation

| # | Column Name | DataType | List | Nullable | Description | Max Length |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | AffiliationID | nvarchar(32) |  | 0 |  | 32 |
| 2 | ProjectID | nvarchar(32) |  | 0 | Must match a ProjectID in Project.csv where RRHSubType = 1 | 32 |
| 3 | ResProjectID | nvarchar(32) |  | 0 | Must match a ProjectID in Project.csv where RRHSubType is null or 0 | 32 |
| 4 | DateCreated | datetime |  | 0 |  | 19 |
| 5 | DateUpdated | datetime |  | 0 |  | 19 |
| 6 | UserID | nvarchar(32) |  | 1 | n/a - will not be imported | 32 |
| 7 | DateDeleted | datetime |  | 1 | Must be NULL | 19 |
| 8 | ExportID | nvarchar(32) |  | 0 | Must match LSAReport.ReportID  | 32 |

