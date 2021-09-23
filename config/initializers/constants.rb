# frozen_string_literal: true

EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\z/.freeze
PASSWORD_LENGTH = (6..128).freeze
VALID_LEAVE_RANGE = (1..40).freeze
LEAVE_COUNT_SCALE = 0.5
PAGE_SIZE = 5
TRUNCATE_LENGTH = 15
DEFAULT_TAX_RATE = 10
DEFAULT_VALUE = '--'
