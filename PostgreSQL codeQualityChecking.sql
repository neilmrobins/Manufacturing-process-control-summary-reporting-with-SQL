-- CTE to be selected from by final query to summarise performance of each operator
WITH grouped AS (
    SELECT
        operator,
        alert,
        COUNT(*) AS count_alerts,	
        SUM(COUNT(*)) OVER (PARTITION BY operator) AS total_per_operator,
	-- calculate % each alert type is out of total for each operator
        ROUND(
            COUNT(*) * 100.0 
            / SUM(COUNT(*)) OVER (PARTITION BY operator),
            2
        ) AS pct_of_operator
    FROM (
        SELECT    
            operator,
            row_number,
            height,
            avg_height,
            stddev_height,
            ucl,
            lcl,
            CASE 
                WHEN height > ucl THEN TRUE
                WHEN height < lcl THEN TRUE
                ELSE FALSE 
            END AS alert
        FROM (
            SELECT
                item_no,
                operator,
                height,
                avg_height,
                stddev_height,
                row_number,
				-- upper control limit calculation
                avg_height + 3 * (stddev_height/SQRT(5)) AS ucl,
				-- lower control limit calculation
                avg_height - 3 * (stddev_height/SQRT(5)) AS lcl
            FROM (
                SELECT
                    item_no,
                    operator,
                    height,
                    AVG(height) OVER temp_window AS avg_height,
                    STDDEV(height) OVER temp_window AS stddev_height,
                    ROW_NUMBER() OVER temp_window AS row_number
                FROM manufacturing_parts
                --set the window for the 3 above window functions to use
				WINDOW temp_window AS (
                    PARTITION BY operator
                    ORDER BY item_no
                    ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
                )
            ) AS A
			-- exclude first 5 rows for each operator as ucl/lcl not applicable until after 5th item has been produced 
            WHERE row_number >= 5
        ) AS B
    ) AS C
    GROUP BY operator, alert
)
SELECT *
FROM grouped
--sort so that ordering is by highest to lowest operator based on % of parts not outside the control limits
ORDER BY
    MAX(CASE WHEN alert = FALSE THEN pct_of_operator END)
        OVER (PARTITION BY operator) DESC,
    operator,
    alert;