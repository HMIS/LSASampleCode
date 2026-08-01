---
layout: default
title: "4 - HMIS Business Logic: Project Descriptor Data for Export"
nav_order: 5
parent: "LSA Programming Specifications"
has_toc: true
last_modified_date: 2026-08-01
---

- Contents
{:toc}

# 4.1 Get Project.csv Records / lsa_Project
``` mermaid

flowchart LR

	R[[lsa_Report]] & C[(hmis_ProjectCoC)]-->HF[(hmis_Project)]-->LP[[lsa_Project]]

	R:::LSA
	LP:::LSA
	C:::HMIS
	HF:::HMIS

	classDef Temp stroke:#FF5978, fill:#FFDFE5, color:#8E2236
	classDef LSA stroke:#FBB35A, fill:#FFEFDB, color:#8F632D 
	classDef HMIS stroke:#374D7C, fill:#E2EBFF, color:#374D7C
	
```

Records exported to Project.csv are included in the LSA output and uploaded to HDX 2.0.

LSA business logic in subsequent steps is dependent on the identification of projects that meet the criteria for inclusion. References to lsa_Project.**ProjectID** are to these projects; references to hmis_Project records or _ProjectID_ are to projects in HMIS.

## Source

| **lsa_Report**            |
|---------------------------|
| ReportStart               |
| ReportEnd                 |
| ReportCoC                 |

| **hmis_Project**          |
|---------------------------|
| (all columns – see below) |

| **hmis_ProjectCoC**       |
|---------------------------|
| CoCCode                   |

## Target

HDX 2.0 validation of Project.csv is generally consistent with the HMIS CSV specifications; differences are noted in the column descriptions below.

| lsa_Project | Column Description |
|----|----|
| ProjectID | (See HMIS CSV documentation) |
| OrganizationID | (See HMIS CSV documentation) |
| ProjectName | Truncate HMIS value in export if \>200 characters |
| ProjectCommonName | n/a – will not be imported |
| OperatingStartDate | (See HMIS CSV documentation) |
| OperatingEndDate | If not NULL, date must be \> <u>LookbackDate</u> |
| ContinuumProject | Must = 1 |
| ProjectType | Must be in (0,1,2,3,8,9,10,13) |
| HousingType | Must be in (1,2,3) unless *RRHSubType* = 1 |
| RRHSubType | Must be NULL unless *ProjectType* = 13; otherwise, must be in (1,2) |
| ResidentialAffiliation | Must be NULL unless *RRHSubType* = 1; otherwise, must be in (0,1) |
| TargetPopulation | (See HMIS CSV documentation) |
| HOPWAMedAssistedLivingFac | (See HMIS CSV documentation) |
| PITCount | (See below) |
| DateCreated | (See HMIS CSV documentation) |
| DateUpdated | (See HMIS CSV documentation) |
| UserID | n/a – will not be imported |
| DateDeleted | NULL |
| ExportID | Must match **ReportID** in LSAReport.csv |

## Logic

### Record Selection: Systemwide LSA

When the **LSAScope** is Systemwide (1) or HIC (3), export records for projects where:
- *ContinuumProject* = Yes (1); and
- *CoCCode* = <u>ReportCoC</u>; and
- *ProjectType* is ES (0 or 1), SH (8), TH (2), RRH (13), PSH (3), or OPH (9 or 10); and
	- *OperatingEndDate* is NULL; or
	- *OperatingEndDate* \> <u>LookbackDate</u> and \> *OperatingStartDate*

All project records that meet the criteria above should be included.

The export of PDDE data includes records for permanent housing project types ‘PH – Housing Only’ (9) and ‘PH – Housing with Services (no disability required for entry)’ (10). With the exception of counts of active clients in Section 9.6 when **LSAScope** = 3 (HIC), this is the only context in which data associated with project types 9 and 10 are relevant to the LSA.

### Record Selection: Project-Focused LSA

If the LSA is being generated for a subset of projects, export records for projects where:

- *CoCCode* = <u>ReportCoC</u>; and
- *ProjectID* is in \[list of user-selected *ProjectID*s\]; and
	- *OperatingEndDate* is NULL; or
	- *OperatingEndDate* \> <u>LookbackDate</u> and \> *OperatingStartDate*

Section 3.1 requires that the projects available to a user for selection when entering report parameters must be limited to  *ProjectType*s ES (0 or 1), SH (8), TH (2), RRH (13), and PSH (3), so records for other project types are never included when  **LSAScope** = 2.

### PITCount

There is no requirement for an HMIS to collect point-in-time counts for non-participating projects, nor is there an HMIS data element defined for this purpose. As such, users generally enter these counts directly into the HDX for the HIC and, as noted above, the value of this column may always be NULL.

