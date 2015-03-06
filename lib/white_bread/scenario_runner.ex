defmodule WhiteBread.ScenarioRunner do

  def run(context, scenario) do

    starting_state = %{}

    reduction = fn
      (step, {:ok, state})                            -> run_step(context, step, state)
      (_step, {:missing_step, missing_step})          -> {:missing_step, missing_step}
      (_step, {:no_clause_match, failing_step})       -> {:no_clause_match, failing_step}
      (_step, {:fail, failing_step, assertion_error}) -> {:fail, failing_step, assertion_error}
      (_step, error_data)                             -> error_data
    end

    result = scenario.steps
    |> Enum.reduce({:ok, starting_state}, reduction)

    case result do
      {:ok, _}                       -> {:ok, scenario.name}
      {:missing_step, step}          -> {:failed, {:missing_step, step}}
      {:no_clause_match, step}       -> {:failed, {:no_clause_match, step}}
      {:fail, step, assertion_error} -> {:failed, {:assertion_failure, step, assertion_error}}
      error_data                     -> {:failed, error_data}
    end
  end

  defp run_step(context, step, state) do
    apply(context, :execute_step, [step, state])
  end

end
