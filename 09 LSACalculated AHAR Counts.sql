/*

LSA FY2021 Sample Code
Name:  09 LSACalculated AHAR Counts .sql  
Date:  23 SEP 2021   
	
Uses static reference tables:
	ref_RowValues - Required Cohort, Universe, SystemPath values for each RowID
	ref_RowPopulations - Required Populations for each RowID 
					and (for rows 1-9) whether the RowID is required by SystemPath for the Population
	ref_PopHHTypes -  HHTypes required in LSACalculated for each Population by PopID
Populates and references:
	tlsa_CountPops - By PopID -- HoHID, HHType, and Cohort for each population member
	
  9 Populations for AHAR Counts 
*/
	delete from tlsa_CountPops 

	insert into tlsa_CountPops (PopID, HouseholdID, Step)
	select 10, HouseholdID, '9.1.1' 
	from tlsa_HHID
	where ahar = 1 and HHAdultAge = 18 
	and tlsa_HHID.ActiveHHType in (select HHType from ref_PopHHTypes where PopID = 10)

	insert into tlsa_CountPops (PopID, HouseholdID, Step)
	select 11, HouseholdID, '9.1.2' 
	from tlsa_HHID
	where ahar = 1 and HHAdultAge = 24 
	and tlsa_HHID.ActiveHHType in (select HHType from ref_PopHHTypes where PopID = 11)

	insert into tlsa_CountPops (PopID, HouseholdID, Step)
	select 12, HouseholdID, '9.1.3' 
	from tlsa_HHID
	where ahar = 1 and HHParent = 1 and HHAdultAge in (18,24)
	and tlsa_HHID.ActiveHHType = 2

	insert into tlsa_CountPops (PopID, HouseholdID, Step)
	select 13, HouseholdID, '9.1.4' 
	from tlsa_HHID
	where ahar = 1 and HHVet = 1
	and tlsa_HHID.ActiveHHType in (select HHType from ref_PopHHTypes where PopID = 13)

	insert into tlsa_CountPops (PopID, HouseholdID, Step)
	select 14, HouseholdID, '9.1.5' 
	from tlsa_HHID
	where ahar = 1 and HHVet = 0 and HHAdultAge in (25,55)
	and tlsa_HHID.ActiveHHType in (select HHType from ref_PopHHTypes where PopID = 14)

	insert into tlsa_CountPops (PopID, HouseholdID, Step)
	select 15, HouseholdID, '9.1.6' 
	from tlsa_HHID
	where ahar = 1 and HHChronic = 1
	and tlsa_HHID.ActiveHHType in (select HHType from ref_PopHHTypes where PopID = 15)

	insert into tlsa_CountPops (PopID, HouseholdID, Step)
	select 18, HouseholdID, '9.1.7' 
	from tlsa_HHID
	where ahar = 1 and HHDisability = 1
		and tlsa_HHID.ActiveHHType in (select HHType from ref_PopHHTypes where PopID = 18)

	insert into tlsa_CountPops (PopID, HouseholdID, Step)
	select 19, HouseholdID, '9.1.8'
	from tlsa_HHID
	where ahar = 1 and HHFleeingDV = 1
	and tlsa_HHID.ActiveHHType in (select HHType from ref_PopHHTypes where PopID = 19)

	insert into tlsa_CountPops (PopID, HouseholdID, Step)
	select 34, HouseholdID, '9.1.9' 
	from tlsa_HHID
	where ahar = 1 and HHAdultAge = 55
	and tlsa_HHID.ActiveHHType = 1

	insert into tlsa_CountPops (PopID, HouseholdID, Step)
	select 35, HouseholdID, '9.1.10' 
	from tlsa_HHID
	where ahar = 1 and HHParent = 1
	and tlsa_HHID.ActiveHHType in (select HHType from ref_PopHHTypes where PopID = 35)

	insert into tlsa_CountPops (PopID, PersonalID, Step) 
	select 50, n.PersonalID, '9.1.11' 
	from tlsa_Enrollment n 
	inner join tlsa_Person lp on lp.PersonalID = n.PersonalID 
	where n.AHAR = 1 and lp.VetStatus = 1

	insert into tlsa_CountPops (PopID, PersonalID, HouseholdID, Step) 
	select 51, hhid.HoHID, hhid.HouseholdID, '9.1.12'
	from tlsa_HHID hhid 
	where hhid.AHAR = 1 and hhid.HHAdultAge in (18,24) and hhid.HHParent = 1 and hhid.ActiveHHType = 2

	insert into tlsa_CountPops (PopID, PersonalID, HouseholdID, Step) 
	select 52, hhid.HoHID, hhid.HouseholdID, '9.1.13' 
	from tlsa_HHID hhid 
	where hhid.AHAR = 1 and hhid.HHParent = 1 and hhid.ActiveHHType = 3

	insert into tlsa_CountPops (PopID, PersonalID, Step) 
	select 53, n.PersonalID, '9.1.14' 
	from tlsa_Enrollment n 
	inner join tlsa_Person lp on lp.PersonalID = n.PersonalID 
	where n.AHAR = 1 and lp.DisabilityStatus = 1 and (
		(lp.CHTime = 365 and lp.CHTimeStatus in (1,2))
		or (lp.CHTime = 400 and lp.CHTimeStatus = 2))

	insert into tlsa_CountPops (PopID, PersonalID, Step) 
	select 54, n.PersonalID, '9.1.15' 
	from tlsa_Enrollment n 
	inner join tlsa_Person lp on lp.PersonalID = n.PersonalID 
	where n.AHAR = 1 and lp.DisabilityStatus = 1

	insert into tlsa_CountPops (PopID, PersonalID, Step) 
	select 55, n.PersonalID, '9.1.16' 
	from tlsa_Enrollment n 
	inner join tlsa_Person lp on lp.PersonalID = n.PersonalID 
	where n.AHAR = 1 and lp.DVStatus = 1

	insert into tlsa_CountPops (PopID, PersonalID, HouseholdID, Step) 
	select case when lp.Race = 5 and lp.Ethnicity <> 1 then 56
		when lp.Race = 5 and lp.Ethnicity <> 1 then 57
		when lp.Race = 5 and lp.Ethnicity = 1 then 58
		when lp.Race = 3 and lp.Ethnicity <> 1 then 59
		when lp.Race = 3 and lp.Ethnicity = 1 then 60
		when lp.Race = 2 then 61
		when lp.Race = 1 and lp.Ethnicity <> 1 then 62
		when lp.Race = 1 and lp.Ethnicity = 1 then 63
		else 64 end
		, n.PersonalID, n.HouseholdID, '9.1.17' 
	from tlsa_Enrollment n 
	inner join tlsa_Person lp on lp.PersonalID = n.PersonalID 
	where n.AHAR = 1 and lp.Race not in (-1,98,99) 

	insert into tlsa_CountPops (PopID, PersonalID, HouseholdID, Step) 
	select case when lp.Ethnicity = 0 then 65
		else 66 end, n.PersonalID, n.HouseholdID, '9.1.18' 
	from tlsa_Enrollment n 
	inner join tlsa_Person lp on lp.PersonalID = n.PersonalID 
	where n.AHAR = 1 and lp.Ethnicity in (0,1)

	insert into tlsa_CountPops (PopID, PersonalID, HouseholdID, Step) 
	select case lp.Gender
		when 1 then 67
		when 2 then 68
		when 3 then 69
		when 4 then 70
		else 71 end, n.PersonalID, n.HouseholdID, '9.1.19' 
	from tlsa_Enrollment n 
	inner join tlsa_Person lp on lp.PersonalID = n.PersonalID 
	where n.AHAR = 1 and lp.Gender between 1 and 5

	insert into tlsa_CountPops (PopID, PersonalID, Step) 
	select case max(n.ActiveAge)
		when 0 then 72
		when 2 then 73
		when 5 then 74
		when 17 then 75
		when 21 then 76
		when 24 then 77
		when 34 then 78
		when 44 then 79
		when 54 then 80
		when 64 then 81
		else 82 end
		, n.PersonalID, '9.1.20'
	from tlsa_Enrollment n 
	where n.ActiveAge not in (98,99) and n.AHAR = 1 
	group by n.PersonalID

	insert into tlsa_CountPops (PopID, PersonalID, HouseholdID, Step)
	select case when hhid.ActiveHHType = 1 and n.ActiveAge = 21 then 1176
			when hhid.ActiveHHType = 1 and n.ActiveAge = 24 then 1177
			when hhid.ActiveHHType = 2 and n.ActiveAge = 21 then 1276
			else 1277 end
		, n.PersonalID, hhid.HouseholdID, '9.1.21'
	from tlsa_Enrollment n
	inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
	where hhid.HHAdultAge in (18,24)
		and (ActiveHHType = 1 or (ActiveHHType = 2 and HHParent = 1)) 

    insert into tlsa_CountPops (PopID, PersonalID, HouseholdID, Step)
	select rp.PopID, p1.PersonalID, p1.HouseholdID, '9.1.22'
	from ref_RowPopulations rp
	inner join tlsa_CountPops p1 on p1.PopID = rp.Pop1
	inner join tlsa_CountPops p2 on p2.PopID = rp.Pop2 and (p2.PersonalID = p1.PersonalID or p1.PersonalID is NULL)
		and (p2.HouseholdID = p1.HouseholdID or p1.HouseholdID is null)
	where rp.RowMin >= 53 and rp.RowMax <> 64

