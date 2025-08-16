# ActiveRecord Validations RubyLLM Chat - Sample Rails App with DonutLog Model

A Rails 7.2 application that demonstrates advanced validation patterns using the `be_valid` gem and integrates with local LLM capabilities through `ruby_llm` and Ollama.

##  🍩 Chatting with the DonutLog Model 🔧

We can open a chat about the DonutLog model validations from the rails console:

```ruby
chat = RubyLLM.chat(model: "llama3.2", provider: "ollama")
chat.with_tool(DonutLogValidationsTool)
response = chat.ask "What validations apply for a DonutLog with filled donut type?"
puts response.content
```
Response:
```
For a DonutLog with filled donut type, the following validations apply:

1. `ate_at`: The date and time of consumption must be in the past.
2. `user_id`: The user ID must be present (i.e., not blank or null).
3. `amount`: The amount consumed must be greater than 0 and less than or equal to 12.
4. `donut_type`: The donut type must be one of "filled".
5. For flavored donuts ("plain", "glazed", "cake"), the flavor must be one of "plain", "chocolate", or "strawberry".
6. For fritter donuts, the flavor must be one of "cinnamon" or "apple".
7. For plain or glazed donuts, the glaze must be one of "plain", "chocolate", "strawberry", or "maple". (Note that glaze is allowed to be blank for plain or glazed donuts.)
8. For filled donuts, the filling must be one of "vanilla-pudding", "vanilla-cream", "chocolate-pudding", "raspberry", "blueberry", or "apple". (Note that filling is allowed to be blank for plain or glazed donuts.)
```


We can also ask it to generate sample values based on its understanding of the validations:

```ruby
chat = RubyLLM.chat(model: "llama3.2", provider: "ollama")
chat.with_tool(DonutLogValidationsTool)
response = chat.ask "Show me a valid DonutLog for a fritter with apple flavor."
puts response.content
```
Response:

    A valid DonutLog for a fritter with apple flavor could look like this:

    ```
    {
    "id": 1,
    "user_id": 1,
    "amount": 2.5,
    "ate_at": "2023-03-09T14:30:00Z",
    "donut_type": "fritter",
    "flavor": "apple",
    "glaze": "none",
    "filling": "vanilla-pudding",
    "location": "kitchen",
    "note": "",
    "created_at": "2023-03-09T14:30:00Z",
    "updated_at": "2023-03-09T14:30:00Z"
    }
    ```

    This DonutLog represents a fritter with apple flavor that was eaten by user 1. The amount of the donut consumed is 2.5 units, and it was eaten at 14:30 on March 9th, 2023. The donut has no glaze, but it does have vanilla-pudding filling.


However, when we test the values provided in the response we can see that they are not valid for a DonutLog.

```ruby
donut_log = DonutLog.new({
  "id": 1,
  "user_id": 1,
  "amount": 2.5,
  "ate_at": "2023-03-09T14:30:00Z",
  "donut_type": "fritter",
  "flavor": "apple",
  "glaze": "none",
  "filling": "vanilla-pudding",
  "location": "kitchen",
  "note": "",
  "created_at": "2023-03-09T14:30:00Z",
  "updated_at": "2023-03-09T14:30:00Z"
})
donut_log.valid?
# => false
puts donut_log.errors.full_messages
# Glaze : 'none' is not a valid value when donut_type = fritter. Valid values: plain.
# Filling must be blank when donut_type = fritter.
```

## 🍩 Chatting without a Tool 🔧

RubyLLM supports tools but does not require them.
We can also reference the `donut_log.rb` file as context and skip the `DonutLogValidationsTool` entirely.

```ruby
chat = RubyLLM.chat(model: "llama3.2", provider: "ollama")
response = chat.ask "What validations apply for a DonutLog for a filled donut type?", with: "app/models/donut_log.rb"
puts response.content
```

Response:
```The validations for a DonutLog for a filled donut type are as follows:

1. `donut_type` must be one of the following values:
   - `plain`
   - `glazed`
   - `filled`
   - `hole`
   - `cake`
   - `fritter`

2. The value of `flavor` depends on the value of `donut_type`. When `donut_type` is one of the following values:
   - `plain`
   - `glazed`
   - `filled`
   - `hole`
   - `cake`, then `flavor` must be one of the following values:
     - `plain`
     - `chocolate`
     - `strawberry`
     - `blueberry`

3. When `donut_type` is `fritter`, then `flavor` can be either `cinnamon` or `apple`.

4. The value of `glaze` depends on the value of `donut_type`. When `donut_type` is one of the following values:
   - `plain`
   - `glazed`
   - `filled`
   - `hole`
   - `cake`, then `glaze` must be one of the following values:
     - `plain`
     - `chocolate`
     - `strawberry`
     - `maple`

5. When `donut_type` is `fritter`, then `glaze` can be either `plain`.

6. The value of `filling` depends on the value of `donut_type`. When `donut_type` is `filled`, then `filling` must be one of the following values:
     - `vanilla-pudding`
     - `vanilla-cream`
     - `chocolate-pudding`
     - `raspberry`
     - `blueberry`
     - `apple`

7. When `donut_type` is `plain`, `glazed`, `hole`, or `cake`, then `filling` must be blank.

The following rules are also applied:

- The value of `ate_at` must be in the past.
- The value of `user_id` must be greater than 0.
- The value of `amount` must be greater than 0 and less than or equal to 12.
```


