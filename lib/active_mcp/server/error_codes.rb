# frozen_string_literal: true

module ActiveMcp
  module ErrorCode
    NOT_INITIALIZED = -32_002
    ALREADY_INITIALIZED = -32_002

    PARSE_ERROR = -32_700
    INVALID_REQUEST = -32_600
    METHOD_NOT_FOUND = -32_601
    INVALID_PARAMS = -32_602
    INTERNAL_ERROR = -32_603
  end
end
