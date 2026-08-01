---
layout: default
title: "9 - LSA Calculated Counts"
nav_order: 10
parent: "LSA Programming Specifications"
has_toc: true
last_modified_date: 2026-07-30
---

- Contents
{:toc}

# 9.1 Report Rows for LSACalculated Counts

| Row | Reporting Category                                      | Section     |
|----:|---------------------------------------------------------|-------------|
|  53 | Project-level – People by household characteristics     | [Section 9.3](#93-counts-of-people-and-households-by-project-and-household-characteristics) |
|  53 | Project type – People by household characteristics      | [Section 9.3](#93-counts-of-people-and-households-by-project-and-household-characteristics) |
|  54 | Project-level – Households by household characteristics | [Section 9.3](#93-counts-of-people-and-households-by-project-and-household-characteristics) |
|  54 | Project-type – Households by household characteristics  | [Section 9.3](#93-counts-of-people-and-households-by-project-and-household-characteristics) |
|  55 | Project level – People by personal characteristic       | [Section 9.4](#94-get-counts-of-people-by-project-and-personal-characteristics) |
|  55 | Project-type – People by personal characteristic        | [Section 9.4](#94-get-counts-of-people-by-project-and-personal-characteristics) |
|  56 | Project-level – Bed nights by household characteristics | [Section 9.4](#94-get-counts-of-people-by-project-and-personal-characteristics) |
|  56 | Project-type – Bed nights by household characteristics  | [Section 9.5](#95-get-counts-of-bednights) |
|  57 | Project-level – Bed nights by personal characteristics  | [Section 9.5](#95-get-counts-of-bednights) |
|  57 | Project-type – Bed nights by personal characteristics   | [Section 9.5](#95-get-counts-of-bednights) |

# 9.2 Identify Active and Point in Time Cohorts for LSACalculated Counts

The ‘active’ cohort for these counts is limited to people and households with enrollments where **AIR** = 1.

This step identifies records in tlsa_Enrollment in point-in-time cohorts (10-13) to simplify the process of generating counts.

## Source

| **tlsa_CohortDates**                                   |
|--------------------------------------------------------|
| Cohort                                                 |
| CohortStart                                            |
| CohortEnd                                              |

| **tlsa_Enrollment**                                    |
|--------------------------------------------------------|
| AIR                                                    |
| EntryDate                                              |
| MoveInDate                                             |
| ExitDate                                               |
| LSAProjectType                                         |

| **hmis_Services**                                      |
|--------------------------------------------------------|
| EnrollmentID                                           |
| BedNightDate (*DateProvided* where *RecordType* = 200) |

## Target

| tlsa_Enrollment | Cohort | Category          |
|-----------------|--------|-------------------|
| **PITOctober**  | 10     | Active October 31 |
| **PITJanuary**  | 11     | Active January 31 |
| **PITApril**    | 12     | Active April 30   |
| **PITJuly**     | 13     | Active July 31    |

## Logic

Set **PITOctober**, **PITJanuary**, **PITApril**, and **PITJuly** to 1
where **AIR** = 1 and:

- If **LSAProjectType** in (3,13), **MoveInDate** \<= <u>CohortEnd</u>;
  and

- If **LSAProjectType** in (0,1,2,8), **EntryDate** \<=
  <u>CohortEnd</u>; and

- If **LSAProjectType** = 1, there is a valid *BedNightDate* on
  <u>CohortStart</u>; and

- **ExitDate** is NULL, or **ExitDate** \> <u>CohortStart.</u>

# 9.3 Counts of People and Households by Project and Household Characteristics
``` mermaid

flowchart LR

  subgraph grp
    direction TD
        T2([tlsa_HHID         
        tlsa_Enrollment]) ~~~	H2[(hmis_Services)]
  end

	T1([tlsa_CohortDates])-->grp-->L1[[lsa_Calculated]]

	L1:::LSA
	
	T1:::Temp
	T2:::Temp
	
	H2:::HMIS
  grp:::Box

	classDef Temp stroke:#FF5978, fill:#FFDFE5, color:#8E2236
	classDef LSA stroke:#FBB35A, fill:#FFEFDB, color:#8F632D 
	classDef HMIS stroke:#374D7C, fill:#E2EBFF, color:#374D7C
    	classDef Man stroke:#999999, fill:#EEEEEE, color:#000000
	classDef Box stroke: #CCCCCC, fill:none, color: #FFFFFF
	
```
## Source

| **tlsa_Enrollment** |
|---------------------|
| AIR                 |
| PITOctober          |
| PITJanuary          |
| PITApril            |
| PITJuly             |

| **tlsa_HHID**       |
|---------------------|
| ActiveHHType        |
| ProjectID           |
| LSAProjectType      |
| HHChronic           |
| HHVet               |
| HHAdultAge          |
| HHParent            |
| HHFleeingDV         |
| HHDisability        |

## Target

| lsa_Calculated Column | Requirements                        |
| --------------------- | ----------------------------------- |
| Value             | See below                           |
| Cohort            | 1, 10, 11, 12, 13 (see section 9.2) |
| Universe         | See below                           |
| HHType            | See below                           |
| Population        | See below                           |
| SystemPath       | -1                                  |
| ProjectID         | See below                           |
| ReportRow       | See below                           |
| ReportID              | Must match LSAReport.**ReportID**   |

## Logic

### Report Row and Value

Report rows 53 and 54 count people and households in the active and point-in-time cohorts (see section 9.2).

| Row | Value |
|----|----|
| 53 | Count of distinct **PersonalID**s in tlsa_Enrollment |
| 54 | Count of distinct combinations of **HoHID**/**ActiveHHType** in tlsa_HHID |

### Cohort

| Cohort | tlsa_Enrollment Criteria |
|--------|--------------------------|
| 1      | **AIR** = 1              |
| 10     | **PITOctober** = 1       |
| 11     | **PITJanuary** = 1       |
| 12     | **PITApril** = 1         |
| 13     | **PITJuly** = 1          |

### Universe and ProjectID

Report rows 53 and 54 are required for each of the following **Universe** values grouped by cohort, household type, and population. For project-level counts (**Universe** = 10), the **ProjectID** from tlsa_HHID is required and should match a record in lsa_Project.

| Universe | ProjectID | Criteria |
|----|----|----|
| 10 = Project-level | =tlsa_HHID.**ProjectID** | \- |
| 11=ES project type | NULL | tlsa_HHID.**LSAProjectType** in (0,1) |
| 12=SH project type | NULL | tlsa_HHID.**LSAProjectType** = 8 |
| 13=TH project type | NULL | tlsa_HHID.**LSAProjectType** = 2 |
| 14=Housed in RRH | NULL | tlsa_HHID.**LSAProjectType** = 13 |
| 15=Housed in PSH | NULL | tlsa_HHID.**LSAProjectType** = 3 |
| 16=ES/SH/TH unduplicated | NULL | tlsa_HHID.**LSAProjectType** in (0,1,8,2) |

### Household Type and Populations

Report rows 53 and 54 are required for the following combinations of
household type and population:

|  ID | Population                                                      | HHType     | Criteria (tlsa_HHID)                           |
| --: | --------------------------------------------------------------- | ---------- | ---------------------------------------------- |
|   0 | All                                                             | 0,1,2,3,99 | All                                            |
|  10 | Youth 18-21                                                     | 1          | **HHAdultAge = 18**                            |
|  11 | Youth 22-24                                                     | 1          | **HHAdultAge** = 24                            |
|  12 | Parenting Youth 18-24                                           | 2          | **HHParent** = 1 and **HHAdultAge** in (18,24) |
|  13 | Veteran                                                         | 0,1,2,99   | **HHVet = 1**                                  |
|  14 | Non-Veteran 25+                                                 | 1          | **HHVet** = 0 and **HHAdultAge** in (25,55)    |
|  15 | Chronically Homeless                                            | 0,1,2,3,99 | **HHChronic** = 1                              |
|  18 | Disabled Adult or HoH                                           | 0,1,2,3,99 | **HHDisability** = 1                           |
|  19 | Fleeing Domestic Violence                                       | 0,1,2,3,99 | **HHFleeingDV** = 1                            |
|  45 | Seniors 55+                                                     | 1          | **HHAdultAge** = 55                            |
|  46 | Parenting Children                                              | 3          | **HHParent = 1**                               |
|  48 | Domestic Violence Survivors Not Identified as Currently Fleeing | 0,1,2,3,99 | **HHFleeingDV** = 2                            |

# 9.4 Get Counts of People by Project and Personal Characteristics
``` mermaid

flowchart LR

  subgraph grp
    direction TD
        T2([tlsa_HHID         
        tlsa_Enrollment]) ~~~	H2[(hmis_Services)]
  end

	T1([tlsa_CohortDates])-->grp-->L1[[lsa_Calculated]]

	L1:::LSA
	
	T1:::Temp
	T2:::Temp
	
	H2:::HMIS
  grp:::Box

	classDef Temp stroke:#FF5978, fill:#FFDFE5, color:#8E2236
	classDef LSA stroke:#FBB35A, fill:#FFEFDB, color:#8F632D 
	classDef HMIS stroke:#374D7C, fill:#E2EBFF, color:#374D7C
    	classDef Man stroke:#999999, fill:#EEEEEE, color:#000000
	classDef Box stroke: #CCCCCC, fill:none, color: #FFFFFF
	
```
##  Source

| **tlsa_Enrollment** |
|---------------------|
| AIR                 |
| PITOctober          |
| PITJanuary          |
| PITApril            |
| PITJuly             |

| **tlsa_HHID**       |
|---------------------|
| ActiveHHType        |
| ProjectID           |
| LSAProjectType      |
| HHChronic           |
| HHVet               |
| HHAdultAge          |
| HHParent            |
| HHFleeingDV         |

## Target

| lsa_Calculated Column | Requirements                                         |
| --------------------- | ---------------------------------------------------- |
| **Value**             | Count of distinct **PersonalIDs** in tlsa_Enrollment |
| **Cohort**            | 1, 10, 11, 12, 13 (see section 9.2)                  |
| **Universe**          | See below                                            |
| **HHType**            | See below                                            |
| **Population**        | See below                                            |
| **SystemPath**        | -1                                                   |
| **ProjectID**         | See below                                            |
| **ReportRow**         | 55                                                   |
| ReportID              | Must match LSAReport.**ReportID**                    |

## Logic

### Cohort

| Cohort | tlsa_Enrollment Criteria |
|--------|--------------------------|
| 1      | **AIR** = 1              |
| 10     | **PITOctober** = 1       |
| 11     | **PITJanuary** = 1       |
| 12     | **PITApril** = 1         |
| 13     | **PITJuly** = 1          |

### Universe and ProjectID

Report row 55 is required for each of the following **Universe** values grouped by cohort, household type, and population. For project-level counts (**Universe** = 10), the **ProjectID** from tlsa_HHID is required and should match a record in lsa_Project.

| Universe | ProjectID | Criteria |
|----|----|----|
| 10 = Project-level | =tlsa_HHID.**ProjectID** | \- |
| 11=ES project type | NULL | tlsa_HHID.**LSAProjectType** in (0,1) |
| 12=SH project type | NULL | tlsa_HHID.**LSAProjectType** = 8 |
| 13=TH project type | NULL | tlsa_HHID.**LSAProjectType** = 2 |
| 14=Housed in RRH | NULL | tlsa_HHID.**LSAProjectType** = 13 |
| 15=Housed in PSH | NULL | tlsa_HHID.**LSAProjectType** = 3 |
| 16=ES/SH/TH unduplicated | NULL | tlsa_HHID.**LSAProjectType** in (0,1,8,2) |

### Household Type and Populations

For counts by **ProjectID** (**Universe** 10) report row 55 is required for
the following combinations of household type and population:

| ID   | Population                                | HHType     | Criteria                                                                                                                               |
| ---- | ----------------------------------------- | ---------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| 50   | Veteran                                   | 0,1,2,99   | tlsa\_Person.**VetStatus = 1**                                                                                                         |
| 53   | Chronically Homeless Adult/HoH            | 0,1,2,3,99 | tlsa\_Person.**DisabilityStatus** = 1 and **CHTime** = 365 and **CHTimeStatus** in (1,2); or **CHTime** = 400 and **CHTimeStatus** = 2 |
| 1190 | Age 18-21 in AO Youth Household           | 1          | tlsa\_Enrollment.**ActiveAge** \= 21 and tlsa\_HHID.**HHAdultAge** in (18,24)                                                          |
| 1191 | Age 22-24 in AO Youth Household           | 1          | tlsa\_Enrollment.**ActiveAge** \= 24 and tlsa\_HHID.**HHAdultAge** in (18,24)                                                          |
| 1290 | Age 18-21 in AC Parenting Youth Household | 2          | tlsa\_Enrollment.**ActiveAge** \= 21 and tlsa\_HHID.**HHParent** = 1 and tlsa\_HHID.HHAdultAge in (18,24)                              |
| 1291 | Age 22-24 in AC Parenting Youth Household | 2          | tlsa\_Enrollment.**ActiveAge** \= 24 and tlsa\_HHID.**HHParent** = 1 and tlsa\_HHID.HHAdultAge in (18,24)                              |

For counts by project type (**Universe** 11-16)), report row 55 is
required for the following:

| ID   | Population                                                          | HHType     | Criteria                                                                                                                               |
| ---- | ------------------------------------------------------------------- | ---------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| 50   | Veteran                                                             | 0,1,2,99   | tlsa\_Person.**VetStatus = 1**                                                                                                         |
| 51   | Parenting Youth 18-24                                               | **2**      | tlsa\_HHID.**HHParent** = 1 and tlsa\_HHID.**HHAdultAge** in (18,24)                                                                   |
| 52   | Parenting Child                                                     | 3          | tlsa\_HHID.**HHParent** = 1                                                                                                            |
| 53   | Chronically Homeless Adult/HoH                                      | 0,1,2,3,99 | tlsa\_Person.**DisabilityStatus** = 1 and **CHTime** = 365 and **CHTimeStatus** in (1,2); or **CHTime** = 400 and **CHTimeStatus** = 2 |
| 54   | Disabled Adult/HoH                                                  | 0,1,2,3,99 | tlsa\_Person.**DisabilityStatus** = 1                                                                                                  |
| 55   | Fleeing Domestic Violence                                           | 0,1,2,3,99 | tlsa\_Person.**DVStatus** = 1                                                                                                          |
| 56   | American Indian, Alaska Native, or Indigenous (only)                | 0,1,2,3,99 | **RaceEthnicity** = 1                                                                                                                  |
| 57   | American Indian, Alaska Native, or Indigenous & Hispanic/Latina/e/o | 0,1,2,3,99 | **RaceEthnicity** = 16                                                                                                                 |
| 58   | Asian or Asian American (only)                                      | 0,1,2,3,99 | **RaceEthnicity** = 2                                                                                                                  |
| 59   | Asian or Asian American & Hispanic/Latina/e/o                       | 0,1,2,3,99 | **RaceEthnicity** = 26                                                                                                                 |
| 60   | Black, African American, or African (only)                          | 0,1,2,3,99 | **RaceEthnicity** = 3                                                                                                                  |
| 61   | Black, African American, or African & Hispanic/Latina/e/o           | 0,1,2,3,99 | **RaceEthnicity** = 36                                                                                                                 |
| 62   | Hispanic/Latina/e/o (only)                                          | 0,1,2,3,99 | **RaceEthnicity** = 6                                                                                                                  |
| 63   | Middle Eastern or North African (only)                              | 0,1,2,3,99 | **RaceEthnicity** = 7                                                                                                                  |
| 64   | Middle Eastern or North African & Hispanic/Latina/e/o               | 0,1,2,3,99 | **RaceEthnicity** = 67                                                                                                                 |
| 65   | Native Hawaiian or Pacific Islander (only)                          | 0,1,2,3,99 | **RaceEthnicity** = 4                                                                                                                  |
| 66   | Native Hawaiian or Pacific Islander & Hispanic/Latina/e/o           | 0,1,2,3,99 | **RaceEthnicity** = 46                                                                                                                 |
| 67   | White (only)                                                        | 0,1,2,3,99 | **RaceEthnicity** = 5                                                                                                                  |
| 68   | White & Hispanic/Latina/e/o                                         | 0,1,2,3,99 | **RaceEthnicity** = 56                                                                                                                 |
| 69   | Multi-Racial (not Hispanic/Latina/e/o)                              | 0,1,2,3,99 | **RaceEthnicity** \>=12**,** not in (98,99), does not include a 6                                                                      |
| 70   | Multi-Racial & Hispanic/Latina/e/o)                                 | 0,1,2,3,99 | **RaceEthnicity** \>=126**,** includes a 6                                                                                             |
| 71   | American Indian, Alaska Native, or Indigenous (any combination)     | 0,1,2,3,99 | **RaceEthnicity** includes a 1                                                                                                         |
| 72   | Asian or Asian American (any combination)                           | 0,1,2,3,99 | **RaceEthnicity** includes a 2                                                                                                         |
| 73   | Black, African American, or African & Any Other (any combination)   | 0,1,2,3,99 | **RaceEthnicity** includes a 3                                                                                                         |
| 74   | Hispanic/Latina/e/o (any combination)                               | 0,1,2,3,99 | **RaceEthnicity** includes a 6                                                                                                         |
| 75   | Middle Eastern or North African & Any Other (any combination)       | 0,1,2,3,99 | **RaceEthnicity** includes a 7                                                                                                         |
| 76   | Native Hawaiian or Pacific Islander & Any Other (any combination)   | 0,1,2,3,99 | **RaceEthnicity** includes a 4                                                                                                         |
| 77   | White (any combination)                                             | 0,1,2,3,99 | **RaceEthnicity** includes a 5                                                                                                         |
| 86   | <1 year                                                             | 0,2,3,99   | Maximum **ActiveAge** \= 0                                                                                                             |
| 87   | 1 to 2 years                                                        | 0,2,3,99   | Maximum **ActiveAge** \= 2                                                                                                             |
| 88   | 3 to 5 years                                                        | 0,2,3,99   | Maximum **ActiveAge** \= 5                                                                                                             |
| 89   | 6 to 17 years                                                       | 0,2,3,99   | Maximum **ActiveAge** \= 17                                                                                                            |
| 90   | 18 to 21 years                                                      | 0,1,2,99   | Maximum **ActiveAge** \= 21                                                                                                            |
| 91   | 22 to 24 years                                                      | 0,1,2,99   | Maximum **ActiveAge** \= 24                                                                                                            |
| 92   | 25 to 34 years                                                      | 0,1,2,99   | Maximum **ActiveAge** \= 34                                                                                                            |
| 93   | 35 to 44 years                                                      | 0,1,2,99   | Maximum **ActiveAge** \= 44                                                                                                            |
| 94   | 45 to 54 years                                                      | 0,1,2,99   | Maximum **ActiveAge** \= 54                                                                                                            |
| 95   | 55 to 64 years                                                      | 0,1,2,99   | Maximum **ActiveAge** \= 64                                                                                                            |
| 96   | 65 and older                                                        | 0,1,2,99   | Maximum **ActiveAge** \= 65                                                                                                            |
| 97   | Domestic Violence Survivor Not Identified as Currently Fleeing      | 0,1,2,3,99 | tlsa\_Person.**DVStatus** in (2,3)                                                                                                     |
| 1190 | Age 18-21 in AO Youth Household                                     | 1          | tlsa\_Enrollment.**ActiveAge** \= 21 and tlsa\_HHID.**HHAdultAge** in (18,24)                                                          |
| 1191 | Age 22-24 in AO Youth Household                                     | 1          | tlsa\_Enrollment.**ActiveAge** \= 24 and tlsa\_HHID.**HHAdultAge** in (18,24)                                                          |
| 1290 | Age 18-21 in AC Parenting Youth Household                           | 2          | tlsa\_Enrollment.**ActiveAge** \= 21 and tlsa\_HHID.**HHParent** = 1 and tlsa\_HHID.HHAdultAge in (18,24)                              |
| 1291 | Age 22-24 in AC Parenting Youth Household                           | 2          | tlsa\_Enrollment.**ActiveAge** \= 24 and tlsa\_HHID.**HHParent** = 1 and tlsa\_HHID.HHAdultAge in (18,24)                              |

In addition, row 55 counts by project type (**Universe** 11-16) are required for three populations in combination with 34 subpopulations.  The three parent populations are:

| ID  | Parent Population     |
|-----|-----------------------|
| 50  | Veteran               |
| 51  | Parenting Youth 18-24 |
| 52  | Parenting Child       |

Each of the parent populations above are reported in combination with each of the subpopulations below. The value for **Population** for these combinations is a four-digit number – the two digits on the left identify the parent population and the two on the right identify the
subpopulation. For example, the subpopulation of Veterans Fleeing Domestic Violence is identified as 5055.

| ID  | Subpopulations                                                      |
|-----|---------------------------------------------------------------------|
| 53  | Chronically Homeless Adult/HoH                                      |
| 54  | Disabled Adult/HoH                                                  |
| 55  | Fleeing Domestic Violence                                           |
| 56  | American Indian, Alaska Native, or Indigenous (only)                |
| 57  | American Indian, Alaska Native, or Indigenous & Hispanic/Latina/e/o |
| 58  | Asian or Asian American (only)                                      |
| 59  | Asian or Asian American & Hispanic/Latina/e/o                       |
| 60  | Black, African American, or African (only)                          |
| 61  | Black, African American, or African & Hispanic/Latina/e/o           |
| 62  | Hispanic/Latina/e/o (only)                                          |
| 63  | Middle Eastern or North African (only)                              |
| 64  | Middle Eastern or North African & Hispanic/Latina/e/o               |
| 65  | Native Hawaiian or Pacific Islander (only)                          |
| 66  | Native Hawaiian or Pacific Islander & Hispanic/Latina/e/o           |
| 67  | White (only)                                                        |
| 68  | White & Hispanic/Latina/e/o                                         |
| 69  | Multi-Racial (not Hispanic/Latina/e/o)                              |
| 70  | Multi-Racial & Hispanic/Latina/e/o)                                 |
| 71  | American Indian, Alaska Native, or Indigenous (any combination)     |
| 72  | Asian or Asian American (any combination)                           |
| 73  | Black, African American, or African & Any Other (any combination)   |
| 74  | Hispanic/Latina/e/o (any combination)                               |
| 75  | Middle Eastern or North African & Any Other (any combination)       |
| 76  | Native Hawaiian or Pacific Islander & Any Other (any combination)   |
| 77  | White (any combination)                                             |
| 97  | Domestic Violence Survivor Not Identified as Currently Fleeing      |

# 9.5 Get Counts of Bednights 
``` mermaid

flowchart LR

  subgraph grp
    direction TD
        T2([tlsa_Person
        tlsa_HHID         
        tlsa_Enrollment]) ~~~	H2[(hmis_Services)]
  end

	L2[[lsa_Report]]-->grp-->L1[[lsa_Calculated]]

	L1:::LSA
	L2:::LSA
	T2:::Temp
	
	H2:::HMIS
  grp:::Box

	classDef Temp stroke:#FF5978, fill:#FFDFE5, color:#8E2236
	classDef LSA stroke:#FBB35A, fill:#FFEFDB, color:#8F632D 
	classDef HMIS stroke:#374D7C, fill:#E2EBFF, color:#374D7C
    	classDef Man stroke:#999999, fill:#EEEEEE, color:#000000
	classDef Box stroke: #CCCCCC, fill:none, color: #FFFFFF
	
```
## Source

| **tlsa_Enrollment** |
|---------------------|
| AIR                 |
| MoveInDate          |
| ExitDate            |

| **tlsa_HHID**       |
|---------------------|
| ActiveHHType        |
| ProjectID           |
| LSAProjectType      |
| HHAdultAge          |

| **tlsa_Person**     |
|---------------------|
| VetStatus           |
| DisabilityStatus    |
| CHTime              |
| CHTimeStatus        |

### Target

| lsa_Calculated Column | Requirements                      |
| --------------------- | --------------------------------- |
| **Value**             | See below                         |
| **Cohort**            | 1                                 |
| **Universe**          | See below                         |
| **HHType**            | See below                         |
| **Population**        | See below                         |
| **SystemPath**        | -1                                |
| **ProjectID**         | See below                         |
| **ReportRow**         | 56 and 57 (see below)             |
| ReportID              | Must match LSAReport.**ReportID** |

## Logic

These counts may be included under any circumstances but are required in LSACalculated only if:

- <u>ReportStart</u> is October 1

- <u>ReportEnd</u> is September 30 of the following year

- LSAReport.**LSAScope** = 1

### Universe and ProjectID

Report rows 56 and 57 are required for each of the following **Universe** values grouped by household type and population. For project-level counts (**Universe** = 10), the **ProjectID** from tlsa\_HHID is required and should match a record in lsa\_Project.

| Universe | ProjectID | Criteria |
|----|----|----|
| 10 = Project-level | =tlsa_HHID.**ProjectID** | \- |
| 11=ES project type | NULL | tlsa_HHID.**LSAProjectType** in (0,1) |
| 12=SH project type | NULL | tlsa_HHID.**LSAProjectType** = 8 |
| 13=TH project type | NULL | tlsa_HHID.**LSAProjectType** = 2 |
| 14=Housed in RRH | NULL | tlsa_HHID.**LSAProjectType** = 13 |
| 15=Housed in PSH | NULL | tlsa_HHID.**LSAProjectType** = 3 |
| 16=ES/SH/TH unduplicated | NULL | tlsa_HHID.**LSAProjectType** in (0,1,8,2) |

### ReportRow, Population, and HHType

The only difference in logic between rows 56 and 57 are the populations. Both count bed nights in the LSA report period for the populations and household types in the table below.

| ReportRow | Population | Name                           | HHType     | Criteria                                                                                                                   |
| --------- | ---------- | ------------------------------ | ---------- | -------------------------------------------------------------------------------------------------------------------------- |
| 56        | 0          | All                            | 0,1,2,3,99 | \-                                                                                                                         |
| 56        | 10         | Youth 18-21                    | 1          | **HHAdultAge** \= 18                                                                                                       |
| 56        | 11         | Youth 22-24                    | 1          | **HHAdultAge** \= 24                                                                                                       |
| 57        | 50         | Veteran                        | 0,1,2,99   | **VetStatus** = 1                                                                                                          |
| 57        | 53         | Chronically Homeless Adult/HoH | 0,1,2,3,99 | **DisabilityStatus** = 1 and: **CHTime** = 365 and **CHTimeStatus** in (1,2); or **CHTime** = 400 and **CHTimeStatus** = 2 |

### Value

**Value** = a count of the combination of \[Date\] and distinct **PersonalID**s in tlsa\_Enrollment where **AIR** = 1 and meet the criteria for inclusion based on household type and population identfiers where \[Date\] is between ReportStart and ReportEnd and:

| Project                       | \[Date\]                                                                                                                         | \[Date\]                                                         |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| **LSAProjectType** in (3,13)  | **\>=MoveInDate**                                                                                                                | <= (**ExitDate** – 1 day) or, If **ExitDate** is NULL, ReportEnd |
| **LSAProjectType** in (0,2,8) | **\>=EntryDate**                                                                                                                 | <= (**ExitDate** – 1 day) or, If **ExitDate** is NULL, ReportEnd |
| **LSAProjectType** = 1        | _BedNightDate_ between <u>ReportStart</u> and <u>ReportEnd</u> and >= **EntryDate** and < **ExitDate** (if ExitDate is not NULL) |                                                                  |

# 9.6 Get OPH Point-in-Time Counts for HIC
``` mermaid

flowchart LR

  subgraph grp
    direction TD
        L2[[lsa_Project
        lsa_HMISParticipation         
        tlsa_Enrollment]] ~~~	H2[(hmis_Enrollment
        hmis_Exit)]
  end

	L1[[lsa_Report]]-->grp-->L3[[lsa_Calculated]]

	L1:::LSA
	L2:::LSA
  L3:::LSA
	
	H2:::HMIS
  grp:::Box

	classDef Temp stroke:#FF5978, fill:#FFDFE5, color:#8E2236
	classDef LSA stroke:#FBB35A, fill:#FFEFDB, color:#8F632D 
	classDef HMIS stroke:#374D7C, fill:#E2EBFF, color:#374D7C
    	classDef Man stroke:#999999, fill:#EEEEEE, color:#000000
	classDef Box stroke: #CCCCCC, fill:none, color: #FFFFFF
	
```
## Source

| **lsa_Report**                   |
|----------------------------------|
| LSAScope                         |
| ReportStart                      |

| **lsa_Project**                  |
|----------------------------------|
| ProjectID                        |
| ProjectType                      |

| **lsa_HMISParticipation**        |
|----------------------------------|
| HMISParticipationType            |
| HMISParticipationStatusStartDate |
| HMISParticipationStatusEndDate   |

| **hmis_Enrollment**              |
|----------------------------------|
| HouseholdID                      |
| PersonalID                       |
| EntryDate                        |
| RelationshipToHoH                |
| MoveInDate                       |

| **hmis_Exit**                    |
|----------------------------------|
| ExitDate                         |

## Target

| lsa_Calculated Column | Requirements                                                     |
| --------------------- | ---------------------------------------------------------------- |
| **Cohort**            | 1                                                                |
| **Universe**          | 10                                                               |
| **HHType**            | 0                                                                |
| **Population**        | 0                                                                |
| **SystemPath**        | -1                                                               |
| **ProjectID**         | Must match Project.**ProjectID** where **ProjectType** in (9,10) |
| **ReportRow**         | 53                                                               |
| **ReportID**          | Must match LSAReport.**ReportID**                                |

## Logic

This adds a project-level point-in-time count of people housed in OPH for the HIC.

If **<u>LSAScope</u>** \= 3 (HIC), **Value** \= a count of distinct *PersonalID*s in hmis\_Enrollment where:

-   *EntryDate* <= <u>ReportStart</u>
-   *ExitDate* \> <u>ReportStart</u> or is NULL
-   The *HouseholdID* is associated with an enrollment that meets the following criteria:
    -   ***RelationshipToHoH*** = 1
    -   *EnrollmentCoC* = <u>ReportCoC</u>
    -   *EntryDate* <= <u>ReportStart</u>
    -   *MoveInDate* <= <u>ReportStart</u>
    -   MoveInDate >= EntryDate
    -   *ExitDate* > <u>ReportStart</u> or is NULL
    -   *ProjectID* \= lsa\_Project.**ProjectID** where **ProjectType** in (9,10)
    -   There is a record in lsa\_HMISParticipation for the ProjectID where:
        -   **HMISParticipationType** \= 1 (participating in HMIS)
        -   **HMISParticipationStatusStartDate** <= <u>ReportStart</u>.
        -   **HMISParticipationStatusEndDate** > <u>ReportStart</u>.or is null