/*
	9.2 Identify Point-in-Time Cohorts for AHAR Counts
*/

update n
set PITOctober = case when cd1.Cohort is null then 0 else 1 end
  , PITJanuary = case when cd2.Cohort is null then 0 else 1 end
  , PITApril = case when cd3.Cohort is null then 0 else 1 end
  , PitJuly = case when cd4.Cohort is null then 0 else 1 end
  , Step = '9.2.1'
from tlsa_Enrollment n
left outer join tlsa_CohortDates cd1 on cd1.CohortEnd >= n.EntryDate 
	and (cd1.CohortStart < n.ExitDate or n.ExitDate is NULL) and cd1.Cohort = 10
left outer join tlsa_CohortDates cd2 on cd2.CohortEnd >= n.EntryDate 
	and (cd2.CohortStart < n.ExitDate or n.ExitDate is NULL) and cd2.Cohort = 11
left outer join tlsa_CohortDates cd3 on cd3.CohortEnd >= n.EntryDate 
	and (cd3.CohortStart < n.ExitDate or n.ExitDate is NULL) and cd3.Cohort = 12
left outer join tlsa_CohortDates cd4 on cd4.CohortEnd >= n.EntryDate 
	and (cd4.CohortStart < n.ExitDate or n.ExitDate is NULL) and cd4.Cohort = 13
