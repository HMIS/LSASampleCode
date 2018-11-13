/**********************************************************

Script validates values in columns in lsa_Report, lsa_Household, lsa_Person, lsa_Exit,
	and lsa_Calculated with predefined list values.  Requires: 

	ref_lsaFiles 
	ref_lsaColumns 
	ref_lsaValues 

10/18/2018 - uploaded to github
		
***********************************************************/


declare @file int = 1
declare @column int = 1
declare @sql nvarchar(max)
declare @lsaValidate table (Issue nvarchar(max))
declare @max int

while @file <= 5 
begin 

	--CHANGE 11/8/2018 reset @column to 1 for each @file loop
	set @column = 1
	select @max = max(ColumnNumber) from ref_lsaColumns where FileNumber = @file
	
	while @column <= @max
	begin

		set @sql = (select distinct 'select distinct ''Invalid value in ' + replace(fil.FileName, 'LSA', 'lsa_')
			+ '.' + col.ColumnName 
			+ ' ('' + cast(' +  replace(fil.FileName, 'LSA', 'lsa_')
			+ '.' + col.ColumnName + ' as nvarchar) + '')'''
			+ ' from ' + replace(fil.FileName, 'LSA', 'lsa_')
			+ ' where ' + replace(fil.FileName, 'LSA', 'lsa_') + '.' + col.ColumnName
			+ ' not in (select intValue from ref_lsaValues where FileNumber = ' 
			+ cast(col.FileNumber as nvarchar)
			+ ' and ColumnNumber = ' + cast(col.ColumnNumber as nvarchar) + ')'
		from ref_lsaColumns col
		inner join ref_lsaFiles fil on fil.FileNumber = col.FileNumber
		where col.List = 1 and col.FileNumber = @file and col.ColumnNumber = @column)

		insert into @lsaValidate (Issue)
		exec(@sql) 

		set @column = @column + 1
	end

	set @file = @file + 1
end

select * from @lsaValidate
