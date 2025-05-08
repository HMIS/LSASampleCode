select 
        id = 'HDX'
		, inventoryRow = 'HDX'
        , inventoryType = inv.InventoryType
		, naturalDisaster = 'HDX'
        , bedType = inv.BedType
        , pitCount = case when inv.PITCount = 0 and p.PITCount > 0 then p.PITCount else inv.PITCount end
        , organizationName = org.OrganizationName
        , organizationID = org.OrganizationID
        , victimServiceProvider = org.VictimServiceProvider            
        , projectName = p.ProjectName
        , projectID = p.ProjectID
        , projectType = case p.ProjectType
            when 0 then 'ES'
            when 1 then 'ES'
            when 2 then 'TH'
            when 3 then 'PSH'
            when 8 then 'SH'
            when 13 then 'RRH'
            else 'OPH' end
        , hmisParticipant = case hmisPart.HMISParticipationType 
                        when 1 then 'Y'
                        when 0 then 'N'
                        when 2 then 'C'
                        else 'Error' end     
        , targetPopulation = case p.TargetPopulation
                        when 1 then 'DV'
                        when 3 then 'HIV'
                        when 4 then 'NA'
                        else '' end 						
        , housingType = case p.HousingType
                    when 1 then 'SB-S'
                    when 2 then 'SB-C'
                    when 3 then 'TB'
                    else 'Error' end 						 
        , allYearBedsWithChildrenBeds = inv.ACBeds
        , allYearBedsWithChildrenUnits = inv.ACUnits
        , allYearBedsWithChildrenBedsChronic = inv.ACChronicBeds
        , allYearBedsWithChildrenBedsVeteran = inv.ACVetBeds
        , allYearBedsWithChildrenBedsYouth = inv.ACYouthBeds
        , allYearBedsWithoutChildrenBeds = inv.AOBeds
        , allYearBedsWithoutChildrenBedsChronic = inv.AOChronicBeds
        , allYearBedsWithoutChildrenBedsVeteran = inv.AOVetBeds
        , allYearBedsWithoutChildrenBedsYouth = inv.AOYouthBeds
        , allYearBedsWithOnlyChildrenBeds = inv.COBeds
        , allYearBedsWithOnlyChildrenBedsChronic = inv.COChronicBeds
        , currentYearRoundBeds = inv.YearRoundBeds
        , seasonalBedsBeds = inv.SeasonalBeds
        , seasonalBedsStartDate = inv.SeasonalStart
        , seasonalBedsEndDate = inv.SeasonalEnd
        , overflowBedsBeds = inv.OverflowBeds
        , totalBeds = inv.TotalBeds
		, utilizationRate = cast(cast(inv.PITCount as float)/cast(inv.TotalBeds as float) * 100 as nvarchar) + '%'
from lsa_Report rpt
inner join lsa_Project p on p.OperatingStartDate < dateadd(yyyy, 1, rpt.ReportStart)
            and (p.OperatingEndDate is NULL or p.OperatingEndDate > rpt.ReportStart)
            and (p.ProjectType <> 13 or p.RRHSubType = 2)
inner join 
	(select row_number() over (partition by hp.ProjectID order by hp.HMISParticipationStatusStartDate desc) as row_num
		, hp.ProjectID, hp.HMISParticipationType
	from lsa_HMISParticipation hp
	where hp.HMISParticipationStatusStartDate <= (select ReportStart from lsa_Report)
	) hmisPart on hmisPart.ProjectID = p.ProjectID and hmisPart.row_num = 1
inner join lsa_ProjectCoC coc on coc.ProjectID = p.ProjectID 
            and coc.CoCCode = rpt.ReportCoC
