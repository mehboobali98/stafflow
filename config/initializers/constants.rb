# frozen_string_literal: true

# Anchored at both ends: unanchored at the tail it matched any prefix, so
# 'someone@example.com.example' and 'someone@example.com <trailing junk>' both
# passed as 'someone@example.com'. The literal '.com' also rejected every
# other top-level domain.
EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\.[a-z]{2,}\z/i.freeze
PASSWORD_LENGTH = (6..128).freeze
MIN_LEAVE_COUNT = 0
MAX_LEAVE_COUNT = 40
LEAVE_COUNT_SCALE = 0.5
PAGE_SIZE = 5
TRUNCATE_LENGTH = 15
DEFAULT_TAX_RATE = 10
DEFAULT_VALUE = '--'
COUNTRIES_LIST = { Austrailia: 'Austrailia', Denmark: 'Denmark', England: 'England', Germany: 'Germany',
                   Netherlands: 'Netherlands', Pakistan: 'Pakistan', Russia: 'Russia' }.freeze
FLOAT_MAX = 99_999_999_999_999_999_999_999
FLOAT_MIN = -99_999_999_999_999_999_999_999
MIN_TAX_RATE = 0
MAX_TAX_RATE = 100