where n.LSAProjectType in (0,2,8) 
	and n.AHAR = 1

update n
set PITOctober = case when cd1.Cohort is null then 0 else 1 end
  , PITJanuary = case when cd2.Cohort is null then 0 else 1 end
  , PITApril = case when cd3.Cohort is null then 0 else 1 end
  , PitJuly = case when cd4.Cohort is null then 0 else 1 end
  , Step = '9.2.2'
from tlsa_Enrollment n
inner join hmis_Services bn on bn.EnrollmentID = n.EnrollmentID
left outer join tlsa_CohortDates cd1 on cd1.CohortStart = bn.DateProvided and cd1.Cohort = 10
left outer join tlsa_CohortDates cd2 on cd2.CohortStart = bn.DateProvided and cd2.Cohort = 11 
left outer join tlsa_CohortDates cd3 on cd3.CohortStart = bn.DateProvided and cd2.Cohort = 12 
left outer join tlsa_CohortDates cd4 on cd4.CohortStart = bn.DateProvided and cd2.Cohort = 13 
where n.LSAProjectType = 1
	and n.AHAR = 1

update n
set PITOctober = case when cd1.Cohort is null then 0 else 1 end
  , PITJanuary = case when cd2.Cohort is null then 0 else 1 end
  , PITApril = case when cd3.Cohort is null then 0 else 1 end
  , PitJuly = case when cd4.Cohort is null then 0 else 1 end
  , Step = '9.2.3'
from tlsa_Enrollment n
left outer join tlsa_CohortDates cd1 on cd1.CohortEnd >= n.MoveInDate 
	and (cd1.CohortStart < n.ExitDate or n.ExitDate is NULL) and cd1.Cohort = 10
