GPIB_addr = 25;
num_pts = 50;

V_fix = 0.1;
V_start = 0;
V_stop = 0.1;

I_fix = 1e-3;
I_start = 0;
I_stop = 1e-3;

dir = 'Up';

SMU = class_Keithley2400SourceMeter(GPIB_addr);
SMU.restore_default();
SMU.set_num_pts(num_pts);

SMU.set_source_const('V', V_fix);
SMU.measure();