classdef class_Keithley2400SourceMeter < handle

    properties
        GPIB_device
        output = 'off';
        delay
        num_pts {mustBeNumeric}
        source_type
        source_mode
        bias_level {mustBeNumeric}
        soak_time {mustBeNumeric}
        source_level {mustBeNumeric}
        source_start {mustBeNumeric}
        source_stop {mustBeNumeric}
        sweep_direction
        raw_data
        data = struct();
    end

    methods
        function SMU = class_Keithley2400SourceMeter(GPIB_address)
            SMU.GPIB_device = visadev(append('GPIB::',num2str(GPIB_address),'::INSTR')); % initialize VISA device connection
        end

        function delete(SMU)
            % writeline(SMU.GPIB_device, 'GTL'); % go to local control
            delete(SMU.GPIB_device); % close VISA device connection
        end

        function restore_default(SMU)
            writeline(SMU.GPIB_device, '*RST'); % restore GPIB defaults
            writeline(SMU.GPIB_device, 'SOUR:CLE:AUTO ON'); % enable auto-output-off
            writeline(SMU.GPIB_device, 'SOUR:CLE:AUTO:MODE TCO'); % set auto-output-off when trigger count expires
            writeline(SMU.GPIB_device, 'FUNC "VOLT", "CURR", "RES"'); % set concurrent voltage, current, and resistance sensing
            writeline(SMU.GPIB_device, 'SENS:RES:MODE MAN'); % set ohms mode to manual
            writeline(SMU.GPIB_device, 'FORM:ELEM VOLT, CURR, RES, TIME, STAT'); % format data response, including timestamps and status info
        end

        function clear_error(SMU)
            writeline(SMU.GPIB_device, '*CLS'); % clear event registers and error queue
        end

        function abort(SMU)
            writeline(SMU.GPIB_device, 'ABOR'); % go idle
            writeline(SMU.GPIB_device, 'OUTP:STAT OFF'); % switch output off
            writeline(SMU.GPIB_device, 'TRIG:CLE');  % clear pending triggers
        end

        function reset_time(SMU)
            writeline(SMU.GPIB_device, 'SYST:TIME:RES'); % reset time to zero
        end

        function set_num_pts(SMU, num_pts)
            SMU.num_pts = num_pts;
            writeline(SMU.GPIB_device, append('TRAC:POIN ', num2str(SMU.num_pts))); % set buffer size (max 2500)
            writeline(SMU.GPIB_device, 'ARM:COUN 1'); % set arm count to 1
            writeline(SMU.GPIB_device, append('TRIG:COUN ', num2str(SMU.num_pts))); % set trigger count to match buffer size (trigger count * arm count <= 2500)
        end

        function set_source_const(SMU, type, level)
            switch type
                case 'V'
                    writeline(SMU.GPIB_device, 'SOUR:FUNC VOLT'); % set source function to voltage
                    writeline(SMU.GPIB_device, 'SOUR:VOLT:MODE FIX'); % set source mode to fixed
                    writeline(SMU.GPIB_device, append('SOUR:VOLT:TRIG ', num2str(level))); % set source level when triggered
                    SMU.source_type = 'Voltage';
                case 'I'
                    writeline(SMU.GPIB_device, 'SOUR:FUNC CURR'); % set source function to current
                    writeline(SMU.GPIB_device, 'SOUR:CURR:MODE FIX'); % set source mode to fixed
                    writeline(SMU.GPIB_device, append('SOUR:CURR:TRIG ', num2str(level))); % set source level when triggered
                    SMU.source_type = 'Current';
            end
            SMU.source_mode = 'Fixed';
            SMU.source_level = level;
            SMU.source_start = [];
            SMU.source_stop = [];
        end

        function set_source_sweep(SMU, type, lower_limit, upper_limit, direction)
            switch type
                case 'V'
                    writeline(SMU.GPIB_device, 'SOUR:FUNC VOLT'); % set source function to voltage
                    writeline(SMU.GPIB_device, 'SOUR:VOLT:MODE SWE'); % set source mode to sweep
                    writeline(SMU.GPIB_device, append('SOUR:VOLT:STAR ', num2str(lower_limit))); % set source start level
                    writeline(SMU.GPIB_device, append('SOUR:VOLT:STOP ', num2str(upper_limit))); % set source stop level
                    SMU.source_type = 'Voltage';
                case 'I'
                    writeline(SMU.GPIB_device, 'SOUR:FUNC CURR'); % set source function to current
                    writeline(SMU.GPIB_device, 'SOUR:CURR:MODE SWE'); % set source mode to sweep
                    writeline(SMU.GPIB_device, append('SOUR:CURR:STAR ', num2str(lower_limit))); % set source start level
                    writeline(SMU.GPIB_device, append('SOUR:CURR:STOP ', num2str(upper_limit))); % set source stop level
                    SMU.source_type = 'Current';
            end
            switch direction
                case 'Up'
                    writeline(SMU.GPIB_device, 'SOUR:SWE:DIR UP'); % set source sweep direction up
                case 'Down'
                    writeline(SMU.GPIB_device, 'SOUR:SWE:DIR DOWN'); % set source sweep direction down
            end
            writeline(SMU.GPIB_device, append('SOUR:SWE:POIN ', num2str(SMU.num_pts))); % set number of points for sweep
            SMU.source_mode = 'Sweep';
            SMU.source_level = [];
            SMU.source_start = lower_limit;
            SMU.source_stop = upper_limit;
            SMU.sweep_direction = direction;
        end

        

        function measure(SMU)
            SMU.raw_data = zeros(5,SMU.num_pts);
            writeline(SMU.GPIB_device, 'READ?');
            SMU.raw_data = str2double(split(readline(SMU.GPIB_device), ','));
            SMU.data.volt = SMU.raw_data(1:5:SMU.num_pts-4);
            SMU.data.curr = SMU.raw_data(2:5:SMU.num_pts-3);
            SMU.data.res = SMU.raw_data(3:5:SMU.num_pts-2);
            SMU.data.time = SMU.raw_data(4:5:SMU.num_pts-1)-SMU.raw_data(4);
            SMU.data.stat = SMU.raw_data(5:5:SMU.num_pts);
        end

        function fig = plot_Vsrc(SMU)
            fig = figure();
            tiledlayout(fig, 3, 1);
            ax1 = nexttile;
            plot(ax1, SMU.data.volt, SMU.data.curr);
            ylabel('Current (A)');
            ax2 = nexttile;
            plot(ax2, SMU.data.volt, SMU.data.res);
            ylabel('Resistance (\Omega)');
            ax3 = nexttile;
            plot(ax3, SMU.data.volt, SMU.data.time);
            xlabel('Voltage (V)');
            ylabel('Time (s)');
            linkaxes([ax1,ax2,ax3],'x');
        end

        function fig = plot_Isrc(SMU)
            fig = figure();
            tiledlayout(fig, 3, 1);
            ax1 = nexttile;
            plot(ax1, SMU.data.curr, SMU.data.volt);
            ylabel('Voltage (V)');
            ax2 = nexttile;
            plot(ax2, SMU.data.curr, SMU.data.res);
            ylabel('Resistance (\Omega)');
            ax3 = nexttile;
            plot(ax3, SMU.data.curr, SMU.data.time);
            xlabel('Current (A)');
            ylabel('Time (s)');
            linkaxes([ax1,ax2,ax3],'x');
        end

        
    end
end