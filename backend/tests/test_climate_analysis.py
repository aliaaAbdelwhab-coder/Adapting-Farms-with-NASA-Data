"""Tests on synthetic climates (no network). They check the logic, not NASA data."""
import numpy as np
import pandas as pd
import pytest

from app.clients.nasa_power import PowerError, parse_power_json
from app.engine.climate_analysis import analyze_climate, _longest_run
from app.sample_input import SAMPLE_FARMS
from app.schemas import FarmInput


def make_climate(lat, mean_t, amp, trend_per_year=0.0, start="2000-01-01",
                 end="2019-12-31", seed=0, noise=1.5, dry_gap=None):
    rng = np.random.default_rng(seed)
    idx = pd.date_range(start, end, freq="D")
    doy = idx.dayofyear.to_numpy()
    years = (idx.year - idx.year[0]).to_numpy() + doy / 365
    sign = -1 if lat >= 0 else 1  # NH coldest ~20 Jan, SH warmest ~20 Jan
    t = mean_t + trend_per_year * years + sign * amp * np.cos(2 * np.pi * (doy - 20) / 365)
    t = t + rng.normal(0, noise, len(idx))
    rain = np.where(rng.random(len(idx)) < 0.3, rng.exponential(8, len(idx)), 0.0)
    if dry_gap:
        rain[(doy >= dry_gap[0]) & (doy <= dry_gap[1])] = 0.0
    return pd.DataFrame(
        {"T2M": t, "T2M_MAX": t + 5, "T2M_MIN": t - 5, "PRECTOTCORR": rain,
         "GWETROOT": 0.5}, index=idx)


def test_longest_run():
    assert _longest_run(np.array([0, 1, 1, 0, 1, 1, 1, 0], bool)) == 3
    assert _longest_run(np.zeros(5, bool)) == 0


def test_northern_temperate_trend_and_frost():
    s = analyze_climate(make_climate(41.6, 10, 14, trend_per_year=0.04), 41.6, -93.6)
    assert s.hemisphere == "north"
    assert s.years_used == 20
    assert 0.25 <= s.temp_trend_c_per_decade <= 0.55  # injected 0.4 C/decade
    assert s.frost_days_per_year > 0
    assert 120 < s.frost_free_days_mean < 260
    assert s.frost_risk in ("moderate", "high")


def test_southern_hemisphere_season_year_keeps_summer_whole():
    # Winter is Jun-Aug (middle of the calendar year). A calendar-year logic
    # would cut the frost-free summer in two (~150 days); season years don't.
    s = analyze_climate(make_climate(-31.9, 12, 10), -31.9, 117.2)
    assert s.hemisphere == "south"
    assert s.frost_days_per_year > 0
    assert s.frost_free_days_mean > 200


def test_tropics_have_no_frost():
    s = analyze_climate(make_climate(-0.3, 26, 2), -0.3, 36.0)
    assert s.frost_risk == "none"
    assert s.frost_days_per_year == 0
    assert s.frost_free_days_mean >= 360


def test_et0_in_plausible_range_and_monthly_shape():
    s = analyze_climate(make_climate(41.6, 10, 14), 41.6, -93.6)
    assert 400 < s.et0_annual_mm < 1400
    assert len(s.monthly) == 12
    summer = {m.name: m for m in s.monthly}["Jul"]
    winter = {m.name: m for m in s.monthly}["Jan"]
    assert summer.et0_mm > winter.et0_mm


def test_dry_spell_detected():
    s = analyze_climate(make_climate(41.6, 10, 14, dry_gap=(200, 235)), 41.6, -93.6)
    assert s.longest_dry_spell_days_max >= 36


def test_incomplete_years_are_dropped():
    df = make_climate(41.6, 10, 14, start="2000-01-01", end="2010-06-30")
    s = analyze_climate(df, 41.6, -93.6)
    assert s.years_used == 10


def test_short_record_has_no_trend_but_still_works():
    df = make_climate(41.6, 10, 14, start="2015-01-01", end="2019-12-31")
    s = analyze_climate(df, 41.6, -93.6)
    assert s.temp_trend_c_per_decade is None
    assert any("trend" in n.lower() for n in s.notes)


def test_missing_required_column_raises():
    with pytest.raises(ValueError):
        analyze_climate(make_climate(41.6, 10, 14).drop(columns=["T2M_MIN"]), 41.6, -93.6)


def test_parse_power_json_converts_fill_values():
    payload = {"properties": {"parameter": {
        "T2M": {"20200101": 1.5, "20200102": -999},
        "PRECTOTCORR": {"20200101": 0.0, "20200102": 3.2}}}}
    df = parse_power_json(payload)
    assert len(df) == 2
    assert np.isnan(df.loc["2020-01-02", "T2M"])
    assert df.loc["2020-01-02", "PRECTOTCORR"] == 3.2


def test_parse_power_json_bad_shape():
    with pytest.raises(PowerError):
        parse_power_json({"oops": 1})


def test_all_sample_farms_validate():
    for name, raw in SAMPLE_FARMS.items():
        farm = FarmInput(**raw)
        assert abs(sum(farm.priorities.weights().values()) - 1) < 1e-9, name
