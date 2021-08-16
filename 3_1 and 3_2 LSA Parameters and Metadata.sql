/*
LSA FY2021 Sample Code

	Name:	3_1 to 3_2 LSA Parameters and Metadata.sql 
	Date:	16 AUG 2021

	The hard-coded values here must be replaced with code to accept actual user-entered parameters 
	and info specific to the HMIS application.
*/
delete from lsa_Report 

insert into lsa_Report (
		  ReportID			--system-generated unique identifier for report process
		, ReportStart		--user-entered start of report period
		, ReportEnd			--user-entered end of report period 
		, ReportCoC			--user-insert into tlsa_Pops (PopID, Cohort, HoHID, HHType) selected HUD Continuum of Care Code
		, SoftwareVendor	--name of vendor  
		, SoftwareName		--name of HMIS application
		, VendorContact		--name of vendor contact
		, VendorEmail		--email address of vendor contact
		, LSAScope			--user-selected 1=systemwide, 2=project-focused
		)
	select
		  12345
		, '10/1/2020'
		, '9/30/2021'
		, 'XX-500'
		, 'Sample Code Inc.'
		, 'LSA Online'
		, 'Molly'			
		, 'molly@squarepegdata.com'
		, 1					

/*
	3.2 Cohort Dates 
*/
	delete from tlsa_CohortDates

	insert into tlsa_CohortDates (Cohort, CohortStart, CohortEnd, ReportID)
	select 1, rpt.ReportStart, rpt.ReportEnd, rpt.ReportID
	from lsa_Report rpt

	insert into tlsa_CohortDates (Cohort, CohortStart, CohortEnd, ReportID)
	select 0, rpt.ReportStart,
		case when dateadd(mm, -6, rpt.ReportEnd) <= rpt.ReportStart 
			then rpt.ReportEnd
			else dateadd(mm, -6, rpt.ReportEnd) end
		, rpt.ReportID
	from lsa_Report rpt

	insert into tlsa_CohortDates (Cohort, CohortStart, CohortEnd, ReportID)
	select -1, dateadd(yyyy, -1, rpt.ReportStart)
		, dateadd(yyyy, -1, rpt.ReportEnd)
		, rpt.ReportID
	from lsa_Report rpt

	insert into tlsa_CohortDates (Cohort, CohortStart, CohortEnd, ReportID)
	select -2, dateadd(yyyy, -2, rpt.ReportStart)
		, dateadd(yyyy, -2, rpt.ReportEnd)
		, rpt.ReportID
	from lsa_Report rpt

	insert into tlsa_CohortDates (Cohort, CohortStart, CohortEnd, ReportID)
	select distinct case cal.mm 
		when 10 then 10
		when 1 then 11 
		when 4 then 12 
		else 13 end
		, cal.theDate
		, cal.theDate
		, rpt.ReportID
	from lsa_Report rpt 
	inner join ref_Calendar cal 
		on cal.theDate between rpt.ReportStart and rpt.ReportEnd
	where (cal.mm = 10 and cal.dd = 31 and cal.yyyy = year(rpt.ReportStart))
		or (cal.mm = 1 and cal.dd = 31 and cal.yyyy = year(rpt.ReportEnd))
		or (cal.mm = 4 and cal.dd = 30 and cal.yyyy = year(rpt.ReportEnd))
		or (cal.mm = 7 and cal.dd = 31 and cal.yyyy = year(rpt.ReportEnd))

	insert into tlsa_CohortDates (Cohort, CohortStart, CohortEnd, ReportID)
	select 20, dateadd(dd, 1, dateadd(yyyy, -3, rpt.ReportEnd)), rpt.ReportEnd, rpt.ReportID
	from lsa_Report rpt

/*