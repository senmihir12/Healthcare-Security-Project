create database healthcare_security_database;
use healthcare_security_database;

select * from blockchain_logs;
select * from fl_bihds_dataset;
select * from healthcare_data;
select * from optimization_metrics;

# Age distribution by diagnosis
select diagnosis_label, count(*) as patient_count, concat(round(avg(age),2), " years") as average_age
from healthcare_data group by diagnosis_label
order by patient_count desc;

# Average vitals by gender
select gender, round(avg(BP),2) as Average_BP, round(avg(Glucose),2) as Average_glucose,
round(avg(heartrate),2) as Average_heart_rate, round(avg(cholesterol),2) as Average_cholesterol
from healthcare_data group by gender;

# Top hospitals by heart disease cases
select hospital_id, count(*) as Heart_cases_number
from healthcare_data where diagnosis_label = "Heart Disease"
group by hospital_id order by Heart_cases_number desc;

# Average latency and bandwidth per hospital
select a.hospital_id, concat(round(avg(b.latency_ms),2), " ms") as Average_latency,
concat(round(avg(b.bandwidth_mbps),2), " ms") as Average_bandwidth
from healthcare_data as a join optimization_metrics as b
on a.hospital_id = b.client_id
group by a.hospital_id order by Average_latency;

# Model update contribution analysis
select a.transaction_type as Transaction_type,
 concat(round(avg(b.data_size_mb),2), " MB") as Average_data_size, round(avg(b.local_epochs),2) as Average_epochs
from blockchain_logs a join optimization_metrics b
on a.client_id = b.client_id
group by a.transaction_type;

# Top resource allocation hospitals
select client_id as Hospital_id, round(avg(resource_allocation_score),2) as Average_score
from optimization_metrics group by client_id order by Average_score desc;

# Latency vs aggregation time correlation check
select round(latency_ms/100)*100 latency_bucket,
concat(round(avg(aggregation_time_ms),2), " ms") as average_aggregation
from optimization_metrics
group by latency_bucket order by latency_bucket;

# Most common diseases by gender
select gender, diagnosis_label, count(*) as cases
from healthcare_data
group by gender, diagnosis_label
order by gender, cases desc;

# Average vitals for diseased vs healthy patients
select diagnosis_label, round(avg(BP),2) as Average_BP, round(avg(glucose),2) as Average_glucose, round(avg(heartrate),2) as Average_heart_rate,
round(avg(cholesterol),2) as Average_cholesterol from healthcare_data group by diagnosis_label;

# Age distribution buckets
select 
case 
	when age<30 then 'Under 30'
    when age between 30 and 50 then '30-50'
    when age between 51 and 70 then '51-70'
    else 'Above 70'
end as Age_group,
count(*) as Patients_number from healthcare_data
group by Age_group order by Patients_number;

# Average Aggregation Time
select client_id, concat(round(avg(aggregation_time_ms),2), " ms") as Average_aggregation_time
from optimization_metrics group by client_id order by Average_aggregation_time;

# Transaction type vs status success rate
select a.transaction_type, a.status, concat(round(avg(b.latency_ms),2)," ms") as Average_latency,
concat(round(avg(b.data_size_mb),2)," MB") as Average_data_size from blockchain_logs as a join optimization_metrics as b
on a.client_id = b.client_id group by a.transaction_type, a.status
order by a.transaction_type, Average_latency desc;

# Hospital Performance by model contribution
select client_id, round(avg(local_epochs),2) as Average_local_epochs,
round(avg(resource_allocation_score),2) as Average_resource_score
from optimization_metrics group by client_id order by Average_resource_score;

# Latency vs bandwidth relation
select round(bandwidth_mbps, -1) as Bandwidth_bucket,
concat(round(avg(latency_ms),2)," ms") as Average_latency,
round(stddev(latency_ms),2) as Latency_variability
from optimization_metrics
group by Bandwidth_bucket order by Bandwidth_bucket;

# Hospital data handling stats
select client_id as hospital_id, concat(round(avg(aggregation_time_ms),2), " ms") as Average_aggregation_time,
concat(round(max(aggregation_time_ms),2), " ms") as Max_aggregation_time,
concat(round(min(aggregation_time_ms),2), " ms") as Min_aggregation_time
from optimization_metrics group by hospital_id order by Average_aggregation_time desc;

# Resource allocation efficiency vs data size
select round(data_size_mb/10)*10 as Data_size_bucket_MB,
round(avg(resource_allocation_score),2) as Average_resource_score,
round(avg(resource_allocation_score * 1.0 / data_size_mb),3) as Efficiency_per_MB
from optimization_metrics group by data_size_bucket_MB
order by data_size_bucket_MB;

# High latency transactions that still succeeded
select a.transaction_type, a.status, concat(round(avg(b.latency_ms),2)," ms") as Average_latency,
round(avg(b.resource_allocation_score),3) as Average_resource_score
from blockchain_logs as a join optimization_metrics as b
on a.client_id = b.client_id
where b.latency_ms>200
group by a.transaction_type, a.status
order by Average_latency desc;

# Resource allocation stability over time
select date(a.timestamp) as Day, round(avg(b.resource_allocation_score),3) as Average_resource_score,
round(stddev(b.resource_allocation_score),3) as Variability
from blockchain_logs as a join optimization_metrics as b
on a.client_id = b.client_id
group by date(a.timestamp) order by Day;

# Peak system load times
select hour(a.timestamp) as Hour, concat(round(avg(b.latency_ms),2)," ms") as Average_latency,
concat(round(avg(b.aggregation_time_ms),2)," ms") as Average_aggregation_time
from blockchain_logs as a join optimization_metrics as b
on a.client_id = b.client_id
group by hour(a.timestamp) order by Hour;

# Performance drift check between first and second half of rounds
select case
when round <= (select max(round)/2 from optimization_metrics) then "First-half"
else "Second-half"
end as Round_period,
concat(round(avg(latency_ms),2)," ms") as Average_latency,
round(avg(resource_allocation_score),3) as Average_resource_score
from optimization_metrics
group by Round_period;

# Resource allocation efficiency by round
select round, round(avg(resource_allocation_score/NULLIF(latency_ms,0)),4) as Average_efficiency,
round(avg(bandwidth_mbps/NULLIF(aggregation_time_ms,0)),3) as Bandwidth_efficiency
from optimization_metrics
group by round order by round;