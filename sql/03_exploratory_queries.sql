-- Daily summary
SELECT
    DATE(UpdatedTime) AS measurement_date,
    AVG(IrradianceGlobal) AS avg_irradiance,
    AVG(TemperatureAmbient) AS avg_ambient_temperature,
    AVG(TemperatureModules) AS avg_module_temperature
FROM pv_measurements
GROUP BY DATE(UpdatedTime)
ORDER BY measurement_date;

-- Hourly average profile
SELECT
    STRFTIME('%H', UpdatedTime) AS measurement_hour,
    AVG(IrradianceGlobal) AS avg_irradiance,
    AVG(TemperatureAmbient) AS avg_ambient_temperature,
    AVG(TemperatureModules) AS avg_module_temperature
FROM pv_measurements
GROUP by STRFTIME('%H', UpdatedTime)
ORDER BY measurement_hour;

-- Hour with the highest average module temperature
SELECT
    STRFTIME('%H', UpdatedTime) AS measurement_hour,
    AVG(TemperatureModules) AS avg_module_temperature
FROM pv_measurements
GROUP BY STRFTIME('%H', UpdatedTime)
ORDER BY avg_module_temperature DESC
LIMIT 1;

-- Average module-to-ambient temperature difference by hour
SELECT
    STRFTIME('%H', UpdatedTime) AS measurement_hour,
    AVG(TemperatureModules - TemperatureAmbient) AS avg_temperature_difference 
FROM pv_measurements
GROUP BY STRFTIME('%H', UpdatedTime)
ORDER BY measurement_hour;

-- Hour with the highest module-to-ambient temperature difference
SELECT
    STRFTIME('%H', UpdatedTime) AS measurement_hour,
    AVG(TemperatureModules - TemperatureAmbient) AS avg_temperature_difference
FROM pv_measurements
GROUP BY STRFTIME('%H', UpdatedTime)
ORDER BY avg_temperature_difference DESC
LIMIT 1;

-- Top 5 days with the highest module-to-ambient temperature difference
WITH daily_temperature AS (
    SELECT
        DATE(UpdatedTime) AS measurement_date,
        AVG(TemperatureAmbient) AS avg_ambient_temperature,
        AVG(TemperatureModules) AS avg_module_temperature
    FROM pv_measurements
    GROUP BY DATE(UpdatedTime)
)

SELECT 
    measurement_date,
    ROUND(avg_ambient_temperature, 4) AS avg_ambient_temperature,
    ROUND(avg_module_temperature, 4) AS avg_module_temperature,
    ROUND(avg_module_temperature - avg_ambient_temperature, 4) AS temperature_difference
FROM daily_temperature 
ORDER BY temperature_difference DESC
LIMIT 5;

-- Temperature behavior by irradiance range
SELECT
    CASE
        WHEN IrradianceGlobal < 200 THEN 'Low'
        WHEN IrradianceGlobal < 600 THEN 'Moderate'
        WHEN IrradianceGlobal < 1000 THEN 'High'
        ELSE 'Very high'
    END AS irradiance_range,

    COUNT(*) AS observations,

    ROUND(AVG(IrradianceGlobal), 4) AS avg_irradiance,
    ROUND(AVG(TemperatureAmbient), 4) AS avg_ambient_temperature,
    ROUND(AVG(TemperatureModules), 4) AS avg_module_temperature,
    ROUND(
        AVG(TemperatureModules - TemperatureAmbient),
        4
    ) AS avg_temperature_difference

FROM pv_measurements
GROUP BY irradiance_range
ORDER BY avg_irradiance;

-- Compare each module temperature with previous measurement
WITH temperature_lag AS (
    SELECT
        UpdatedTime,
        TemperatureModules,
        LAG(TemperatureModules) OVER (
            ORDER BY UpdatedTime
        ) previous_module_temperature
    FROM pv_measurements
)

-- Module temperature change between consecutive measurements
-- Module temperature change between consecutive measurements
WITH temperature_lag AS (
    SELECT
        UpdatedTime,
        TemperatureModules,
        LAG(TemperatureModules) OVER (
            PARTITION BY DATE(UpdatedTime)
            ORDER BY UpdatedTime
        ) AS previous_module_temperature
    FROM pv_measurements
)

SELECT
    UpdatedTime,
    TemperatureModules,
    previous_module_temperature,
    ROUND(
        TemperatureModules - previous_module_temperature,
        4
    ) AS temperature_change
FROM temperature_lag
WHERE previous_module_temperature IS NOT NULL
ORDER BY UpdatedTime
LIMIT 10;
