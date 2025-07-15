classdef class_Keithley2400SourceMeter < handle

    properties
        GPIB_address {mustBeNumeric}
        output = 'off';
        delay
        num_pts {mustBeNumeric} = 2500;
        source_type
        source_mode
        bias_level {mustBeNumeric}
        soak_time {mustBeNumeric}
        source_level {mustBeNumeric}
        source_start {mustBeNumeric}
        source_stop {mustBeNumeric}
        sweep_direction
        data = struct();
    end

    methods
        function device = class_Keithley2400SourceMeter(GPIB_address)
            device = visadev(append('GPIB::',num2str(GPIB_address),'::INSTR'));
            device.GPIB_address = GPIB_address;
        end

        function restore_default(device)
            writeline(device, ':*RST'); % restore GPIB defaults
            writeline(device, ':SOUR:CLE:AUTO ON'); % enable auto-output-off
            writeline(device, ':SOUR:CLE:AUTO:MODE TCO'); % set auto-output-off when trigger count expires
            writeline(device, ':SENS:CONC:ALL'); % set concurrent voltage, current, and resistance sensing
            writeline(device, ':FORM:ELEM, VOLT, CURR, RES, TIME, STAT'); % format data response, including timestamps and status info
        end

        function clear_error(device)
            writeline(device, ':*CLS'); % clear event registers and error queue
        end

        function abort(device)
            writeline(device, ':ABOR'); % go idle
        end

        function set_source_const(device, type, level)
            switch type
                case 'V'
                    writeline(device, ':SOUR:FUNC VOLT'); % set source function to voltage
                    writeline(device, ':SOUR:VOLT:MODE FIX'); % set source mode to fixed
                    writeline(device, append(':SOUR:VOLT:TRIG ', num2str(level))); % set source level when triggered
                    device.source_type = 'Voltage';
                case 'I'
                    writeline(device, ':SOUR:FUNC CURR'); % set source functino to current
                    writeline(device, ':SOUR:CURR:MODE FIX'); % set source mode to fixed
                    writeline(device, append(':SOUR:CURR:TRIG ', num2str(level))); % set source level when triggered
                    device.source_type = 'Current';
            end
            device.source_mode = 'Fixed';
            device.source_level = level;
            device.source_start = [];
            device.source_stop = [];
        end

        function set_source_sweep(device, type, lower_limit, upper_limit, direction)
            switch type
                case 'V'
                    writeline(device, ':SOUR:FUNC VOLT'); % set source function to voltage
                    writeline(device, ':SOUR:VOLT:MODE SWE'); % set sourc emode to sweep
                    writeline(device, append(':SOUR:VOLT:STAR ', num2str(lower_limit))); % set source start level
                    writeline(device, append(':SOUR:VOLT:STOP ', num2str(upper_limit))); % set source stop level
                    device.source_type = 'Voltage';
                case 'I'
                    writeline(device, ':SOUR:FUNC CURR'); % set source function to current
                    writeline(device, ':SOUR:CURR:MODE SWE'); % set source mode to sweep
                    writeline(device, append(':SOUR:CURR:STAR ', num2str(lower_limit))); % set source start level
                    writeline(device, append(':SOUR:CURR:STOP ', num2str(upper_limit))); % set source stop level
                    device.source_type = 'Current';
            end
            switch direction
                case 'Up'
                    writeline(device, ':SOUR:SWE:DIR UP'); % set source sweep direction up
                case 'Down'
                    writeline(device, ':SOUR:SWE:DIR DOWN'); % set source sweep direction down
            end
            writeline(device, append(':SOUR:SWE:POIN ', num2str(device.num_pts))); % set number of points for sweep
            device.source_mode = 'Sweep';
            device.source_level = [];
            device.source_start = lower_limit;
            device.source_stop = upper_limit;
            device.sweep_direction = direction;
        end

        function data = trigger(device)
            writeline(device, ':READ?');
            data = str2double(split(readline(device), ','));
        end
    end
end