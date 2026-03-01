# Manufacturing-process-control-summary-reporting-with-SQL
An SQL query that captures if items produced are outside of control tolerances and summarises frequency of products within and outside of control limit by operative.
<img width="1134" height="673" alt="image" src="https://github.com/user-attachments/assets/d4c54706-77e0-416c-a51b-8fbe5e1687f0" />
This short task was to write SQL query to identify if the heights of items in a CSV file of production line data were within the boundaries of an upper and lower control limit and to summarise the findings.

The acceptable range was defined as between the following:

**upper control limit (ucl) = avg_height + 3 * stddev_height/ sqrt(5)**
**lower control limit (lcl) = avg_height - 3 * stddev_height/ sqrt(5)**

The control limits are applied to rolling series of 5 produced items, so only calculations from the fifth item onwards, per operative, are tested against the control limits.

The code uses a CTE with 3 sub queries, with features windows functions, a CASE statement and a GROUP BY clause. The summarising query then selects from the CTE with a windows function and CASE statement within the ORDER BY clause to show the operatives in order of highest % of items within tolerance.
