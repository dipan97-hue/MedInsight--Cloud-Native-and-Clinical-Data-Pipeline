SELECT 
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

    from  {{ref('stg_clinical_data')}} c left join {{ref('stg_lab_data')}} l on c.caseid = l.caseid
    