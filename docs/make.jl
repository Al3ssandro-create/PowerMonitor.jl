# docs/make.jl

using Documenter

# Include the PowerMonitor.jl file to load the module
include("../src/PowerMonitor.jl")
using .PowerMonitor  # Use relative reference for the module

# Generate documentation
Documenter.makedocs(
    sitename = "PowerMonitor.jl Documentation",  # Name of the documentation site
    modules = [PowerMonitor],                    # Modules to document
    format = Documenter.HTML(inventory_version="0.1.0"),                  # Output format (HTML)
    pages = [
        "Home" => "index.md",                    # Main page
        "API" => "api.md",                       # API documentation
    ],
)
