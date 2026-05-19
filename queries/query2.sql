SELECT
    m.last_name,
    m.first_name,
    COUNT(r.repair_id) AS total_repairs
FROM masters m
LEFT JOIN repairs r
ON m.master_id = r.master_id
GROUP BY m.master_id
HAVING total_repairs > 1
ORDER BY total_repairs DESC;
