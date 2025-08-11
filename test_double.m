GPIB_addr_1 = 10;
GPIB_addr_2 = 25;

num_pts = 50;

V_gate = 0.1;

V_start = 0;
V_stop = 0.1;

SMU_1 = class_Keithley2400SourceMeter(GPIB_addr_1);
SMU_2 = class_Keithley2400SourceMeter(GPIB_addr_2);

SMU_1.restore_default();
SMU_2.restore_default();

SMU_1.set_num_pts(num_pts);
SMU_2.set_num_pts(num_pts);

dir = 'Up';

SMU_1.set_source_const('V', V_gate);
SMU_2.set_source_sweep('V', V_start, V_stop, dir);

pool = parpool(2);

spmd

    switch spmdIndex
    
        case 1
            SMU_1.measure();

        case 2
            SMU_2.measure();

    end

end

SMU_1.plot_Vsrc();
SMU_2.plot_Vsrc();

clear