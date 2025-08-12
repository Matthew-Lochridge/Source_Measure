GPIB_addr_1 = 10;
GPIB_addr_2 = 25;

num_pts = 50;

V_gate = 0.1;

V_start = 0;
V_stop = 0.1;
dir = 'Up';

data = [];
fig = [];

spmd

    switch spmdIndex
    
        case 1
            ready = 0;
            SMU_1 = class_Keithley2400SourceMeter(GPIB_addr_1);
            SMU_1.restore_default();
            SMU_1.set_num_pts(num_pts);
            SMU_1.set_source_const('V', V_gate);
            ready = 1;
            while spmdPlus(ready) < 2
            end
            SMU_1.measure();
            data = SMU_1.data;
            fig = SMU_1.plot_Vsrc();

        case 2
            ready = 0;
            SMU_2 = class_Keithley2400SourceMeter(GPIB_addr_2);
            SMU_2.restore_default();
            SMU_2.set_num_pts(num_pts);
            SMU_2.set_source_sweep('V', V_start, V_stop, dir);
            ready = 1;
            while spmdPlus(ready) < 2
            end
            SMU_2.measure();
            data = SMU_2.data;
            fig = SMU_2.plot_Vsrc();

    end

end

