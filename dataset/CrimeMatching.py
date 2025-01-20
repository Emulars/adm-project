import pandas as pd

def update_crime_ids(parquet_file_path, output_file_path):
    # Load the Parquet file into a DataFrame
    df = pd.read_parquet(parquet_file_path)

    # Create a unique identifier for matching rows based on the rules
    df['MatchKey'] = df['DateTime'] + "|" + df['District'] + "|" + df['Crime type'] + "|" + df['Street']

    # Group by the MatchKey to identify groups of rows with the same key
    grouped = df.groupby('MatchKey')

    # Create a mapping of new CrimeIds for each group
    crime_id_map = {}
    new_crime_id = max(df['CrimeId']) + 1  # Start new CrimeIds from the max existing one

    matching_rows = []

    for match_key, group in grouped:
        # Check if there are differences in Age, Gender, and Ethnicity within the group
        if len(group[['Age', 'Gender', 'Ethnicity']].drop_duplicates()) > 1:
            # Assign the same CrimeId to all rows in this group
            crime_id_map.update({idx: new_crime_id for idx in group.index})
            new_crime_id += 1

            # Collect matching rows for display
            matching_rows.append(group)

    # Print matching rows
    if matching_rows:
        print("Matching rows:")
        for match in matching_rows:
            print(match)

    # Update the CrimeId column based on the mapping
    df['CrimeId'] = df.index.map(lambda idx: crime_id_map.get(idx, df.loc[idx, 'CrimeId']))

    # Drop the MatchKey column as it is no longer needed
    df = df.drop(columns=['MatchKey'])

    # Save the updated DataFrame to a new Parquet file
    df.to_parquet(output_file_path, index=False)

# Example usage
input_parquet_file = "base/Crime-Data-from-2020-to-Present-Cleaned.parquet"
output_parquet_file = "CrimeDataSet.parquet"
update_crime_ids(input_parquet_file, output_parquet_file)