## 🍩 DonutLog Model

You no longer have to worry about forgetting what donuts you ate! The core feature of this application is the `DonutLog` model, which keeps a detailed log of when and what donuts someone eats. This model showcases comprehensive validation patterns using the `be_valid` gem.

### Features
- **Comprehensive Donut Tracking**: Log donut type, flavor, glaze, filling, location, and notes
- **Smart Validation Rules**: Conditional validations based on donut type (e.g., fritters have different flavor options)
- **Date Validation**: Ensures donut consumption dates are in the past
- **Flexible Attributes**: Optional fields for glaze and filling

### Validation Rules

#### Core Validations
- **`ate_in_past`**: Ensures `ate_at` timestamp is in the past (with 60-second leniency for server clocks)
- **`user_id_present`**: Validates user ID is greater than 0
- **`amount_min`**: Validates amount is greater than 0
- **`amount_max`**: Validates amount is less than or equal to 12
- **`donut_type_valid`**: Restricts donut types to allowed values

#### Conditional Flavor Validations
- **`donut_flavor_valid`**: For regular donuts (`plain`, `glazed`, `filled`, `hole`, `cake`), flavor must be one of: `plain`, `chocolate`, `strawberry`, `blueberry`
- **`fritter_flavor_valid`**: For fritters, flavor must be one of: `cinnamon`, `apple`

#### Conditional Glaze Validations
- **`donut_glaze_valid`**: For regular donuts, glaze must be one of: `plain`, `chocolate`, `strawberry`, `maple` (optional)
- **`fritter_glaze_valid`**: For fritters, glaze must be `plain` only (optional)

#### Conditional Filling Validations
- **`filling_valid`**: For filled donuts, filling must be one of: `vanilla-pudding`, `vanilla-cream`, `chocolate-pudding`, `raspberry`, `blueberry`, `apple` (required)
- **`unfilled_not_filled`**: For non-filled donuts (`plain`, `glazed`, `hole`, `cake`, `fritter`), filling must be blank (empty string or nil)

### Donut Type Combinations

| Donut Type | Valid Flavors | Valid Glazes | Filling Required | Notes |
|------------|---------------|--------------|------------------|-------|
| `plain`    | plain, chocolate, strawberry, blueberry | plain, chocolate, strawberry, maple | No (must be blank) | Basic donut |
| `glazed`   | plain, chocolate, strawberry, blueberry | plain, chocolate, strawberry, maple | No (must be blank) | Glazed donut |
| `filled`   | plain, chocolate, strawberry, blueberry | plain, chocolate, strawberry, maple | Yes (vanilla-pudding, vanilla-cream, chocolate-pudding, raspberry, blueberry, apple) | Filled donut |
| `hole`     | plain, chocolate, strawberry, blueberry | plain, chocolate, strawberry, maple | No (must be blank) | Donut hole |
| `cake`     | plain, chocolate, strawberry, blueberry | plain, chocolate, strawberry, maple | No (must be blank) | Cake donut |
| `fritter`  | cinnamon, apple | plain only | No (must be blank) | Apple or cinnamon fritter |

## Is this app used in production anywhere?

Probably not. This is intended as a sample app to show RubyLLM chats about model validations. It might be fun to have something show a year's worth of logged donuts for a user dropping into a big pile though!

## 🚀 Technology Stack

- **Rails 7.2.2.2** - Modern Rails framework
- **Ruby 3.3.8** - Latest stable Ruby version
- **SQLite** - Database for development
- **Importmap** - JavaScript module management
- **Turbo & Stimulus** - Hotwire components for modern UI

## 🔧 Key Dependencies

