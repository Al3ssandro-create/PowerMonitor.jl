## Usage

### Basic Example
```julia
using PowerMonitor

# Monitor power usage for 5 seconds
data = monitor_power(5.0)

# Save the data to a CSV file
log_power_data("power_data.csv", data)
```

### Monitoring a Code Block
```julia
@monitor_power_block "output.csv" begin
    # Your computation here
    for i in 1:10^7
        sqrt(i)
    end
end
```