inner join lsa_Organization org on org.OrganizationID = p.OrganizationID
left outer join    
            (select base.ProjectID
                            , InventoryType = isnull(base.InventoryType, '')
                            , InventoryStart = min(base.InventoryStartDate)
                            , BedType = isnull(base.BedType, '')
                            , ACBeds = sum(base.ACBeds)
                            , ACUnits = sum(base.ACUnits)
                            , ACVetBeds = sum(base.ACVetBeds)
                            , ACYouthBeds = sum(base.ACYouthBeds)
                            , ACChronicBeds = sum(base.ACChronicBeds)
                            , AOBeds = sum(base.AOBeds)
                            , AOVetBeds = sum(base.AOVetBeds)
                            , AOYouthBeds = sum(base.AOYouthBeds)
                            , AOChronicBeds = sum(base.AOChronicBeds)
                            , COBeds = sum(base.COBeds)
                            , COChronicBeds = sum(base.[Chronic Beds for PSH Households with only Children])
                            , YearRoundBeds = sum(base.YearRoundBeds)
                            , SeasonalBeds = sum(base.SeasonalBeds)
                            , SeasonalStart = min(base.SeasonalStart)
                            , SeasonalEnd = max(base.SeasonalEnd)
                            , OverflowBeds = sum(base.OverflowBeds)
                            , PITCount = max(base.PIT) 
                            , TotalBeds = sum(base.BedInventory)
            from      (select distinct 
                            i.InventoryID, i.ProjectID
                                        , case when i.InventoryStartDate > rpt.ReportStart then 'U'
                                                                                else 'C' end as InventoryType
                                        , i.InventoryStartDate
                                        , case when p.ProjectType <> 1 then ''
                                                                    when i.ESBedType = 1 then 'F'
                                                                    when i.ESBedType = 2 then 'V'
                                                                    else '' end as BedType
                                        , case when (p.ProjectType <> 1 or i.Availability = 1) and i.HouseholdType = 3 then i.BedInventory else 0 end
                                                        as ACBeds
                                        , case when (p.ProjectType <> 1 or i.Availability = 1) and i.HouseholdType = 3 then i.UnitInventory else 0 end
                                                        as ACUnits
                                        , case when p.ProjectType = 3 and i.HouseholdType = 3 then i.CHBedInventory + i.CHVetBedInventory + i.CHYouthBedInventory
                                                                    else 0 end
                                                        as ACChronicBeds
                                        , case when (p.ProjectType <> 1 or i.Availability = 1) and i.HouseholdType = 3 then i.VetBedInventory + i.CHVetBedInventory + i.YouthVetBedInventory else 0 end
                                                        as ACVetBeds
                                        , case when (p.ProjectType <> 1 or i.Availability = 1) and i.HouseholdType = 3 then i.YouthBedInventory + i.CHYouthBedInventory + i.YouthVetBedInventory else 0 end
                                                        as ACYouthBeds
                                        , case when (p.ProjectType <> 1 or i.Availability = 1) and i.HouseholdType = 1 then i.BedInventory else 0 end
                                                        as AOBeds
                                        , case when p.ProjectType = 3 and i.HouseholdType = 1 then i.CHBedInventory + i.CHVetBedInventory + i.CHYouthBedInventory
                                                                    else 0 end
                                                        as AOChronicBeds
                                        , case when (p.ProjectType <> 1 or i.Availability = 1) and i.HouseholdType = 1 then i.VetBedInventory + i.CHVetBedInventory + i.YouthVetBedInventory else 0 end
                                                        as AOVetBeds
                                        , case when (p.ProjectType <> 1 or i.Availability = 1) and i.HouseholdType = 1 then i.YouthBedInventory + i.CHYouthBedInventory + i.YouthVetBedInventory else 0 end
                                                        as AOYouthBeds
                                        , case when (p.ProjectType <> 1 or i.Availability = 1) and i.HouseholdType = 4 then i.BedInventory else 0 end
                                                        as COBeds
                                        , case when p.ProjectType = 3 and i.HouseholdType = 4 then i.CHBedInventory + i.CHVetBedInventory + i.CHYouthBedInventory
                                                                    else 0 end
                                                        as [Chronic Beds for PSH Households with only Children]
                                        , case when (p.ProjectType = 1 and i.Availability = 2) then i.BedInventory else 0 end
                                                        as SeasonalBeds
                                        , case when (p.ProjectType = 1 and i.Availability = 2) then i.InventoryStartDate else null end
                                                        as SeasonalStart
                                        , case when (p.ProjectType = 1 and i.Availability = 2) then i.InventoryEndDate else null end
                                                        as SeasonalEnd
                                        , case when (p.ProjectType = 1 and i.Availability = 3) then i.BedInventory else 0 end
                                                        as OverflowBeds
                                        , case when (p.ProjectType <> 1 or i.Availability = 1) then i.BedInventory else 0 end as YearRoundBeds
                                        , i.BedInventory
                                        , case when calc.Value is null then 0
                                                                    when estypes.ProjectID is not null then 0
                                                                    else calc.Value end as PIT
                                        from lsa_Inventory i
                                        inner join lsa_Project p on p.ProjectID = i.ProjectID
                                        inner join lsa_Organization o on o.OrganizationID = p.OrganizationID
                                        inner join lsa_ProjectCoC coc on coc.ProjectID = p.ProjectID
                                        inner join lsa_Report rpt on rpt.ReportID = i.ExportID
                                                        and rpt.ReportCoC = coc.CoCCode
                                        left outer join lsa_Funder f on f.ProjectID = p.ProjectID
                                        left outer join lsa_Inventory estypes on estypes.ProjectID = i.ProjectID
                                                        and p.ProjectType = 1 
                                                        and estypes.ESBedType < i.ESBedType 
                                        left outer join lsa_Calculated calc on calc.ProjectID = p.ProjectID 
                                                        and i.InventoryStartDate <= rpt.ReportStart
                                                        and calc.HHType = 0
                                                        and calc.Population = 0
                                                        and calc.Cohort = 1
                                                        and calc.Universe = 10
                                                        and calc.ReportRow = 53
                                        --select PITCount column for OPH and non-participating
                                        ) base 
                            group by base.ProjectID, base.InventoryType, base.BedType
                            ) inv on inv.ProjectID = p.ProjectID 

order by p.ProjectID