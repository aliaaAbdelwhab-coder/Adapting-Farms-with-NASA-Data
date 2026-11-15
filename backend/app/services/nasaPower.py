import pandas as pd
import requests

from app.config.config import NASA_COMMUNITY, NASA_PARAMETERS, NASA_POWER_URL




def get_nasa_data(
    latitude: float,
    longitude: float,
    start_date: str,
    end_date: str,
) -> pd.DataFrame:
    params = {
        "parameters": ",".join(NASA_PARAMETERS),
        "community": NASA_COMMUNITY,
        "longitude": longitude,
        "latitude": latitude,
        "start": start_date,
        "end": end_date,
        "format": "JSON",
        "time-standard": "UTC",
    }

    response = requests.get(NASA_POWER_URL, params=params, timeout=90)
    response.raise_for_status()
    payload = response.json()

    try:
        parameter_data = payload["properties"]["parameter"]
    except KeyError as exc:
        raise ValueError(
            "Unexpected NASA POWER response: 'properties.parameter' was not found."
        ) from exc

    df = pd.DataFrame(parameter_data)
    df.index = pd.to_datetime(df.index, format="%Y%m%d", errors="coerce")
    df.index.name = "date"
    df = df.reset_index()

    for column in NASA_PARAMETERS:
        if column not in df.columns:
            raise ValueError(f"NASA POWER response is missing {column}.")

    df[NASA_PARAMETERS] = df[NASA_PARAMETERS].apply(
        pd.to_numeric, errors="coerce"
    )
    df[NASA_PARAMETERS] = df[NASA_PARAMETERS].replace(-999, float("nan"))
    df = df.dropna(subset=["date"])

    if df[NASA_PARAMETERS].notna().sum().sum() == 0:
        raise ValueError(
            "NASA POWER returned no valid values for the requested parameters "
            "and dates. Check the response and date range before continuing."
        )

    return df