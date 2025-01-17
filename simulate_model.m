% Function to simulate the model
function [DA, DAads, DAtotal] = simulate_model(parameters, time)

    % Extract parameters
    r = parameters(1);
    ke = parameters(2);
    ku = parameters(3);
    kads = parameters(4);
    kdes = parameters(5);

    % Define initial conditions
    initial_conditions = [0, 0]; % Initial DA and DAads

    % Solve the differential equations using ODE45
    [t, y] = ode45(@(t, y) model_equations(t, y, r, ke, ku, kads, kdes), time, initial_conditions);

    % Extract DA, DAads, and total DA
    DA = y(:, 1);
    DAads = y(:, 2);
    DAtotal = DA + DAads;

end

% Function to define the differential equations
function dydt = model_equations(t, y, r, ke, ku, kads, kdes)

    DA = y(1);
    DAads = y(2);

    dDA_dt = r * exp(-ke * t) - ku * DA - kads * DA + kdes * DAads;
    dDAads_dt = kads * DA - kdes * DAads;

    dydt = [dDA_dt; dDAads_dt];

end