WITH
  vmp_amp AS (
    SELECT DISTINCT id, nm, id AS vmp FROM dmd.vmp
    UNION DISTINCT
    SELECT DISTINCT id, nm, vmp FROM dmd.amp
  )
SELECT vmp_amp.id, vmp_amp.nm
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
