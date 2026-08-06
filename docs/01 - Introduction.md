---
layout: default
title: "1 - Introduction"
nav_order: 2
parent: "LSA Programming Specifications"
has_toc: true
toc_levels: 1..1
last_modified_date: 2026-08-01
---

- Contents
{:toc}

# 1.1 Background 

Every year, the U.S. Department of Housing and Urban Development (HUD) submits an Annual Homeless Assessment Report (AHAR) to the United States Congress. The AHAR is a national-level report that provides information about homeless service providers, people and households experiencing homelessness, and various characteristics of that population. It informs strategic planning for federal, state, and local initiatives designed to prevent and end homelessness.

Nationwide, HUD has tasked Continuums of Care (CoCs) with coordinating homeless services in specific geographic areas. The AHAR is based on data provided annually by these CoCs in the form of three separate aggregate data submissions. US Census and other data are used for contextual analysis.

HUD’s *Notice for Housing Inventory Count (HIC) and Point-in-Time (PIT) Data Collection for Continuum of Care (CoC) Program and the Emergency Solutions Grants (ESG) Program* defines the requirements for two components of continuum-level data used in the AHAR.

**The HIC** provides data related to the capacity and utilization of residential projects dedicated to serving people experiencing homelessness on one night in the last 10 calendar days of January. CoCs provide HIC data to HUD by generating and uploading the report defined by this document, the **Longitudinal System Analysis** (LSA), using the date of the HIC as both the start and end dates.

**The PIT** is a count of sheltered and unsheltered people who are experiencing homelessness on the same night in the last 10 calendar days of January. PIT data are manually entered.

The third component of data provided by CoCs for the AHAR is also submitted to HUD via the LSA using the start and end dates of the fiscal year for which it is being submitted. For people and households served by the CoC during the report period, the LSA includes:
  - Demographic characteristics like age, race/ethnicity, and veteran status;
  - Length of time homeless and patterns of system use;
  - Information specific to populations whose needs and/or eligibility for services may differ from the broader homeless population, such as veterans, people and households experiencing chronic homelessness, and others; and
  - Housing outcomes for those who exit the homeless services system.

The LSA also incorporates follow-up reporting on households and populations who exited the system in three discrete periods: two years prior to the report period, one year prior to the report period, and the first six months of the report period. This includes:
-   Patterns of system use prior to exit;
-   Destination types; and,
-   For those who were served again later by continuum projects, lengths of time between exit and re-engagement or returns to homelessness.

# 1.2 About This Document

## Intended Audience

This document is intended for software and database developers who produce HMIS reporting and are familiar with relational database concepts, Structured Query Language (SQL), as well as other HMIS technical documentation, particularly the HMIS Data Dictionary and the HMIS CSV Format. The document may also be useful to expert-level HMIS system administrators interested in further understanding LSA logic, how HDX 2.0 uses uploaded data to produce report output, or in using the LSA files exported from HMIS to develop custom local reports.

## Purpose and Scope

The primary purpose of this document is to define LSA business logic and programming specifications for:
-   Selection of project descriptor data for export
-   Identification of client cohorts, household types, and special populations included in the LSA based on HMIS data
-   Grouping clients and households into reporting categories
-   Producing and populating LSA CSV files
-   Validating LSA CSV files

## Structure and Content

**Section 1: Introduction** (this section) outlines general concepts related to the LSA and this document.

**Section 2: HDX 2.0 Upload** describes each of the CSV files that are included in the upload. There are five CSV files specific to the LSA:
-   LSAReport.csv
-   LSAHousehold.csv
-   LSAPerson.csv
-   LSAExit.csv
-   LSACalculated.csv

The LSA upload also includes seven CSV files of Project Descriptor Data Elements (PDDEs) defined in the HMIS CSV Specifications:
-   Organization.csv
-   Project.csv
-   Funder.csv
-   ProjectCoC.csv
-   Inventory.csv
-   Affiliation.csv
-   HMISParticipation.csv

