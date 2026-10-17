

  create or replace view `medical-analytics-510812`.`vitaldb_transformation`.`stg_lab_data`
  OPTIONS()
  as select * 
from `medical-analytics-510812`.`vitaldb`.`lab_data`;