left outer join tlsa_CohortDates cd2 on cd2.CohortEnd >= n.MoveInDate 
	and (cd2.CohortStart < n.ExitDate or n.ExitDate is NULL) and cd2.Cohort = 11
left outer join tlsa_CohortDates cd3 on cd3.CohortEnd >= n.MoveInDate 
	and (cd3.CohortStart < n.ExitDate or n.ExitDate is NULL) and cd3.Cohort = 12
left outer join tlsa_CohortDates cd4 on cd4.CohortEnd >= n.MoveInDate 
	and (cd4.CohortStart < n.ExitDate or n.ExitDate is NULL) and cd4.Cohort = 13
where n.LSAProjectType = 3 
	and n.AHAR = 1

update n
set PITOctober = case when cd1.Cohort is null then 0 else 1 end
  , PITJanuary = case when cd2.Cohort is null then 0 else 1 end
  , PITApril = case when cd3.Cohort is null then 0 else 1 end
  , PitJuly = case when cd4.Cohort is null then 0 else 1 end
  , Step = '9.2.4'
from tlsa_Enrollment n
left outer join tlsa_CohortDates cd1 on cd1.CohortEnd >= n.MoveInDate 
	and (cd1.CohortStart < n.ExitDate 
			or n.ExitDate is NULL
			or (cd1.CohortStart = n.ExitDate and cd1.CohortStart = n.MoveInDate)) and cd1.Cohort = 10
left outer join tlsa_CohortDates cd2 on cd2.CohortEnd >= n.MoveInDate 
	and (cd2.CohortStart < n.ExitDate  
			or n.ExitDate is NULL
			or (cd2.CohortStart = n.ExitDate and cd2.CohortStart = n.MoveInDate)) and cd2.Cohort = 11
left outer join tlsa_CohortDates cd3 on cd3.CohortEnd >= n.MoveInDate 
	and (cd3.CohortStart < n.ExitDate  
			or n.ExitDate is NULL
			or (cd3.CohortStart = n.ExitDate and cd3.CohortStart = n.MoveInDate)) and cd3.Cohort = 12
left outer join tlsa_CohortDates cd4 on cd4.CohortEnd >= n.MoveInDate 
	and (cd4.CohortStart < n.ExitDate  
			or n.ExitDate is NULL
			or (cd4.CohortStart = n.ExitDate and cd4.CohortStart = n.MoveInDate)) and cd4.Cohort = 13
where n.LSAProjectType = 13 
	and n.AHAR = 1

/*
	9.3 Counts of People and Households by Project and Household Characteristics

*/
	
	delete from lsa_Calculated where ReportRow > 17

	insert into lsa_Calculated (Value, Cohort, Universe, HHType, Population, SystemPath, ProjectID
		, ReportRow, ReportID, Step)
	select distinct case when rv.RowID = 53 then count(distinct n.PersonalID) else count(distinct n.HouseholdID) end
		, rv.Cohort, rv.Universe, hhid.ActiveHHType, rp.PopID, rv.SystemPath
		, case when rv.Universe = 10 then hhid.ProjectID else null end
		, rv.RowID, (select ReportID from lsa_Report), '9.3.1'
	from ref_RowValues rv
	inner join ref_RowPopulations rp on rv.RowID between rp.RowMin and rp.RowMax 
	inner join ref_PopHHTypes ph on ph.PopID = rp.PopID
	inner join tlsa_CountPops pop on rp.PopID = pop.PopID
	inner join tlsa_HHID hhid on rp.PopID = 0 or hhid.HouseholdID = pop.HouseholdID
		and (hhid.ActiveHHType = ph.HHType or ph.HHType = 0)
		and (
				rv.Universe = 10 
				or (rv.Universe = 11 and hhid.LSAProjectType in (0,1))
				or (rv.Universe = 12 and hhid.LSAProjectType = 8)
				or (rv.Universe = 13 and hhid.LSAProjectType = 2)
				or (rv.Universe = 14 and hhid.LSAProjectType = 13)
				or (rv.Universe = 15 and hhid.LSAProjectType = 3)
				or (rv.Universe = 16 and hhid.LSAProjectType in (0,1,2,8))
			)
	inner join tlsa_Enrollment n on n.HouseholdID = hhid.HouseholdID
			and case rv.Cohort	
				when 1 then n.AHAR
				when 10 then n.PITOctober
				when 11 then n.PITJanuary
				when 12 then n.PITApril
				else n.PITJuly end = 1 
		where rv.RowID in (53,54)
		group by rv.RowID, rv.Cohort, rv.Universe, hhid.ActiveHHType, rp.PopID, rv.SystemPath
			, case when rv.Universe = 10 then hhid.ProjectID else null end
			, case when rv.RowID = 53 then hhid.HouseholdID else null end