However, in systems that do allow manual entry of point-in-time counts, if the **PITCount** column includes a value, the HDX will incorporate it into the HIC if **HMISParticipationType** \<\> 1 on the date of the HIC.

# 4.2 Get Organization.csv Records / lsa_Organization
``` mermaid

flowchart LR

	P[[lsa_Project]]-->HF[(hmis_Organization)]-->LF[[lsa_Organization]]

	P:::LSA
	HF:::HMIS
	LF:::LSA

	classDef Temp stroke:#FF5978, fill:#FFDFE5, color:#8E2236
	classDef LSA stroke:#FBB35A, fill:#FFEFDB, color:#8F632D 
	classDef HMIS stroke:#374D7C, fill:#E2EBFF, color:#374D7C
	
```

Records exported to Organization.csv are included in the LSA output and uploaded to HDX 2.0.

LSA business logic does not utilize Organization data beyond the export of records.

## Source

| **lsa_Project**           |
|---------------------------|
| OrganizationID            |

| **hmis_Organization**     |
|---------------------------|
| (all columns – see below) |

## Target

HDX 2.0 validation of Organization.csv is generally consistent with the HMIS CSV specifications; differences are noted in the column descriptions below.

| lsa_Organization | Column Description |
|----|----|
| OrganizationID | (See HMIS CSV documentation) |
| OrganizationName | Truncate HMIS value in export if \>200 characters |
| VictimServiceProvider | Must be in (0,1) – there must be a valid response in this column |
| OrganizationCommonName | n/a - will not be imported |
| DateCreated | (See HMIS CSV documentation) |
| DateUpdated | (See HMIS CSV documentation) |
| UserID | n/a - will not be imported |
| DateDeleted | NULL |
| ExportID | Must match LSAReport.**ReportID** |

## Logic

Export all Organization records where:

- *OrganizationID* = lsa_Project.**OrganizationID**

Validation for Organization.csv will require exactly one record for every **OrganizationID** included in Project.csv. CoCs will be required to make corrections in HMIS if this is not the case.

Populate **ExportID** with LSAReport.**ReportID***;* the data type for **ExportID** is a string, so **ReportID** must be converted appropriately.

**OrganizationCommonName** and **UserID** may be exported as NULL; regardless of their values, they will not be imported into the HDX 2.0.

# 4.3 Get Funder.csv Records / lsa_Funder
``` mermaid

flowchart LR

	R[[lsa_Report]] & P[[lsa_Project]]-->HF[(hmis_Funder)]-->LF[[lsa_Funder]]

	R:::LSA
	P:::LSA
	HF:::HMIS
	LF:::LSA

	classDef Temp stroke:#FF5978, fill:#FFDFE5, color:#8E2236
	classDef LSA stroke:#FBB35A, fill:#FFEFDB, color:#8F632D 
	classDef HMIS stroke:#374D7C, fill:#E2EBFF, color:#374D7C
	
```
Records exported to Funder.csv are included in the LSA output and uploaded to HDX 2.0.

LSA business logic does not utilize Funder data beyond the export of records.

## Source

| **lsa_Project**           |
|---------------------------|
| ProjectID                 |
| **lsa_Report**            |
| ReportStart               |
| **hmis_Funder**           |
| (all columns – see below) |

## Target

HDX 2.0 validation of Funder.csv is generally consistent with the HMIS
CSV specifications; differences are noted in the column descriptions
below.

| lsa_Funder  | Column Description                |
|-------------|-----------------------------------|
| FunderID    | (See HMIS CSV documentation)      |
| ProjectID   | (See HMIS CSV documentation)      |
| Funder      | (See HMIS CSV documentation)      |
| OtherFunder | (See HMIS CSV documentation)      |
| GrantID     | n/a - will not be imported        |
| StartDate   | (See HMIS CSV documentation)      |
| EndDate     | (See HMIS CSV documentation)      |
| DateCreated | (See HMIS CSV documentation)      |
| DateUpdated | (See HMIS CSV documentation)      |
| UserID      | n/a - will not be imported        |
| DateDeleted | NULL                              |
| ExportID    | Must match LSAReport.**ReportID** |

## Logic

Export all Funder records where:

- *ProjectID* = lsa_Project.**ProjectID**; and
- *EndDate* is NULL or (*EndDate* \>= <u>ReportStart</u> and *EndDate* \> *StartDate*)

Validation for Funder.csv includes the requirements that there must be at least one Funder record for every **ProjectID** included in Project.csv that is active during the report period (i.e., where
Project.**OperatingEndDate** \> <u>ReportStart</u> or Project.**OperatingEndDate** is NULL).

