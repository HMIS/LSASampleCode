/*
LSA FY2021 Sample Code

Name:  5_12 to 5_15 LSAPerson Project Group and Population Household Types.sql  
Date:  16 AUG 2021   

	
	5.12 Set Population Identifiers for Active HouseholdIDs
*/

	update hhid
	set hhid.HHChronic = coalesce((select min(
					case when (lp.CHTime = 365 and lp.CHTimeStatus in (1,2))
							or (lp.CHTime = 400 and lp.CHTimeStatus = 2) then 1
						when lp.CHTime in (365, 400) then 2
						when lp.CHTime = 270 and lp.DisabilityStatus = 1 then 3
					else null end)
			from tlsa_Person lp
			inner join tlsa_Enrollment n on n.PersonalID = lp.PersonalID and n.Active = 1 
				and n.RelationshipToHoH = 1 or n.ActiveAge between 18 and 65
			inner join tlsa_HHID hh on hh.HouseholdID = n.HouseholdID
			where n.HouseholdID = hhid.HouseholdID), 0)
		, hhid.HHVet = (select max(
					case when lp.VetStatus = 1 
						and n.ActiveAge between 18 and 65 
						and hh.ActiveHHType <> 3 then 1
					else 0 end)
			from tlsa_Person lp
			inner join tlsa_Enrollment n on n.PersonalID = lp.PersonalID and n.Active = 1
			inner join tlsa_HHID hh on hh.HouseholdID = n.HouseholdID
			where n.HouseholdID = hhid.HouseholdID)
		, hhid.HHDisability = (select max(
				case when lp.DisabilityStatus = 1 
					and (n.ActiveAge between 18 and 65 or n.RelationshipToHoH = 1) then 1
				else 0 end)
			from tlsa_Person lp
			inner join tlsa_Enrollment n on n.PersonalID = lp.PersonalID and n.Active = 1
			where n.HouseholdID = hhid.HouseholdID)
		, hhid.HHFleeingDV = (select max(
				case when lp.DVStatus = 1 
					and (n.ActiveAge between 18 and 65 or n.RelationshipToHoH = 1) then 1
				else 0 end)
			from tlsa_Person lp
			inner join tlsa_Enrollment n on n.PersonalID = lp.PersonalID and n.Active = 1
			where n.HouseholdID = hhid.HouseholdID)
		--Set HHAdultAge for active households based on HH member AgeGroup(s) 
		, hhid.HHAdultAge = (select 
				-- n/a for households with member(s) of unknown age
				case when max(n.ActiveAge) >= 98 then -1
					-- n/a for CO households
					when max(n.ActiveAge) <= 17 then -1
					-- 18-21
					when max(n.ActiveAge) = 21 then 18
					-- 22-24
					when max(n.ActiveAge) = 24 then 24
					-- 55+
					when min(n.ActiveAge) between 64 and 65 then 55
					-- all other combinations
					else 25 end
				from tlsa_Enrollment n 
				where n.HouseholdID = hhid.HouseholdID and n.Active = 1) 
		, hhid.AC3Plus = (select case sum(case when n.ActiveAge <= 17 and hh.ActiveHHType = 2 then 1
								else 0 end) 
							when 0 then 0 
							when 1 then 0 
							when 2 then 0 
							else 1 end
				from tlsa_Enrollment n 
				inner join tlsa_HHID hh on hh.HouseholdID = n.HouseholdID
				where n.Active = 1 and n.HouseholdID = hhid.HouseholdID) 
		, hhid.Step = '5.12.1'
	from tlsa_HHID hhid
	where hhid.Active = 1

	update hhid
	set hhid.HHParent = (select max(
			case when n.RelationshipToHoH = 2 then 1
				else 0 end)
		from tlsa_Enrollment n 
		where n.Active = 1 and n.HouseholdID = hhid.HouseholdID)
		, hhid.Step = '5.12.2'
	from tlsa_HHID hhid
	where hhid.Active = 1


