import pandas as pd

# Specify the input TSV file and output Parquet file
input_tsv = 'base/Crime-Data-from-2020-to-Present-Cleaned.tsv'
output_parquet = 'base/Crime-Data-from-2020-to-Present-Cleaned.parquet'

# Read the TSV file
df = pd.read_csv(input_tsv, sep='\t')

# Remove the following columns: DistrictKm2, Crime Value, Sub Eth, Status, Coordinates
df = df.drop(columns=['DistrictKm2', 'Crime Value', 'Sub Eth', 'Status', 'Coordinates'])

# Add an ID for the crime as the first column
df.insert(0, 'CrimeId', range(1, 1 + len(df)))
df.insert(5, 'VictimId', range(1, 1 + len(df)))
# Write to Parquet file
df.to_parquet(output_parquet, engine='pyarrow', index=False)

print(f"Successfully converted '{input_tsv}' to '{output_parquet}'.")