**Sections 3 through 11: HMIS Business Logic** details business logic associated with constructing LSA report output from HMIS data. There is an inherent order of operations to some aspects of the process. For example, household members’ ages must be calculated to determine household types for individual HMIS *HouseholdID*s. Household types are required to identify distinct combinations of head of household and household type, which is the basis for counting individual households throughout the LSA.

In this document, LSA business logic is described as a series of discrete steps, each with a specific result. Results are cumulative; the ‘output’ of earlier steps serves as input for later steps. The sequence of steps is consistent with the order of operations, but in practice, many could be combined and executed simultaneously. They are separated here to clarify the business logic associated with individual columns.

To avoid repetition, simplify descriptions, and emphasize various aspects of the logic, several of these steps specify the creation of intermediate data constructs (tables) with column names that function as variables in later steps. There is no requirement to use this process or these constructs as long as output is consistent with the logic described here.

## External References

This document is comprehensive with respect to the business logic for the LSA upload, but additional references are indicated below. The short-hand terms used to refer to each document are in parentheses following the formal names and are hyperlinked to the documents online.

**FY 2026 HMIS Data Standards: Data Dictionary** ([Dictionary](https://files.hudexchange.info/resources/documents/HMIS-Data-Dictionary.pdf)) – The Dictionary defines federal data collection requirements for HMIS applications.

**FY 2026 HMIS CSV Format Specifications** ([HMIS CSV](https://files.hudexchange.info/resources/documents/HMIS-CSV-Format-Specifications.pdf)) – Descriptions of LSA business logic reference HMIS fields using the file and column names of the HMIS CSV.

## Style Notes

Throughout this document, descriptions of business logic reference diverse types of data – HMIS fields, report parameters, derived variables, intermediate data constructs, etc. – and many have similar (or identical) names.

To help clarify, many sections include simple graphics to illustrate the flow of the process. Text formatting of variable/field/column names indicates their context. The conventions used are:

| Example         | Description                                                                                                                                                                                                                                                                                                |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <u>ReportCoC<u> | Report parameters are underlined                                                                                                                                                                                                                                                                           |
| hmis_Project    | HMIS data structures / raw HMIS data are referenced using HMIS CSV file names with an hmis\_ prefix. This assumes the presence/availability of all HMIS data from <u>LookbackDate</u> to <u>ReportEnd</u>.                                                                                   |
| *ProjectID*     | References to HMIS fields / raw HMIS data use HMIS CSV column names and are italicized. *ProjectID* potentially refers to any project record in the HMIS where the operating end date is >= <u>LookbackDate</u>.                                                                                    |
| lsa_Project     | The lsa\_ prefix indicates a CSV file included in the LSA upload and that the data therein is the result of a process / business logic defined by this document.                                                                                                                                           |
| **ProjectID**   | References to variables and/or data created or transformed by the processes described in this document – e.g., columns in LSA CSV files or intermediate data constructs – are in bold. **ProjectID** refers only to project records that meet the criteria for inclusion in the uploaded Project.csv file. |

# 1.3 Definitions/Acronyms

The definitions here are intended to serve as a general reference and are not comprehensive with respect to business logic, which is detailed in later sections.

**AO** – Adult-only household; a household in which all household members have valid dates of birth and are age 18 or older.

**AC** – Adult and child household; a household in which at least one household member is age 18 or older and at least one household member is age 17 or younger and both have valid dates of birth; may include household members without valid dates of birth.

**AIR** – When used in column names, ‘AIR’ indicates that a person or household was active in residence/has at least one bed night in the report period.

**Between** – When used to describe business logic, *between* includes the values used in the description. For example, the report start date and the report end date are both “between <u>ReportStart</u> and <u>ReportEnd</u>.”

**CO** – Child-only household; a household in which all household members have valid dates of birth and are age 17 or younger.

**Cohort** – A group of clients who meet the criteria for inclusion in reporting in a specific period. See also “Exit Cohorts."

**Cohort period** – The period that defines a cohort (e.g. “the first six months of the report period.”)

**Continuous** (in reference to a period of homelessness or enrollment) – A period in which relevant system use for a given client is documented in HMIS and is uninterrupted by any period of seven or more contiguous days of a permanently housed situation, no documented system use, or a combination of those.

**Enrollment** – A period in which a client receives services from a given project, beginning with the *Project Start Date* recorded in HMIS and ending on the *Project Exit Date*.

**ES** – Emergency shelter projects. ES clients are considered to be experiencing homelessness while enrolled; any date between ES project entry and the day prior to exit is included in counts of days in ES/SH or on the street for purposes of determining chronic homelessness *as long as there is no conflicting data that identifies the client as enrolled in TH or housed in RRH/PSH*.

**EST** or **ES/SH/TH** – Emergency shelter, safe haven, and/or transitional housing projects; i.e., residential project types in which all clients are homeless while enrolled. Demographics for clients served in these three project types are reported in the combined ES/SH/TH project group.

**Exit Cohorts** – Groups of households who exited from continuum projects and have no record of relevant system use in HMIS during the following 14 days. There are three exit cohort periods – and thus three exit cohorts – included in the LSA.

**HIC** – Housing Inventory Count; a continuum-level report to HUD listing continuum ES, SH, TH, RRH, PSH, and OPH projects and associated bed and unit inventory dedicated to serving people experiencing homelessness on a single night; submitted to HUD annually via an LSA report generated for the date of the HIC.

**HDX/HDX 2.0** – Homelessness Data Exchange; a HUD website that accepts and stores CoC-level reports, including the HIC, the PIT, the SPM report, and the LSA upload.

**Informational value** – For HMIS data elements, a response category defined by the HMIS Data Standards that provides the information collected in each field.  For example, ‘Yes’ and ‘No’ are both informational values for *3.07 Veteran Status*. ‘Client doesn’t know (8), ‘Client prefers not to answer’ (9), and ‘Data not collected' (99) are not informational; they are explanations for missing data. Response categories ‘Other’ (17) and ‘No exit interview completed’ (30) for *3.12 Destination* are also not informational.

**Lookback Date** – \[<u>ReportStart</u> – 7 years\]. Projects with operating end dates and enrollments with exit dates that occur prior to the <u>LookbackDate</u> are not relevant to the LSA.

**LOTH** – Length of time homeless. LOTH reporting includes counts of households grouped by total number of days in ES, SH, and TH projects, in RRH and PSH projects prior to moving into housing, and in ES/SH or on the street prior to project entry as identified in *3.917 Living Situation*. Although it is not, by definition, ‘homeless,’ time housed in RRH is also included in LOTH output.

**OPH** – Permanent housing project types other than PSH or RRH; specifically, projects typed in HMIS as *PH – Housing Only* (9) or *PH – Housing with Services (no disability required for entry)* (10). Apart from project descriptor data and point-in-time counts for the HIC, data associated with OPH projects is excluded from the LSA.

**PIT Count** – Point in Time Count; a continuum-level report to HUD, required at least every two years, that reports on the total number of people experiencing sheltered and unsheltered homelessness in the geographic area of the continuum on a single night, usually on a night in the last 10 calendar days of January.

**Population** – As used in this document, a group of people in households with one or more members who have specific characteristics that may indicate that the households have needs and/or eligibility for services that differ from the broader homeless population; for example, households fleeing domestic violence or unaccompanied children. The LSA upload includes population-specific output.

**Project group** – ES, SH, and TH (combined), RRH (only), and PSH (only). Demographics reporting for the active cohort is produced separately for each of these three project groups.

**PSH** – Permanent supportive housing for formerly homeless people.

-   PSH clients who are homeless at project entry based on *3.917 Living Situation* are considered to be experiencing homelessness until a documented *3.20 Housing Move-In Date* or exit, whichever comes first.
-   For clients who were in ES/SH or on the street at project entry, all time between *Approximate Date Started* and move-in is counted in determining chronic homelessness.
-   In general, a client may not be counted as experiencing homeless on any date between PSH move-in and the day prior to exit, regardless of other conflicting enrollment data. The only exception to this is for stays of less than seven days, and only if the dates fall between two dates less than seven days apart on which the client is otherwise documented as being on the street or in ES/SH.

**Report period** – The period of time between the report start date and report end date report parameters.

**RRH** – Rapid Re-Housing projects with the sub-type of ‘Housing with or without Services.’

-   RRH clients who are homeless at project entry based on *3.917 Living Situation* are considered to be experiencing homelessness until a documented *3.20 Housing Move-In Date* or exit, whichever comes first.
-   For clients who were in ES/SH or on the street at project entry, all time between *Approximate Date Started* and move-in is counted in determining chronic homelessness.
-   A client may not be counted as experiencing homelessness on any date between RRH move-in and the day prior to exit, regardless of other conflicting enrollment data. The only exception to this is for stays of less than seven days, and only if the dates fall between two dates less than seven days apart on which the client is otherwise documented as being on the street or in ES/SH.

**RRH-SO** – Rapid Re-Housing projects with the sub-type of ‘Services Only.’ This is a new designation with the HMIS Data Standards effective October 1, 2023. For reporting on FY2023 (which ends September 30,2023), RRH-SO enrollment data, if they exist at all, are incorporated in a limited manner:

-   For RRH-SO clients who were in ES/SH or on the street at project entry, all dates between *Approximate Date Started* and the earliest of move-in, exit, or report end are counted in determining chronic homelessness.
-   People and households served in RRH-SO are included in LSAPerson, LSAHousehold, and LSAExit.

**SH** – Safe Haven projects. All SH clients are considered to be experiencing homelessness while enrolled; any date between SH project entry and the day prior to exit is included in counts of days in ES/SH or on the street for purposes of determining chronic homelessness *as long as there is no conflicting enrollment data that identifies the client as enrolled in TH or housed in RRH/PSH*.

**SPM** – HUD’s System Performance Measures report, a CoC-level report uploaded to or manually entered to the HDX.

**System exit** – An exit from a continuum ES, SH, TH, RRH, or PSH project followed by a period of at least 14 days in which the household is not active in any other continuum ES, SH, TH, RRH, or PSH projects.

**System path** – The distinct combination of project types in which a household was enrolled during a continuous period of system use that overlaps with the report/cohort period, including enrollments prior to the start of the report/cohort period.

**TH** – Transitional housing for homeless people. All TH clients are considered to be experiencing homelessness while enrolled; however, no date between TH project entry and the day prior to exit may be included in counts of days in ES/SH or on the street for purposes of determining chronic homelessness, regardless of other conflicting enrollment data. The only exception to this is for stays of less than seven days, and only if the dates fall between two dates less than seven days apart on which the client is otherwise documented as being on the street or in ES/SH.

**UN** – Unknown household type; includes at least one member without a valid date of birth and does not include both an adult and a child.

# 1.4 Changes for Reporting on FY2026

This section is limited to a high-level review of changes. Tracked versions of this document and [more detailed information about each change](https://github.com/HMIS/LSASampleCode/issues?q=type%3A%22LSA%20Update%22) are available in the [GitHub repository](https://github.com/HMIS/LSASampleCode).

## Include Counts of Four Digit Social Security Numbers in LSAReport DQ Counts
A new column ([SSN4Digit](11 - LSAReport.md#ssn4digit)) has been added to the DQ counts in LSAReport to capture the number clients served during the report period with 4 digit SSNs.  These will be excluded from the count of SSNMissingOrInvalid.  

## Update LSAPerson.DisabilityStatus to Include an Option to Indicate Client Doesn't Know or Prefers Not to Answer
Consistent with other demographics, reporting on disability status in LSAPerson will now include both a category for Data not provided by client (98) and Data not collected or invalid (99). Previous versions grouped all responses other than Yes and No under the 99 value.  

## Add a Project-Level Count of NBN Enrollments Excluded from the LSA Because of Missing Bed-Nights
A new count of NBN enrollments excluded from the LSA because there are no bed nights associated with them has been added to LSACalculated as ReportRow 921.  This does not include enrollments that were excluded because they have no bed nights *in the report period* as long as there is at least one bed night record associated with the enrollment prior to the start of the report period. 
