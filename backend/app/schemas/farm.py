
from pydantic import BaseModel, Field


class FarmProfile(BaseModel):
    farmName: str = Field(..., min_length=1)
    location: str = Field(..., min_length=1)

    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)

    cultivatedArea: float = Field(..., gt=0)
    areaUnit: str

    soilType: str
    currentCrop: str
