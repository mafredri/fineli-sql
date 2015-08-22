/**
 * Select details for banana with descriptions in Finnish
 */
SELECT
    food.foodid AS "id",
    food.foodname AS "name",
    food.edport AS "edible portion",

    foodtype.desc AS "food type",
    process.desc AS "processing",
    igclass.desc AS "ingredient class",
    igclass2.desc AS "ingredient class (alt)",
    fuclass.desc AS "food unit class",
    fuclass2.desc AS "food unit class (alt)"
FROM food
JOIN foodtype ON food.foodtype = foodtype.id
    AND foodtype.lang = 'fi'
JOIN process ON food.process = process.id
    AND process.lang = 'fi'
JOIN igclass ON food.igclass = igclass.id
    AND igclass.lang = 'fi'
JOIN igclass igclass2 ON food.igclassp = igclass2.id
    AND igclass2.lang = 'fi'
JOIN fuclass ON food.fuclass = fuclass.id
    AND fuclass.lang = 'fi'
JOIN fuclass fuclass2 ON food.fuclassp = fuclass2.id
    AND fuclass2.lang = 'fi'
WHERE foodid = 11049;

/**
 * Select ingredients for banana with descriptions in Finnish
 */
SELECT
    /* Convert joules to calories, all values in mg except enerc */
    CASE
        WHEN cv.eufdname = 'enerc' THEN cv.bestloc * 0.239005736
        ELSE cv.bestloc
    END AS "amount",
    cv.eufdname AS "type",
    CASE
        WHEN c.compunit = 'kj' THEN 'cal'
        ELSE c.compunit
    END AS "unit",
    c.cmpclass AS "class",
    c.cmpclassp AS "class (alt)",
    eufdname.desc AS "type desc",
    acqtype.desc AS "acquisition desc",
    methtype.desc AS "methodology desc"
FROM component_value cv
JOIN component c ON cv.eufdname = c.eufdname
JOIN eufdname ON cv.eufdname = eufdname.id
    AND eufdname.lang = 'fi'
JOIN acqtype ON cv.acqtype = acqtype.id
    AND acqtype.lang = 'fi'
JOIN methtype ON cv.methtype = methtype.id
    AND methtype.lang = 'fi'
WHERE foodid = 11049;
