local DataStoreService = game:GetService("DataStoreService")

local Databases = {
	profiles = DataStoreService:GetDataStore("_profiles"),


	kills = DataStoreService:GetOrderedDataStore("_killsTest"),
	wins = DataStoreService:GetOrderedDataStore("_winsTest"),
	minutes = DataStoreService:GetOrderedDataStore("_minutesTest"),
	level = DataStoreService:GetOrderedDataStore("_levelTest"),
}
return Databases