- If there are no Funder records that meet the criteria for inclusion for any given project that is active during the report period, CoCs   will be required to create them.
- If there are Funder records active during the report period for inactive projects, CoCs will be required to enter an end date for   those records that is consistent with Project.**OperatingEndDate**.

Populate **ExportID** with LSAReport.**ReportID***;* the data type for **ExportID** is a string, so **ReportID** must be converted appropriately.

**GrantID** and **UserID** may be exported as NULL; regardless of their values, they will not be imported into the HDX 2.0.

## 4.4 Get ProjectCoC.csv Records / lsa_ProjectCoC
``` mermaid

flowchart LR

	R[[lsa_Report]] & P[[lsa_Project]]-->HF[(hmis_ProjectCoC)]-->LF[[lsa_ProjectCoC]]

	R:::LSA
	P:::LSA
	HF:::HMIS
	LF:::LSA

	classDef Temp stroke:#FF5978, fill:#FFDFE5, color:#8E2236
	classDef LSA stroke:#FBB35A, fill:#FFEFDB, color:#8F632D 
	classDef HMIS stroke:#374D7C, fill:#E2EBFF, color:#374D7C
	
```
Records exported to ProjectCoC.csv are included in the LSA output and uploaded to HDX 2.0.

LSA business logic uses ProjectCoC data to:
- Select project records for export to Project.csv; and 
- Report on geography type for active households in LSAHousehold.

## Source

| **lsa_Project**           |
|---------------------------|
| ProjectID                 |

| **lsa_Report**            |
|---------------------------|
| ReportCoC                 |

| **hmis_ProjectCoC**       |
|---------------------------|
| (all columns – see below) |

## Target

HDX 2.0 validation of ProjectCoC.csv is generally consistent with the HMIS CSV specifications; differences are noted in the column descriptions below.

| lsa_ProjectCoC | Column Description |
|----|----|
| ProjectCoCID | (See HMIS CSV documentation) |
| ProjectID | (See HMIS CSV documentation) |
| CoCCode | (See HMIS CSV documentation) |
| Geocode | Not NULL. *Geocode* has a data type of string and must be exported as such / padded with double quotes so that leading zeroes are not omitted. |
| Address1 | (See HMIS CSV documentation) |
| Address2 | (See HMIS CSV documentation) |
| City | (See HMIS CSV documentation) |
| State | (See HMIS CSV documentation) |
| ZIP | Not NULL. Note that *ZIP* has a data type of string and must be exported as such / padded with double quotes so that leading zeroes are not omitted. If ZIP codes are collected with a four-digit suffix, only the first five digits should be exported. |
| GeographyType | Not NULL / in (1,2,3) |
| DateCreated | (See HMIS CSV documentation) |
| DateUpdated | (See HMIS CSV documentation) |
| UserID | n/a - will not be imported |
| DateDeleted | NULL |
| ExportID | Must match LSAReport.**ReportID** |

## Logic

There must be exactly one ProjectCoC record for every *ProjectID* included in Project.csv. Export only records where *CoCCode* = <u>ReportCoC</u>.

The HMIS CSV allows NULL values for *Geocode*, *ZIP* and *GeographyType.* However, they are mandatory for the LSA and upload validation will fail if those columns do not contain valid values.

Populate **ExportID** with LSAReport.**ReportID***;* the data type for **ExportID** is a string, so **ReportID** must be converted appropriately.

**UserID** may be exported as NULL; regardless of value, it will not be imported into the HDX 2.0.

# 4.5 Get Inventory.csv Records / lsa_Inventory
``` mermaid

flowchart LR

	R[[lsa_Report]] & P[[lsa_Project]]-->HF[(hmis_Inventory)]-->LF[[lsa_Inventory]]

	R:::LSA
	P:::LSA
	HF:::HMIS
	LF:::LSA

	classDef Temp stroke:#FF5978, fill:#FFDFE5, color:#8E2236
	classDef LSA stroke:#FBB35A, fill:#FFEFDB, color:#8F632D 
	classDef HMIS stroke:#374D7C, fill:#E2EBFF, color:#374D7C
	
```

Records exported to Inventory.csv are included in the LSA output and uploaded to HDX 2.0.

LSA business logic does not utilize Inventory data beyond the export of records.

## Source

| **lsa_Report**            |
|---------------------------|
| ReportStart               |
| ReportEnd                 |
| ReportCoC                 |

| **lsa_Project**           |
|---------------------------|
| ProjectID                 |
| ProjectType               |

