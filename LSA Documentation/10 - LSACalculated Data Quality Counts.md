# 10 - HMIS Business Logic - LSACalculated Project-Level Data Quality Counts

Report Rows 901-920 are project-level counts of data quality issues; this is to provide information to CoCs and the AHAR analysis team about specific sources of data quality issues.
## 10.1 Static Column Values

| lsa_Calculated Column | Requirements                      |
| --------------------- | --------------------------------- |
| **Cohort**            | 1                                 |
| **Universe**          | 10                                |
| **HHType**            | 0                                 |
| **Population**        | 0                                 |
| **SystemPath**        | -1                                |
| **ProjectID**         | Must match Project.**ProjectID**. |
| **ReportID**          | Must match LSAReport.**ReportID** |

**ReportRow** numbers and **Value** criteria are defined in the following sections.

## 10.2 DQ - Enrollments Active After Project Operating End Date by Project

**ReportRow** 901 counts enrollments in tlsa\_Enrollment with no *ExitDate* in hmis\_Exit for projects that have an *OperatingEndDate* between <u>ReportStart</u> and <u>ReportEnd</u>.

**ReportRow** 902 counts enrollments in tlsa\_Enrollment where *OperatingEndDate* is between <u>ReportStart</u> and <u>ReportEnd</u> and hmis\_Exit.*ExitDate* > *OperatingEndDate*.

These counts are grouped by **ProjectID**.

**Value** = a count of distinct **EnrollmentID**s in tlsa\_Enrollment where:

-   *ExitDate* is NULL (**ReportRow** 901); or
-   *ExitDate* > Project. *OperatingEndDate* (**ReportRow** 902);

AND:

-   *OperatingEndDate* between <u>ReportStart</u> and <u>ReportEnd</u>

Records are only included when the count is greater than zero.

## 10.3 DQ - Night-by-Night Enrollments with Exit Date Discrepancies by Project

**ReportRow** 903 counts enrollments without an *ExitDate* as of <u>ReportEnd</u> (i.e., *ExitDate* is after <u>ReportEnd</u> or is NULL) in continuum night-by-night ES projects that have no record of a bed night in the 90 days ending on <u>ReportEnd</u>.

**ReportRow** 904 counts enrollments with an *ExitDate* in continuum night-by-night ES projects between <u>ReportStart</u> and <u>ReportEnd</u> and where there is no record of a bed night on \[*ExitDate* – 1 day\].

**Value** = a count of distinct *EnrollmentID*s in hmis\_Enrollment where:

-   hmis\_Project.*ProjectType* = 1; and
-   hmis\_Project.*ContinuumProject* = 1; and
-   There is a record for the *HouseholdID* in tlsa\_HHID (i.e., the household was active in <u>ReportCoC</u>)
    -   *ExitDate* is NULL or *ExitDate* > <u>ReportEnd</u>; and
        -   **LastBedNight** <= \[CohortEnd – 90 days\](**ReportRow** 903); or
    -   *ExitDate* between <u>ReportStart</u> and <u>ReportEnd</u> and **LastBedNight** <> *ExitDate* – 1 day\] (**ReportRow** 904)

In this context, **LastBedNight** is the most recent bed night for the enrollment on or before <u>ReportEnd</u>.

## 10.4 DQ - Counts of Households with no EnrollmentCoC by Project

**ReportRow** 905 counts households that are active in a continuum ES/SH/TH/RRH/PSH/RRHSO project during the report period and whose enrollment(s) are not associated with any CoC.

**Value** = a count of distinct *HouseholdID*s in hmis\_Enrollment where:

-   *ProjectID* = lsa\_Project.**ProjectID** and *ProjectType* is not in (9,10); and
-   *EntryDate* <= <u>ReportEnd</u>; and
-   *ExitDate* is NULL or
    -   *ExitDate* >= <u>ReportStart</u>; and
    -   *ExitDate* > *EntryDate*
-   There is no hmis\_Enrollment record where:
    -   *EnrollmentCoC* is not NULL; and
    -   *RelationshipToHoH* = 1

## 10.5 DQ – Enrollments in Non-Participating Projects

**ReportRow** 906 counts enrollments in hmis\_Enrollment that are active during the report period and overlap with a period in which the project was not identified as participating in HMIS. This may include enrollments that were excluded from the LSA entirely and/or enrollments used in LSA reporting with adjusted entry/exit dates.

**Value** = a count of distinct *EnrollmentID*s in hmis\_Enrollment where:

