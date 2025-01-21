# PowerMonitor.jl

**PowerMonitor.jl** is a Julia library for monitoring power consumption of CPUs and GPUs. It provides tools to track energy usage, log data to files, and monitor power during code execution.

---

## Features

- **GPU Monitoring**: Uses NVML (NVIDIA Management Library) to measure GPU power consumption.
- **CPU Monitoring**: Uses the Linux RAPL interface to measure CPU power usage.
- **Logging**: Logs power data to CSV files for analysis.
- **Code Block Monitoring**: A macro for tracking power usage during code execution.

---

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/PowerMonitor.jl.git
   cd PowerMonitor.jl
   ```

2. Activate the environment:
   ```julia
   using Pkg
   Pkg.activate(".")
   ```

3. Install dependencies:
   ```julia
   Pkg.instantiate()
   ```

---

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

---

## Documentation

The full documentation is available [here](https://Al3ssandro-create.github.io/PowerMonitor.jl/).

It includes:
- **API reference** for all functions, types, and macros.
- **Examples** demonstrating key features.

---

## Requirements

- Julia 1.6 or higher
- CUDA-enabled NVIDIA GPU
- Linux system with RAPL enabled for CPU power monitoring

---

## Contributing

Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Submit a pull request.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
