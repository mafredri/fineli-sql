/**
 * Select details for banana with descriptions in Finnish
 */
SELECT
	f.id, f.name, f.edible_portion,
	ft.description AS food_type,
	pm.description AS processing_method,
	ig.description AS ingredient_category,
	fu.description AS food_category,
	ig2.description AS ingredient_category2,
	fu2.description AS food_category2
FROM food f
JOIN food_types ft ON ft.id = f.type_id
JOIN processing_methods pm ON pm.id = f.processing_method_id
JOIN ingredient_class ig ON ig.id = f.ingredient_class_id
JOIN food_use_class fu ON fu.id = f.food_use_class_id
JOIN ingredient_class ig2 ON ig2.id = f.ingredient_superclass_id
JOIN food_use_class fu2 ON fu2.id = f.food_use_superclass_id
WHERE f.id = 11049;

/**
 * Select ingredients for banana with descriptions
 */
SELECT
	cv.food_id, cv.value,
	c.description AS component,
	u.description AS unit,
	cc.description AS component_category,
	cc2.description AS component_category2,
	s.description AS source,
	m.description AS method
FROM component_value cv
JOIN components c ON c.id = cv.component_id
JOIN units u ON u.id = c.unit_id
JOIN component_class cc ON cc.id = c.component_class_id
JOIN component_class cc2 ON cc2.id = c.component_superclass_id
JOIN sources s ON s.id = cv.source_id
JOIN methods m ON m.id = cv.method_id
WHERE cv.food_id = 11049;
