
# LSA Sample Code Repository

The Longitudinal System Analysis (LSA) is:
* A report to the US Department of Housing and Urban Development (HUD) as 
* A zip file containing 10 Comma-Separated Values (CSV) files 
* Generated by a Homeless Management Information System (HMIS) 
* For Continuums of Care for the Homeless (CoCs) 
* Submitted annually via HUD's Homelessness Data Exchange (HDX 2.0) 
* Used to produce HUD's Annual Homelessness Assessment Report (AHAR) to Congress and
* Provides the data for Stella, HUD's strategy and analysis tool for CoCs, available on HDX 2.0.

This repository is provided as a supplement to the [LSA Report Specifications](https://www.hudexchange.info/resource/5726/lsa-report-specifications-and-tools/) for the benefit of HMIS vendors. Its purpose is to provide a space for reconciling the LSA specifications to the HMIS Data Standards as required to maintain a compliant HMIS product. The LSA Report Specifications remain the central reference for vendors in regards to creating and maintaining LSA reporting.

## Documentation
The final versions of these documents are available on the [HUD Exchange](https://www.hudexchange.info/resource/5726/lsa-report-specifications-and-tools/). The documents here are working versions that change more frequently and prior to release on the HUD Exchange.  
* LSA Programming Specifications (usually referred to as 'the specs') - a Word document with detailed business logic and step-by-step instructions for producing the LSA based on HMIS data. 
* LSA Data Dictionary - an Excel file that lists file names, columns, and valid values for the 12 CSV files included in an LSA upload.

## Code
The sample code is SQL, and written in SQL Server. Originally, it was not intended for public release -- it was written concurrent with the first version of the specs (FY2018) as a check to make sure the specs were specific enough. It was released on GitHub as a reference.  

## Sample Data
The Sample Data file above includes five ZIP files:  
* Sample HMIS Data - HMIS CSV files  
* Sample LSA Output - LSA CSV files generated by the LSA Sample Code based on the HMIS CSV files using general parameters
* Sample LSA Temp Tables - CSV files of exported data from the temporary tables created by the LSA sample code
* Sample HIC Output - LSA CSV files generated by the LSA sample code based on the HMIS CSV files using HIC parameters
* Sample HIC Temp Tables - CSV files of exported data from the temporary tables with HIC parameters

# Dependencies
In order to run the code as is, a user must have access to a SQL Server (or SQL Server Express) database with:
* Permissions that allow creating tables, inserting records, and exporting CSV files.  
* HMIS data in tables modeled after [HMIS CSV FY2024 v1.4](https://files.hudexchange.info/resources/documents/HMIS-CSV-Format-Specifications-2024.pdf).  Naming conventions for tables use an hmis_ prefix with the CSV file name -- e.g., hmis_Project.

Specifically, the LSA sample code requires the tables listed below. Only records where DateDeleted is NULL are relevant.
* hmis_Organization
* hmis_Project
* hmis_Funder
* hmis_ProjectCoC
* hmis_Inventory
* hmis_Affiliation
* hmis_HMISParticipation
* hmis_Client
* hmis_Enrollment
* hmis_Exit
* hmis_Services
* hmis_HealthAndDV
* hmis_Disabilities



