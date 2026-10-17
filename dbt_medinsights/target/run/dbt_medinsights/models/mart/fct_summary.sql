

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

