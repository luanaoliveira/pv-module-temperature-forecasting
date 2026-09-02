DROP TABLE IF EXISTS pv_measurements;

CREATE TABLE pv_measurements (
    UpdatedTime TEXT NOT NULL,
    IrradianceGlobal REAL NOT NULL,
    TemperatureAmbient REAL NOT NULL,
    TemperatureModules REAL NOT NULL
);

CREATE INDEX idx_pv_measurements_time
ON pv_measurements (UpdatedTime);