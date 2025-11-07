# frozen_string_literal: true

# Class with invalid tag ordering
class InvalidTagOrder
  # Tags are in wrong order (return before param)
  # @return [String] result
  # @param value [Integer] input value
  def process(value)
    value.to_s
  end

  # Another method with wrong order
  # @raise [StandardError] on error
  # @return [Boolean] success
  # @param data [Hash] input data
  def validate(data)
    raise StandardError unless data.is_a?(Hash)

    true
  end
end
