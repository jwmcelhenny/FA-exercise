# FA-exercise

Purpose: Calculate churn rates based on daily tasks per user.

Definitions:

Active user -  A user is considered active on any day where they have at least one task executed in the prior 28 days.

Churn - A user is considered to be churn the 28 days following their last being considered active. A user is no longer 
part of churn if they become active again.

Data Source(s):
zapier database - source_data.tasks_used_da

Tools Used:

SQL Workbench - utilized to connect to zapier database, extract data, and execute queries to manipulate data set and perform calculations

Tableau - utilized to calculate churn rates and report results/visualizations

Methodology:
1. Extracted data from zapier source_data.tasks_used_da, pulling total tasks by user_id and date
2. Created user_id timeline by identifying user id "active" and "churn" periods, based on Definitions listed above and date of tasks
3. Organized resulting data by user_id, period_type (active or churn), and period length
4. Tagged new customers and cohort based on data of first task
5. Pulled the relevant time period from the primary data table
6. Performed analysis on daily user_id timeline to convert to monthly time
7. Pulled data into Tableau by connecting to Redshift database, visualizing churn rates by day and month, both with and without cohort

Code:
Steps 1-6 performed in SQL workbench by executing FA exercise.sql (see attached)

Outputs:
Output and visualizations created in Tableau in FA exercise.twb (see attached)