/*
	9.4 Counts of People by Project and Personal Characteristics
*/
	delete from lsa_Calculated where ReportRow = 55 
	insert into lsa_Calculated (Value, Cohort, Universe, HHType, Population, SystemPath, ProjectID
		, ReportRow, ReportID, Step)
	select distinct count(distinct n.PersonalID) 
		, rv.Cohort, rv.Universe, hhid.ActiveHHType, rp.PopID, rv.SystemPath
		, case when rp.ByProject = 1 and rv.Universe = 10 then hhid.ProjectID else null end
		, rv.RowID, (select ReportID from lsa_Report), '9.4.1'
	from ref_RowValues rv
	inner join ref_RowPopulations rp on rv.RowID between rp.RowMin and rp.RowMax 
	inner join ref_PopHHTypes ph on ph.PopID = rp.PopID
	inner join tlsa_CountPops pop on rp.PopID = pop.PopID
	inner join tlsa_HHID hhid on rp.PopID = 0 or hhid.HouseholdID = pop.HouseholdID
		and (rp.PopID = 0 or hhid.HouseholdID = pop.HouseholdID) 
		and (hhid.ActiveHHType = ph.HHType or ph.HHType = 0)
		and (
				rv.Universe = 10 
				or (rv.Universe = 11 and hhid.LSAProjectType in (0,1))
				or (rv.Universe = 12 and hhid.LSAProjectType = 8)
				or (rv.Universe = 13 and hhid.LSAProjectType = 2)
				or (rv.Universe = 14 and hhid.LSAProjectType = 13)
				or (rv.Universe = 15 and hhid.LSAProjectType = 3)
				or (rv.Universe = 16 and hhid.LSAProjectType in (0,1,2,8))
			)
	inner join tlsa_Enrollment n on n.HouseholdID = hhid.HouseholdID
			and (n.PersonalID = pop.PersonalID or pop.PopID = 0)
			and case rv.Cohort	
				when 1 then n.AHAR
				when 10 then n.PITOctober
				when 11 then n.PITJanuary
				when 12 then n.PITApril
				else n.PITJuly end = 1 
		where rv.RowID = 55
		group by  rv.Cohort, rv.Universe, hhid.ActiveHHType, rp.PopID, rv.SystemPath
		, case when rp.ByProject = 1 and rv.Universe = 10 then hhid.ProjectID else null end
		, rv.RowID