| **hmis_Inventory**        |
|---------------------------|
| (all columns – see below) |

## Target

HDX 2.0 validation of Inventory.csv is generally consistent with the HMIS CSV specifications; differences are noted in the column descriptions below.

| lsa_Inventory        | Column Description                                                                                                                  |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| InventoryID          | (See HMIS CSV documentation)                                                                                                        |
| ProjectID            | (See HMIS CSV documentation)                                                                                                        |
| CoCCode              | (See HMIS CSV documentation)                                                                                                        |
| HouseholdType        | In (1,3,4)                                                                                                                          |
| Availability         | NULL unless Project.*ProjectType* in (0,1); otherwise, in (1,2,3)                                                                   |
| UnitInventory        | (See HMIS CSV documentation)                                                                                                        |
| BedInventory         | Total number of beds equal to the sum of the seven columns below                                                                    |
| CHVetBedInventory    | Count of dedicated beds for chronically homeless veterans; may not be NULL                                                          |
| YouthVetBedInventory | Count of dedicated beds for veterans between 18 and 24; may not be NULL                                                             |
| VetBedInventory      | Count of dedicated beds for veterans with no requirements based on CH status or age; may not be NULL                                |
| CHYouthBedInventory  | Count of dedicated beds for chronically homeless youth between 18 and 24; may not be NULL                                           |
| YouthBedInventory    | Count of dedicated beds for youth between 18 and 24; may not be NULL                                                                |
| CHBedInventory       | Count of dedicated beds for chronically homeless clients with no requirements based on veteran status or age; may not be NULL       |
| OtherBedInventory    | Count of beds for people experiencing homelessness with no requirements based on CH status, veteran status, or age; may not be NULL |
| ESBedType            | NULL unless *ProjectType* in (0,1); otherwise, in (1,2,3)                                                                           |
| InventoryStartDate   | \< ReportEnd                                                                                                                        |
| InventoryEndDate     | NULL or \>= ReportStart                                                                                                             |
| DateCreated          | (See HMIS CSV documentation)                                                                                                        |
| DateUpdated          | (See HMIS CSV documentation)                                                                                                        |
| UserID               | n/a - will not be imported                                                                                                          |
| DateDeleted          | NULL                                                                                                                                |
| ExportID             | Must match LSAReport.**ReportID**                                                                                                   |

## Logic

The HMIS CSV allows NULL values for *CHVetBedInventory*, *YouthVetBedInventory*, *VetBedInventory*, *CHYouthBedInventory*, *YouthBedInventory*, *CHBedInventory*, and *OtherBedInventory*. They are
mandatory for the LSA and upload validation will fail if those columns do not have valid non-NULL values. If the project does not have beds in a given category, the value should be 0.

*BedInventory* must be equal to the sum of those columns. For projects with no beds dedicated for CH, youth, or veteran populations, *BedInventory* = *OtherBedInventory*.

Export all inventory records where:
- *ProjectID* = lsa_Project.**ProjectID**;
- **ProjectType** \<\> 13 or **RRHSubType** = 2;
- Inventory.*CoCCode =* <u>ReportCoC</u>; and
- *InventoryEndDate* is NULL or (*InventoryEndDate* \>= <u>ReportStart</u>
  and *InventoryEndDate* \> *InventoryStartDate*)

Validation for Inventory.csv will require at least one record for every **ProjectID** included in Project.csv that is active during the report period (i.e., where Project.**OperatingEndDate** \> <u>ReportStart</u> or Project.**OperatingEndDate** is NULL) and not categorized as RRH-SO.

- If there are no inventory records that meet the criteria for inclusion for any given project that is active during the report period, CoCs must enter them into HMIS and re-run the LSA.

- If there are inventory records active during the report period for inactive projects, CoCs will be required to enter an end date for those records that is consistent with Project.**OperatingEndDate**.

Populate *ExportID* with LSAReport.**ReportID***;* the data type for *ExportID* is a string, so values must be padded with quotes.

*UserID* may be exported as NULL; regardless of its value, it will not be imported into the HDX 2.0.

# 4.6 Get HMISParticipation.csv Records / lsa_HMISParticipation
``` mermaid

flowchart LR

	R[[lsa_Report]] & P[[lsa_Project]]-->HF[(hmis_HMISParticipation)]-->LF[[lsa_HMISParticipation]]

	R:::LSA
	P:::LSA
	HF:::HMIS
	LF:::LSA

	classDef Temp stroke:#FF5978, fill:#FFDFE5, color:#8E2236
	classDef LSA stroke:#FBB35A, fill:#FFEFDB, color:#8F632D 
	classDef HMIS stroke:#374D7C, fill:#E2EBFF, color:#374D7C
	
```

