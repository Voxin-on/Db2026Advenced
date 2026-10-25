do $$
begin
    insert into batch (id, soldier_id, device_id) values (100, 1, 1);
    insert into parameters (batch_id, type_par_id, unit_meas_id, value) values 
    (100, 2, 2, 100.0);

    insert into batch (id, soldier_id, device_id) values (101, 1, 1);
    insert into parameters (batch_id, type_par_id, unit_meas_id, value) values 
    (101, 3, 3, 2000),
    (101, 6, 1, 50);

    insert into batch (id, soldier_id, device_id) values (102, 1, 2);
    insert into parameters (batch_id, type_par_id, unit_meas_id, value) values 
    (102, 4, 4, 99);

    insert into batch (id, soldier_id, device_id) values (103, 2, 1);
    insert into parameters (batch_id, type_par_id, unit_meas_id, value) values 
    (103, 5, 5, 20);

    insert into batch (id, soldier_id, device_id) values (104, 2, 2);
    insert into parameters (batch_id, type_par_id, unit_meas_id, value) values 
    (104, 6, 1, 200),
    (104, 5, 5, 5);

    insert into batch (id, soldier_id, device_id) values (105, 3, 1);
    insert into parameters (batch_id, type_par_id, unit_meas_id, value) values 
    (105, 2, 2, -100.0);
end $$;