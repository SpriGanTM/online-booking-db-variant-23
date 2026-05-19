SELECT
    m.last_name,
    m.first_name,

    AVG(
        TIMESTAMPDIFF(
            MINUTE,
            r.repair_datetime,
            r.completion_datetime
        )
    ) AS avg_repair_time_minutes

FROM masters m

JOIN repairs r
ON m.master_id = r.master_id

WHERE r.status = 'завершён'

GROUP BY m.master_id

ORDER BY avg_repair_time_minutes;
