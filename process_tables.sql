-- acqtype
-- THSCODE;DESCRIPT;LANG
-- A;Authoritative Document;EN
DROP TABLE IF EXISTS sources;
CREATE TABLE sources (
    id          integer PRIMARY KEY,
    description varchar,
    code        varchar
);

INSERT INTO sources (description, code)
    SELECT DESCRIPT, THSCODE FROM acqtype_csv ORDER BY THSCODE;

-- methtype
-- THSCODE;DESCRIPT;LANG
-- A;analytical result(s);EN
DROP TABLE IF EXISTS methods;
CREATE TABLE methods (
    id          integer PRIMARY KEY,
    description varchar,
    code        varchar
);

INSERT INTO methods (description, code)
    SELECT DESCRIPT, THSCODE FROM methtype_csv ORDER BY THSCODE;

-- process
-- THSCODE;DESCRIPT;LANG
-- BAK;Baked in oven;EN
DROP TABLE IF EXISTS processing_methods;
CREATE TABLE processing_methods (
    id          integer PRIMARY KEY,
    description varchar,
    code        varchar
);

INSERT INTO processing_methods (description, code)
    SELECT DESCRIPT, THSCODE FROM process_csv ORDER BY THSCODE;

-- fuclass
-- THSCODE;DESCRIPT;LANG
-- FRUDITOT;Fruit and berry dishes;EN
DROP TABLE IF EXISTS food_use_class;
CREATE TABLE food_use_class (
    id          integer PRIMARY KEY,
    description varchar,
    code        varchar
);

INSERT INTO food_use_class (description, code)
    SELECT DESCRIPT, THSCODE FROM fuclass_csv ORDER BY THSCODE;

-- igclass
-- THSCODE;DESCRIPT;LANG
-- FRUITTOT;Fruits;EN
DROP TABLE IF EXISTS ingredient_class;
CREATE TABLE ingredient_class (
    id          integer PRIMARY KEY,
    description varchar,
    code        varchar
);

INSERT INTO ingredient_class (description, code)
    SELECT DESCRIPT, THSCODE FROM igclass_csv ORDER BY THSCODE;

-- cmpclass
-- THSCODE;DESCRIPT;LANG
-- NUTRIENT;Nutrients;EN

DROP TABLE IF EXISTS component_class;
CREATE TABLE component_class (
    id          integer PRIMARY KEY,
    description varchar,
    code        varchar
);

INSERT INTO component_class (description, code)
    SELECT DESCRIPT, THSCODE FROM cmpclass_csv ORDER BY THSCODE;

-- compunit / foodunit
-- THSCODE;DESCRIPT;LANG
-- G;gram;EN
DROP TABLE IF EXISTS units;
CREATE TABLE units (
    id          integer PRIMARY KEY,
    description varchar,
    code        varchar
);

INSERT INTO units (description, code)
    SELECT DESCRIPT, THSCODE FROM compunit_csv ORDER BY THSCODE;
INSERT INTO units (description, code)
    SELECT DESCRIPT, THSCODE
    FROM foodunit_csv
    WHERE THSCODE NOT IN (SELECT THSCODE FROM compunit_csv)
    ORDER BY THSCODE;

-- component / eufdname
-- EUFDNAME;COMPUNIT;CMPCLASS;CMPCLASSP
-- ENERC;KJ;ENERGY;MACROCMP
DROP TABLE IF EXISTS components;
CREATE TABLE components (
    id                      integer PRIMARY KEY,
    description             varchar,
    unit_id                 integer,
    component_class_id      integer,
    component_superclass_id integer,
    code                    varchar
);

INSERT INTO components (description, unit_id, component_class_id, component_superclass_id, code)
    SELECT euf.DESCRIPT, units.id, cp.id, cpp.id, c.EUFDNAME
    FROM component_csv c
    JOIN eufdname_csv euf ON c.EUFDNAME = euf.THSCODE
    JOIN units ON c.COMPUNIT = units.code
    JOIN component_class cp ON c.CMPCLASS = cp.code
    JOIN component_class cpp ON c.CMPCLASSP = cpp.code
    ORDER BY c.EUFDNAME;

-- component_value
-- FOODID;EUFDNAME;BESTLOC;ACQTYPE;METHTYPE
-- 1;ENERC;1698,30;S;S
DROP TABLE IF EXISTS component_value;
CREATE TABLE component_value (
    id              integer PRIMARY KEY,
    food_id         integer,
    component_id    integer,
    value           real,
    source_id       integer,
    method_id       integer
);

INSERT INTO component_value (food_id, component_id, value, source_id, method_id)
    SELECT
        cv.FOODID,
        c.id,
        CASE WHEN cv.BESTLOC != "" THEN replace(cv.BESTLOC, ",", ".") ELSE NULL END,
        s.id,
        m.id
    FROM component_value_csv cv
    JOIN components c ON cv.EUFDNAME = c.code
    JOIN sources s ON cv.ACQTYPE = s.code
    JOIN methods m ON cv.METHTYPE = m.code
    ORDER BY cv.FOODID, c.id;

