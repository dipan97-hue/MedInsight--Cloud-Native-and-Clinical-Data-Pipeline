with clinical_summary as (
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
group by age_group, sex