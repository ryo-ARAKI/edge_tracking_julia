#=
Compute the 2D system
    ẋ = -x + 10 y
    ẏ = y (10 e^(-0.01 x²) - y) (y - 1)
and investigate its edge state.

Cf.[Rich Kerswell, "Edge Tracking - Walking the Tightrope"](https://gfd.whoi.edu/wp-content/uploads/sites/18/2018/03/rich8_131207.pdf)
=#


"""
Module to define ODEs
"""
module ODE

"""
ODE function of the 2D system
    ẋ = -x + 10 y
    ẏ = y (10 e^(-0.01 x²) - y) (y - 1)
"""
function ODE_2D_system!(dX, X, p, t)
    # Set variables
    x, y = X

    dX[1] = (  # ẋ
        -x + 10.0 * y
    )
    dX[2] = (  # ẏ
        y * (10.0 * exp(-0.01 * x^2) - y) * (y - 1.0)
    )
end
end


"""
Module for output & plot results
"""
module Output
using Plots
using Printf

"""
Save timeseries in .d file
"""
function save_timeseries(
    filename, sol
)

    full_filename = (
        "result/"
        * filename
        * ".d"
    )

    open(full_filename, "w") do f
        for itr = 1:length(sol.t)
            println(
                f,
                @sprintf "%.3e %.5e %.5e" sol.t[itr] sol[1, itr] sol[2, itr]  # t, x, y
            )
        end
    end
    println("Save: ", full_filename)

end
end


using DifferentialEquations
using Printf
using LaTeXStrings
using PyPlot
using .ODE: ODE_2D_system!
using .Output: save_timeseries

# ========================================
# Main function
# ========================================
function main()

    # Set list of initial condition for x and y
    ic_x_list = [-3.0:3.0:18.0;]
    ic_y_list = [-3.0; 0.99; 1.01]
    # Set time range to compute
    t_span = (0.0, 50.0)

    # Prepare result/ directory if not present
    try
        mkdir("result")
        println("Create ", pwd(), "/result/ to save result.\n")
    catch
        println(pwd(), "/result/ directory already exists.\n")
    end

    # Set up plot configurations
    fig, ax = subplots()
    ax.set_xlabel(L"x")
    ax.set_ylabel(L"y")

    # Stdout problem information
    println(
        "Solve:
        ẋ = -x + 10 y
        ẏ = y (10 e^(-0.01 x²) - y) (y - 1)\n"
    )
    println("Time range: ", t_span)

    # Iteration over initial condition
    for ic_x in ic_x_list, ic_y in ic_y_list

        # Set initial condition
        init_cond = [ic_x; ic_y]

        # Set up strings
        filename_parameter = @sprintf "ic=%.2f_%.2f" init_cond[1] init_cond[2]

        # Set up the problem
        prob = ODEProblem(ODE_2D_system!, init_cond, t_span)

        # Solve the problem
        arg = RK4()
        sol = solve(prob, arg, adaptive = false, dt = 0.002)

        # Save result of the problem
        filename = "2dsystem_" * filename_parameter
        save_timeseries(filename, sol)

        # Plot result
        ax.plot(
            sol[1, :], sol[2, :],  # x, y
            color = "Navy",
            zorder = 1
        )
    end

    # Plot the edge and varuous status of the model
    ax.axhline(  # The edge line
        y = 1.0,
        color = "Gold",
        zorder = 2
    )
    state_x = [0.0; 10.0; 14.0]  # The laminar, edge, and turbulent states
    state_y = [0.0; 1.0; 1.4]
    ax.scatter(
        state_x, state_y,
        color = "red",
        zorder = 3
    )

    # Save figure
    filename_figure = "result/" * "2dsystem.png"
    savefig(filename_figure)
    println("Save: ", filename_figure)

end

main()