-   *ProjectID* = lsa\_Project.**ProjectID** and *ProjectType* is not in (9,10); and
-   *EntryDate* <= <u>ReportEnd</u>; and
-   *ExitDate* is NULL or
    -   *ExitDate* >= <u>ReportStart</u>; and
    -  *ExitDate* > *EntryDate*
-   *EnrollmentCoC* \= <u>ReportCoC</u> for the head of household’s enrollment; and
-   There is no record in lsa\_HMISParticipation for the **ProjectID** where:
-   **HMISParticipationType** = 1 and **HMISParticipationStatusStartDate** <= *EntryDate*; and
    -   **HMISParticipationStatusEndDate** is null; or
    -   **HMISParticipationStatusEndDate** >= *ExitDate;* or
    -   *ExitDate* is null and **HMISParticipationStatusEndDate** > <u>ReportEnd</u>

## 10.6 DQ – Enrollments Active in LSA Projects During the Report Period without Exactly One HoH

**ReportRow** 907 counts enrollments that are active in a continuum ES/SH/TH/RRH/PSH/RRHSO project during the report period and do not have exactly one HoH.

**Value** = a count of distinct *EnrollmentID*s in hmis\_Enrollment where:

-   *ProjectID* = lsa\_Project.**ProjectID** and lsa\_Project.**ProjectType** is not in (9,10)
-   *EnrollmentCoC* for the head of household’s enrollment = <u>ReportCoC</u>
-   *ExitDate* is null or *ExitDate* \>= <u>ReportStart</u>; and
-   *ExitDate* is null or *ExitDate* \> *EntryDate*; and
-   The count of *PersonalID*s in hmis\_Enrollment with the same *HouseholdID* and a *RelationshipToHoH* \= 1 <> 1

## DQ – Enrollments Active in LSA Projects without a Valid Relationship to HoH

**ReportRow** 908 counts enrollments that are active in a continuum ES/SH/TH/RRH/PSH/RRHSO project during the report period and do not have a valid *RelationshipToHoH.*.

**Value** = a count of distinct *EnrollmentID*s in hmis\_Enrollment where:

-   *ProjectID* = lsa\_Project.**ProjectID** and lsa\_Project.**ProjectType** is not in (9,10)
-   *EnrollmentCoC* for the head of household’s enrollment = <u>ReportCoC</u>
-   *ExitDate* is null or *ExitDate* \>= <u>ReportStart</u>; and
-   *ExitDate* is null or *ExitDate* \> *EntryDate*; and
-   *RelationshipToHoH* is NULL or not in (1,2,3,4,5)

## DQ – Household Entry

The **Value** for **ReportRow** 909 is a count of distinct **HouseholdID**s in tlsa\_HHID where **AIR** \= 1 or (**<u>LSAScope</u>** <> 3 and **Active** \= 1).

## DQ – Client Entry

The **Value** for **ReportRow** 910 is a count of distinct **EnrollmentID**s in tlsa\_Enrollment where **AIR** \= 1 or (**<u>LSAScope</u>** <> 3 and **Active** \= 1).

## DQ – Adult/HoH Entry

The **Value** for **ReportRow** 911 is a count of distinct **EnrollmentID**s in tlsa\_Enrollment where **AIR** \= 1 or (**<u>LSAScope</u>** <> 3 and **Active** \= 1) and:

-   **ActiveAge** between 18 and 65; or
-   **RelationshipToHoH** = 1.

## DQ – Client Exit

The **Value** for **ReportRow** 912 is a count of distinct **PersonalID**s in tlsa\_Enrollment where **AIR** \= 1 or (**<u>LSAScope</u>** <> 3 and **Active** \= 1) and **ExitDate** is not NULL.

## DQ – Disabling Condition

This is a subset of **ClientEntry** (the **Value** for **ReportRow** 910).

The **Value** for **ReportRow** 913 is a count of distinct **EnrollmentIDs** in tlsa\_Enrollment for **ProjectID**s in lsa\_Project where where **AIR** \= 1 or (**<u>LSAScope</u>** <> 3 and **Active** \= 1) and:

-   DisabilityStatus = 99.

## DQ – Living Situation

This is a subset of **AdultHoHEntry**(the **Value** for **ReportRow** 911).

The **Value** for **ReportRow** 914 is a count of distinct **EnrollmentIDs** in tlsa\_Enrollment for **ProjectID**s in lsa\_Project where where **AIR** \= 1 or (**<u>LSAScope</u>** <> 3 and **Active** \= 1) and:

