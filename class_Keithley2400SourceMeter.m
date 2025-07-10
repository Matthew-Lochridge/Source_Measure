classdef class_Keithley2400SourceMeter < handle

    properties
        GPIB_address {mustBeNumeric}
        output = 'off';
        source_type
        measure_type
        source_mode
    end

    methods
        function device = class_Keithley2400SourceMeter(GPIB_address)
            device = visadev(append('GPIB::',num2str(GPIB_address),'::INSTR'));
            writeline(device, ':SOUR:CLE:AUTO ON'); % set output to automatically switch on and off for measurement
            device.GPIB_address = GPIB_address;
        end

        function restore_default(device)
            writeline(device, ':*RST'); % restore GPIB defaults
        end

        function clear_error(device)
            writeline(device, ':*CLS'); % clear event registers and error queue
        end

        function abort(device)
            writeline(device, ':ABOR'); % go idle
        end

        function set_constant_source(device, source_type, source_level)
            switch source_type
                case 'V'
                    writeline(device, ':SOUR:FUNC VOLT');
                    writeline(device, ':SOUR:VOLT:MODE FIX');
                    writeline(device, append(':SOUR:VOLT:TRIG ', num2str(source_level)));
                    device.source_type = 'Voltage';
                case 'I'
                    writeline(device, ':SOUR:FUNC CURR');
                    writeline(device, ':SOUR:CURR:MODE FIX');
                    writeline(device, append(':SOUR:CURR:TRIG ', num2str(source_level)));
                    device.source_type = 'Current';
            end
            device.source_mode = 'Constant';
        end

        function set_sweep(device, source_type, source_level)
            switch source_type
                case 'V'
                    writeline(device, ':SOUR:FUNC VOLT');
                    writeline(device, ':SOUR:VOLT:MODE SWE');
                    writeline(device, append(':SOUR:VOLT:TRIG ', num2str(source_level)));
                    device.source_type = 'Voltage';
                case 'I'
                    writeline(device, ':SOUR:FUNC CURR');
                    writeline(device, ':SOUR:CURR:MODE SWE');
                    writeline(device, append(':SOUR:CURR:TRIG ', num2str(source_level)));
                    device.source_type = 'Current';
            end
            device.source_mode = 'Constant';
        end

        function data = trigger(device)
            writeline(device, ':READ?');
            data = str2double(split(readline(device), ','));
        end
    end
end