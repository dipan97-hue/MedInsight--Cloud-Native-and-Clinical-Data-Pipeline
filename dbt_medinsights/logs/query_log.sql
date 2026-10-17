-- created_at: 2026-10-17T18:02:46.945444700+00:00
-- finished_at: 2026-10-17T18:02:48.572291+00:00
-- elapsed: 1.6s
-- outcome: success
-- dialect: bigquery
-- node_id: model.dbt_medinsights.stg_lab_data
-- query_id: adbc-f41f87dd-f170-472f-abb8-74ea3f3c036a
-- desc: execute adapter call
/* {"app": "dbt", "dbt_version": "2.0.0", "node_id": "model.dbt_medinsights.stg_lab_data", "profile_name": "medinsights", "target_name": "dev"} */


  create or replace view `medical-analytics-510812`.`vitaldb_transformation`.`stg_lab_data`
  OPTIONS()
  as select * 
from `medical-analytics-510812`.`vitaldb`.`lab_data`;

;

-- created_at: 2026-10-17T18:02:49.054228600+00:00
-- finished_at: 2026-10-17T18:02:50.466753200+00:00
-- elapsed: 1.4s
-- outcome: success
-- dialect: bigquery
-- node_id: model.dbt_medinsights.stg_clinical_data
-- query_id: adbc-202d855d-4050-4c2d-88c3-ab8d6667cd5a
-- desc: execute adapter call
/* {"app": "dbt", "dbt_version": "2.0.0", "node_id": "model.dbt_medinsights.stg_clinical_data", "profile_name": "medinsights", "target_name": "dev"} */


  create or replace view `medical-analytics-510812`.`vitaldb_transformation`.`stg_clinical_data`
  OPTIONS()
  as select * 
from `medical-analytics-510812`.`vitaldb`.`clinical_data`;

;

-- created_at: 2026-10-17T18:02:50.475879500+00:00
-- finished_at: 2026-10-17T18:02:52.093403100+00:00
-- elapsed: 1.6s
-- outcome: success
-- dialect: bigquery
-- node_id: model.dbt_medinsights.int_case_lab_data
-- query_id: adbc-f1b0a055-b1fe-4b61-942d-9b45a50c4f60
-- desc: execute adapter call
/* {"app": "dbt", "dbt_version": "2.0.0", "node_id": "model.dbt_medinsights.int_case_lab_data", "profile_name": "medinsights", "target_name": "dev"} */


  create or replace view `medical-analytics-510812`.`vitaldb_transformation`.`int_case_lab_data`
  OPTIONS()
  as SELECT 
--- CASE INFORMATION
c.caseid,
c.subjectid,

---Patient Information
c.age,
c.height,
c.weight,
c.sex,
c.bmi,
c.asa,

-- Clinical Information
c.department,
    c.optype,
    c.dx,
    c.opname,
    c.approach,
    c.position,
    c.ane_type,

    -- Preoperative factors
    c.preop_htn,
    c.preop_dm,
    c.preop_ecg,
    c.preop_pft,
    c.preop_hb,
    c.preop_plt,
    c.preop_pt,
    c.preop_aptt,
    c.preop_na,
    c.preop_k,
    c.preop_gluc,
    c.preop_alb,
    c.preop_ast,
    c.preop_alt,
    c.preop_bun,
    c.preop_cr,
    c.preop_ph,
    c.preop_hco3,
    c.preop_be,
    c.preop_pao2,
    c.preop_paco2,
    c.preop_sao2,

    -- Airway information
    c.cormack,
    c.airway,

    -- Lab Information

    l.dt  as lab_time,
    l.name as lab_name,
    l.result as lab_result,

    from  `medical-analytics-510812`.`vitaldb_transformation`.`stg_clinical_data` c left join `medical-analytics-510812`.`vitaldb_transformation`.`stg_lab_data` l on c.caseid = l.caseid
    ;