-   **LivingSituation** in (8,9,99) or is NULL; and
-   **ActiveAge** between 18 and 65 or **RelationshipToHoH** = 1

## DQ – Length of Stay

This is a subset of **AdultHoHEntry** (the **Value** for **ReportRow** 911).

The **Value** for **ReportRow** 915 is a count of distinct **EnrollmentIDs** in tlsa\_Enrollment for **ProjectID**s in lsa\_Project where where **AIR** \= 1 or (**<u>LSAScope</u>** <> 3 and **Active** \= 1) and:

-   *LengthOfStay* in (8,9,99) or is NULL; and
-   **ActiveAge** between 18 and 65 or **RelationshipToHoH** = 1

## DQ – Date ES/SH/Street Homelessness Started

This is a subset of **AdultHoHEntry**(the **Value** for **ReportRow** 911).

The **Value** for **ReportRow** 916 is a count of distinct **EnrollmentIDs** in tlsa\_Enrollment for **ProjectID**s in lsa\_Project where where **AIR** \= 1 or (**<u>LSAScope</u>** <> 3 and **Active** \= 1) and:

-   **ActiveAge** between 18 and 65 or **RelationshipToHoH** = 1; and
-   *DateToStreetESSH* > *EntryDate*; or
-   *DateToStreetESSH* is NULL; and
    -   **LSAProjectType** in (0,1,8); or
    -   *LivingSituation* in (101,116,118); or
    -   *PreviousStreetESSH* = 1.

## DQ – Times ES/SH/Street Homeless Last 3 Years

This is a subset of **AdultHoHEntry** (the **Value** for **ReportRow** 911).

The **Value** for **ReportRow** 917 is a count of distinct **EnrollmentIDs** in tlsa\_Enrollment for **ProjectID**s in lsa\_Project where where **AIR** \= 1 or (**<u>LSAScope</u>** <> 3 and **Active** \= 1) and:

-   **ActiveAge** between 18 and 65 or **RelationshipToHoH** = 1; and
-   *TimesHomelessPastThreeYears* is NULL or not in (1,2,3,4); and
    -   **LSAProjectType** in (0,1,8); or
    -   *LivingSituation* in (101,116,118); or
    -   *PreviousStreetESSH* = 1.

## DQ – Months ES/SH/Street Homeless Last 3 Years

This is a subset of **AdultHoHEntry**(the **Value** for **ReportRow** 911).

The **Value** for **ReportRow** 918 is a count of distinct **EnrollmentIDs** in tlsa\_Enrollment for **ProjectID**s in lsa\_Project where where **AIR** \= 1 or (**<u>LSAScope</u>** <> 3 and **Active** \= 1) and:

-   **ActiveAge** between 18 and 65 or **RelationshipToHoH** = 1; and
-   *MonthsHomelessPastThreeYears* is NULL or not between 101 and 113; and
    -   **LSAProjectType** in (0,1,8); or
    -   *LivingSituation* in (101,116,118); or
    -   *PreviousStreetESSH* = 1.

## DQ – Destination

This is a subset of **ClientExit** (the **Value** for **ReportRow** 912).

The **Value** for **ReportRow** 919 is a count of distinct **EnrollmentIDs** in tlsa\_Enrollment for **ProjectID**s in lsa\_Project where where **AIR** \= 1 or (**<u>LSAScope</u>** <> 3 and **Active** \= 1) and:

-   **ExitDate** is not NULL; and
    -   *Destination* is NULL or in (8,9,17,30,99) or
    -   *Destination* = 435 and hmis\_Exit.*DestinationSubsidyType* is NULL

## DQ – Date of Birth

The **Value** for **ReportRow** 920 is a count of distinct **PersonalIDs** in tlsa\_Enrollment for **ProjectID**s in lsa\_Project where where **AIR** \= 1 or (**<u>LSAScope</u>** <> 3 and **Active** \= 1) and **ActiveAge** in (98,99).

## LSACalculated

LSACalculated has nine columns. Except for **ProjectID,** the datatype for all columns is integer and none may be NULL.

**Value** for every record must be greater than zero; neither averages nor counts are generated when there are no records that meet criteria specific to the household type, population, cohort, etc.

The data type for the **ProjectID** column is an alphanumeric string of no more than 32 characters.

-   If **Universe** <> 10, **ProjectID** must be NULL.
-   If **Universe** \= 10, **ProjectID** may not be NULL.
