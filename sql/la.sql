WITH
  vmp_amp AS (
    SELECT DISTINCT id, nm, id AS vmp, bnf_code FROM dmd.vmp
    UNION DISTINCT
    SELECT DISTINCT id, nm, vmp, bnf_code FROM dmd.amp
  )
SELECT
  vmp_amp.id,
  vmp_amp.nm,
  vmp_amp.vmp,
  vmp_amp.bnf_code,
  CASE
    WHEN
      COALESCE(vpi.bs_subid, vpi.ing) = 373492002
      AND route.descr = 'patch.transdermal'
      AND strnt_nmrtr_val / (COALESCE(strnt_dnmtr_val, 1)) >= 37.5
      THEN
        TRUE  -- Fentanyl patches (strengths equal to or higher than 37.5mcg/hour) (ing code)
    WHEN
      COALESCE(vpi.bs_subid, vpi.ing) = 387024006
      AND route.descr LIKE '%modified-release.oral'
      AND vmp_amp.nm NOT LIKE '%Onexila%40mg%'
      AND strnt_nmrtr_val / (COALESCE(strnt_dnmtr_val, 1)) >= 30
      THEN
        TRUE  -- Oxycodone MR oral preps [excluding Onexila 40mg as 24hr] (strengths equal to or higher than 30mg) (ing code)
    WHEN
      COALESCE(vpi.bs_subid, vpi.ing) = 441757005
      AND route.descr LIKE '%modified-release.oral'
      AND strnt_nmrtr_val / (COALESCE(strnt_dnmtr_val, 1)) >= 112.5
      THEN
        TRUE  -- Tapentadol base substance (strengths equal to or higher than 112.5mg) (ing code)
    WHEN
      COALESCE(vpi.bs_subid, vpi.ing) = 387173000
      AND route.descr LIKE 'patch.transdermal'
      AND strnt_nmrtr_val / (COALESCE(strnt_dnmtr_val, 1)) >= 39.375
      THEN
        TRUE  -- Buprenorphine patches (strengths equal to or higher than 39.375mg/hour) (ing code)
    WHEN
      COALESCE(vpi.bs_subid, vpi.ing) = 60886004
      AND route.descr LIKE '%modified-release.oral'
      AND vmp_amp.nm NOT LIKE '%MXL%'
      AND strnt_nmrtr_val / (COALESCE(strnt_dnmtr_val, 1)) >= 45
      THEN
        TRUE  -- Morphine Sulfate MR oral preps [excluding MXL as 24hr] (strengths equal to or higher than 45mg) (ing code)
    WHEN
      COALESCE(vpi.bs_subid, vpi.ing) = 60886004
      AND route.descr LIKE '%modified-release.oral'
      AND vmp_amp.nm LIKE '%MXL%'
      AND strnt_nmrtr_val / (COALESCE(strnt_dnmtr_val, 1)) >= 90
      THEN TRUE  -- MXL (strengths equal to or higher than 90mg) (ing code)
    WHEN
      COALESCE(vpi.bs_subid, vpi.ing) = 44508008
      AND route.descr LIKE '%modified-release.oral'
      AND strnt_nmrtr_val / (COALESCE(strnt_dnmtr_val, 1)) >= 9
      THEN
        TRUE  -- Hydromorphone base substance (strengths equal to or higher than 9mg) (ing code)
    ELSE FALSE
    END AS is_high_strength
FROM vmp_amp
INNER JOIN dmd.vmp vmp
  ON vmp.id = vmp_amp.vmp
INNER JOIN dmd.vpi AS vpi
  ON
    vmp.id
    = vpi.vmp  -- joins vmp to vpi table to get ingredient strengths (strnt_nmrtr_val)
INNER JOIN dmd.ont AS ont
  ON vmp.id = ont.vmp  -- joins vmp to ont table to get formulation codes
INNER JOIN dmd.ontformroute AS route
  ON
    ont.form
    = route.cd  -- joins ont table to ontform table to get formulation names
WHERE
  (
    (
      COALESCE(vpi.bs_subid, vpi.ing) = 373492002
      AND route.descr = 'patch.transdermal')  -- Fentanyl patches (ing code)
    OR (
      COALESCE(vpi.bs_subid, vpi.ing) = 387024006
      AND route.descr
        LIKE '%modified-release.oral')  -- Oxycodone MR oral preps (ing code)
    OR (
      COALESCE(vpi.bs_subid, vpi.ing) = 441757005
      AND route.descr
        LIKE '%modified-release.oral')  -- Tapentadol base substance oral preps (ing code)
    OR (
      COALESCE(vpi.bs_subid, vpi.ing) = 387173000
      AND route.descr
        LIKE 'patch.transdermal')  -- Buprenorphine patches (ing code)
    OR (
      COALESCE(vpi.bs_subid, vpi.ing) = 60886004
      AND route.descr
        LIKE '%modified-release.oral')  -- Morphine Sulfate MR oral preps (ing code)
    OR (
      COALESCE(vpi.bs_subid, vpi.ing) = 387485001
      AND route.descr
        LIKE '%modified-release.oral'))  -- Hydromorphone HCl MR oral preps (ing code)
