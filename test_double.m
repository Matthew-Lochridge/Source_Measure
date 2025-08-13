GPIB_addr = [10, 25];

num_pts = 50;

V_gate = 0.1;

V_start = 0;
V_stop = 0.1;
dir = 'Up';

spmd

    SMU = class_Keithley2400SourceMeter(GPIB_addr(spmdIndex));
    SMU.restore_default();
    SMU.set_num_pts(num_pts);

    switch spmdIndex
        case 1
            SMU.set_source_const('V', V_gate);

        case 2
            SMU.set_source_sweep('V', V_start, V_stop, dir);
    end

    spmdBarrier;
    SMU.measure();

    volt = SMU.data.volt;
    curr = SMU.data.curr;
    res = SMU.data.res;
    time = SMU.data.time;
    stat = SMU.data.stat;
    fig = SMU.plot_Vsrc();

end