/*
	9.5 Counts of Bednights
*/

	-- by project night by night for pop 0
	insert into lsa_Calculated (Value, Cohort, Universe, HHType, Population, SystemPath, ProjectID, ReportRow, ReportID, Step)
	select count(distinct bn.EnrollmentID + cast(bn.DateProvided as varchar)), 1, 10, hhid.ActiveHHType, 0, -1
			, hhid.ProjectID, 56, (select ReportID from lsa_Report), '9.5.1'
		from hmis_Services bn
		inner join tlsa_Enrollment n on n.EnrollmentID = bn.EnrollmentID
		inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID 
		inner join lsa_Report rpt on rpt.ReportStart <= bn.DateProvided and rpt.ReportEnd > bn.DateProvided
		where hhid.LSAProjectType = 1 and bn.RecordType = 200 and bn.DateDeleted is NULL and n.AHAR = 1
		group by hhid.ActiveHHType, hhid.ProjectID

	-- by project night by night for pops 10 and 11
	insert into lsa_Calculated (Value, Cohort, Universe, HHType, Population, SystemPath, ProjectID, ReportRow, ReportID, Step)
	select count(distinct bn.EnrollmentID + cast(bn.DateProvided as varchar)), 1, 10, hhid.ActiveHHType, pop.PopID, -1
			, hhid.ProjectID, 56, (select ReportID from lsa_Report), '9.5.2'
		from hmis_Services bn
		inner join tlsa_Enrollment n on n.EnrollmentID = bn.EnrollmentID
		inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID 
		inner join tlsa_CountPops pop on pop.HouseholdID = n.HouseholdID and pop.PopID in (10,11)
		inner join lsa_Report rpt on rpt.ReportStart <= bn.DateProvided and rpt.ReportEnd > bn.DateProvided
		where hhid.LSAProjectType = 1 and bn.RecordType = 200 and bn.DateDeleted is NULL and n.AHAR = 1
		group by hhid.ActiveHHType, hhid.ProjectID, pop.PopID

	-- by project night by night for pops 50 and 53
	insert into lsa_Calculated (Value, Cohort, Universe, HHType, Population, SystemPath, ProjectID, ReportRow, ReportID, Step)
	select count(distinct bn.EnrollmentID + cast(bn.DateProvided as varchar)), 1, 10, hhid.ActiveHHType, pop.PopID, -1
			, hhid.ProjectID, 57, (select ReportID from lsa_Report), '9.5.3'
		from hmis_Services bn
		inner join tlsa_Enrollment n on n.EnrollmentID = bn.EnrollmentID
		inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID 
		inner join tlsa_CountPops pop on pop.PersonalID = n.PersonalID and pop.PopID in (50,53)
		inner join lsa_Report rpt on rpt.ReportStart <= bn.DateProvided and rpt.ReportEnd > bn.DateProvided
		where hhid.LSAProjectType = 1 and bn.RecordType = 200 and bn.DateDeleted is NULL and n.AHAR = 1
		group by hhid.ActiveHHType, hhid.ProjectID, pop.PopID

	-- by project entry-exit, safe haven, and TH for pop 0
	insert into lsa_Calculated
		(Value, Cohort, Universe, HHType
		, Population, SystemPath, ReportRow, ProjectID, ReportID, Step)
	select count (distinct n.PersonalID + cast(est.theDate as nvarchar))
		, 1, 10, hhid.ActiveHHType
		, 0, -1, 56
		, n.ProjectID
		, rpt.ReportID, '9.5.4'
	from tlsa_Enrollment n 
	inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
	inner join lsa_Report rpt on rpt.ReportEnd >= n.EntryDate
	inner join ref_Calendar est on est.theDate >= n.EntryDate
		and est.theDate >= rpt.ReportStart
		and est.theDate < coalesce(n.ExitDate, dateadd(dd, 1, rpt.ReportEnd))
		and n.LSAProjectType in (0,2,8)
	where hhid.AHAR = 1 
	group by n.ProjectID, rpt.ReportID, hhid.ActiveHHType
	
	-- by project entry-exit, safe haven, and TH for pops 10 and 11
	insert into lsa_Calculated
		(Value, Cohort, Universe, HHType
		, Population, SystemPath, ReportRow, ProjectID, ReportID, Step)
	select count (distinct n.PersonalID + cast(est.theDate as nvarchar))
		, 1, 10, hhid.ActiveHHType
		, pop.PopID, -1, 56
		, n.ProjectID
		, rpt.ReportID, '9.5.5'
	from tlsa_Enrollment n 
	inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
	inner join tlsa_CountPops pop on hhid.HouseholdID = pop.HouseholdID and pop.PopID in (10, 11)
	inner join lsa_Report rpt on rpt.ReportEnd >= n.EntryDate
	inner join ref_Calendar est on est.theDate >= n.EntryDate
		and est.theDate >= rpt.ReportStart
		and est.theDate < coalesce(n.ExitDate, dateadd(dd, 1, rpt.ReportEnd))
		and n.LSAProjectType in (0,2,8)
	where hhid.AHAR = 1 
	group by n.ProjectID, rpt.ReportID, hhid.ActiveHHType, pop.PopID
	
	-- by project entry-exit, safe haven, and TH for pops 50 and 53
	insert into lsa_Calculated
		(Value, Cohort, Universe, HHType
		, Population, SystemPath, ReportRow, ProjectID, ReportID, Step)
	select count (distinct n.PersonalID + cast(est.theDate as nvarchar))
		, 1, 10, hhid.ActiveHHType
		, pop.PopID, -1, 56
		, n.ProjectID
		, rpt.ReportID, '9.5.6'
	from tlsa_Enrollment n 
	inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
	inner join tlsa_CountPops pop on n.HouseholdID = pop.HouseholdID and n.PersonalID = pop.PersonalID and pop.PopID in (50, 53)
	inner join lsa_Report rpt on rpt.ReportEnd >= n.EntryDate
	inner join ref_Calendar est on est.theDate >= n.EntryDate
		and est.theDate >= rpt.ReportStart
		and est.theDate < coalesce(n.ExitDate, dateadd(dd, 1, rpt.ReportEnd))
		and n.LSAProjectType in (0,2,8)
	where hhid.AHAR = 1 
	group by n.ProjectID, rpt.ReportID, hhid.ActiveHHType, pop.PopID
	

	-- by project rrh/psh for pop 0
	insert into lsa_Calculated
		(Value, Cohort, Universe, HHType
		, Population, SystemPath, ReportRow, ProjectID, ReportID, Step)
	select count (distinct n.PersonalID + cast(est.theDate as nvarchar))
		, 1, 10, hhid.ActiveHHType
		, 0, -1, 56
		, n.ProjectID
		, rpt.ReportID, '9.5.7'
	from tlsa_Enrollment n 
	inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
	inner join lsa_Report rpt on rpt.ReportEnd >= n.MoveInDate
	inner join ref_Calendar est on est.theDate >= n.MoveInDate
		and est.theDate >= rpt.ReportStart
		and est.theDate < coalesce(n.ExitDate, dateadd(dd, 1, rpt.ReportEnd))
		and n.LSAProjectType in (3,13)
	where hhid.AHAR = 1 
	group by n.ProjectID, rpt.ReportID, hhid.ActiveHHType
	
	-- by project rrh/psh for pops 10 and 11
	insert into lsa_Calculated
		(Value, Cohort, Universe, HHType
		, Population, SystemPath, ReportRow, ProjectID, ReportID, Step)
	select count (distinct n.PersonalID + cast(est.theDate as nvarchar))
		, 1, 10, hhid.ActiveHHType
		, pop.PopID, -1, 56
		, n.ProjectID
		, rpt.ReportID, '9.5.8'
	from tlsa_Enrollment n 
	inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
	inner join tlsa_CountPops pop on hhid.HouseholdID = pop.HouseholdID and pop.PopID in (10, 11)
	inner join lsa_Report rpt on rpt.ReportEnd >= n.MoveInDate
	inner join ref_Calendar est on est.theDate >= n.MoveInDate
		and est.theDate >= rpt.ReportStart
		and est.theDate < coalesce(n.ExitDate, dateadd(dd, 1, rpt.ReportEnd))
		and n.LSAProjectType in (3,13)
	where hhid.AHAR = 1 
	group by n.ProjectID, rpt.ReportID, hhid.ActiveHHType, pop.PopID
	
	-- by project rrh/psh for pops 50 and 53
	insert into lsa_Calculated
		(Value, Cohort, Universe, HHType
		, Population, SystemPath, ReportRow, ProjectID, ReportID, Step)
	select count (distinct n.PersonalID + cast(est.theDate as nvarchar))
		, 1, 10, hhid.ActiveHHType
		, pop.PopID, -1, 56
		, n.ProjectID
		, rpt.ReportID, '9.5.9'
	from tlsa_Enrollment n 
	inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
	inner join tlsa_CountPops pop on n.HouseholdID = pop.HouseholdID and n.PersonalID = pop.PersonalID and pop.PopID in (50, 53)
	inner join lsa_Report rpt on rpt.ReportEnd >= n.MoveInDate
	inner join ref_Calendar est on est.theDate >= n.MoveInDate
		and est.theDate >= rpt.ReportStart
		and est.theDate < coalesce(n.ExitDate, dateadd(dd, 1, rpt.ReportEnd))
		and n.LSAProjectType in (3,13)
	where hhid.AHAR = 1 
	group by n.ProjectID, rpt.ReportID, hhid.ActiveHHType, pop.PopID	
	
	