Records exported to HMISParticipation.csv are included in the LSA output and uploaded to HDX 2.0.

## Source

| **lsa_Report**             |
| -------------------------- |
| ReportStart                |
| ReportEnd                  |
| ReportCoC                  |

| **lsa_Project**            |
| -------------------------- |
| ProjectID                  |
| OperatingEndDate           |

| **hmis_HMISParticipation** |
| -------------------------- |
| (all columns – see below)  |

## Target

HDX 2.0 validation of HMISParticipation.csv is generally consistent with the HMIS CSV specifications; differences are noted in the column descriptions below.

| lsa_HMISParticipation            | Column Description                |
|----------------------------------|-----------------------------------|
| HMISParticipationID              | (See HMIS CSV documentation)      |
| ProjectID                        | (See HMIS CSV documentation)      |
| HMISParticipationType            | (See HMIS CSV documentation)      |
| HMISParticipationStatusStartDate | (See HMIS CSV documentation)      |
| HMISParticipationStatusEndDate   | (See HMIS CSV documentation)      |
| DateCreated                      | (See HMIS CSV documentation)      |
| DateUpdated                      | (See HMIS CSV documentation)      |
| UserID                           | n/a - will not be imported        |
| DateDeleted                      | NULL                              |
| ExportID                         | Must match LSAReport.**ReportID** |

## Logic

Export all HMISParticipation records where:
- *ProjectID* = lsa_Project.**ProjectID**;
- .**OperatingEndDate** is null or **OperatingEndDate** \> <u>ReportStart</u>

Validation for HMISParticipation.csv will require that HMIS participation status is documented for – at a minimum – all dates in the report period on which the project was operational. If these records do not exist, CoCs must enter them in HMIS and re-run the LSA.

Populate **ExportID** with LSAReport.**ReportID***;* the data type for **ExportID** is a string, so values must be padded with quotes.

**UserID** may be NULL; regardless of its value, it will not be imported into the HDX 2.0.

# 4.7 Get Affiliation.csv Records / lsa_Affiliation
``` mermaid

flowchart LR

	P[[lsa_Project]]-->HF[(hmis_Affiliation)]-->LF[[lsa_HMISParticipation]]

	P:::LSA
	HF:::HMIS
	LF:::LSA

	classDef Temp stroke:#FF5978, fill:#FFDFE5, color:#8E2236
	classDef LSA stroke:#FBB35A, fill:#FFEFDB, color:#8F632D 
	classDef HMIS stroke:#374D7C, fill:#E2EBFF, color:#374D7C
	
```
Records exported to Inventory.csv are included in the LSA output and uploaded to HDX 2.0.

LSA business logic does not utilize Affiliation data beyond the export of records.
## Source

| **lsa_Report**            |
|---------------------------|
| ReportStart               |
| ReportEnd                 |
| ReportCoC                 |

| **lsa_Project**           |
|---------------------------|
| ProjectID                 |
| ProjectType               |
| RRHSubType                |
| ResidentialAffiliation    |
| OperatingEndDate          |

| **hmis_Affiliation**      |
|---------------------------|
| (all columns – see below) |

## Target

HDX 2.0 validation of Affiliation.csv is generally consistent with the HMIS CSV specifications; differences are noted in the column descriptions below.

| lsa_Affiliation | Column Description |
|----|----|
| AffiliationID | (See HMIS CSV documentation) |
| ProjectID | Must match a *ProjectID* in Project.csv where *RRHSubType* = 1 and *ResidentialAffiliation* = 1 |
| ResProjectID | (See HMIS CSV documentation) |
| DateCreated | (See HMIS CSV documentation) |
| DateUpdated | (See HMIS CSV documentation) |
| UserID | n/a - will not be imported |
| DateDeleted | NULL |
| ExportID | Must match LSAReport.**ReportID** |

## Logic

Export all Affiliation records where:
- *ProjectID* = lsa_Project.**ProjectID**;
- **RRHSubType** = 1; and
- **ResidentialAffiliation** = 1; and
- **OperatingEndDate** is null or **OperatingEndDate** \>  <u>ReportStart</u>

Validation for Affiliation.csv requires at least one record for every RRH-SO project identified as having a residential affiliation in Project.csv. If these records do not exist, CoCs must enter them in HMIS and re-run the LSA.

Populate **ExportID** with LSAReport.**ReportID***;* the data type for **ExportID** is a string, so values must be padded with quotes.

**UserID** may be exported as NULL; regardless of its value, it will not be imported into the HDX 2.0.

