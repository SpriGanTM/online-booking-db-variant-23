SELECT
    r.repair_id,
    c.last_name,
    c.first_name,
    b.brand,
    s.service_name,
    m.last_name AS master_last_name,
    r.repair_datetime,
    r.status
FROM repairs r
JOIN bicycles b
ON r.bicycle_id = b.bicycle_id
JOIN clients c
ON b.client_id = c.client_id
JOIN services s
ON r.service_id = s.service_id
JOIN masters m
ON r.master_id = m.master_id
ORDER BY r.repair_datetime;
