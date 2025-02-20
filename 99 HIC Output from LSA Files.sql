select 
                           [Row #] = 'HDX'
                           , [CocState] = left(rpt.ReportCoC, 2)
                           , [CoC] = 'HDX'
                           , [CoC\ID] = 'HDX'
                           , [HudNum] = rpt.ReportCoC
                           , [Status] = 'HDX'
                           , [Year] = year(rpt.ReportStart)
                           , [Organization ID] = 'HDX'
                           , [Organization Name] = org.OrganizationName
                           , [HMIS Org ID] = org.OrganizationID
                           , [useHmisDb] = 'Yes'
                           , [Project ID] = 'HDX'
                           , [Project Name] = p.ProjectName
                           , [HMIS Project ID] = p.ProjectID
                           , [HIC Date] = rpt.ReportStart
                           , [Project Type] = case p.ProjectType
                                                                     when 0 then 'ES'
                                                                     when 1 then 'ES'
                                                                     when 2 then 'TH'
                                                                     when 3 then 'PSH'
                                                                     when 8 then 'SH'
                                                                     when 13 then 'RRH'
                                                                     else 'OPH' end
                           , [Bed Type] = inv.[Bed Type]
                           , [Geo Code] = coc.Geocode
                           , [HMIS Participating] = case hp.HMISParticipationType 
                                         when 1 then 'Yes'
                                         when 0 then 'No'
                                         when 2 then 'Comp'
                                         else 'Error' end
                           , [Inventory Type] = inv.[Inventory Type]
                           , [beginsOperationsWithinYear] = case inv.[Inventory Type]
                                         when 'U' then '1'
                                         else '' end
                           , [Target Population] = case p.TargetPopulation
                                         when 1 then 'DV'
                                         when 3 then 'HIV'
                                         when 4 then 'NA'
                                         else '' end 
                           , mcKinneyVentoEsg = isnull((select max(case when f.Funder in (8,10) then 1 else 0 end) 
                                                                                                             from lsa_Funder f where f.ProjectID = p.ProjectID), 99)
                           , mcKinneyVentoEsgEs = isnull((select max(case when f.Funder = 8 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , mcKinneyVentoEsgRrh = isnull((select max(case when f.Funder = 10 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , mcKinneyVentoEsgCov = 'n/a import'
                           , mcKinneyVentoEsgEsCov = 'n/a import'
                           , mcKinneyVentoEsgRrhCov = 'n/a import'
                           , mcKinneyVentoCoc = isnull((select max(case when f.Funder in (2,3,5,6,7,44) then 1 else 0 end) 
                                                                                                             from lsa_Funder f where f.ProjectID = p.ProjectID), 99)
                           , mcKinneyVentoCocSh = isnull((select max(case when f.Funder = 6 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , mcKinneyVentoCocTh = isnull((select max(case when f.Funder = 5 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , mcKinneyVentoCocPsh = isnull((select max(case when f.Funder = 2 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , mcKinneyVentoCocRrh = isnull((select max(case when f.Funder = 3 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , mcKinneyVentoCocSro = isnull((select max(case when f.Funder = 7 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , mcKinneyVentoCocThRrh = isnull((select max(case when f.Funder = 44 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , mcKinneyVentoSpC = 'n/a import'
                           , mcKinneyVentoS8 = 'n/a import'
                           , mcKinneyVentoShp = 'n/a import'
                           , mcKinneyVentoYhdp = isnull((select max(case when f.Funder = 43 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , mcKinneyVentoYhdpRenewals = 'n/a import'
                           , federalFundingVash = 'n/a import'
                           , federalFundingSsvf = isnull((select max(case when f.Funder = 33 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingGpd = isnull((select max(case when f.Funder in (37,38,39,40,41,42) then 1 else 0 end) 
                                                                                                             from lsa_Funder f where f.ProjectID = p.ProjectID), 99)
                           , federalFundingGpdBh = isnull((select max(case when f.Funder = 37 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingGpdLd = isnull((select max(case when f.Funder = 38 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingGpdHh = isnull((select max(case when f.Funder = 39 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingGpdCt = isnull((select max(case when f.Funder = 40 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingGpdSith = isnull((select max(case when f.Funder = 41 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingGpdTp = isnull((select max(case when f.Funder = 42 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingHchv = isnull((select max(case when f.Funder in (27,30) then 1 else 0 end) 
                                                                                                             from lsa_Funder f 
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingHchvCrs = isnull((select max(case when f.Funder = 27 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingHchvSh = isnull((select max(case when f.Funder = 30 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingBcp = isnull((select max(case when f.Funder = 22 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingTlp = isnull((select max(case when f.Funder = 24 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingMgh = isnull((select max(case when f.Funder = 23 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingRhyDp = isnull((select max(case when f.Funder = 26 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingHopwa = isnull((select max(case when f.Funder in (13,15,18,19,48) then 1 else 0 end) 
                                                                                                             from lsa_Funder f 
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingHopwaHmv = isnull((select max(case when f.Funder = 13 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingHopwaPh = isnull((select max(case when f.Funder = 15 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingHopwaStsf = isnull((select max(case when f.Funder = 18 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingHopwaTh = isnull((select max(case when f.Funder = 19 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingHopwaCovid = isnull((select max(case when f.Funder = 48 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingPih = isnull((select max(case when f.Funder = 36 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingHome = isnull((select max(case when f.Funder = 50 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingHomeArp = isnull((select max(case when f.Funder = 51 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingIndianEhv = isnull((select max(case when f.Funder = 52 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingOther = isnull((select max(case when f.Funder = 46 then 1 else 0 end) 
                                                                                                             from lsa_Funder f
                                                                                                             where f.ProjectID = p.ProjectID), 99)
                           , federalFundingOtherSpecify = isnull((select stuff ((select ', ' + isnull(oth.OtherFunder, 'Error') 
                                                                                                                                                       from (select distinct f.OtherFunder
                                                                                                                                                                    from lsa_Funder f
                                                                                                                                                                     where f.ProjectID = p.ProjectID and f.Funder = 46) oth
                                                                                                                                                       for xml path('')
                                                                                                                                                       ), 1, 2, '')
                                                                                                                                         ), '')
                           , [housingType] = case p.HousingType
                                                                     when 1 then 'Site-based - single site'
                                                                     when 2 then 'Site-based - clustered/multiple sites'
                                                                     when 3 then 'Tenant-based - scattered site'
                                                                     else 'Error' end 
                           , [Victim Service Provider] = org.VictimServiceProvider            
                           , [address1] = isnull(coc.Address1, '')
                           , [address2] = isnull(coc.Address2, '')
                           , [city] = isnull(coc.City, '')
                           , [state] = isnull(coc.State, '')
                           , [zip] = isnull(coc.ZIP, '')
                           , [Beds HH w/ Children] = inv.[Beds for Households with Children]
                           , [Units HH w/ Children] = inv.[Units for Households with Children]
                           , [Veteran Beds HH w/ Children] = inv.[Veteran Beds for Households with Children]
                           , [Youth Beds HH w/ Children] = inv.[Youth Beds for Households with Children]
                           , [CH Beds HH w/ Children] = inv.[Chronic Beds for PSH Households with Children]
                           , [Beds HH w/o Children] = inv.[Beds for Households without Children]
                           , [Veteran Beds HH w/o Children] = inv.[Veteran Beds for Households without Children]
                           , [Youth Beds HH w/o Children] = inv.[YouthBeds for Households without Children]
                           , [CH Beds HH w/o Children] = inv.[Chronic Beds for PSH Households without Children]
                           , [Beds HH w/ only Children] = inv.[Beds for Households with only Children]
                           , [CH Beds HH w only Children] = inv.[Chronic Beds for PSH Households with only Children]
                           , [Year-Round Beds] = inv.[Year-Round Beds]
                           , [DV Beds] = case when p.TargetPopulation = 1 then inv.[Year-Round Beds] else '' end
                           , [Total Seasonal Beds] = inv.[Seasonal Beds]
                           , [Availability Start Date] = inv.[Seasonal Beds Start Date]
                           , [Availability End Date] = inv.[Seasonal Beds End Date]
                           , [O/V Beds] = inv.[Overflow Beds]
                           , [PIT Count] = inv.[Point-in-time count of people in these beds]
                           , [Total Beds] = inv.[Total Beds]
              from lsa_Report rpt
              inner join lsa_Project p on p.OperatingStartDate < dateadd(yyyy, 1, rpt.ReportStart)
                           and (p.OperatingEndDate is NULL or p.OperatingEndDate > rpt.ReportStart)
                           and (p.ProjectType <> 13 or p.RRHSubType = 2)
              inner join lsa_HMISParticipation hp on hp.ProjectID = p.ProjectID 
                           and hp.HMISParticipationStatusStartDate <= rpt.ReportStart 
                           and (hp.HMISParticipationStatusEndDate is null or hp.HMISParticipationStatusEndDate > rpt.ReportStart)
              inner join lsa_ProjectCoC coc on coc.ProjectID = p.ProjectID 
                           and coc.CoCCode = rpt.ReportCoC
              inner join lsa_Organization org on org.OrganizationID = p.OrganizationID
              left outer join    
                           (select base.ProjectID
                                         , [Inventory Type] = isnull(base.InventoryType, '')
                                         , [Inventory Start Date] = min(base.InventoryStartDate)
                                         , [Bed Type] = isnull(base.BedType, '')
                                         , [Beds for Households with Children] = sum(base.[Beds for Households with Children])
                                         , [Units for Households with Children] = sum(base.[Units for Households with Children])
                                         , [Veteran Beds for Households with Children] = sum(base.[Veteran Beds for Households with Children])
                                         , [Youth Beds for Households with Children] = sum(base.[Youth Beds for Households with Children])
                                         , [Chronic Beds for PSH Households with Children] = sum(base.[Chronic Beds for PSH Households with Children])
                                         , [Beds for Households without Children] = sum(base.[Beds for Households without Children])
                                         , [Veteran Beds for Households without Children] = sum(base.[Veteran Beds for Households without Children])
                                         , [YouthBeds for Households without Children] = sum(base.[Youth Beds for Households without Children])
                                         , [Chronic Beds for PSH Households without Children] = sum(base.[Chronic Beds for PSH Households without Children])
                                         , [Beds for Households with only Children] = sum(base.[Beds for Households with only Children])
                                         , [Chronic Beds for PSH Households with only Children] = sum(base.[Chronic Beds for PSH Households with only Children])
                                         , [Year-Round Beds] = sum(base.[Year-Round Beds])
                                         , [Seasonal Beds] = sum(base.[Seasonal Beds])
                                         , [Seasonal Beds Start Date] = min(base.[Seasonal Beds Start Date])
                                         , [Seasonal Beds End Date] = max(base.[Seasonal Beds End Date])
                                         , [Overflow Beds] = sum(base.[Overflow Beds])
                                         , [Point-in-time count of people in these beds] = sum(base.PIT)     
                                         , [Total Beds] = sum(base.BedInventory)
                           from      (select distinct 
                                           i.InventoryID, i.ProjectID
                                                       , case when i.InventoryStartDate > rpt.ReportStart then 'U'
                                                                                                else 'C' end as InventoryType
                                                       , i.InventoryStartDate
                                                       , case when p.ProjectType <> 1 then ''
                                                                                  when i.ESBedType = 1 then 'F'
                                                                                  when i.ESBedType = 2 then 'V'
                                                                                  else 'O' end as BedType
                                                       , case when (p.ProjectType <> 1 or i.Availability = 1) and i.HouseholdType = 3 then i.BedInventory else 0 end
                                                                     as [Beds for Households with Children]
                                                       , case when (p.ProjectType <> 1 or i.Availability = 1) and i.HouseholdType = 3 then i.UnitInventory else 0 end
                                                                     as [Units for Households with Children]
                                                       , case when p.ProjectType = 3 and i.HouseholdType = 3 then i.CHBedInventory + i.CHVetBedInventory + i.CHYouthBedInventory
                                                                                  else 0 end
                                                                     as [Chronic Beds for PSH Households with Children]
                                                       , case when (p.ProjectType <> 1 or i.Availability = 1) and i.HouseholdType = 3 then i.VetBedInventory + i.CHVetBedInventory + i.YouthVetBedInventory else 0 end
                                                                     as [Veteran Beds for Households with Children]
                                                       , case when (p.ProjectType <> 1 or i.Availability = 1) and i.HouseholdType = 3 then i.YouthBedInventory + i.CHYouthBedInventory + i.YouthVetBedInventory else 0 end
                                                                     as [Youth Beds for Households with Children]
                                                       , case when (p.ProjectType <> 1 or i.Availability = 1) and i.HouseholdType = 1 then i.BedInventory else 0 end
                                                                     as [Beds for Households without Children]
                                                       , case when p.ProjectType = 3 and i.HouseholdType = 1 then i.CHBedInventory + i.CHVetBedInventory + i.CHYouthBedInventory
                                                                                  else 0 end
                                                                     as [Chronic Beds for PSH Households without Children]
                                                       , case when (p.ProjectType <> 1 or i.Availability = 1) and i.HouseholdType = 1 then i.VetBedInventory + i.CHVetBedInventory + i.YouthVetBedInventory else 0 end
                                                                     as [Veteran Beds for Households without Children]
                                                       , case when (p.ProjectType <> 1 or i.Availability = 1) and i.HouseholdType = 1 then i.YouthBedInventory + i.CHYouthBedInventory + i.YouthVetBedInventory else 0 end
                                                                     as [Youth Beds for Households without Children]
                                                       , case when (p.ProjectType <> 1 or i.Availability = 1) and i.HouseholdType = 4 then i.BedInventory else 0 end
                                                                     as [Beds for Households with only Children]
                                                       , case when p.ProjectType = 3 and i.HouseholdType = 4 then i.CHBedInventory + i.CHVetBedInventory + i.CHYouthBedInventory
                                                                                  else 0 end
                                                                     as [Chronic Beds for PSH Households with only Children]
                                                       , case when (p.ProjectType = 1 and i.Availability = 2) then i.BedInventory else 0 end
                                                                     as [Seasonal Beds]
                                                       , case when (p.ProjectType = 1 and i.Availability = 2) then i.InventoryStartDate else null end
                                                                     as [Seasonal Beds Start Date]
                                                       , case when (p.ProjectType = 1 and i.Availability = 2) then i.InventoryEndDate else null end
                                                                     as [Seasonal Beds End Date]
                                                       , case when (p.ProjectType = 1 and i.Availability = 3) then i.BedInventory else 0 end
                                                                     as [Overflow Beds]
                                                       , case when (p.ProjectType <> 1 or i.Availability = 1) then i.BedInventory else 0 end as [Year-Round Beds]
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