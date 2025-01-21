# PowerMonitor.jl

**PowerMonitor.jl** is a Julia library for monitoring power consumption of CPUs and GPUs. It provides tools to track energy usage, log data to files, and monitor power during code execution.


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

