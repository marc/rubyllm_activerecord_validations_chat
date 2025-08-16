class DonutLogValidationsTool < RubyLLM::Tool
  description "Gets current validations for the DonutLog model"

  def execute
    DonutLog.load_schema
    {
      model: DonutLog.inspect,
      validations: DonutLog._validators,
      important_context: <<~END_OF_CONTEXT
        now means the current date and time

        allow_blank: true means that the field can be blank
        blank: true means that the field must be blank
        present: true means that the field must be present

        do not confuse flavor, filling and glaze.
        vanilla-pudding is a filling and not a flavor
      END_OF_CONTEXT
    }
    rescue => e
      { error: e.message }
  end
end
  