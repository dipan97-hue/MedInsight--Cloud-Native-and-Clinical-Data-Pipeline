select
    cast(caseid as int64) as case_id,
    cast(hba1c_level as float64) as hba1c_level,
    trim(diabetes_diagnosis_type) as diabetes_diagnosis_type,
    cast(insulin_dependent as boolean) as insulin_dependent
from `medical-analytics-510812`.`vitaldb`.`clinical_data`
where caseid is not null