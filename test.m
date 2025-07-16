GPIB_addr = 25;
num_pts = 50;

V_fix = 1e-3;
V_start = 0;
V_stop = 1e-3;

I_fix = 1e-3;
I_start = 0;
I_stop = 1e-3;

dir = 'Up';

SMU = class_Keithley2400SourceMeter(GPIB_addr);
SMU.restore_default();
SMU.set_num_pts(num_pts);

SMU.set_source_const('V', V_fix);
SMU.measure();
SMU.plot_Vsrc();

SMU.set_source_sweep('V', V_start, V_stop, dir);
SMU.measure();
SMU.plot_Vsrc();

SMU.set_source_const('I', I_fix);
SMU.measure();
SMU.plot_Isrc();

SMU.set_source_sweep('I', I_start, I_stop, dir);
SMU.measure();
SMU.plot_Isrc();



clear