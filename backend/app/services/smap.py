
import earthaccess

# Authenticate with NASA Earthdata
earthaccess.login()

# Search SMAP L4 data for the farm location
granules = earthaccess.search_data(
    short_name="SPL4SMGP",
    version="008",
    temporal=("2025-01-01", "2025-01-02"),
    point=(30.47, 31.04),
    count=2,
)

print("Number of granules:", len(granules))

for granule in granules:
    print(granule)