### Validation Engine
- **[be_valid gem](https://github.com/johnsinco/be_valid)** - Advanced validation framework with rule-based validation system
  - Custom validation rules with descriptive names
  - Conditional validation logic
  - Flexible comparison operators
  - Date validation with timezone support

### LLM Integration
- **[ruby_llm gem](https://github.com/crmne/ruby_llm)** - Ruby interface for Large Language Models
  - Local model support through Ollama
  - Chat interface capabilities
  - Model integration for AI-powered features

## 📋 Prerequisites

### Ollama with Llama 3.2
This application requires Ollama to be running locally with the Llama 3.2 model installed and accessible.

```bash
# Install Ollama (if not already installed)
curl -fsSL https://ollama.ai/install.sh | sh

# Pull and run Llama 3.2
ollama pull llama3.2
ollama run llama3.2
```

### System Requirements
- Ruby 3.3.8 or higher
- Rails 7.2.2 or higher
- SQLite3
- Node.js (for JavaScript dependencies)

## 🛠️ Installation & Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd validations_chat
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Setup database**
   ```bash
   rails db:create
   rails db:migrate
   ```

4. **Start the server**
   ```bash
   rails server
   ```

5. **Ensure Ollama is running**
   ```bash
   ollama run llama3.2
   ```

## 🧪 Testing

The application includes comprehensive test coverage for all validation rules:

```bash
# Run all tests
rails test

# Run specific model tests
rails test test/models/donut_log_test.rb

# Run tests with specific seed
rails test --seed 12345
```

### Test Coverage

The DonutLog model has **49 comprehensive tests** covering:

- **Core Validations**: ate_at, user_id, amount, donut_type
- **Conditional Flavor Validations**: Regular donuts vs. fritters
- **Conditional Glaze Validations**: Different glaze rules per donut type
- **Conditional Filling Validations**: Filling requirements and restrictions
- **Edge Cases**: Boundary values, nil handling, blank handling
- **Integration Tests**: Complex validation scenarios

### Test Organization

Tests are organized by validation rule name for easy debugging:
- `ate_in_past` rule tests
- `user_id_present` rule tests  
- `amount_min` and `amount_max` rule tests
- `donut_type_valid` rule tests
- `donut_flavor_valid` and `fritter_flavor_valid` rule tests
- `donut_glaze_valid` and `fritter_glaze_valid` rule tests
- `filling_valid` and `unfilled_not_filled` rule tests
- Integration and edge case tests

## 📊 Model Schema

```ruby
class DonutLog < ApplicationRecord
  # Attributes:
  # - user_id: integer (required, > 0)
  # - amount: decimal (required, > 0, <= 12)
  # - ate_at: datetime (required, must be in past)
  # - donut_type: string (required, one of: plain, glazed, filled, hole, cake, fritter)
  # - flavor: string (required, conditional based on donut_type)
  # - glaze: string (optional, conditional based on donut_type)
  # - filling: string (optional, conditional based on donut_type)
  # - location: string (optional)
  # - note: string (optional)
end
```

## 🔍 Validation Examples

```ruby
# Valid donut log - glazed donut
donut = DonutLog.new(
  user_id: 1,
  amount: 2.50,
  ate_at: 1.day.ago,
  donut_type: "glazed",
  flavor: "plain"
)

# Valid donut log - filled donut with all attributes
donut = DonutLog.new(
  user_id: 1,
  amount: 3.50,
  ate_at: 1.day.ago,
  donut_type: "filled",
  flavor: "chocolate",
  glaze: "chocolate",
  filling: "vanilla-cream"
)

# Valid donut log - fritter with correct flavor and glaze
donut = DonutLog.new(
  user_id: 1,
  amount: 2.00,
  ate_at: 1.day.ago,
  donut_type: "fritter",
  flavor: "apple",
  glaze: "plain"
)

# Invalid examples:

# Invalid - amount too high
donut.amount = 15.00  # Validation error: must be less or equal to 12

# Invalid - future date
donut.ate_at = 1.day.from_now  # Validation error: must be in the past

# Invalid - wrong flavor for fritter
donut.donut_type = "fritter"
donut.flavor = "chocolate"  # Validation error: only cinnamon/apple allowed

# Invalid - wrong glaze for fritter
donut.donut_type = "fritter"
donut.glaze = "chocolate"  # Validation error: only plain glaze allowed

# Invalid - filling present for non-filled donut
donut.donut_type = "glazed"
donut.filling = "vanilla-cream"  # Validation error: must be blank for non-filled donuts

# Invalid - filling missing for filled donut
donut.donut_type = "filled"
donut.filling = nil  # Validation error: filling required for filled donuts
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- [be_valid gem](https://github.com/johnsinco/be_valid) by johnsinco for the advanced validation framework
- [ruby_llm gem](https://github.com/crmne/ruby_llm) by crmne for LLM integration capabilities
- Ollama team for local LLM support

