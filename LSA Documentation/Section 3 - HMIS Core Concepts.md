# HMIS Business Logic: Core Concepts

The universe of HMIS project, client, and enrollment data used to generate the LSA is broad in scope. It uses systemwide enrollment data for HMIS-participating continuum ES, SH, TH, RRH, and PSH projects and includes project descriptor data for OPH projects. It may include enrollments with exit dates and projects with operating end dates as far back as the LookbackDate (ReportStart – 7 years).

The HMIS data required for the LSA are shown below. The fields relevant to the business logic of the report are listed.

**hmis_Affiliation**

**hmis_HMISParticipation**

**hmis_Client**

PersonalID

SSN

SSNDataQuality

DOB

DOBDataQuality

Race and Ethnicity

VeteranStatus

**hmis_Enrollment**

EnrollmentID

PersonalID

ProjectID

EntryDate

HouseholdID

RelationshipToHoH

EnrollmentCoC

LivingSituation

RentalSubsidyType

LengthOfStay

PreviousStreetESSH

DateToStreetESSH

TimesHomelessPastThreeYears

MonthsHomelessPastThreeYears

DisablingCondition

MoveInDate

**hmis_HealthAndDV**

EnrollmentID

InformationDate

DomesticViolenceVictim

CurrentlyFleeing

**hmis_Services**

EnrollmentID

DateProvided (BedNightDate)

RecordType

**hmis_Exit**

EnrollmentID

ExitDate

Destination

DestinationSubsidyType

**hmis_ProjectCoC**

ProjectID

CoCCode

GeographyType

**hmis_Project**

ProjectID

OperatingEndDate

ContinuumProject

ProjectType

RRHSubTypeMethod

**hmis_Organization**

**hmis_Funder**

**hmis_Inventory**

EnrollmentID

InformationDate

DisabilityType

DisabilityResponse

IndefiniteAndImpairs

**hmis_Disabilities**

The business logic in this section defines core concepts: report parameters, reporting cohorts, basic criteria for record selection, and identification of household types in various contexts.

Any given enrollment may be relevant for a variety of reporting purposes, each of which has specific criteria, but there is a common set of criteria that applies to the identification of relevant HMIS data in every aspect of LSA reporting.

There are also adjustments to HMIS move-in and exit dates that may be required to resolve conflicts with other HMIS data that apply regardless of how a particular enrollment is being used for reporting.

To simplify subsequent steps and to reduce repetition, the logic associated with selection of valid enrollments and resolution of data conflicts is described here for all HMIS _HouseholdID_s active on or after LookbackDate in HMIS-participating continuum ES/SH/TH/RRH/PSH projects that meet the core criteria.

As described, it is a process that creates records in two ‘temporary tables’ – tlsa_HHID and tlsa_Enrollment. They are highly de-normalized and include both HMIS data (e.g., _ProjectID_) and calculated variables (e.g., **HHType**) that are set once in these tables and referenced repeatedly in subsequent steps.

- A record is created in tlsa_HHID for each _HouseholdID_ with columns for frequently used data, including effective/adjusted move-in and exit dates where relevant (section 3.3).
- A record is created in tlsa_Enrollment for each validated _EnrollmentID_ with columns for frequently used data, including effective/adjusted move-in and exit dates where relevant (section 3.4).

Household type is determined by the ages of household members. The calculation of age and household type is context-dependent – some processes require household type based on ages at project entry; others require household type based on age at the later of project entry or the start of a given cohort period. As described:

There are multiple age columns in tlsa_Enrollment (**EntryAge**, **ActiveAge**, etc.) and multiple household type columns in tlsa_HHID (**EntryHHType**, **ActiveHHType**, etc.). Descriptions of business logic associated with age and household type processes are not repeated in subsequent sections.

hmis_Client

Report Parameters

tlsa_CohortDates

lsa_Report

tlsa_HHID

hmis_Exit

hmis_Enrollment

hmis_Services

hmis_Project

hmis_Exit

hmis_Disabilities

hmis_Enrollment

hmis_HealthAndDV

tlsa_Enrollment

Insert parameters to LSAReport

_HouseholdIDs_ active –LookbackDate -ReportEnd

Get cohort start/end dates

Associated enrollments

Get enrollment ages

Set household types

## Report Parameters and Metadata (lsa_Report)

lsa_Report

Report Parameters

Vendor Info

User-entered report parameters are included in LSAReport for upload to HDX 2.0. When they are applied in subsequent steps, their source is represented in graphics using lsa_Report. References to individual report parameters are always underlined – e.g., ReportStart – in descriptions of business logic.

### Relevant Data

#### Source

User-entered and vendor-provided data.

#### Target

| LSAReport |
| --- |
| ReportID |
| ReportStart |
| ReportEnd |
| ReportCoC |
| LSAScope |
| SoftwareVendor |
| SoftwareName |
| VendorContact |
| VendorEmail |

### Logic

#### ReportID

**ReportID** is a system-generated integer that distinctly identifies an instance of LSA output and is repeated in each of the CSV files to confirm that they were produced together.

#### ReportStart

For the annual year-long LSA submitted to HUD, the report start date must be the first day (October 1) of the fiscal year for which the LSA is being produced.

For submission as the HIC, the report start date must be the date of the count.

It must be possible for a user to select any date on or after October 1, 2018.

The data type for the column is date; values should be formatted as ‘yyyy-mm-dd’.

#### ReportEnd

For the annual year-long LSA submitted to HUD, this must be the last day (September 30) of the fiscal year for which the LSA is being produced.

For submission as the HIC, this must be the same as ReportStart, i.e. the date of the count.

It must be possible for a user to select any date >= ReportStart. However, since the LSA is resource-intensive, HMIS vendors may limit the ability of users to specify date ranges beyond one year in length.

The phrase “report period,” in the context of this document, refers to the period between ReportStart and ReportEnd, inclusive of those two dates.

The data type for the column is date; values should be formatted as ‘yyyy-mm-dd’.

#### ReportCoC

**CoC Code** (ReportCoC) – The HUD-assigned code identifying the continuum for which the LSA is being produced. Users must be able to select one CoC from a drop-down list that includes all _2.03 Continuum of Care Codes_ for which they are authorized to generate the LSA.

The column is limited to six characters – e.g., ‘XX-999’ – and must match the HDX 2.0 value for the CoC for which the user is uploading data.

#### LSAScope

LSAScope is a user-selected report parameter.

| LSAScope Values | Category |
| --- | --- |
| 1   | Systemwide |
| 2   | Project-focused |
| 3   | HIC |