-- contribfood
-- FOODID;CONFDID;AMOUNT;FOODUNIT;MASS;EVREMAIN;RECYEAR
-- 29;922;500,00;G;500,00;70;
DROP TABLE IF EXISTS food_recipes;
CREATE TABLE food_recipes (
    id                      integer PRIMARY KEY,
    main_food_id            integer,
    food_id                 integer,
    amount                  real,
    unit_id                 integer,
    mass                    real,
    evaporation_remainder   integer,
    recorded_year           integer
);

INSERT INTO food_recipes (
    main_food_id,
    food_id,
    amount,
    unit_id,
    mass,
    evaporation_remainder,
    recorded_year
)
    SELECT cf.FOODID,
        cf.CONFDID,
        replace(cf.AMOUNT, ",", "."),
        u.id,
        replace(cf.MASS, ",", "."),
        cf.EVREMAIN,
        CASE WHEN cf.RECYEAR = '' THEN NULL ELSE cf.RECYEAR END
    FROM contribfood_csv cf
    JOIN units u ON cf.FOODUNIT = u.code;


-- foodtype
-- THSCODE;DESCRIPT;LANG
-- FOOD;Food;EN
DROP TABLE IF EXISTS food_types;
CREATE TABLE food_types (
    id          integer PRIMARY KEY,
    description varchar,
    code        varchar
);

INSERT INTO food_types (description, code) SELECT DESCRIPT, THSCODE FROM foodtype_csv ORDER BY THSCODE;

-- food
-- FOODID;FOODNAME;FOODTYPE;PROCESS;EDPORT;IGCLASS;IGCLASSP;FUCLASS;FUCLASSP
-- 1;SOKERI;FOOD;IND;100;SUGARSYR;SUGARTOT;SUGADD;SUGARTOT
DROP TABLE IF EXISTS food;
CREATE TABLE food (
    id                          integer PRIMARY KEY,
    name                        varchar,
    type_id                     integer,
    processing_method_id        integer,
    edible_portion              integer,
    ingredient_class_id         integer,
    ingredient_superclass_id    integer,
    food_use_class_id           integer,
    food_use_superclass_id      integer
);

INSERT INTO food (
    id,
    name,
    type_id,
    processing_method_id,
    edible_portion,
    ingredient_class_id,
    ingredient_superclass_id,
    food_use_class_id,
    food_use_superclass_id
)
    SELECT f.FOODID, fn.FOODNAME, t.id, pm.id, f.EDPORT, ic.id, icc.id, fu.id, fuu.id
    FROM food_csv f
    JOIN foodname_csv fn ON fn.FOODID = f.FOODID
    JOIN food_types t ON t.code = f.FOODTYPE
    JOIN processing_methods pm ON pm.code = f.PROCESS
    JOIN ingredient_class ic ON ic.code = f.IGCLASS
    JOIN ingredient_class icc ON icc.code = f.IGCLASSP
    JOIN food_use_class fu ON fu.code = f.FUCLASS
    JOIN food_use_class fuu ON fuu.code = f.FUCLASSP;

-- foodaddunit
-- FOODID;FOODUNIT;MASS
-- 1;PORTS;5,00
DROP TABLE IF EXISTS food_add_unit;
CREATE TABLE food_add_unit (
    id      integer PRIMARY KEY,
    food_id integer,
    unit_id integer,
    mass    real
);

INSERT INTO food_add_unit (food_id, unit_id, mass)
    SELECT fau.FOODID, u.id, replace(fau.MASS, ",", ".")
    FROM foodaddunit_csv fau
    JOIN units u ON u.code = fau.FOODUNIT
    ORDER BY fau.FOODID, u.id;

-- specdiet_EN
-- THSCODE;DESCRIPT;LANG
-- ADDFREE;no additives;EN
DROP TABLE IF EXISTS special_diet;
CREATE TABLE special_diet (
    id          integer PRIMARY KEY,
    description varchar,
    code        varchar
);

INSERT INTO special_diet (description, code)
    SELECT DESCRIPT, THSCODE FROM specdiet_csv ORDER BY THSCODE;

-- specdiet (foodspecdiet)
-- FOODID;SPECDIET
-- 1;GLUTFREE
DROP TABLE IF EXISTS food_special_diet;
CREATE TABLE food_special_diet (
    id              integer PRIMARY KEY,
    food_id         integer,
    special_diet_id integer
);

INSERT INTO food_special_diet (food_id, special_diet_id)
    SELECT fsd.FOODID, sp.id
    FROM foodspecdiet_csv fsd
    JOIN special_diet sp ON sp.code = fsd.SPECDIET
    ORDER BY fsd.FOODID, sp.code;
