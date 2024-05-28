select sdj.JOB,
         jjd.job_name,
         sdj.NEXT_DATE
    from sys.dba_jobs sdj,
         job_man.job_definition jjd
   where sdj.JOB = jjd.job_id
     and sdj.next_date < (sysdate - 1 / 24);


--Stop Job

select * from job_man.vw_long_running_jobs

select * from dba_scheduler_running_jobs ---where job_name like 'DBMS_JOB$_<JOBID>%'; -- REPLACE JOBID WITH REAL JOBID


--Run as owner of ther job

exec DBMS_SCHEDULER.STOP_JOB(job_name => 'DBMS_JOB$_JOBID',force => TRUE);-- REPLACE JOBID WITH REAL JOBID
