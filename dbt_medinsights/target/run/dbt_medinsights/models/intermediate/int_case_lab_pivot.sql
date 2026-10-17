

  create or replace view `medical-analytics-510812`.`vitaldb_transformation`.`int_case_lab_pivot`
  OPTIONS()
  as select
    caseid as case_id,

    -- Blood / hematology
    max(case when lab_name = 'hb' then lab_result end) as hemoglobin,
    max(case when lab_name = 'hct' then lab_result end) as hematocrit,
    max(case when lab_name = 'plt' then lab_result end) as platelet_count,
    max(case when lab_name = 'wbc' then lab_result end) as white_blood_cell_count,

    -- Electrolytes
    max(case when lab_name = 'na' then lab_result end) as sodium,
    max(case when lab_name = 'k' then lab_result end) as potassium,
    max(case when lab_name = 'cl' then lab_result end) as chloride,
    max(case when lab_name = 'ica' then lab_result end) as ionized_calcium,
    max(case when lab_name = 'p' then lab_result end) as phosphorus,

    -- Kidney function
    max(case when lab_name = 'cr' then lab_result end) as creatinine,
    max(case when lab_name = 'bun' then lab_result end) as blood_urea_nitrogen,
    max(case when lab_name = 'gfr' then lab_result end) as glomerular_filtration_rate,
    max(case when lab_name = 'ccr' then lab_result end) as creatinine_clearance,

    -- Liver function
    max(case when lab_name = 'ast' then lab_result end) as aspartate_aminotransferase,
    max(case when lab_name = 'alt' then lab_result end) as alanine_aminotransferase,
    max(case when lab_name = 'tbil' then lab_result end) as total_bilirubin,
    max(case when lab_name = 'alb' then lab_result end) as albumin,
    max(case when lab_name = 'tprot' then lab_result end) as total_protein,

    -- Inflammation
    max(case when lab_name = 'crp' then lab_result end) as c_reactive_protein,
    max(case when lab_name = 'esr' then lab_result end) as erythrocyte_sedimentation_rate,

    -- Coagulation
    max(case when lab_name = 'pt%' then lab_result end) as prothrombin_time_percent,
    max(case when lab_name = 'ptinr' then lab_result end) as international_normalized_ratio,
    max(case when lab_name = 'ptsec' then lab_result end) as prothrombin_time_seconds,
    max(case when lab_name = 'aptt' then lab_result end) as activated_partial_thromboplastin_time,
    max(case when lab_name = 'fib' then lab_result end) as fibrinogen,

    -- Blood gas
    max(case when lab_name = 'ph' then lab_result end) as blood_ph,
    max(case when lab_name = 'pco2' then lab_result end) as partial_pressure_co2,
    max(case when lab_name = 'po2' then lab_result end) as partial_pressure_o2,
    max(case when lab_name = 'hco3' then lab_result end) as bicarbonate,
    max(case when lab_name = 'be' then lab_result end) as base_excess,
    max(case when lab_name = 'sao2' then lab_result end) as oxygen_saturation,

    -- Metabolic
    max(case when lab_name = 'gluc' then lab_result end) as glucose,
    max(case when lab_name = 'lac' then lab_result end) as lactate,

    -- Other laboratory measurements
    max(case when lab_name = 'ammo' then lab_result end) as ammonia

from `medical-analytics-510812`.`vitaldb_transformation`.`int_case_lab_data`

group by caseid;

