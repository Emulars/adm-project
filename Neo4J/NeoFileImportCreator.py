import pandas as pd

# Load the data
crime_data = pd.read_parquet("../dataset/CrimeDataSet.parquet")
police_stations = pd.read_csv("../dataset/Updated_LAPD_Police_Stations.csv")

# Take only half of the data for testing purposes
crime_data = crime_data.sample(frac=0.04, random_state=42)

# Sanitize street names by removing leading/traling and duplicate whitespaces
crime_data["Street"] = crime_data["Street"].str.replace(r"\s+", " ", regex=True).str.strip()
police_stations["LOCATION"] = police_stations["LOCATION"].str.replace(r"\s+", " ", regex=True).str.strip()

# Create CrimeType nodes
crime_type_nodes = crime_data[["CrimeId", "Crime type", "Crime subtype"]].drop_duplicates()
crime_type_nodes.columns = ["CrimeId", "Type", "Subtype"]
crime_type_nodes.to_csv("to_import/CrimeType.csv", index=False)

# Create WeaponType nodes
weapon_type_nodes = crime_data[["Weapon", "Weapon Type"]].drop_duplicates()
weapon_type_nodes.columns = ["Name", "Type"]
weapon_type_nodes.to_csv("to_import/WeaponType.csv", index=False)

# Create DistrictName nodes
district_nodes = crime_data[["District"]].drop_duplicates()
district_nodes.columns = ["Name"]
district_nodes.to_csv("to_import/DistrictName.csv", index=False)

# Create Street nodes
street_nodes = pd.concat([
    crime_data[["Street"]].rename(columns={"Street": "Name"}),
    police_stations[["LOCATION"]].rename(columns={"LOCATION": "Name"})
]).drop_duplicates()
street_nodes.to_csv("to_import/Street.csv", index=False)

# Create TargetVictim nodes (including ethnicity as a label)
target_victim_nodes = crime_data[["VictimId", "Age", "Gender", "Ethnicity"]]
target_victim_nodes = target_victim_nodes.drop_duplicates()
# target_victim_nodes["NodeLabel"] = "TargetVictim:" + target_victim_nodes["Ethnicity"]
# target_victim_nodes.to_csv("to_import/TargetVictim.csv", index=False, columns=["VictimId", "Age", "Gender", "NodeLabel"])
target_victim_nodes.to_csv("to_import/TargetVictim.csv", index=False, columns=["VictimId", "Age", "Gender", "Ethnicity"])

# Create PoliceStation nodes
police_station_nodes = police_stations[["OBJECTID", "CONTACT_NUMBER", "EMAIL_ADDRESS", "NUM_COPS"]]
police_station_nodes.columns = ["PoliceStationId", "PhoneNumber", "Mail", "NumCops"]
police_station_nodes.to_csv("to_import/PoliceStation.csv", index=False)

# Create relationships

# CrimeType-INVOLVES->TargetVictim
crime_involves_victim = crime_data[crime_data["VictimId"] != "NONE"][["CrimeId", "VictimId"]]
crime_involves_victim.to_csv("to_import/CrimeType_Involves_TargetVictim.csv", index=False)

# CrimeType-OCCURRED_IN->DistrictName
crime_occurred_in_district = crime_data[["CrimeId", "District"]].merge(district_nodes, left_on="District", right_on="Name")[["CrimeId", "Name"]]
crime_occurred_in_district.to_csv("to_import/CrimeType_OccurredIn_DistrictName.csv", index=False)

# CrimeType-OCCURRED_AT->Street
crime_occurred_at_street = crime_data[["CrimeId", "Street", "DateTime"]].merge(street_nodes, left_on="Street", right_on="Name")[["CrimeId", "Name", "DateTime"]]
crime_occurred_at_street.columns = ["CrimeId", "StreetId", "DateTime"]
crime_occurred_at_street.to_csv("to_import/CrimeType_OccurredAt_Street.csv", index=False)

# WeaponType-USED->CrimeType
# If the Weapon is NONE do not create a relationship
weapon_used_in_crime = crime_data[crime_data["Weapon"] != "NONE"][["CrimeId", "Weapon"]].merge(weapon_type_nodes, left_on="Weapon", right_on="Name")[["Weapon", "CrimeId"]]
weapon_used_in_crime.to_csv("to_import/WeaponType_Used_CrimeType.csv", index=False)

# Street-LOCATED->PoliceStation
street_located_police_station = police_stations[["LOCATION", "OBJECTID"]].merge(street_nodes, left_on="LOCATION", right_on="Name")
street_located_police_station = street_located_police_station[["Name", "OBJECTID"]]  # Select only relevant columns
street_located_police_station.columns = ["Street", "PoliceStationId"]
street_located_police_station.to_csv("to_import/Street_Located_PoliceStation.csv", index=False)

# Street-IN->District
# Extract unique combinations of Street and District from both datasets and merge the results
crime_street_district = crime_data[["Street", "District"]].drop_duplicates()
police_street_district = police_stations[["LOCATION", "DIVISION"]].rename(columns={"LOCATION": "Street", "DIVISION": "District"}).drop_duplicates()
street_in_district = pd.concat([crime_street_district, police_street_district]).drop_duplicates()
street_in_district.to_csv("to_import/Street_In_District.csv", index=False)
