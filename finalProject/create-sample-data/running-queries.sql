SELECT *
FROM (
    SELECT unnest(array[1, 2, 3]) AS array1_element, unnest(array[1, 3, 3]) AS array2_element
) subquery

