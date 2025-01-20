import pandas as pd
from faker import Faker

# Define a function to generate Los Angeles-specific phone numbers
def generate_la_phone_number():
    area_codes = ['213', '310', '323', '424', '818']
    area_code = faker.random_element(area_codes)
    return f"({area_code}) {faker.random_number(digits=3, fix_len=True)}-{faker.random_number(digits=4, fix_len=True)}"



# Load the uploaded dataset
file_path = 'base/LAPD_Police_Stations_-3946316159051949741.csv'
data = pd.read_csv(file_path)

# Initialize Faker
faker = Faker()

# Add the requested properties to the dataset
data['CONTACT_NUMBER'] = [generate_la_phone_number() for _ in range(len(data))]
data['COMMANDING_OFFICER'] = [faker.name() for _ in range(len(data))]
data['EMAIL_ADDRESS'] = [faker.email() for _ in range(len(data))]
data['NUM_COPS'] = [faker.random_int(min=10, max=300) for _ in range(len(data))]

# Save the updated dataset
updated_file_path = 'base/Updated_LAPD_Police_Stations.csv'
data.to_csv(updated_file_path, index=False)

updated_file_path


