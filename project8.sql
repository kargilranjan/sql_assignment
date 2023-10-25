use project8;


show tables;
                    select * from affiliated_with ;
                     select * from appointment;
                      select * from block;
                       select * from department;
                        select * from medication ;
                         select * from nurse;
                          select * from on_call;
                           select * from patient ;
                            select * from physician;
                             select * from prescribes;
                              select * from procedures;
                               select * from room;
                                select * from stay;
                                 select * from trained_in ;
                                  select * from undergoes ;

       -- 8.1 Obtain the names of all physicians that have performed a medical procedure they have never been certified to perform.
                
         select * from undergoes ;
         select * from physician;
          select * from trained_in ;
        select p.name
        from physician as p join trained_in as t
        on p.employeeid=t.physician
        where t.treatment not in (select procedures
                                   from undergoes
                                   group by physician
                                   );
-- 8.2 Same as the previous query, but include the following information in the results: 
-- Physician name, name of procedure, date when the procedure was carried out, name of the patient the procedure was carried out on.

	 select p.name,u.dateundergoes,u.patient,u.procedures,pp.name
        from physician as p join trained_in as t
        on p.employeeid=t.physician
         join procedures as pp 
        on pp.code=t.treatment
        join undergoes as u
        on t.physician =u.physician
        where t.treatment not in (select procedures
                                   from undergoes
                                   group by physician);
                                   
-- 8.3 Obtain the names of all physicians that have performed a medical procedure that they are certified to perform,
--  but such that the procedure was done at a date (Undergoes.Date) after the physician's certification expired (Trained_In.CertificationExpires).
                                                
                                     select name
                                        from physician 
                                        where employeeid in (select physician
                                                             from trained_in
                                                             where certificationexpires  <any(select dateundergoes
                                                                                          from undergoes));

-- 8.4 Same as the previous query, but include the following information in the results: 
-- Physician name, name of procedure, date when the procedure was carried out, name of the patient 
-- the procedure was carried out on, and date when the certification expired.
                           
                        select p.name,u.procedures,pp.name,u.dateundergoes,u.patient,t.certificationexpires
                        from physician as p join trained_in as t
                        on t.physician=p.employeeid
                        join undergoes as u 
                        on t.treatment =u.procedures
                        join procedures as pp 
                        on pp.code =t.treatment
                        where t.certificationexpires <any (select dateundergoes
                                                           from undergoes);
                                                           
-- 8.5 Obtain the information for appointments where a patient met with a physician other than 
-- his/her primary care physician. Show the following information: Patient name, physician name, 
-- nurse name (if any), start and end time of appointment, examination room, and the name of the patient's primary care physician.
   select * from undergoes ;
                          select *from procedures;
         select * from physician;
          select * from trained_in ; 

-- 8.6 The Patient field in Undergoes is redundant, since we can obtain it from the Stay table. There are no constraints in force to prevent inconsistencies between these two tables. More specifically, the Undergoes table may include a row where the patient ID does not match the one we would obtain from the Stay table through the Undergoes.Stay foreign key. Select all rows from Undergoes that exhibit this inconsistency.
SELECT U.*
FROM Undergoes U
LEFT JOIN Stay S ON U.Stay = S.StayID
WHERE U.Patient != S.Patient
OR U.Patient IS NULL
OR S.Patient IS NULL;

-- 8.7 Obtain the names of all the nurses who have ever been on call for room 123.
SELECT DISTINCT N.Name
FROM Nurse N
JOIN On_Call OC ON N.EmployeeID = OC.Nurse
JOIN Room R ON OC.BlockFloor = R.BlockFloor AND OC.BlockCode = R.BlockCode
WHERE R.RoomNumber = 123;

-- 8.8 The hospital has several examination rooms where appointments take place. Obtain the number of appointments that have taken place in each examination room.
SELECT ExaminationRoom, COUNT(*) AS NumberOfAppointments
FROM Appointment
GROUP BY ExaminationRoom
ORDER BY NumberOfAppointments DESC;

-- 8.9 Obtain the names of all patients (also include, for each patient, the name of the patient's primary care physician), such that \emph{all} the following are true:
    -- The patient has been prescribed some medication by his/her primary care physician.
    -- The patient has undergone a procedure with a cost larger that $5,000
    -- The patient has had at least two appointment where the nurse who prepped the appointment was a registered nurse.
    -- The patient's primary care physician is not the head of any department.
SELECT DISTINCT P.Name AS PatientName, PCP.Name AS PrimaryCarePhysician
FROM Patient AS P
JOIN Physician AS PCP ON P.PCP = PCP.EmployeeID
WHERE P.SSN IN (
    SELECT DISTINCT Patient
    FROM Prescribes
    WHERE Medication IN (
        SELECT Code
        FROM Medication
        WHERE Brand IS NOT NULL
    )
)
AND P.SSN IN (
    SELECT DISTINCT Patient
    FROM Undergoes
    WHERE DateUndergoes IN (
        SELECT DateUndergoes
        FROM Undergoes
        WHERE Procedures IN (
            SELECT Code
            FROM Procedures
            WHERE Cost > 5000
        )
        GROUP BY DateUndergoes
        HAVING COUNT(*) >= 2
    )
)
AND PCP.EmployeeID IN (
    SELECT Head
    FROM Department
    WHERE Head IS NOT NULL
);