**Systemwide** – LSA reporting procedures must identify projects relevant to the LSA based on project types and business logic defined by this document without requiring the user to select individual projects. (**LSAScope** must be 1 for submissions to HUD.)

**Project-Focused** – Users must be able to specify a subset of one or more HMIS projects such that clients included in reporting are limited to those served in the selected projects. (Reporting on system use and chronic homelessness uses systemwide data regardless of LSAScope.) Projects available to select should be limited to:

- Continuum projects (_ContinuumProject_ = 1)
- ES, SH, TH, RRH, and PSH projects (_ProjectType_ in (0,1,2,3,8,13))

**HIC** – The HIC is a single day systemwide report.

#### User-Selected Projects (for Project-Focused LSA)

For a project-focused LSA, the HMIS _ProjectID_s for the projects selected by the user are also a parameter. This parameter is applied when selecting PDDE data for export.

#### SoftwareVendor and SoftwareName

**SoftwareVendor** and **SoftwareName** must be hard-coded to ensure that the values are consistent across all HMIS implementations. Both columns are strings; they may not exceed 50 characters and may not include any of the following: &lt; &gt; \[ \] { }.

#### VendorContact and VendorEmail

Vendors may elect to provide contact information or to populate these columns with ‘n/a.’ In either case, **VendorContact** and **VendorEmail** must be hard-coded by the vendor. Both columns are strings; they may not exceed 50 characters and may not include any of the following: &lt; &gt; \[ \] { }.

## LSA Reporting Cohorts and Dates (tlsa_CohortDates)

lsa_Report

tlsa_CohortDates

A ‘cohort’ refers to a group of clients and/or households who meet specific criteria and were served in a given time frame.

The user-entered LSA report period – ReportStart to ReportEnd – defines the **active cohort**, which includes people and households served in continuum ES, SH, TH, RRH, and PSH projects during that time frame. Reporting in LSAPerson and LSAHousehold is limited to the active cohort.

The LSA is not limited to the active cohort, however; it includes reporting for multiple time frames and cohorts.

LSAExit is limited to reporting on three **exit cohorts**, which include households who:

- Exited from a continuum ES, SH, TH, RRH, or PSH project during three cohort time periods; and
- Were not enrolled in any continuum ES, SH, TH, RRH, or PSH project in the 14 days after exit.

Finally, there are four **point-in-time cohorts**, which include people and households active in residence (i.e., with a bed night) in continuum ES, SH, TH, RRH, or PSH projects on four specific dates during the report period. Reporting on these cohorts is limited to counts in LSACalculated.

This section defines the logic associated with deriving the cohort periods based on ReportStart and ReportEnd.

### Relevant Data

#### Source

| lsa_Report |
| --- |
| ReportStart |
| ReportEnd |

#### Target

Cohorts and cohort periods are referenced in subsequent steps using an intermediate data construct/temporary table called tlsa_CohortDates.

| tlsa_CohortDates |
| --- |
| Cohort |
| CohortStart |
| CohortEnd |

### Logic

Point-in-time cohorts are only included if the relevant date falls between ReportStart and ReportEnd and **LSAScope** <> 3 (HIC). Exit cohorts are included only if **LSAScope** <> 3.

| Cohort | Cohort Type | CohortStart | CohortEnd |
| --- | --- | --- | --- |
| \-2 | Exit Minus 2 | (ReportStart - 2 years) | (ReportEnd - 2 years) |
| \-1 | Exit Minus 1 | (ReportStart - 1 year) | (ReportEnd – 1 year) |
| 0   | Exit 0 | ReportStart | If \[ReportEnd – 6 months\] <= ReportStart, use ReportEnd<br><br>Otherwise, \[ReportEnd – 6 months\] |
| 1   | Active | ReportStart | ReportEnd |
| 10  | Point in time 10/31 | October 31 of ReportStart year | \= **CohortStart** |
| 11  | Point in time 1/31 | January 31 of ReportEnd year | \= **CohortStart** |
| 12  | Point in time 4/30 | April 30 of ReportEnd year | \= **CohortStart** |
| 13  | Point in time 7/31 | July 31 of ReportEnd year | \= **CohortStart** |

## HMIS Household Enrollments (tlsa_HHID)

hmis_HMISParticipation

lsa_Report

tlsa_HHID

hmis_Exit

hmis_Enrollment

hmis_Services

hmis_Project

Not all the _HouseholdID_s identified in this step will ultimately be used by LSA reporting processes. Subsequent steps define the specific criteria associated with each step. However, all subsequent steps are based on the following assumptions:

- Unless otherwise specified, all LSA reporting<sup>[\[1\]](#footnote-2)</sup> is limited to enrollments that meet the core criteria defined in this step; and
- Any reference to **EntryDate**, **MoveInDate** or **ExitDate** (in bold) as a property of tlsa_HHID or tlsa_Enrollment is a reference to the effective/adjusted entry, exit and move-in dates consistent with the logic in this step.
- References to _EntryDate_, _MoveInDate_ and _ExitDate_ (italicized) are to raw HMIS data as entered.

### Relevant Data

#### Source

| **lsa_Report** |
| --- |
| ReportCoC |
| LookbackDate |
| ReportEnd |
| **hmis_Organization** |
| VictimServiceProvider |
| **hmis_Project** |
| ContinuumProject |
| ProjectID |
| ProjectType |
| RRHSubType |
| OperatingStartDate |
| OperatingEndDate |

| **hmis_HMISParticipation** |
| --- |
| HMISParticipationType |
| HMISParticipationStatusStartDate |
| HMISParticipationStatusEndDate |

| **hmis_Enrollment** |
| --- |
| EnrollmentID |
| PersonalID |
| ProjectID |
| HouseholdID |
| EntryDate |
| RelationshipToHoH |
| EnrollmentCoC |
| MoveInDate |
| **hmis_Services** |
| EnrollmentID |
| _BedNightDate_ (_DateProvided_ where _RecordType_ = 200) |
| **hmis_Exit** |
| EnrollmentID |
| ExitDate |

#### Target

The logic associated with values for columns with names in **bold** below is described in this step. The business logic associated with other columns is described in subsequent steps.

| **tlsa_HHID** | **Column Description** |
| --- | --- |
| **HouseholdID** | Distinct _HouseholdIDs_ served in continuum ES/SH/TH/RRH/PSH projects between LookbackDate and ReportEnd |
| **HoHID** | The unique identifier for the head of household – i.e., the _PersonalID_ from the enrollment associated with the _HouseholdID_ where _RelationshipToHoH_ = 1. |
| **EnrollmentID** | From hmis_Enrollment |
| **ProjectID** | From hmis_Enrollment |
| **LSAProjectType** | From hmis_Project _ProjectType_ and _RRHSubType_ columns.If _ProjectType_ = 13 and _RRHSubType_ \= 2, **LSAProjectType** = 13<br><br>If _ProjectType_ = 13 and _RRHSubType_ \= 1, **LSAProjectType** = 15<br><br>Otherwise, LSAProjectType = hmis_Project._ProjectType_. |
| **EntryDate** | The effective entry date for the enrollment, which may differ from the recorded _EntryDate_ in HMIS for night-by-night ES enrollments. (See logic section for **EntryDate** below.) |
| **MoveInDate** | The move-in date for RRH/PSH enrollments, which may differ from the recorded _MoveInDate_ in HMIS. (See logic section for **MoveInDate** below.) |
| **ExitDate** | The effective exit date for the HoH enrollment, which may differ from the _ExitDate_ recorded in hmis_Exit. (See logic section for **ExitDate** below.) |
| **LastBedNight** | If _ProjectType_ = 1, the latest _BedNightDate_ for the HoH on or before ReportEnd |
| EntryHHType | For all household enrollments, household type based on household member ages as of their **EntryDate** |
| ActiveHHType | For all household enrollments, household type as the enrollment might be relevant to reporting on the active cohort. For those active in the report period, this is based on household member ages as of the later of **EntryDate** and ReportStart. For inactive enrollments, which may be relevant to reporting on system use or homelessness prior to the report period, this is always the **EntryHHType**. |
| Exit1HHType | For all household enrollments, household type as the enrollment might be relevant to reporting on exit cohort -1. For household enrollments where **ExitDate** occurs in the cohort period, household type based on ages as of the later of **EntryDate** and **CohortStart.** For enrollments before and after the cohort period, which may be relevant to reporting on system use or returns, this is always the **EntryHHType**. |
| Exit2HHType | For all household enrollments, household type as the enrollment might be relevant to reporting on exit cohort -2. For household enrollments where **ExitDate** occurs in the cohort period, household type based on ages as of the later of **EntryDate** and **CohortStart.** For enrollments before and after the cohort period, which may be relevant to reporting on system use or returns, this is always the **EntryHHType**. |
| ExitCohort | Identifies the cohort period in which the **ExitDate** occurs, if any; set in section [7.1 Identify Qualifying Exits in Exit Cohort Periods](#_Identify_Qualifying_Exits) |
| **ExitDest** | Exit destination, if relevant |
| Active | Identifies **HouseholdID**s included in the active cohort |
| AIR | Active in residence - Identifies the subset of active enrollments with at least one bed night in the report period |
| PITOctober | Identifies the subset of AIR enrollments with a bed night on October 31 (if within the report period) |
| PITJanuary | Identifies the subset of AIR enrollments with a bed night on January 31 (if within the report period) |
| PITApril | Identifies the subset of AIR enrollments with a bed night on April 30 (if within the report period) |
| PITJuly | Identifies the subset of AIR enrollments with a bed night on July 31 (if within the report period) |
| ExitCohort | Identifies the exit cohort period, if any, in which the enrollment is relevant; set in section [7.1 Identify Qualifying Exits in Exit Cohort Periods](#_Identify_Qualifying_Exits) |
| HHChronic | Identifies households with a chronically homeless HoH or adult or other specific patterns of long-term homelessness.<br><br>See section [5.12 Set Population Identifiers for Active HMIS Households](#_Set_Population_Identifiers_5) |
| HHVet | Identifies households with one or more veteran adults<br><br>See section [5.12 Set Population Identifiers for Active HMIS Households](#_Set_Population_Identifiers_5) |
| HHDisability | Identifies households with a disabled HoH or other adult<br><br>See section [5.12 Set Population Identifiers for Active HMIS Households](#_Set_Population_Identifiers_5) |
| HHFleeingDV | Identifies households fleeing or otherwise impacted by domestic violence<br><br>See section [5.12 Set Population Identifiers for Active HMIS Households](#_Set_Population_Identifiers_5) |
| HHAdultAge | Identifies age-related populations (e.g., Senior 55+, Parenting Youth 18-24, Non-Veteran 25+)<br><br>See section [5.12 Set Population Identifiers for Active HMIS Households](#_Set_Population_Identifiers_5) |
| HHParent | Identifies households where at least one household member has a _RelationshipToHoH_ of ‘Child’ (2)<br><br>See section [5.12 Set Population Identifiers for Active HMIS Households](#_Set_Population_Identifiers_5) |
| AC3Plus | Identifies AC households with 3 or more household members under 18<br><br>See section [5.12 Set Population Identifiers for Active HMIS Households](#_Set_Population_Identifiers_5) |

### Logic

#### HMIS Data Requirements and Assumptions

**The HMIS Lead must identify and merge duplicate records for individual clients prior to generating the LSA.** The production of an unduplicated count of people experiencing homelessness is a fundamental purpose of HMIS. As such, it has been a requirement of every version of the HMIS Data Standards since March 2010 that an HMIS application must have functionality that allows the HMIS Lead to de-duplicate records with different _PersonalID_s for the same client. For the LSA, it is particularly critical that HMIS Leads _utilize_ this functionality; it is not otherwise possible to produce accurate longitudinal and/or systemwide reporting.

**Unless otherwise specified by this document, reporting procedures must exclude any data which is inconsistent with the HMIS Data Standards and HMIS CSV Specifications.** Both the programming specifications and sample code assume the existence of relational database tables with properties consistent with the HMIS CSV specifications, to include column names, primary keys, foreign keys, and column values limited to those defined for HMIS. Referential integrity is also assumed. There are defined requirements for addressing a limited number of data issues in LSA reporting; however, it is outside the scope of this document to anticipate every potential inconsistency. In systems that – for whatever reason – allow users to create records that are inconsistent with HMIS requirements, it is the responsibility of the vendor to be aware of these exceptions and exclude the records from LSA reporting.

**Deleted data are never used for reporting.** Any record marked as deleted must be excluded from LSA reporting.

**Only data associated with valid enrollments in continuum projects are included in the LSA.** A valid enrollment has, at a minimum, an _EntryDate_, a _PersonalID_, a _ProjectID_, a _HouseholdID_, a valid _RelationshipToHoH_, and an _EnrollmentCoC_ associated with the head of household’s _EnrollmentID_. Data not associated with a valid enrollment – including bed nights in systems that allow users to create a record of a bed night without a valid enrollment – are excluded from the LSA.

**For any given _HouseholdID_, there must be exactly one enrollment record where _RelationshipToHoH_ = 1**. If the HMIS allows users to create enrollments with no designated HoH and/or with more than one designated HoH:

- Those enrollments will be excluded from LSA reporting.
- A count of enrollments with <> 1 HoH will be included in LSAReport.**NotOneHoH**.
- CoCs may upload LSA file sets where **NotOneHoH** > 0 to HDX 2.0 for local use and review.
- CoCs may not submit LSA file sets where **NotOneHoH** > 0 to HUD for use in the AHAR. Invalid HoH data must be corrected and a new LSA file set must be uploaded.

**A head of household must be present for the duration of a project stay.** Entry and exit dates for household members will be adjusted if they fall outside of the period between the effective **EntryDate** and **ExitDate** (if any) for the head of household.

**An _ExitDate_ must be at least one day later than the _EntryDate_.** Enrollments with a duration of less than a day will be excluded from LSA reporting.

**Households with RRH enrollments in the report period where _MoveInDate_ is equal to the _ExitDate_ will be counted as housed in RRH.** It is consistent with the RRH model that a project might provide services and/or financial assistance to assist a household in obtaining permanent housing that do not continue past the date that the household moves in. As such, a household is considered housed in RRH on their _MoveInDate_ even if it coincides with the _ExitDate_. This is the only circumstance under which a bed night is counted for an _ExitDate_.

**Households with PSH enrollments in the report period where _MoveInDate_ is equal to the _ExitDate_ will not be counted as housed in PSH.** It is not consistent with the PSH model, which includes long-term residential services, that a household could be considered housed by the project with an exit on the move-in date.

**Regardless of entry, move-in, exit, and/or bed nights recorded in HMIS, anything that occurs outside of date range in which a project is both operating and participating in HMIS is disregarded.** Except for exits, anything that occurs on a project’s operating end date and/or HMIS participation end date is disregarded. Enrollments that span changes in a project’s status will be truncated.

**A night-by-night ES enrollment begins with a bed night.** For any enrollment where there is not a record of a bed night on the entry date:

- The effective **EntryDate** for the enrollment will be the date of the earliest bed night (after the recorded _EntryDate_) associated with the enrollment.
- _LivingSituation_ will be reported as unknown, if applicable.

**For night-by-night ES enrollments, any _ExitDate_ must be one day after the last recorded bed night.** For any exit where there is not a record of a bed night for the preceding date:

- LSA reporting procedures will use an effective exit date of \[last bed night + 1 day\].
- _Destination_ will be reported as unknown, if applicable.

**Night-by-night ES clients are to be auto-exited after an extended period without a bed night.** For any night-by-night ES enrollment where there is no record of an exit and there is no record of a bed night in the 90 days ending on ReportEnd:

- LSA reporting procedures will use an effective exit date of \[last bed night + 1 day\].
- _Destination_ will be reported as unknown, if applicable.

#### HMISStart and HMISEnd

**HMISStart** refers to the most recent HMISParticipation._HMISParticipationStatusStartDate_ for the enrollment’s _ProjectID_ where _HMISParticipationType_ = 1 and:

- HMISParticipationStatusStartDate <= ReportEnd; and
- ExitDate is null or > HMISParticipationStatusStartDate; and
- HMISParticipationStatusEndDate is null or (> EntryDate AND > LookbackDate).

**HMISEnd** refers to the _HMISParticipationStatusEndDate_ associated with **HMISStart;** dates after ReportEnd should be evaluated as NULL**.**

#### BedNightDates, FirstBedNight and LastBedNight

For night-by-night shelter (_ProjectType_ = 1) enrollments, a Services record where _RecordType_ = 200 is counted as a _BedNightDate_ if _DateProvided_ is:

- \>= LookbackDate; and
- \>=OperatingStartDate; and
- \>= HMISStart; and
- \>=_EntryDate_; and
- <= ReportEnd; and
- <_ExitDate_ (if not null); and
- < _OperatingEndDate_ (if not null); and
- < **HMISEnd** (if not null).

**FirstBedNight** is the earliest _BedNightDate_ associated with an enrollment.

**LastBedNight** is the latest _BedNightDate_ associated with an enrollment.

#### Record Selection

Potentially relevant _HouseholdID_s are those associated with one or more project enrollments that meet the following criteria.

- _VictimServiceProvider =_ 0
- The project type is relevant to the LSA:
- _ProjectType_ in (0,1,2,3,8); or
- _ProjectType_ = 13 and Project._RRHSubType_ in (1,2)
- ContinuumProject \= 1
- The project was operating during the relevant period:
- _OperatingStartDate_ <= ReportEnd
- _OperatingEndDate_ is NULL; or
- _OperatingEndDate_ \> LookbackDate and >_OperatingStartDate_
- _RelationshipToHoH_ = 1
- _EnrollmentCoC_ = ReportCoC
- There is no other enrollment record for the _HouseholdID_ where _RelationshipToHoH_ = 1
- _EntryDate_ <= ReportEnd
- EntryDate < _OperatingEndDate_ or _OperatingEndDate_ is NULL
- _EntryDate_ < **HMISEnd** or **HMISEnd** is NULL
- _ExitDate_ is NULL or:
- _ExitDate_ > LookbackDate; and
- _ExitDate_ > _EntryDate_; and
- _ExitDate_ > **HMISStart**; and
- _ExitDate_ > _OperatingStartDate_
- If_ProjectType_ = 1, there is at least one _BedNightDate_ record for the enrollment (see criteria above).

#### EntryDate

To be included in the LSA, an enrollment must have an _EntryDate_ that meets the following criteria:

- <= ReportEnd
- < _OperatingEndDate_ (if not null)
- < **HMISEnd** (if not null)

Under some circumstances, the LSA will use an adjusted **EntryDate**:

| Priority | Criteria | Effective Entry Date |
| --- | --- | --- |
| 1   | _ProjectType_ = 1 | **FirstBedNight** |
| 2   | _EntryDate_ >= **HMISStart**; and<br><br>_EntryDate_ >= _OperatingStartDate_ | _EntryDate_ |
| 3   | (any other) | The later of _OperatingStartDate/_**HMISStart** |

#### MoveInDate

The _MoveInDate_ is set for the head of household from the HMIS enrollment record only if it occurs on or before the end of the report period and is logically consistent with the project type, the head of household’s entry/exit dates, and the project’s operating/HMIS participation dates. Under some circumstances, the LSA will use an adjusted **MoveInDate**:

| Priority | Criteria | Effective Move-In Date |
| --- | --- | --- |
| 1   | _ProjectType_ not in (3,13) | NULL |
| 1   | _MoveInDate_ < _EntryDate_ | NULL |
| 1   | _MoveInDate_ > Exit._ExitDate_ | NULL |
| 1   | _MoveInDate_ = Exit._ExitDate_ and _ProjectType_ = 3 | NULL |
| 1   | _MoveInDate_ > ReportEnd | NULL |
| 1   | _MoveInDate_ >= _OperatingEndDate_ or **HMISEnd** | NULL |
| 2   | _MoveInDate_ is NULL or<br><br>_(MoveInDate_ \>= **HMISStart** _and MoveInDate_ \>= _OperatingStartDate)_ | _MoveInDate_ |
| 3   | (any other) | The later of _OperatingStartDate_/**HMISStart** |

#### ExitDate

If the recorded _ExitDate_ (or lack thereof) associated with an enrollment is inconsistent with other data, reporting must be based on an adjusted **ExitDate** consistent with the logic below. If applicable, _Destination_ for these enrollments is reported as ‘Data missing or invalid’ (99).

- An _ExitDate_ \> ReportEnd should be evaluated as NULL prior to making any adjustments.
- Any adjustment that results in an effective **ExitDate** > ReportEnd should be evaluated as NULL.

| Priority | Condition | Effective Exit Date |
| --- | --- | --- |
| 1   | LastBedNight = ReportEnd | NULL |
| --- | --- | --- |
| 2   | \[**LastBedNight** + 90 days\] <= ReportEnd | \[**LastBedNight** \+ 1 day\] |
| 2   | **LSAProjectType** \= 1 and _ExitDate_ < ReportEnd | \[**LastBedNight** \+ 1 day\] |
| 3   | **ProjectType** = 13 and _ExitDate_ = _MoveInDate_ and _ExitDate_ = ReportEnd | NULL |
| 4   | **ProjectType** = 13 and _ExitDate_ = _MoveInDate_ | \[_MoveInDate_ + 1 day\] |
| 5   | _OperatingEndDate_ and/or **HMISEnd** _<=_ ReportEnd; and<br><br>_ExitDate_ is null or _ExitDate >_ (the earlier of **HMISEnd**/_OperatingEndDate_) | The earlier of _OperatingEndDate_/**HMISEnd** |
| 6   | (other) | _ExitDate_ |

#### ExitDest

The LSA includes reporting on exit destinations for the active and exit cohorts. Destination for inactive enrollments may also be relevant to system engagement status for the active and exit cohorts. If the recorded _ExitDate_ (or lack thereof) associated with an enrollment is inconsistent with other data, (see **ExitDate** above), destination is always reported as unknown where relevant. The only exception to this is for RRH exits when the recorded exit date is the same as the **MoveInDate** – the recorded destination is valid under those circumstances.

**ExitDest** should be set based on the first of the criteria below met by the associated data:

- If tlsa_HHID.**ExitDate** is null, **ExitDest** = -1
- If tlsa_HHID.**ExitDate** <> hmis_Exit._ExitDate_ and hmis_Exit._ExitDate_ <> tlsa_HHID.**MoveInDate**, **ExitDest** = 99
- If tlsa_HHID.**ExitDate** is not null and hmis_Exit._Destination_ is null, **ExitDest** = 99
- If hmis_Exit._Destination_ in (8,9), set **ExitDest** = 98
- If hmis_Exit._Destination_ in (17,30,99), set **ExitDest** = 99
- If hmis_Exit._Destination_ \= 435 and hmis_Exit._DestinationSubsidyType_ is null, set **ExitDest** \= 99
- If hmis_Exit._Destination_ \= 435, set **ExitDest** = hmis_Exit._DestinationSubsidyType_
- Otherwise, set **ExitDest** to hmis_Exit._Destination_

| Value | Destination |
| --- | --- |
| \-1 | Not applicable |
| 24  | Deceased |
| 98  | Data not provided by client |
| 99  | Data missing or invalid |
| 101 | Emergency shelter, including hotel or motel paid for with emergency shelter voucher, Host Home shelter |
| 116 | Place not meant for habitation (e.g., a vehicle, an abandoned building, bus/train/subway station/airport or anywhere outside) |
| 118 | Safe Haven |
| 204 | Psychiatric hospital or other psychiatric facility |
| 205 | Substance abuse treatment facility or detox center |
| 206 | Hospital or other residential non-psychiatric medical facility |
| 207 | Jail, prison, or juvenile detention facility |
| 215 | Foster care home or foster care group home |
| 225 | Long-term care facility or nursing home |
| 302 | Transitional housing for homeless persons (including homeless youth) |
| 312 | Staying or living with family, temporary tenure (e.g. room, apartment, or house) |
| 313 | Staying or living with friends, temporary tenure (e.g. room, apartment, or house) |
| 314 | Hotel or motel paid for without emergency shelter voucher |
| 327 | Moved from one HOPWA funded project to HOPWA TH |
| 329 | Residential project or halfway house with no homeless criteria |
| 332 | Host Home (non-crisis) |
| 410 | Rental by client, no ongoing housing subsidy |
| 411 | Owned by client, no ongoing housing subsidy |
| 419 | Rental by client - VASH housing subsidy |
| 420 | Rental by client - Other ongoing subsidy |
| 421 | Owned by client, with ongoing housing subsidy |
| 422 | Staying or living with family, permanent tenure |
| 423 | Staying or living with friends, permanent tenure |
| 426 | Moved from one HOPWA funded project to HOPWA PH |
| 428 | Rental by client - GPD TIP housing subsidy |
| 431 | Rental by client - RRH or equivalent subsidy |
| 433 | Rental by client - HCV voucher (tenant or project based) (not dedicated) |
| 434 | Rental by client - Public housing unit |
| 436 | Rental by client - Emergency Housing Voucher |
| 437 | Rental by client - Family Unification Program Voucher (FUP) |
| 438 | Rental by client - Foster Youth to Independence Initiative (FYI) |
| 439 | Rental by client - Permanent Supportive Housing |
| 440 | Rental by client - Other permanent housing dedicated for formerly homeless persons |

## HMIS Client Enrollments (tlsa_Enrollment)

lsa_Report

tlsa_HHID

tlsa_Enrollment

hmis_Exit

hmis_Client

hmis_Enrollment

hmis_HealthAndDV

hmis_Services

### Relevant Data

#### Source

| **lsa_Report** |
| --- |
| ReportStart |
| ReportEnd |
| **tlsa_HHID** |
| HouseholdID |
| ProjectID |
| LSAProjectType |
| EntryDate |
| MoveInDate |
| ExitDate |
| **hmis_Enrollment** |
| EnrollmentID |
| PersonalID |
| ProjectID |
| HouseholdID |
| EntryDate |
| RelationshipToHoH |
| DisablingCondition |
| **hmis_HealthAndDV** |
| InformationDate |
| DomesticViolenceSurvivor |
| CurrentlyFleeing |
| **hmis_Client** |
| PersonalID |
| DOB |
| DOBDataQuality |
| **hmis_Services** |
| EnrollmentID |
| _BedNightDate_ (_DateProvided_ where _RecordType_ = 200) |
| **hmis_Exit** |
| EnrollmentID |
| ExitDate |

#### Target

The logic associated with values for columns with names in **bold** below is described in this step. The business logic associated with other columns is described in subsequent steps.

| **tlsa_Enrollment** | **Column Description** |
| --- | --- |
| **EnrollmentID** | Distinct _EnrollmentIDs_ in continuum ES/SH/TH/RRH/PSH projects between LookbackDate and ReportEnd |
| **PersonalID** | From hmis_Enrollment |
| **HouseholdID** | From hmis_Enrollment, limited to_HouseholdID_s in tlsa_HHID |
| **RelationshipToHoH** | From hmis_Enrollment |
| **ProjectID** | From tlsa_HHID |
| **LSAProjectType** | From tlsa_HHID |
| **EntryDate** | From hmis_Enrollment |
| **MoveInDate** | Based on tlsa_HHID – the move-in date for RRH/PSH enrollments, which may differ from the recorded _MoveInDate_ in HMIS or for the HoH. (See below.) |
| **ExitDate** | Based on hmis_Exit, the effective exit date for the enrollment, which may differ from the _ExitDate_ recorded in hmis_Exit. (See below.) |
| **LastBedNight** | If **LSAProjectType** = 1, the latest _BedNightDate_ for the enrollment on or before ReportEnd |
| EntryAge | The client’s age as of **EntryDate** |
| ActiveAge | For enrollments active in the report period, the client’s age as of the later of **EntryDate** and ReportStart. For all other enrollments, this will be the same as **EntryAge** |
| Exit1Age | For enrollments with an exit date between **CohortStart** and **CohortEnd** for exit cohort -1, client age as of the later of **EntryDate** and **CohortStart** for the relevant cohort period. For all other enrollments, this will be the same as **EntryAge** |
| Exit2Age | For enrollments with an exit date between **CohortStart** and **CohortEnd** for exit cohort -2, client age as of the later of **EntryDate** and **CohortStart** for the relevant cohort period. For all other enrollments, this will be the same as **EntryAge** |
| **DisabilityStatus** | From hmis_Enrollment; used repeatedly in subsequent steps for demographic reporting and to identify households and people included in various populations of interest |
| **DVStatus** | From hmis_HealthAndDV; used repeatedly in subsequent steps for demographic reporting and to identify households and people included in various populations of interest |
| Active | Identifies enrollments that meet the criteria for inclusion in the active cohort |
| AIR | Active in residence - identifies the subset of active enrollments with at least one bed night in the report period |
| PITOctober | Identifies the subset of AIR enrollments with a bed night on January 31 (if within the report period) |
| PITJanuary | Identifies the subset of AIR enrollments with a bed night on April 30 (if within the report period) |
| PITApril | Identifies the subset of AIR enrollments with a bed night on July 31 (if within the report period) |
| PITJuly | Identifies the subset of AIR enrollments with a bed night on October 31 (if within the report period) |
| CH  | Identifies enrollment relevant to reporting on chronic homelessness |

### Logic

#### Record Selection

An enrollment should be included in tlsa_Enrollment if:

- _HouseholdID_ meets the selection criteria for inclusion in tlsa_HHID (HHID)
- Enrollment._RelationshipToHoH_ in (1,2,3,4,5)
- Enrollment._EntryDate_ <= ReportEnd
- Exit._ExitDate_ is NULL or
- Exit_.ExitDate_ > LookbackDate; and
- Exit_.ExitDate_ > Enrollment._EntryDate_; and
- Exit._ExitDate_ \> tlsa_HHID._EntryDate_.
- If tlsa_HHID.**LSAProjectType** = 1, there is at least one _BedNightDate_ Services._RecordType_ = 200) record for the enrollment where _DateProvided_ is:
- Between LookbackDate and the earlier of Enrollment._ExitDate_ or ReportEnd; and
- On or after Enrollment._EntryDate_; and
- On or after tlsa_HHID.**EntryDate**; and
- On or before tlsa_HHID.**ExitDate** (if it is not NULL)

#### EntryDate

For night by night enrollments (tlsa_HHID.**LSAProjectType** = 1), **EntryDate** is set to the earliest _BedNightDate_ for the enrollment that is consistent with the record selection criteria.

For all other enrollments, tlsa_Enrollment.**EntryDate** should be set to the later of:

- hmis_Enrollment._EntryDate_; or
- tlsa_HHID.**EntryDate**.

#### MoveInDate

All requirements for _MoveInDate_ that apply to the active household also apply to all household members’ individual enrollments. If the household’s effective _MoveInDate_ is logically inconsistent with a household member’s entry/exit dates, additional logic applies to setting the household member’s effective _MoveInDate._

- If the household _MoveInDate_ is prior to a household member’s _EntryDate_, the effective _MoveInDate_ for the household member’s enrollment is the same as their _EntryDate_.
- If the household _MoveInDate_ is after a household member’s _ExitDate_, the household member does not have a _MoveInDate._
- If a household member exits the project on the date that the head of household moves in to permanent housing AND the household remains active in the project, the household member does not have a _MoveInDate_.

| Condition | Effective Move-In Date |
| --- | --- |
| HHID.**MoveInDate** < Enrollment._EntryDate_ | Enrollment._EntryDate_ |
| HHID.**MoveInDate** > Exit._ExitDate_ | NULL |
| HHID.**MoveInDate** = Exit._ExitDate_ and HHID.**ExitDate** is NULL | NULL |
| HHID.**MoveInDate** = Exit._ExitDate_ and HHID.**ExitDate** > Exit._ExitDate_ | NULL |
| (any other) | HHID.**MoveInDate** |

#### Last Bed Night for Night-by-Night Shelter Enrollments

Where tlsa_HHID.**LSAProjectType** = 1, **LastBedNight** refers to the most recent record (hmis_Services._RecordType_ = 200) of a bed night that meets the criteria for record selection.

#### ExitDate

All requirements for _ExitDate_ that apply to the active household apply to household members. In addition, no household member’s enrollment may continue past the head of household’s actual or effective exit date (tlsa_HHID.**ExitDate**).

For all project types other than night-by-night ES, if a household member’s enrollment remains active after the household exit date (actual or effective), the effective exit date for the household member is the same as the household’s exit date.

| Condition | Effective Exit Date |
| --- | --- |
| _ExitDate_ > tlsa_HHID.**ExitDate** | tlsa_HHID.**ExitDate** |
| _ExitDate_ is NULL and tlsa_HHID.**ExitDate** is not NULL | tlsa_HHID.**ExitDate** |
| _ExitDate_ > ReportEnd | NULL |
| (any other) | _ExitDate_ |

For night by night ES enrollments (tlsa_HHID.**LSAProjectType** = 1), **ExitDate** is set to NULL if:

- hmis_Enrollment._ExitDate_ is NULL; and
- tlsa_HHID.**ExitDate** is NULL; and
- **\[LastBedNight** + 90 days\] > ReportEnd.

Otherwise, **ExitDate** = \[**LastBedNight** \+ 1 day\].

#### DisabilityStatus

Because it is relevant and used repeatedly in subsequent steps both for demographic reporting and for identification of people and households who are part of specific populations of interest (e.g, Households with a Disabled Adult or Head of Household) , a preliminary enrollment-level value is included in tlsa_Enrollment.

| Enrollment DisablingCondition Value | DisabilityStatus |
| --- | --- |
| 0   | 0   |
| 1   | 1   |
| (any other) | NULL |

#### DVStatus

Because it is relevant and used repeatedly in subsequent steps both for demographic reporting and for identification of people and households who are part of specific populations of interest (e.g, Households Fleeing Domestic Violence), a preliminary enrollment-level value is included in tlsa_Enrollment.

It is the minimum DVStatus value in the table below based on _DomesticViolenceSurvivor_ and _CurrentlyFleeing_ values for any record associated with the enrollment and dated:

- On or before ReportEnd; and
- On or after tlsa_Enrollment.**EntryDate**_;_ and
- On or before tlsa_Enrollment.**ExitDate**, if it is not null.

| DomesticViolenceSurvivor | CurrentlyFleeing | DVStatus |
| --- | --- | --- |
| 1   | 1   | 1   |
| 1   | 0   | 2   |
| 1   | (any other) | 3   |
| 0   | (n/a) | 10  |
| In (8,9) | (n/a) | 98  |
| (any other) | (n/a) | NULL |

## Enrollment Ages (tlsa_Enrollment)

lsa_Report

tlsa_CohortDates

hmis_Client

tlsa_Enrollment

Age is used to determine household type, for demographic reporting, and to identify households and people in reporting populations of interest. This section defines the logic associated with determining client age for all enrollments in all contexts that age may be relevant.

It uses data in tlsa_CohortDates and hmis_Client to set age group values for tlsa_Enrollment.

### Relevant Data

#### Source

| **lsa_Report** |
| --- |
| ReportStart |
| ReportEnd |
| **tlsa_CohortDates** |
| Cohort |
| CohortStart |
| CohortEnd |
| **tlsa_Enrollment** |
| EntryDate |
| RelationshipToHoH |
| ExitDate |
| **hmis_Client** |
| DOB |
| DOBDataQuality |

#### Target

| **tlsa_Enrollment** |
| --- |
| **EntryAge** |
| **ActiveAge** |
| **Exit1Age** |
| **Exit2Age** |

### Logic

#### EntryAge

A client’s age at project entry is based on hmis_Client _DOB_ and _DOBDataQuality_ and the entry date for the enrollment.

All dates of birth must be validated; a client’s age must be handled as unknown if any of the following are true:

- _DOBDataQuality_ is anything other than ‘Full DOB reported’ (1) or ‘Approximate or partial DOB reported’ (2);
- _DOB_ is missing or set to a system default;
- The calculation would result in an age over 105 years old;
- _DOB_ is later than _EntryDate_ for the enrollment; or
- RelationshipToHoH = 1 and DOB = EntryDate for the enrollment

The first of the criteria listed below met by the combination of values for _DOB,_ _DOBDataQuality,_ and **EntryDate** determines the **EntryAge** for each enrollment:

| Priority | Condition | AgeGroup | LSA Category |
| --- | --- | --- | --- |
| 1   | _DOBDataQuality_ in (8,9) | 98  | Data not provided |
| 2   | _DOBDataQuality_ not in (1,2) | 99  | Missing/invalid |
| 3   | _DOB_ is missing or set to a system default | 99  | Missing/invalid |
| 4   | _DOB_ _\> EntryDate_ | 99  | Missing/invalid |
| 5   | _RelationshipToHoH_ \= 1 and _DOB_ _\= EntryDate_ | 99  | Missing/invalid |
| 6   | \[_DOB_ _\+_ 105 years\] _<=_ **EntryDate** | 99  | Missing/invalid |
| 7   | \[_DOB_ _\+_ 65 years\] _<=_ **EntryDate** | 65  | 65 and older |
| 8   | \[_DOB_ _\+_ 55 years\] _<=_ **EntryDate** | 64  | 55 to 64 |
| 9   | \[_DOB_ _\+_ 45 years\] _<=_ **EntryDate** | 54  | 45 to 54 years |
| 10  | \[_DOB_ _\+_ 35 years\] _<=_ **EntryDate** | 44  | 35 to 44 years |
| 11  | \[_DOB_ _\+_ 25 years\] _<=_ **EntryDate** | 34  | 25 to 34 years |
| 12  | \[_DOB_ _\+_ 22 years\] _<=_ **EntryDate** | 24  | 22 to 24 years |
| 13  | \[_DOB_ _\+_ 18 years\] _<=_ **EntryDate** | 21  | 18 to 21 years |
| 14  | \[_DOB_ + 6 years\] _<=_ **EntryDate** | 17  | 6 to 17 years |
| 15  | \[_DOB_ + 3 years\] _<=_ **EntryDate** | 5   | 3 to 5 years |
| 16  | \[_DOB_ + 1 years\] _<=_ **EntryDate** | 2   | 1 to 2 years |
| 17  | (other) | 0   | <1 year |

#### Once **EntryAge** is set, an additional adjustment may be required so that the date of birth (or lack thereof) used to calculate age is consistent across all enrollments. For any given **PersonalID**, if there is any enrollment in tlsa_Enrollment where **EntryAge** = 99, **EntryAge** for all enrollments should be set to 99

#### ActiveAge

**ActiveAge** is calculated for all enrollments. For enrollments active in the report period, it will only differ from **EntryAge** if the **EntryDate** < ReportStart (and may not differ then).

For inactive enrollments, it is equal to **EntryAge.** (Age for inactive enrollments may be needed to report on active client/household history.)

| Priority | Condition | AgeGroup |
| --- | --- | --- |
| 1   | **ExitDate** < ReportStart | **EntryAge** |
| 2   | **EntryDate** _>=_ ReportStart | **EntryAge** |
| 3   | **EntryAge** in (98,99) | **EntryAge** |
| 4   | \[_DOB_ _\+_ 65 years\] _<=_ ReportStart | 65  |
| 5   | \[_DOB_ _\+_ 55 years\] _<=_ ReportStart | 64  |
| 6   | \[_DOB_ _\+_ 45 years\] _<=_ ReportStart | 54  |
| 7   | \[_DOB_ _\+_ 35 years\] _<=_ ReportStart | 44  |
| 8   | \[_DOB_ _\+_ 25 years\] _<=_ ReportStart | 34  |
| 9   | \[_DOB_ _\+_ 22 years\] _<=_ ReportStart | 24  |
| 10  | \[_DOB_ _\+_ 18 years\] _<=_ ReportStart | 21  |
| 11  | \[_DOB_ + 6 years\] _<=_ ReportStart | 17  |
| 12  | \[_DOB_ + 3 years\] _<=_ ReportStart | 5   |
| 13  | \[_DOB_ + 1 years\] _<=_ ReportStart | 2   |
| 14  | (other) | 0   |

#### Exit1Age/Exit2Age

**Exit1Age/Exit2Age** are set for all enrollments as they apply to reporting on exit cohorts -1 and -2.

Like **ActiveAge**, they will differ from **EntryAge** only when the enrollment meets the time criteria for inclusion in the cohort (**ExitDate** is between **CohortStart** and **CohortEnd** ) AND the **EntryDate** is before the start of the cohort period. Otherwise, the exit age = **EntryAge**.

| Priority | Condition | AgeGroup |
| --- | --- | --- |
| 1   | **ExitDate** not between **CohortStart** and **CohortEnd** | **EntryAge** |
| 2   | **ExitDate** between **CohortStart** and **CohortEnd** and **EntryDate** _>=_ **CohortStart** | **EntryAge** |
| 3   | **EntryAge** in (98,99) | **EntryAge** |
| 4   | \[_DOB_ _\+_ 65 years\] _<=_ **CohortStart** | 65  |
| 5   | \[_DOB_ _\+_ 55 years\] _<=_ **CohortStart** | 64  |
| 6   | \[_DOB_ _\+_ 45 years\] _<=_ **CohortStart** | 54  |
| 7   | \[_DOB_ _\+_ 35 years\] _<=_ **CohortStart** | 44  |
| 8   | \[_DOB_ _\+_ 25 years\] _<=_ **CohortStart** | 34  |
| 9   | \[_DOB_ _\+_ 22 years\] _<=_ **CohortStart** | 24  |
| 10  | \[_DOB_ _\+_ 18 years\] _<=_ **CohortStart** | 21  |
| 11  | \[_DOB_ + 6 years\] _<=_ **CohortStart** | 17  |
| 12  | \[_DOB_ + 3 years\] _<=_ **CohortStart** | 5   |
| 13  | \[_DOB_ + 1 years\] _<=_ **CohortStart** | 2   |
| 14  | (other) | 0   |

## Household Types (tlsa_HHID)

tlsa_HHID

tlsa_Enrollment

tlsa_CohortDates

This section defines the logic associated with determining household type for each active household.

It uses the tlsa_Enrollment **EntryAge**, **ActiveAge**, **Exit1Age**, and **Exit2Age** values set in the previous step to set tlsa_HHID **EntryHHType, ActiveHHType, Exit1HHType** and **Exit2HHType**.

### Relevant Data

#### Source

| **tlsa_Enrollment** |
| --- |
| HouseholdID |
| EntryDate |
| ExitDate |
| EntryAge |
| ActiveAge |
| Exit1Age |
| Exit2Age |
| **tlsa_CohortDates** |
| Cohort |
| CohortStart |
| CohortEnd |

#### Target

| **tlsa_HHID** |
| --- |
| **EntryHHType** |
| **ActiveHHType** |
| **Exit1HHType** |
| **Exit2HHType** |

### Logic

Household type for each **HouseholdID** is based on counts of distinct **PersonalID**s in tlsa_Enrollment by age status – adult, child, or unknown – for enrollments associated with the _HouseholdID_.

Age status is based on the **Entry/Active/Exit1/Exit2Age** value for each enrollment, as shown below.

| Age Status | Age | Entry/Active/Exit1/Exit2Age |
| --- | --- | --- |
| Adult | 18 and over | Between 21 and 65 |
| Child | Under 18 | Between 0 and 17 |
| Unknown | Unknown | 98 or 99 |

The criteria below are mutually exclusive; it is not necessary to apply them in priority order.

| \# Adults | \# Children | \# Unknown Age | HHType | LSA Value |
| --- | --- | --- | --- | --- |
| \>= 1 | 0   | 0   | AO (Adult-only) | 1   |
| \>= 1 | \>= 1 | (any) | AC (Adult-child) | 2   |
| 0   | \>= 1 | 0   | CO (Child-only) | 3   |
| (any) | 0   | \>= 1 | UN (Unknown) | 99  |
| 0   | (any) | \>= 1 | UN (Unknown) | 99  |

#### EntryHHType

Calculate for tlsa_HHID based on **EntryAge** for all records in tlsa_Enrollment with the same **HouseholdID**.

**EntryHHType** is based on all household members’ age at the time of their own project entry. It is not a point-in-time determination – for households whose members entered at different times, it may differ from the household type as of the head of household’s entry and/or household members’ entry dates.

#### ActiveHHType

If tlsa_HHID.**EntryDate** is >= ReportStart or tlsa_HHID.**ExitDate** < ReportStart, **ActiveHHType** = **EntryHHType**.

For all other households, **ActiveHHType** is based on **ActiveAge** values for records in tlsa_Enrollment with the same **HouseholdID** where **ExitDate** is NULL or **ExitDate** >= ReportStart. In other words, if the household is active in the report period, household type is based only on the ages of household members who were also active in the report period.

**ActiveHHType** is set for all household enrollments, but it is not an indicator that the household meets all of the criteria for inclusion in the active cohort, which are described in section [5.1 Get Active and AIR HouseholdIDs](#_Get_Active_HouseholdIDs_1).

#### Exit1HHType/Exit2HHType

If tlsa_HHID.**EntryDate** is >= **CohortStart** or tlsa_HHID.**ExitDate** < **CohortStart**, **Exit(1 or 2)HHType** = **EntryHHType**.

For all other households, **Exit1HHType** is based on **Exit1Age** and **Exit2HHType** is based on **Exit2Age** for all records in tlsa_Enrollment with the same **HouseholdID** and:

- tlsa_Enrollment.EntryDate < CohortEnd; and
- tlsa_Enrollment.**ExitDate** is null or tlsa_Enrollment.**ExitDate** >= **CohortStart**