;

-- created_at: 2026-10-17T18:02:52.101523+00:00
-- finished_at: 2026-10-17T18:02:53.896329400+00:00
-- elapsed: 1.8s
-- outcome: success
-- dialect: bigquery
-- node_id: model.dbt_medinsights.int_case_lab_pivot
-- query_id: adbc-57a33ec9-a56a-4bea-9be3-849c7500ed1d
-- desc: execute adapter call
/* {"app": "dbt", "dbt_version": "2.0.0", "node_id": "model.dbt_medinsights.int_case_lab_pivot", "profile_name": "medinsights", "target_name": "dev"} */


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

;

-- created_at: 2026-10-17T18:02:53.907416300+00:00
-- finished_at: 2026-10-17T18:02:56.404585900+00:00
-- elapsed: 2.5s
-- outcome: success
-- dialect: bigquery
-- node_id: model.dbt_medinsights.fct_summary
-- query_id: adbc-4a7683b9-b42d-4ada-988d-69cefa44977b
-- desc: execute adapter call
/* {"app": "dbt", "dbt_version": "2.0.0", "node_id": "model.dbt_medinsights.fct_summary", "profile_name": "medinsights", "target_name": "dev"} */


  create or replace view `medical-analytics-510812`.`vitaldb_transformation`.`fct_summary`
  OPTIONS()
  as with pivoted_labs as (
    select * from `medical-analytics-510812`.`vitaldb_transformation`.`int_case_lab_pivot`
),

clinical as (
    select 
        caseid,age,sex,
        height,
        weight
    from `medical-analytics-510812`.`vitaldb_transformation`.`stg_clinical_data`
)

select
    c.caseid,
    c.age,
    c.sex,
    c.height,
    c.weight,
    l.glucose,
    l.lactate,
    l.hemoglobin,
    l.potassium,
    -- Dynamically derive diabetes/hyperglycemia risk based on lab thresholds
    case 
        when l.glucose >= 200 then 'High Diabetes Risk / Hyperglycemia Alert'
        when l.glucose between 140 and 199 then 'Moderate Risk / Elevated Glucose'
        else 'Normal Glucose Range'
    end as diabetes_risk_category,
    -- Overall clinical status
    case 
        when l.glucose >= 200 then 'Critical'
        when l.potassium > 5.0 or l.potassium < 3.5 then 'Warning'
        else 'Stable'
    end as clinical_risk_status
from clinical c
left join pivoted_labs l on c.caseid = l.case_id;

;

-- created_at: 2026-10-17T18:02:56.416094200+00:00
-- finished_at: 2026-10-17T18:02:58.207553100+00:00
-- elapsed: 1.8s
-- outcome: success
-- dialect: bigquery
-- node_id: model.dbt_medinsights.fct_patient_clinical_summary
-- query_id: adbc-53650b12-7096-4d00-84ce-f555eece8ae0
-- desc: execute adapter call
/* {"app": "dbt", "dbt_version": "2.0.0", "node_id": "model.dbt_medinsights.fct_patient_clinical_summary", "profile_name": "medinsights", "target_name": "dev"} */


  create or replace view `medical-analytics-510812`.`vitaldb_transformation`.`fct_patient_clinical_summary`
  OPTIONS()
  as with clinical_summary as (
    select * from `medical-analytics-510812`.`vitaldb_transformation`.`fct_summary`
)

select
    case 
        when age < 18 then 'Pediatric (<18)'
        when age between 18 and 45 then 'Young Adult (18-45)'
        when age between 46 and 65 then 'Middle Aged (46-65)'
        else 'Senior (>65)'
    end as age_group,
    sex,
    count(caseid) as total_patients_in_cohort,
    round(avg(age), 1) as average_age,
    round(avg(glucose), 2) as average_glucose_level,
    round(avg(potassium), 2) as average_potassium_level
from clinical_summary
group by age_group, sex;

;

