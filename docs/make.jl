# docs/make.jl

using Documenter

# Include the PowerMonitor.jl file to load the module
include("../src/PowerMonitor.jl")
using .PowerMonitor  # Use relative reference for the module

# Generate documentation
Documenter.makedocs(
    sitename = "PowerMonitor.jl",  # Name of the documentation site
    modules = [PowerMonitor],                    # Modules to document
    format = Documenter.HTML(inventory_version="0.1.0"),                  # Output format (HTML)
    pages = [
        "Home" => "index.md",                    # Main page
        "Manual" => [                            # Guide page with nested structure
            "Installation" => "guide/installation.md",  # Add installation page
            "API" => "guide/api.md",                  # API documentation under Guide
        ]
    ],
)
