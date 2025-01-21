module PowerMonitor

using CUDA

"""
Structure to store power monitoring data.

## Fields:
- `time::Vector{Float64}`: Time points (in seconds) when measurements were taken.
- `gpu_power::Vector{Float64}`: GPU power consumption values (in watts).
- `cpu_power::Vector{Float64}`: CPU power consumption values (in watts).

## Example:
```julia
data = PowerData([0.1, 0.2], [50.0, 52.0], [10.0, 12.0])
println(data.gpu_power)  # [50.0, 52.0]
```
"""
mutable struct PowerData
    time::Vector{Float64}
    gpu_power::Vector{Float64}
    cpu_power::Vector{Float64}
end

"""
Structure to monitor CPU power consumption using RAPL (Running Average Power Limit).

## Fields:
- `prev_energy::Float64`: Energy consumption at the previous measurement (in joules).
- `prev_time::Float64`: Time of the previous measurement (in seconds).
- `initialized::Bool`: Whether the monitor has been initialized.

## Constructor:
Creates a new `CPUPowerMonitor` instance with default values.

## Example:
```julia
monitor = CPUPowerMonitor()
println(monitor.initialized)  # false
```
"""
mutable struct CPUPowerMonitor
    prev_energy::Float64
    prev_time::Float64
    initialized::Bool

    function CPUPowerMonitor()
        return new(0.0, 0.0, false)
    end
end

"""
Initializes GPU power monitoring by ensuring CUDA and NVML are available.

## Throws:
- An error if CUDA is not available.
- An error if NVML is not available.

## Example:
```julia
init_gpu_monitor()
println("GPU monitoring initialized.")
```
"""
function init_gpu_monitor()
    if !CUDA.has_cuda()
        error("CUDA is not available. Ensure that the CUDA toolkit is installed.")
    end
    if !CUDA.has_nvml()
        error("NVML is not available. Ensure that the NVIDIA driver is installed.")
    end
end

"""
Placeholder function for GPU power monitoring cleanup. Currently, no explicit cleanup is required.

## Example:
```julia
terminate_gpu_monitor()
println("GPU monitoring terminated.")
```
"""
function terminate_gpu_monitor()
    # No cleanup required
end

"""
Monitors power consumption of the GPU and CPU over a specified duration.

## Parameters:
- `duration::Float64`: Total duration of monitoring (in seconds).
- `interval::Float64`: Sampling interval for power measurements (in seconds, default = 0.001).

## Returns:
- `PowerData`: A structure containing time, GPU power, and CPU power data.

## Example:
```julia
data = monitor_power(5.0)
println("GPU power: ", data.gpu_power)
println("CPU power: ", data.cpu_power)
```
"""
function monitor_power(duration::Float64, interval::Float64 = 0.001)
    init_gpu_monitor()
    device = NVML.Device(0)  # Assuming GPU device 0
    power_data = PowerData([], [], [])
    cpu_monitor = CPUPowerMonitor()
    start_time = time()

    while time() - start_time < duration
        elapsed = time() - start_time
        gpu_power = NVML.power_usage(device)
        cpu_power = read_cpu_power(cpu_monitor)

        push!(power_data.time, elapsed)
        push!(power_data.gpu_power, gpu_power)
        push!(power_data.cpu_power, cpu_power)
        sleep(interval)
    end

    terminate_gpu_monitor()
    return power_data
end

"""
Reads CPU power consumption using the Linux sysfs interface.

## Parameters:
- `cpu_monitor::CPUPowerMonitor`: The CPU power monitor state.

## Returns:
- `Float64`: The calculated CPU power consumption (in watts).

## Throws:
- Error if unable to read from the RAPL sysfs interface.

## Example:
```julia
cpu_monitor = CPUPowerMonitor()
power = read_cpu_power(cpu_monitor)
println("CPU power: ", power)
```
"""
function read_cpu_power(cpu_monitor::CPUPowerMonitor)
    try
        power_file = "/sys/class/powercap/intel-rapl:0/energy_uj"
        open(power_file, "r") do io
            current_energy = parse(Float64, readline(io)) / 1e6  # Convert microjoules to joules
            current_time = time()

            if !cpu_monitor.initialized
                # Initialize state on the first read
                cpu_monitor.prev_energy = current_energy
                cpu_monitor.prev_time = current_time
                cpu_monitor.initialized = true
                return 0.0  # No meaningful power calculation for the first read
            end

            # Calculate power as delta energy / delta time
            delta_energy = current_energy - cpu_monitor.prev_energy
            delta_time = current_time - cpu_monitor.prev_time

            # Update state
            cpu_monitor.prev_energy = current_energy
            cpu_monitor.prev_time = current_time

            return delta_energy / delta_time  # Power in watts
        end
    catch e
        error("Unable to read CPU power. Ensure RAPL is enabled. Error: $(e)")
    end
end

"""
Logs power data to a CSV file.

## Parameters:
- `file_name::String`: Name of the CSV file to save the data.
- `power_data::PowerData`: The power data to log.

## Output:
- The CSV file contains three columns: `Time(s)`, `GPU_Power(W)`, and `CPU_Power(W)`.

## Example:
```julia
data = PowerData([0.1, 0.2], [50.0, 52.0], [10.0, 12.0])
log_power_data("power_data.csv", data)
println("Power data logged to file.")
```
"""
function log_power_data(file_name::String, power_data::PowerData)
    open(file_name, "w") do io
        println(io, "Time(s),GPU_Power(W),CPU_Power(W)")
        for i in 1:length(power_data.time)
            println(io, "$(power_data.time[i]),$(power_data.gpu_power[i]),$(power_data.cpu_power[i])")
        end
    end
end

"""
Monitors power consumption (GPU and CPU) during the execution of a code block.

## Parameters:
- `file_name::String`: Name of the CSV file to save the power data.
- `block`: The code block to monitor.

## Usage:
```julia
@monitor_power_block "output.csv" begin
    for i in 1:10^6
        sqrt(i)
    end
end
```
"""
macro monitor_power_block(file_name::String, block)
    return quote
        println("Starting power monitoring...")
        
        # Initialize power data and CPU monitor
        local data = PowerMonitor.PowerData([], [], [])
        local cpu_monitor = PowerMonitor.CPUPowerMonitor()

        # Start monitoring power in a separate task
        local block_completed = Ref(false)  # Use a reference for shared state
        local monitoring_task = @async begin
            PowerMonitor.init_gpu_monitor()
            try
                while !block_completed[]
                    elapsed = time()
                    gpu_power = NVML.power_usage(NVML.Device(0))  # Assuming GPU 0
                    cpu_power = PowerMonitor.read_cpu_power(cpu_monitor)

                    push!(data.time, elapsed)
                    push!(data.gpu_power, gpu_power)
                    push!(data.cpu_power, cpu_power)
                    sleep(0.1)  # Adjust interval as needed
                end
            finally
                PowerMonitor.terminate_gpu_monitor()
            end
        end

        # Execute the block of code
        local block_start = time()
        $(esc(block))  # Execute the user-provided block
        local block_end = time()

        println("Code execution completed. Duration: $(block_end - block_start) seconds.")
        block_completed[] = true  # Notify monitoring task to stop

        # Wait for the monitoring task to complete
        fetch(monitoring_task)

        # Log power data
        PowerMonitor.log_power_data($file_name, data)
    end
end

end