/*
	5.13 Set tlsa_Person Project Group and Population Household Types
*/


	update lp
	set lp.HHTypeEST = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType in (1,2,8)) 
		, lp.HoHEST = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType in (1,2,8)
					and n.RelationshipToHoH = 1) 
		, lp.AdultEST = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType in (1,2,8)
					and n.ActiveAge between 18 and 65) 
		, lp.AHAREST = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.AHAR = 1 and n.ProjectType in (1,2,8)) 
		, lp.AHARHoHEST = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.AHAR= 1 and n.ProjectType in (1,2,8)
					and n.RelationshipToHoH = 1) 
		, lp.AHARAdultEST = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.AHAR = 1 and n.ProjectType in (1,2,8)
					and n.ActiveAge between 18 and 65) 
		, lp.HHChronicEST = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType in (1,2,8)
					and hhid.HHChronic = 1)
		, lp.HHVetEST = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType in (1,2,8)
					and hhid.HHVet = 1)
		, lp.HHDisabilityEST = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType in (1,2,8)
					and hhid.HHDisability = 1)
		, lp.HHFleeingDVEST = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType in (1,2,8)
					and hhid.HHFleeingDV = 1)
		, lp.HHParentEST = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType in (1,2,8)
					and hhid.HHParent = 1)
		, lp.AC3PlusEST = (select sum(distinct case when hhid.AC3Plus = 1 then 1 else 0 end)
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType in (1,2,8)
					and hhid.AC3Plus = 1)
		, lp.HHTypeRRH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType = 13) 
		, lp.HoHRRH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType = 13
					and n.RelationshipToHoH = 1) 
		, lp.AdultRRH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType = 13
					and n.ActiveAge between 18 and 65) 
		, lp.AHARRRH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.AHAR = 1 and n.ProjectType = 13) 
		, lp.AHARHoHRRH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.AHAR = 1 and n.ProjectType = 13
					and n.RelationshipToHoH = 1) 
		, lp.AHARAdultRRH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.AHAR = 1 and n.ProjectType = 13
					and n.ActiveAge between 18 and 65) 
		, lp.HHChronicRRH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType = 13
					and hhid.HHChronic = 1)
		, lp.HHVetRRH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType = 13
					and hhid.HHVet = 1)
		, lp.HHDisabilityRRH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType = 13
					and hhid.HHDisability = 1)
		, lp.HHFleeingDVRRH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType = 13
					and hhid.HHFleeingDV = 1)
		, lp.HHParentRRH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType = 13
					and hhid.HHParent = 1)
		, lp.AC3PlusRRH = (select sum(distinct case when hhid.AC3Plus = 1 then 1 else 0 end)
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType = 13
					and hhid.AC3Plus = 1)
		, lp.HHTypePSH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType = 3) 
		, lp.HoHPSH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType = 3
					and n.RelationshipToHoH = 1) 
		, lp.AdultPSH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType = 3
					and n.ActiveAge between 18 and 65) 
		, lp.AHARPSH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.AHAR = 1 and n.ProjectType = 3) 
		, lp.AHARHoHPSH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.AHAR = 1 and n.ProjectType = 3
					and n.RelationshipToHoH = 1) 
		, lp.AHARAdultPSH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.AHAR = 1 and n.ProjectType = 3
					and n.ActiveAge between 18 and 65) 
		, lp.HHChronicPSH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType = 3
					and hhid.HHChronic = 1)
		, lp.HHVetPSH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType = 3
					and hhid.HHVet = 1)
		, lp.HHDisabilityPSH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType = 3
					and hhid.HHDisability = 1)
		, lp.HHFleeingDVPSH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType = 3
					and hhid.HHFleeingDV = 1)
		, lp.HHParentPSH = (select sum(distinct case hhid.ActiveHHType 
					when 1 then 1000
					when 2 then 200
					when 3 then 30
					else 9 end) 
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType = 3
					and hhid.HHParent = 1)
		, lp.AC3PlusPSH = (select sum(distinct case when hhid.AC3Plus = 1 then 1 else 0 end)
				from tlsa_Enrollment n
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
				where n.PersonalID = lp.PersonalID and n.Active = 1 and n.ProjectType = 3
					and hhid.AC3Plus = 1)
		, lp.Step = '5.13'
	from tlsa_Person lp

	update lp set lp.AdultEST = case lp.AdultEST when 0 then -1 else cast(replace(cast(lp.AdultEST as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.AdultPSH = case lp.AdultPSH when 0 then -1 else cast(replace(cast(lp.AdultPSH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.AdultRRH = case lp.AdultRRH when 0 then -1 else cast(replace(cast(lp.AdultRRH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.AHARAdultEST = case lp.AHARAdultEST when 0 then -1 else cast(replace(cast(lp.AHARAdultEST as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.AHARAdultPSH = case lp.AHARAdultPSH when 0 then -1 else cast(replace(cast(lp.AHARAdultPSH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.AHARAdultRRH = case lp.AHARAdultRRH when 0 then -1 else cast(replace(cast(lp.AHARAdultRRH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.AHAREST = case lp.AHAREST when 0 then -1 else cast(replace(cast(lp.AHAREST as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.AHARHoHEST = case lp.AHARHoHEST when 0 then -1 else cast(replace(cast(lp.AHARHoHEST as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.AHARHoHPSH = case lp.AHARHoHPSH when 0 then -1 else cast(replace(cast(lp.AHARHoHPSH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.AHARHoHRRH = case lp.AHARHoHRRH when 0 then -1 else cast(replace(cast(lp.AHARHoHRRH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.AHARPSH = case lp.AHARPSH when 0 then -1 else cast(replace(cast(lp.AHARPSH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.AHARRRH = case lp.AHARRRH when 0 then -1 else cast(replace(cast(lp.AHARRRH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.HHChronicEST = case lp.HHChronicEST when 0 then -1 else cast(replace(cast(lp.HHChronicEST as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.HHChronicPSH = case lp.HHChronicPSH when 0 then -1 else cast(replace(cast(lp.HHChronicPSH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.HHChronicRRH = case lp.HHChronicRRH when 0 then -1 else cast(replace(cast(lp.HHChronicRRH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.HHDisabilityEST = case lp.HHDisabilityEST when 0 then -1 else cast(replace(cast(lp.HHDisabilityEST as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.HHDisabilityPSH = case lp.HHDisabilityPSH when 0 then -1 else cast(replace(cast(lp.HHDisabilityPSH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.HHDisabilityRRH = case lp.HHDisabilityRRH when 0 then -1 else cast(replace(cast(lp.HHDisabilityRRH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.HHFleeingDVEST = case lp.HHFleeingDVEST when 0 then -1 else cast(replace(cast(lp.HHFleeingDVEST as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.HHFleeingDVPSH = case lp.HHFleeingDVPSH when 0 then -1 else cast(replace(cast(lp.HHFleeingDVPSH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.HHFleeingDVRRH = case lp.HHFleeingDVRRH when 0 then -1 else cast(replace(cast(lp.HHFleeingDVRRH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.HHParentEST = case lp.HHParentEST when 0 then -1 else cast(replace(cast(lp.HHParentEST as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.HHParentPSH = case lp.HHParentPSH when 0 then -1 else cast(replace(cast(lp.HHParentPSH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.HHParentRRH = case lp.HHParentRRH when 0 then -1 else cast(replace(cast(lp.HHParentRRH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.HHTypeEST = case lp.HHTypeEST when 0 then -1 else cast(replace(cast(lp.HHTypeEST as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.HHTypePSH = case lp.HHTypePSH when 0 then -1 else cast(replace(cast(lp.HHTypePSH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.HHTypeRRH = case lp.HHTypeRRH when 0 then -1 else cast(replace(cast(lp.HHTypeRRH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.HHVetEST = case lp.HHVetEST when 0 then -1 else cast(replace(cast(lp.HHVetEST as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.HHVetPSH = case lp.HHVetPSH when 0 then -1 else cast(replace(cast(lp.HHVetPSH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.HHVetRRH = case lp.HHVetRRH when 0 then -1 else cast(replace(cast(lp.HHVetRRH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.HoHEST = case lp.HoHEST when 0 then -1 else cast(replace(cast(lp.HoHEST as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.HoHPSH = case lp.HoHPSH when 0 then -1 else cast(replace(cast(lp.HoHPSH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.HoHRRH = case lp.HoHRRH when 0 then -1 else cast(replace(cast(lp.HoHRRH as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.PSHAgeMax = case lp.PSHAgeMax when 0 then -1 else cast(replace(cast(lp.PSHAgeMax as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.PSHAgeMin = case lp.PSHAgeMin when 0 then -1 else cast(replace(cast(lp.PSHAgeMin as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.RRHAgeMax = case lp.RRHAgeMax when 0 then -1 else cast(replace(cast(lp.RRHAgeMax as varchar), '0', '') as int) end from tlsa_Person lp
	update lp set lp.RRHAgeMin = case lp.RRHAgeMin when 0 then -1 else cast(replace(cast(lp.RRHAgeMin as varchar), '0', '') as int) end from tlsa_Person lp

	   	  
	/*
		5.14 Adult Age Population Identifiers - LSAPerson
	*/
	update lp
	set lp.HHAdultAgeAOEST = coalesce((select case when min(hhid.HHAdultAge) between 18 and 24
					then min(hhid.HHAdultAge) 
				else max(hhid.HHAdultAge) end
				from tlsa_Enrollment n 
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
					and hhid.HHAdultAge between 18 and 55 and hhid.ActiveHHType = 1 
					and hhid.ProjectType in (1,2,8)
				where n.PersonalID = lp.PersonalID and n.Active = 1), -1)
		, lp.HHAdultAgeACEST = coalesce((select case when min(hhid.HHAdultAge) between 18 and 24
					then min(hhid.HHAdultAge) 
				else max(hhid.HHAdultAge) end
				from tlsa_Enrollment n 
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
					and hhid.HHAdultAge between 18 and 55 and hhid.ActiveHHType = 2
					and hhid.ProjectType in (1,2,8)
				where n.PersonalID = lp.PersonalID and n.Active = 1), -1)
		, lp.HHAdultAgeAORRH = coalesce((select case when min(hhid.HHAdultAge) between 18 and 24
					then min(hhid.HHAdultAge) 
				else max(hhid.HHAdultAge) end
				from tlsa_Enrollment n 
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
					and hhid.HHAdultAge between 18 and 55 and hhid.ActiveHHType = 1 
					and hhid.ProjectType = 13
				where n.PersonalID = lp.PersonalID and n.Active = 1), -1)
		, lp.HHAdultAgeACRRH = coalesce((select case when min(hhid.HHAdultAge) between 18 and 24
					then min(hhid.HHAdultAge) 
				else max(hhid.HHAdultAge) end
				from tlsa_Enrollment n 
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
					and hhid.HHAdultAge between 18 and 55 and hhid.ActiveHHType = 2
					and hhid.ProjectType = 13
				where n.PersonalID = lp.PersonalID
					and n.Active = 1), -1)
		, lp.HHAdultAgeAOPSH = coalesce((select case when min(hhid.HHAdultAge) between 18 and 24
					then min(hhid.HHAdultAge) 
				else max(hhid.HHAdultAge) end
				from tlsa_Enrollment n 
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
					and hhid.HHAdultAge between 18 and 55 and hhid.ActiveHHType = 1 
					and hhid.ProjectType = 3
				where n.PersonalID = lp.PersonalID and n.Active = 1), -1)
		, lp.HHAdultAgeACPSH = coalesce((select case when min(hhid.HHAdultAge) between 18 and 24
					then min(hhid.HHAdultAge) 
				else max(hhid.HHAdultAge) end
				from tlsa_Enrollment n 
				inner join tlsa_HHID hhid on hhid.HouseholdID = n.HouseholdID
					and hhid.HHAdultAge between 18 and 55 and hhid.ActiveHHType = 2
					and hhid.ProjectType = 3
				where n.PersonalID = lp.PersonalID and n.Active = 1), -1)
		, lp.Step = '5.14'
	from tlsa_Person lp

/*
	5.15 Select Data for Export to LSAPerson
*/
	-- LSAPerson
	delete from lsa_Person
	insert into lsa_Person (RowTotal
		, Gender, Race, Ethnicity, VetStatus, DisabilityStatus
		, CHTime, CHTimeStatus, DVStatus
		, ESTAgeMin, ESTAgeMax, HHTypeEST, HoHEST, AdultEST, HHChronicEST, HHVetEST, HHDisabilityEST
		, HHFleeingDVEST, HHAdultAgeAOEST, HHAdultAgeACEST, HHParentEST, AC3PlusEST, AHAREST, AHARHoHEST
		, RRHAgeMin, RRHAgeMax, HHTypeRRH, HoHRRH, AdultRRH, HHChronicRRH, HHVetRRH, HHDisabilityRRH
		, HHFleeingDVRRH, HHAdultAgeAORRH, HHAdultAgeACRRH, HHParentRRH, AC3PlusRRH, AHARRRH, AHARHoHRRH
		, PSHAgeMin, PSHAgeMax, HHTypePSH, HoHPSH, AdultPSH, HHChronicPSH, HHVetPSH, HHDisabilityPSH
		, HHFleeingDVPSH, HHAdultAgeAOPSH, HHAdultAgeACPSH, HHParentPSH, AC3PlusPSH, AHARPSH, AHARHoHPSH
		, ReportID 
		)
	select count(distinct PersonalID)
		, Gender, Race, Ethnicity, VetStatus, DisabilityStatus
		, CHTime, CHTimeStatus, DVStatus
		, ESTAgeMin, ESTAgeMax, HHTypeEST, HoHEST, AdultEST, HHChronicEST, HHVetEST, HHDisabilityEST
		, HHFleeingDVEST, HHAdultAgeAOEST, HHAdultAgeACEST, HHParentEST, AC3PlusEST, AHAREST, AHARHoHEST
		, RRHAgeMin, RRHAgeMax, HHTypeRRH, HoHRRH, AdultRRH, HHChronicRRH, HHVetRRH, HHDisabilityRRH
		, HHFleeingDVRRH, HHAdultAgeAORRH, HHAdultAgeACRRH, HHParentRRH, AC3PlusRRH, AHARRRH, AHARHoHRRH
		, PSHAgeMin, PSHAgeMax, HHTypePSH, HoHPSH, AdultPSH, HHChronicPSH, HHVetPSH, HHDisabilityPSH
		, HHFleeingDVPSH, HHAdultAgeAOPSH, HHAdultAgeACPSH, HHParentPSH, AC3PlusPSH, AHARPSH, AHARHoHPSH
		, ReportID 
	from tlsa_Person
	group by 
		Gender, Race, Ethnicity, VetStatus, DisabilityStatus
		, CHTime, CHTimeStatus, DVStatus
		, ESTAgeMin, ESTAgeMax, HHTypeEST, HoHEST, AdultEST, HHChronicEST, HHVetEST, HHDisabilityEST
		, HHFleeingDVEST, HHAdultAgeAOEST, HHAdultAgeACEST, HHParentEST, AC3PlusEST, AHAREST, AHARHoHEST
		, RRHAgeMin, RRHAgeMax, HHTypeRRH, HoHRRH, AdultRRH, HHChronicRRH, HHVetRRH, HHDisabilityRRH
		, HHFleeingDVRRH, HHAdultAgeAORRH, HHAdultAgeACRRH, HHParentRRH, AC3PlusRRH, AHARRRH, AHARHoHRRH
		, PSHAgeMin, PSHAgeMax, HHTypePSH, HoHPSH, AdultPSH, HHChronicPSH, HHVetPSH, HHDisabilityPSH
		, HHFleeingDVPSH, HHAdultAgeAOPSH, HHAdultAgeACPSH, HHParentPSH, AC3PlusPSH, AHARPSH, AHARHoHPSH
		, ReportID 
	
/*
	End LSAPerson
*/