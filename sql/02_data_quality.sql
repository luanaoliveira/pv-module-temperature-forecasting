-- Total number of records
SELECT COUNT(*) AS total_records
FROM pv_measurements;

-- Check for missing values
SELECT
    SUM(CASE WHEN UpdatedTime IS NULL THEN 1 ELSE 0 END) AS missing_time,
    SUM(CASE WHEN IrradianceGlobal IS NULL THEN 1 ELSE 0 END) AS missing_irradiiance,
    SUM(CASE WHEN TemperatureAmbient IS NULL THEN 1 ELSE 0 END) AS missing_ambient_temperature,
    SUM(CASE WHEN TemperatureModules IS NULL THEN 1 ELSE 0 END) AS missing_module_temperature
FROM pv_measurements;

-- Check for duplicated timestamps
SELECT
    UpdatedTime, 
    COUNT(*) AS occurences
FROM pv_measurements
GROUP BY UpdatedTime
HAVING COUNT(*) > 1
ORDER BY occurences DESC;

-- Summary statistics
SELECT
    MIN(IrradianceGlobal) AS min_irradiance,
    MAX(IrradianceGlobal) AS max_irradiance,
    AVG(IrradianceGlobal) AS avg_irradiance,

    MIN(TemperatureAmbient) AS min_ambient_temperature,
    MAX(TemperatureAmbient) AS max_ambient_temperature,
    AVG(TemperatureAmbient) AS avg_ambient_temperature,

    MIN(TemperatureModules) AS min_module_temperature,
    MAX(TemperatureModules) AS max_module_temperature,
    AVG(TemperatureModules) AS avg_module_temperature
FROM pv_measurements;

-- Check for invalid or non-positive values
SELECT
    SUM(CASE WHEN IrradianceGlobal < 0 THEN 1 ELSE 0 END) AS negative_irradiance,
    SUM(CASE WHEN TemperatureAmbient <= 0 THEN 1 ELSE 0 END) AS invalid_ambient_temperature,
    SUM(CASE WHEN TemperatureModules <= 0 THEN 1 ELSE 0 END) AS invalid_module_temperature
FROM pv_measurements;

-- Check measurements date range
SELECT
    MIN(UpdatedTime) AS first_measurement,
    MAX(UpdatedTime) AS last_measurement
FROM pv_measurements;