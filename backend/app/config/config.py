import os


NASA_POWER_URL = "https://power.larc.nasa.gov/api/temporal/daily/point"
NASA_PARAMETERS = ["T2M", "T2M_MAX", "T2M_MIN", "PRECTOTCORR"]
NASA_COMMUNITY = "AG"
START_DATE = os.getenv("NASA_START_DATE", "20250101")
END_DATE = os.getenv("NASA_END_DATE", "20251231")